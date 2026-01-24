<!-- SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell -->
<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->

# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

**Do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: **security@jewell.dev**

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

You will receive a response within 48 hours. If confirmed, we will:
1. Acknowledge the report
2. Work on a fix
3. Release a patch
4. Credit you (unless you prefer anonymity)

## Security Measures

### WASM Sandboxing

- selur.wasm runs in wasmtime sandbox (no host filesystem access)
- Linear types prevent memory leaks and use-after-free
- Shared memory is isolated per IPC session

### Formal Verification

- Idris2 proofs ensure IPC correctness (noLostRequests, noMemoryLeaks)
- Ephapax-linear enforces memory safety at compile time
- No unsafe code in Rust bindings

### Dependencies

- wasmtime: Bytecode Alliance (trusted, audited)
- Minimal dependency tree (only wasmtime + anyhow)

## Threat Model

selur mediates IPC between Svalinn (edge) and Vörðr (runtime):

1. **Malicious requests from edge**: WASM sandbox prevents host access
2. **Memory exhaustion**: Linear types bound memory usage
3. **IPC corruption**: Idris2 proofs ensure correctness
4. **Supply chain**: Dependencies pinned with Cargo.lock

## Disclosure Policy

- We follow responsible disclosure
- 90-day disclosure timeline after patch release
- Security advisories published via GitHub Security Advisories
