# Cleanup script for GitHub Actions Self-Hosted Runner
# This script removes the runner configuration and files

$RunnerDir = "$env:USERPROFILE\actions-runner"

Write-Host "========================================"
Write-Host "GitHub Actions Runner Cleanup"
Write-Host "========================================"
Write-Host ""

if (!(Test-Path $RunnerDir)) {
    Write-Host "Runner directory not found at: $RunnerDir"
    Write-Host "Nothing to clean up."
    exit 0
}

Write-Host "Runner directory: $RunnerDir"
Write-Host ""
Write-Warning "This will remove the runner and all its configuration."
$confirm = Read-Host "Are you sure you want to continue? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "Cleanup cancelled."
    exit 0
}

# Stop runner if running as service
if (Test-Path "$RunnerDir\svc.sh") {
    Write-Host "Stopping runner service..."
    try {
        Set-Location $RunnerDir
        & ".\svc.sh" "stop" 2>$null
        & ".\svc.sh" "uninstall" 2>$null
    } catch {
        Write-Host "Service not installed or already stopped."
    }
}

# Remove runner configuration
if (Test-Path "$RunnerDir\config.cmd") {
    Write-Host "Removing runner configuration..."
    try {
        Set-Location $RunnerDir
        # Note: You'll need a PAT token to remove the runner
        Write-Host "To properly remove the runner from GitHub, run:"
        Write-Host "  cd $RunnerDir"
        Write-Host "  .\config.cmd remove --token YOUR_TOKEN"
    } catch {
        Write-Host "Could not remove configuration automatically."
    }
}

# Remove runner directory
Write-Host "Removing runner directory..."
try {
    Remove-Item -Path $RunnerDir -Recurse -Force
    Write-Host "Runner removed successfully!"
} catch {
    Write-Error "Failed to remove runner directory: $_"
    Write-Host "You may need to manually delete: $RunnerDir"
    exit 1
}

Write-Host ""
Write-Host "Cleanup complete!"
