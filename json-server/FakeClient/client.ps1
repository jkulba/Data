param (
    [string]$jsonPayload
)

# Define the API endpoint
$apiUrl = "http://localhost:3000/users"

# Define headers (modify as needed)
$headers = @{
    "Content-Type" = "application/json"
    "SubscriptionKey" = "123456"
}

# Make the POST request
try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $jsonPayload -Headers $headers
    Write-Output "Response received: $($response | ConvertTo-Json -Depth 10)"
} catch {
    Write-Error "Error invoking API: $_"
}
