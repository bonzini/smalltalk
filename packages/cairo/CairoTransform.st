"======================================================================
|
|   Compositional transformation classes using CairoMatrix
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

CStruct subclass: CairoMatrix [
    <declaration: #(
      (#xx #double)
      (#yx #double)
      (#xy #double)
      (#yy #double)
      (#x0 #double)
      (#y0 #double))>

    <category: 'Cairo-C interface'>

    CairoMatrix class >> new [
	^ super new addToBeFinalized
    ]

    initIdentity [
        Cairo matrixInitIdentity: self.
    ]

    withPoint: point do: block [
        | ox oy |
	ox := CDouble value: point x.
	oy := CDouble value: point y.
	^ [
	    block value:self value:ox value: oy
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


"A note on transforms: to be compositional, the most straight-forward thing
 is to always use a transformation matrix.  However, a lot of the time, we'll
 be doing just one kind of transformation; e.g., a scale, or a translation.
 Further, we may only ever modify a transformation in one way, like translating
 a translation.  For this reason, we specialise for each of the translations
 and provide a generic matrix implementation for composing heterogeneous
 transformations."

Object subclass: Transform [
    | matrix |

    Transform class >> newIdentity [
	^ super new initialize
    ]

    initialize []

    before: aTransform [
        "I return a new Transform that transforms its visitor by self
        first, then by aTransform."

        ^ aTransform after: self.
    ]

    after: transform [
        "I return a new Transform that transforms its visitor by
        aTransform first, then by self."

        self subclassResponsibility
    ]

    Transform class >> identity [
        "I return the identity transform, that leaves its visitor
        unchanged."

        ^ IdentityTransform instance
    ]

    Transform class >> sequence: transforms [
        "I return a compound transform, that transforms its visitor by
        each of the Transforms in transforms in first-to-last order."

	transforms isEmpty ifTrue: [ ^self identity ].
        ^ transforms fold: [:acc :xform | xform after: acc]
    ]

    about: aPoint [
        ^ ((Translate by: aPoint * -1)
              before: self) before: (Translate by: aPoint)
    ]

    asMatrixTransform [
        matrix isNil ifFalse: [matrix := self after: MatrixTransform newIdentity].
	^matrix
    ]

    translateBy: point [
        ^ self asMatrixTransform translateBy: point.
    ]

    scaleBy: point [
        ^ self asMatrixTransform scaleBy: point.
    ]

    rotateBy: rads [
        ^ self asMatrixTransform rotateBy: rads.
    ]

    nullTransform [
	^ self
    ]

    transformBy: aTransform [
        ^ self asMatrixTransform transformBy: aTransform.
    ]

    transformPoint: point [
        ^ self asMatrixTransform transformPoint: point
    ]

    transformDistance: point [
        ^ self asMatrixTransform transformDistance: point
    ]

    transformBounds: rect [
        | corners |
        "Transform the given bounds. Note this is distinct from
         transforming a rectangle, since bounds must be aligned with
         the axes."
        corners := {self transformPoint: rect topLeft.
		    self transformPoint: rect topRight.
		    self transformPoint: rect bottomLeft.
		    self transformPoint: rect bottomRight}.
        ^ (corners fold: [ :left :right | left min: right ]) corner:
            (corners fold: [ :left :right | left max: right ])
    ]

    inverse [
        ^ self subclassResponsibility
    ]

    scale [ ^ (1@1) ]
    
    rotation [ ^ 0 ]

    translation [ ^ (0@0) ]
		      
    translateTo: aPoint [
	^ self translateBy: (aPoint - self translation).
    ]
    
    scaleTo: sxsy [
	^ self scaleBy: sxsy asPoint / self scale
    ]

    rotateTo: rads [
	^ self rotateBy: (rads - self rotation)
    ]

]

Transform subclass: IdentityTransform [

    IdentityTransform class extend [
        | instance |

        instance [
	    instance ifNil: [ instance := self new ].
	    ^instance
        ]
    ]

    before: aTransform [
	^ aTransform
    ]

    after: aTransform [
	^ aTransform
    ]

    translateBy: aPoint [
	^ Translate by: aPoint
    ]

    scaleBy: aPoint [
	^ Scale by: aPoint
    ]

    rotateBy: rads [
	^ Rotate by: rads
    ]

    nullTransform [
	^ self
    ]

    transformPoint: aPoint [
	^ aPoint
    ]

    inverse [
	^ self
    ]
]

Transform subclass: MatrixTransform [
    | to |
    
    toLocal [ ^ to ]

    toLocal: matrix [
        to := matrix.
    ]

    copyOp: aBlock [
	| newMatrix |
	newMatrix := to copy.
	aBlock value: newMatrix.
	^ MatrixTransform new toLocal: newMatrix
    ]

    initialize [
        to := CairoMatrix new initIdentity.
        self addToBeFinalized.
    ]

    finalize [
        to ifNil: [ ^ self ].
        to free.
        to := nil.
    ]

    release [
        self finalize.
	self removeToBeFinalized.
        super release
    ]

    transformBy: aTransform [
	^ self copyOp: [:n | Cairo matrixMultiply: n a: aTransform toLocal b: n]
    ]

    translateBy: aPoint [
	^ self copyOp: [:n | Cairo matrixTranslate: n tx: aPoint x ty: aPoint y]
    ]

    scaleBy: aPoint [
	| p |
	p := aPoint asPoint.
	^ self copyOp: [:n | Cairo matrixScale: n sx: p x sy: p y]
    ]

    rotateBy: rads [
	^ self copyOp: [:n | Cairo matrixRotate: n radians: rads]
    ]

    after: aTransform [
        ^ aTransform transformBy: self.
    ]

    transformPoint: point [
        ^ to withPoint: point do:
            [ :mtx :x :y |
                Cairo matrixTransformPoint: mtx x: x y: y.
                x value @ y value
            ]
    ]

    transformDistance: point [
        ^ to withPoint: point do:
            [ :mtx :x :y |
                Cairo matrixTransformDistance: mtx dx: x dy: y.
                x value @ y value
            ]
    ]

    inverse [
	^ self copyOp: [:n | Cairo matrixInvert: n]
    ]

    scale [
	| pt1 pt2 |
	pt1 := self transformDistance: (1@0).
	pt2 := self transformDistance: (0@1).
	^ (pt1 dist: (0@0)) @ (pt2 dist: (0@0))
    ]

    rotation [
	| pt1 pt2 |
	pt1 := self transformDistance: (1@0).
	pt2 := self transformDistance: (0@1).
	^ pt2 arcTan: pt1
    ]

    translation [
	^ self transformPoint: (0@0)
    ]
]

Transform subclass: Translate [
    | dxdy |

    Translate class >> by: aPoint [
        | t |
        t := Translate new.
        t translation: aPoint.
        ^ t.
    ]

    translation: aPoint [
        dxdy := aPoint.
    ]

    translateBy: point [
        ^ Translate by: (dxdy + point).
    ]

    after: aTransform [
	^ aTransform translateBy: dxdy.
    ]

    transformPoint: point [
        ^ point + dxdy
    ]
    
    transformDistance: point [
        ^ point
    ]

    transformBounds: rect [
        ^ rect translateBy: dxdy
    ]

    inverse [
        ^ Translate by: dxdy * -1
    ]

    translation [ ^ dxdy ]
]

Transform subclass: Scale [
    | sxsy |
    
    factors: aPoint [
        sxsy := aPoint.
    ]

    Scale class >> by: aPoint [
        | scale |
        scale := Scale new.
        scale factors: aPoint asPoint.
        ^ scale
    ]

    scaleBy: factors [
        ^ Scale by: (sxsy * factors)
    ]

    after: aTransform [
	^ aTransform scaleBy: sxsy.
    ]

    transformPoint: point [
        ^ point * sxsy
    ]
    
    transformDistance: point [
        ^ point * sxsy
    ]
    
    transformBounds: rect [
        ^ rect scaleBy: sxsy
    ]
    
    inverse [
        ^ Scale by: (1/(sxsy x)) @ (1/(sxsy y))
    ]

    scale [ ^ sxsy ]
]

Transform subclass: Rotate [
    | radians |

    radians: aDouble [
        radians := aDouble.
        matrix := nil.
    ]

    Rotate class >> by: rads [
        | r |
        r := Rotate new.
        r radians: rads.
        ^ r
    ]

    rotateBy: rads [
        ^ Rotate by: radians + rads.
    ]

    after: aTransform [
	^ aTransform rotateBy: radians.
    ]

    inverse [
        ^ Rotate by: -1 * radians
    ]

    rotation [ ^ radians ]
]
