;; SPDX-License-Identifier: PMPL-1.0-or-later
;; ECOSYSTEM.scm - Project relationship mapping

(ecosystem
  (version "1.0")
  (name "selur")
  (type "wasm-bridge")
  (purpose "Zero-copy IPC sealant between Svalinn edge gateway and Vörðr container runtime using Ephapax-linear types")

  (position-in-ecosystem
    (role "bridge-component")
    (layer "runtime-integration")
    (description "WASM-based sealant that enables memory-safe, zero-overhead IPC between Svalinn (ReScript/Deno edge gateway) and Vörðr (Rust OCI runtime). Part of Cerro Torre container tooling ecosystem. Implements Ephapax-linear type system for compile-time memory safety guarantees."))

  (related-projects
    ((name . "svalinn")
     (relationship . "sibling-standard")
     (description . "ReScript-powered edge gateway (Deno) - selur bridges Svalinn to Vörðr"))
    ((name . "cerro-torre")
     (relationship . "sibling-standard")
     (description . "Parent container tooling ecosystem - selur is part of ct-seal architecture"))
    ((name . "ephapax")
     (relationship . "sibling-standard")
     (description . "Linear type system for WASM memory safety - selur uses Ephapax-linear"))
    ((name . "verified-container-spec")
     (relationship . "sibling-standard")
     (description . "Supply-chain verification protocol - selur works with .ctp bundles"))
    ((name . "wasmtime")
     (relationship . "inspiration")
     (description . "WASM runtime - selur.wasm runs in wasmtime"))
    ((name . "zig")
     (relationship . "inspiration")
     (description . "Systems language - used to compile Ephapax to WASM32")))

  (provides
    (capability "zero-copy-ipc")
    (capability "ephapax-linear-verification")
    (capability "wasm-sandboxed-bridge")
    (interface "request-response-channel"))

  (consumes
    (dependency "ephapax-linear")
    (dependency "wasmtime-runtime")
    (dependency "zig-wasm-toolchain"))

  (integration-points
    ((component . "svalinn")
     (method . "wasm-module-import")
     (description . "Svalinn loads selur.wasm and calls send_request()"))
    ((component . "vörðr")
     (method . "rust-embedded-wasmtime")
     (description . "Vörðr embeds wasmtime and instantiates selur.wasm"))
    ((component . "ct-seal")
     (method . "cli-flag")
     (description . "ct-seal run --selur selur.wasm myapp.ctp")))

  (what-this-is
    "A WASM bridge compiled from Ephapax-linear code (via Zig) that provides zero-copy memory sharing between Svalinn (edge gateway) and Vörðr (container runtime). Replaces heavyweight serialization (JSON/HTTP, gRPC) with shared WASM linear memory. Enforces linear types to prevent memory leaks and use-after-free. Includes formal verification via Idris2 proofs. Part of Cerro Torre's welding (tight .ctp integration) and gluing (loose arbitrary image wrapping) architecture. Named 'selur' (Icelandic for seal) because it seals the gap between edge and runtime like a seal bridges land and sea.")

  (what-this-is-not
    "Not a general-purpose IPC framework (specific to Svalinn-Vörðr). Not a replacement for Svalinn or Vörðr (bridges them). Not a container runtime (works with Vörðr). Not language-specific (WASM is polyglot). Not a serialization library (eliminates serialization). Not standalone (part of Cerro Torre ecosystem)."))
