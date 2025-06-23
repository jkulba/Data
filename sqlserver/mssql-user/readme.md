# Run Mssql Server Pod as MSSQL User

## Use Case

The goal is to run mssql-server as a pod under the mssql user in pod rootless mode.  In order to run the pod in rootless mode, we need to create a mssql user.  The following commands detail each step needed to create the dedicated user and run the pod.


## Pre-requisites

- Podman CLI                              
- Podman Desktop

## User Setup

(1) Create the mssql user

Step 1: Create user

```shell
sudo useradd -m -d /opt/mssql -s /bin/bash mssql
```

- The `-d` creates the home directory.
- The `s` sets the shell to bash for the new user.

Step 2: Enable linger on mssql user

```shell
sudo loginctl enable-linger mssql
```

Step 3: Assume mssql user 

```shell
sudo su - mssql
```

Step 4: Show podman version

```shell
podman version
```

Expectations

- No errors. 


## Pod Script

(2) Copy the mssql.sh script to the new mssql home directory: /opt/mssql






