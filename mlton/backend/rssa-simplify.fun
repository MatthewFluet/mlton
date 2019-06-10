(* Copyright (C) 2019 Matthew Fluet.
 *
 * MLton is released under a HPND-style license.
 * See the file MLton-LICENSE for details.
 *)

functor RssaSimplify (S: RSSA_SIMPLIFY_STRUCTS): RSSA_SIMPLIFY =
struct

open S

structure ImplementHandlers = ImplementHandlers (S)
structure ImplementProfiling = ImplementProfiling (S)
structure LimitCheck = LimitCheck (S)
structure BounceVars = BounceVars (S)
structure SignalCheck = SignalCheck(S)

val rssaPasses =
   {name = "rssaShrink1", doit = Program.shrink, execute = true} ::
   {name = "insertLimitChecks", doit = LimitCheck.transform, execute = true} ::
   {name = "insertSignalChecks", doit = SignalCheck.transform, execute = true} ::
   (* must be before implementHandlers *)
   {name = "bounceVars", doit = BounceVars.transform, execute = true} ::
   {name = "implementHandlers", doit = ImplementHandlers.transform, execute = true} ::
   {name = "rssaShrink2", doit = Program.shrink, execute = true} ::
   {name = "implementProfiling", doit = ImplementProfiling.transform, execute = true} ::
   {name = "rssaOrderFunctions", doit = Program.orderFunctions, execute = true} ::
   {name = "rssaShuffle", doit = Program.shuffle, execute = false} ::
   nil

fun simplify p =
   let
      val rssaPasses = rssaPasses
      (* RSSA type check is too slow to run by default. *)
      (* val () = Control.trace (Control.Pass, "rssaTypeCheck") Program.typeCheck p *)
      val p =
         Control.simplifyPasses
         {arg = p,
          passes = rssaPasses,
          stats = Program.layoutStats,
          toFile = Program.toFile,
          typeCheck = Program.typeCheck}
      (* val () = Control.trace (Control.Pass, "rssaTypeCheck") Program.typeCheck p *)
   in
      p
   end
end
