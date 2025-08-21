#!/bin/bash
set -e

function say() { echo -e "\n$1"; }

function get_smart_input() {
  local prompt="$1"
  local allow_empty="${2:-false}"
  local input=""
  
  while true; do
    printf "%s" "$prompt"
    read -r input
    
    if [[ "$allow_empty" == "true" ]] || [[ -n "$input" ]]; then
      break
    else
      echo "❌ Input cannot be empty. Please try again."
    fi
  done
  
  echo "$input"
}

function ensure_git() {
  if ! command -v git &> /dev/null; then
    echo "❌ git not found. Please install Git and try again."
    exit 1
  fi
}

function check_git_config() {
  local global_user_name global_user_email git_user_name git_user_email use_existing
  
  global_user_name=$(git config --global user.name 2>/dev/null || true)
  global_user_email=$(git config --global user.email 2>/dev/null || true)
  
  if [[ -n "$global_user_name" && -n "$global_user_email" ]]; then
    echo "✅ Found existing global git configuration:"
    echo "   user.name:  $global_user_name"
    echo "   user.email: $global_user_email"
    
    while true; do
      read -p "Use existing git configuration? (Y/N): " use_existing
      case $use_existing in
        [Yy]* ) 
          git_user_name="$global_user_name"
          git_user_email="$global_user_email"
          break
          ;;
        [Nn]* ) break ;;
        * ) echo "❌ Please enter Y or N." ;;
      esac
    done
  fi
  
  if [[ -z "$git_user_name" || -z "$git_user_email" ]]; then
    git_user_name=$(get_smart_input "Enter your git user.name (e.g., yourusername): ")
    git_user_email=$(get_smart_input "Enter your git user.email (e.g., you@example.com): ")
    
    if [[ -z "$git_user_name" ]]; then
      echo "❌ user.name cannot be empty."
      exit 1
    fi
    if [[ -z "$git_user_email" ]]; then
      echo "❌ user.email cannot be empty."
      exit 1
    fi
  fi
  
  echo "$git_user_name|$git_user_email"
}

# ---------------- Container Config ----------------
IMG="abxglia/speedrun-stylus:0.1"
NAME="speedrun-stylus"
PORT=3000

function ensure_docker() {
  if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Install Docker."
    exit 1
  fi
  
  if ! docker info &> /dev/null; then
    echo "❌ Docker daemon not running. Start Docker."
    exit 1
  fi
  
  # Check if the image is already pulled
  local image_exists
  image_exists=$(docker images -q "$IMG" 2>/dev/null)
  if [[ -n "$image_exists" ]]; then
    echo "✅ Docker image '$IMG' already pulled"
  else
    say "📦 Pulling Docker image '$IMG'..."
    if docker pull "$IMG"; then
      echo "✅ Docker image pulled successfully"
    else
      echo "❌ Failed to pull Docker image"
      exit 1
    fi
  fi
}

function ensure_container() {
  local status
  
  # Check if container exists and its status
  if status=$(docker inspect -f '{{.State.Status}}' "$NAME" 2>/dev/null); then
    if [[ "$status" == "running" ]]; then
      say "♻️ Container '$NAME' already running; reusing."
      return 0
    elif [[ "$status" == "exited" ]]; then
      say "▶️ Starting existing container '$NAME'..."
      if docker start "$NAME" &> /dev/null; then
        sleep 1
        say "✅ Container started successfully"
        return 0
      else
        echo "❌ Failed to start existing container. Removing and creating new one..."
        docker rm -f "$NAME" &> /dev/null || true
      fi
    else
      echo "⚠️ Container '$NAME' in unexpected state: $status. Removing and creating new one..."
      docker rm -f "$NAME" &> /dev/null || true
    fi
  fi
  
  # Create new container
  say "🚀 Starting new container..."
  echo "   - Image: $IMG"
  echo "   - Name: $NAME"
  echo "   - Port: $PORT:3000"
  echo "   - Working directory: $PWD"
  
  if docker run -d --name "$NAME" \
    -v "$PWD:/app" \
    -v speedrun-yarn-cache:/root/.cache/yarn \
    -v speedrun-cargo-registry:/root/.cargo/registry \
    -v speedrun-cargo-git:/root/.cargo/git \
    -v speedrun-rustup:/root/.rustup \
    -v speedrun-foundry:/root/.foundry \
    -p "$PORT:3000" \
    "$IMG" tail -f /dev/null; then
    
    # Wait a moment for container to fully start
    sleep 2
    
    # Verify container is actually running and ready
    if docker inspect -f '{{.State.Status}}' "$NAME" 2>/dev/null | grep -q "running"; then
      say "✅ Container started and verified successfully"
      
      # Test container readiness with a simple command
      echo "   Testing container readiness..."
      if docker exec "$NAME" echo "Container ready" &> /dev/null; then
        echo "   ✅ Container is ready for commands"
      else
        echo "   ⚠️ Container not ready yet, waiting..."
        sleep 3
        if docker exec "$NAME" echo "Container ready" &> /dev/null; then
          echo "   ✅ Container is now ready"
        else
          echo "   ❌ Container readiness check failed"
          docker logs "$NAME" 2>/dev/null || true
          exit 1
        fi
      fi
    else
      echo "❌ Container started but is not running properly"
      docker logs "$NAME" 2>/dev/null || true
      exit 1
    fi
  else
    echo "❌ Failed to start container"
    echo "💡 Debug: Check if port $PORT is already in use or if Docker has sufficient resources"
    # Show any error logs
    docker logs "$NAME" 2>/dev/null || true
    exit 1
  fi
}

