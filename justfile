# SPDX-License-Identifier: PMPL-1.0-or-later
# justfile for selur

# Build selur.wasm from Zig (Ephapax compiler not ready yet)
build:
    @echo "Building selur.wasm..."
    cd zig && zig build wasm

# Run tests
test:
    @echo "Running Rust tests..."
    cargo test
    @echo "Verifying Idris2 proofs..."
    cd idris && idris2 --check proofs.idr
    cd idris && idris2 --check theorems.idr

# Check code quality
check:
    cargo clippy -- -D warnings
    cargo fmt -- --check

# Format code
fmt:
    cargo fmt

# Clean build artifacts
clean:
    cd zig && zig build clean || true
    cargo clean
    rm -rf zig/zig-out zig/zig-cache

# Generate docs
docs:
    cargo doc --no-deps --open

# Run benchmarks
bench:
    cargo bench

# Verify Idris2 proofs
verify:
    @echo "Verifying Idris2 proofs..."
    cd idris && idris2 --check proofs.idr
    cd idris && idris2 --check theorems.idr
    @echo "✓ All proofs verified"

# List all tasks
list:
    @just --list
