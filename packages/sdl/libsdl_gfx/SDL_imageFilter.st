"======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
|
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
|
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlImageFilter
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SdlImageFilter Wrapper'! !

!SdlImageFilter class methodsFor: 'C call-outs'!

sdlImageFilterMMXDetect
    "I answer the MMX capabillity of the CPU. My C function call
    prototype:

    DLLINTERFACE int SDL_imageFilterMMXdetect(void);"
    <cCall: 'SDL_imageFilterMMXdetect' returning: #int 
        args: #( )>!

sdlImageFilterMMXOff
    "I turn off MMX assisted filtering. My C function call prototype:

    DLLINTERFACE void SDL_imageFilterMMXoff(void);"
    <cCall: 'SDL_imageFilterMMXoff' returning: #void 
        args: #( )>!

sdlImageFilterMMXOn
    "I turn on MMX assisted filtering. My C function call prototype:

    DLLINTERFACE void SDL_imageFilterMMXon(void);"
    <cCall: 'SDL_imageFilterMMXon' returning: #void 
        args: #( )>!

sdlImageFilterAdd: aString0 src2: aString1 dest: aString2 length: aInt3 
    "I add an image filter. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterAdd(unsigned char *Src1, unsigned char *Src2, 
         unsigned char *Dest, int length);"
    <cCall: 'SDL_imageFilterAdd' returning: #int 
        args: #( #string #string #string #int  )>!

sdlImageFilterMean: aString0 src2: aString1 dest: aString2 length: aInt3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterMean(unsigned char *Src1, unsigned char *Src2, 
         unsigned char *Dest, int length);"
    <cCall: 'SDL_imageFilterMean' returning: #int 
        args: #( #string #string #string #int  )>!

sdlImageFilterSub: aString0 src2: aString1 dest: aString2 length: aInt3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterSub(unsigned char *Src1, unsigned char *Src2, 
         unsigned char *Dest, int length);"
    <cCall: 'SDL_imageFilterSub' returning: #int 
        args: #( #string #string #string #int  )>!

sdlImageFilterABSDiff: aString0 src2: aString1 dest: aString2 length: aInt3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterAbsDiff(unsigned char *Src1, unsigned char *Src2, 
         unsigned char *Dest, int length);"
    <cCall: 'SDL_imageFilterAbsDiff' returning: #int 
        args: #( #string #string #string #int  )>!

sdlImageFilterMult: aString0 src2: aString1 dest: aString2 length: aInt3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterMult(unsigned char *Src1, unsigned char *Src2, 
         unsigned char *Dest, int length);"
    <cCall: 'SDL_imageFilterMult' returning: #int 
        args: #( #string #string #string #int  )>!

sdlImageFilterMultNor: aString0 src2: aString1 dest: aString2 length: aInt3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterMultNor(unsigned char *Src1, unsigned char *Src2, 
         unsigned char *Dest, int length);"
    <cCall: 'SDL_imageFilterMultNor' returning: #int 
        args: #( #string #string #string #int  )>!

sdlImageFilterMultDivBy2: aString0 src2: aString1 dest: aString2 length: aInt3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterMultDivby2(unsigned char *Src1, unsigned char *Src2, 
         unsigned char *Dest, int length);"
    <cCall: 'SDL_imageFilterMultDivby2' returning: #int 
        args: #( #string #string #string #int  )>!

sdlImageFilterMultDivBy4: aString0 src2: aString1 dest: aString2 length: aInt3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterMultDivby4(unsigned char *Src1, unsigned char *Src2, 
         unsigned char *Dest, int length);"
    <cCall: 'SDL_imageFilterMultDivby4' returning: #int 
        args: #( #string #string #string #int  )>!

sdlImageFilterBitAnd: aString0 src2: aString1 dest: aString2 length: aInt3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterBitAnd(unsigned char *Src1, unsigned char *Src2, 
         unsigned char *Dest, int length);"
    <cCall: 'SDL_imageFilterBitAnd' returning: #int 
        args: #( #string #string #string #int  )>!

