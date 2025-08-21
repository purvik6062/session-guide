# Speedrun Scripts for Linux/WSL

This folder contains Linux/WSL-compatible versions of the Speedrun Stylus scripts, adapted from the PowerShell versions for Windows users.

## Scripts

### 1. `speedrun-setup.sh`
The main speedrun script that clones a challenge repository and sets up the complete development environment.

### 2. `speedrun-current-dir-setup.sh`
Script for users who have already cloned a challenge repository and want to run it using the existing codebase.

### 3. `speedrun_submissions.sh` ⭐ **NEW**
**Complete automation script** that handles the entire speedrun workflow including:
- Git repository setup and push automation
- Smart contract verification
- Smart cache configuration for gas optimization
- Rust crate automation with stylus-cache-sdk integration
- Contract deployment with cargo stylus
- Multi-terminal workflow management

## Prerequisites

1. **Docker** - Must be installed and running
2. **Git** - Required for repository operations
3. **Linux/WSL** - These scripts are designed for Linux environments

## Key Features of speedrun_submissions.sh

### 🔄 **Git Workflow Automation**
- Automatic git configuration detection and setup
- Multi-terminal push workflow with dedicated terminals
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
- TOML file generation and management
- Gas optimization setup

### 🦀 **Rust Crate Automation**
- stylus-cache-sdk integration
- Automatic lib.rs modification with cache functions
- WebAssembly target installation
- Contract deployment with cargo stylus
- Contract address extraction and display

### 🖥️ **Multi-Terminal Management**
- Automatic terminal detection (gnome-terminal, xterm, konsole)
- Separate terminals for different git operations
- Script generation for terminal execution
- Fallback manual execution instructions

## Usage

### Basic Setup (Clone and Run)
```bash
./speedrun-setup.sh
```

### Existing Project Setup
```bash
./speedrun-current-dir-setup.sh
```

### Complete Automation Workflow
```bash
./speedrun_submissions.sh
```

## Supported Challenges

1. **counter** - Basic counter smart contract
2. **nft** - NFT implementation
3. **vending-machine** - Vending machine smart contract
4. **multi-sig** - Multi-signature wallet
5. **stylus-uniswap** - Uniswap v2 implementation

## Key Differences from Windows Version

- **Shell Scripting**: Uses bash instead of PowerShell
- **Terminal Management**: Uses Linux terminal emulators (gnome-terminal, xterm, konsole)
- **Path Handling**: Uses Unix-style paths and commands
- **Command Availability**: Uses `command -v` instead of `Get-Command`
- **Input Handling**: Uses `read` instead of `Read-Host`
- **Process Management**: Uses bash job control instead of PowerShell background jobs

## Error Handling

The scripts include comprehensive error handling:
- Dependency validation (Docker, Git)
- Docker daemon status checks
- Repository structure validation
- Git configuration verification
- Smart contract deployment error handling
- Retry mechanisms for network operations

## Terminal Compatibility

The scripts automatically detect and use available terminal emulators:
1. **gnome-terminal** (preferred)
2. **xterm** (fallback)
3. **konsole** (KDE environments)
4. **Manual execution** (if no terminal emulator detected)

## Docker Configuration

- Uses standard Linux Docker image: `abxglia/speedrun-stylus:0.1`
- Volume mounts for source code and caches
- Port forwarding (3000:3000)
- Persistent caches for yarn, cargo, rust, and foundry

## Environment Variables

The scripts automatically configure:
- `NEXT_PUBLIC_RPC_URL` - Arbitrum Sepolia RPC endpoint
- `NEXT_PUBLIC_PRIVATE_KEY` - User's private key for frontend
- `PRIVATE_KEY` - Private key for contract deployment

## Making Scripts Executable

Before running the scripts, make them executable:

```bash
chmod +x speedrun-setup.sh speedrun-current-dir-setup.sh speedrun_submissions.sh
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
   - Script opens separate terminals for git operations
   - Complete each terminal task as instructed
   - Return to main terminal to continue

4. **Optional automation steps**:
   - Smart contract verification
   - Smart cache configuration
   - Rust crate automation with deployment

## Troubleshooting

1. **Docker not found**: Install Docker using your package manager
2. **Docker daemon not running**: Start Docker service
3. **Permission denied**: Run `chmod +x` on the script files
4. **Git not found**: Install Git using your package manager
5. **Terminal not opening**: Ensure you have a GUI environment or use manual execution
6. **Smart cache errors**: Check network connectivity and contract addresses

## Support

These scripts are production-ready and have been adapted to ensure compatibility with Linux/WSL systems while maintaining all the functionality of the original Windows PowerShell versions.