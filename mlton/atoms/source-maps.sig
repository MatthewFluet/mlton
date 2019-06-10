(* Copyright (C) 2009,2014,2019 Matthew Fluet.
 * Copyright (C) 1999-2007 Henry Cejtin, Matthew Fluet, Suresh
 *    Jagannathan, and Stephen Weeks.
 *
 * MLton is released under a HPND-style license.
 * See the file MLton-LICENSE for details.
 *)

signature SOURCE_MAPS_STRUCTS =
   sig
      structure ProfileLabel: PROFILE_LABEL
   end

signature SOURCE_MAPS =
   sig
      include SOURCE_MAPS_STRUCTS

      datatype t =
         T of {(* the collection of profile labels embedded in output program
                * paired with an index into sourceSeqs of the sequence of source
                * names corresponding to the code pointer; only used with
                * ProfileTimeLabel.
                *)
               profileLabelInfos: {profileLabel: ProfileLabel.t,
                                   sourceSeqIndex: int} vector,
               (* the collection of source names from the program.
                *)
               sourceNames: string vector,
               (* each entry describes a sequence of source names as a sequence
                * of indices into sources.
                *)
               sourceSeqs: {sourceIndex: int} vector vector,
               (* each entry describes a source name and successor sources as
                * the pair of an index into sourceNames and an index into
                * sourceSeqs.
                *)
               sources: {sourceNameIndex: int,
                         successorSourceSeqIndex: int} vector}

      val empty: t
      val check: t -> bool
      val checkSourceSeqIndex: t * int -> bool
      val checkProfileLabel: t -> (ProfileLabel.t -> bool) * (unit -> bool)
      val clear: t -> unit
      val layouts: t * (Layout.t -> unit) -> unit
      val layout: t -> Layout.t
      val modify: t -> {newProfileLabel: ProfileLabel.t -> ProfileLabel.t,
                        delProfileLabel: ProfileLabel.t -> unit,
                        getSourceMaps: unit -> t}
   end