sdlImageFilterBitOr: aString0 src2: aString1 dest: aString2 length: aInt3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterBitOr(unsigned char *Src1, unsigned char *Src2, 
         unsigned char *Dest, int length);"
    <cCall: 'SDL_imageFilterBitOr' returning: #int 
        args: #( #string #string #string #int  )>!

sdlImageFilterDiv: aString0 src2: aString1 dest: aString2 length: aInt3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterDiv(unsigned char *Src1, unsigned char *Src2, 
         unsigned char *Dest, int length);"
    <cCall: 'SDL_imageFilterDiv' returning: #int 
        args: #( #string #string #string #int  )>!

sdlImageFilterBitNegation: aString0 dest: aString1 length: aInt2 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterBitNegation(unsigned char *Src1, 
         unsigned char *Dest, int length);"
    <cCall: 'SDL_imageFilterBitNegation' returning: #int 
        args: #( #string #string #int  )>!

sdlImageFilterAddByte: aString0 dest: aString1 length: aInt2 c: aChar3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterAddByte(unsigned char *Src1, 
         unsigned char *Dest, int length, unsigned char C);"
    <cCall: 'SDL_imageFilterAddByte' returning: #int 
        args: #( #string #string #int #char  )>!

sdlImageFilterAddUint: aString0 dest: aString1 length: aInt2 c: aUint3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterAddUint(unsigned char *Src1, 
         unsigned char *Dest, int length, unsigned int C);"
    <cCall: 'SDL_imageFilterAddUint' returning: #int 
        args: #( #string #string #int #uInt  )>!

sdlImageFilterAddByteToHalf: aString0 dest: aString1 length: aInt2 c: aChar3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterAddByteToHalf(unsigned char *Src1, 
         unsigned char *Dest, int length, unsigned char C);"
    <cCall: 'SDL_imageFilterAddByteToHalf' returning: #int 
        args: #( #string #string #int #char  )>!

sdlImageFilterSubByte: aString0 dest: aString1 length: aInt2 c: aChar3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterSubByte(unsigned char *Src1, unsigned char *Dest, 
         int length, unsigned char C);"
    <cCall: 'SDL_imageFilterSubByte' returning: #int 
        args: #( #string #string #int #char  )>!

sdlImageFilterSubUint: aString0 dest: aString1 length: aInt2 c: aUint3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterSubUint(unsigned char *Src1, unsigned char *Dest, 
         int length, unsigned int C);"
    <cCall: 'SDL_imageFilterSubUint' returning: #int 
        args: #( #string #string #int #uInt  )>!

sdlImageFilterShiftRight: aString0 dest: aString1 length: aInt2 n: aChar3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterShiftRight(unsigned char *Src1, unsigned char *Dest, 
         int length, unsigned char N);"
    <cCall: 'SDL_imageFilterShiftRight' returning: #int 
        args: #( #string #string #int #char  )>!

sdlImageFilterShiftRightUint: aString0 dest: aString1 length: aInt2 n: aChar3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterShiftRightUint(unsigned char *Src1, unsigned char *Dest, 
         int length, unsigned char N);"
    <cCall: 'SDL_imageFilterShiftRightUint' returning: #int 
        args: #( #string #string #int #char  )>!

sdlImageFilterMultByByte: aString0 dest: aString1 length: aInt2 c: aChar3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterMultByByte(unsigned char *Src1, 
         unsigned char *Dest, int length, unsigned char C);"
    <cCall: 'SDL_imageFilterMultByByte' returning: #int 
        args: #( #string #string #int #char  )>!

sdlImageFilterShiftRightAndMultByByte: aString0 dest: aString1 length: aInt2 
    n: aChar3 c: aChar4 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterShiftRightAndMultByByte(unsigned char *Src1, 
         unsigned char *Dest, int length, unsigned char N, unsigned char C);"
    <cCall: 'SDL_imageFilterShiftRightAndMultByByte' returning: #int 
        args: #( #string #string #int #char #char  )>!

