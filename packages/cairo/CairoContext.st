"======================================================================
|
|   CairoContext wrapper class for libcairo
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


Object subclass: CairoSurface [
    | surface |

    cairoSurface [
	"Return the CObject for the Cairo surface."

	<category: 'C interface'>
	surface isNil ifTrue: [ self rebuildSurface ].
	^surface
    ]

    update: aspect [
	<category: 'private-persistence'>
	aspect == #returnFromSnapshot ifTrue: [
	    ^ self rebuildSurface].
    ]

    buildSurface [
	"Abstract method to actually create a Cairo surface.
	 Returns the CObject."

	<category: 'C interface'>
	self subclassResponsibility.
    ]

    extent [
	"Return the size of the surface"

	self subclassResponsibility
    ]

    rebuildSurface [
	<category: 'private-persistence'>
	surface := self buildSurface.
	self addToBeFinalized.
	self changed: #returnFromSnapshot.
    ]

    finalize [
	<category: 'private-finalization'>
	surface ifNil: [ ^self ].
	Cairo surfaceDestroy: surface.
	surface := nil.
    ]

    withContextDo: aBlock [
	"Execute aBlock passing a valid Cairo context for the
	 surface.  The context is invalidated after aBlock returns."

	<category: 'accessing'>
	| context |
	[ aBlock value: (context := CairoContext on: self) ] ensure: [ 
	    context isNil ifFalse: [ context finalize ] ]
    ]
]

CairoSurface subclass: CairoImageSurface [
    | extent |

    CairoImageSurface class >> extent: aPoint [
	"Create a new surface with the given size.  Right now it is
	 only possible to create 32-bit color surfaces.

	 The surface is blanked when the Smalltalk image is restarted."
	<category: 'instance creation'>
	^self new extent: aPoint
    ]

    extent [
	"Return the size of the surface"

	<category: 'accessing'>
	^extent
    ]

    extent: aPoint [ extent := aPoint ]

    buildBlankSurface [
	<category: 'C interface'>
	^Cairo imageSurfaceCreate: Cairo formatArgb32 width: extent x height: extent y
    ]

    buildSurface [
	<category: 'C interface'>
	^self buildBlankSurface
    ]
]

CairoImageSurface subclass: CairoFileSurface [
    | filename |

    CairoFileSurface class >> on: aFile with: aSurface [
	"Create a new surface that will save to aFile and whose
	 size and initial content is the same as aSurface's.
	 The content is reset to the content of aFile when
	 the Smalltalk image is restarted."

	<category: 'instance creation'>
	^(self extent: aSurface extent)
	    buildBlankSurface;
	    paint: aSurface;
	    filename: aFile asString;
	    yourself
    ]

    CairoFileSurface class >> on: aFile extent: aPoint [
	"Create a new surface that will save to aFile, whose
	 size is aPoint and whose initial content is transparent.
	 The content is reset to the content of aFile when
	 the Smalltalk image is restarted."

	<category: 'instance creation'>
	^(self extent: aSurface extent)
	    buildBlankSurface;
	    filename: aFile asString;
	    yourself
    ]

    CairoFileSurface class >> on: aFile [
	"Create a new surface that will save to aFile, whose
	 size is aPoint and whose initial content is obtained
	 by loading aFile.  aFile is reloaded on every Smalltalk
	 image load."

	^self new filename: aFile asString
    ]

    extent [
	"Return the size of the surface.  Requires the file to exist
	 if the size was not supplied at surface creation time."

	extent isNil ifTrue: [
	    self extent: ((Cairo imageSurfaceGetWidth: self cairoSurface) @
			  (Cairo imageSurfaceGetHeight: self cairoSurface)) ].
	^super extent
    ]

    paint: aSurface [
	"Private - Paint the contents of aSurface on this surface."

	<category: 'private'>
	super withContextDo: [ :context |
	    context source: (SurfacePattern on: aSurface); paint ]
    ]

    filename [
	"Answer the file from which the bits of the surface are loaded."

	<category: 'accessing'>
	^filename
    ]

    filename: aString [
	"Answer the file to which the bits of the surface are saved."

	<category: 'accessing'>
	filename := aString.
    ]

    buildSurface [
	"Try to read the surface from the file if it exists.  Otherwise,
	 create a blank surface whose size must have been given with
	 the superclass constructor method, #extent:."

	<category: 'file'>
	^(File name: filename) exists
	    ifTrue: [ self buildSurfaceFromFile ]
	    ifFalse: [ self buildBlankSurface ]
    ]

    buildSurfaceFromFile [
	"Load the contents of the surface to the file specified by
	 #filename."

	<category: 'file'>
	self subclassResponbsibility
    ]

    save [
	"Save the contents of the surface to the file specified by
	 #filename."

	<category: 'file'>
	self subclassResponbsibility
    ]

    withContextDo: aBlock [
	"Execute aBlock passing a valid Cairo context for the
	 surface.  After aBlock returns, the context is invalidated
	 and the content of the surface is saved to the file."

	<category: 'accessing'>
	[ super withContextDo: aBlock ] ensure: [ self save ]
    ]
]

