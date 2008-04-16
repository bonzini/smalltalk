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

Object subclass: #SdlRotoZoom
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SdlRotoZoom Wrapper'! !

CStruct subclass: #TColorRGBA
    declaration: #(
        (#r #char)
        (#g #char)
        (#b #char)
        (#a #char))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'TColorRGBA Wrapper'! !

CStruct subclass: #TColorY
    declaration: #(
        (#y #char))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'TColorY Wrapper'! !

!SdlRotoZoom class methodsFor: 'Constants'!

mPi
    ^3.141592654!

smoothingOff
    ^0!

smoothingOn
    ^1!

!SdlRotoZoom class methodsFor: 'C call-outs'!

rotoZoomSurface: aCobject0 angle: aDouble1 zoom: aDouble2 smooth: aInt3 
    "I rotates and zoom a 32bit or 8bit 'src' surface to newly created
    'dst' surface. My C function call prototype:

    DLLINTERFACE SDL_Surface *rotozoomSurface(SDL_Surface * src, double angle, 
         double zoom, int smooth);"
    <cCall: 'rotozoomSurface' returning: #cObject 
        args: #( #cObject #double #double #int  )>!

rotoZoomSurfaceXY: aCobject0 angle: aDouble1 zoomX: aDouble2 zoomY: aDouble3 
    smooth: aInt4 
    "I rotates and zoom a 32bit or 8bit 'src' surface to newly created
    'dst' surface. My C function call prototype:

    DLLINTERFACE SDL_Surface *rotozoomSurfaceXY(SDL_Surface * src, double angle, 
         double zoomx, double zoomy, int smooth);"
    <cCall: 'rotozoomSurfaceXY' returning: #cObject 
        args: #( #cObject #double #double #double #int  )>!

rotoZoomSurfaceSize: aInt0 height: aInt1 angle: aDouble2 zoom: aDouble3 
    dstWidth: aCobject4 dstHeight: aCobject5 
    "I answer the size of the target surface for a rotozoomSurface()
    call. My C function call prototype:

    DLLINTERFACE void rotozoomSurfaceSize(int width, int height, double angle, 
         double zoom, int *dstwidth, int *dstheight);"
    <cCall: 'rotozoomSurfaceSize' returning: #void 
        args: #( #int #int #double #double #cObject #cObject  )>!

rotoZoomSurfaceSizeXY: aInt0 height: aInt1 angle: aDouble2 zoomX: aDouble3 
    zoomY: aDouble4 dstWidth: aCobject5 dstHeight: aCobject6 
    "I answer the size of the target surface for a rotozoomSurface()
    call. My C function call prototype:

    DLLINTERFACE void rotozoomSurfaceSizeXY (int width, int height, double angle, 
         double zoomx, double zoomy, int *dstwidth, int *dstheight);"
    <cCall: 'rotozoomSurfaceSizeXY' returning: #void 
        args: #( #int #int #double #double #double #cObject #cObject  )>!

zoomSurface: aCobject0 zoomX: aDouble1 zoomY: aDouble2 smooth: aInt3 
    "I zoom a 32bit or 8bit 'src' surface to newly created 'dst'
    surface. My C function call prototype:

     DLLINTERFACE SDL_Surface *zoomSurface(SDL_Surface * src, double zoomx, 
         double zoomy, int smooth);"
    <cCall: 'zoomSurface' returning: #cObject 
        args: #( #cObject #double #double #int  )>!

zoomSurfaceSize: aInt0 height: aInt1 zoomX: aDouble2 zoomY: aDouble3 
    dstWidth: aCobject4 dstHeight: aCobject5 
    "I answer the size of the target surface for a zoomSurface()
    call. My C function call prototype:

    DLLINTERFACE void zoomSurfaceSize(int width, int height, double zoomx, 
         double zoomy, int *dstwidth, int *dstheight);"
    <cCall: 'zoomSurfaceSize' returning: #void 
        args: #( #int #int #double #double #cObject #cObject  )>! !