sdlImageFilterShiftLeftByte: aString0 dest: aString1 length: aInt2 n: aChar3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterShiftLeftByte(unsigned char *Src1, 
         unsigned char *Dest, int length, unsigned char N);"
    <cCall: 'SDL_imageFilterShiftLeftByte' returning: #int 
        args: #( #string #string #int #char  )>!

sdlImageFilterShiftLeftUint: aString0 dest: aString1 length: aInt2 n: aChar3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterShiftLeftUint(unsigned char *Src1, 
         unsigned char *Dest, int length, unsigned char N);"
    <cCall: 'SDL_imageFilterShiftLeftUint' returning: #int 
        args: #( #string #string #int #char  )>!

sdlImageFilterShiftLeft: aString0 dest: aString1 length: aInt2 n: aChar3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterShiftLeft(unsigned char *Src1, 
         unsigned char *Dest, int length, unsigned char N);"
    <cCall: 'SDL_imageFilterShiftLeft' returning: #int 
        args: #( #string #string #int #char  )>!

sdlImageFilterBinarizeUsingThreshold: aString0 dest: aString1 length: aInt2 t: aChar3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterBinarizeUsingThreshold(unsigned char *Src1, 
         unsigned char *Dest, int length, unsigned char T);"
    <cCall: 'SDL_imageFilterBinarizeUsingThreshold' returning: #int 
        args: #( #string #string #int #char  )>!

sdlImageFilterClipToRange: aString0 dest: aString1 length: aInt2 tMin: aChar3 tMax: aChar4 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterClipToRange(unsigned char *Src1, unsigned char *Dest, 
         int length, unsigned char Tmin, unsigned char Tmax);"
    <cCall: 'SDL_imageFilterClipToRange' returning: #int 
        args: #( #string #string #int #char #char  )>!

sdlImageFilterNormalizeLinear: aString0 dest: aString1 length: aInt2 cMin: aInt3 
        cMax: aInt4 nMin: aInt5 nMax: aInt6 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterNormalizeLinear(unsigned char *Src1, 
         unsigned char *Dest, int length, int Cmin, int Cmax, int Nmin, int Nmax);"
    <cCall: 'SDL_imageFilterNormalizeLinear' returning: #int 
        args: #( #string #string #int #int #int #int #int  )>!

sdlImageFilterConvolveKernel3x3Divide: aString0 dest: aString1 rows: aInt2 
    columns: aInt3 kernel: aCobject4 divisor: aChar5 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterConvolveKernel3x3Divide(unsigned char *Src, 
         unsigned char *Dest, int rows, int columns, signed short *Kernel, unsigned char Divisor);"
    <cCall: 'SDL_imageFilterConvolveKernel3x3Divide' returning: #int 
        args: #( #string #string #int #int #cObject #char  )>!

sdlImageFilterConvolveKernel5x5Divide: aString0 dest: aString1 rows: aInt2 
    columns: aInt3 kernel: aCobject4 divisor: aChar5 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterConvolveKernel5x5Divide(unsigned char *Src, 
         unsigned char *Dest, int rows, int columns, signed short *Kernel, 
         unsigned char Divisor);"
    <cCall: 'SDL_imageFilterConvolveKernel5x5Divide' returning: #int 
        args: #( #string #string #int #int #cObject #char  )>!

sdlImageFilterConvolveKernel7x7Divide: aString0 dest: aString1 rows: aInt2 
    columns: aInt3 kernel: aCobject4 divisor: aChar5 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterConvolveKernel7x7Divide(unsigned char *Src, 
         unsigned char *Dest, int rows, int columns, signed short *Kernel, 
         unsigned char Divisor);"
    <cCall: 'SDL_imageFilterConvolveKernel7x7Divide' returning: #int 
        args: #( #string #string #int #int #cObject #char  )>!

