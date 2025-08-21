#!/bin/bash
set -e

# ---------------- Config ----------------
IMG="abxglia/speedrun-stylus-mac:0.1"
NAME="speedrun-stylus"
REPO="https://github.com/abhi152003/speedrun_stylus.git"
PORT=3000
# ---------------------------------------

function say() { echo -e "\n$1"; }

# 0) Checks
if ! command -v docker &> /dev/null; then
  echo "❌ Docker not found. Install Docker Desktop."
  exit 1
fi

if ! docker info &> /dev/null; then
  echo "❌ Docker daemon not running. Start Docker Desktop."
  exit 1
fi

if ! command -v git &> /dev/null; then
  echo "❌ git not found. Install git."
  exit 1
fi

# 1) Choose challenge
echo "Choose a challenge:
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

# 2) Prepare workspace
WORKDIR="$(pwd)/speedrun-$branch"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# 3) Clone only needed branch (idempotent)
if [ ! -d ".git" ]; then
  say "📦 Cloning branch '$branch'..."
  git init > /dev/null
  git remote add origin $REPO
  git fetch --depth=1 origin $branch
  git checkout -b $branch FETCH_HEAD > /dev/null
else
  say "ℹ️ Repo already present. Using existing checkout."
fi

# 4) Ensure image present (skip pull if already local)
if ! docker image inspect $IMG &> /dev/null; then
  say "🐳 Pulling Docker image with platform flag (first time only)..."
  docker pull --platform linux/amd64 $IMG > /dev/null
else
  say "✅ Docker image present; skipping pull."
fi

# 5) Always remove existing container and start fresh
say "🧹 Removing any existing container '$NAME'..."
if docker rm -f $NAME &> /dev/null; then
  say "✅ Existing container removed successfully"
else
  say "ℹ️ No existing container found (this is normal for first run)"
fi

# 6) Start new container with caches
say "🚀 Starting fresh container..."
docker run -d --name $NAME \
  -v "$PWD":/app \
  -v speedrun-yarn-cache:/root/.cache/yarn \
  -v speedrun-cargo-registry:/root/.cargo/registry \
  -v speedrun-cargo-git:/root/.cargo/git \
  -v speedrun-rustup:/root/.rustup \
  -v speedrun-foundry:/root/.foundry \
  -p "$PORT:3000" \
  $IMG tail -f /dev/null > /dev/null

# 7) Ensure deploy script exists
docker exec -it $NAME bash -lc "command -v deploy-contract.sh >/dev/null || { echo 'deploy-contract.sh missing in image'; exit 1; }"

# 8) Install deps (skip if already installed)
say "📥 Ensuring dependencies are installed..."
docker exec -it $NAME bash -lc "cd /app && if [ -d node_modules ] && [ -d packages/nextjs/node_modules ]; then echo '✔ yarn already installed; skipping.'; else yarn install; fi"

# 9) Private key (skip prompt if both .env files already contain keys)
if [ "$challenge" = "counter" ]; then
  pkgEnv="/app/packages/stylus-demo/.env"
else
  pkgEnv="/app/packages/cargo-stylus/$challenge/.env"
fi
nextEnv="/app/packages/nextjs/.env"

nextOk=false
pkgOk=false

if docker exec $NAME bash -lc "test -f '$nextEnv' && grep -q '^NEXT_PUBLIC_PRIVATE_KEY=0x' '$nextEnv'" &> /dev/null; then
  nextOk=true
fi

if docker exec $NAME bash -lc "test -f '$pkgEnv' && grep -q '^PRIVATE_KEY=0x' '$pkgEnv'" &> /dev/null; then
  pkgOk=true
fi

skipPkPrompt=false
if [ "$nextOk" = true ] && [ "$pkgOk" = true ]; then
  skipPkPrompt=true
fi

if [ "$skipPkPrompt" = false ]; then
  echo -n "Enter PRIVATE KEY (hex, no spaces). I will prepend 0x: "
  read -s raw_pk
  echo
  # Remove any existing 0x prefix and add our own
  pk="0x$(echo "$raw_pk" | sed 's/^0x//')"
else
  pk=""
fi

# 10) Write env files
say "🧩 Writing .env files..."
if [ "$skipPkPrompt" = true ]; then
  # Only ensure RPC URL in nextjs .env; do not modify existing keys
  envCmdNoKey="set -e; cd /app/packages/nextjs || { echo 'nextjs package not found'; exit 1; }; if [ ! -f .env ]; then if [ -f .env.example ]; then cp -n .env.example .env; else touch .env; fi; fi; if grep -q '^NEXT_PUBLIC_RPC_URL=' .env; then sed -i 's^NEXT_PUBLIC_RPC_URL=.*^NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc^' .env; else echo 'NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc' >> .env; fi"
  docker exec -it $NAME bash -lc "$envCmdNoKey"
