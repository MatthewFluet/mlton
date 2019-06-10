/* Copyright (C) 2014,2019 Matthew Fluet.
 * Copyright (C) 1999-2008 Henry Cejtin, Matthew Fluet, Suresh
 *    Jagannathan, and Stephen Weeks.
 * Copyright (C) 1997-2000 NEC Research Institute.
 *
 * MLton is released under a HPND-style license.
 * See the file MLton-LICENSE for details.
 */

#ifndef _COMMON_MAIN_H_
#define _COMMON_MAIN_H_

#include "mlton-main.h"

#define MLTON_GC_INTERNAL_TYPES
#define MLTON_GC_INTERNAL_BASIS
#include "platform.h"

/* The label must be declared as weak because gcc's optimizer may prove that
 * the code that declares the label is dead and hence eliminate the declaration.
 */
#define DeclareProfileLabel(l)                  \
        extern char l __attribute__ ((weak))

#define BeginVectorInits static struct GC_vectorInit vectorInits[] = {
#define VectorInitElem(es, gi, l, w) { es, gi, l, w },
#define EndVectorInits };

#define LoadArray(a, f) if (fread (a, sizeof(*a), cardof(a), f) != cardof(a)) return -1;
#define SaveArray(a, f) if (fwrite(a, sizeof(*a), cardof(a), f) != cardof(a)) return -1;

PRIVATE Pointer gcStateAddress;

#define Initialize(al, mg, mfs, mmc, pk, ps)                            \
        gcStateAddress = (pointer)&gcState;                             \
        gcState.alignment = al;                                         \
        gcState.atMLtons = atMLtons;                                    \
        gcState.atMLtonsLength = cardof(atMLtons);                      \
        gcState.frameInfos = frameInfos;                                \
        gcState.frameInfosLength = cardof(frameInfos);                  \
        gcState.globals = (objptr*)globalObjptr;                        \
        gcState.globalsLength = cardof(globalObjptr);                   \
        gcState.loadGlobals = loadGlobals;                              \
        gcState.magic = mg;                                             \
        gcState.maxFrameSize = mfs;                                     \
        gcState.mutatorMarksCards = mmc;                                \
        gcState.objectTypes = objectTypes;                              \
        gcState.objectTypesLength = cardof(objectTypes);                \
        gcState.returnAddressToFrameIndex = returnAddressToFrameIndex;  \
        gcState.saveGlobals = saveGlobals;                              \
        gcState.vectorInits = vectorInits;                              \
        gcState.vectorInitsLength = cardof(vectorInits);                \
        gcState.sourceMaps.profileLabelInfos = profileLabelInfos;       \
        gcState.sourceMaps.profileLabelInfosLength = cardof(profileLabelInfos);   \
        gcState.sourceMaps.sourceNames = sourceNames;                   \
        gcState.sourceMaps.sourceNamesLength = cardof(sourceNames);     \
        gcState.sourceMaps.sourceSeqs = sourceSeqs;                     \
        gcState.sourceMaps.sourceSeqsLength = cardof(sourceSeqs);       \
        gcState.sourceMaps.sources = sources;                           \
        gcState.sourceMaps.sourcesLength = cardof(sources);             \
        gcState.profiling.kind = pk;                                    \
        gcState.profiling.stack = ps;                                   \
        MLton_init (argc, argv, &gcState);                              \

#define LIB_PASTE(x,y) x ## y
#define LIB_OPEN(x) LIB_PASTE(x, _open)
#define LIB_CLOSE(x) LIB_PASTE(x, _close)

#endif /* #ifndef _COMMON_MAIN_H_ */
