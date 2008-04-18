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


"A note on transforms: to be compositional, the most straight-forward thing
 is to always use a transformation matrix.  However, a lot of the time, we'll
 be doing just one kind of transformation; e.g., a scale, or a translation.
 Further, we may only ever modify a transformation in one way, like translating
 a translation.  For this reason, we specialise for each of the translations
 and provide a generic matrix implementation for composing heterogeneous
 transformations."

Object subclass: Transform [

    Transform class >> newIdentity [
	^ super new initialize
    ]

    initialize []

    accept: visitor [
        self subclassResponsibility.
    ]

    before: aTransform [
        "I return a new Transform that transforms its visitor by self
        first, then by aTransform."

        ^ aTransform accept: self.
    ]

    after: transform [
        "I return a new Transform that transforms its visitor by
        aTransform first, then by self."

        ^ self accept: transform.
    ]

    Transform class >> identity [
        "I return the identity transform, that leaves its visitor
        unchanged."

        ^ IdentityTransform instance
    ]

    Transform class >> sequence: transforms [
        "I return a compound transform, that transforms its visitor by
        each of the Transforms in transforms in first-to-last order."

        ^ transforms inject: self identity
                     into: [:acc :xform | acc before: xform]
    ]

    about: aPoint [
        ^ ((Translate by: aPoint)
              before: self) before: (Translate by: (aPoint * -1))]

    asMatrixTransform [
        ^ self accept: MatrixTransform newIdentity
    ]

    translateBy: point [
        ^ self asMatrixTransform translateBy: point.
    ]

    scaleByFactor: factor [
        ^ self scaleBy: (factor@factor).
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
        ^ self subclassResponsibility
    ]

    transformDistance: point [
        ^ self transformPoint: point
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
	^ self scaleBy: sxsy / self scale
    ]

    rotateTo: rads [
	^ self rotateBy: (rads - self rotation)
    ]

]

Transform subclass: IdentityTransform [
    accept: visitor [
	^ visitor nullTransform.
    ]

    before: aTransform [
	^ aTransform
    ]

    after: aTransform [
	^ aTransform
    ]

    asMatrixTransform [
	^ MatrixTransform newIdentity
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

IdentityTransform class extend [
    | instance |

    instance [
	instance ifNil: [ instance := self new ].
	^instance
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

    transformBy: aTransform [
	^ self copyOp: [:n | Cairo matrixMultiply: n a: aTransform toLocal b: n]
    ]

    translateBy: aPoint [
	^ self copyOp: [:n | Cairo matrixTranslate: n tx: aPoint x ty: aPoint y]
    ]

    scaleBy: aPoint [
	^ self copyOp: [:n | Cairo matrixScale: n sx: aPoint x sy: aPoint y]
    ]

    rotateBy: rads [
	^ self copyOp: [:n | Cairo matrixRotate: n radians: rads]
    ]

    accept: visitor [
        ^ visitor transformBy: self.
    ]

    transformPoint: point [
        to withPoint: point do:
            [ :mtx :x :y |
                Cairo matrixTransformPoint: mtx x: x y: y.
                ^ x value @ y value
            ]
    ]

    transformDistance: point [
        to withPoint: point do:
            [ :mtx :x :y |
                Cairo matrixTransformDistance: mtx dx: x dy: y.
                ^ x value @ y value
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
	| pt |
	pt := self transformDistance: (1@0).
	^ pt arcTan
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

    accept: visitor [
	^ visitor translateBy: dxdy.
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
        scale factors: aPoint.
        ^ scale
    ]

    Scale class >> byFactor: factor [
        ^ Scale by: (factor@factor)
    ]

    scaleBy: factors [
        ^ Scale by: (sxsy * factors)
    ]

    accept: visitor [
	^ visitor scaleBy: sxsy.
    ]

    transformPoint: point [
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
    | radians matrix |

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

    accept: visitor [
	^ visitor rotateBy: radians.
    ]

    transformPoint: point [
        matrix ifNil: [matrix := self asMatrixTransform].
        ^ matrix transformPoint: point
    ]

    inverse [
        ^ Rotate by: -1 * radians
    ]

    rotation [ ^ radians ]
]
