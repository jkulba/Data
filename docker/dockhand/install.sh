#!/usr/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo"
    exit 1
fi

if id "dockhand" &>/dev/null; then
    echo "User 'dockhand' already exists, continuing..."
else
    sudo useradd -m -d /opt/dockhand -s /bin/bash dockhand
    echo "User 'dockhand' created"
fi

# Add dockhand user to docker group for container access
sudo usermod -aG docker dockhand
echo "User 'dockhand' added to docker group"

sudo loginctl enable-linger dockhand

sudo cp -v dockhand.sh /opt/dockhand/
sudo chmod +x /opt/dockhand/dockhand.sh

sudo cp -v dockhand.service /etc/systemd/system

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable dockhand.service

echo ""
echo "Installation complete!"
echo ""
echo "To start Dockhand:"
echo "  sudo systemctl start dockhand.service"
echo ""
echo "To check status:"
echo "  sudo systemctl status dockhand.service"
echo ""
echo "To view logs:"
echo "  sudo journalctl -xeu dockhand.service"
echo ""