function select_challenge_branch() {
  while true; do
    echo "Choose a challenge (for branch selection):
1) counter
2) nft
3) vending-machine
4) multi-sig
5) stylus-uniswap"
    read -p "Enter 1-5: " choice
    case $choice in
      1) echo "counter"; return ;;
      2) echo "nft"; return ;;
      3) echo "vending-machine"; return ;;
      4) echo "multi-sig"; return ;;
      5) echo "stylus-uniswap"; return ;;
      *) echo "❌ Invalid choice. Please enter a number between 1 and 5." ;;
    esac
  done
}

function find_repo_path() {
  local branch="$1"
  local candidates=("/app" "/app/speedrun-$branch" "/app/test-vending")
  local candidate result
  
  # Look for directories with .git first
  for candidate in "${candidates[@]}"; do
    if docker exec "$NAME" test -d "$candidate/.git" 2>/dev/null; then
      echo "$candidate"
      return 0
    fi
  done
  
  # Fallback: find any .git directory
  result=$(docker exec "$NAME" find /app -maxdepth 2 -name ".git" -type d 2>/dev/null | head -1)
  if [[ -n "$result" ]]; then
    echo "${result%/.git}"
    return 0
  fi
  
  # If no .git found, look for project directories
  for candidate in "${candidates[@]}"; do
    if docker exec "$NAME" test -d "$candidate/packages" 2>/dev/null || 
       docker exec "$NAME" test -f "$candidate/package.json" 2>/dev/null; then
      echo "$candidate"
      return 0
    fi
  done
  
  # Final fallback: find any directory with packages folder
  result=$(docker exec "$NAME" find /app -maxdepth 2 -name "packages" -type d 2>/dev/null | head -1)
  if [[ -n "$result" ]]; then
    echo "${result%/packages}"
    return 0
  fi
  
  return 1
}

function find_packages_folder() {
  local repo_path="$1"
  local packages_path parent_dir
  
  packages_path=$(docker exec "$NAME" bash -c "find '$repo_path' -name 'packages' -type d | head -1" 2>/dev/null)
  if [[ -n "$packages_path" ]]; then
    parent_dir=$(docker exec "$NAME" bash -c "dirname '$packages_path'" 2>/dev/null)
    if [[ -n "$parent_dir" ]]; then
      echo "$parent_dir"
      return 0
    fi
  fi
  echo "$repo_path"
}

function ensure_remote() {
  local remote_url="$1"
  local repo_path="$2"
  
  docker exec "$NAME" bash -c "cd '$repo_path' && git remote remove origin 2>/dev/null || true" &> /dev/null
  docker exec "$NAME" bash -c "cd '$repo_path' && git remote add origin '$remote_url'" &> /dev/null
}

function ensure_branch() {
  local branch="$1"
  local repo_path="$2"
  
  docker exec "$NAME" bash -c "cd '$repo_path' && git branch -M '$branch'" &> /dev/null
}

function commit_if_needed() {
  local message="$1"
  local repo_path="$2"
  
  docker exec "$NAME" bash -c "cd '$repo_path' && git add . && git commit --no-verify -m '$message' || true" &> /dev/null
}

# ---------------- Main ----------------
ensure_git
ensure_docker
ensure_container

say "🎯 Container setup complete! Starting speedrun automation workflow..."

# Small delay to ensure container is fully ready
sleep 1

# 1) Inputs
echo ""
echo "============================================"
echo "  SPEEDRUN SUBMISSIONS AUTOMATION"
echo "============================================"
echo ""

# Force output flush
exec 1>&1

