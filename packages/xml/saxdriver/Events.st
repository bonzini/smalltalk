


Object subclass: XPPEvent [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isEndDocument [
	<category: 'testing'>
	^false
    ]

    isEndTag [
	<category: 'testing'>
	^false
    ]

    isEndTag: aStringOrNodeTag [
	<category: 'testing'>
	^false
    ]

    isStartDocument [
	<category: 'testing'>
	^false
    ]

    isStartTag [
	<category: 'testing'>
	^false
    ]

    isStartTag: aStringOrNodeTag [
	<category: 'testing'>
	^false
    ]

    isText [
	<category: 'testing'>
	^false
    ]
]



XPPEvent subclass: XPPEndDocument [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isEndDocument [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	
    ]
]



XPPEvent subclass: XPPStartDocument [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isStartDocument [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer startDocument
    ]
]



XPPEvent subclass: XPPTagEvent [
    | tag |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    XPPTagEvent class >> tag: tag [
	<category: 'instance creation'>
	^self new tag: tag
    ]

    is: tagName [
	<category: 'accessing'>
	^tag isLike: tagName
    ]

    name [
	<category: 'accessing'>
	^tag name
    ]

    namespace [
	<category: 'accessing'>
	^tag namespace
    ]

    qualifier [
	<category: 'accessing'>
	^tag qualifier
    ]

    tag [
	<category: 'accessing'>
	^tag
    ]

    tag: aNodeTag [
	<category: 'accessing'>
	tag := aNodeTag
    ]

    type [
	<category: 'accessing'>
	^tag type
    ]
]



XPPTagEvent subclass: XPPEndTag [
    
    <category: 'XMLPullParser'>
    <comment: nil>

    isEndTag [
	<category: 'testing'>
	^true
    ]

    isEndTag: aStringOrNodeTag [
	<category: 'testing'>
	^tag isLike: aStringOrNodeTag
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPutAll: ' </';
	    nextPutAll: tag asString;
	    nextPutAll: '>'
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    endElement: tag namespace
	    localName: tag type
	    qName: tag asString
    ]
]



XPPTagEvent subclass: XPPStartTag [
    | attributes attrArray |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    XPPStartTag class >> tag: tag attributesArray: a [
	<category: 'instance creation'>
	^(super tag: tag) attributesArray: a
    ]

    XPPStartTag class >> tag: tag attributes: a [
	<category: 'instance creation'>
	^(super tag: tag) attributes: a
    ]

    at: attName [
	<category: 'accessing'>
	^self at: attName
	    ifNone: 
		[XPPStructureException 
		    raiseSignal: 'Expected attribute ' , attName , ' is missing']
    ]

    at: attName ifFound: aFoundBlock ifNone: aBlock [
	<category: 'accessing'>
	attributes at: attName ifPresent: [ :value | ^aFoundBlock value: value].
	^aBlock value
    ]

    at: attName ifNone: aBlock [
	<category: 'accessing'>
	^attributes at: attName asString ifAbsent: [aBlock value]
    ]

    attributesArray [
	<category: 'accessing'>
	^attrArray
    ]

    attributes [
	<category: 'accessing'>
	^attributes
    ]

    attributesArray: anObject [
	<category: 'accessing'>
	attrArray := anObject.
	attributes := LookupTable new.
	attrArray do: [ :each | attributes at: each key name put: each value ].

    ]

    attributes: anObject [
	<category: 'accessing'>
	attributes := anObject.
	attrArray := OrderedCollection new.
	attributes keysAndValuesDo: [ :key :value |
	    attrArray add: (Attribute name: key value: value) ].
    ]

    isStartTag [
	<category: 'testing'>
	^true
    ]

    isStartTag: aStringOrNodeTag [
	<category: 'testing'>
	^tag isLike: aStringOrNodeTag
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream
	    nextPutAll: ' <';
	    nextPutAll: tag asString;
	    nextPutAll: '>'
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    startElement: tag namespace
	    localName: tag type
	    qName: tag asString
	    attributes: attrArray
    ]
]



XPPEvent subclass: XPPText [
    | text |
    
    <category: 'XMLPullParser'>
    <comment: nil>

    XPPText class >> text: aString [
	<category: 'instance creation'>
	^self new text: aString
    ]

    isText [
	<category: 'testing'>
	^true
    ]

    serializeTo: serializer [
	<category: 'serializing'>
	serializer 
	    characters: text
	    from: 1
	    to: text size
    ]

    text [
	<category: 'accessing'>
	^text
    ]

    text: aString [
	<category: 'accessing'>
	text := aString
    ]
]
