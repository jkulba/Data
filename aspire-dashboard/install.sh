#!/usr/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo"
    exit 1
fi

if id "aspire" &>/dev/null; then
    echo "User 'aspire' already exists, continuing..."
else
    sudo useradd -m -d /opt/aspire -s /bin/bash aspire
    echo "User 'aspire' created"
fi

# Add aspire user to docker group for container access
sudo usermod -aG docker aspire
echo "User 'aspire' added to docker group"

sudo loginctl enable-linger aspire

sudo cp -v azurite.sh /opt/aspire/
sudo chmod +x /opt/aspire/azurite.sh

sudo cp -v azurite.service /etc/systemd/system

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable azurite.service

echo ""
echo "Installation complete!"
echo ""
echo "To start Aspire:"
echo "  sudo systemctl start aspire.service"
echo ""
echo "To check status:"
echo "  sudo systemctl status aspire.service"
echo ""
echo "To view logs:"
echo "  sudo journalctl -xeu aspire.service"
echo ""
