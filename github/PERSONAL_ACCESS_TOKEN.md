# GitHub with Personal Access Token (PAT) - Complete Guide

> A comprehensive tutorial for pushing code to GitHub using Personal Access Tokens for secure authentication.

## 🌟 Overview

This guide walks you through the complete process of setting up and using Personal Access Tokens (PAT) to push code to GitHub repositories. PATs are the recommended way to authenticate with GitHub instead of using passwords.

## 🔑 Why Use Personal Access Tokens?

- **Enhanced Security**: More secure than password authentication
- **Fine-grained Permissions**: Control exactly what the token can access
- **Easy to Revoke**: Can be revoked immediately if compromised
- **Required for 2FA**: Necessary when two-factor authentication is enabled
- **API Access**: Works with both Git operations and GitHub API

## 📋 Prerequisites

Before starting, ensure you have:

- A GitHub account
- Git installed on your local machine
- A code repository ready to push

## 🚀 Step-by-Step Guide

### Step 1: Generate a Personal Access Token

1. **Log into GitHub**

   - Go to [GitHub.com](https://github.com) and sign in

2. **Navigate to Settings**

   - Click your profile picture (top-right corner)
   - Select **"Settings"** from the dropdown menu

3. **Access Developer Settings**

   - Scroll down to the bottom of the left sidebar
   - Click **"Developer settings"**

4. **Go to Personal Access Tokens**

   - Click **"Personal access tokens"**
   - Select **"Tokens (classic)"** or **"Fine-grained tokens"** (recommended)

5. **Generate New Token**

   - Click **"Generate new token"**
   - Choose **"Generate new token (classic)"** for simplicity

6. **Configure Token Settings**

   ```
   Note: Descriptive name (e.g., "My Local Development")
   Expiration: Choose appropriate duration (30 days, 90 days, etc.)
   Select scopes: Check the boxes for required permissions
   ```

7. **Required Scopes for Code Pushing**

   - ✅ **repo** - Full control of private repositories
   - ✅ **workflow** - Update GitHub Action workflows (if needed)
   - ✅ **write:packages** - Upload packages (if needed)

8. **Generate and Copy Token**
   - Click **"Generate token"**
   - **⚠️ Important**: Copy the token immediately (you won't see it again!)
   - Store it safely (consider using a password manager)

### Step 2: Configure Git with Your Token

#### Option A: Use Token During Clone/Push (Recommended)

```bash
# Clone repository using token
git clone https://YOUR_TOKEN@github.com/username/repository.git

# Or configure remote with token
git remote set-url origin https://YOUR_TOKEN@github.com/username/repository.git
```

#### Option B: Configure Git Credentials

```bash
# Configure Git with your GitHub username
git config --global user.name "Your GitHub Username"
git config --global user.email "your-email@example.com"

# Set up credential helper (Windows)
git config --global credential.helper manager-core

# Set up credential helper (macOS)
git config --global credential.helper osxkeychain

# Set up credential helper (Linux)
git config --global credential.helper store
```

### Step 3: Push Code to GitHub

#### For a New Repository

```bash
# 1. Initialize Git repository
git init

# 2. Add all files
git add .

# 3. Create initial commit
git commit -m "Initial commit"

# 4. Add remote origin with token
git remote add origin https://YOUR_TOKEN@github.com/username/repository.git

# 5. Push to GitHub
git push -u origin main
```

#### For an Existing Repository

```bash
# 1. Add and commit changes
git add .
git commit -m "Your commit message"

# 2. Push to GitHub
git push origin main
```

### Step 4: Authentication During Push

When prompted for credentials:

- **Username**: Your GitHub username
- **Password**: Your Personal Access Token (NOT your GitHub password)

```bash
Username for 'https://github.com': your-username
Password for 'https://your-username@github.com': your_personal_access_token
```

## 🔒 Security Best Practices

### Token Security

- **Never share your token** in code, screenshots, or public places
- **Use environment variables** for CI/CD and scripts
- **Set appropriate expiration dates** (not "no expiration")
- **Use minimal required permissions** for each token
- **Revoke unused tokens** regularly

### Environment Variables

```bash
# Linux/macOS
export GITHUB_TOKEN="your_token_here"
git clone https://$GITHUB_TOKEN@github.com/username/repo.git

# Windows PowerShell
$env:GITHUB_TOKEN="your_token_here"
git clone https://$env:GITHUB_TOKEN@github.com/username/repo.git
```

### Using .env Files (for applications)

```bash
# .env file (add to .gitignore!)
GITHUB_TOKEN=your_personal_access_token

# Use in scripts
git clone https://${GITHUB_TOKEN}@github.com/username/repo.git
```

## 🛠️ Common Commands

### Basic Git Workflow with PAT

```bash
# Check current repository status
git status

# Add specific files
git add filename.txt

# Add all changes
git add .

# Commit with message
git commit -m "Descriptive commit message"

# Push to main branch
git push origin main

# Pull latest changes
git pull origin main

# Check remote URL
git remote -v

# Update remote URL with token
git remote set-url origin https://YOUR_TOKEN@github.com/username/repo.git
```

### Branch Management

```bash
# Create and switch to new branch
git checkout -b feature-branch-name

# Push new branch to GitHub
git push -u origin feature-branch-name

# Switch between branches
git checkout main
git checkout feature-branch-name

# Merge branch (after switching to main)
git merge feature-branch-name
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. **Authentication Failed**

```
Error: remote: Invalid username or password
```

**Solution**: Make sure you're using your PAT as the password, not your GitHub password.

#### 2. **Token Expired**

```
Error: remote: Invalid authentication credentials
```

**Solution**: Generate a new token and update your configuration.

#### 3. **Permission Denied**

```
Error: remote: Permission to user/repo.git denied
```

**Solution**: Check that your token has the correct scopes (especially `repo`).

#### 4. **Repository Not Found**

```
Error: remote: Repository not found
```

**Solution**: Verify the repository URL and ensure your token has access to it.

### Debug Commands

```bash
# Check Git configuration
git config --list

# Verify remote URL
git remote -v

# Test connectivity
git ls-remote origin
```

## 🔄 Token Management

### Updating an Existing Token

```bash
# Update remote URL with new token
git remote set-url origin https://NEW_TOKEN@github.com/username/repository.git
```

### Revoking a Token

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Find your token in the list
3. Click **"Delete"** or **"Revoke"**
4. Confirm the action

### Token Expiration

- Set up calendar reminders before expiration
- Consider using longer expiration periods for stable projects
- Automate token renewal in CI/CD systems

## 📚 Additional Resources

- [GitHub PAT Documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Git Configuration Guide](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)
- [GitHub CLI Alternative](https://cli.github.com/)

## ⚠️ Important Notes

- **Tokens are like passwords** - treat them with the same security
- **Fine-grained tokens** offer better security for organization repositories
- **Classic tokens** are simpler but have broader access
- **Always use HTTPS** URLs when using tokens
- **Keep tokens out of version control** (add to .gitignore)

---

_Secure, efficient, and reliable GitHub authentication with Personal Access Tokens._
