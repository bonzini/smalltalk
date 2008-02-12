Object extend [
   restoreFromSnapshot: anObject [
        <category: '*Seaside-Core'>
	self basicSize = anObject basicSize
	    ifFalse: [ self become: (self class basicNew: anObject basicSize) ].
	self class instSize = anObject class instSize
	    ifFalse: [ self halt ].
        1 to: self class instSize do: [ :i |
	    self instVarAt: i put: (anObject instVarAt: i) ].
        1 to: self basicSize do: [ :i |
	    self basicAt: i put: (anObject basicAt: i) ]
    ]
]

WAFileLibrary class extend [
    compileText: aByteArrayOrString selector: aSymbol [
        "Compiles aByteArrayOrString into a method named aSymbol that returns aByteArrayOrString as a string literal.B
         aSymbol
         ^ aByteArrayOrString"

        <category: 'private'>
        | code |
        code := SeasidePlatformSupport
                    asMethodReturningString: aByteArrayOrString toString
                    named: aSymbol.
        SeasidePlatformSupport
            compile: code
            into: self
            classified: self methodCategory
    ]
]

WAResponse extend [
    nextPutAll: aString [
        <category: 'streaming'>
        stream nextPutAll: aString
    ]
]
