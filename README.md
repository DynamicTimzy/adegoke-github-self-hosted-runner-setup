# adegoke-github-self-hosted-runner-setup
This repository contains a complete solution for setting up and running a GitHub Actions self-hosted runner on a Windows PC. The project includes automated setup scripts, service configuration, and a test workflow to verify the runner functionality.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup Instructions](#detailed-setup-instructions)
- [Testing the Runner](#testing-the-runner)
- [Managing the Runner](#managing-the-runner)
- [Project Structure](#project-structure)
- [Challenges and Solutions](#challenges-and-solutions)
- [Production Considerations](#production-considerations)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [References](#references)

##  Overview

A self-hosted GitHub Actions runner that allows you to execute GitHub Actions workflows on your own infrastructure. This is useful for:

- Running workflows that require specific hardware or software configurations
- Accessing internal resources or networks
- Reducing costs for compute-intensive workflows
- Having more control over the execution environment

This project provides PowerShell scripts to automate the entire setup process on Windows systems.

##  Prerequisites

Before starting, ensure you have:

- **Operating System**: Windows 10/11 or Windows Server 2016+
- **PowerShell**: Version 5.1 or higher (pre-installed on Windows)
- **Administrator Access**: Required for service installation (optional)
- **GitHub Repository**: A repository where you have admin access
- **Network Access**: Ability to download files from GitHub and connect to github.com
- **Disk Space**: At least 1GB of free disk space

##  Quick Start

### Step 1: Clone this Repository

```powershell
git clone https://github.com/DynamicTimzy/adegoke-github-self-hosted-runner-setup.git
cd github-actions-self-hosted-runner
```

### Step 2: Run the Setup Script

```powershell
.\scripts\setup-runner.ps1
```

This script will:
- Download the latest GitHub Actions runner (version 2.311.0)
- Extract it to `%USERPROFILE%\actions-runner`
- Provide instructions for the next steps

### Step 3: Configure the Runner

1. Go to your GitHub repository settings:
   ```
   hhttps://github.com/DynamicTimzy/adegoke-github-self-hosted-runner-setup.git/settings/actions/runners/new
   ```

2. Copy the configuration token provided by GitHub

3. Run the configuration command:
   ```powershell
   cd $env:USERPROFILE\actions-runner
   .\config.cmd --url https://github.com/DynamicTimzy/adegoke-github-self-hosted-runner-setup.git --token YOUR_TOKEN
   ```

4. Follow the prompts to configure the runner (accept defaults for most options)

### Step 4: Start the Runner

**Option A: Run Interactively**
```powershell
.\scripts\start-runner.ps1
```
Press `Ctrl+C` to stop the runner.

**Option B: Install as Windows Service** (Recommended for production)
```powershell
# Run PowerShell as Administrator
.\scripts\install-service.ps1
```

The runner is now active and will pick up jobs from your GitHub repository!

## 📖 Detailed Setup Instructions

### Understanding the Runner Configuration

When you run `config.cmd`, you'll be prompted for:

1. **Runner Group**: Default is fine for most cases
2. **Runner Name**: A unique name to identify this runner (e.g., `windows-pc-01`)
3. **Runner Labels**: Additional labels beyond the default `self-hosted`, `Windows`, `X64` (optional)
4. **Work Folder**: Where workflow files will be stored (default: `_work`)

```powershell
# Configure with custom name and labels
.\config.cmd --url https://github.com/DynamicTimzy/adegoke-github-self-hosted-runner-setup.git --token YOUR_TOKEN --name "my-windows-runner" --labels windows,custom-label

# Configure for ephemeral use (runner is deleted after one job)
.\config.cmd --url https://github.com/DynamicTimzy/adegoke-github-self-hosted-runner-setup.git --token YOUR_TOKEN --ephemeral

# Configure without prompts (automated setup)
.\config.cmd --url https://github.com/DynamicTimzy/adegoke-github-self-hosted-runner-setup.git --unattended
```

## 🧪 Testing the Runner

This repository includes a test workflow that exercises various aspects of the self-hosted runner.

### Running the Test Workflow

1. Push this repository to your GitHub account
2. Ensure your runner is active
3. Go to the "Actions" tab in your repository
4. Select the "Test Self-Hosted Runner" workflow
5. Click "Run workflow"

The workflow will:
-  Display runner and system information
-  Test file operations
-  Test network connectivity
-  List installed development tools
-  Verify the runner is working correctly

### Using the Runner in Your Own Workflows

To use your self-hosted runner in a workflow, set `runs-on: self-hosted`:

```yaml
name: My Workflow

on: [push]

jobs:
  my-job:
    runs-on: self-hosted
    
    steps:
      - uses: actions/checkout@v4
      - name: Run a command
        run: Write-Host "Running on my self-hosted runner!"
```

## 🔧 Managing the Runner

### Starting and Stopping

**If running interactively:**
```powershell
# Start
.\scripts\start-runner.ps1

# Stop: Press Ctrl+C in the terminal
```

**If running as a service:**
```powershell
cd $env:USERPROFILE\actions-runner

# Check status
.\svc.sh status

# Start service
.\svc.sh start

# Stop service
.\svc.sh stop

# Restart service
.\svc.sh stop
.\svc.sh start
```

### Removing the Runner

```powershell
# Stop the service if running
cd $env:USERPROFILE\actions-runner
.\svc.sh stop
.\svc.sh uninstall

# Remove the runner from GitHub
.\config.cmd remove --token YOUR_TOKEN

# Clean up all files
.\scripts\cleanup-runner.ps1
```

## 📁 Project Structure

```
github-actions-self-hosted-runner/
├── .github/
│   └── workflows/
│       └── test-runner.yml      # Test workflow for the runner
├── scripts/
│   ├── setup-runner.ps1         # Main setup script
│   ├── start-runner.ps1         # Start runner interactively
│   ├── install-service.ps1      # Install as Windows service
│   └── cleanup-runner.ps1       # Remove runner and clean up
├── .gitignore                   # Git ignore file
└── README.md                    # This file
```

##  Challenges and Solutions

### Challenge 1: Runner Download and Extraction

**Issue**: Initially needed to handle both Linux/macOS and Windows environments with different package formats and commands.

**Solution**: Created platform-specific scripts using PowerShell for Windows, which handles:
- Automatic architecture detection
- Reliable download using .NET WebClient
- Native ZIP extraction with `Expand-Archive`
- Error handling for network and filesystem issues

### Challenge 2: Service Installation Complexity

**Issue**: Running the runner as a Windows service requires administrator privileges and understanding of Windows service management.

**Solution**: 
- Created a dedicated `install-service.ps1` script with clear privilege checks
- Added comprehensive error messages guiding users through the process
- Implemented validation checks to ensure the runner is configured before service installation
- Documented the difference between interactive and service modes

### Challenge 3: Configuration Token Security

**Issue**: GitHub provides a temporary token for runner registration that expires quickly and shouldn't be stored in scripts or version control.

**Solution**:
- Scripts prompt for tokens rather than accepting them as parameters
- Clear documentation emphasizes that tokens are temporary and should not be saved
- Instructions guide users to generate tokens on-demand from GitHub's UI

### Challenge 4: Runner Updates and Maintenance

**Issue**: Runners need to be updated regularly to maintain compatibility with GitHub Actions.

**Solution**:
- Parameterized runner version in setup script for easy updates
- Cleanup script ensures old installations are properly removed before reinstalling
- Documentation includes update procedures

### Challenge 5: Testing Workflow Compatibility

**Issue**: Needed to verify that the self-hosted runner works correctly with various GitHub Actions features.

**Solution**:
- Created a comprehensive test workflow that exercises:
  - Checkout action (most common action)
  - PowerShell scripting
  - File system operations
  - Network connectivity
  - Environment variable access
  - System information retrieval

 ##  Production Considerations

### What Would Be Different in Production?

1. **Infrastructure**
   - Use dedicated VMs or containers instead of personal PCs
   - Implement high availability with multiple runners
   - Use infrastructure-as-code (Terraform, ARM templates) for provisioning
   - Consider using Azure VMs, AWS EC2, or other cloud infrastructure

2. **Runner Configuration**
   - Use organization or enterprise-level runners instead of repository-level
   - Implement runner groups for different teams or purposes
   - Use ephemeral runners that are destroyed after each job
   - Configure runners with specific labels for different job types

3. **Automation**
   - Automate runner provisioning and deprovisioning
   - Use configuration management tools (Ansible, Chef, Puppet)
   - Implement auto-scaling based on workflow demand
   - Automate runner updates and patching

4. **Monitoring and Logging**
   - Implement centralized logging (ELK stack, Splunk, Azure Monitor)
   - Set up alerting for runner failures or performance issues
   - Monitor resource utilization (CPU, memory, disk)
   - Track workflow execution metrics

5. **Networking**
   - Place runners in isolated network segments (VLANs, subnets)
   - Implement firewall rules restricting inbound/outbound traffic
   - Use VPN or private endpoints for internal resource access
   - Configure proxy settings if required by corporate policies

6. **Backup and Disaster Recovery**
   - Implement automated backups of runner configurations
   - Document recovery procedures
   - Test disaster recovery scenarios regularly
   - Maintain redundant runners across multiple regions/availability zones

7. **Compliance and Auditing**
   - Log all runner activities for audit trails
   - Implement compliance controls (SOC2, HIPAA, etc.)
   - Regular security assessments and penetration testing
   - Document change management procedures

##  Security Considerations

### Implemented Security Measures

1. **User Privileges**
   - Scripts check for and warn against running as Administrator unnecessarily
   - Runner processes run under regular user accounts, not SYSTEM
   - Principle of least privilege applied throughout

2. **Token Management**
   - Configuration tokens are never stored in files or version control
   - Tokens are prompted for interactively when needed
   - Documentation emphasizes token security and temporary nature

3. **File System Isolation**
   - Runner installed in user profile directory
   - Work directory isolated from system files
   - Scripts validate paths before operations

4. **Network Security**
   - All communication with GitHub uses HTTPS
   - Scripts verify download integrity where possible
   - Test workflow includes network connectivity verification 

### Security Checklist

Before deploying to production:

- [ ] Verify repository is private
- [ ] Implement branch protection
- [ ] Configure required code reviews
- [ ] Set up secret scanning
- [ ] Enable Windows Firewall
- [ ] Install antivirus software
- [ ] Disable unnecessary services
- [ ] Implement network isolation
- [ ] Configure logging and monitoring
- [ ] Document incident response procedures
- [ ] Schedule regular security reviews
- [ ] Plan for runner rotation/replacement


##  Troubleshooting

### Runner Won't Start

**Symptoms**: Runner fails to start or connect to GitHub

**Solutions**:
1. Check network connectivity:
   ```powershell
   Test-NetConnection -ComputerName github.com -Port 443
   ```
2. Verify the runner is configured:
   ```powershell
   Test-Path $env:USERPROFILE\actions-runner\.runner
   ```
3. Check runner logs:
   ```powershell
   Get-Content $env:USERPROFILE\actions-runner\_diag\Runner_*.log


### Service Installation Fails

**Symptoms**: Error when running `install-service.ps1`

**Solutions**:
1. Ensure running PowerShell as Administrator
2. Verify runner is configured before installing service
3. Check if service already exists:
   ```powershell
   Get-Service | Where-Object {$_.Name -like "*actions.runner*"}
   ```

### Workflows Not Picking Up Jobs

**Symptoms**: Runner is online but workflows don't execute

**Solutions**:
1. Verify the workflow uses `runs-on: self-hosted`
2. Check runner labels match workflow requirements
3. Verify runner is online in GitHub Settings → Actions → Runners
4. Check if runner is idle (not currently running a job)

### Permission Errors During Workflow Execution

**Symptoms**: Workflows fail with access denied errors

**Solutions**:
1. Ensure the runner user has appropriate file system permissions
2. Check if antivirus is blocking file operations
3. Verify network access to required resources
4. Review Windows Event Logs for detailed errors

### Runner Goes Offline Unexpectedly

**Symptoms**: Runner shows offline in GitHub but process is running

**Solutions**:
1. Check network connectivity to github.com
2. Review runner logs for errors
3. Restart the runner:
   ```powershell
   .\svc.sh stop
   .\svc.sh start
   ```
4. Check for Windows updates or system reboots

##  References

- [GitHub Actions Self-Hosted Runners Documentation](https://docs.github.com/en/actions/hosting-your-own-runners)
- [GitHub Actions Runner Releases](https://github.com/actions/runner/releases)
- [Workflow Syntax for GitHub Actions](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [Security Hardening for GitHub Actions](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Using Self-Hosted Runners in a Workflow](https://docs.github.com/en/actions/hosting-your-own-runners/using-self-hosted-runners-in-a-workflow)