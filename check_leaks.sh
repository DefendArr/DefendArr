#!/bin/bash

# Function to log messages with timestamp
function log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to check for leaks
function check_leaks() {
  # Fetch IP leak information from the VPN container
  local result=$(docker exec $VPN_CONTAINER_NAME curl -s ipleak.net/json/ 2>/dev/null)

  if [[ -z $result ]]; then
    log "Error: Unable to fetch IP leak information."
    return 1
  fi

  # Run the DNS leak test from the VPN container
  local dns_test_result=$(docker exec $VPN_CONTAINER_NAME /config/dnsleaktest.sh 2>/dev/null)

  if [[ -z $dns_test_result ]]; then
    log "Error: Unable to run DNS leak test."
    return 1
  fi

  # Check if there is a DNS leak
  local dns_leak=$(echo "$dns_test_result" | grep "DNS may be leaking")

  # Add your desired condition to check for leaks
  # For example, check if the ISP name is not your VPN provider's name
  local isp_name=$(echo "$result" | jq -r '.isp_name' 2>/dev/null)

  if [[ -z $isp_name ]]; then
    log "Error: Unable to extract ISP name from IP leak information."
    return 1
  fi

  if [[ $isp_name != $vpn_provider_name ]] || [[ ! -z $dns_leak ]]; then
    return 1
  else
    return 0
  fi
}

# Load configuration variables from the environment or config file
if [ -f "/config/config.env" ]; then
  source /config/config.env
else
  VPN_CONTAINER_NAME="${VPN_CONTAINER_NAME:-}"
  APP_CONTAINERS="${APP_CONTAINERS:-}"
  VPN_PROVIDER_NAME="${VPN_PROVIDER_NAME:-}"
  CHECK_INTERVAL_MINUTES="${CHECK_INTERVAL_MINUTES:-5}"
fi

# Ensure required variables are set
if [ -z "$VPN_CONTAINER_NAME" ] || [ -z "$APP_CONTAINERS" ] || [ -z "$VPN_PROVIDER_NAME" ]; then
  echo "Error: Missing required environment variables. Please set VPN_CONTAINER_NAME, APP_CONTAINERS, and VPN_PROVIDER_NAME."
  exit 1
fi

# Convert APP_CONTAINERS from a comma-separated string to an array
IFS=',' read -ra APP_CONTAINERS <<< "$APP_CONTAINERS"

# Main loop with a delay based on the CHECK_INTERVAL_MINUTES variable
while true; do
    if check_leaks; then
    log "No leaks detected. Continuing."
    else
    log "Leak detected. Stopping app containers and restarting VPN container."
    
    # Stop all app containers
    for container in "${APP_CONTAINERS[@]}"; do
        docker stop $container
    done

    # Restart the VPN container
    docker restart $VPN_CONTAINER_NAME

    # Initialize reconnect attempts counter
    reconnect_attempts=0

    # Reconnect loop with a maximum of 30 attempts
    while [[ $reconnect_attempts -lt 30 ]]; do
        log "Waiting for 1 minute before checking the connection (Attempt: $((reconnect_attempts + 1)))"
        
        # Wait for 1 minute before checking the connection
        sleep 1m

        # Check the connection with ipleak and dnsleaktest.sh
        if check_leaks; then
        log "VPN connection reestablished. Waiting for 5 minutes before starting app containers."
        
        # Wait for 5 minutes before starting the app containers again
        sleep 5m

        # Start all app containers
        for container in "${APP_CONTAINERS[@]}"; do
            docker start $container
        done
        break
        else
        log "VPN connection not reestablished. Retrying..."
        reconnect_attempts=$((reconnect_attempts + 1))
        fi
    done

    # If the maximum number of reconnect attempts is reached, restart the VPN container and inform the user
    if [[ $reconnect_attempts -ge 30 ]]; then
        log "Maximum number of reconnect attempts reached. Restarting the VPN container."
        docker restart $VPN_CONTAINER_NAME
    fi
  log "Waiting for ${CHECK_INTERVAL_MINUTES} minutes before the next check..."
  sleep "${CHECK_INTERVAL_MINUTES}m"
done