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
