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

sudo loginctl enable-linger mssql

sudo cp -v mssql.sh /opt/mssql/
sudo chmod +x /opt/mssql/mssql.sh

sudo cp -v mssql.service /etc/systemd/system
sudo chmod +x /etc/systemd/system/mssql.service 

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now mssql.service

sudo systemctl start mssql.service

systemctl status mssql.service
journalctl -xeu mssql.service