CairoFileSurface subclass: CairoPngSurface [
    buildSurfaceFromFile [
	"Try to read the surface from the file if it exists.  Otherwise,
	 create a blank surface whose size must have been given with
	 the superclass constructor method, #extent:."

	<category: 'file'>
	^Cairo imageSurfaceCreateFromPng: filename
    ]

    save [
	"Save the contents of the surface to the PNG file specified by
	 #filename."

	<category: 'file'>
	Cairo surfaceWriteToPng: self cairoSurface filename: filename
    ]
].

BlockClosure extend [
    maskOn: context [
	<category: 'cairo double dispatch'>
	| pattern |
	[
	    Cairo.Cairo pushGroup: context.
	    self ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo mask: context pattern: pattern
	] ensure: [
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]

    on: context withSourceDo: paintBlock [
	<category: 'cairo double dispatch'>
	| pattern source |
	source := Cairo.Cairo getSource: context.
	Cairo.Cairo patternReference: source.
	[
	    Cairo.Cairo pushGroup: context.
	    self ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo setSource: context source: pattern.
	    paintBlock value
	] ensure: [
	    source isNil ifFalse: [
		Cairo.Cairo
		    setSource: context source: source;
		    patternDestroy: source ].
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]

    setSourceOn: context [
	<category: 'cairo double dispatch'>
	| pattern |
	[
	    Cairo.Cairo pushGroup: context.
	    self ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo setSource: context source: pattern.
	] ensure: [
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]
]

Object subclass: CairoPattern [
    | pattern canonical |

    Patterns := nil.
    CairoPattern class >> initialize [
	<category: 'initialize'>
	Patterns := WeakKeyDictionary new.
	ObjectMemory addDependent: self.
    ]

    CairoPattern class >> update: aspect [
	"Clear our cache."
	<category: 'private-persistence'>
	aspect == #returnFromSnapshot ifTrue: [
	    Patterns do: [ :each | each finalize ]].
    ]

    pattern [
	<category: 'private-persistence'>
	^pattern
    ]

    cachedPattern [
	<category: 'private-persistence'>
	[canonical isNil] whileTrue: [
	    Patterns
		at: self
		ifAbsentPut: [
		    self addToBeFinalized.
		    pattern := self createCachedPattern.
		    canonical := self ].
	    "Keep the canonical object alive so we don't need to
	     reference count its pattern.  The #at:ifAbsent: call
	     makes the code resistant to finalization races."
	    canonical := pattern isNil
	        ifTrue: [Patterns at: self ifAbsent: [nil]]
		ifFalse: [self]].

	^canonical pattern
    ]

    createCachedPattern [
	<category: 'C interface'>
	self subclassResponsibility.
    ]

    postCopy [
	"We reference the same canonical object, but the pattern lives
	 from the canonical object."

	<category: 'private-persistence'>
	pattern := nil.
    ]

    finalize [
	<category: 'private-persistence'>
	pattern ifNotNil: [ :p | Cairo patternDestroy: p ].
	pattern := nil.
    ]

    maskOn: context [
	<category: 'cairo double dispatch'>
	Cairo.Cairo mask: context pattern: self cachedPattern
    ]

    setSourceOn: context [
	<category: 'cairo double dispatch'>
	Cairo setSource: context source: self cachedPattern
    ]

    on: context withSourceDo: paintBlock [
	<category: 'cairo double dispatch'>
	| pattern source |
	source := Cairo getSource: context.
	Cairo patternReference: source.
	[
	    self setSourceOn: context.
	    paintBlock value
	] ensure: [
	    source isNil ifFalse: [
		Cairo
		    setSource: context source: source;
		    patternDestroy: source ].
	].
    ]
].

CairoPattern subclass: CairoPatternDecorator [
    | wrappedPattern |
    CairoPatternDecorator class >> on: aPattern [
	<category: 'instance creation'>
	^self new wrappedPattern: aPattern; yourself
    ]

    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [
	    self wrappedPattern = anObject wrappedPattern ]
    ]

    hash [
	<category: 'basic'>
	^self class hash bitXor: self wrappedPattern hash
    ]

    wrappedPattern [
	<category: 'accessing'>
	^wrappedPattern
    ]

    wrappedPattern: aPattern [
	<category: 'private-accessing'>
	wrappedPattern := aPattern
    ]
]

CairoPatternDecorator subclass: ReflectedPattern [
    createCachedPattern [
	<category: 'C interface'>
	| result |
	result := self wrappedPattern createCachedPattern.
	Cairo patternSetExtend: result extend: Cairo extendReflect.
	^result
    ]
]

CairoPatternDecorator subclass: RepeatedPattern [
    createCachedPattern [
	<category: 'C interface'>
	| result |
	result := self wrappedPattern createCachedPattern.
	Cairo patternSetExtend: result extend: Cairo extendRepeat.
	^result
    ]
]

CairoPatternDecorator subclass: PaddedPattern [
    createCachedPattern [
	<category: 'C interface'>
	| result |
	result := self wrappedPattern createCachedPattern.
	Cairo patternSetExtend: result extend: Cairo extendPad.
	^result
    ]
]

CairoPattern subclass: SurfacePattern [
    | surface |

    SurfacePattern class >> on: aSurface [
	<category: 'instance creation'>
	^self new surface: aSurface; yourself
    ]

    surface [
	<category: 'accessing'>
	^ surface
    ]

    surface: aCairoSurface [
	<category: 'private-accessing'>
	surface := aCairoSurface
    ]

    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [
	    self surface = anObject surface ]
    ]

    hash [
	<category: 'basic'>
	^self class hash bitXor: self surface hash
    ]

    createCachedPattern [
	<category: 'C interface'>
	^ Cairo patternCreateForSurface: surface cairoSurface
    ]
].

