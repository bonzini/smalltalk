Collection extend [
    Object >> isCollection [ ^false ]
    isCollection [ ^true ]

    includesAllOf: aCollection [
	^aCollection allSatisfy: [ :each | self includes: each ]
    ]

    groupBy: keyBlock having: selectBlock [
	"Split the receiver's contents into collections of 
	elements for which keyBlock returns the same results, and return those 
	collections allowed by selectBlock."
	| result |
	result := LookupTable new.
	self do: [:each |
	    | coll key |
	    key := keyBlock value: each.
	    coll := result at: key ifAbsentPut: [OrderedCollection new].
	    coll add: each].
	^result select: selectBlock
    ]
]

Message extend [
    collectArguments: anArray [
	^anArray copyFrom: 1 to: self selector numArgs
    ]
]

DirectedMessage extend [
    cull: arg1 [
        ^self valueWithPossibleArgs: { arg1 }
    ]

    cull: arg1 cull: arg2 [
        ^self valueWithPossibleArgs: { arg1. arg2 }
    ]

]

SequenceableCollection extend [
    fifth [ ^self at: 5]
    sixth [ ^self at: 6]
    seventh [ ^self at: 7]
    eighth [ ^self at: 8]

    sort: aBlock [
	^self replaceFrom: 1 to: self size
	     with: (self asSortedCollection: aBlock)
    ]
]

String extend [
    translated [ ^self ]
    asText [ ^self ]

    findSelector [
	"From Squeak, hunts down selectors with keyword parts; while this
	 doesn't give a true parse, in most cases it does what we want,
	 in where it doesn't, we're none the worse for it."

	| sel tokens level n |
	sel := self trimSeparators.
	(sel includes: $:) ifTrue: [
	    sel := sel copyReplaceAll: ':' with: ': '.
	    tokens := sel subStrings.
	    sel := self class streamContents:
		[:s | level := 0.
		tokens do: [:token |
		    (level = 0 and: [token endsWith: ':'])
			ifTrue: [s nextPutAll: token]
			ifFalse: [
			    (n := token occurrencesOf: $( ) > 0 ifTrue: [level := level + n].
			    (n := token occurrencesOf: $[ ) > 0 ifTrue: [level := level + n].
			    (n := token occurrencesOf: $] ) > 0 ifTrue: [level := level - n].
			    (n := token occurrencesOf: $) ) > 0 ifTrue: [level := level - n]]]]].

	sel isEmpty ifTrue: [^nil].
	Symbol hasInterned: sel ifTrue: [:aSymbol | ^aSymbol].
	^nil
    ]
]

Object subclass: OBObject [
    OBObject class >> new [ ^super new initialize ]
    initialize []
]
