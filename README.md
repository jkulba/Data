# Data Tools

**(1) JSON-SERVER**
A node module used to serve JSON endpoints of supplied data in a db.json file.  _Very useful for quick testing._

Resource: https://github.com/typicode/json-server

**(2) PostgreSQL**
Docker compose files to host the PostgreSQL server and the pgAdmin tool.

Resource: https://hub.docker.com/_/postgres/

**(3) MS SQL Server**
Bash script uses latest version of the docker image from Microsoft.

```shell
./sql.sh start | stop | status
```

Resources:
- https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-ver16&tabs=cli&pivots=cs1-bash

**(3) Seq**
Bash script uses latest version.

```shell
./seq.sh start | stop | status
```

Resources:
- https://datalust.co/