CairoPattern subclass: GradientPattern [
    | colorStops |

    GradientPattern class >> new [
	<category: 'instance creation'>
	^super new initialize
    ]

    colorStops [
	<category: 'accessing'>
	^colorStops
    ]

    initialize [
	<category: 'initialize'>
	colorStops := OrderedCollection new.
    ]

    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [
	    self colorStops = anObject colorStops ]
    ]

    hash [
	<category: 'basic'>
	^self class hash bitXor: self colorStops hash
    ]

    addStopAt: aNumber color: aColor [
	<category: 'accessing'>
	colorStops add: aNumber -> aColor.
    ]

    addStopAt: aNumber red: r green: g blue: b alpha: a [
	<category: 'accessing'>
	colorStops add: aNumber -> (Color r: r g: g blue: b a: a).
    ]

    initializeCachedPattern: p [
	<category: 'private'>
	| c |
	colorStops do: [ :stop |
	    c := stop value.
	    Cairo patternAddColorStopRgba: p
		  offset: stop key asCNumber
		  red: c red asCNumber
		  green: c green asCNumber
		  blue: c blue asCNumber
		  alpha: c alpha asCNumber ].
    ]
].

GradientPattern subclass: LinearGradient [
    | point0 point1 |

    LinearGradient class >> from: point0 to: point1 [
	<category: 'instance creation'>
	^ self new
	    from: point0 to: point1;
	    yourself
    ]

    from [
	<category: 'accessing'>
	^point0
    ]

    to [
	<category: 'accessing'>
	^point1
    ]

    from: aPoint0 to: aPoint1 [
	<category: 'private-accessing'>
	point0 := aPoint0.
	point1 := aPoint1.
    ]

    = anObject [
	<category: 'basic'>
	^super = anObject and: [
	    point0 = anObject from and: [
	    point1 = anObject to ]]
    ]

    hash [
	<category: 'basic'>
	^(super hash bitXor: point0 hash) bitXor: point1 hash
    ]

    createCachedPattern [
	<category: 'C interface'>
	| p c |
	p := Cairo patternCreateLinear: point0 x asCNumber
		   y0: point0 y asCNumber
		   x1: point1 x asCNumber
		   y1: point1 y asCNumber.
	self initializeCachedPattern: p.
	^ p
    ]
].

