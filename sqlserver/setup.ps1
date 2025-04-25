# Define container name, username, and password for SQL Server inside the container
$ContainerName = "mssql-ultra3"
$Username = "sa"          # SQL Server username
$Password = "P@ssword92"  # SQL Server password

# SQL script path inside the container
$SqlScriptPathInContainer = "/tmp/setup-acmedb-database.sql"

# Local path to the SQL script
$LocalSqlScript = "setup-acmedb-database.sql"

# Copy the SQL script into the container
Write-Host "Copying SQL script to the container..."
podman cp $LocalSqlScript "$ContainerName:$SqlScriptPathInContainer"

# Build the sqlcmd command
$SqlCmdCommand = "/opt/mssql-tools18/bin/sqlcmd -S localhost -U '$Username' -P '$Password' -N -C -i '$SqlScriptPathInContainer'"

# Execute the command inside the container
Write-Host "Executing SQL script inside the container..."
$execResult = podman exec -it $ContainerName bash -c $SqlCmdCommand

# Output the result of the command
Write-Output $execResult

# Check for errors (simulate Bash’s $? by checking last exit code)
if ($LASTEXITCODE -eq 0) {
    Write-Host "Database 'AcmeDB', schema 'Recruits', and table 'Recruits.Users' created and populated successfully inside the container."
} else {
    Write-Host "An error occurred during database setup inside the container. Check the output above for details (it's from within the container)."
}

