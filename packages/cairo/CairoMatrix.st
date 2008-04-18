"======================================================================
|
|   CairoMatrix function declarations
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


CStruct subclass: #CairoMatrix
    declaration: #(
      (#xx #double)
      (#yx #double)
      (#xy #double)
      (#yy #double)
      (#x0 #double)
      (#y0 #double))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Cairo structs'! !

CairoMatrix extend [
    CairoMatrix class >> new [
	^ super new addToBeFinalized
    ]

    finalize [
	self free.
    ]

    initIdentity [
        Cairo matrixInitIdentity: self.
    ]

    withPoint: point do: block [
        | ox oy |
	ox := CDouble value: point x.
	oy := CDouble value: point y.
	[
	    ^ block value:self value:ox value: oy
	] ensure: [
	    ox ifNotNil: [ :x | x free ].
	    oy ifNotNil: [ :y | y free ]].
    ]

    copy [
        | shiny |
        shiny := CairoMatrix new.
        Cairo matrixInit: shiny 
	      xx: self xx value
	      yx: self yx value
	      xy: self xy value
	      yy: self yy value
	      x0: self x0 value
	      y0: self y0 value.
        ^ shiny
    ]
]

