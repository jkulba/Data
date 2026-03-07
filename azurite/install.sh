#!/usr/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo"
    exit 1
fi

if id "azurite" &>/dev/null; then
    echo "User 'azurite' already exists, continuing..."
else
    sudo useradd -m -d /opt/azurite -s /bin/bash azurite
    echo "User 'azurite' created"
fi

# Add azurite user to docker group for container access
sudo usermod -aG docker azurite
echo "User 'azurite' added to docker group"

sudo loginctl enable-linger azurite

sudo cp -v azurite.sh /opt/azurite/
sudo chmod +x /opt/azurite/azurite.sh

sudo cp -v azurite.service /etc/systemd/system

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable azurite.service

echo ""
echo "Installation complete!"
echo ""
echo "To start Azurite:"
echo "  sudo systemctl start azurite.service"
echo ""
echo "To check status:"
echo "  sudo systemctl status azurite.service"
echo ""
echo "To view logs:"
echo "  sudo journalctl -xeu azurite.service"
echo ""
