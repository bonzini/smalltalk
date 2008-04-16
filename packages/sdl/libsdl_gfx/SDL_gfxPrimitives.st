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

Object subclass: #SdlGfxPrimitives
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SdlGfxPrimitives Wrapper'! !

!SdlGfxprimitives class methodsFor: 'Constants'!

mPi
    ^3.141592654!

sdlGfxPrimitivesMajor
    ^2!

sdlGfxPrimitivesMinor
    ^0!

sdlGfxPrimitivesMicro
    ^13!

!SdlGfxPrimitives class methodsFor: 'C call-outs'!

pixelColor: aCobject0 x: aInt1 y: aInt2 color: aUint3 
    "I draw a pixel. My C function call prototype:

    DLLINTERFACE int pixelColor(SDL_Surface * dst, Sint16 x, Sint16 y, Uint32 color);"
    <cCall: 'pixelColor' returning: #int 
        args: #( #cObject #int #int #uInt  )>!

pixelRGBA: aCobject0 x: aInt1 y: aInt2 r: aUchar3 g: aUchar4 b: aUchar5 a: aUchar6
    "I draw a pixel. My C function call prototype:

    DLLINTERFACE int pixelRGBA(SDL_Surface * dst, Sint16 x, Sint16 y, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'pixelRGBA' returning: #int 
        args: #( #cObject #int #int #char #char #char #char  )>!

hLineColor: aCobject0 x1: aInt1 x2: aInt2 y: aInt3 color: aUint 
    "I draw a horizontal line. My C function call prototype:

    DLLINTERFACE int hlineColor(SDL_Surface * dst, Sint16 x1, Sint16 x2, Sint16 y, Uint32 color);"
    <cCall: 'hlineColor' returning: #int 
        args: #( #cObject #int #int #int #uInt  )>!

hLineRGBA: aCobject0 x1: aInt1 x2: aInt3 y: aInt4 r: aUchar4 g: aUchar5 b: aUchar6 a: aUchar7 
    "I draw a horizontal line. My C function call prototype:

    DLLINTERFACE int hlineRGBA(SDL_Surface * dst, Sint16 x1, Sint16 x2, Sint16 y, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'hlineRGBA' returning: #int 
        args: #( #cObject #int #int #int #char #char #char #char  )>!

vLineColor: aCobject0 x: aInt1 y1: aInt2 y2: aInt3 color: aUint4 
    "I draw a veritcal line. My C function call prototype:

    DLLINTERFACE int vlineColor(SDL_Surface * dst, Sint16 x, Sint16 y1, Sint16 y2, Uint32 color);"
    <cCall: 'vlineColor' returning: #int 
        args: #( #cObject #int #int #int #uInt  )>!

vLineRGBA: aCobject0 x: aInt1 y1: aInt2 y2: aInt3 r: aUchar4 g: aUchar5 b: aUchar6 a: aUchar7 
    "I draw a vertical line. My C function call prototype:

    DLLINTERFACE int vlineRGBA(SDL_Surface * dst, Sint16 x, Sint16 y1, Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'vlineRGBA' returning: #int 
        args: #( #cObject #int #int #int #char #char #char #char  )>!

rectangleColor: aCobject0 x1: aInt1 y1: aInt2 x2: aInt3 y2: aInt4 color: aUint5 
    "I draw a rectangle. My C function call prototype:

    DLLINTERFACE int rectangleColor(SDL_Surface * dst, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint32 color);"
    <cCall: 'rectangleColor' returning: #int 
        args: #( #cObject #int #int #int #int #uInt  )>!

rectangleRGBA: aCobject0 x1: aIntt1 y1: aInt2 x2: aIntt3 y2: aIntt4 r: aUchar5 g: aUchar6 b: aUchar7 a: aUchar8 
    "I draw a rectangle. My C function call prototype:

    DLLINTERFACE int rectangleRGBA(SDL_Surface * dst, Sint16 x1, Sint16 y1,
         Sint16 x2, Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'rectangleRGBA' returning: #int 
        args: #( #cObject #int #int #int #int #char #char #char #char  )>!

boxColor: aCobject0 x1: aInt1 y1: aInt2 x2: aInt3 y2: aInt4 color: aUint5 
    "I draw a filled rectangle. My C function call prototype:

    DLLINTERFACE int boxColor(SDL_Surface * dst, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint32 color);"
    <cCall: 'boxColor' returning: #int 
        args: #( #cObject #int #int #int #int #uInt  )>!

boxRGBA: aCobject0 x1: aInt1 y1: aInt2 x2: aInt3 y2: aInt4 r: aUchar5 g: aUchar6 b: aUchar7 a: aUchar8 
    "I draw a filled rectangle. My C function call prototype:

    DLLINTERFACE int boxRGBA(SDL_Surface * dst, Sint16 x1, Sint16 y1, Sint16 x2,
         Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'boxRGBA' returning: #int 
        args: #( #cObject #int #int #int #int #char #char #char #char  )>!

lineColor: aCobject0 x1: aInt1 y1: aInt2 x2: aInt3 y2: aInt4 color: aUint5 
    "I draw a line. My C function call prototype:

    DLLINTERFACE int lineColor(SDL_Surface * dst, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint32 color);"
    <cCall: 'lineColor' returning: #int 
        args: #( #cObject #int #int #int #int #uInt  )>!

lineRGBA: aCobject0 x1: aInt1 y1: aInt2 x2: aInt3 y2: aInt4 r: aUchar5 g: aUchar6 b: aUchar7 a: aUchar8 
    "I draw a line. My C function call prototype:

    DLLINTERFACE int lineRGBA(SDL_Surface * dst, Sint16 x1, Sint16 y1,
         Sint16 x2, Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'lineRGBA' returning: #int 
        args: #( #cObject #int #int #int #int #char #char #char #char  )>!

aaLineColor: aCobject0 x1: aInt1 y1: aInt2 x2: aInt3 y2: aInt4 color: aUint5 
    "I draw a line. My C function call prototype:

    DLLINTERFACE int aalineColor(SDL_Surface * dst, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint32 color);"
    <cCall: 'aalineColor' returning: #int 
        args: #( #cObject #int #int #int #int #uInt  )>!

aaLineRGBA: aCobject0 x1: aInt1 y1: aInt2 x2: aInt3 y2: aInt4 r: aUchar5 g: aUchar6 b: aUchar7 a: aUchar8 
    "I draw a line. My C function call prototype:

    DLLINTERFACE int aalineRGBA(SDL_Surface * dst, Sint16 x1, Sint16 y1,
         Sint16 x2, Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'aalineRGBA' returning: #int 
        args: #( #cObject #int #int #int #int #char #char #char #char  )>!

circleColor: aCobject0 x: aInt1 y: aInt2 r: aInt3 color: aUint4 
    "I draw a circle. My C function call prototype.

    DLLINTERFACE int circleColor(SDL_Surface * dst, Sint16 x, Sint16 y, Sint16 r, Uint32 color);"
    <cCall: 'circleColor' returning: #int 
        args: #( #cObject #int #int #int #uInt  )>!

circleRGBA: aCobject0 x: aInt1 y: aInt2 rad: aInt3 r: aUchar4 g: aUchar5 b: aUchar6 a: aUchar7 
    "I draw a circle. My C function call prototype.

    DLLINTERFACE int circleRGBA(SDL_Surface * dst, Sint16 x, Sint16 y, Sint16 rad, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'circleRGBA' returning: #int 
        args: #( #cObject #int #int #int #char #char #char #char  )>!

aaCircleColor: aCobject0 x: aInt1 y: aInt2 r: aInt3 color: aUint4 
    "I draw a circle. My C function call prototype.

    DLLINTERFACE int aacircleColor(SDL_Surface * dst, Sint16 x, Sint16 y, Sint16 r, Uint32 color);"
    <cCall: 'aacircleColor' returning: #int 
        args: #( #cObject #int #int #int #uInt  )>!

aaCircleRGBA: aCobject0 x: aInt1 y: aInt2 rad: aInt3 r: aUchar4 g: aUchar5 b: aUchar6 a: aUchar7 
    "I draw a circle. My C function call prototype.

    DLLINTERFACE int aacircleRGBA(SDL_Surface * dst, Sint16 x, Sint16 y,
         Sint16 rad, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'aacircleRGBA' returning: #int 
        args: #( #cObject #int #int #int #char #char #char #char  )>!

filledCircleColor: aCobject0 x: aInt1 y: aInt2 r: aInt3 color: aUint 
    "I draw a filled circle. My C function call prototype.

    DLLINTERFACE int filledCircleColor(SDL_Surface * dst, Sint16 x, Sint16 y, Sint16 r, Uint32 color);"
    <cCall: 'filledCircleColor' returning: #int 
        args: #( #cObject #int #int #int #uInt  )>!

filledCircleRGBA: aCobject0 x: aInt1 y: aInt2 rad: aInt3 r: aUchar4 g: aUchar5 b: aUchar6 a: aUchar7 
    "I draw a filled circle. My C function call prototype.

    DLLINTERFACE int filledCircleRGBA(SDL_Surface * dst, Sint16 x, Sint16 y,
         Sint16 rad, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'filledCircleRGBA' returning: #int 
        args: #( #cObject #int #int #int #char #char #char #char  )>!

ellipseColor: aCobject0 x: aInt1 y: aInt2 rx: aInt3 ry: aInt4 color: aUint5 
    "I draw an ellipse. My C function call prototype:

    DLLINTERFACE int ellipseColor(SDL_Surface * dst, Sint16 x, Sint16 y, Sint16 rx, Sint16 ry, Uint32 color);"
    <cCall: 'ellipseColor' returning: #int 
        args: #( #cObject #int #int #int #int #uInt  )>!

ellipseRGBA: aCobject0 x: aInt1 y: aInt2 rx: aInt3 ry: aInt4 r: aUchar5 g: aUchar6 b: aUchar7 a: aUchar8 
    "I draw an ellipse. My C function call prototype:

    DLLINTERFACE int ellipseRGBA(SDL_Surface * dst, Sint16 x, Sint16 y,
         Sint16 rx, Sint16 ry, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'ellipseRGBA' returning: #int 
        args: #( #cObject #int #int #int #int #char #char #char #char  )>!

aaEllipseColor: aCobject0 xc: aInt1 yc: aInt2 rx: aInt3 ry: aInt4 color: aUint5 
    "I draw an ellipse. My C function call prototype:

    DLLINTERFACE int aaellipseColor(SDL_Surface * dst, Sint16 xc, Sint16 yc, Sint16 rx, Sint16 ry, Uint32 color);"
    <cCall: 'aaellipseColor' returning: #int 
        args: #( #cObject #int #int #int #int #uInt  )>!

aaEllipseRGBA: aCobject0 x: aInt1 y: aInt2 rx: aInt3 ry: aInt4 r: aUchar5 g: aUchar6 b: aUchar7 a: aUchar8 
    "I draw an ellipse. My C function call prototype:

    DLLINTERFACE int aaellipseRGBA(SDL_Surface * dst, Sint16 x, Sint16 y,
         Sint16 rx, Sint16 ry, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'aaellipseRGBA' returning: #int 
        args: #( #cObject #int #int #int #int #char #char #char #char  )>!

filledEllipseColor: aCobject0 x: aInt1 y: aInt2 rx: aInt3 ry: aInt4 color: aUint 
    "I draw a filled ellipse. My C function call prototype:

    DLLINTERFACE int filledEllipseColor(SDL_Surface * dst, Sint16 x, Sint16 y, Sint16 rx, Sint16 ry, Uint32 color);"
    <cCall: 'filledEllipseColor' returning: #int 
        args: #( #cObject #int #int #int #int #uInt  )>!

filledEllipseRGBA: aCobject0 x: aInt1 y: aInt2 rx: aInt3 ry: aInt4 r: aUchar g: aUchar6 b: aUchar7 a: aUchar8 
    "I draw a filled ellipse. My C function call prototype:

    DLLINTERFACE int filledEllipseRGBA(SDL_Surface * dst, Sint16 x, Sint16 y,
         Sint16 rx, Sint16 ry, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'filledEllipseRGBA' returning: #int 
        args: #( #cObject #int #int #int #int #char #char #char #char  )>!

pieColor: aCobject0 x: aInt1 y: aInt2 rad: aInt3 start: aInt4 end: aInt5 color: aUint6 
    "I draw a pie. My C function call prototype:

    DLLINTERFACE int pieColor(SDL_Surface * dst, Sint16 x, Sint16 y, Sint16 rad,
         Sint16 start, Sint16 end, Uint32 color);"
    <cCall: 'pieColor' returning: #int 
        args: #( #cObject #int #int #int #int #int #uInt  )>!

pieRGBA: aCobject0 x: aInt1 y: aInt2 rad: aInt3 start: aInt4 end: aInt5 r: aUchar6 g: aUchar7 b: aUchar8 a: aUchar9 
    "I draw a pie. My C function call prototype:

    DLLINTERFACE int pieRGBA(SDL_Surface * dst, Sint16 x, Sint16 y, Sint16 rad,
         Sint16 start, Sint16 end, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'pieRGBA' returning: #int 
        args: #( #cObject #int #int #int #int #int #char #char #char #char  )>!

filledPieColor: aCobject0 x: aInt1 y: aInt2 rad: aInt3 start: aInt4 end: aInt5 color: aUint6 
    "I draw a filled pie. My C function call prototype:

    DLLINTERFACE int filledPieColor(SDL_Surface * dst, Sint16 x, Sint16 y, Sint16 rad,
         Sint16 start, Sint16 end, Uint32 color);"
    <cCall: 'filledPieColor' returning: #int 
        args: #( #cObject #int #int #int #int #int #uInt  )>!

filledPieRGBA: aCobject0 x: aInt1 y: aInt2 rad: aInt3 start: aInt4 end: aInt5 r: aUchar g: aUchar7 b: aUchar8 a: aUchar9 
    "I draw a filled pie. My C function call prototype:

    DLLINTERFACE int filledPieRGBA(SDL_Surface * dst, Sint16 x, Sint16 y, Sint16 rad,
         Sint16 start, Sint16 end, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'filledPieRGBA' returning: #int 
        args: #( #cObject #int #int #int #int #int #char #char #char #char  )>!

trigonColor: aCobject0 x1: aInt1 y1: aInt2 x2: aInt3 y2: aInt4 x3: aInt5 y3: aInt6 color: aUint7 
    "I draw a trigon. My C function call:

    DLLINTERFACE int trigonColor(SDL_Surface * dst, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3, Uint32 color);"
    <cCall: 'trigonColor' returning: #int 
        args: #( #cObject #int #int #int #int #int #int #uInt  )>!

trigonRGBA: aCobject0 x1: aInt1 y1: aInt2 x2: aInt3 y2: aInt4 x3: aInt5 y3: aInt6 r: aUchar7 g: aUchar8 b: aUchar9 a: aUchar10 
    "I draw a trigon. My C function call:

    DLLINTERFACE int aatrigonRGBA(SDL_Surface * dst,  Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3,
         Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'trigonRGBA' returning: #int 
        args: #( #cObject #int #int #int #int #int #int #char #char #char #char  )>!

aatrigonColor: aCobject0 x1: aInt1 y1: aInt2 x2: aInt3 y2: aInt4 x3: aInt5 y3: aInt6 color: aUint7 
    "I draw a trigon. My C function call:

    DLLINTERFACE int trigonColor(SDL_Surface * dst, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3, Uint32 color);"
    <cCall: 'aatrigonColor' returning: #int 
        args: #( #cObject #int #int #int #int #int #int #uInt  )>!

aatrigonRGBA: aCobject0 x1: aInt1 y1: aInt2 x2: aInt3 y2: aInt4 x3: aInt5 y3: aInt6 r: aUchar7 g: aUchar8 b: aUchar9 a: aUchar10 
    "I draw a trigon. My C function call:

    DLLINTERFACE int trigonRGBA(SDL_Surface * dst, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3,
         Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'aatrigonRGBA' returning: #int 
        args: #( #cObject #int #int #int #int #int #int #char #char #char #char  )>!

filledTrigonColor: aInt0 x1: aInt1 y1: aInt2 x2: aInt3 y2: aInt4 x3: aInt5 y3: aInt6 color: aUint7 
    "I draw a filled trigon. My C function call:

    DLLINTERFACE int filledTrigonColor(SDL_Surface * dst, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3, Uint32 color);"
    <cCall: 'filledTrigonColor' returning: #int 
        args: #( #cObject #int #int #int #int #int #int #uInt  )>!

filledTrigonRGBA: aCobject0 x1: aInt1 y1: aInt2 x2: aInt3 y2: aInt4 x3: aInt5 y3: aInt6 r: aUchar7 g: aUchar8 b: aUchar9 a: aUchar10 
    "I draw a filled trigon. My C function call:

    DLLINTERFACE int filledTrigonRGBA(SDL_Surface * dst, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3,
         Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'filledTrigonRGBA' returning: #int 
        args: #( #cObject #int #int #int #int #int #int #char #char #char #char  )>!

polygonColor: aCobject0 vx: aInt1 vy: aInt2 n: aInt3 color: aUint4 
    "I draw a polygon. My C function call:

    DLLINTERFACE int polygonColor(SDL_Surface * dst, const Sint16 * vx, const Sint16 * vy, int n, Uint32 color);"
    <cCall: 'polygonColor' returning: #int 
        args: #( #cObject #int #int #int #uInt  )>!

polygonRGBA: aCobject0 vx: aInt1 vy: aInt2 n: aInt3 r: aUchar4 g: aUchar5 b: aUchar6 a: aUchar7 
    "I draw a polygon. My C function call:

    DLLINTERFACE int polygonRGBA(SDL_Surface * dst, const Sint16 * vx, const Sint16 * vy,
         int n, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'polygonRGBA' returning: #int 
        args: #( #cObject #int #int #int #char #char #char #char  )>!

aapolygonColor: aCobject0 vx: aInt1 vy: aInt2 n: aInt3 color: aUint4 
    "I draw a polygon. My C function call:

    DLLINTERFACE int aapolygonColor(SDL_Surface * dst, const Sint16 * vx, const Sint16 * vy, int n, Uint32 color);"
    <cCall: 'aapolygonColor' returning: #int 
        args: #( #cObject #int #int #int #uInt  )>!

aapolygonRGBA: aCobject0 vx: aInt1 vy: aInt2 n: aInt3 r: aUchar4 g: aUchar5 b: aUchar6 a: aUchar7 
    "I draw a polygon. My C function call:

    DLLINTERFACE int aapolygonRGBA(SDL_Surface * dst, const Sint16 * vx, const Sint16 * vy,
         int n, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'aapolygonRGBA' returning: #int 
        args: #( #cObject #cObject #cObject #int #cObject #cObject #cObject #cObject  )>!

filledPolygonColor: aCobject0 vx: aInt vy: aInt2 n: aInt3 color: aUint4 
    "I draw a filled polygon. My C function call:

    DLLINTERFACE int filledPolygonColor(SDL_Surface * dst, const Sint16 * vx, const Sint16 * vy, int n, Uint32 color);"
    <cCall: 'filledPolygonColor' returning: #int 
        args: #( #cObject #int #int #int #uInt  )>!

filledPolygonRGBA: aCobject0 vx: aInt1 vy: aInt2 n: aInt3 r: aUchar4 g: aUchar5 b: aUchar6 a: aUchar7 
    "I draw a filled polygon. My C function call:

    DLLINTERFACE int filledPolygonRGBA(SDL_Surface * dst, const Sint16 * vx,
         const Sint16 * vy, int n, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'filledPolygonRGBA' returning: #int 
        args: #( #cObject #cObject #cObject #int #cObject #cObject #cObject #cObject  )>!

bezierColor: aCobject0 vx: aInt1 vy: aInt2 n: aInt3 s: aInt4 color: aUint5
    "I draw a bezier curve. My C function call prototype:

    DLLINTERFACE int bezierColor(SDL_Surface * dst, const Sint16 * vx, const Sint16 * vy, int n, int s, Uint32 color);"
    <cCall: 'bezierColor' returning: #int 
        args: #( #cObject #int #int #int #int #uInt  )>!

bezierRGBA: aCobject0 vx: aInt vy: aInt2 n: aInt3 s: aInt4 r: aUchar5 g: aUchar6 b: aUchar7 a: aUchar8 
    "I draw a bezier curve. My C function call prototype:

    DLLINTERFACE int bezierRGBA(SDL_Surface * dst, const Sint16 * vx, const Sint16 * vy,
         int n, int s, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'bezierRGBA' returning: #int 
        args: #( #cObject #int #int #int #int #char #char #char #char  )>!

characterColor: aCobject0 x: aInt y: aInt2 c: aChar3 color: aUint4 
    "I draw a character. My C function call prototype:

    DLLINTERFACE int characterColor(SDL_Surface * dst, Sint16 x, Sint16 y, char c, Uint32 color);"
    <cCall: 'characterColor' returning: #int 
        args: #( #cObject #int #int #char #uInt  )>!

characterRGBA: aCobject0 x: aInt1 y: aInt2 c: aChar3 r: aUchar4 g: aUchar5 b: aUchar6 a: aUchar7 
    "I draw a character. My C function call prototype:

    DLLINTERFACE int characterRGBA(SDL_Surface * dst, Sint16 x, Sint16 y, char c, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'characterRGBA' returning: #int 
        args: #( #cObject #int #int #char #char #char #char #char  )>!

stringColor: aCobject0 x: aInt1 y: aInt2 c: aString3 color: aUint4
    "I draw a string. My C function call prototype:

    DLLINTERFACE int stringColor(SDL_Surface * dst, Sint16 x, Sint16 y, const char *c, Uint32 color);"
    <cCall: 'stringColor' returning: #int 
        args: #( #cObject #int #int #string #uInt  )>!

stringRGBA: aCobject0 x: aInt1 y: aInt2 c: aString3 r: aUchar4 g: aUchar5 b: aUchar6 a: aUchar7 
    "I draw a string. My C function call prototype:

    DLLINTERFACE int stringRGBA(SDL_Surface * dst, Sint16 x, Sint16 y, const char *c, Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'stringRGBA' returning: #int 
        args: #( #cObject #int #int #string #char #char #char #char  )>!

gfxPrimitivesSetFont: aCobject0 cw: aInt1 ch: aInt2 
    "I set the font to draw characters in. My C function call prototype:

    DLLINTERFACE void gfxPrimitivesSetFont(const void *fontdata, int cw, int ch);"
    <cCall: 'gfxPrimitivesSetFont' returning: #void 
        args: #( #cObject #int #int  )>! !