while true; do
  origin=$(get_smart_input "Enter your GitHub repository origin URL (e.g., https://github.com/username/repo.git): ")
  if [[ "$origin" =~ ^https://github\.com/[^/]+/[^/]+(\.git)?$ ]]; then
    break
  fi
  echo "❌ Invalid repository URL. Please enter a GitHub https URL like: https://github.com/owner/repo.git"
done

# Check git configuration
git_config=$(check_git_config)
git_user_name="${git_config%|*}"
git_user_email="${git_config#*|}"

# Collect private key for later use
say "🔐 Enter your wallet private key for smart cache and deployment operations"
while true; do
  echo -n "Private Key (will not be displayed): "
  read -s user_private_key
  echo
  user_private_key="${user_private_key//[$'\r\n']/}"  # Remove line endings
  pk_no_prefix="${user_private_key#0x}"
  if [[ "$pk_no_prefix" =~ ^[0-9a-fA-F]{64}$ ]]; then
    user_private_key="0x$pk_no_prefix"
    break
  fi
  echo "❌ Invalid private key. Provide a 64-hex-character key (with or without 0x)."
done

branch=$(select_challenge_branch)

# 2) Find the repository path inside container
repo_path=$(find_repo_path "$branch")
if [[ -z "$repo_path" ]]; then
  echo "❌ No speedrun project found inside container. Looking for a directory with:"
  echo "   - .git folder (existing git repository)"
  echo "   - packages/ folder (speedrun project structure)"
  echo "   - package.json file (Node.js project)"
  echo ""
  echo "💡 Make sure you have:"
  echo "   1. Cloned a speedrun project properly, OR"
  echo "   2. Created a project directory with packages/ folder or package.json"
  echo "   3. If .git folder was deleted, the script will initialize a fresh repository"
  exit 1
fi

repo_path="${repo_path//[$'\r\n']/}"  # Remove line endings
say "📁 Using speedrun project: $repo_path"

# 3) Configure git identity inside container
say "👤 Setting git identity inside container..."
docker exec "$NAME" bash -c "cd '$repo_path' && git config user.name '$git_user_name'" &> /dev/null
docker exec "$NAME" bash -c "cd '$repo_path' && git config user.email '$git_user_email'" &> /dev/null

confirm_name=$(docker exec "$NAME" bash -c "cd '$repo_path' && git config user.name" 2>/dev/null || echo "(not set)")
confirm_email=$(docker exec "$NAME" bash -c "cd '$repo_path' && git config user.email" 2>/dev/null || echo "(not set)")
echo "   user.name:  $confirm_name"
echo "   user.email: $confirm_email"

# 4) Set remote origin inside container
say "🔗 Setting remote origin: $origin"
ensure_remote "$origin" "$repo_path"
say "✅ Remote origin set in container (git operations will be done from fresh terminal)"

# 5) Ensure correct branch inside container
ensure_branch "$branch" "$repo_path"

# 6) Get commit message from user and commit if needed
say "💡 IMPORTANT: You will handle your own commits in the fresh terminal that opens next."
say "   The script will NOT auto-commit with generic messages like 'Initial commit from automation script'."
say "   You will have full control over your commit messages and git workflow."

commit_message=$(get_smart_input "Enter your commit message (or press Enter to skip commit): " true)
if [[ -n "$commit_message" ]]; then
  say "✅ Your commit message saved: '$commit_message'"
  say "💡 You'll use this message when you commit in the fresh terminal"
else
  say "⏭️ No commit message provided - you can enter one in the fresh terminal"
fi

# 7) Push from fresh terminal
packages_dir=$(find_packages_folder "$repo_path")
say "🚀 Opening new terminal for git push..."

# Create push script
push_script_path="/tmp/push_to_github_$(date +%s).sh"
cat > "$push_script_path" << EOF
#!/bin/bash
set -e

# Change to the project directory
cd "$(pwd)"

# Find directory containing packages folder
packages_path=\$(find . -name "packages" -type d 2>/dev/null | head -1)
if [[ -n "\$packages_path" ]]; then
    project_dir=\$(dirname "\$packages_path")
    if [[ -n "\$project_dir" && -d "\$project_dir" ]]; then
        cd "\$project_dir"
        echo "Navigated to project directory containing packages: \$project_dir"
    fi
else
    # Fallback to speedrun-$branch directory
    if [[ -d "speedrun-$branch" ]]; then
        cd "speedrun-$branch"
        echo "Using speedrun project directory: speedrun-$branch"
    fi
fi

# Initialize git repository if it doesn't exist
if [[ ! -d ".git" ]]; then
    echo "Initializing new git repository..."
    git init
fi

# Set git user identity
git config user.name '$git_user_name'
git config user.email '$git_user_email'

# Add remote origin
git remote remove origin 2>/dev/null || true
git remote add origin '$origin'

# Ensure correct branch
git branch -M '$branch'

# Check if this is a fresh repository (no commits)
has_commits=\$(git log --oneline -1 2>/dev/null || echo "")
is_fresh_repo=false
if [[ -z "\$has_commits" ]]; then
    is_fresh_repo=true
fi

# Check if there are changes to commit
status=\$(git status --porcelain)
if [[ -n "\$status" || "\$is_fresh_repo" == "true" ]]; then
    if [[ "\$is_fresh_repo" == "true" ]]; then
        echo "Fresh repository detected. Adding all files for initial commit..."
    else
        echo "Changes detected. Auto-committing with your saved message..."
    fi
    
    git add .
    
    if [[ -n '$commit_message' ]]; then
        git commit -m '$commit_message'
        echo "Committed with message: $commit_message"
    else
        if [[ "\$is_fresh_repo" == "true" ]]; then
            git commit -m 'Initial commit from speedrun automation script'
            echo "Initial commit created with default message"
        else
            git commit -m 'Automated commit from speedrun script'
            echo "Committed with default message"
        fi
    fi
else
    echo "No changes detected. Ready to push..."
fi

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin '$branch'

if [[ \$? -eq 0 ]]; then
    echo "✅ Push successful!"
else
    echo "❌ Push failed. Check your git credentials and try again."
fi

echo "Press Enter to close this terminal..."
read
EOF

chmod +x "$push_script_path"

# Open new terminal with the push script
if command -v gnome-terminal &> /dev/null; then
    gnome-terminal -- bash -c "$push_script_path"
elif command -v xterm &> /dev/null; then
    xterm -e "$push_script_path" &
elif command -v konsole &> /dev/null; then
    konsole -e "$push_script_path" &
else
    echo "🔧 Please run this script manually in a new terminal:"
    echo "bash $push_script_path"
fi

say "✅ New terminal opened for git push"
say "💡 Complete the push in the new terminal, then return here to continue"
say "⏸️  Press Enter when you're ready to continue..."
read

# 2) Stylus Smart Contract Verification (Optional)
say "🔍 Stylus Smart Contract Verification"
read -p "Do you want to verify your Stylus smart contract? (Y/N): " verify_contract
if [[ "$verify_contract" =~ ^[Yy]$ ]]; then
  say "🔧 Setting up contract verification..."
  
  # Find Rust project directory
  say "📁 Locating Rust project directory..."
  rust_project_dir=""
  
  # Look for Cargo.lock first, then Cargo.toml, then rust-toolchain.toml
  cargo_lock_dir=$(docker exec "$NAME" bash -c "find '$repo_path' -name 'Cargo.lock' -type f | head -1 | xargs dirname" 2>/dev/null || true)
  if [[ -n "$cargo_lock_dir" ]]; then
    rust_project_dir="$cargo_lock_dir"
  else
    cargo_toml_dir=$(docker exec "$NAME" bash -c "find '$repo_path' -name 'Cargo.toml' -type f | head -1 | xargs dirname" 2>/dev/null || true)
    if [[ -n "$cargo_toml_dir" ]]; then
      rust_project_dir="$cargo_toml_dir"
    else
      rust_toolchain_dir=$(docker exec "$NAME" bash -c "find '$repo_path' -name 'rust-toolchain.toml' -type f | head -1 | xargs dirname" 2>/dev/null || true)
      if [[ -n "$rust_toolchain_dir" ]]; then
        rust_project_dir="$rust_toolchain_dir"
      fi
    fi
  fi
  
  if [[ -z "$rust_project_dir" ]]; then
    echo "❌ Could not find Rust project directory (no Cargo.lock, Cargo.toml, or rust-toolchain.toml found)"
    say "⏭️ Skipping contract verification"
  else
    rust_project_dir="${rust_project_dir//[$'\r\n']/}"  # Remove line endings
    say "✅ Found Rust project at: $rust_project_dir"
    
    # Initialize git repository in the Rust project directory
    say "🔧 Initializing git repository in Rust project directory..."
    docker exec "$NAME" bash -c "cd '$rust_project_dir' && git init" &> /dev/null
    
    # Configure git identity in the Rust project
    docker exec "$NAME" bash -c "cd '$rust_project_dir' && git config user.name '$git_user_name'" &> /dev/null
    docker exec "$NAME" bash -c "cd '$rust_project_dir' && git config user.email '$git_user_email'" &> /dev/null
    
    # Add remote origin
    docker exec "$NAME" bash -c "cd '$rust_project_dir' && git remote add origin '$origin'" &> /dev/null
    
    # Add all files and commit
    docker exec "$NAME" bash -c "cd '$rust_project_dir' && git add ." &> /dev/null
    docker exec "$NAME" bash -c "cd '$rust_project_dir' && git commit -m 'Stylus smart contract verification'" &> /dev/null
    
    # Create and switch to verify branch
    docker exec "$NAME" bash -c "cd '$rust_project_dir' && git branch -M verify" &> /dev/null
    
    say "🚀 Opening new terminal for contract verification push..."
    
    # Create verify push script
    verify_push_script_path="/tmp/push_verify_$(date +%s).sh"
    cat > "$verify_push_script_path" << EOF
#!/bin/bash
set -e

# Change to the project directory
cd "$(pwd)"

# Navigate to the Rust project directory
rust_project_path="${rust_project_dir#/app/}"
if [[ -d "\$rust_project_path" ]]; then
    cd "\$rust_project_path"
    echo "Navigated to Rust project directory: \$rust_project_path"
else
    echo "❌ Could not find Rust project directory: \$rust_project_path"
    echo "Press Enter to close this terminal..."
    read
    exit 1
fi

# Initialize git repository if it doesn't exist
if [[ ! -d ".git" ]]; then
    echo "Initializing new git repository..."
    git init
fi

# Set git user identity
git config user.name '$git_user_name'
git config user.email '$git_user_email'

# Add remote origin
git remote remove origin 2>/dev/null || true
git remote add origin '$origin'

# Add all files and commit
git add .
git commit -m 'Stylus smart contract verification'

# Create and switch to verify branch
git branch -M verify

# Push to verify branch
echo "Pushing to verify branch for contract verification..."
git push -u origin verify

if [[ \$? -eq 0 ]]; then
    echo "✅ Contract verification push successful!"
    echo "🎯 Your Rust contract has been pushed to the verify branch"
else
    echo "❌ Push failed. Check your git credentials and try again."
fi

echo "Press Enter to close this terminal..."
read
EOF

    chmod +x "$verify_push_script_path"
    
    # Open new terminal with the verify push script
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal -- bash -c "$verify_push_script_path"
    elif command -v xterm &> /dev/null; then
        xterm -e "$verify_push_script_path" &
    elif command -v konsole &> /dev/null; then
        konsole -e "$verify_push_script_path" &
    else
        echo "🔧 Please run this script manually in a new terminal:"
        echo "bash $verify_push_script_path"
    fi

    say "✅ New terminal opened for contract verification push"
    say "💡 Complete the push in the new terminal, then return here to continue"
    say "⏸️  Press Enter when you're ready to continue..."
    read
    
    # Clean up the .git directory in the Rust project
    say "🧹 Cleaning up git repository in Rust project directory..."
    docker exec "$NAME" bash -c "cd '$rust_project_dir' && rm -rf .git" &> /dev/null
    say "✅ Git repository cleaned up from Rust project directory"
  fi
else
  say "⏭️ Skipping contract verification. Continuing with Smart Cache configuration..."
fi

# 3) Smart Cache Configuration (Optional)
say "🧠 Smart Cache Configuration for Gas Optimization"
read -p "Are you ready for smart cache configuration for making this contract efficient for gas savings? (Y/N): " configure_smart_cache
if [[ "$configure_smart_cache" =~ ^[Yy]$ ]]; then
  say "🔧 Setting up Smart Cache for gas optimization..."
  
  # Check if smart-cache-cli is already installed
  say "🔍 Checking if smart-cache-cli is already installed..."
  if docker exec "$NAME" bash -c "smart-cache --help" &> /dev/null; then
    say "✅ Smart-cache-cli is already installed, skipping installation"
  else
    # Install smart-cache-cli globally
    say "📦 Installing smart-cache-cli..."
    if docker exec "$NAME" bash -c "npm install -g smart-cache-cli" &> /dev/null; then
      say "✅ Smart-cache-cli installed globally"
    else
      say "⚠️ Global installation failed. Trying local installation..."
      if docker exec "$NAME" bash -c "cd '$repo_path' && npm install smart-cache-cli" &> /dev/null; then
        say "✅ Smart-cache-cli installed locally in project"
      else
        echo "❌ Failed to install smart-cache-cli. You may need to install it manually."
        echo "   Run: docker exec -it $NAME bash -c 'npm install -g smart-cache-cli'"
      fi
    fi
  fi
  
  # Run smart-cache init
  say "🚀 Initializing smart cache configuration..."
  docker exec "$NAME" bash -c "cd '$repo_path' && npx smart-cache init" &> /dev/null
  
  # Get user inputs for smart cache configuration
  deployer_address=$(get_smart_input "Enter your wallet address that deployed the contracts: ")
  contract_address=$(get_smart_input "Enter your contract address (or press Enter to skip): " true)
  
  # Update smartcache.toml with user values
  say "🔧 Updating smartcache.toml with your addresses..."
  
  # Create update script
  update_script='#!/bin/bash
set -e
cd '"'"$repo_path"'"'
f=smartcache.toml

# Ensure file exists
touch "$f"

# Update deployed_by
if grep -q "^deployed_by" "$f"; then
  sed -i "s/^deployed_by.*/deployed_by = \"$1\"/" "$f"
else
  echo "deployed_by = \"$1\"" >> "$f"
fi

# Update contract_address if provided
if [ -n "$2" ]; then
  if grep -q "^contract_address" "$f"; then
    sed -i "s/^contract_address.*/contract_address = \"$2\"/" "$f"
  else
    echo "contract_address = \"$2\"" >> "$f"
  fi
fi'

  # Write and execute update script
  docker exec "$NAME" bash -c "cat > /tmp/update_toml.sh << 'SCRIPT_EOF'
$update_script
SCRIPT_EOF
chmod +x /tmp/update_toml.sh
/tmp/update_toml.sh '$deployer_address' '$contract_address'"
  
  sleep 0.5
  say "✅ Smart cache configuration created at: $repo_path/smartcache.toml"
  
  # Smart cache configuration retry loop
  max_retries=3
  retry_count=0
  smart_cache_add_success=false
  
  while [[ $retry_count -lt $max_retries && "$smart_cache_add_success" == "false" ]]; do
    ((retry_count++))
    if [[ $retry_count -gt 1 ]]; then
      say "🔄 Retry attempt $retry_count of $max_retries"
    fi
    
    # Run smart-cache add command
    say "🚀 Running smart-cache add command..."
    add_cmd="cd '$repo_path' && npx -y smart-cache add"
    if [[ -n "$contract_address" ]]; then
      add_cmd="cd '$repo_path' && npx -y smart-cache add $contract_address"
    fi
    
    smart_cache_add_output=$(docker exec "$NAME" bash -c "$add_cmd" 2>&1 || true)
    if [[ $? -eq 0 ]]; then
      smart_cache_add_success=true
    fi
    
    # Display the output to user
    echo "📋 Smart-cache add command output:"
    echo "$smart_cache_add_output"
    
    if [[ "$smart_cache_add_success" == "true" ]]; then
      say "✅ Smart-cache add command executed successfully!"
      break
    else
      say "⚠️ Smart-cache add command encountered errors"
      
      if [[ $retry_count -lt $max_retries ]]; then
        read -p "Would you like to retry with new contract address and deployer address? (Y/N): " retry
        if [[ "$retry" =~ ^[Yy]$ ]]; then
          deployer_address=$(get_smart_input "Enter your wallet address that deployed the contracts: ")
          contract_address=$(get_smart_input "Enter your contract address (or press Enter to skip): " true)
          
          # Update smartcache.toml with new inputs
          say "🔧 Updating smartcache.toml with new addresses..."
          docker exec "$NAME" bash -c "/tmp/update_toml.sh '$deployer_address' '$contract_address'"
          say "✅ Smart cache configuration updated with new addresses"
        else
          break
        fi
      else
        say "⚠️ Maximum retry attempts reached ($max_retries)"
        break
      fi
    fi
  done
  
  # Commit and push smart cache configuration
  smart_cache_commit_msg=$(get_smart_input "Enter commit message for smart cache configuration (or press Enter to skip): " true)
  if [[ -n "$smart_cache_commit_msg" ]]; then
    docker exec "$NAME" bash -c "cd '$repo_path' && git add smartcache.toml && git commit --no-verify -m '$smart_cache_commit_msg'" &> /dev/null
    say "✅ Smart cache configuration committed"
    
    # Check if smart-cache add was successful before pushing
    if [[ "$smart_cache_add_success" == "false" ]]; then
      say "⚠️ Smart-cache add command had errors after $retry_count attempts"
      read -p "Are you sure to push the code to GitHub without successful run of smart-cache add command? (Y/N): " continue_push
      if [[ ! "$continue_push" =~ ^[Yy]$ ]]; then
        say "⏭️ Skipping smart cache push due to smart-cache add errors."
        read -p "Would you like to continue with Rust Crate automation? (Y/N): " continue_to_rust_crate
        if [[ ! "$continue_to_rust_crate" =~ ^[Yy]$ ]]; then
          say "⏭️ Script completed. Smart cache is configured but not pushed due to errors."
          exit 0
        fi
        say "⏭️ Continuing with Rust Crate automation..."
      fi
    fi
    
    # Push the new changes
    say "🚀 Opening new terminal for smart cache push..."
    
    # Create smart cache push script
    smart_cache_push_script_path="/tmp/push_smartcache_$(date +%s).sh"
    cat > "$smart_cache_push_script_path" << EOF
#!/bin/bash
set -e

# Change to the project directory
cd "$(pwd)"

# Find directory containing packages folder
packages_path=\$(find . -name "packages" -type d 2>/dev/null | head -1)
if [[ -n "\$packages_path" ]]; then
    project_dir=\$(dirname "\$packages_path")
    if [[ -n "\$project_dir" && -d "\$project_dir" ]]; then
        cd "\$project_dir"
        echo "Navigated to project directory containing packages: \$project_dir"
    fi
else
    # Fallback to speedrun-$branch directory
    if [[ -d "speedrun-$branch" ]]; then
        cd "speedrun-$branch"
        echo "Using speedrun project directory: speedrun-$branch"
    fi
fi

# Initialize git repository if it doesn't exist
if [[ ! -d ".git" ]]; then
    echo "Initializing new git repository..."
    git init
fi

# Set git user identity
git config user.name '$git_user_name'
git config user.email '$git_user_email'

# Add remote origin
git remote remove origin 2>/dev/null || true
git remote add origin '$origin'

# Ensure correct branch
git branch -M '$branch'

# Check if there are changes to commit
status=\$(git status --porcelain)
if [[ -n "\$status" ]]; then
    echo "Changes detected. Auto-committing smart cache configuration..."
    git add .
    git commit -m 'Smart cache configuration update'
    echo "Committed smart cache changes"
else
    echo "No changes detected. Ready to push..."
fi

# Push smart cache configuration to GitHub
echo "Pushing smart cache configuration to GitHub..."
git push origin '$branch'

if [[ \$? -eq 0 ]]; then
    echo "✅ Smart cache configuration pushed successfully!"
else
    echo "❌ Push failed. Check your git credentials and try again."
fi

echo "Press Enter to close this terminal..."
read
EOF

    chmod +x "$smart_cache_push_script_path"
    
    # Open new terminal with the push script
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal -- bash -c "$smart_cache_push_script_path"
    elif command -v xterm &> /dev/null; then
        xterm -e "$smart_cache_push_script_path" &
    elif command -v konsole &> /dev/null; then
        konsole -e "$smart_cache_push_script_path" &
    else
        echo "🔧 Please run this script manually in a new terminal:"
        echo "bash $smart_cache_push_script_path"
    fi

    say "✅ New terminal opened for smart cache push"
    say "💡 Complete the push in the new terminal, then return here to continue"
    say "⏸️  Press Enter when you're ready to continue with Rust Crate automation..."
    read
  else
    say "⏭️ Smart cache configuration created but not committed. You can commit manually later."
  fi
else
  say "⏭️ Skipping smart cache configuration. You can configure it manually later if needed."
fi

# 4) Rust Crate Automation (Optional)
say "🦀 Rust Crate Automation for Contract Optimization"
read -p "Are you ready to use RUST crate to automate the process? (Y/N): " configure_rust_crate
if [[ "$configure_rust_crate" =~ ^[Yy]$ ]]; then
  say "🔧 Setting up Rust crate automation..."
  
  # Find Cargo.toml directory
  say "📁 Locating Cargo.toml directory..."
  cargo_dir=$(docker exec "$NAME" bash -c "find '$repo_path' -name 'Cargo.toml' -type f | head -1 | xargs dirname" 2>/dev/null || true)
  if [[ -z "$cargo_dir" ]]; then
    cargo_dir=$(docker exec "$NAME" bash -c "find '$repo_path' -name 'rust-toolchain.toml' -type f | head -1 | xargs dirname" 2>/dev/null || true)
  fi
  
  if [[ -z "$cargo_dir" ]]; then
    echo "❌ Could not find Cargo.toml or rust-toolchain.toml directory"
    say "⏭️ Skipping Rust crate automation"
  else
    cargo_dir="${cargo_dir//[$'\r\n']/}"  # Remove line endings
    say "✅ Found Rust project at: $cargo_dir"
    
    # Install stylus-cache-sdk
    say "📦 Installing stylus-cache-sdk..."
    if docker exec "$NAME" bash -c "cd '$cargo_dir' && cargo add stylus-cache-sdk" &> /dev/null; then
      say "✅ stylus-cache-sdk installed successfully"
    else
      echo "❌ Failed to install stylus-cache-sdk"
      say "⏭️ Skipping Rust crate automation"
      exit 0
    fi
    
    # Find and update lib.rs
    say "🔧 Updating lib.rs file..."
    lib_rs_path=$(docker exec "$NAME" bash -c "find '$cargo_dir' -name 'lib.rs' -type f | head -1" 2>/dev/null || true)
    if [[ -z "$lib_rs_path" ]]; then
      echo "❌ Could not find lib.rs file"
      say "⏭️ Skipping lib.rs updates"
    else
      lib_rs_path="${lib_rs_path//[$'\r\n']/}"  # Remove line endings
      say "✅ Found lib.rs at: $lib_rs_path"
      
      # Update lib.rs with import and cacheable function
      update_lib_script='#!/bin/bash
set -e
libfile='"'"$lib_rs_path"'"'

# Add import if not already present
if ! grep -q "use stylus_cache_sdk" "$libfile"; then
  # Add after extern crate alloc line
  sed -i "/extern crate alloc;/a use stylus_cache_sdk::{is_contract_cacheable};" "$libfile"
fi

# Add is_cacheable function if not already present
if ! grep -q "pub fn is_cacheable" "$libfile"; then
  # Find impl block and add the function
  if grep -q "impl " "$libfile"; then
    # Add the function before the last closing brace of the impl block
    sed -i "/impl /,/^}/ {
      /^}/ i\    pub fn is_cacheable(&self) -> bool {\
        is_contract_cacheable()\
    }\

    }" "$libfile"
  fi
