#!/bin/bash

cp -v sql.sh /opt/mssql-ultra3/
cp -v mssql-ultra3.service /etc/systemd/system 

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now mssql-ultra3.service

sudo systemctl start mssql-ultra3.service

systemctl status mssql-ultra3.service
journalctl -xeu mssql-ultra3.service

