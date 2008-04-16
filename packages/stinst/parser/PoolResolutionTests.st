"======================================================================
|
|   PoolResolution tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright (C) 2008 Free Software Foundation, Inc.
| Written by Stephen Compall.
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

Tests addSubspace: #MyLibrary; addSubspace: #MyProject.
MyProject addSubspace: #MyLibWrapper.

Namespace current: STInST.Tests.MyLibrary [

Eval [
    MyLibrary at: #StandardOverrides put:
        (Dictionary from: {#Scape -> 42});
	at: #ValueAdaptor put: 9994
]

Object subclass: Foo [
    Exception := 42.
    Scape := 21.

    exception [^Exception]
    scape [^Scape]
]

Foo subclass: Bar [
    <import: StandardOverrides>
    scape [^Scape]
    valueAdaptor [^ValueAdaptor]
]

] "end namespace MyLibrary"

Namespace current: STInST.Tests.MyProject.MyLibWrapper [

Eval [
    "note this changes my superspace"
    MyProject at: #Exception put: #Exception
]

MyLibrary.Foo subclass: Baz [
    exception [^Exception]
    valueAdaptor [^ValueAdaptor]
]

] "end namespace MyProject.MyLibWrapper"



Namespace current: STInST.Tests [

TestCase subclass: TestDefaultPoolResolution [
    | foo bar baz |

    assertVariable: symbol of: pools is: value description: str [
	| binding |
	binding := pools lookupBindingOf: symbol.
	self assert: binding notNil.
	self assert: value = binding value description: str.
    ]

    setUp [
	foo := DefaultPoolResolution of: MyLibrary.Foo.
	bar := DefaultPoolResolution of: MyLibrary.Bar.
	baz := DefaultPoolResolution of: MyProject.MyLibWrapper.Baz.
    ]

    testClassPoolFirst [
	self assertVariable: #Exception of: foo is: 42
	     description: 'prefer class pool to namespace'
    ]

    testSharedPoolBeforeSuperClassPool [
	self assertVariable: #Scape of: bar is: 42
	     description: 'prefer here-shared pool to super-class pool'
    ]

    testShortNamespaceWalk [
	self assertVariable: #Exception of: baz is: #Exception
	     description: 'namespace walked briefly before moving to superclass'.
	self assertVariable: #ValueAdaptor of: baz is: 9994
	     description: 'namespace walk stops at super-common space'
    ]
]

TestCase subclass: TestClassicPoolResolution [
    | foo bar baz |

    assertVariable: symbol of: pools is: value description: str [
	| binding |
	binding := pools lookupBindingOf: symbol.
	self assert: binding notNil.
	self assert: value = binding value description: str.
    ]

    setUp [
	foo := ClassicPoolResolution of: MyLibrary.Foo.
	bar := ClassicPoolResolution of: MyLibrary.Bar.
	baz := ClassicPoolResolution of: MyProject.MyLibWrapper.Baz.
    ]

    testNamespaceFirst [
	self assertVariable: #Exception of: foo is: Exception
	     description: 'prefer namespace to class pool'
    ]

    testClassPoolFirst [
	self assertVariable: #Scape of: bar is: 21
	     description: 'prefer class pool to shared pool'
    ]

    testLongNamespaceWalk [
	self assertVariable: #Exception of: baz is: #Exception
	     description: 'namespace walked before moving to superclass'.
	self assertVariable: #ValueAdaptor of: baz is: ValueAdaptor
	     description: 'and again'.
	self assertVariable: #ValueAdaptor of: bar is: 9994
	     description: 'top class''s namespace goes first'
    ]
]

]
