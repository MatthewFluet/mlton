(* Copyright (C) 2009 Matthew Fluet.
 * Copyright (C) 1999-2006 Henry Cejtin, Matthew Fluet, Suresh
 *    Jagannathan, and Stephen Weeks.
 * Copyright (C) 1997-2000 NEC Research Institute.
 *
 * MLton is released under a BSD-style license.
 * See the file MLton-LICENSE for details.
 *)

signature ME_ALLOCATE_REGISTERS_STRUCTS =
   sig
      structure Rssa: ME_RSSA
      structure Machine: MACHINE
      sharing Rssa.Runtime = Machine.Runtime
      sharing Rssa.Type = Machine.Type
   end

signature ME_ALLOCATE_REGISTERS =
   sig
      include ME_ALLOCATE_REGISTERS_STRUCTS

      val allocate:
         {mkArgOperands: (Rssa.Var.t * Rssa.Type.t) vector -> Machine.Operand.t vector,
          function: Rssa.Function.t,
          varInfo: Rssa.Var.t -> {
                                  (* If (isSome operand) then a stack slot or
                                   * register needs to be allocated for the
                                   * variable.
                                   *)
                                  operand: Machine.Operand.t option ref option,
                                  ty: Machine.Type.t
                                  }
          }
         -> {(* If handlers are used, handlerLinkOffset gives the stack offsets
              * where the handler and link (old exnStack) should be stored.
              *)
             handlerLinkOffset: {handler: Bytes.t,
                                 link: Bytes.t} option,
             labelInfo:
             Rssa.Label.t -> {(* Live operands at the beginning of the block. *)
                              live: Machine.Operand.t vector,
                              (* Live operands at the beginning of the block, 
                               * excepting its formals.
                               *)
                              liveNoFormals: Machine.Operand.t vector,
                              (* Size of frame including return address. *)
                              size: Bytes.t}}
   end
