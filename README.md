![image](https://user-images.githubusercontent.com/131348548/234977628-2bd74432-2a3d-403e-b0be-7ccc001bc0ca.png)

# DefendArr

DefendArr is an IP and DNS leak detector to act as a killswitch for Docker containers that ensures your applications remain protected in case of a VPN connection failure. It periodically checks for IP and DNS leaks, stops application containers when leaks are detected, and restarts them once the VPN connection is reestablished.

## Features

- Monitors VPN connections for IP and DNS leaks
- Automatically stops application containers when leaks are detected
- Restarts application containers when the VPN connection is reestablished
- Configurable check interval

## Prerequisites

- Docker
- Docker Compose
- A VPN container with an accessible `dnsleaktest.sh` script

## Setup

1. Clone this repository:
<pre>
git clone https://github.com/defendarr/defendarr.git
</pre>

2. Change the current directory to `defendarr`:
```bash
cd defendarr
```

3. Modify the `.env` file to set your environment variables:
```
VPN_CONTAINER_NAME=your_vpn_container_name
APP_CONTAINERS=app_container_1,app_container_2,app_container_3
VPN_PROVIDER_NAME=your_vpn_provider_name
CHECK_INTERVAL_MINUTES=5
```

Replace `your_vpn_container_name`, `app_container_1,app_container_2,app_container_3`, and `your_vpn_provider_name` with the appropriate values.

4. To find your VPN provider's name, run the following command in your VPN container:

```curl ipleak.net/json/```

Look for the `isp_name` field in the output JSON.

5. Place the `dnsleaktest.sh` script inside the ```/config/```directory accessible by your VPN container. If there is no /config volume for the container, create one and put it there. You can download the script from [here](https://github.com/macvk/dnsleaktest).

6. Build the DefendArr Docker image:

```docker build -t yourusername/defendarr .```

7. Run DefendArr using Docker Compose:

```docker-compose up -d```

8. Check the logs for any issues:

```docker logs defendarr```

## Configuration

You can configure DefendArr using the following environment variables:

- `VPN_CONTAINER_NAME`: The name of your VPN container.
- `APP_CONTAINERS`: A comma-separated list of application container names that should be stopped when leaks are detected.
- `VPN_PROVIDER_NAME`: The name of your VPN provider.
- `CHECK_INTERVAL_MINUTES`: The interval (in minutes) between leak checks. *Note: Setting this value too low may result in being banned from certain services.*

## Support

If you encounter any issues or have questions, please open an issue on GitHub or reach out via email, mailto:DefendArr@pm.me

## Contributing

Pull requests and bug reports are welcome! If you'd like to contribute to the project, please fork the repository and submit a pull request with your changes.

## License

DefendArr is released under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support DefendArr

If you find DefendArr useful and would like to support the project, please consider donating. Your contributions will help ensure the continued development and improvement of DefendArr. We accept donations through the following methods:

- **PayPal**: [Donate via PayPal](https://www.paypal.com/donate?hosted_button_id=YQBHSUQ47FNQS)

Thank you for your support!
