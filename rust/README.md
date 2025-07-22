# Rust

# 🦀 Rust Basics & Smart Contract Bootcamp

Welcome to the Rust + Stylus Bootcamp! This document serves as a comprehensive overview and recap of the topics covered, ideal for revision and quick reference.

---

## 📥 Installation Guide

### 🔹 Windows / macOS / Linux
Install Rust using `rustup`:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

After installation:

```sh
rustc --version   # check Rust compiler
cargo --version   # check Cargo package manager
```

---

## 🧠 Rust Syntax & Structure

```rust
fn main() {
    println!("Hello, world!");
}
```

- `fn` defines a function
- `main` is the program’s entry point
- `println!` is a macro to print output

---

## 🧮 Data Types in Rust

### Scalar Types
- `i32`, `u32`, `f64`, `bool`, `char`

### Compound Types
- **Tuple** – `(i32, f64, char)`
- **Array** – `[i32; 3]`
- **Vector** – `Vec<i32>`

---

## 📦 Variables in Rust

```rust
let x = 5;           // immutable
let mut y = 10;      // mutable
const PI: f64 = 3.14; // constant, must include type
```

---

## 🌀 Shadowing

```rust
let name = "Meet";
let name = name.len(); // now name is usize
```

- Allows redeclaration of a variable with a new type or value

---

## 🔁 Ownership, Borrowing & References

```rust
fn main() {
    let s = String::from("Rust");
    takes_ownership(s); // s is moved and cannot be used afterward
}

fn takes_ownership(val: String) {
    println!("{}", val);
}
```

### Borrowing
```rust
fn print_name(name: &String) {
    println!("{}", name);
}
```

### Mutable Borrowing
```rust
fn change(name: &mut String) {
    name.push_str(" Lang");
}
```

---

## ➕ Operators

- Arithmetic: `+`, `-`, `*`, `/`, `%`
- Logical: `&&`, `||`, `!`
- Comparison: `==`, `!=`, `>`, `<`, `>=`, `<=`

---

## 🔧 Functions

```rust
fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

---

## 🔁 Loops and Control Flow

### `loop`
```rust
loop {
    break;
}
```

### `while`
```rust
while condition {
    // code
}
```

### `for`
```rust
for i in 0..5 {
    println!("{}", i);
}
```

---

## 🧰 Tuple, Array, Vector

### Tuple
```rust
let tup = (1, "hello", true);
let (a, b, c) = tup;
```

### Array
```rust
let arr = [1, 2, 3, 4];
let first = arr[0];
```

### Vector
```rust
let mut vec = vec![10, 20, 30];
vec.push(40);
```

---

## 🗝️ Keywords in Rust

`fn`, `let`, `mut`, `const`, `match`, `if`, `else`, `loop`, `for`, `while`, `pub`, `mod`, `impl`, `struct`, `enum`, `use`, `ref`, `as`, `return`

---

## 📂 Rust Project Structure

Created using:

```sh
cargo new my_project
```

### Files generated:
- `Cargo.toml`: Like `package.json`, used for dependencies and metadata.
- `Cargo.lock`: Like `package-lock.json`, used to lock dependency versions.
- `src/main.rs`: Main application code.
- `target/`: Compiled output directory.

---

## 🗂 Statement vs Expression

```rust
let x = {
    let y = 5;
    y + 1 // This is an expression
};
```

---

## 💡 Constant & Static

```rust
const MAX_POINTS: u32 = 100_000;
```

---

## 🌍 WASM & Stylus

- Rust can compile to **WebAssembly (WASM)**, enabling high-performance code to run in web or blockchain environments.
- You can build **smart contracts** using frameworks like:
  - **Stylus** (for Arbitrum)
  - **ink!** (for Polkadot/Substrate)
  - **Solang** (Solidity-like syntax in WASM)

---

## 💬 Why Use Rust?

| Benefit                         | Description |
|----------------------------------|-------------|
| 🛡️ **Memory Safety Without GC** | Prevents null, dangling, or data races at compile time without a garbage collector |
| ⚡ **Performance Comparable to C** | Near-zero cost abstractions and high-speed execution |
| 🧱 **Strong Type System** | Avoids bugs and enforces code correctness at compile time |
| 🌐 **WebAssembly & Blockchain** | Rust is a top language for WASM and secure smart contract development |

---

## ✅ Topics Covered

- ✅ Installation
- ✅ Rust Syntax
- ✅ Data Types (Scalar + Compound)
- ✅ Variables & Constants
- ✅ Shadowing
- ✅ Ownership & Borrowing
- ✅ References (Mutable & Immutable)
- ✅ Operators & Control Flow
- ✅ Functions & Scoping
- ✅ Tuple, Array, Vector
- ✅ Statement vs Expression
- ✅ Keywords
- ✅ Project File Structure
- ✅ WASM Basics + Stylus Intro

---

## 📘 Want to Practice More?

Try building:
- ✅ Simple calculator CLI
- ✅ To-do list using vectors
- ✅ Ownership-based memory tracker
- ✅ WebAssembly example in browser

---

If you want to learn more about Rust, check out the official Rust book: [The Rust Programming Language](https://doc.rust-lang.org/book/)

---

Happy Rusting! 🦀🚀  
*Made with ❤️ by Lampros Labs*
