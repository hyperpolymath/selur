-- SPDX-License-Identifier: PMPL-1.0-or-later
-- SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell
--
-- Formal verification proofs for selur IPC correctness

module Selur.Proofs

import Data.Vect

-- Core types matching Ephapax bridge
data Request : Type where
  MkRequest : String -> String -> Request

data Response : Type where
  MkResponse : Nat -> String -> Response

-- Properties to prove

||| Prove that no requests are lost in transit between Svalinn and Vörðr
||| @req The incoming request
||| @resp The response that must correspond to req
noLostRequests : (req : Request) -> (resp : Response) -> Type
noLostRequests req resp = ResponseMatchesRequest req resp

||| Prove that memory regions are properly freed (no leaks)
||| @before Memory state before IPC
||| @after Memory state after IPC
noMemoryLeaks : (before : Nat) -> (after : Nat) -> Type
noMemoryLeaks before after = before = after

||| Prove that all requests receive exactly one response (no duplication)
||| @req The request
||| @resps List of responses
oneResponsePerRequest : (req : Request) -> (resps : Vect n Response) -> Type
oneResponsePerRequest req resps = n = 1

-- Helper lemmas (to be proven)

ResponseMatchesRequest : Request -> Response -> Type
ResponseMatchesRequest (MkRequest method path) (MkResponse status body) =
  ?responseMatchesRequest_impl

-- Theorem: IPC is correct if no requests lost and no memory leaked
total
ipcCorrectness : (req : Request)
              -> (resp : Response)
              -> (beforeMem : Nat)
              -> (afterMem : Nat)
              -> (noLostRequests req resp, noMemoryLeaks beforeMem afterMem)
              -> Type
ipcCorrectness req resp beforeMem afterMem (reqProof, memProof) =
  ?ipcCorrectness_impl
