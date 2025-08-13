#Requires -Version 7
$ErrorActionPreference = "Stop"

# Ensure script execution is permitted for current user (no prompt)
try {
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop | Out-Null
} catch {
  Write-Host "⚠️ Could not set ExecutionPolicy (scope CurrentUser). Continuing..."
}

# ---------------- Config ----------------
$IMG  = "abxglia/speedrun-stylus:0.1"
$NAME = "speedrun-stylus"
$REPO = "https://github.com/abhi152003/speedrun_stylus.git"
$PORT = 3000
# ---------------------------------------

function Say($msg) { Write-Host "`n$msg" }

# 0) Checks
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Host "❌ Docker not found. Install Docker Desktop."; exit 1
}
try { docker info | Out-Null } catch { Write-Host "❌ Docker daemon not running. Start Docker Desktop."; exit 1 }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Host "❌ git not found. Install git."; exit 1
}

# 1) Choose challenge
Write-Host "Choose a challenge:
1) counter
2) nft
3) vending-machine
4) multi-sig
5) stylus-uniswap"
$sel = Read-Host "Enter 1-5"
switch ($sel) {
  "1" { $branch="counter";         $challenge="counter" }
  "2" { $branch="nft";             $challenge="nft" }
  "3" { $branch="vending-machine"; $challenge="vending_machine" }
  "4" { $branch="multi-sig";       $challenge="multi-sig" }
  "5" { $branch="stylus-uniswap";  $challenge="stylus-uniswap-v2" }
  default { Write-Host "Invalid choice."; exit 1 }
}

# 2) Prepare workspace
$WORKDIR = Join-Path (Get-Location) ("speedrun-" + $branch)
New-Item -ItemType Directory -Force -Path $WORKDIR | Out-Null
Set-Location $WORKDIR

# 3) Clone only needed branch (idempotent)
if (-not (Test-Path ".git")) {
  Say "📦 Cloning branch '$branch'..."
  git init | Out-Null
  git remote add origin $REPO
  git fetch --depth=1 origin $branch
  git checkout -b $branch FETCH_HEAD | Out-Null
} else {
  Say "ℹ️ Repo already present. Using existing checkout."
}

# 4) Ensure image present (skip pull if already local)
$null = docker image inspect $IMG 2>$null
if ($LASTEXITCODE -ne 0) {
  Say "🐳 Pulling Docker image (first time only)..."
  docker pull $IMG | Out-Null
} else {
  Say "✅ Docker image present; skipping pull."
}

# 5) Always remove existing container and start fresh
Say "🧹 Removing any existing container '$NAME'..."
docker rm -f $NAME 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
  Say "✅ Existing container removed successfully"
} else {
  Say "ℹ️ No existing container found (this is normal for first run)"
}

# 6) Start new container with caches
Say "🚀 Starting fresh container..."
docker run -d --name $NAME `
  -v ${PWD}:/app `
  -v speedrun-yarn-cache:/root/.cache/yarn `
  -v speedrun-cargo-registry:/root/.cargo/registry `
  -v speedrun-cargo-git:/root/.cargo/git `
  -v speedrun-rustup:/root/.rustup `
  -v speedrun-foundry:/root/.foundry `
  -p "$PORT`:3000" `
  $IMG tail -f /dev/null | Out-Null

# 7) Ensure deploy script exists
docker exec -it $NAME bash -lc "command -v deploy-contract.sh >/dev/null || { echo 'deploy-contract.sh missing in image'; exit 1; }"

# 8) Install deps (skip if already installed)
Say "📥 Ensuring dependencies are installed..."
docker exec -it $NAME bash -lc "cd /app && if [ -d node_modules ] && [ -d packages/nextjs/node_modules ]; then echo '✔ yarn already installed; skipping.'; else yarn install; fi"

# 9) Private key (skip prompt if both .env files already contain keys)
if ($challenge -eq "counter") {
  $pkgEnv = "/app/packages/stylus-demo/.env"
} else {
  $pkgEnv = "/app/packages/cargo-stylus/$challenge/.env"
}
$nextEnv = "/app/packages/nextjs/.env"

docker exec $NAME bash -lc "test -f '$nextEnv' && grep -q '^NEXT_PUBLIC_PRIVATE_KEY=0x' '$nextEnv'" | Out-Null
$nextOk = ($LASTEXITCODE -eq 0)
docker exec $NAME bash -lc "test -f '$pkgEnv' && grep -q '^PRIVATE_KEY=0x' '$pkgEnv'" | Out-Null
$pkgOk = ($LASTEXITCODE -eq 0)
$skipPkPrompt = ($nextOk -and $pkgOk)

if (-not $skipPkPrompt) {
  $secure = Read-Host -AsSecureString "Enter PRIVATE KEY (hex, no spaces). I will prepend 0x"
  $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  $raw = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
  $pk = "0x" + ($raw -replace '^0x','')
} else {
  $pk = $null
}

