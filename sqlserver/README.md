MS SQL Server in Docker Container

_System Pre-requisites:_

- Podman - 
- Docker CLI


## Start using shell script

```shell
./sql.sh start | stop | status
```

## Automatic start using systemd

(1) Create new directory

```
/opt/mssql-ultra3
```

(2) Create the `mssql` user (No home, no shell)

```
sudo useradd --system --no-create-home --shell /usr/sbin/nologin mssql
```
- Verify the user

```
getent passwd mssql
```

(3) Copy sql.sh to /opt/mssql-ultra3

(4) Create a systemd service

```
[Unit]
Description=Start mssql-ultra3
After=network.target

[Service]
Type=oneshot
ExecStart=/opt/mssql-ultra3/sql.sh
RemainAfterExit=true
User=mssql

[Install]
WantedBy=multi-user.target
```