sdlImageFilterConvolveKernel9x9Divide: aString0 dest: aString1 rows: aInt2 
    columns: aInt3 kernel: aCobject4 divisor: aChar5 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterConvolveKernel9x9Divide(unsigned char *Src, 
         unsigned char *Dest, int rows, int columns, signed short *Kernel, 
         unsigned char Divisor);"
    <cCall: 'SDL_imageFilterConvolveKernel9x9Divide' returning: #int 
        args: #( #string #string #int #int #cObject #char  )>!

sdlImageFilterConvolveKernel3x3ShiftRight: aString0 dest: aString1 rows: aInt2 
    columns: aInt3 kernel: aCobject4 nRightShift: aChar5 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterConvolveKernel3x3ShiftRight(unsigned char *Src, 
         unsigned char *Dest, int rows, int columns, signed short *Kernel, 
         unsigned char NRightShift);"
    <cCall: 'SDL_imageFilterConvolveKernel3x3ShiftRight' returning: #int 
        args: #( #string #string #int #int #cObject #char  )>!

sdlImageFilterConvolveKernel5x5ShiftRight: aString0 dest: aString1 rows: aInt2 
    columns: aInt3 kernel: aCobject4 nRightShift: aChar5 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterConvolveKernel5x5ShiftRight(unsigned char *Src, 
         unsigned char *Dest, int rows, int columns, signed short *Kernel, 
         unsigned char NRightShift);"
    <cCall: 'SDL_imageFilterConvolveKernel5x5ShiftRight' returning: #int 
        args: #( #string #string #int #int #cObject #char  )>!

sdlImageFilterConvolveKernel7x7ShiftRight: aString0 dest: aString1 rows: aInt2 
    columns: aInt3 kernel: aCobject4 nRightShift: aChar5 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterConvolveKernel7x7ShiftRight(unsigned char *Src, 
         unsigned char *Dest, int rows, int columns, signed short *Kernel, 
         unsigned char NRightShift);"
    <cCall: 'SDL_imageFilterConvolveKernel7x7ShiftRight' returning: #int 
        args: #( #string #string #int #int #cObject #char  )>!

sdlImageFilterConvolveKernel9x9ShiftRight: aString0 dest: aString1 rows: aInt2 
    columns: aInt3 kernel: aCobject4 nRightShift: aChar5 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterConvolveKernel9x9ShiftRight(unsigned char *Src, 
         unsigned char *Dest, int rows, int columns, signed short *Kernel, 
         unsigned char NRightShift);"
    <cCall: 'SDL_imageFilterConvolveKernel9x9ShiftRight' returning: #int 
        args: #( #string #string #int #int #cObject #char  )>!

sdlImageFilterSobelX: aString0 dest: aString1 rows: aInt2 columns: aInt3 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterSobelX(unsigned char *Src, unsigned char *Dest, 
         int rows, int columns);"
    <cCall: 'SDL_imageFilterSobelX' returning: #int 
        args: #( #string #string #int #int  )>!

sdlImageFilterSobelXShiftRight: aString0 dest: aString1 rows: aInt2 
    columns: aInt3 nRightShift: aChar4 
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE int SDL_imageFilterSobelXShiftRight(unsigned char *Src, 
         unsigned char *Dest, int rows, int columns, unsigned char NRightShift);"
    <cCall: 'SDL_imageFilterSobelXShiftRight' returning: #int 
        args: #( #string #string #int #int #char  )>!

sdlImageFilterAlignStack
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE void SDL_imageFilterAlignStack(void);"
    <cCall: 'SDL_imageFilterAlignStack' returning: #void 
        args: #( )>!

sdlImageFilterRestoreStack
    "I perform image filtering. My C function call prototype:

    DLLINTERFACE void SDL_imageFilterRestoreStack(void);"
    <cCall: 'SDL_imageFilterRestoreStack' returning: #void 
        args: #( )>! !
