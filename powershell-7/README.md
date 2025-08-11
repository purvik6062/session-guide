# PowerShell 7 Installation Guide for Windows

This guide provides step-by-step instructions for installing PowerShell 7 on Windows using two methods: winget (Windows Package Manager) and MSI installer.

## Prerequisites

- Windows 10 version 1903 or later, or Windows Server 2019 or later
- Administrator privileges (recommended for system-wide installation)

## Method 1: Installing with winget (Recommended)

### What is winget?
Windows Package Manager (winget) is a command-line tool that helps you discover, install, upgrade, remove, and configure applications on Windows computers.

### Prerequisites for winget
- Windows 10 version 1809 or later
- winget is included with Windows 11 and recent Windows 10 updates
- If winget is not available, install it from the [Microsoft Store](https://www.microsoft.com/p/app-installer/9nblggh4nns1)

### Installation Steps

1. **Open Command Prompt or PowerShell as Administrator**
   - Press `Windows + X` and select "Terminal (Admin)" or "Command Prompt (Admin)"

2. **Check if winget is available**
   ```cmd
   winget --version
   ```

3. **Install PowerShell 7**
   ```cmd
   winget install --id Microsoft.Powershell --source winget
   ```

4. **Verify Installation**
   ```cmd
   pwsh --version
   ```

## Method 2: Installing with MSI Package

### Download Options

1. **Visit the PowerShell GitHub Releases Page**
   - Go to: https://github.com/PowerShell/PowerShell/releases
   - Find the latest release

2. **Choose the appropriate MSI package:**
   - **x64 systems:** `PowerShell-7.x.x-win-x64.msi`
   - **x86 systems:** `PowerShell-7.x.x-win-x86.msi`
   - **ARM64 systems:** `PowerShell-7.x.x-win-arm64.msi`

### Installation Steps

1. **Download the MSI file**
   - Click on the appropriate MSI file for your system architecture

2. **Run the installer**
   - Double-click the downloaded MSI file
   - If prompted by User Account Control, click "Yes"

3. **Follow the installation wizard**
   - Accept the license agreement
   - Choose installation location (default is recommended)
   - Select additional options:
     - ✅ **Add PowerShell to PATH environment variable**
     - ✅ **Register Windows Event Logging manifest**
     - ✅ **Enable PowerShell remoting** (if needed)

4. **Complete installation**
   - Click "Install" and wait for completion
   - Click "Finish" when done


## Post-Installatio

### Verify Installation

1. **Check version:**
   ```cmd
   pwsh --version
   ```

2. **Open PowerShell 7:**
   ```cmd
   pwsh
   ```

3. **View detailed version information:**
   ```powershell
   $PSVersionTable
   ```

### Key Differences from Windows PowerShell

- **PowerShell 7:** Use `pwsh` command
- **Windows PowerShell 5.1:** Use `powershell` command
- Both can coexist on the same system

### Accessing PowerShell 7

- **Command line:** Type `pwsh`
- **Start Menu:** Look for "PowerShell 7"

## Updating PowerShell 7

### Using winget
```cmd
winget upgrade Microsoft.Powershell
```

### Using MSI
Download and run the latest MSI installer - it will upgrade the existing installation.

### Using PowerShell (automated)
```powershell
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
```

## Troubleshooting

### Common Issues

1. **"winget is not recognized"**
   - Install App Installer from Microsoft Store
   - Update Windows to the latest version

2. **Installation fails with permission error**
   - Run Command Prompt/PowerShell as Administrator
   - Check Windows execution policy: `Get-ExecutionPolicy`

3. **PowerShell 7 not found after installation**
   - Restart your terminal/command prompt
   - Check if `pwsh` (not `powershell`) command works
   - Verify PATH environment variable includes PowerShell 7 directory

### Uninstalling PowerShell 7

**Via winget:**
```cmd
winget uninstall Microsoft.Powershell
```

**Via Windows Settings:**
- Go to Settings → Apps → Apps & features
- Search for "PowerShell 7"
- Click and select "Uninstall"

## Additional Resources

- [Official PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
- [PowerShell GitHub Repository](https://github.com/PowerShell/PowerShell/releases)
---

**Note:** This installation will not replace Windows PowerShell 5.1, which remains available via the `powershell` command. PowerShell 7 uses the `pwsh` command.

## ⚠️ Important: Restart Required

**After installation, restart your laptop/PC to ensure that IDEs (Visual Studio Code, Visual Studio, etc.) recognize PowerShell 7 as the default PowerShell version.**

Without restarting, your development environment may continue using Windows PowerShell 5.1 instead of the newly installed PowerShell 7.

---

**Note:** This installation will not replace Windows PowerShell 5.1, which remains available via the `powershell` command. PowerShell 7 uses the `pwsh` command.