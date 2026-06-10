#!/usr/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo"
    exit 1
fi

if id "qdrant" &>/dev/null; then
    echo "User 'qdrant' already exists, continuing..."
else
    sudo useradd -m -d /opt/qdrant -s /bin/bash qdrant
    echo "User 'qdrant' created"
fi

# Add qdrant user to docker group for container access
sudo usermod -aG docker qdrant
echo "User 'qdrant' added to docker group"

sudo loginctl enable-linger qdrant

sudo cp -v qdrant.sh /opt/qdrant/
sudo chmod +x /opt/qdrant/qdrant.sh

sudo cp -v qdrant.service /etc/systemd/system

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable qdrant.service

echo ""
echo "Installation complete!"
echo ""
echo "To start Qdrant:"
echo "  sudo systemctl start qdrant.service"
echo ""
echo "To check status:"
echo "  sudo systemctl status qdrant.service"
echo ""
echo "To view logs:"
echo "  sudo journalctl -xeu qdrant.service"
echo ""
