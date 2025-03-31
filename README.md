# wg-monitor
Wireguard Monitor
# Wireguard Connection Monitor

This bash script monitors a Wireguard VPN connection to a remote server and automatically restarts the connection if the server becomes unreachable.

## Problem Statement

When using Wireguard to connect two sites and the internet connection on the "server side" becomes unreliable or hangs, requiring a manual restart of the connection from the client side (e.g., `wg-quick down wg0 && wg-quick up wg0`). This script automates this process by monitoring the connection and restarting it when needed.

## Usage

1. Save the script to a file, e.g., `wg-monitor.sh`
2. Make it executable: `chmod +x wg-monitor.sh`
3. Run it as root or with sudo: `sudo ./wg-monitor.sh`

## Configuration

You can customize the following parameters in the script to suit your needs:
- `SERVER_IP`: The IP address of the Wireguard server
- `INTERFACE`: The name of your Wireguard interface (typically "wg0")
- `PING_COUNT`: Number of ping attempts before a connection is considered failed
- `PING_TIMEOUT`: Timeout for each ping attempt
- `CHECK_INTERVAL`: Time between checks in seconds
- `LOG_FILE`: Path to the log file

## Setting up as a System Service

For permanent monitoring, you can set up the script as a system service:

1. Create a systemd service file:

```bash
sudo nano /etc/systemd/system/wg-monitor.service
```

2. Add the following content:

```
[Unit]
Description=Wireguard Connection Monitor
After=network.target

[Service]
Type=simple
ExecStart=/path/to/your/wg-monitor.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

3. Enable and start the service:

```bash
sudo systemctl enable wg-monitor.service
sudo systemctl start wg-monitor.service
```

4. Check the status:

```bash
sudo systemctl status wg-monitor.service
```

## Troubleshooting

- If the script fails to restart the connection, check if you have the necessary permissions to execute `wg-quick`
- Verify that the server IP address is correct
- Check the log file at `/var/log/wg-monitor.log` for error messages

## Requirements

- Bash
- Wireguard tools (`wg-quick`)
- Root access for managing the Wireguard interface