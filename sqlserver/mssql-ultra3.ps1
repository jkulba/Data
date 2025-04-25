# Define variables
$ContainerName = "mssql-ultra3"
$Image = "mcr.microsoft.com/mssql/server:2022-latest"
$SaPassword = "P@ssword92"
$Port = 1433
$DataPath = "$env:USERPROFILE\.mssql-ultra5\mssql-data"

function Start-Container {
    Write-Host "Starting SQL Server container..."

    podman rm -f $ContainerName 2>$null

    if (!(Test-Path -Path $DataPath)) {
        New-Item -ItemType Directory -Path $DataPath | Out-Null
    }

    # Optional: Set ownership - depends on your platform (Linux vs Windows)
    if ($env:HOST_UID -and $env:HOST_GID) {
        & chown -R "$($env:HOST_UID):$($env:HOST_GID)" $DataPath
    }

    podman run -d `
        --user root `
        --name $ContainerName `
        --network host `
        -e "ACCEPT_EULA=Y" `
        -e "SA_PASSWORD=$SaPassword" `
        -v "$DataPath:/var/opt/mssql:Z" `
        $Image
}

function Stop-Container {
    Write-Host "Stopping SQL Server container..."
    podman stop $ContainerName
    podman rm $ContainerName
}

function Status-Container {
    podman ps -a --filter "name=$ContainerName"
}

param(
    [string]$Action = "help"
)

switch ($Action.ToLower()) {
    "start"  { Start-Container }
    "stop"   { Stop-Container }
    "status" { Status-Container }
    default  { Write-Host "Usage: script.ps1 {start|stop|status}" }
}

