(* Copyright (C) 2017 Matthew Fluet.
 * Copyright (C) 1999-2008 Henry Cejtin, Matthew Fluet, Suresh
 *    Jagannathan, and Stephen Weeks.
 * Copyright (C) 1997-2000 NEC Research Institute.
 *
 * MLton is released under a BSD-style license.
 * See the file MLton-LICENSE for details.
 *)

structure Array: ARRAY_EXTRA =
   struct
      structure A = Sequence (Primitive.Array)
      open A

      val op +? = Int.+?
      val op < = Int.<
      val op <= = Int.<=

      fun wrap2 f = fn (i, x) => f (SeqIndex.toIntUnsafe i, x)

      type 'a array = 'a array
      type 'a vector = 'a Vector.vector

      structure ArraySlice =
         struct
            open Slice
            val vector = Primitive.Array.Slice.vector
            fun update x = updateMk Primitive.Array.updateUnsafe x
            fun unsafeUpdate x = unsafeUpdateMk Primitive.Array.updateUnsafe x
            val copyVec = Vector.VectorSlice.copy
            val unsafeCopyVec = Vector.VectorSlice.unsafeCopy
            fun modifyi f sl = Primitive.Array.Slice.modifyi (wrap2 f) sl
            val modify = Primitive.Array.Slice.modify
         end

      val array = new
      val vector = Primitive.Array.vector
      fun update x = updateMk Primitive.Array.updateUnsafe x
      fun unsafeUpdate x = unsafeUpdateMk Primitive.Array.updateUnsafe x
      val copyVec = Vector.copy
      val unsafeCopyVec = Vector.unsafeCopy
      fun modifyi f sl = Primitive.Array.modifyi (wrap2 f) sl
      val modify = Primitive.Array.modify
   end

structure ArraySlice: ARRAY_SLICE_EXTRA = Array.ArraySlice

structure ArrayGlobal: ARRAY_GLOBAL = Array
open ArrayGlobal
