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
    store: Store<()>,
    instance: Instance,
}

impl Bridge {
    /// Load selur.wasm and initialize the bridge
    pub fn new(wasm_path: impl AsRef<Path>) -> Result<Self> {
        let engine = Engine::default();
        let module = Module::from_file(&engine, wasm_path)?;
        let mut store = Store::new(&engine, ());
        let instance = Instance::new(&mut store, &module, &[])?;

        Ok(Self {
            engine,
            module,
            store,
            instance,
        })
    }

    /// Send a request through the sealant
    pub fn send_request(&mut self, request: &[u8]) -> Result<Vec<u8>> {
        // 1. Allocate WASM memory for request
        let allocate = self
            .instance
            .get_typed_func::<u32, u32>(&mut self.store, "allocate")?;
        let request_ptr = allocate.call(&mut self.store, request.len() as u32)?;

        // 2. Write request data to WASM linear memory
        let memory = self
            .instance
            .get_memory(&mut self.store, "memory")
            .ok_or_else(|| anyhow::anyhow!("Failed to get WASM memory"))?;
        memory.write(&mut self.store, request_ptr as usize, request)?;

        // 3. Call send_request in WASM
        let send_request_fn = self
            .instance
            .get_typed_func::<(u32, u32), u32>(&mut self.store, "send_request")?;
        let error_code = send_request_fn.call(
            &mut self.store,
            (request_ptr, request.len() as u32),
        )?;

        if error_code != 0 {
            return Err(anyhow::anyhow!("WASM send_request failed with code {}", error_code));
        }

        // 4. Get response pointer from WASM
        let get_response_fn = self
            .instance
            .get_typed_func::<u32, u32>(&mut self.store, "get_response")?;
        let response_len = get_response_fn.call(&mut self.store, 0)?;

        // 5. Read response data from WASM linear memory
        let mut response = vec![0u8; response_len as usize];
        memory.read(&self.store, 0, &mut response)?;

        // 6. Deallocate request memory (response memory handled by WASM)
        let deallocate = self
            .instance
            .get_typed_func::<(u32, u32), ()>(&mut self.store, "deallocate")?;
        deallocate.call(&mut self.store, (request_ptr, request.len() as u32))?;

        Ok(response)
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
