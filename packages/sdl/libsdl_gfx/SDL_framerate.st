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

Object subclass: #SdlFrameRate
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'SdlFrameRate Wrapper'! !

CStruct subclass: #FpsManager
    declaration: #(
        (#frameCount #uInt)
        (#rateTicks #float)
        (#lastTicks #uInt)
        (#rate #uInt))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'FpsManager Wrapper'! !

!SdlFrameRate class methodsFor: 'Constants'!

fpsUpperLimit
    ^200!

fpsLowerLimit
    ^1!

fpsDefault
    ^30!

!SdlFrameRate class methodsFor: 'C call-outs'!

sdlInitFrameRate: aCobject0 
    "DLLINTERFACE void SDL_initFramerate(FPSmanager * manager);"
    <cCall: 'SDL_initFramerate' returning: #void 
        args: #( #cObject  )>!

sdlSetFrameRate: aCobject0 rate: aInt1 
    "DLLINTERFACE int SDL_setFramerate(FPSmanager * manager, int rate);"
    <cCall: 'SDL_setFramerate' returning: #int 
        args: #( #cObject #int  )>!

sdlGetFrameRate: aCobject0 
    "DLLINTERFACE int SDL_getFramerate(FPSmanager * manager);"
    <cCall: 'SDL_getFramerate' returning: #int 
        args: #( #cObject  )>!

sdlFrameRateDelay: aCobject0 
    "DLLINTERFACE void SDL_framerateDelay(FPSmanager * manager);"
    <cCall: 'SDL_framerateDelay' returning: #void 
        args: #( #cObject  )>! !
