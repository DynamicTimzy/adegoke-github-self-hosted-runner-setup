# GitHub Actions Self-Hosted Runner Setup Script for Windows
# This script downloads and configures a GitHub Actions runner on Windows

param(
    [string]$RunnerVersion = "2.311.0",
    [string]$RunnerDir = "$env:USERPROFILE\actions-runner"
)

Write-Host "========================================"
Write-Host "GitHub Actions Self-Hosted Runner Setup"
Write-Host "========================================"

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Warning "Running as Administrator. It's recommended to run the runner as a regular user."
    $continue = Read-Host "Do you want to continue? (y/n)"
    if ($continue -ne 'y') {
        exit 1
    }
}

Write-Host ""
Write-Host "Configuration:"
Write-Host "  Runner Version: $RunnerVersion"
Write-Host "  Installation Directory: $RunnerDir"
Write-Host ""

# Create runner directory
Write-Host "Creating runner directory..."
if (!(Test-Path $RunnerDir)) {
    New-Item -ItemType Directory -Path $RunnerDir -Force | Out-Null
}

Set-Location $RunnerDir

# Download runner
Write-Host "Downloading GitHub Actions Runner..."
$DownloadUrl = "https://github.com/actions/runner/releases/download/v$RunnerVersion/actions-runner-win-x64-$RunnerVersion.zip"
$ZipFile = "actions-runner.zip"

Write-Host "Downloading from: $DownloadUrl"

try {
    # Use .NET WebClient for reliable downloads
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($DownloadUrl, "$RunnerDir\$ZipFile")
    
    # Verify download
    if (!(Test-Path $ZipFile)) {
        throw "Failed to download runner package"
    }
    
    Write-Host "Download complete!"
    
} catch {
    Write-Error "Download failed: $_"
    exit 1
}

# Extract runner
Write-Host "Extracting runner..."
try {
    Expand-Archive -Path $ZipFile -DestinationPath $RunnerDir -Force
    Remove-Item $ZipFile
    Write-Host "Extraction complete!"
} catch {
    Write-Error "Extraction failed: $_"
    exit 1
}

Write-Host ""
Write-Host "========================================"
Write-Host "Runner downloaded successfully!"
Write-Host "========================================"
Write-Host ""
Write-Host "Next steps:"
Write-Host ""
Write-Host "1. Go to GitHub repository settings:"
Write-Host "   https://github.com/DynamicTimzy/adegoke-github-self-hosted-runner-setup.git"
Write-Host ""
Write-Host "2. Copy the token from the GitHub page"
Write-Host ""
Write-Host "3. Run the configuration command:"
Write-Host "   cd $RunnerDir"
Write-Host "   .\config.cmd --url https://github.com/DynamicTimzy/adegoke-github-self-hosted-runner-setup.git --token YOUR_TOKEN"
Write-Host ""
Write-Host "4. Start the runner:"
Write-Host "   .\run.cmd"
Write-Host ""
Write-Host "5. (Optional) Install as a Windows service:"
Write-Host "   .\svc.sh install"
Write-Host "   .\svc.sh start"
Write-Host ""
Write-Host "Installation directory: $RunnerDir"
