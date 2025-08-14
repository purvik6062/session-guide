# First 5 Speedrun Stylus Challenges: Step-by-Step Guide

This guide walks you through completing and submitting the first five challenges with minimal setup and confusion. Follow the steps in order for each challenge.

---

## 1) Prerequisites (one-time)

- Install Docker Desktop and ensure the Docker engine is running.
  - Guide: [Docker setup and usage](https://github.com/purvik6062/session-guide/blob/main/docker/README.md)
- Pull the required Docker image:
  ```bash
  docker pull abxglia/speedrun-stylus:0.1
  ```
- Generate a GitHub Personal Access Token (PAT) with all listed scopes.
  - Guide: [Generate PAT and select all scopes](https://github.com/purvik6062/session-guide/blob/main/github/PERSONAL_ACCESS_TOKEN.md)

---

## 2) Do this for each challenge (1–5)

1. Create a fresh empty folder for your chosen challenge (e.g., `Desktop/speedrun-counter`) and open it in VS Code/Cursor.

   Then clone the correct branch into that folder (run exactly one of these):

   - Counter:
     ```
     git clone --single-branch -b counter https://github.com/abhi152003/speedrun_stylus.git ./
     ```
   - NFT:
     ```
     git clone --single-branch -b nft https://github.com/abhi152003/speedrun_stylus.git ./
     ```
   - Vending Machine:
     ```
     git clone --single-branch -b vending-machine https://github.com/abhi152003/speedrun_stylus.git ./
     ```
   - Multisig Wallet:
     ```
     git clone --single-branch -b multi-sig https://github.com/abhi152003/speedrun_stylus.git ./
     ```
   - Uniswap V2:
     ```
     git clone --single-branch -b stylus-uniswap https://github.com/abhi152003/speedrun_stylus.git ./
     ```

   Note: Use only the command for the challenge you're working on. For the next challenge, create a new folder and use its corresponding command.

2. Place these two scripts in the ROOT of your challenge folder (you'll reuse the same two scripts for all challenges):

   - Setup + run: [powershell7-readme-automation/speedrun_readme_steps.ps1](https://github.com/purvik6062/session-guide/blob/main/powershell7-readme-automation/speedrun_readme_steps.ps1)
   - Submit (3x): [github-push/speedrun_submissions.ps1](https://github.com/purvik6062/session-guide/blob/main/github-push/speedrun_submissions.ps1)

3. Run the setup script to set up, deploy, and start the frontend:

   Open a terminal in the project ROOT and run:

   ```powershell
   ./speedrun_readme_steps.ps1
   ```

   This script will:

   - Use your cloned repo
   - Pull/start the Docker container
   - Install dependencies (yarn install)
   - Prompt for your private key (prefix will be added as 0x)
   - Deploy the contract and inject the address into the debug UI
   - Start the frontend at http://localhost:3000/

4. Open the app at http://localhost:3000/ and verify your contract is deployed (address visible in the debug UI).
5. When ready to submit, run the submission script from the ROOT of the same challenge folder.

---

## 3) Submit your solution (As per challenge we have 3 variants of stylus usage so devs to test and submit 3 variants of code)

Use the submission helper script to push your work and handle the required extra submissions:

- Script: [github-push/speedrun_submissions.ps1](https://github.com/purvik6062/session-guide/blob/main/github-push/speedrun_submissions.ps1)

Open a terminal in the project ROOT and run:

```powershell
./speedrun_submissions.ps1
```

What it does for you:

- Prompts for your PAT, GitHub repo URL, git user.name/email
- Ensures/sets the correct remote with PAT and branch
- Commits and pushes your changes from inside the container
- Offers optional Smart Cache and Rust crate automations for subsequent submissions

Submission flow per challenge:

1. Create a new public GitHub repository.
2. Run the submission script and provide:
   - Your PAT (with all scopes)
   - The repository URL (https://github.com/yourusername/your-repo.git)
   - Your git user.name and user.email
   - Your private key (the script will prepend 0x if missing)
3. Complete the first push.
4. For the 2nd and 3rd submissions, run the same script again and follow prompts.
   - Tip: For optimization-focused re-submissions, see the Smart Cache steps in the script and the Rust crate guidance here: [rust-crate-and-toml-guide](https://github.com/purvik6062/session-guide/blob/main/rust-crate-and-toml-guide/README.md)

---

## Quick reference per challenge

- Create a new folder → open in VS Code/Cursor → clone the correct branch
- Run: [powershell7-readme-automation/speedrun_readme_steps.ps1](https://github.com/purvik6062/session-guide/blob/main/powershell7-readme-automation/speedrun_readme_steps.ps1)
- Verify UI at http://localhost:3000/
- Submit 3 times with: [github-push/speedrun_submissions.ps1](https://github.com/purvik6062/session-guide/blob/main/github-push/speedrun_submissions.ps1)

---

## Troubleshooting

- Docker not running: Start Docker Desktop and verify the engine shows "Engine running".
- Port 3000 already in use: Remove the existing container: `docker rm -f speedrun-stylus` and re-run the script.
- PAT errors: Ensure PAT has all scopes selected (see the PAT guide linked above).
- Private key format: The scripts will prepend 0x if missing; ensure you use the correct wallet key.
- Repository push issues: Double-check remote URL and branch; the submission script will help configure both.

---

You're set. Repeat these steps for challenges 1–5 to complete and submit smoothly.
