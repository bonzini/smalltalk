SAXParser subclass: ExpatXMLParser [
    | pullParser |
    
    <comment: 'A push parser based on Expat.  This uses the pull
parser and serializes the events to the SAX driver.'>
    <category: 'XML-XML-Parsing'>

    ExpatXMLParser class >> pullParserOn: dataSource [
	"Use the expat pull parser directly, without going through
	 pull on push on pull. :-)"

	^ExpatXMLPullParser on: dataSource
    ]

    on: dataSource [
	"The dataSource may be a URI, a Filename (or a String
	 which will be treated as a Filename), or an InputSource."

	<category: 'initialize'>
	super on: dataSource.

	"As the underlying parser we use the event-based Expat bindings.
	 We need to get all the events in order to pass them to the user's
	 own driver."
	pullParser := ExpatXMLPullParser on: dataSource.
	pullParser needComments: true.
	pullParser needDTDEvents: true.
	pullParser needCdataDelimiters: true.
	pullParser needPrefixMappingEvents: true.
    ]

    scanDocument [
	"Serialize the events from the pull parser to the SAX driver."

	<category: 'api'>
	[pullParser do: [ :event | event serializeTo: sax]]
		on: XMLResolveEntityNotification
		do: [ :e | e resume:
		    (sax resolveEntity: e publicID systemID: e systemID) ];

		on: MalformedSignal, BadCharacterSignal
		do: [ :e | sax fatalError: e ];

		on: InvalidSignal
		do: [ :e | sax nonFatalError: e ];

		on: WarningSignal
		do: [ :e | sax warning: e ]
    ]
]


Eval [
    SAXParser defaultParserClass isNil
	ifTrue: [SAXParser defaultParserClass: ExpatXMLParser].
]

