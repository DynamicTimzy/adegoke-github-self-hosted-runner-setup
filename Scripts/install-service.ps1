# Install GitHub Actions Runner as a Windows Service
# Run script with Administrator privileges

param(
    [string]$RunnerDir = "$env:USERPROFILE\actions-runner"
)

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (!$isAdmin) {
    Write-Error "This script must be run as Administrator"
    Write-Host "Right-click PowerShell and select 'Run as Administrator'"
    exit 1
}

Write-Host "========================================"
Write-Host "Install Runner as Windows Service"
Write-Host "========================================"
Write-Host ""

# Check if runner exists
if (!(Test-Path "$RunnerDir\config.cmd")) {
    Write-Error "Runner not found at $RunnerDir"
    Write-Host "Please run setup-runner.ps1 and configure the runner first"
    exit 1
}

# Check if runner is configured
if (!(Test-Path "$RunnerDir\.runner")) {
    Write-Error "Runner is not configured"
    Write-Host "Please run config.cmd first to configure the runner"
    exit 1
}

Write-Host "Installing runner as a Windows service..."
Write-Host "Runner directory: $RunnerDir"
Write-Host ""

Set-Location $RunnerDir

# Install service
try {
    & ".\svc.sh" "install"
    Write-Host ""
    Write-Host "Service installed successfully!"
    Write-Host ""
    
    # Start service
    Write-Host "Starting service..."
    & ".\svc.sh" "start"
    Write-Host ""
    Write-Host "Service started successfully!"
    Write-Host ""
    Write-Host "To check service status, run:"
    Write-Host "  cd $RunnerDir"
    Write-Host "  .\svc.sh status"
    Write-Host ""
    Write-Host "To stop the service, run:"
    Write-Host "  .\svc.sh stop"
    Write-Host ""
    Write-Host "To uninstall the service, run:"
    Write-Host "  .\svc.sh uninstall"
    
} catch {
    Write-Error "Failed to install service: $_"
    exit 1
}