GradientPattern subclass: RadialGradient [
    | point0 r0 point1 r1 |

    RadialGradient class >> from: point0 radius: r0 to: point1 radius: r1 [
	<category: 'instance creation'>
	^ self new
	    from: point0 radius: r0 to: point1 radius: r1;
	    yourself
    ]

    from [
	<category: 'accessing'>
	^point0
    ]

    fromRadius [
	<category: 'accessing'>
	^r0
    ]

    to [
	<category: 'accessing'>
	^point1
    ]

    toRadius [
	<category: 'accessing'>
	^r1
    ]

    from: aPoint0 radius: aR0 to: aPoint1 radius: aR1 [
	<category: 'private-accessing'>
	point0 := aPoint0.
	r0 := aR0.
	point1 := aPoint1.
	r1 := aR1.
    ]

    = anObject [
	<category: 'basic'>
	^super = anObject and: [
	    point0 = anObject from and: [
	    r0 = anObject fromRadius and: [
	    point0 = anObject to and: [
	    r1 = anObject toRadius ]]]]
    ]

    hash [
	<category: 'basic'>
	^(((super hash bitXor: point0 hash) bitXor: point1 hash)
	     bitXor: r0 hash) bitXor: r1 hash
    ]

    createCachedPattern [
	<category: 'C interface'>
	| p c |
	p := Cairo patternCreateRadial: point0 x asCNumber
		   cy0: point0 y asCNumber
		   radius0: r0 asCNumber
		   cx1: point1 x asCNumber
		   cy1: point1 y asCNumber
		   radius1: r1 asCNumber.
	self initializeCachedPattern: p.
	^ p
    ]
].

CairoPattern subclass: Color [
    | red green blue alpha |

    Color >> new [
	<category: 'instance creation'>
	^self new r: 0 g: 0 b: 0 a: 1.
    ]

    Color class >> r: r g: g b: b [
	<category: 'instance creation'>
	^ self basicNew r: r g: g b: b a: 1.0.
    ]

    Color class >> r: r g: g b: b a: a [
	<category: 'instance creation'>
	^ self basicNew r: r g: g b: b a: a.
    ]

    Color class >> black [
	<category: 'instance creation'>
	^ self r: 0 g: 0 b: 0
    ]

    Color class >> white [
	<category: 'instance creation'>
	^ self r: 1 g: 1 b: 1
    ]

    Color class >> red [
	<category: 'instance creation'>
	^ self r: 1 g: 0 b: 0
    ]

    Color class >> green [
	<category: 'instance creation'>
	^ self r: 0 g: 1 b: 0
    ]

    Color class >> blue [
	<category: 'instance creation'>
	^ self r: 0 g: 0 b: 1
    ]

    Color class >> cyan [
	<category: 'instance creation'>
	^ self r: 0 g: 1 b: 1
    ]

    Color class >> magenta [
	<category: 'instance creation'>
	^ self r: 1 g: 0 b: 1
    ]

    Color class >> yellow [
	<category: 'instance creation'>
	^ self r: 1 g: 1 b: 0
    ]

    = anObject [
	<category: 'basic'>
	^self class == anObject class and: [
	    red = anObject red and: [
	    green = anObject green and: [
	    blue = anObject blue and: [
	    alpha = anObject alpha]]]]
    ]

    hash [
	<category: 'basic'>
	^(red * 255) truncated +
	 ((green * 255) truncated * 256) +
	 ((blue * 255) truncated * 65536) +
	 ((alpha * 63) truncated * 16777216)
    ]
	 
    red [
	<category: 'accesing'>
	^red
    ]

    green [
	<category: 'accesing'>
	^green
    ]

    blue [
	<category: 'accesing'>
	^blue
    ]

    alpha [
	<category: 'accesing'>
	^alpha
    ]

    r: r g: g b: b a: a [
	<category: 'private-accesing'>
	red := r.
	green := g.
	blue := b.
	alpha := a.
    ]

    withRed: aNumber [
	<category: 'instance creation'>
	^ Color r: aNumber g: green b: blue a: alpha
    ]

    withGreen: aNumber [
	<category: 'instance creation'>
	^ Color r: red g: aNumber b: blue a: alpha
    ]

    withBlue: aNumber [
	<category: 'instance creation'>
	^ Color r: red g: green b: aNumber a: alpha
    ]

    withAlpha: aNumber [
	<category: 'instance creation'>
	^ Color r: red g: green b: blue a: aNumber
    ]

    mix: aColor ratio: aScale [
	<category: 'mixing'>
	^Color r: ((red * aScale) + (aColor red * (1 - aScale)))
		g: ((green * aScale) + (aColor green * (1 - aScale)))
		b: ((blue * aScale) + (aColor blue * (1 - aScale)))
		a: ((alpha * aScale) + (aColor alpha * (1 - aScale)))
    ]

    * aScale [
	<category: 'mixing'>
	aScale isNumber ifTrue: [
	    ^ Color r: ((red * aScale) min: 1)
		    g: ((green * aScale) min: 1)
		    b: ((blue * aScale) min: 1)
		    a: alpha ].
	^ Color r: red * aScale red
		g: green * aScale green
		b: blue * aScale blue
		a: alpha * aScale alpha
    ]

    createCachedPattern [
	<category: 'C interface'>

	"Should never be reached."
	self halt.
	^ Cairo patternCreateRgba: red asCNumber
		green: green asCNumber
		blue: blue asCNumber
		alpha: alpha asCNumber.
    ]

    printOn: st [
	<category: 'printing'>

	st << 'Color r: ' << red << ' g: ' << green << ' b: ' << blue << ' a: ' << alpha.
    ]

    storeOn: st [
	<category: 'printing'>

	st << $(.
	self printOn: st.
	st << $)
    ]

    setSourceOn: context [
	<category: 'cairo double dispatch'>
	Cairo
	    setSourceRgba: context
	    red: red asCNumber
	    green: green asCNumber
	    blue: blue asCNumber
	    alpha: alpha asCNumber.
    ]
].

