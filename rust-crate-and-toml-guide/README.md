# Smart Cache Script

## Setup Instructions

### 1. Repository Setup

The first step is to get the repository code that you have already submitted for the speedrun challenges. 

- **If you have not deleted that repo**: Open it in your Cursor or VSCode IDE
- **If you have deleted the repo**: Create anew folder, open it in Cursor and Clone your published repository from your GitHub that you submitted for the speedrun challenges

### 2. Directory Navigation

**Important Note**: All commands including cd commands must be run in WSL (Windows Subsystem for Linux) only. If you're on Windows, make sure to use WSL terminal for all operations.

After you have the code for that challenge open in your IDE, open the terminal and navigate to the appropriate directory:

#### For Counter Project:
```bash
cd speedrun_stylus/packages/stylus-demo
```

#### For NFT Project:
```bash
cd speedrun_stylus/packages/cargo-stylus/nft
```

#### For Vending Machine Project:
```bash
cd speedrun_stylus/packages/cargo-stylus/vending_machine
```

**Note**: In short, you have to find `rust-toolchain.toml` and `cd` into the folder structure until you get the `rust-toolchain.toml` file.

### 3. Install Dependencies and Add Cache Functionality

**Important Note**: All cargo commands must be run in WSL (Windows Subsystem for Linux) only. If you're on Windows, make sure to use WSL terminal for all cargo operations.

Install the stylus cache SDK:
```bash
cargo add stylus-cache-sdk
```

Then add the following code in your `lib.rs` file:

```rust
use stylus_cache_sdk::{is_contract_cacheable};

#[public]
impl Counter {
    pub fn is_cacheable(&self) -> bool {
        is_contract_cacheable()
    }
}
```

**Important**: Just like this example, in the `impl` block of your contract, you must include the `is_cacheable` function. Make sure that the function must be exactly like this.

### 4. Make Your Contract Unique

Change the name of any function in your contract to make it unique. For example, if you are working on the counter challenge, in the `impl Counter` block you will have all the defined functions. Change the function name like this:

- If the function name is `set_number`, change it to `set_number_meet`
- Simply append your name so that the contract can be unique for everyone

### 5. Deploy Your Contract

Run the following command in WSL only (if you are on Windows):

```bash
cargo stylus deploy --endpoint='https://sepolia-rollup.arbitrum.io/rpc' --private-key="<YOUR_PRIVATE_KEY>" --no-verify
```

**Troubleshooting**: If you get any issue related to `wasm32-unknown-unknown`, run the command:
```bash
rustup target add wasm32-unknown-unknown
```

Then run the `cargo stylus deploy` command again.

### 6. Commit and Submit

Commit your changes, push them to your repository, and make sure to submit that same repository again on [https://www.speedrunstylus.com/](https://www.speedrunstylus.com/) for the challenge you were working on (e.g., if the `lib.rs` was for counter contract, then submit your modified code for counter repo again in the speedrun).

### 7. Initialize Smart Cache

**Important Note**: From step 7 onwards, make sure to run all commands in a new terminal using PowerShell or bash (not WSL).

In that same challenge's code in your IDE, open a new terminal and run:

```bash
npm unlink -g smart-cache-cli
```

If you have installed smart-cache previously, then run:
```bash
npm install -g smart-cache-cli
```

Then run:
```bash
smart-cache init
```

This will create a new `smartcache.toml` file.

### 8. Configure Smart Cache

In the `smart-cache.toml` file, add:
- The contract address which you just deployed on Arbitrum Sepolia
- The deployed address of the private key which you used to deploy the contract on Arbitrum Sepolia

### 9. Add Contract to Cache

Run the command:
```bash
smart-cache add
```

This command will be running in your terminal and the contract will be cached to optimize gas usage.

### 10. Final Submission

Push your changed code to your GitHub repository again and then submit that repository again in the speedrun challenges.
