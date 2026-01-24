;; SPDX-License-Identifier: PMPL-1.0-or-later
;; META.scm - Project metadata and architectural decisions

(define project-meta
  `((version . "0.1.0")
    (architecture-decisions
      ((adr-001
         ((status . "accepted")
          (date . "2026-01-24")
          (context . "Need efficient IPC between Svalinn (ReScript/Deno edge) and Vörðr (Rust runtime). Options: JSON/HTTP, gRPC, WASM shared memory, direct FFI.")
          (decision . "Use WASM shared memory with Ephapax-linear types. Compile Ephapax to WASM32 via Zig.")
          (consequences . "Pros: Zero-copy, 30-50% faster than JSON/HTTP, formal verification possible. Cons: Requires Ephapax compiler, WASM runtime overhead, new technology risk. Mitigation: Provide --direct fallback to JSON/HTTP.")))
       (adr-002
         ((status . "accepted")
          (date . "2026-01-24")
          (context . "Linear types prevent memory leaks but add complexity. Options: Rust's borrow checker, Ephapax-linear, manual memory management.")
          (decision . "Use Ephapax-linear for compile-time guarantees of no leaks, no use-after-free.")
          (consequences . "Pros: Stronger than Rust (no unsafe), formally verifiable in Idris2. Cons: Steep learning curve, small ecosystem. Mitigation: Comprehensive docs and examples.")))
       (adr-003
         ((status . "accepted")
          (date . "2026-01-24")
          (context . "Formal verification options: Coq, Idris2, ATS2, TLA+. Need proofs of IPC correctness (noLostRequests, noMemoryLeaks).")
          (decision . "Use Idris2 for dependent types and executable proofs. ATS2 for dynamic validation in vordr-a variant.")
          (consequences . "Pros: Idris2 compiles to executable code, integrates with Ephapax. Cons: Compile-time overhead, limited tooling. Mitigation: Make verification opt-in (vordr-i variant).")))
       (adr-004
         ((status . "accepted")
          (date . "2026-01-24")
          (context . "Sealant positioning: separate binary vs library vs embedded in Svalinn/Vörðr.")
          (decision . "Ship as selur.wasm (WASM module) loaded by both Svalinn and Vörðr via wasmtime.")
          (consequences . "Pros: Sandboxed, polyglot (works with ReScript and Rust), distributable. Cons: WASM runtime startup cost. Mitigation: Lazy loading, caching compiled module.")))
       (adr-005
         ((status . "accepted")
          (date . "2026-01-24")
          (context . "Naming: Generic (ipc-bridge, wasm-channel) vs Nordic theme (selur, svalinn, vörðr).")
          (decision . "Use Nordic naming: selur (Icelandic for seal) aligns with Svalinn (shield) and Vörðr (guardian).")
          (consequences . "Pros: Memorable, cohesive branding, metaphor (seal bridges land/sea = sealant bridges edge/runtime). Cons: Non-obvious to non-Norse speakers. Mitigation: Explain in README.")))
       (adr-006
         ((status . "proposed")
          (date . "2026-01-24")
          (context . "Cerro Torre integration: selur as part of ct-seal tooling. Options: standalone binary, embedded in ct CLI, separate subcommand.")
          (decision . "Integrate as ct-seal run --selur selur.wasm myapp.ctp. Provide standalone selur CLI for testing.")
          (consequences . "Pros: Unified interface, follows ct-seal convention. Cons: Adds dependency to Cerro Torre. Mitigation: selur works standalone, ct-seal integration is optional.")))))
    (development-practices
      ((code-style . "zig fmt (Zig) + rustfmt (Rust bindings)")
       (security . "cargo-audit + openssf-scorecard + WASM sandboxing")
       (testing . "unit (Ephapax properties) + integration (Svalinn+Vörðr) + fuzzing (libFuzzer) + formal (Idris2)")
       (versioning . "semver")
       (documentation . "rustdoc + asciidoc + Idris2 literate proofs")
       (branching . "trunk-based")))
    (design-rationale
      ((why-wasm
         . "WASM provides sandboxing, polyglot interop (ReScript + Rust), and deterministic execution. Aligns with public-facing WASM proxy architecture.")
       (why-ephapax-linear
         . "Linear types eliminate entire classes of bugs (memory leaks, use-after-free) at compile time. Essential for zero-copy IPC where manual memory management would be error-prone.")
       (why-zig
         . "Zig compiles to WASM32 with minimal runtime, excellent C interop, explicit allocators. Enables Ephapax → WASM compilation pipeline.")
       (why-idris2
         . "Dependent types allow proofs about IPC properties (e.g., 'all requests receive responses'). Aligns with formal methods research goals.")
       (why-not-json-http
         . "JSON/HTTP has ~2.3ms latency vs selur's target <1ms. Serialization overhead is 8.2MB vs selur's <2MB. Type safety at runtime vs compile-time.")
       (why-nordic-naming
         . "Cohesive branding with Svalinn (edge shield) and Vörðr (runtime guardian). Metaphor: seal (selur) bridges land and sea like sealant bridges edge and runtime.")))))