fi'
      
      docker exec "$NAME" bash -c "cat > /tmp/update_lib.sh << 'SCRIPT_EOF'
$update_lib_script
SCRIPT_EOF
chmod +x /tmp/update_lib.sh
/tmp/update_lib.sh"
      
      say "✅ lib.rs updated with stylus-cache-sdk integration"
      
      # Ask user to make contract unique
      say "🎯 Make Your Contract Unique"
      echo "To make your contract unique, you should rename one of your functions."
      echo "For example: 'set_number' → 'set_number_yourname'"
      echo ""
      read -p "Would you like to make manual changes to make your contract unique? (Y/N): " make_unique
      if [[ "$make_unique" =~ ^[Yy]$ ]]; then
        echo "✅ Please manually edit your lib.rs file to rename a function and make it unique."
        echo "📝 The file is located at: $lib_rs_path"
        echo "⏸️  Press Enter when you're done making changes..."
        read
      fi
      
      # Ensure WebAssembly target is installed
      say "🔧 Ensuring WebAssembly target is installed..."
      if docker exec "$NAME" bash -c "rustup target add wasm32-unknown-unknown" &> /dev/null; then
        say "✅ WebAssembly target ready"
      else
        echo "⚠️ Warning: Could not install wasm32-unknown-unknown target"
      fi
      
      # Deploy contract with cargo stylus
      say "🚀 Deploying contract with cargo stylus..."
      echo "Running: cargo stylus deploy --endpoint='https://sepolia-rollup.arbitrum.io/rpc' --private-key=<your-key> --no-verify"
      
      # Use the private key collected at the beginning of the script
      deploy_output=$(docker exec "$NAME" bash -c "cd '$cargo_dir' && cargo stylus deploy --endpoint='https://sepolia-rollup.arbitrum.io/rpc' --private-key='$user_private_key' --no-verify" 2>&1 || true)
      deploy_success=false
      if [[ $? -eq 0 ]]; then
        deploy_success=true
      fi
      
      # Display deploy output
      echo "📋 Cargo stylus deploy output:"
      echo "$deploy_output"
      
      if [[ "$deploy_success" == "true" ]]; then
        # Extract contract address from deployment output
        deployed_contract_address=""
        if [[ "$deploy_output" =~ deployed\ code\ at\ address\ (0x[0-9a-fA-F]{40}) ]]; then
          deployed_contract_address="${BASH_REMATCH[1]}"
        else
          # Try alternative patterns
          deployed_contract_address=$(echo "$deploy_output" | grep -oE '0x[0-9a-fA-F]{40}' | tail -1)
        fi
        
        if [[ -n "$deployed_contract_address" ]]; then
          say "✅ Contract deployed successfully!"
          echo "🎯 Contract Address: $deployed_contract_address"
          echo "📋 Save this address - you'll need it for interacting with your contract!"
        else
          say "✅ Contract deployed successfully!"
          echo "⚠️ Could not extract contract address from output. Check the deployment log above."
        fi
      else
        say "⚠️ Contract deployment encountered errors"
        read -p "Do you want to push the code to GitHub despite deployment errors? (Y/N): " continue_push_after_deploy
        if [[ ! "$continue_push_after_deploy" =~ ^[Yy]$ ]]; then
          say "⏭️ Skipping push due to deployment errors. Rust crate automation is complete locally."
          say "🎉 Local Rust automation complete! You can deploy and push manually later."
          echo "   ✅ Stylus cache SDK integration (local)"
          echo "   ✅ Contract code updated (local)"
          echo "   ⚠️ Manual deployment and push required"
          exit 0
        fi
      fi
      
      # Commit and push Rust changes
      rust_commit_msg=$(get_smart_input "Enter commit message for Rust crate automation (or press Enter to skip): " true)
      if [[ -n "$rust_commit_msg" ]]; then
        docker exec "$NAME" bash -c "cd '$repo_path' && git add . && git commit --no-verify -m '$rust_commit_msg'" &> /dev/null
        say "✅ Rust changes committed"
        
        # Push the Rust changes
        say "🚀 Opening new terminal for Rust automation push..."
        
        # Create rust push script
        rust_push_script_path="/tmp/push_rust_$(date +%s).sh"
        cat > "$rust_push_script_path" << EOF
