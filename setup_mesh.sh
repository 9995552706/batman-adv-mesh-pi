#!/bin/bash

# Batman-adv Mesh Network Setup Script
# This script sets up a basic Batman-adv mesh network on Raspberry Pi

set -e  # Exit on any error

echo "=== Batman-adv Mesh Network Setup ==="
echo "This script will configure your Raspberry Pi for mesh networking"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (use sudo)"
    exit 1
fi

# Function to install packages
install_packages() {
    echo "Installing required packages..."
    apt update
    apt install -y batctl wireless-tools iw net-tools iproute2
    echo "Packages installed successfully"
}

# Function to stop conflicting services
stop_services() {
    echo "Stopping conflicting network services..."
    systemctl stop wpa_supplicant 2>/dev/null || true
    systemctl disable wpa_supplicant 2>/dev/null || true
    systemctl stop dhcpcd 2>/dev/null || true
    systemctl disable dhcpcd 2>/dev/null || true
    systemctl stop NetworkManager 2>/dev/null || true
    systemctl disable NetworkManager 2>/dev/null || true
    echo "Services stopped"
}

# Function to setup wireless interface
setup_wireless() {
    echo "Configuring wireless interface..."
    
    # Unblock WiFi
    rfkill unblock all
    sleep 2
    
    # Check if wlan0 exists
    if ! ip link show wlan0 > /dev/null 2>&1; then
        echo "Error: wlan0 interface not found"
        echo "Please ensure your WiFi adapter is connected"
        exit 1
    fi
    
    # Configure wireless interface
    ip link set wlan0 down
    iwconfig wlan0 mode ad-hoc
    iwconfig wlan0 essid "meshnet"
    iwconfig wlan0 ap "02:12:34:56:78:9A"
    iwconfig wlan0 channel 1
    ip link set wlan0 up
    
    echo "Wireless interface configured"
}

# Function to setup batman-adv
setup_batman() {
    echo "Setting up Batman-adv..."
    
    # Load batman-adv module
    modprobe batman-adv
    
    # Add wireless interface to batman-adv
    batctl if add wlan0
    
    # Bring up bat0 interface
    ip link set up dev bat0
    
    echo "Batman-adv setup complete"
}

# Function to configure IP address
configure_ip() {
    echo "Configuring IP address..."
    
    # Get node number from user
    read -p "Enter node number (1, 2, 3, etc.): " node_num
    
    if [[ ! "$node_num" =~ ^[0-9]+$ ]]; then
        echo "Invalid node number. Using 1 as default."
        node_num=1
    fi
    
    # Configure IP address
    ip addr add 192.168.1.$node_num/24 dev bat0
    
    echo "IP address configured: 192.168.1.$node_num"
}

# Function to setup internet sharing (optional)
setup_internet_sharing() {
    echo ""
    read -p "Do you want to enable internet sharing? (y/n): " enable_sharing
    
    if [[ "$enable_sharing" =~ ^[Yy]$ ]]; then
        echo "Setting up internet sharing..."
        
        # Enable IP forwarding
        echo 1 > /proc/sys/net/ipv4/ip_forward
        
        # Configure NAT
        iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
        iptables -A FORWARD -i bat0 -o eth0 -j ACCEPT
        iptables -A FORWARD -i eth0 -o bat0 -m state --state RELATED,ESTABLISHED -j ACCEPT
        
        echo "Internet sharing enabled"
    else
        echo "Internet sharing disabled"
    fi
}

# Function to create startup script
create_startup_script() {
    echo "Creating startup script..."
    
    cat > /usr/local/bin/start_mesh.sh << 'EOF'
#!/bin/bash

# Start Batman-adv mesh network
modprobe batman-adv
batctl if add wlan0
ip link set up dev bat0

# Configure IP (change node number as needed)
ip addr add 192.168.1.1/24 dev bat0

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Configure NAT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i bat0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o bat0 -m state --state RELATED,ESTABLISHED -j ACCEPT
EOF
    
    chmod +x /usr/local/bin/start_mesh.sh
    echo "Startup script created: /usr/local/bin/start_mesh.sh"
}

# Function to create systemd service
create_systemd_service() {
    echo "Creating systemd service..."
    
    cat > /etc/systemd/system/mesh-network.service << EOF
[Unit]
Description=Batman-adv Mesh Network
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/start_mesh.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl enable mesh-network.service
    echo "Systemd service created and enabled"
}

# Function to display status
show_status() {
    echo ""
    echo "=== Mesh Network Status ==="
    echo "Wireless interface:"
    iwconfig wlan0 | grep -E "(ESSID|Channel|Mode)"
    
    echo ""
    echo "Batman-adv status:"
    batctl if
    
    echo ""
    echo "Mesh neighbors:"
    batctl o
    
    echo ""
    echo "Network interfaces:"
    ip addr show bat0
    
    echo ""
    echo "Test connectivity with: ping 192.168.1.1"
}

# Main execution
main() {
    echo "Starting Batman-adv mesh network setup..."
    
    # Install packages
    install_packages
    
    # Stop conflicting services
    stop_services
    
    # Setup wireless interface
    setup_wireless
    
    # Setup batman-adv
    setup_batman
    
    # Configure IP address
    configure_ip
    
    # Setup internet sharing
    setup_internet_sharing
    
    # Create startup script
    create_startup_script
    
    # Create systemd service
    create_systemd_service
    
    # Show status
    show_status
    
    echo ""
    echo "=== Setup Complete ==="
    echo "Your mesh network is now configured!"
    echo ""
    echo "Useful commands:"
    echo "  Check neighbors: sudo batctl o"
    echo "  View routing: sudo batctl r"
    echo "  Monitor traffic: sudo tcpdump -i bat0"
    echo "  Restart mesh: sudo systemctl restart mesh-network.service"
    echo ""
    echo "For additional nodes, run this script and use different node numbers."
}

# Run main function
main 