# Speedrun Scripts for macOS

This folder contains macOS-compatible versions of the Speedrun Stylus scripts, adapted from the PowerShell versions for Windows users.

## Scripts

### 1. `speedrun.sh`
The main speedrun script that clones a challenge repository and sets up the complete development environment.

**Features:**
- Clones the specified challenge branch from the repository
- Pulls the macOS-compatible Docker image with platform flag
- Sets up Docker container with volume mounts and caches
- Handles environment file configuration
- Deploys smart contracts automatically
- Starts the frontend development server
- Injects contract addresses into the frontend

**Usage:**
```bash
./speedrun.sh
```

### 2. `speedrun_readme_steps.sh`
Script for users who have already cloned a challenge repository and want to run it using the existing codebase.

**Features:**
- Detects existing `packages/nextjs` folder in current directory
- Works with pre-cloned challenge repositories
- Same Docker setup and deployment process as main script
- Preserves existing repository structure

**Usage:**
```bash
# Navigate to your cloned challenge repository first
cd your-challenge-repo
# Then run the script
/path/to/speedrun_readme_steps.sh
```

### 3. `speedrun_submissions.sh` ⭐ **NEW**
**Complete automation script** that handles the entire speedrun workflow including:
- Git repository setup and push automation
- Smart contract verification
- Smart cache configuration for gas optimization
- Rust crate automation with stylus-cache-sdk integration
- Contract deployment with cargo stylus
- macOS-specific terminal management

**Usage:**
```bash
./speedrun_submissions.sh
```

## Prerequisites

1. **Docker Desktop** - Must be installed and running
2. **Git** - Required for repository operations
3. **macOS** - These scripts are specifically designed for macOS

## Key Features of speedrun_submissions.sh

### 🔄 **Git Workflow Automation**
- Automatic git configuration detection and setup
- macOS Terminal.app integration for multi-terminal workflow
- Branch management and remote origin configuration
- Smart commit message handling

### 🔍 **Smart Contract Verification**
- Automatic Rust project detection (Cargo.lock, Cargo.toml, rust-toolchain.toml)
- Separate git repository setup for contract verification
- Dedicated verify branch creation and push
- Clean-up of temporary git repositories

### 🧠 **Smart Cache Configuration**
- Automatic smart-cache-cli installation (global/local fallback)
- Interactive configuration with retry mechanism
- TOML file generation and management (macOS sed compatibility)
- Gas optimization setup

### 🦀 **Rust Crate Automation**
- stylus-cache-sdk integration
- Automatic lib.rs modification with cache functions
- WebAssembly target installation
- Contract deployment with cargo stylus
- Contract address extraction and display

### 🍎 **macOS-Specific Features**
- AppleScript integration for Terminal.app
- macOS-compatible sed syntax for file modifications
- Platform-specific Docker image pulling
- Native macOS terminal workflow

## Key Differences from Windows Version

- **Shell Scripting**: Uses bash instead of PowerShell
- **Docker Platform**: Includes `--platform linux/amd64` flag for macOS compatibility
- **Docker Image**: Uses `abxglia/speedrun-stylus-mac:0.1` instead of the Windows version
- **Path Handling**: Uses Unix-style paths and commands
- **Command Availability**: Uses `command -v` instead of `Get-Command`
- **Input Handling**: Uses `read` instead of `Read-Host`
- **Terminal Management**: Uses AppleScript and Terminal.app instead of PowerShell terminals
- **File Editing**: Uses macOS-compatible sed syntax with empty backup extension

## Supported Challenges

1. **counter** - Basic counter smart contract
2. **nft** - NFT implementation
3. **vending-machine** - Vending machine smart contract
4. **multi-sig** - Multi-signature wallet
5. **stylus-uniswap** - Uniswap v2 implementation

## Error Handling

The scripts include comprehensive error handling:
- Checks for required dependencies (Docker, Git)
- Validates Docker daemon status
- Handles missing repositories gracefully
- Provides clear error messages and guidance

## Docker Configuration

The scripts set up Docker containers with:
- Volume mounts for source code and caches
- Port forwarding (3000:3000)
- Persistent caches for yarn, cargo, rust, and foundry
- Platform-specific image pulling

## Environment Variables

The scripts automatically configure:
- `NEXT_PUBLIC_RPC_URL` - Arbitrum Sepolia RPC endpoint
- `NEXT_PUBLIC_PRIVATE_KEY` - User's private key for frontend
- `PRIVATE_KEY` - Private key for contract deployment

## Making Scripts Executable

Before running the scripts, make them executable:

```bash
chmod +x speedrun.sh speedrun_readme_steps.sh
```

## Workflow Example

1. **Run the automation script**:
   ```bash
   ./speedrun_submissions.sh
   ```

2. **Follow the interactive prompts**:
   - Enter GitHub repository URL
   - Configure git identity
   - Provide wallet private key
   - Select challenge type

3. **Multi-terminal workflow**:
   - Script opens separate Terminal.app windows for git operations
   - Complete each terminal task as instructed
   - Return to main terminal to continue

4. **Optional automation steps**:
   - Smart contract verification
   - Smart cache configuration
   - Rust crate automation with deployment

## Terminal Integration

The scripts use AppleScript to integrate with macOS Terminal.app:
```applescript
osascript -e "tell app \"Terminal\" to do script \"script_path\""
```

If AppleScript is not available, manual execution instructions are provided.

## Troubleshooting

1. **Docker not found**: Install Docker Desktop for Mac
2. **Docker daemon not running**: Start Docker Desktop application
3. **Permission denied**: Run `chmod +x` on the script files
4. **Git not found**: Install Git using Homebrew or Xcode Command Line Tools
5. **Platform issues**: The scripts automatically handle platform-specific Docker image pulling
6. **Terminal not opening**: Ensure Terminal.app is available or use manual execution
7. **Smart cache errors**: Check network connectivity and contract addresses
8. **sed errors**: The scripts use macOS-compatible sed syntax automatically

## Support

These scripts are production-ready and have been adapted to ensure compatibility with macOS systems while maintaining all the functionality of the original Windows PowerShell versions. The automation script provides the same comprehensive workflow as the Windows version with macOS-specific optimizations.
