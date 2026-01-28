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
    cd idris && idris2 --check Proofs.idr
    cd idris && idris2 --check Theorems.idr

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
    cd idris && idris2 --check Proofs.idr
    cd idris && idris2 --check Theorems.idr
    @echo "✓ All proofs verified"

# List all tasks
list:
    @just --list

# ============================================================
# Welded Build: selur(svalinn+vordr)
# ============================================================

VERSION := "1.0.0"

# Build welded image (svalinn + vordr integrated via selur IPC)
build-sv:
    @echo "🔗 Building selur(svalinn+vordr) welded image..."
    podman build -f containerfiles/selur-sv.containerfile \
      -t selur-sv:{{VERSION}} \
      -t selur-sv:latest \
      --build-context vordr=../vordr \
      --build-context svalinn=../svalinn \
      .

# Test welded deployment
test-sv:
    @echo "🧪 Testing selur-sv welded deployment..."
    podman run -d --name test-sv -p 8000:8000 selur-sv:latest
    sleep 5
    curl -f http://localhost:8000/healthz || (podman logs test-sv && exit 1)
    @echo "✅ Health check passed"
    podman stop test-sv && podman rm test-sv

# Run welded image locally
run-sv:
    @echo "🚀 Running selur-sv..."
    podman run -d \
      -p 8000:8000 \
      -v selur-data:/var/lib/selur-sv \
      --name selur-sv \
      selur-sv:latest
    @echo "✅ Running at http://localhost:8000"

# Stop welded image
stop-sv:
    podman stop selur-sv || true
    podman rm selur-sv || true

# Publish welded image
publish-sv:
    @echo "📤 Publishing selur-sv..."
    podman push selur-sv:{{VERSION}} ghcr.io/hyperpolymath/selur-sv:{{VERSION}}
    podman push selur-sv:latest ghcr.io/hyperpolymath/selur-sv:latest

# Clean welded build artifacts
clean-sv:
    podman rmi selur-sv:{{VERSION}} || true
    podman rmi selur-sv:latest || true
