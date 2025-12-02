#!/usr/bin/env pwsh
# Helper script to tag a git repository using the annotated tag format.

param (
    [Parameter(Mandatory)]
    [string]$version,
    [string]$message
)

# Define the tag message
if ($message -eq $null) {
    $message = $version
}

# Create the annotated tag
git tag -a $version -m $message

# Push the tag to the remote repository
git push origin $version

Write-Output "Tagged repository with version $version and pushed to the remote repository."