Object subclass: TextExtents [
    | bearing extent advance |

    bearing [
	<category: 'accessing'>
	^bearing
    ]

    extent [
	<category: 'accessing'>
	^extent
    ]

    advance [
	<category: 'accessing'>
	^advance
   ]

    TextExtents class >> from: aCairoTextExtents [
	<category: 'private-instance creation'>
	^ self new initializeFrom: aCairoTextExtents
    ]

    initializeFrom: aCairoTextExtents [
	<category: 'private'>
	bearing := aCairoTextExtents xBearing value @ aCairoTextExtents yBearing value.
	extent := aCairoTextExtents width value @ aCairoTextExtents height value.
	advance := aCairoTextExtents xAdvance value @ aCairoTextExtents yAdvance value.
    ]
].

Object subclass: CairoContext [
    | surface context depth |

    CairoContext class >> on: aCairoSurface [
	<category: 'instance creation'>
	^ self new initialize: aCairoSurface
    ]

    initialize: aCairoSurface [
	<category: 'private'>
	surface := aCairoSurface.
	depth := 0.
	surface addDependent: self.
	self rebuildContext.
    ]

    rebuildContext [
	<category: 'private-persistence'>
	context := Cairo create: surface cairoSurface.
	self addToBeFinalized.
    ]

    update: aspect [
	<category: 'private-persistence'>
	aspect == #returnFromSnapshot ifTrue: [
	    ^self rebuildContext].
    ]

    finalize [
	<category: 'private-persistence'>
	context ifNil: [ ^self ].
	Cairo destroy: context.
	context := nil.
	surface removeDependent: self.
	surface := nil.
    ]

    restore [
	<category: 'drawing'>
	Cairo restore: context.
    ]

    save [
	<category: 'drawing'>
	Cairo save: context.
    ]

    saveWhile: aBlock [
	<category: 'drawing-handy API'>
	Cairo save: context.
	^ aBlock ensure: [ Cairo restore: context ].
    ]

    withSource: aPatternOrBlock do: paintBlock [
	<category: 'drawing-handy API'>
	aPatternOrBlock on: context withSourceDo: paintBlock
    ]

    source: aPatternOrBlock [
	<category: 'accessing'>
	aPatternOrBlock setSourceOn: context
    ]

    sourceRed: r green: g blue: b [
	<category: 'accessing'>
	Cairo setSourceRgb: context red: r asCNumber green: g asCNumber blue: b asCNumber.
    ]

    sourceRed: r green: g blue: b alpha: a [
	<category: 'accessing'>
	Cairo setSourceRgba: context red: r asCNumber green: g asCNumber blue: b asCNumber alpha: a asCNumber.
    ]

    closePath [
	<category: 'paths'>
	Cairo closePath: context.
    ]

    withClosedPath: aBlock do: opsBlock [
	<category: 'paths-handy API'>
	self withPath: [ aBlock value. self closePath ] do: opsBlock
    ]

    addClosedSubPath: aBlock [
	<category: 'paths-handy API'>
	self newSubPath.
	aBlock value.
	self closePath
    ]

    addSubPath: aBlock [
	<category: 'paths-handy API'>
	self newSubPath.
	aBlock value
    ]

    withPath: aBlock do: opsBlock [
	<category: 'paths-handy API'>

	"Cannot yet save a path and go back to it later."
	depth >= 1 ifTrue: [ self notYetImplemented ].
	depth := depth + 1.
	[aBlock value. opsBlock value] ensure: [
	    depth := depth - 1. self newPath]
    ]

    newSubPath [
	<category: 'paths'>
	Cairo newSubPath: context.
    ]

    newPath [
	<category: 'paths'>
	Cairo newPath: context.
    ]

    moveTo: aPoint [
	<category: 'paths'>
	Cairo moveTo: context x: aPoint x asCNumber y: aPoint y asCNumber.
    ]

    relMoveTo: aPoint [
	<category: 'paths'>
	Cairo relMoveTo: context dx: aPoint x asCNumber dy: aPoint y asCNumber.
    ]

    lineTo: aPoint [
	<category: 'paths'>
	Cairo lineTo: context x: aPoint x asCNumber y: aPoint y asCNumber.
    ]

    relLineTo: aPoint [
	<category: 'paths'>
	Cairo relLineTo: context dx: aPoint x asCNumber dy: aPoint y asCNumber.
    ]

    curveTo: aPoint3 via: aPoint1 via: aPoint2 [
	<category: 'paths'>
	Cairo curveTo: context
	      x1: aPoint1 x asCNumber y1: aPoint1 y asCNumber
	      x2: aPoint2 x asCNumber y2: aPoint2 y asCNumber
	      x3: aPoint3 x asCNumber y3: aPoint3 y asCNumber.
    ]

    curveVia: aPoint1 via: aPoint2 to: aPoint3 [
	<category: 'paths'>
	Cairo curveTo: context
	      x1: aPoint1 x asCNumber y1: aPoint1 y asCNumber
	      x2: aPoint2 x asCNumber y2: aPoint2 y asCNumber
	      x3: aPoint3 x asCNumber y3: aPoint3 y asCNumber.
    ]

    arc: aPoint radius: r from: angle1 to: angle2 [
	<category: 'paths'>
	Cairo arc: context
	      xc: aPoint x asCNumber yc: aPoint y asCNumber
	      radius: r asCNumber
	      angle1: angle1 asCNumber angle2: angle2 asCNumber.
    ]

    arcNegative: aPoint radius: r from: angle1 to: angle2 [
	<category: 'paths'>
	Cairo arcNegative: context
	      xc: aPoint x asCNumber yc: aPoint y asCNumber
	      radius: r asCNumber
	      angle1: angle1 asCNumber angle2: angle2 asCNumber.
    ]

    rectangle: aRect [
	<category: 'paths'>
	Cairo rectangle: context
	      x: aRect left asCNumber y: aRect top asCNumber
	      width: aRect width asCNumber height: aRect height asCNumber.
    ]

    roundedRectangle: b radius: cornerRadius [
	<category: 'paths-handy API'>
	| hr vr h2 v2 |
	hr := cornerRadius@0.
	vr := 0@cornerRadius.
	h2 := hr * (1 - 0.55228475).
	v2 := vr * (1 - 0.55228475).
	self
	    moveTo: b topLeft + hr;
	    lineTo: b topRight - hr;
	    curveTo: b topRight + vr via: b topRight - h2 via: b topRight + v2;
	    lineTo: b bottomRight - vr;
	    curveTo: b bottomRight - hr via: b bottomRight - v2 via: b bottomRight - h2;
	    lineTo: b bottomLeft + hr;
	    curveTo: b bottomLeft - vr via: b bottomLeft + h2 via: b bottomLeft - v2;
	    lineTo: b topLeft + vr;
	    curveTo: b topLeft + hr via: b topLeft + v2 via: b topLeft + h2.
    ]

    groupWhile: aBlock [
	<category: 'drawing-handy API'>
	| pattern |
	[
	    Cairo.Cairo pushGroup: context.
	    aBlock ensure: [ pattern := Cairo.Cairo popGroup: context ].
	    Cairo.Cairo setSource: context source: pattern.
	] ensure: [
	    pattern isNil ifFalse: [ Cairo.Cairo patternDestroy: pattern ].
	].
    ]

    clipPreserve [
	<category: 'drawing'>
	Cairo clipPreserve: context
    ]

    clip [
	<category: 'drawing'>
	depth > 0
	    ifTrue: [Cairo clipPreserve: context]
	    ifFalse: [Cairo clip: context]
    ]

    clip: aBlock [
	<category: 'drawing-handy API'>
	self withPath: aBlock do: [ self clip ]
    ]

    resetClip [
	<category: 'drawing'>
        Cairo resetClip: context.
    ]

    mask: aPatternOrBlock [
	<category: 'drawing'>
        aPatternOrBlock maskOn: context
    ]

    paint [
	<category: 'drawing'>
        Cairo paint: context.
    ]

    paintWith: aPatternOrBlock [
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self paint ]
    ]

    paintWithAlpha: a [
	<category: 'drawing'>
        Cairo paintWithAlpha: context alpha: a asCNumber.
    ]

    paint: aPatternOrBlock withAlpha: a [
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self paintWithAlpha: a ]
    ]

    fillPreserve [
	<category: 'drawing'>
	Cairo fillPreserve: context
    ]

    fill [
	<category: 'drawing'>
	depth > 0
	    ifTrue: [Cairo fillPreserve: context]
	    ifFalse: [Cairo fill: context]
    ]

    fill: aBlock [
	<category: 'drawing-handy API'>
	self withPath: aBlock do: [ self fill ]
    ]

    fill: pathBlock with: aPatternOrBlock [
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self fill: pathBlock ]
    ]

    fillWith: aPatternOrBlock [
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self fill ]
    ]

    strokePreserve [
	<category: 'drawing'>
	Cairo strokePreserve: context
    ]

    stroke [
	<category: 'drawing'>
	depth > 0
	    ifTrue: [Cairo strokePreserve: context]
	    ifFalse: [Cairo stroke: context]
    ]

    stroke: aBlock [
	<category: 'drawing-handy API'>
	self withPath: aBlock do: [ self stroke ]
    ]

    stroke: pathBlock with: aPatternOrBlock [
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self stroke: pathBlock ]
    ]

    strokeWith: aPatternOrBlock [
	<category: 'drawing-handy API'>
	self withSource: aPatternOrBlock do: [ self stroke ]
    ]

    identityMatrix [
	<category: 'transform'>
        Cairo identityMatrix: context.
    ]

    translateBy: aPoint [
	<category: 'transform'>
	Cairo translate: context tx: aPoint x asCNumber ty: aPoint y asCNumber.
    ]

    scaleBy: aPoint [
	<category: 'transform'>
	| p |
	p := aPoint asPoint.
        Cairo scale: context sx: p x asCNumber sy: p y asCNumber.
    ]

    rotateBy: rads [
	<category: 'transform'>
        Cairo rotate: context angle: rads asCNumber.
    ]

    nullTransform [
	<category: 'transform-handy API'>
    ]

    transformBy: aTransform [
	<category: 'transform'>
        Cairo transform: context matrix: aTransform toLocal.
    ]

    CairoContext class >> lookupLineCapValue: anInteger [
	<category: 'accessing'>
	anInteger == Cairo lineCapSquare ifTrue: [ ^#square ].
	anInteger == Cairo lineCapRound ifTrue: [ ^#round ].
	anInteger == Cairo lineCapButt ifTrue: [ ^#butt ].
	self error: 'Unsupported line cap value ', anInteger
    ]

    CairoContext class >> lookupLineJoinValue: anInteger [
	<category: 'accessing'>
	anInteger == Cairo lineJoinBevel ifTrue: [ ^#bevel ].
	anInteger == Cairo lineJoinRound ifTrue: [ ^#round ].
	anInteger == Cairo lineJoinMiter ifTrue: [ ^#miter ].
	self error: 'Unsupported line join value ', anInteger
    ]

    CairoContext class >> lookupFillRuleValue: anInteger [
	<category: 'accessing'>
	anInteger == Cairo fillRuleEvenOdd ifTrue: [ ^#evenOdd ].
	anInteger == Cairo fillRuleWinding ifTrue: [ ^#winding ].
	self error: 'Unsupported fill rule value ', anInteger
    ]

    CairoContext class >> lookupSlantValue: anInteger [
	<category: 'accessing'>
	anInteger == Cairo fontSlantNormal ifTrue: [ ^#normal ].
	anInteger == Cairo fontSlantItalic ifTrue: [ ^#italic ].
	anInteger == Cairo fontSlantOblique ifTrue: [ ^#oblique ].
	self error: 'Unsupported slant value ', anInteger
    ]

    CairoContext class >> lookupLineCap: aSymbol [
	<category: 'accessing'>
	aSymbol == #square ifTrue: [ ^Cairo lineCapSquare ].
	aSymbol == #round ifTrue: [ ^Cairo lineCapRound ].
	aSymbol == #butt ifTrue: [ ^Cairo lineCapButt ].
	self error: 'Unsupported line cap symbol ', aSymbol
    ]

    CairoContext class >> lookupLineJoin: aSymbol [
	<category: 'accessing'>
	aSymbol == #bevel ifTrue: [ ^Cairo lineJoinBevel ].
	aSymbol == #round ifTrue: [ ^Cairo lineJoinRound ].
	aSymbol == #miter ifTrue: [ ^Cairo lineJoinMiter ].
	self error: 'Unsupported line join symbol ', aSymbol
    ]

    CairoContext class >> lookupFillRule: aSymbol [
	<category: 'accessing'>
	aSymbol == #evenOdd ifTrue: [ ^Cairo fillRuleEvenOdd ].
	aSymbol == #winding ifTrue: [ ^Cairo fillRuleWinding ].
	self error: 'Unsupported fill rule symbol ', aSymbol
    ]

    CairoContext class >> lookupSlant: aSymbol [
	<category: 'accessing'>
	aSymbol == #normal ifTrue: [ ^Cairo fontSlantNormal ].
	aSymbol == #italic ifTrue: [ ^Cairo fontSlantItalic ].
	aSymbol == #oblique ifTrue: [ ^Cairo fontSlantOblique ].
	self error: 'Unsupported slant symbol ', aSymbol
    ]

    CairoContext class >> lookupWeight: aSymbol [
	<category: 'accessing'>
	aSymbol == #normal ifTrue: [ ^Cairo fontWeightNormal ].
	aSymbol == #bold ifTrue: [ ^Cairo fontWeightBold ].
	self error: 'Unsupported weight symbol ', aSymbol
    ]

    selectFontFamily: aString slant: slantSymbol weight: weightSymbol [
	<category: 'text'>
	Cairo selectFontFace: context
	      family: aString
	      slant: (self class lookupSlant: slantSymbol)
	      weight: (self class lookupWeight: weightSymbol).
    ]

    lineWidth [
	<category: 'accessing'>
	^Cairo getLineWidth: context.
    ]

    lineCap [
	<category: 'accessing'>
	^self class lookupLineCapValue: (Cairo getLineCap: context).
    ]

    fillRule [
	<category: 'accessing'>
	^self class lookupFillRuleValue: (Cairo getFillRule: context).
    ]

    lineJoin [
	<category: 'accessing'>
	^self class lookupLineJoinValue: (Cairo getLineJoin: context).
    ]

    miterLimit [
	<category: 'accessing'>
	^Cairo getMiterLimit: context.
    ]

    lineWidth: w [
	<category: 'accessing'>
	Cairo setLineWidth: context width: w asCNumber.
    ]

    lineCap: aNumber [
	<category: 'accessing'>
	Cairo setLineCap: context lineCap: (self class lookupLineCap: aNumber).
    ]

    fillRule: aNumber [
	<category: 'accessing'>
	Cairo setFillRule: context fillRule: (self class lookupFillRule: aNumber).
    ]

    lineJoin: aNumber [
	<category: 'accessing'>
	Cairo setLineJoin: context lineJoin: (self class lookupLineJoin: aNumber).
    ]

    miterLimit: aNumber [
	<category: 'accessing'>
	Cairo setMiterLimit: context miterLimit: aNumber asCNumber.
    ]

    fontSize: aNumber [
	<category: 'accessing'>
	Cairo setFontSize: context size: aNumber.
    ]

    showText: aString [
	<category: 'drawing'>
	Cairo showText: context utf8: aString.
    ]

    textPath: aString [
	<category: 'paths'>
	Cairo textPath: context utf8: aString.
    ]

    textExtents: aString [
	<category: 'text'>
	| ext |
	ext := CairoTextExtents new.
	^[
	    Cairo textExtents: context utf8: aString extents: ext.
	    TextExtents from: ext
	] ensure: [ ext free ]
    ]
].

Eval [
    CairoPattern initialize
]