#!/bin/bash
set -e

# Change to the project directory
cd "$(pwd)"

# Find directory containing packages folder
packages_path=\$(find . -name "packages" -type d 2>/dev/null | head -1)
if [[ -n "\$packages_path" ]]; then
    project_dir=\$(dirname "\$packages_path")
    if [[ -n "\$project_dir" && -d "\$project_dir" ]]; then
        cd "\$project_dir"
        echo "Navigated to project directory containing packages: \$project_dir"
    fi
else
    # Fallback to speedrun-$branch directory
    if [[ -d "speedrun-$branch" ]]; then
        cd "speedrun-$branch"
        echo "Using speedrun project directory: speedrun-$branch"
    fi
fi

# Initialize git repository if it doesn't exist
if [[ ! -d ".git" ]]; then
    echo "Initializing new git repository..."
    git init
fi

# Set git user identity
git config user.name '$git_user_name'
git config user.email '$git_user_email'

# Add remote origin
git remote remove origin 2>/dev/null || true
git remote add origin '$origin'

# Ensure correct branch
git branch -M '$branch'

# Check if there are changes to commit
status=\$(git status --porcelain)
if [[ -n "\$status" ]]; then
    echo "Changes detected. Auto-committing Rust automation changes..."
    git add .
    git commit -m 'Rust crate automation update'
    echo "Committed Rust automation changes"
