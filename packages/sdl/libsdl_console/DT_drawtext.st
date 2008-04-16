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

Object subclass: #DtDrawText
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'DtDrawText Wrapper'! !

CStruct subclass: #BitFont
    declaration: #(
        (#fontSurface (#ptr #CObject))
        (#charWidth #int)
        (#charHeight #int)
        (#fontNumber #int)
        (#nextFont (#ptr #CObject)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'BitFont Wrapper'! !

DLD addLibrary: 'libSDL_console'!

!DtDrawText class methodsFor: 'Constants'!

transFont
    ^1!

!DtDrawText class methodsFor: 'C call-outs'!

dtDrawText: aString0 surface: aCobject1 fontType: aInt2 x: aInt3 y: aInt4 
    "void DT_DrawText(const char *string, SDL_Surface *surface, int FontType, int x, int y );"
    <cCall: 'DT_DrawText' returning: #void 
        args: #( #string #cObject #int #int #int )>!

dtLoadFont: aString0 flags: aInt1 
    "int DT_LoadFont(const char *BitmapName, int flags );"
    <cCall: 'DT_LoadFont' returning: #int 
        args: #( #string #int )>!

dtFontHeight: aInt0 
    "int DT_FontHeight( int FontNumber );"
    <cCall: 'DT_FontHeight' returning: #int 
        args: #( #int )>!

dtFontWidth: aInt0 
    "int DT_FontWidth( int FontNumber );"
    <cCall: 'DT_FontWidth' returning: #int 
        args: #( #int )>!

dtFontPointer: aInt0 
    "BitFont* DT_FontPointer(int FontNumber );"
    <cCall: 'DT_FontPointer' returning: #cObject 
        args: #( #int )>!

dtDestroyDrawText
    "void DT_DestroyDrawText();"
    <cCall: 'DT_DestroyDrawText' returning: #void 
        args: #( )>! !
