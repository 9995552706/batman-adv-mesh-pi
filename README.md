# Batman-adv Mesh Network for Raspberry Pi

A simple and general implementation of a Batman-adv mesh network using Raspberry Pi devices.

## What is Batman-adv?

Batman-adv (Better Approach To Mobile Adhoc Networking - Advanced) is a Linux kernel module that implements a Layer 2 mesh networking protocol. It creates a self-organizing mesh network where nodes automatically discover each other and find optimal routing paths.

## Features

- **Automatic topology discovery**: Nodes automatically find each other
- **Self-healing**: Network automatically reroutes if nodes fail
- **Layer 2 operation**: Works transparently with existing network protocols
- **Scalable**: Easy to add or remove nodes
- **Wireless optimized**: Designed for wireless mesh networks

## Quick Start

### Prerequisites

- Raspberry Pi (any model with WiFi)
- MicroSD card (8GB+)
- Power supply
- WiFi adapter (built-in or USB)

### Installation

1. **Flash Raspberry Pi OS Lite** to your MicroSD card
2. **Enable SSH** by creating an empty `ssh` file in the boot partition
3. **Boot and connect** via SSH

### Setup

```bash
# Clone this repository
git clone https://github.com/your-username/batman-adv-mesh-pi.git
cd batman-adv-mesh-pi

# Make the setup script executable
chmod +x setup_mesh.sh

# Run the setup script
sudo ./setup_mesh.sh
```

The script will:
- Install required packages
- Configure wireless interface for ad-hoc mode
- Setup Batman-adv mesh network
- Configure IP addresses
- Enable internet sharing (optional)
- Create startup service

## Network Configuration

### Default Settings

- **ESSID**: `meshnet`
- **Channel**: `1`
- **IP Range**: `192.168.1.x`
- **BSSID**: `02:12:34:56:78:9A`

### Multi-Node Setup

1. **Node 1**: Run setup script, enter node number `1` (IP: 192.168.1.1)
2. **Node 2**: Run setup script, enter node number `2` (IP: 192.168.1.2)
3. **Node 3**: Run setup script, enter node number `3` (IP: 192.168.1.3)

## Verification

### Check Mesh Status

```bash
# View mesh neighbors
sudo batctl o

# View routing table
sudo batctl r

# View interface status
sudo batctl if

# View mesh statistics
sudo batctl s
```

### Test Connectivity

```bash
# Ping between nodes
ping 192.168.1.1
ping 192.168.1.2
ping 192.168.1.3

# Check network interfaces
ip addr show

# Monitor mesh traffic
sudo tcpdump -i bat0
```

## Useful Commands

```bash
# Check wireless interface
iwconfig wlan0

# View network interfaces
ip addr show

# Check system logs
sudo journalctl -f

# Monitor mesh traffic
sudo tcpdump -i bat0

# Restart mesh network
sudo systemctl restart mesh-network.service
```

## Troubleshooting

### Common Issues

**Nodes not connecting:**
- Verify all nodes use the same ESSID (`meshnet`)
- Check that all nodes are on channel `1`
- Ensure batman-adv module is loaded: `lsmod | grep batman`

**No internet access:**
- Verify IP forwarding is enabled: `cat /proc/sys/net/ipv4/ip_forward`
- Check iptables rules: `sudo iptables -t nat -L POSTROUTING`
- Test internet connectivity: `ping 8.8.8.8`

**High latency:**
- Check signal strength: `iwconfig wlan0`
- Monitor network performance: `sudo tcpdump -i bat0`
- Check system resources: `htop`

### Debug Commands

```bash
# Check wireless interface status
iwconfig wlan0

# View network interfaces
ip addr show

# Check system logs
sudo journalctl -f

# Monitor mesh traffic
sudo tcpdump -i bat0

# View batman-adv debug information
sudo batctl if
sudo batctl o
sudo batctl r
```

## Customization

### Change Network Name

Edit the setup script and change the ESSID:

```bash
iwconfig wlan0 essid "my_mesh_network"
```

### Change IP Range

Edit the setup script and change the IP configuration:

```bash
ip addr add 10.0.0.1/24 dev bat0
```

### Change Channel

Edit the setup script and change the channel (use 1, 6, or 11):

```bash
iwconfig wlan0 channel 6
```

## Performance Optimization

### Channel Selection
- Use channels 1, 6, or 11 to avoid interference
- Scan for interference: `sudo iwlist wlan0 scan | grep -i channel`

### Transmit Power
```bash
# Set transmit power (if supported)
sudo iwconfig wlan0 txpower 20
```

### Antenna Configuration
```bash
# Check antenna status
iwconfig wlan0

# Configure external antenna if available
```

## Security Considerations

1. **Network isolation**: Use separate VLANs if needed
2. **Access control**: Implement proper authentication
3. **Regular updates**: Keep system updated
4. **Monitoring**: Monitor network traffic for anomalies

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Batman-adv project](https://www.open-mesh.org/projects/open-mesh/wiki)
- [Raspberry Pi Foundation](https://www.raspberrypi.org/)
- Open source community contributors

## Support

For support and questions:
- Create an issue on GitHub
- Check the [documentation](batman-adv-mesh-guide.md)
- Visit the [Batman-adv project website](https://www.open-mesh.org/projects/open-mesh/wiki) 
