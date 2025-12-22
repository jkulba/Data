#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo"
    exit 1
fi

if id "mssql" &>/dev/null; then
    echo "User 'mssql' already exists, continuing..."
else
    sudo useradd -m -d /opt/mssql -s /bin/bash mssql
    echo "User 'mssql' created"
fi

# Add mssql user to docker group for container access
sudo usermod -aG docker mssql
echo "User 'mssql' added to docker group"

sudo loginctl enable-linger mssql

sudo cp -v mssql.sh /opt/mssql/
sudo chmod +x /opt/mssql/mssql.sh

sudo cp -v mssql.service /etc/systemd/system

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable mssql.service

echo ""
echo "Installation complete!"
echo ""
echo "To start SQL Server:"
echo "  sudo systemctl start mssql.service"
echo ""
echo "To check status:"
echo "  sudo systemctl status mssql.service"
echo ""
echo "To view logs:"
echo "  sudo journalctl -xeu mssql.service"
echo ""