else
  # Write both RPC URL and keys
  envCmd="set -e; cd /app/packages/nextjs || { echo 'nextjs package not found'; exit 1; }; if [ ! -f .env ]; then if [ -f .env.example ]; then cp -n .env.example .env; else touch .env; fi; fi; if grep -q '^NEXT_PUBLIC_RPC_URL=' .env; then sed -i 's^NEXT_PUBLIC_RPC_URL=.*^NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc^' .env; else echo 'NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc' >> .env; fi; if grep -q '^NEXT_PUBLIC_PRIVATE_KEY=' .env; then sed -i 's^NEXT_PUBLIC_PRIVATE_KEY=.*^NEXT_PUBLIC_PRIVATE_KEY=$pk^' .env; else echo 'NEXT_PUBLIC_PRIVATE_KEY=$pk' >> .env; fi"
  docker exec -it $NAME bash -lc "$envCmd"
  
  if [ "$challenge" = "counter" ]; then
    docker exec -it $NAME bash -lc "mkdir -p /app/packages/stylus-demo; echo 'PRIVATE_KEY=$pk' > /app/packages/stylus-demo/.env"
  else
    docker exec -it $NAME bash -lc "mkdir -p /app/packages/cargo-stylus/$challenge; echo 'PRIVATE_KEY=$pk' > /app/packages/cargo-stylus/$challenge/.env"
  fi
fi

# 11) Force re-deploy contract every time (clear old artifacts and deploy fresh)
if [ "$challenge" = "counter" ]; then
  baseDir="/app/packages/stylus-demo"
else
  baseDir="/app/packages/cargo-stylus/$challenge"
fi

deployJson="$baseDir/build/stylus-deployment-info.json"
deployLog="$baseDir/deploy.log"

# Clear previous deployment artifacts to force fresh deployment
say "🧹 Clearing previous deployment artifacts..."
docker exec $NAME bash -lc "rm -f '$deployJson' '$deployLog'" > /dev/null

# Force fresh deployment every time
say "🛠️ Deploying contract for '$challenge' (fresh deployment)..."
deployOut=$(docker exec $NAME bash -lc "cd /app && deploy-contract.sh $challenge | tee '$deployLog'")
addr=$(echo "$deployOut" | grep -o '0x[0-9a-fA-F]\{40\}' | tail -1)

if [ -n "$addr" ]; then
  say "✅ Contract address: $addr"
  if [ "$challenge" = "stylus-uniswap-v2" ]; then
    target="/app/packages/nextjs/app/debug/_components/UniswapInterface.tsx"
    var="uniswapContractAddress"
  else
    target="/app/packages/nextjs/app/debug/_components/DebugContracts.tsx"
    var="contractAddress"
  fi

  # Always inject the new contract address (force update)
  say "🔧 Updating frontend with new contract address..."
  
  # Inject detected contract address into frontend file using Node (robust across shells)
  js='const fs = require("fs");
const path = process.env.TARGET;
const varName = process.env.VARNAME;
const addr = process.env.ADDR;
if (!fs.existsSync(path)) {
  console.log("⚠️ " + path + " not found; please paste manually.");
  process.exit(0);
}
let src = fs.readFileSync(path, "utf8");
const re = new RegExp(varName + "\\s*=\\s*(?:\"|'"'"')0x[0-9a-fA-F]{40}(?:\"|'"'"')");
if (re.test(src)) {
  src = src.replace(re, varName + "=\"" + addr + "\"");
} else {
  const re2 = new RegExp("(\\b" + varName + "\\s*=\\s*)(?:\"|'"'"')0x[0-9a-fA-F]{40}(?:\"|'"'"')");
  src = src.replace(re2, "$1\"" + addr + "\"");
}
fs.writeFileSync(path, src);
console.log("🔧 Injected " + varName + " into " + path);'

  b64=$(echo "$js" | base64)
  inject="printf '%s' '$b64' | base64 -d > /tmp/inject.js && node /tmp/inject.js && touch '$target'"
  docker exec -e TARGET="$target" -e VARNAME="$var" -e ADDR="$addr" -it $NAME bash -lc "$inject"
else
  say "⚠️ Could not detect contract address automatically. Copy it from logs and paste manually in the debug UI file."
fi

# 12) Start frontend (restart cleanly and run Next directly from packages/nextjs)
say "🌐 Starting frontend (it may take ~15–30s to be ready)..."
docker exec $NAME bash -lc "pkill -f 'next dev' 2>/dev/null || true; pkill -f 'start-frontend.sh' 2>/dev/null || true"
docker exec -d $NAME bash -lc "cd /app/packages/nextjs && yarn dev > /tmp/next-dev.log 2>&1 & disown"
sleep 2
if ! docker exec $NAME bash -lc "command -v curl >/dev/null 2>&1 && curl -sf http://localhost:3000 >/dev/null 2>&1" &> /dev/null; then
  say "⌛ Waiting for dev server..."
fi

say "🎉 All set! Open: http://localhost:$PORT"
say "Shell inside container:  docker exec -it $NAME bash"
say "Switch challenge later:  docker rm -f $NAME   # then run this script again"
