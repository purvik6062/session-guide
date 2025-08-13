#!/bin/bash
set -e

# ---------------- Config ----------------
IMG="abxglia/speedrun-stylus:0.1"
NAME="speedrun-stylus"
PORT=3000
# ---------------------------------------

function say() { echo -e "\n$1"; }

# 0) Checks
if ! command -v docker &> /dev/null; then
  echo "❌ Docker not found. Install Docker."
  exit 1
fi

if ! docker info &> /dev/null; then
  echo "❌ Docker daemon not running. Start Docker."
  exit 1
fi

if ! command -v git &> /dev/null; then
  echo "❌ git not found. Install git."
  exit 1
fi

# 1) Check if packages/nextjs exists in the current project
find_packages_nextjs() {
  local current_dir="$(pwd)"
  local packages_nextjs_path=""
  
  # Check current directory first
  if [ -d "$current_dir/packages/nextjs" ]; then
    packages_nextjs_path="$current_dir/packages/nextjs"
    echo "$packages_nextjs_path"
    return 0
  fi
  
  # Search in subdirectories
  for subdir in "$current_dir"/*; do
    if [ -d "$subdir" ]; then
      if [ -d "$subdir/packages/nextjs" ]; then
        packages_nextjs_path="$subdir/packages/nextjs"
        echo "$packages_nextjs_path"
        return 0
      fi
    fi
  done
  
  return 1
}

packages_nextjs_path=$(find_packages_nextjs)
if [ -z "$packages_nextjs_path" ]; then
  echo "❌ packages/nextjs folder not found in the current project."
  echo "Please follow the required steps mentioned at: https://github.com/purvik6062/session-guide/blob/main/docker/README.md"
  echo "Make sure you have cloned a challenge repository first."
  exit 1
fi

say "✅ Found packages/nextjs at: $packages_nextjs_path"

# 2) Choose challenge (ask user which repo they cloned)
echo "Which challenge repository did you clone?
1) counter
2) nft
3) vending-machine
4) multi-sig
5) stylus-uniswap"
read -p "Enter 1-5: " sel

case $sel in
  1) branch="counter"; challenge="counter" ;;
  2) branch="nft"; challenge="nft" ;;
  3) branch="vending-machine"; challenge="vending_machine" ;;
  4) branch="multi-sig"; challenge="multi-sig" ;;
  5) branch="stylus-uniswap"; challenge="stylus-uniswap-v2" ;;
  *) echo "Invalid choice."; exit 1 ;;
esac

# 3) Set working directory to current location (where the cloned repo is)
WORKDIR="$(pwd)"
say "🏠 Working in current directory: $WORKDIR"

# 4) Ensure image present (skip pull if already local)
if ! docker image inspect "$IMG" &> /dev/null; then
  say "🐳 Pulling Docker image (first time only)..."
  docker pull "$IMG"
else
  say "✅ Docker image present; skipping pull."
fi

# 5) Ensure container running (reuse if exists)
if docker inspect -f '{{.State.Status}}' "$NAME" &> /dev/null; then
  status=$(docker inspect -f '{{.State.Status}}' "$NAME")
  if [ "$status" = "running" ]; then
    say "♻️ Container '$NAME' already running; reusing."
  else
    say "▶️ Starting existing container '$NAME'..."
    docker start "$NAME"
  fi
else
  # 6) Start new container with caches
  say "🚀 Starting container..."
  docker run -d --name "$NAME" \
    -v "$PWD:/app" \
    -v speedrun-yarn-cache:/root/.cache/yarn \
    -v speedrun-cargo-registry:/root/.cargo/registry \
    -v speedrun-cargo-git:/root/.cargo/git \
    -v speedrun-rustup:/root/.rustup \
    -v speedrun-foundry:/root/.foundry \
    -p "$PORT:3000" \
    "$IMG" tail -f /dev/null
fi

# 7) Ensure deploy script exists
if ! docker exec -it "$NAME" bash -lc "command -v deploy-contract.sh >/dev/null"; then
  echo "❌ deploy-contract.sh missing in image"
  exit 1
fi

# 8) Install deps (skip if already installed)
say "📥 Ensuring dependencies are installed..."
docker exec -it "$NAME" bash -lc "cd /app && if [ -d node_modules ] && [ -d packages/nextjs/node_modules ]; then echo '✔ yarn already installed; skipping.'; else yarn install; fi"

# 9) Private key (skip prompt if both .env files already contain keys)
if [ "$challenge" = "counter" ]; then
  pkg_env="/app/packages/stylus-demo/.env"
else
  pkg_env="/app/packages/cargo-stylus/$challenge/.env"
fi
next_env="/app/packages/nextjs/.env"

next_ok=false
pkg_ok=false

if docker exec "$NAME" bash -lc "test -f '$next_env' && grep -q '^NEXT_PUBLIC_PRIVATE_KEY=0x' '$next_env'" &> /dev/null; then
  next_ok=true
fi

if docker exec "$NAME" bash -lc "test -f '$pkg_env' && grep -q '^PRIVATE_KEY=0x' '$pkg_env'" &> /dev/null; then
  pkg_ok=true
fi

skip_pk_prompt=false
if $next_ok && $pkg_ok; then
  skip_pk_prompt=true
fi

if ! $skip_pk_prompt; then
  echo -n "Enter PRIVATE KEY (hex, no spaces). I will prepend 0x: "
  read -s raw_pk
  echo  # newline after hidden input
  pk="0x${raw_pk#0x}"  # prepend 0x and remove any existing 0x prefix
else
  pk=""
fi

# 10) Write env files
say "🧩 Writing .env files..."
if $skip_pk_prompt; then
  # Only ensure RPC URL in nextjs .env; do not modify existing keys
  env_cmd_no_key="set -e; cd /app/packages/nextjs || { echo 'nextjs package not found'; exit 1; }; if [ ! -f .env ]; then if [ -f .env.example ]; then cp -n .env.example .env; else touch .env; fi; fi; if grep -q '^NEXT_PUBLIC_RPC_URL=' .env; then sed -i 's|NEXT_PUBLIC_RPC_URL=.*|NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc|' .env; else echo 'NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc' >> .env; fi"
  docker exec -it "$NAME" bash -lc "$env_cmd_no_key"
else
  # Write both RPC URL and keys
  env_cmd="set -e; cd /app/packages/nextjs || { echo 'nextjs package not found'; exit 1; }; if [ ! -f .env ]; then if [ -f .env.example ]; then cp -n .env.example .env; else touch .env; fi; fi; if grep -q '^NEXT_PUBLIC_RPC_URL=' .env; then sed -i 's|NEXT_PUBLIC_RPC_URL=.*|NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc|' .env; else echo 'NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc' >> .env; fi; if grep -q '^NEXT_PUBLIC_PRIVATE_KEY=' .env; then sed -i 's|NEXT_PUBLIC_PRIVATE_KEY=.*|NEXT_PUBLIC_PRIVATE_KEY=$pk|' .env; else echo 'NEXT_PUBLIC_PRIVATE_KEY=$pk' >> .env; fi"
  docker exec -it "$NAME" bash -lc "export pk='$pk'; $env_cmd"
  
  if [ "$challenge" = "counter" ]; then
    docker exec -it "$NAME" bash -lc "mkdir -p /app/packages/stylus-demo; echo 'PRIVATE_KEY=$pk' > /app/packages/stylus-demo/.env"
  else
    docker exec -it "$NAME" bash -lc "mkdir -p /app/packages/cargo-stylus/$challenge; echo 'PRIVATE_KEY=$pk' > /app/packages/cargo-stylus/$challenge/.env"
  fi
fi

# 11) Deploy and capture address (skip deploy if previous artifacts exist and contain address)
if [ "$challenge" = "counter" ]; then
  base_dir="/app/packages/stylus-demo"
else
  base_dir="/app/packages/cargo-stylus/$challenge"
fi

deploy_json="$base_dir/build/stylus-deployment-info.json"
deploy_log="$base_dir/deploy.log"

json_addr=""
log_addr=""

if docker exec "$NAME" bash -lc "[ -f '$deploy_json' ]" &> /dev/null; then
  json_addr=$(docker exec "$NAME" bash -lc "grep -oE '\"contract_address\"[[:space:]]*:[[:space:]]*\"0x[0-9a-fA-F]{40}\"' '$deploy_json' | head -1 | grep -oE '0x[0-9a-fA-F]{40}'" 2>/dev/null || true)
fi

if docker exec "$NAME" bash -lc "[ -f '$deploy_log' ]" &> /dev/null; then
  log_addr=$(docker exec "$NAME" bash -lc "grep -i 'Contract address' '$deploy_log' | grep -oE '0x[0-9a-fA-F]{40}' | head -1" 2>/dev/null || true)
fi

addr=""
if [ -n "$json_addr" ] && [ -n "$log_addr" ]; then
  if [ "$json_addr" != "$log_addr" ]; then
    say "⚠️ Address mismatch in artifacts; preferring JSON: $json_addr"
  fi
  addr="$json_addr"
elif [ -n "$json_addr" ]; then
  addr="$json_addr"
elif [ -n "$log_addr" ]; then
  addr="$log_addr"
fi

if [ -z "$addr" ]; then
  say "🛠️ Deploying contract for '$challenge'..."
  deploy_out=$(docker exec "$NAME" bash -lc "cd /app && deploy-contract.sh $challenge | tee '$deploy_log'")
  addr=$(echo "$deploy_out" | grep -oE '0x[0-9a-fA-F]{40}' | tail -1)
fi

if [ -n "$addr" ]; then
  say "✅ Contract address: $addr"
  if [ "$challenge" = "stylus-uniswap-v2" ]; then
    target="/app/packages/nextjs/app/debug/_components/UniswapInterface.tsx"
    var="uniswapContractAddress"
  else
    target="/app/packages/nextjs/app/debug/_components/DebugContracts.tsx"
    var="contractAddress"
  fi

  # Skip injection if target already contains the same address
  already_set=false
  if docker exec "$NAME" bash -lc "[ -f '$target' ] && grep -q '$addr' '$target'" &> /dev/null; then
    already_set=true
  fi

  if ! $already_set; then
    # Inject detected contract address into frontend file using Node (robust across shells)
    # Write the JS code to a temporary file to avoid shell quoting issues
    cat > /tmp/inject_local.js << 'JSEOF'
const fs = require("fs");
const path = process.env.TARGET;
const varName = process.env.VARNAME;
const addr = process.env.ADDR;
if (!fs.existsSync(path)) {
  console.log("⚠️ " + path + " not found; please paste manually.");
  process.exit(0);
}
let src = fs.readFileSync(path, "utf8");
// First try: exact pattern match with proper escaping
const re = new RegExp(varName + "\\s*=\\s*[\"']0x[0-9a-fA-F]{40}[\"']");
if (re.test(src)) {
  src = src.replace(re, varName + ' = "' + addr + '"');
  console.log("🔧 Injected " + varName + " into " + path);
} else {
  // Second try: more flexible pattern
  const re2 = new RegExp("(\\b" + varName + "\\s*=\\s*)[\"']0x[0-9a-fA-F]{40}[\"']");
  if (re2.test(src)) {
    src = src.replace(re2, '$1"' + addr + '"');
    console.log("🔧 Injected " + varName + " into " + path);
  } else {
    console.log("⚠️ Could not find " + varName + " pattern in " + path + "; please update manually.");
    process.exit(1);
  }
}
fs.writeFileSync(path, src);
JSEOF
    
    docker cp /tmp/inject_local.js "$NAME:/tmp/inject.js"
    docker exec -e TARGET="$target" -e VARNAME="$var" -e ADDR="$addr" -it "$NAME" node /tmp/inject.js
    rm /tmp/inject_local.js
  else
    say "🔎 Contract address already set in target; skipping injection."
  fi
else
  say "⚠️ Could not detect contract address automatically. Copy it from logs and paste manually in the debug UI file."
fi