# 10) Write env files
Say "🧩 Writing .env files..."
if ($skipPkPrompt) {
  # Only ensure RPC URL in nextjs .env; do not modify existing keys
  $envCmdNoKey = "set -e; cd /app/packages/nextjs || { echo 'nextjs package not found'; exit 1; }; if [ ! -f .env ]; then if [ -f .env.example ]; then cp -n .env.example .env; else touch .env; fi; fi; if grep -q '^NEXT_PUBLIC_RPC_URL=' .env; then sed -i 's^NEXT_PUBLIC_RPC_URL=.*^NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc^' .env; else echo 'NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc' >> .env; fi"
  docker exec -it $NAME bash -lc $envCmdNoKey
} else {
  # Write both RPC URL and keys
  $envCmd = "set -e; cd /app/packages/nextjs || { echo 'nextjs package not found'; exit 1; }; if [ ! -f .env ]; then if [ -f .env.example ]; then cp -n .env.example .env; else touch .env; fi; fi; if grep -q '^NEXT_PUBLIC_RPC_URL=' .env; then sed -i 's^NEXT_PUBLIC_RPC_URL=.*^NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc^' .env; else echo 'NEXT_PUBLIC_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc' >> .env; fi; if grep -q '^NEXT_PUBLIC_PRIVATE_KEY=' .env; then sed -i 's^NEXT_PUBLIC_PRIVATE_KEY=.*^NEXT_PUBLIC_PRIVATE_KEY=$pk^' .env; else echo 'NEXT_PUBLIC_PRIVATE_KEY=$pk' >> .env; fi"
  docker exec -it $NAME bash -lc $envCmd
  if ($challenge -eq "counter") {
    docker exec -it $NAME bash -lc "mkdir -p /app/packages/stylus-demo; echo 'PRIVATE_KEY=$pk' > /app/packages/stylus-demo/.env"
  } else {
    docker exec -it $NAME bash -lc "mkdir -p /app/packages/cargo-stylus/$challenge; echo 'PRIVATE_KEY=$pk' > /app/packages/cargo-stylus/$challenge/.env"
  }
}

# 11) Force re-deploy contract every time (clear old artifacts and deploy fresh)
if ($challenge -eq "counter") {
  $baseDir = "/app/packages/stylus-demo"
} else {
  $baseDir = "/app/packages/cargo-stylus/$challenge"
}

$deployJson = "$baseDir/build/stylus-deployment-info.json"
$deployLog  = "$baseDir/deploy.log"

# Clear previous deployment artifacts to force fresh deployment
Say "🧹 Clearing previous deployment artifacts..."
docker exec $NAME bash -lc "rm -f '$deployJson' '$deployLog'" | Out-Null

# Force fresh deployment every time
Say "🛠️ Deploying contract for '$challenge' (fresh deployment)..."
$deployOut = docker exec $NAME bash -lc "cd /app && deploy-contract.sh $challenge | tee '$deployLog'"
$addr = ($deployOut | Select-String -Pattern '0x[0-9a-fA-F]{40}' -AllMatches).Matches | Select-Object -Last 1 | ForEach-Object { $_.Value }

if ($addr) {
  Say "✅ Contract address: $addr"
  if ($challenge -eq "stylus-uniswap-v2") {
    $target = "/app/packages/nextjs/app/debug/_components/UniswapInterface.tsx"
    $var = "uniswapContractAddress"
  } else {
    $target = "/app/packages/nextjs/app/debug/_components/DebugContracts.tsx"
    $var = "contractAddress"
  }

  # Always inject the new contract address (force update)
  Say "🔧 Updating frontend with new contract address..."
  
  # Inject detected contract address into frontend file using Node (robust across shells)
  $js = @"
const fs = require('fs');
const path = process.env.TARGET;
const varName = process.env.VARNAME;
const addr = process.env.ADDR;
if (!fs.existsSync(path)) {
  console.log('⚠️ ' + path + ' not found; please paste manually.');
  process.exit(0);
}
let src = fs.readFileSync(path, 'utf8');
const re = new RegExp(varName + '\\s*=\\s*(?:\"|\')0x[0-9a-fA-F]{40}(?:\"|\')');
if (re.test(src)) {
  src = src.replace(re, varName + '="' + addr + '"');
} else {
  const re2 = new RegExp('(\\\b' + varName + '\\s*=\\s*)(?:\"|\')0x[0-9a-fA-F]{40}(?:\"|\')');
  src = src.replace(re2, '$1"' + addr + '"');
}
fs.writeFileSync(path, src);
console.log('🔧 Injected ' + varName + ' into ' + path);
"@
    $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($js))
    $inject = "printf '%s' '$b64' | base64 -d > /tmp/inject.js && node /tmp/inject.js && touch '$target'"
    docker exec -e TARGET="$target" -e VARNAME="$var" -e ADDR="$addr" -it $NAME bash -lc $inject
} else {
  Say "⚠️ Could not detect contract address automatically. Copy it from logs and paste manually in the debug UI file."
}

# 12) Start frontend (restart cleanly and run Next directly from packages/nextjs)
Say "🌐 Starting frontend (it may take ~15–30s to be ready)..."
docker exec $NAME bash -lc "pkill -f 'next dev' 2>/dev/null || true; pkill -f 'start-frontend.sh' 2>/dev/null || true"
docker exec -d $NAME bash -lc "cd /app/packages/nextjs && yarn dev > /tmp/next-dev.log 2>&1 & disown"
Start-Sleep -Seconds 2
docker exec $NAME bash -lc "command -v curl >/dev/null 2>&1 && curl -sf http://localhost:3000 >/dev/null 2>&1" | Out-Null
if ($LASTEXITCODE -ne 0) { Say "⌛ Waiting for dev server..." }

Say "🎉 All set! Open: http://localhost:$PORT"
Say "Shell inside container:  docker exec -it $NAME bash"
Say "Switch challenge later:  docker rm -f $NAME   # then run this script again"