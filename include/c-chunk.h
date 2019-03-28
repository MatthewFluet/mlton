/* Copyright (C) 2019 Matthew Fluet.
 * Copyright (C) 1999-2008 Henry Cejtin, Matthew Fluet, Suresh
 *    Jagannathan, and Stephen Weeks.
 * Copyright (C) 1997-2000 NEC Research Institute.
 *
 * MLton is released under a HPND-style license.
 * See the file MLton-LICENSE for details.
 */

#ifndef _C_CHUNK_H_
#define _C_CHUNK_H_

#include <stdio.h>
/* `memcpy` is used by coercion `<ty>_castTo<ty>` functions (`basis/coerce.h`)
 * and by misaligned `<ty>_fetch`, `<ty>_store`, and `<ty>_move` functions
 * (`basis/Real/Real-ops.h` and `basis/Word/Word-ops.h`)
 */
#include <string.h>
/* Math functions used by `Real<n>_f` functions (`basis/Real/Real-ops.h`).
 */
#include <math.h>

#include "ml-types.h"
#include "c-types.h"
#include "c-common.h"

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef DEBUG_CCODEGEN
#define DEBUG_CCODEGEN FALSE
#endif

#define GCState ((Pointer)&gcState)
#define ExnStack *(size_t*)(GCState + ExnStackOffset)
#define FrontierMem *(Pointer*)(GCState + FrontierOffset)
#define Frontier frontier
#define StackBottom *(Pointer*)(GCState + StackBottomOffset)
#define StackTopMem *(Pointer*)(GCState + StackTopOffset)
#define StackTop stackTop

/* ------------------------------------------------- */
/*                      Memory                       */
/* ------------------------------------------------- */

#define C(ty, x) (*(ty*)(x))
#define G(ty, i) (global##ty [i])
#define GPNR(i) G(ObjptrNonRoot, i)
#define O(ty, b, o) (*(ty*)((b) + (o)))
#define X(ty, b, i, s, o) (*(ty*)((b) + ((i) * (s)) + (o)))
#define S(ty, i) *(ty*)(StackTop + (i))

/* ------------------------------------------------- */
/*                       Tests                       */
/* ------------------------------------------------- */

#define IsInt(p) (0x3 & (int)(p))

#define BZ(x, l)                                                        \
        do {                                                            \
                if (DEBUG_CCODEGEN)                                     \
                        fprintf (stderr, "%s:%d: BZ(%d, %s)\n", \
                                        __FILE__, __LINE__, (x), #l);   \
                if (0 == (x)) goto l;                                   \
        } while (0)

#define BNZ(x, l)                                                       \
        do {                                                            \
                if (DEBUG_CCODEGEN)                                     \
                        fprintf (stderr, "%s:%d: BNZ(%d, %s)\n",        \
                                        __FILE__, __LINE__, (x), #l);   \
                if (x) goto l;                                          \
        } while (0)

#define FlushFrontier()                         \
        do {                                    \
                FrontierMem = Frontier;         \
        } while (0)

#define FlushStackTop()                         \
        do {                                    \
                StackTopMem = StackTop;         \
        } while (0)

#define CacheFrontier()                         \
        do {                                    \
                Frontier = FrontierMem;         \
        } while (0)

#define CacheStackTop()                         \
        do {                                    \
                StackTop = StackTopMem;         \
        } while (0)

/* ------------------------------------------------- */
/*                       Chunk                       */
/* ------------------------------------------------- */

#if (defined (__sun__) && defined (REGISTER_FRONTIER_STACKTOP))
#define Chunk(n)                                                \
        DeclareChunk(n) {                                       \
                register unsigned int frontier asm("g5");       \
                register unsigned int stackTop asm("g6");
#else
#define Chunk(n)                                \
        DeclareChunk(n) {                       \
                Pointer frontier;               \
                Pointer stackTop;
#endif

#define ChunkSwitch(n)                                                  \
                if (DEBUG_CCODEGEN)                                     \
                        fprintf (stderr, "%s:%d: entering chunk %d  nextBlock = %d\n", \
                                        __FILE__, __LINE__, n, (int)nextBlock); \
                CacheFrontier();                                        \
                CacheStackTop();                                        \
                doSwitchNextBlock:                                      \
                switch (nextBlock) {

#define EndChunkSwitch                                                  \
                default:                                                \
                        goto doLeaveChunk;                              \
                } /* end switch (nextBlock) */

#define EndChunk                                                        \
                /* interchunk return */                                 \
                doLeaveChunk:                                           \
                        FlushFrontier();                                \
                        FlushStackTop();                                \
                        return nextBlock;                               \
        } /* end chunk */

/* ------------------------------------------------- */
/*                Calling SML from C                 */
/* ------------------------------------------------- */

#define Thread_returnToC()                                              \
        do {                                                            \
                if (DEBUG_CCODEGEN)                                     \
                        fprintf (stderr, "%s:%d: Thread_returnToC()\n", \
                                        __FILE__, __LINE__);            \
                return (uintptr_t)-1;                                   \
        } while (0)

/* ------------------------------------------------- */
/*                      FarGoto                      */
/* ------------------------------------------------- */

#define FarGoto(l)                              \
        do {                                    \
                nextBlock = l;                  \
                goto doLeaveChunk;              \
        } while (0)

/* ------------------------------------------------- */
/*                       Stack                       */
/* ------------------------------------------------- */

#define Push(bytes)                                                     \
        do {                                                            \
                if (DEBUG_CCODEGEN)                                     \
                        fprintf (stderr, "%s:%d: Push (%d)\n",          \
                                        __FILE__, __LINE__, bytes);     \
                StackTop += (bytes);                                    \
        } while (0)

#define Return()                                                                \
        do {                                                                    \
                nextBlock = *(uintptr_t*)(StackTop - sizeof(uintptr_t));        \
                if (DEBUG_CCODEGEN)                                             \
                        fprintf (stderr, "%s:%d: Return()  nextBlock = %d\n",   \
                                        __FILE__, __LINE__, (int)nextBlock);    \
                goto doSwitchNextBlock;                                         \
        } while (0)

#define Raise()                                                                 \
        do {                                                                    \
                if (DEBUG_CCODEGEN)                                             \
                        fprintf (stderr, "%s:%d: Raise\n",                      \
                                        __FILE__, __LINE__);                    \
                StackTop = StackBottom + ExnStack;                              \
                Return();                                                       \
        } while (0)                                                             \

/* ------------------------------------------------- */
/*                       Primitives                  */
/* ------------------------------------------------- */

#ifndef MLTON_CODEGEN_STATIC_INLINE
#define MLTON_CODEGEN_STATIC_INLINE static inline
#endif
#include "basis-ffi.h"
#include "basis/coerce.h"
#include "basis/cpointer.h"
#include "basis/Real/Real-ops.h"
#include "basis/Word/Word-ops.h"

#endif /* #ifndef _C_CHUNK_H_ */