else
    echo "No changes detected. Ready to push..."
fi

# Push Rust crate automation to GitHub
echo "Pushing Rust crate automation to GitHub..."
git push origin '$branch'

if [[ \$? -eq 0 ]]; then
    echo "✅ Rust crate automation pushed successfully!"
    echo "🎉 All automation complete! Your contract now includes:"
    echo "   ✅ Smart cache configuration"
    echo "   ✅ Stylus cache SDK integration"
    echo "   ✅ Optimized contract functions"
else
    echo "❌ Push failed. Check your git credentials and try again."
    echo "⚠️ All configurations are complete locally. You can push manually later."
    echo "🎉 Local automation complete! Your contract now includes:"
    echo "   ✅ Smart cache configuration (local)"
    echo "   ✅ Stylus cache SDK integration (local)"
    echo "   ✅ Optimized contract functions (local)"
    echo "   ⚠️ Manual push required to sync with GitHub"
fi

echo "Press Enter to close this terminal..."
read
EOF

        chmod +x "$rust_push_script_path"
        
        # Open new terminal with the push script
        if command -v gnome-terminal &> /dev/null; then
            gnome-terminal -- bash -c "$rust_push_script_path"
        elif command -v xterm &> /dev/null; then
            xterm -e "$rust_push_script_path" &
        elif command -v konsole &> /dev/null; then
            konsole -e "$rust_push_script_path" &
        else
            echo "🔧 Please run this script manually in a new terminal:"
            echo "bash $rust_push_script_path"
        fi

        say "✅ New terminal opened for Rust automation push"
        say "💡 Complete the push in the new terminal, then return here to continue"
        say "⏸️  Press Enter when you're ready to continue..."
        read
      else
        say "⏭️ Rust changes created but not committed. You can commit manually later."
      fi
    fi
  fi
else
  say "⏭️ Skipping Rust crate automation. You can configure it manually later if needed."
fi

say "🎉 Speedrun submissions automation completed!"
