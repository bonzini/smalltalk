Object subclass: MACompatibility [
    
    <category: 'Magritte-Model-Core'>
    <comment: 'I am providing all the platform compatibility code on my class side, so that porting to different Smalltalk dialects can concentrate in a single place.'>

    ShowLicense := false.

    MACompatibility class >> allSubInstancesOf: aClass do: aBlock [
	"Evaluate the aBlock for all instances of aClass and all its subclasses."

	<category: 'environment'>
	aClass allSubinstancesDo: aBlock
    ]

    MACompatibility class >> classNamed: aString [
	"Return the class named aString, nil if the class can't be found."

	<category: 'environment'>
	^(aString subStrings: $.) inject: Smalltalk into: [ :old :each |
	    old at: each asSymbol ifAbsent: [ ^nil ] ]
    ]

    MACompatibility class >> openWorkspace: aContentsString titled: aTitleString [
	"Open a new wokspace with the contents aContentsString and the title aTitleString."

	ShowLicense ifFalse: [ ^self ].
	('%1

%2
' % { aTitleString asUppercase. aContentsString }) displayOn: stderr
    ]

    MACompatibility class >> referenceStream: aReadWriteStream [
	"Return a stream instance to operate on aReadWriteStream being able to serialize and deserialize objects by sending #nextPut: and #next. Squeak: The implementation of ReferenceStream doesn't work well together with the default WriteStream implementaiton, therefor we have to change it on the fly."

	<category: 'environment'>
	^ObjectDumper on: aReadWriteStream
    ]

    MACompatibility class >> uuid [
	"Answer a random object that is extremly likely to be unique over space and time."

	<category: 'environment'>
	^UUID new
    ]
]



Symbol extend [
    isUnary [
	<category: 'testing'>

	^self numArgs = 0
    ]
]



ByteArray subclass: UUID [
    
    <shape: #byte>
    <category: 'Seaside-Core-Utilities'>
    <comment: 'I am a session or conticuation key.'>

    Node := nil.
    SequenceValue := nil.
    LastTime := nil.
    Generator := nil.
    GeneratorMutex := nil.

    UUID class >> timeValue [
	^Time utcSecondClock * 1000 + Time millisecondClock * 10000
    ]

    UUID class >> randomNodeValue [
	| n |
	"TODO: use some kind of digest to produce cryptographically strong
	 random numbers."
	n := Generator between: 0 and: 16rFFFF.
	n := (n bitShift: 16) bitOr: (Generator between: 0 and: 16rFFFF).
	n := (n bitShift: 16) bitOr: (Generator between: 0 and: 16rFFFF).
	^n bitOr: 1
    ]

    UUID class >> update: aSymbol [
	aSymbol == #returnFromSnapshot ifTrue: [
	    "You cannot be sure that the node ID is the same."
	    GeneratorMutex critical: [
		Generator := Random new.
		LastTime := self timeValue.
		Node := self randomNodeValue.
		SequenceValue := (SequenceValue + 1) bitAnd: 16383 ]].
    ]

    UUID class >> defaultSize [
	<category: 'private'>
	^16
    ]

    UUID class >> initialize [
	<category: 'initialization'>
	ObjectMemory addDependent: self.
	Generator := Random new.
	LastTime := self timeValue.
	Node := self randomNodeValue.
	SequenceValue := Generator between: 0 and: 16383.
	GeneratorMutex := Semaphore forMutualExclusion.
    ]

    UUID class >> new [
	<category: 'instance-creation'>
	^(self new: self defaultSize) initialize
    ]

    initialize [
	<category: 'private'>
	| t |
	GeneratorMutex critical: [
	    t := self class timeValue bitAnd: 16rFFFFFFFFFFFFFFF.
	    t <= LastTime
		ifTrue: [ SequenceValue := (SequenceValue + 1) bitAnd: 16383 ].

	    LastTime := t.
	    self at: 1 put: ((t bitShift: -24) bitAnd: 255).
	    self at: 2 put: ((t bitShift: -16) bitAnd: 255).
	    self at: 3 put: ((t bitShift: -8) bitAnd: 255).
	    self at: 4 put: (t bitAnd: 255).
	    self at: 5 put: ((t bitShift: -40) bitAnd: 255).
	    self at: 6 put: ((t bitShift: -32) bitAnd: 255).
	    self at: 7 put: (t bitShift: -56) + 16r10.
	    self at: 8 put: ((t bitShift: -48) bitAnd: 255).
	    self at: 9 put: (SequenceValue bitShift: -8) + 16r80.
	    self at: 10 put: (SequenceValue bitAnd: 255).
	    self at: 13 put: ((Node bitShift: -40) bitAnd: 255).
	    self at: 14 put: ((Node bitShift: -32) bitAnd: 255).
	    self at: 15 put: ((Node bitShift: -24) bitAnd: 255).
	    self at: 16 put: ((Node bitShift: -16) bitAnd: 255).
	    self at: 11 put: ((Node bitShift: -8) bitAnd: 255).
	    self at: 12 put: (Node bitAnd: 255)]
    ]

    printOn: aStream from: a to: b [
	<category: 'private'>
	self from: a to: b do: [:each |
	    aStream nextPut: (Character digitValue: (each bitShift: -4)).
	    aStream nextPut: (Character digitValue: (each bitAnd: 15)) ]
    ]

    printOn: aStream [
	<category: 'printing'>
	self printOn: aStream from: 1 to: 4.
	aStream nextPut: $-.
	self printOn: aStream from: 5 to: 6.
	aStream nextPut: $-.
	self printOn: aStream from: 7 to: 8.
	aStream nextPut: $-.
	self printOn: aStream from: 9 to: 10.
	aStream nextPut: $-.
	self printOn: aStream from: 11 to: 16.
    ]
]

FileDescriptor extend [
    binary []
]

Object extend [
    asString [ ^self displayString ]
    isCollection [ ^false ]
    isEmptyOrNil [ ^false ]
]

Collection extend [
    intersection: b [ ^self asSet & b ]
    hasEqualElements: b [ ^self asArray = b asArray ]
    isCollection [ ^true ]
    isEmptyOrNil [ ^self isEmpty ]
]

SequenceableCollection extend [
    sort: aBlock [
	self
	    replaceFrom: 1
	    to: self size
	    with: (self asSortedCollection: aBlock)
	    startingAt: 1
    ]
]

UndefinedObject extend [
    isEmptyOrNil [ ^true ]
]

String extend [
    includesSubstring: aString caseSensitive: aBoolean [
	aBoolean ifTrue: [ ^(self indexOfSubCollection: aString) > 0 ].
	^(self asLowercase indexOfSubCollection: aString asLowercase) > 0
    ]
]

ValueHolder extend [
    contents [ ^self value ]
    contents: anObject [ self value: anObject ]
]

Time extend [
    print24: boolean24 showSeconds: booleanSec on: aStream [
        "Print a representation of the receiver on aStream"

        <category: 'arithmetic'>
	| h |
	h := boolean24 ifTrue: [ self hour24 ] ifFalse: [ self hour12 ].
        h printOn: aStream.
        aStream nextPut: $:.
        self minutes < 10 ifTrue: [aStream nextPut: $0].
        self minutes printOn: aStream.
	booleanSec ifFalse: [ ^self ].
        aStream nextPut: $:.
        self seconds < 10 ifTrue: [aStream nextPut: $0].
        self seconds printOn: aStream
    ]
]

Object subclass: MAVisitor [
    MAVisitor class >> new [ ^super new initialize ]
    initialize []
]

Eval [
    UUID initialize.
]
