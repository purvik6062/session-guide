# Using Docker for Speedrun Stylus Project (Arbitrum Sepolia Deployment)

This guide explains how to use a pre-built Docker image to set up and deploy the Speedrun Stylus project to the Arbitrum Sepolia testnet. The Docker image includes all necessary dependencies (Node.js, Yarn, Rust with nightly toolchain and rust-src, cargo-stylus, Foundry, etc.), so you don't need to install them manually. This is tailored for deploying via `run-sepolia-deploy.sh` and running the frontend.

## Prerequisites
- **Docker Installed**:
  - **Ubuntu**: Install Docker Engine with `sudo apt update && sudo apt install docker.io` (or follow [official docs](https://docs.docker.com/engine/install/ubuntu/)).
  - **Windows**: Install Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop/). Ensure it's running and configured (e.g., enable WSL2 backend if using WSL).
- Git installed on your host machine for cloning the repo.
- An Ethereum wallet with Arbitrum Sepolia testnet ETH (get from a faucet like [Arbitrum's official faucet](https://faucet.arbitrum.io/)).
- Your wallet's private key (prefixed with `0x`) for the `.env` file—**never commit this to Git or share publicly**.

## General Steps (Common to Both Platforms)
1. **Clone the Repository**:
   ```
   git clone -b counter https://github.com/abhi152003/speedrun_stylus.git speedrun_stylus_counter
   cd speedrun_stylus_counter
   ```
   - **Tip for Windows Users**: To avoid line-ending issues (CRLF), clone with `git clone ... --config core.autocrlf=false`.

2. **Pull the Docker Image**:
   ```
   docker pull abxglia/speedrun-stylus-sepolia:latest
   ```

## Steps for Ubuntu Users
1. **Run the Docker Container**:
   ```
   docker run -it \
       -v $(pwd):/app \
       -p 3000:3000 \
       abxglia/speedrun-stylus-sepolia:latest
   ```
   - This mounts your local project directory to `/app` in the container and exposes port 3000 for the frontend.

2. **Inside the Container**:
   - Install dependencies:
     ```
     yarn install
     ```
   - Configure the environment for Sepolia:
     ```
     cd packages/nextjs
     cp .env.example .env
     ```
     Edit `.env` (use `nano .env` or `vi .env`):
     ```
     NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
     NEXT_PUBLIC_PRIVATE_KEY=0xYourPrivateKeyHere  # Replace with your wallet's private key
     ```
   - Deploy the contract:
     ```
     cd /app/packages/stylus-demo
     bash run-sepolia-deploy.sh
     ```
     - Copy the outputted contract address and transaction hash.
   - Update the frontend:
     - Edit `/app/packages/nextjs/app/debug/DebugContracts.tsx` (e.g., `nano /app/packages/nextjs/app/debug/DebugContracts.tsx`).
     - Paste the contract address into the relevant variable.
   - Start the frontend:
     ```
     cd /app/packages/nextjs
     yarn run dev
     ```

3. **Access the App**:
   - Open `http://localhost:3000` in your browser to interact with the deployed contract on Sepolia.

## Steps for Windows Users
1. **Run the Docker Container** (in PowerShell):
   ```
   docker run -it `
       -v ${PWD}:/app `
       -p 3000:3000 `
       abxglia/speedrun-stylus-sepolia:latest
   ```
   - Or as a single line:
     ```
     docker run -it -v ${PWD}:/app -p 3000:3000 abxglia/speedrun-stylus-sepolia:latest
     ```
   - Ensure your project directory is shared in Docker Desktop (Settings > Resources > File Sharing).
   - This mounts your local project directory to `/app` in the container and exposes port 3000.

2. **Inside the Container**:
   - Install dependencies:
     ```
     yarn install
     ```
   - Fix line endings if needed (common on Windows-cloned repos):
     ```
     cd /app/packages/stylus-demo
     dos2unix run-sepolia-deploy.sh
     ```
   - Configure the environment for Sepolia:
     ```
     cd packages/nextjs
     cp .env.example .env
     ```
     Edit `.env` (use `nano .env` or `vi .env`):
     ```
     NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
     NEXT_PUBLIC_PRIVATE_KEY=0xYourPrivateKeyHere  # Replace with your wallet's private key
     ```
   - Deploy the contract:
     ```
     cd /app/packages/stylus-demo
     bash run-sepolia-deploy.sh
     ```
     - Copy the outputted contract address and transaction hash.
   - Update the frontend:
     - Edit `/app/packages/nextjs/app/debug/DebugContracts.tsx` (e.g., `nano /app/packages/nextjs/app/debug/DebugContracts.tsx`).
     - Paste the contract address into the relevant variable.
   - Start the frontend:
     ```
     cd /app/packages/nextjs
     yarn run dev
     ```

3. **Access the App**:
   - Open `http://localhost:3000` in your browser to interact with the deployed contract on Sepolia.

## Troubleshooting
- **Line Ending Errors** (e.g., `'\r': command not found`): Run `dos2unix run-sepolia-deploy.sh` inside the container.
- **Insufficient Funds**: Ensure your wallet has Sepolia ETH from a faucet.
- **Permission Issues**: If volume mount fails, check Docker Desktop file sharing settings (Windows) or run `sudo docker run ...` (Ubuntu).
- **Build/Deployment Errors**: Verify Rust versions with `rustup show` and `cargo stylus --version` inside the container.
- **Exiting the Container**: Use `Ctrl+C` to stop the frontend, then `exit` to leave the shell. To re-enter a running container: `docker exec -it <container_id> bash` (get ID from `docker ps`).
