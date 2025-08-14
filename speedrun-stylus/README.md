# Speedrun Stylus

> A challenge-based onboarding platform helping Rust and Web2 developers level up their Web3 skills through practical Stylus smart contract challenges.

## 🌟 Overview

Speedrun Stylus is an interactive learning platform inspired by Speedrun Ethereum, specifically designed for developers who want to master Arbitrum Stylus development. Through curated challenges, GitHub integration, and on-chain verification, developers can build real skills while earning verifiable achievements.

**🔗 Live Platform:** [https://speedrunstylus.com](https://speedrunstylus.com)

## 🚀 Quick Start: First 5 Challenges

- **Prerequisites**: Install Docker Desktop and ensure the engine is running. Pull the image `abxglia/speedrun-stylus:0.1` (see the Docker guide). Generate a GitHub PAT with all scopes.

  - Docker guide: [docker/README.md](../docker/README.md)
  - PAT guide: [github/PERSONAL_ACCESS_TOKEN.md](../github/PERSONAL_ACCESS_TOKEN.md)

- **For each challenge (1–5)**:

  - Create a new folder → open in VS Code/Cursor
  - Clone the correct branch for your chosen challenge using the commands here: [Clone commands → Step 1](../docker/README.md#step-1-clone-the-repository-for-your-challenge)
  - Place these two scripts in the ROOT of your challenge folder (reused for all challenges):
    - Setup + run: [powershell-7/speedrun.ps1](../powershell-7/speedrun.ps1)
    - Submit (3x): [github-push/speedrun_submissions.ps1](../github-push/speedrun_submissions.ps1)
  - Run setup script: [powershell-7/speedrun.ps1](../powershell-7/speedrun.ps1)
  - Verify app at http://localhost:3000/
  - Submit 3 times with: [github-push/speedrun_submissions.ps1](../github-push/speedrun_submissions.ps1) (run from project ROOT)
  - Already have a cloned repo? Use: [powershell7-readme-automation/speedrun_readme_steps.ps1](../powershell7-readme-automation/speedrun_readme_steps.ps1)

- **Full step-by-step guide**: [FIRST_FIVE_CHALLENGES.md](./FIRST_FIVE_CHALLENGES.md)

## ✨ Key Features

- **10+ Curated Challenges**: From Stylus fundamentals to advanced ZK projects
- **GitHub Integration**: PR-based submission flow with OAuth authentication
- **Public Leaderboard**: Showcase your progress and compete with peers
- **On-chain Verification**: Deploy to Arbitrum testnet with explorer integration
- **Self-Paced Learning**: Complete challenges at your own speed
- **ZK Focus**: Beginner-friendly introduction to zero-knowledge development

## 🎯 Challenge Structure

### **Core Stylus Projects** (4 Challenges)

- Basic storage and contract logic
- Token handling and transfers
- Advanced contract interactions
- Stylus-specific features and optimizations

### **Beginner ZK Challenges** (4 Challenges)

- Introduction to zero-knowledge concepts in Rust
- Basic proof generation and verification
- ZK circuit implementation with Stylus
- Practical ZK applications

### **Advanced ZK Challenges** (2+ Challenges)

- Complex proof systems
- Verifier contracts in Stylus
- Real-world ZK use cases
- Production-ready implementations

## 👥 Perfect For

- **Rust Developers** curious about smart contracts but finding Solidity limiting
- **Web2 Backend Engineers** wanting structured transition into Web3 development
- **ZK-Curious Developers** looking for accessible, project-based ZK learning
- **Career-focused developers** wanting to showcase their blockchain skills

## 🚀 What Makes It Special

### **Rust-Native Learning**

Unlike Solidity-focused platforms, Speedrun Stylus is built specifically for Rust developers entering Web3 through Arbitrum Stylus.

### **Verifiable Progress**

Every challenge completion creates a verifiable record through:

- GitHub submission history
- On-chain deployment verification
- Public achievement badges
- Transparent progress tracking

### **ZK Accessibility**

Makes zero-knowledge development approachable for beginners while providing depth for advanced practitioners.

### **Community-Driven Learning**

Connect with other developers, share achievements, and learn together in a supportive environment.

## 🏆 What You'll Gain

### **Practical Skills**

- **Real Stylus Experience**: Work with actual smart contract deployments
- **ZK Knowledge**: Learn zero-knowledge development from the ground up
- **Portfolio Projects**: Build deployable contracts you can showcase
- **Industry Best Practices**: Learn from experienced Stylus developers

### **Career Benefits**

- **Verifiable Achievements**: On-chain proof of your completed challenges
- **Public Recognition**: Showcase your rank and badges to potential employers
- **Networking**: Connect with other skilled Stylus developers
- **Job Opportunities**: Get discovered by projects looking for Stylus talent

### **Learning Experience**

- **Self-Paced**: Complete challenges on your own schedule
- **Progressive Difficulty**: Start simple and work up to advanced projects
- **Instant Feedback**: Get immediate results and guidance
- **Competitive Fun**: Challenge yourself and compete with peers

---

_Bridging Rust developers into Web3 through hands-on Stylus mastery._
