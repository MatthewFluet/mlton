(* Copyright (C) 1999-2006 Henry Cejtin, Matthew Fluet, Suresh
 *    Jagannathan, and Stephen Weeks.
 * Copyright (C) 1997-2000 NEC Research Institute.
 *
 * MLton is released under a BSD-style license.
 * See the file MLton-LICENSE for details.
 *)

signature ME_CLOSURE_CONVERT_STRUCTS =
   sig
      structure Ssa: ME_SSA
      structure Sxml: SXML
      sharing Sxml.Atoms = Ssa.Atoms
   end

signature ME_CLOSURE_CONVERT =
   sig
      include ME_CLOSURE_CONVERT_STRUCTS

      val closureConvert: Sxml.Program.t -> Ssa.Program.t
   end
