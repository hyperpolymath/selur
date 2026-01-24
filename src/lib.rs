// SPDX-License-Identifier: PMPL-1.0-or-later
// SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell

//! Rust bindings for selur WASM sealant
//!
//! This library provides a safe Rust API for loading and interacting
//! with the selur.wasm module in Svalinn and Vörðr.

use wasmtime::*;
use std::path::Path;

pub struct Bridge {
    engine: Engine,
    module: Module,
}

impl Bridge {
    /// Load selur.wasm and initialize the bridge
    pub fn new(wasm_path: impl AsRef<Path>) -> Result<Self> {
        let engine = Engine::default();
        let module = Module::from_file(&engine, wasm_path)?;

        Ok(Self { engine, module })
    }

    /// Start the bridge (instantiate WASM module)
    pub fn start(&self) -> Result<()> {
        let mut store = Store::new(&self.engine, ());
        let _instance = Instance::new(&mut store, &self.module, &[])?;
        Ok(())
    }

    /// Send a request through the sealant
    pub fn send_request(&self, _request: &[u8]) -> Result<Vec<u8>> {
        // TODO: Implement request/response passing via WASM linear memory
        todo!("Implement request passing")
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_bridge_load() {
        // Test will pass when selur.wasm is built
        // let bridge = Bridge::new("../selur.wasm").unwrap();
        // bridge.start().unwrap();
    }
}
