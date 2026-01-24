# SPDX-License-Identifier: PMPL-1.0-or-later
# justfile for selur

# Build selur.wasm from Ephapax-linear
build:
    @echo "Building selur.wasm..."
    must zig/build.must selur.wasm

# Run tests
test:
    cargo test
    must zig/build.must test

# Check code quality
check:
    cargo clippy -- -D warnings
    cargo fmt -- --check

# Format code
fmt:
    cargo fmt

# Clean build artifacts
clean:
    must zig/build.must clean
    cargo clean

# Generate docs
docs:
    cargo doc --no-deps --open

# Run benchmarks
bench:
    cargo bench

# Verify Idris2 proofs
verify:
    @echo "Verifying Idris2 proofs..."
    cd idris && idris2 --build proofs.idr
