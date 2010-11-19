"======================================================================
|
|   UnicodeCharacter Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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



Character subclass: UnicodeCharacter [
    
    <category: 'Language-Data types'>
    <comment: 'My instances represent the over one million characters of the Unicode
character set.  It provides messages to translate between integers and
character objects.

UnicodeCharacter objects are created when accessing UnicodeStrings,
or with Character class>>#codePoint:.'>

    UnicodeCharacter class >> primitiveValue: anInteger [
        "Returns the character object, possibly a Character, corresponding
         to anInteger.  Error if anInteger is not an integer, or not in
         0..16r10FFFF.
         
         This is only a primitive for speed.  UnicodeCharacter's #value:
         method is equivalent to #codePoint: (which is the same for
         Character and UnicodeCharacter)."

        <category: 'built ins'>
        <primitive: VMpr_UnicodeCharacter_create>
        anInteger isInteger
            ifFalse:
                [ SystemExceptions.WrongClass signalOn: anInteger mustBe: SmallInteger ]
            ifTrue:
                [ SystemExceptions.ArgumentOutOfRange
                    signalOn: anInteger
                    mustBeBetween: 0
                    and: 1114111 ]
    ]

    UnicodeCharacter class >> charLookup: aWeakArray at: anInteger value: anUnicodeInteger [
	<category: 'character-lookup'>

	^ (aWeakArray at: anInteger + 1) ifNil: [ aWeakArray at: anInteger + 1 put: (self primitiveValue: anUnicodeInteger) ]
    ]

    UnicodeCharacter class >> lookup: aWeakArray at: anInteger value: anUnicodeInteger [
	<category: 'character-lookup'>

        | index |
        index := (anInteger bitShift: -8) + 1.
	^ self 
		charLookup: ((aWeakArray at: index) ifNil: [ aWeakArray at: index put: (WeakArray new: 256) ])
		at: (anInteger bitAnd: 255)
		value: anUnicodeInteger
    ]

    UnicodeCharacter class >> lookup: anInteger [
	<category: 'character-lookup'>

	| index |
	index := (anInteger bitShift: -16) + 1.
	^ self 
		lookup: (index = 1 
			    ifTrue: [ FixedTable ]
			    ifFalse: [ (Table at: index) ifNil: [ Table at: index put: (WeakArray new: 256) ] ]) 
		at: (anInteger bitAnd: 65535)
		value: anInteger
    ]

    UnicodeCharacter class >> inlinedLookup: anInteger [
        <category: 'character-lookup'>

        | index array |
        index := (anInteger bitShift: -16) + 1.
	array := index = 1
                            ifTrue: [ FixedTable ]
                            ifFalse: [ (Table at: index) ifNil: [ Table at: index put: (WeakArray new: 256) ] ].
	index := ((anInteger bitAnd: 65535) bitShift: -8) + 1.
	array := (array at: index) ifNil: [ array at: index put: (WeakArray new: 256) ].
	index := (anInteger bitAnd: 255) + 1.
	^ (array at: index) ifNil: [ array at: index put: (self primitiveValue: anInteger) ]
    ]

    UnicodeCharacter class >> value: anInteger [
	<category: 'built ins'>

	^ self primitiveValue: anInteger
    ]

    * aNumber [
	"Returns a String with aNumber occurrences of the receiver."

	<category: 'coercion methods'>
	^UnicodeString new: aNumber withAll: self
    ]
]

