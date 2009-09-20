XMLPullParserTest subclass: ExpatXMLPullParserTest [
    
    <comment: 'I test the expat pull parser directly.'>
    <category: 'ExpatPullParser'>

    parserOn: source [
	<category: 'instance creation'>
	^ExpatXMLPullParser onString: source.
    ]
]

XMLPullParserTest subclass: ExpatXMLParserTest [
    
    <comment: 'I test the expat push parser by wrapping it again
with the generator-based generic pull parser.'>
    <category: 'ExpatPullParser'>

    parserOn: source [
	<category: 'instance creation'>
	^XMLGenerativePullParser
	    onParser: (ExpatXMLParser onString: source)
    ]
]

