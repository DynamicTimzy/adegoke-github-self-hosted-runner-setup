# Script for GitHub Actions Runner
# Run this after configuring the runner with config.cmd

$RunnerDir = "$env:USERPROFILE\actions-runner"

if (!(Test-Path "$RunnerDir\run.cmd")) {
    Write-Error "Runner not found at $RunnerDir"
    Write-Host "Please run setup-runner.ps1 first"
    exit 1
}

Write-Host "Starting GitHub Actions Runner..."
Write-Host "Runner directory: $RunnerDir"
Write-Host ""
Write-Host "Press Ctrl+C to stop the runner"
Write-Host ""

Set-Location $RunnerDir
& ".\run.cmd"
