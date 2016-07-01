(* Copyright (C) 2016 Matthew Fluet.
 * Copyright (C) 1999-2005, 2008 Henry Cejtin, Matthew Fluet, Suresh
 *    Jagannathan, and Stephen Weeks.
 * Copyright (C) 1997-2000 NEC Research Institute.
 *
 * MLton is released under a BSD-style license.
 * See the file MLton-LICENSE for details.
 *)

functor ClosureConvertRefactor (S: CLOSURE_CONVERT_STRUCTS): CLOSURE_CONVERT =
struct

open S

(* CFAs *)
structure IntersectCFA = IntersectCFA(S)
structure SynKnownCFA = SynKnownCFA(S)
structure TyCFA = TyCFA(S)
val cfaRef = ref (TyCFA.cfa {config = ()})
val cfaString = ref "tycfa"
val cfaGet = fn () => !cfaString
val cfaSet =
   let
      val cfaRdrs =
         IntersectCFA.scan ::
         SynKnownCFA.scan ::
         TyCFA.scan ::
         nil

      fun cfaRdrRec charRdr strm0 =
         let
            fun loop cfaRdrs =
               case cfaRdrs of
                  [] => NONE
                | cfaRdr::cfaRdrs =>
                     (case cfaRdr cfaRdrRec charRdr strm0 of
                         NONE => loop cfaRdrs
                       | SOME (cfa, strm') => SOME (cfa, strm'))
         in
            loop cfaRdrs
         end
   in
      fn s =>
      case cfaRdrRec Substring.getc (Substring.full s) of
         NONE => Result.No s
       | SOME (cfa, ss') =>
            if Substring.isEmpty ss'
               then (cfaRef := cfa;
                     cfaString := s;
                     Result.Yes ())
               else Result.No s
   end
val _ = List.push (Control.indirectFlags, {flag = "cc-cfa", get = cfaGet, set = cfaSet})

(* Transforms *)
structure TyTransform = TyTransform(S)

fun closureConvert (program: Sxml.Program.t): Ssa.Program.t =
   let
      val Sxml.Program.T {body, ...} = program

      val cfa =
         Control.trace (Control.Pass, "cfa: " ^ !cfaString) (!cfaRef)

      val {cfa, destroy = destroyCFA, ...} =
         cfa {program = program}

      val _ =
         Control.diagnostics
         (fn display =>
          let
             val {get, set, rem} =
                Property.getSetOnce
                (Sxml.Var.plist,
                 Property.initRaise ("ClosureConvert.get", Sxml.Var.layout))
             val _ =
                Sxml.Exp.foreachBoundVar
                (body, fn (var, _, ty) => set (var, ty))
             val _ =
                Sxml.Exp.foreachPrimExp
                (body, fn (res, resTy, exp) =>
                 case exp of
                    Sxml.PrimExp.App {func, arg} =>
                       let
                          val func = Sxml.VarExp.var func
                          val arg = Sxml.VarExp.var arg
                          val lambdas =
                             cfa {arg = arg,
                                  argTy = get arg,
                                  func = func,
                                  res = res,
                                  resTy = resTy}
                          val lambdas =
                             List.insertionSort
                             (lambdas, fn (lam1, lam2) =>
                              String.<= (Sxml.Var.toString (Sxml.Lambda.arg lam1),
                                         Sxml.Var.toString (Sxml.Lambda.arg lam2)))
                          val lambdasCard =
                             Int.layout (List.length lambdas)
                          fun layoutLam lam =
                             Layout.seq
                             [Layout.str "fn ",
                              Sxml.Var.layout (Sxml.Lambda.arg lam)]
                          val lambdas =
                             Layout.seq [Layout.str "{",
                                         (Layout.fill o Layout.separateRight)
                                         (List.map (lambdas, layoutLam), ","),
                                         Layout.str "}"]
                          val call =
                             (Layout.str o String.concat)
                             ["val ",
                              Sxml.Var.toString res,
                              " = ",
                              Sxml.Var.toString func,
                              " ",
                              Sxml.Var.toString arg]
                       in
                          (display o Layout.seq)
                          [Layout.str "|cfa(", call, Layout.str ")| = ", lambdasCard];
                          (display o Layout.align)
                          [Layout.seq [Layout.str "cfa(", call, Layout.str ") ="],
                           Layout.indent (lambdas, 3)]
                       end
                  | _ => ())
             val _ =
                Sxml.Exp.foreachBoundVar
                (body, fn (var, _, _) => rem var)
          in
             ()
          end)

      val {program, destroy = destroyTransform, ...} =
         TyTransform.transform {program = program, cfa = cfa}
      val _ = destroyCFA ()
      val _ = destroyTransform ()
      val _ = Ssa.Program.clear program
   in
      program
   end

end