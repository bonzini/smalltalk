OBBrowser subclass: OBFakeBrowser [
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    cmdBeZ [
	^(OBPluggableCommand new)
	    label: 'become z';
	    active: [:node :col | col isSelected: node];
	    action: 
		    [:node :col | 
		    node beZ.
		    node announceChangedWith: col];
	    yourself
    ]

    cmdCreateZ [
	^(OBPluggableCommand new)
	    label: 'create z';
	    action: [:node :col | node createZ announceSelectionWith: col];
	    active: [:node :col | (col isSelected: node) not];
	    yourself
    ]

    cmdDelete [
	^(OBPluggableCommand new)
	    label: 'delete';
	    action: 
		    [:node :col | 
		    node delete.
		    node announceDeletionWith: col];
	    active: [:node :col | col isSelected: node];
	    yourself
    ]

    cmdDeleteRoot [
	^(OBPluggableCommand new)
	    label: 'delete root';
	    action: [:node :col | node root announceDeletionWith: col];
	    active: [:node :col | col isSelected: node];
	    yourself
    ]
]



OBBrowser subclass: OBFakeCommandBrowser [
    | action |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    OBFakeCommandBrowser class >> defaultMetaNode [
	<category: 'defaults'>
	^OBFakeNode metagraph
    ]

    OBFakeCommandBrowser class >> defaultRootNode [
	<category: 'defaults'>
	^OBFakeNode new
    ]

    OBFakeCommandBrowser class >> withAction: aBlock [
	| browser |
	browser := self basicNew initialize.
	browser action: aBlock.
	self panels do: [:ea | browser addPanel: ea].
	browser setMetaNode: self defaultMetaNode node: self defaultRootNode.
	^browser
    ]

    action [
	<category: 'accessing'>
	^action
    ]

    action: aBlock [
	<category: 'accessing'>
	action := aBlock
    ]

    cmdObsolete [
	^OBPluggableCommand action: action
    ]

    cmdPluggable [
	^OBPluggableCommand action: action
    ]

    obsoleteCmd [
	^#cmdObsolete
    ]
]



OBNode subclass: OBFake2Node [
    | name children |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    OBFake2Node class >> metagraph [
	<category: 'running'>
	| root |
	root := OBMetaNode named: 'Fake2'.
	root childAt: #children put: root.
	^root
    ]

    OBFake2Node class >> tree: anObject [
	| children token |
	anObject isSymbol 
	    ifTrue: 
		[token := anObject.
		children := #()]
	    ifFalse: 
		[token := anObject first.
		children := anObject second].
	^self basicNew setName: token children: children
    ]

    = aNode [
	<category: 'comparing'>
	^self name = aNode name
    ]

    children [
	<category: 'accessing'>
	^children
    ]

    hash [
	<category: 'comparing'>
	^name hash
    ]

    isAncestorOf: aNode using: aSelector [
	<category: 'ancestry'>
	^self = aNode or: [children anySatisfy: [:ea | ea isAncestorOf: aNode]]
    ]

    name [
	<category: 'public'>
	^name
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: 'Fake2<';
	    nextPutAll: name;
	    nextPut: $>
    ]

    setName: aSymbol children: anArray [
	<category: 'initialize-release'>
	name := aSymbol.
	children := anArray collect: [:ea | self class tree: ea].
    ]
]



OBNode subclass: OBFakeNode [
    | item parent children |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    OBFakeNode class >> metagraph [
	<category: 'browsing'>
	| fake |
	fake := OBMetaNode new.
	fake childAt: #children put: fake.
	^fake
    ]

    OBFakeNode class >> parent: aFakeNode item: aString [
	<category: 'instance creation'>
	^(self new)
	    parent: aFakeNode;
	    item: aString
    ]

    = aNode [
        <category: 'comparing'>
        ^self class = aNode class and: [self name = aNode name]
    ]

    adopt: aNode [
	<category: 'public'>
	aNode parent removeChild: aNode.
	aNode parent: self.
	children := self children copyWith: aNode.
	^aNode
    ]

    beZ [
	<category: 'actions'>
	item := 'z'
    ]

    childX [
	<category: 'public'>
	^Array with: (OBFakeNode parent: self item: #x)
    ]

    children [
	<category: 'public'>
	^children ifNil: 
		[children := (self item endsWith: 'c') 
			    ifTrue: [Array new]
			    ifFalse: 
				[#($a $b $c) collect: [:i | OBFakeNode parent: self item: i asString]]]
    ]

    createZ [
	<category: 'actions'>
	^self adopt: (OBFakeNode parent: self item: 'z')
    ]

    delete [
	<category: 'actions'>
	parent ifNotNil: [parent removeChild: self]
    ]

    dropOnFakeNode: aNode [
	<category: 'drag and drop'>
	aNode adopt: self.
	aNode signalSelection
    ]

    dropSelector [
	<category: 'drag and drop'>
	^#dropOnFakeNode:
    ]

    hash [
	<category: 'comparing'>
	^self name hash
    ]

    isAncestorOf: aNode using: aSelector [
	<category: 'public'>
	| current |
	current := aNode.
	[current isNil] whileFalse: 
		[current = self ifTrue: [^true].
		current := current parent].
	^false
    ]

    item [
	<category: 'private'>
	^item ifNil: [item := '']
    ]

    item: aSymbol [
	<category: 'private'>
	item := aSymbol
    ]

    name [
	<category: 'public'>
	^self parentName , self item
    ]

    noChildren [
	<category: 'public'>
	^#()
    ]

    parent [
	<category: 'private'>
	^parent
    ]

    parent: aFakeNode [
	<category: 'private'>
	parent := aFakeNode
    ]

    parentName [
	<category: 'private'>
	^parent ifNil: [''] ifNotNil: [parent name]
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: 'FakeNode<';
	    nextPutAll: self name;
	    nextPut: $>
    ]

    removeChild: aFakeNode [
	<category: 'private'>
	children := self children copyWithout: aFakeNode
    ]

    root [
	<category: 'public'>
	| node |
	node := self parent.
	[node parent notNil] whileTrue: [node := node parent].
	^node
    ]

    text [
	<category: 'public'>
	^self name
    ]

    text: aText [
	<category: 'public'>
	self item: (aText asString allButFirst: self parentName size).
	self demandSelection.
	^true
    ]
]



TestCase subclass: OBAnnouncerTest [
    | announcer |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    testBlock [
	<category: 'tests'>
	| announcement |
	announcer := OBAnnouncer new.
	announcer observe: OBSelectionChanged do: [:arg | announcement := arg].
	announcer announce: OBSelectionChanged.
	self assert: (announcement isKindOf: OBSelectionChanged)
    ]

    testInstance [
	<category: 'tests'>
	| announcement |
	announcer := OBAnnouncer new.
	announcer observe: OBSelectionChanged do: [:arg | announcement := arg].
	announcer announce: OBSelectionChanged new.
	self assert: (announcement isKindOf: OBSelectionChanged)
    ]

    testMessage [
	<category: 'tests'>
	| announcement |
	announcer := OBAnnouncer new.
	announcer 
	    observe: OBSelectionChanged
	    send: #value:
	    to: [:ann | announcement := ann].
	announcer announce: OBSelectionChanged.
	self assert: (announcement isKindOf: OBSelectionChanged)
    ]
]



TestCase subclass: OBBrowserCommandsTest [
    | browser |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    test01ScanFindsCommandCreationMethods [
	<category: 'tests'>
	| called scan |
	called := false.
	browser := OBFakeCommandBrowser withAction: [called := true].
	scan := browser announce: OBNodeCommandScan.
	(scan commandsOn: nil for: nil) first execute.
	self assert: called
    ]

    test02CommandSelectorsFindsCommands [
	<category: 'tests'>
	browser := OBFakeCommandBrowser new.
	self assert: (browser commandSelectors includes: #cmdPluggable)
    ]

    test03CommandSelectorsFindsCommands [
	<category: 'tests'>
	browser := OBFakeCommandBrowser new.
	self deny: (browser commandSelectors includes: #cmdObsolete)
    ]
]



TestCase subclass: OBBrowserTest [
    | model widget |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    OBBrowserTest class >> isAbstract [
	<category: 'testing'>
	^self name = #OBBrowserTest
    ]

    assertAListIncludes: anArrayOfStrings [
	<category: 'asserting'>
	self listMorphs detect: 
		[:m | 
		| list |
		list := m getListDelicately collect: [:ea | ea asString trimSeparators].
		list includesAllOf: anArrayOfStrings]
	    ifNone: [self assert: false]
    ]

    assertAListMatches: strings [
	<category: 'asserting'>
	| list |
	self listMorphs detect: 
		[:m | 
		list := m getListDelicately.
		list size = strings size and: [list includesAllOf: strings]]
	    ifNone: [self assert: false]
    ]

    assertButtonSelected: aString [
	<category: 'asserting'>
	| button |
	button := (self morphsOfClass: OBFakeButton) 
		    detect: [:m | m label contents = aString]
		    ifNone: [self signalFailure: 'No button labeled ' , aString].
	self assert: button isOn
    ]

    assertCurrentItemIs: expected [
	<category: 'asserting'>
	| actual |
	actual := self currentItem trimSeparators.
	self assert: actual = expected
    ]

    assertListAt: index contains: items [
	<category: 'asserting'>
	| list |
	list := self listItemsAt: index.
	self assert: list size = items size.
	self assert: (list includesAllOf: items)
    ]

    assertListAt: index includes: items [
	<category: 'asserting'>
	| list |
	list := (self listItemsAt: index) 
		    collect: [:ea | ea asString trimSeparators].
	self assert: (list includesAllOf: items)
    ]

    assertMenuContains: aString [
	<category: 'asserting'>
	| item |
	item := self menuItemNamed: aString.
	self assert: item notNil
    ]

    assertNoButtonsVisible [
	<category: 'asserting'>
	self 
	    assert: ((widget findDeeplyA: OBFakeScroller) findDeeplyA: OBFakeButton) 
		    isNil
    ]

    assertSelectedTextIs: aString [
	<category: 'asserting'>
	| text selection |
	widget := self textMorph.
	text := widget text.
	selection := widget selectionInterval.
	self assert: (text atAll: selection) asString = aString
    ]

    assertTextIs: aString [
	<category: 'asserting'>
	| actual |
	actual := self textMorph text.
	self assert: actual = aString
    ]

    assertTextIsSelected [
	<category: 'asserting'>
	self assert: self textMorph getSelection size = self textMorph text size
    ]

    browserClass [
	<category: 'configuration'>
	self subclassResponsibility
    ]

    clickButtonLabeled: aString [
	<category: 'simulating'>
	| button |
	button := (self morphsOfClass: OBFakeButton) 
		    detect: [:m | m label contents = aString]
		    ifNone: [self signalFailure: 'No button labeled ' , aString].
	button click
    ]

    currentItem [
	<category: 'examining'>
	^self currentList selection asString
    ]

    currentList [
	<category: 'examining'>
	^self listMorphs reverse detect: [:list | list selection notNil]
	    ifNone: [self signalFailure: 'No item is currently selected']
    ]

    denyAListIncludes: anArrayOfStrings [
	<category: 'asserting'>
	self listMorphs 
	    detect: [:m | m getListDelicately includesAllOf: anArrayOfStrings]
	    ifNone: [^self].
	self assert: false
    ]

    deselect: aString [
	<category: 'simulating'>
	| listMorph |
	listMorph := self findListContaining: aString.
	listMorph changeModelSelection: 0
    ]

    drag: aString [
	<category: 'simulating'>
	| list |
	list := self findListContaining: aString.
	^list model dragPassengerFor: aString
    ]

    drag: passangerName to: targetName [
	<category: 'simulating'>
	| passanger |
	passanger := self drag: passangerName.
	self drop: passanger on: targetName
    ]

    drop: aPassenger on: targetName [
	<category: 'simulating'>
	| list |
	list := self findListContaining: targetName.
	self assert: list notNil.
	self assert: (list canDrop: aPassenger on: targetName).
	list drop: aPassenger on: targetName
    ]

    editText: aString [
	<category: 'simulating'>
	self textMorph text: aString
    ]

    findListContaining: aString [
	<category: 'examining'>
	^self listMorphs detect: 
		[:m | 
		| list |
		list := m getListDelicately collect: [:ea | ea asString trimSeparators].
		list includes: aString]
	    ifNone: [nil]
    ]

    forceLayout [
	<category: 'simulating'>
	widget update
    ]

    listItemsAt: index [
	<category: 'examining'>
	^(self listMorphs at: index
	    ifAbsent: [self signalFailure: 'List ' , index asString , ' does not exist']) 
		getListDelicately
    ]

    listMorphs [
	<category: 'examining'>
	^self morphsOfClass: OBFakeList
    ]

    menuItemNamed: aString [
	<category: 'examining'>
	| lists current |
	lists := self listMorphs.
	current := lists reverse detect: [:list | list selection notNil].
	^(current getMenu: true) itemWithWording: aString
    ]

    metagraph [
	<category: 'running'>
	^self browserClass defaultMetaNode
    ]

    morphNamed: aString [
	<category: 'examining'>
	^widget findDeepSubmorphThat: [:m | m knownName = aString]
	    ifAbsent: [self signalFailure: aString , 'not found']
    ]

    morphsOfClass: aClass [
	<category: 'examining'>
	| found |
	found := OrderedCollection new.
	widget 
	    withAllChildrenDo: [:m | (m isMemberOf: aClass) ifTrue: [found add: m]].
	^found
    ]

    mouseMoveEventIn: name [
	<category: 'simulating'>
	| rect plm |
	plm := self findListContaining: name.
	rect := plm listMorph rectForRow: (plm getListDelicately indexOf: name).
	^MouseMoveEvent new 
	    setType: #mouseEnter
	    startPoint: rect center + (rect width @ 0)
	    endPoint: rect center
	    trail: #()
	    buttons: 4
	    hand: ActiveHand
	    stamp: Time millisecondClockValue
    ]

    node [
	<category: 'configuration'>
	self subclassResponsibility
    ]

    select: aString [
	"We don't use #getListDelicately because the user would have to scroll through the list
	 to find the item we're selecting, thus triggering updates to the list."

	<category: 'simulating'>
	| listMorph list |
	listMorph := self findListContaining: aString.
	self assert: listMorph notNil.
	listMorph model okToChange ifFalse: [^self].
	list := listMorph getListObtrusively 
		    collect: [:ea | ea asString trimSeparators].
	listMorph changeModelSelection: (list indexOf: aString)
    ]

    selectMenuItem: aString [
	<category: 'simulating'>
	| item |
	item := self menuItemNamed: aString.
	item 
	    ifNil: [self signalFailure: 'Menu item ''' , aString , ''' does not exist.'].
	item click
    ]

    selectSequence: aCollection [
	<category: 'simulating'>
	| plm |
	aCollection withIndexDo: 
		[:item :index | 
		plm := self listMorphs at: index.
		plm changeModelSelection: (plm getListObtrusively indexOf: item)]
    ]

    setText: aString [
	<category: 'simulating'>
	| textMorph |
	textMorph := self textMorph.
	textMorph
	    text: aString asText;
	    accept
    ]

    setUp [
	<category: 'running'>
	model := self browserClass metaNode: self metagraph node: self node.
	widget := OBFakeBuilder build: model.
	self forceLayout
    ]

    textMorph [
	<category: 'examining'>
	^(self morphsOfClass: OBFakeText) last
    ]
]



OBBrowserTest subclass: OBFakeBrowserTest [
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    browserClass [
	<category: 'constants'>
	^OBFakeBrowser
    ]

    metagraph [
	<category: 'running'>
	^OBFakeNode metagraph
    ]

    node [
	<category: 'running'>
	^OBFakeNode new
    ]

    paneCount [
	<category: 'constants'>
	^4
    ]

    testAcceptText [
	<category: 'testing'>
	self select: 'a'.
	self assertListAt: 1 contains: #('a' 'b' 'c').
	self assertListAt: 2 contains: #('aa' 'ab' 'ac').
	self assertTextIs: 'a'.
	self setText: 'x'.

	"This is a gratuitous refresh to make the test pass. It isn't necessary when the
	 browser is actually open. It's a deficiency of the test environment..."
	self listMorphs do: [:ea | ea update: #list].
	self assertListAt: 1 contains: #('x' 'b' 'c').
	self assertListAt: 2 contains: #('xa' 'xb' 'xc').
	self assertTextIs: 'x'
    ]

    testAction [
	<category: 'testing'>
	self select: 'a'.
	self selectMenuItem: 'become z'.
	self assertListAt: 1 contains: #('z' 'b' 'c')
    ]

    testConfirmAbandon [
	<category: 'testing'>
	self select: 'a'.
	self assertListAt: 1 contains: #('a' 'b' 'c').
	self assertListAt: 2 contains: #('aa' 'ab' 'ac').
	self assertTextIs: 'a'.
	self editText: 'x'.
	[self select: 'b'] on: OBConfirmationRequest
	    do: [:notification | notification cancel].
	self assertCurrentItemIs: 'a'.
	self assertTextIs: 'x'
    ]

    testConfirmClose [
	<category: 'testing'>
	| notification |
	self select: 'a'.
	self assertListAt: 1 contains: #('a' 'b' 'c').
	self assertListAt: 2 contains: #('aa' 'ab' 'ac').
	self assertTextIs: 'a'.
	self editText: 'x'.
	[widget close] on: OBConfirmationRequest do: [:ex | notification := ex].
	self deny: notification isNil
    ]

    testCreateWindow [
	<category: 'testing'>
	self assert: (widget isKindOf: OBFakeWindow).
	self assert: widget label = 'OmniBrowser'
    ]

    testDeleteB [
	<category: 'testing'>
	self select: 'b'.
	self selectMenuItem: 'delete'.
	self assertListAt: 1 contains: #('a' 'c').
	self assert: self listMorphs size = self paneCount.
	self assertTextIs: ''
    ]

    testDeleteRootNode [
	<category: 'testing'>
	self select: 'a'.
	self selectMenuItem: 'delete root'.
	self denyAListIncludes: #('a' 'b' 'c').
	self assertTextIs: ''
    ]

    testDeselectA [
	<category: 'testing'>
	self select: 'a'.
	self deselect: 'a'.
	self assertListAt: 1 contains: #('a' 'b' 'c').
	self assert: self listMorphs size = self paneCount.
	self assertTextIs: ''
    ]

    testDragAndDrop [
	<category: 'testing'>
	| node |
	self select: 'a'.
	node := self drag: 'ab'.
	self assert: (node isKindOf: OBFakeNode).
	self assert: node name = 'ab'.
	self drop: node on: 'c'.
	self assertListAt: 1 contains: #('a' 'b' 'c').
	self assertCurrentItemIs: 'c'.
	self assertTextIs: 'c'.
	self assertListAt: 2 contains: #('cb')
    ]

    testInitialDisplay [
	<category: 'testing'>
	self assert: self listMorphs size = self paneCount.
	self assertListAt: 1 contains: #('a' 'b' 'c').
	self assertTextIs: ''
    ]

    testPanes [
	<category: 'testing'>
	| scroller |
	self assert: (self morphsOfClass: OBFakeList) size = self paneCount.
	self assert: (self morphsOfClass: OBFakeText) size = 1.
	scroller := (self morphsOfClass: OBFakeScroller) anyOne.
	self assert: scroller children size = model navigationPanel minPanes
    ]

    testRefreshDirty [
	<category: 'testing'>
	self select: 'a'.
	self editText: 'x'.
	[self selectMenuItem: 'create z'] on: OBConfirmationRequest
	    do: 
		[:request | request cancel].
	model announcer announce: OBRefreshRequired new.
	self assertListAt: 1 contains: #('a' 'b' 'c' 'z').
	self assertCurrentItemIs: 'a'.
	self assertTextIs: 'x'
    ]

    testSelectA [
	<category: 'testing'>
	self select: 'a'.
	self assertListAt: 1 contains: #('a' 'b' 'c').
	self assertListAt: 2 contains: #('aa' 'ab' 'ac').
	self assertTextIs: 'a'
    ]

    testSelectC [
	<category: 'testing'>
	self select: 'c'.
	self assertListAt: 1 contains: #('a' 'b' 'c').
	self assertListAt: 2 contains: #().
	self assertTextIs: 'c'
    ]

    testSelectionPath [
	<category: 'testing'>
	self select: 'a'.
	self select: 'ab'.
	self assert: (model selectionPath collect: [:e | e item]) 
		    = (OrderedCollection with: 'a' with: 'b')
    ]
]



TestCase subclass: OBBuilderTest [
    | model |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    activate [
	<category: 'emulating'>
	
    ]

    announcer [
	<category: 'accessing'>
	^OBAnnouncer new
    ]

    browser [
	<category: 'building'>
	^OBBrowser metaNode: OBFakeNode metagraph node: OBFakeNode new
    ]

    build: aModel [
	<category: 'building'>
	^self builderClass build: aModel
    ]

    buildNavigationPanel [
	<category: 'building'>
	model := self browser.
	^self build: model navigationPanel
    ]

    buildWindow [
	<category: 'building'>
	model := self browser.
	^self build: model
    ]

    childNodes [
	<category: 'emulating'>
	^#(#a #b #c) 
	    collect: [:ea | (OBFake2Node tree: ea) metaNode: self metaNode]
    ]

    columnWithFilter [
	<category: 'accessing'>
	^OBColumn 
	    inPanel: self
	    metaNode: self metaNode
	    node: self
    ]

    displayString [
	<category: 'emulating'>
	^'test'
    ]

    isEnabled: aButton [
	<category: 'emulating'>
	^true
    ]

    isSelected: aButton [
	<category: 'emulating'>
	^false
    ]

    left [
	<category: 'emulating'>
	^Array with: self
    ]

    listForNode: aNode [
	<category: 'emulating'>
	^#(#a #b #c)
    ]

    metaNode [
	<category: 'emulating'>
	^(OBMetaNode named: 'testing')
	    childAt: #left put: (OBMetaNode named: 'Left');
	    childAt: #right put: (OBMetaNode named: 'Right');
	    addFilter: OBModalFilter new;
	    yourself
    ]

    metaNode: aMetanode [
	<category: 'emulating'>
	
    ]

    right [
	<category: 'emulating'>
	^Array with: self
    ]

    selectedNode [
	<category: 'emulating'>
	^OBFakeNode new
    ]

    selection [
	<category: 'emulating'>
	^1
    ]

    switch [
	<category: 'accessing'>
	model := OBSwitch inColumn: self.
	model filter: self.
	^model
    ]
]



TestCase subclass: OBCollectionNodeTest [
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    testAncestryOfDescendent [
	<category: 'tests'>
	| node |
	node := OBCollectionNode on: (Array with: (OBClassNode on: self class)).
	self 
	    assert: (node isAncestorOf: (OBMethodNode on: #testAncestryOfDescendent
			    inClass: self class))
    ]

    testAncestryOfNodeInCollection [
	<category: 'tests'>
	| node |
	node := OBCollectionNode on: (Array with: (OBClassNode on: self class)).
	self assert: (node isAncestorOf: (OBClassNode on: self class))
    ]
]



TestCase subclass: OBColumnPanelTest [
    | announcer |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    announcer [
	<category: 'accessing'>
	^announcer ifNil: [announcer := OBAnnouncer new]
    ]

    testJumpClearsSubsequentPanels [
	<category: 'tests'>
	| root panel second first |
	root := OBFake2Node tree: #(#a #(#b #(#c #(#d #e #(#f #(#g #h #i)))) #j)).
	first := OBFake2Node tree: #h.
	second := OBFake2Node tree: #b.
	panel := OBColumnPanel minPanes: 4 maxPanes: 4.
	panel browser: self.
	panel setMetaNode: OBFake2Node metagraph node: root.
	panel jumpTo: first.
	panel jumpTo: second.
	self assert: panel columns third isEmpty.
	self assert: panel columns fourth isEmpty
    ]

    testJumpToFakeC [
	<category: 'tests'>
	| root node panel |
	root := OBFakeNode parent: nil item: #a.
	node := OBFakeNode parent: (OBFakeNode parent: root item: #b) item: #c.
	panel := OBColumnPanel inBrowser: self.
	panel setMetaNode: OBFakeNode metagraph node: root.
	panel jumpTo: node.
	self assert: panel selectedNode = node
    ]

    testJumpToRootAsChild [
	<category: 'tests'>
	| root node panel |
	root := OBFake2Node tree: #(#b #(#a #b #c)).
	node := OBFake2Node tree: #b.
	panel := OBColumnPanel new.
	panel browser: self.
	panel setMetaNode: OBFake2Node metagraph node: root.
	panel jumpTo: node.
	self assert: panel selectedNode = node.
	self assert: (panel columns indexOf: panel currentColumn) = 1
    ]
]



TestCase subclass: OBColumnTest [
    | announcer column |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    addFactory: aBlock [
	<category: 'support'>
	| factory |
	factory := OBPluggableCommand action: aBlock.
	announcer observe: OBNodeCommandScan do: [:ann | ann addFactory: factory].
	^factory
    ]

    announce: aClass [
	<category: 'updating'>
	^announcer announce: aClass
    ]

    announcer [
	<category: 'emulating'>
	^announcer
    ]

    browser [
	<category: 'emulating'>
	^self
    ]

    clearAfter: aOBColumn [
	<category: 'emulating'>
	
    ]

    parentNode [
	<category: 'support'>
	| node |
	node := OBFakeNode parent: nil item: #a.
	node metaNode: OBFakeNode metagraph.
	^node
    ]

    parentNodeBrokenAutoselect [
	<category: 'support'>
	| node x |
	node := self parentNode.
	x := OBFakeNode metagraph.
	node metaNode childAt: #noChildren put: x.
	node metaNode autoSelect: x.
	^node
    ]

    parentNodeForColumn: aColumn [
	<category: 'emulating'>
	^OBFakeNode parent: nil item: 'b'
    ]

    parentNodeWithAutoselect [
	<category: 'support'>
	| node x |
	node := self parentNode.
	x := OBFakeNode metagraph.
	node metaNode childAt: #childX put: x.
	node metaNode autoSelect: x.
	^node
    ]

    parentNodeWithIcon [
	<category: 'support'>
	| node filter |
	node := self parentNode.
	filter := OBPluggableFilter new.
	filter icon: [:i :n | n item = 'b' ifTrue: [#test] ifFalse: [#blank]].
	node metaNode children first addFilter: filter.
	^node
    ]

    selectionChangedIn: anOBColumn [
	<category: 'emulating'>
	
    ]

    setUp [
	<category: 'support'>
	announcer := OBAnnouncer new.
	column := OBColumn 
		    inPanel: self
		    metaNode: OBFakeNode metagraph
		    node: (OBFakeNode parent: nil item: 'a')
    ]

    test01MenuIncludesCommands [
	<category: 'tests'>
	| menu invoked |
	invoked := false.
	(self addFactory: [invoked := true]) label: 'test service'.
	menu := OBFakeMenu new.
	column menu: menu.
	(menu itemWithWording: 'test service') click.
	self assert: invoked
    ]

    test02KeystrokeInvokesCommand [
	<category: 'tests'>
	| invoked |
	invoked := false.
	(self addFactory: [invoked := true]) keystroke: $s.
	column keystroke: $s from: nil.
	self assert: invoked
    ]

    test03SetParent [
	<category: 'tests'>
	column parent: self parentNode.
	self assert: column listSize = 3.
	self assert: column selection = 0
    ]

    test04AutoSelectNotFound [
	<category: 'tests'>
	column parent: self parentNodeBrokenAutoselect.
	self assert: column listSize = 3.
	self assert: column selection = 0
    ]

    test05AutoSelect [
	<category: 'tests'>
	column parent: self parentNodeWithAutoselect.
	self assert: column listSize = 4.
	self assert: column selection = 4
    ]

    test06Icon [
	<category: 'tests'>
	column parent: self parentNodeWithIcon.
	self assert: (column iconAt: 1) = #blank.
	self assert: (column iconAt: 2) = #test.
	self assert: (column iconAt: 3) = #blank
    ]
]



TestCase subclass: OBCommandTest [
    | service isSelected |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    OBCommandTest class >> isAbstract [
	^self name == #OBCommandTest
    ]

    OBCommandTest class >> shouldInheritSelectors [
	^true
    ]

    command [
	<category: 'support'>
	^self factory on: nil for: nil
    ]

    executeOn: target for: requestor [
	<category: 'support'>
	| command |
	command := self factory on: target for: requestor.
	^command execute
    ]

    isActiveOn: target for: requestor [
	<category: 'support'>
	| command |
	command := self factory on: target for: requestor.
	^command isActive
    ]

    isEnabledOn: target for: requestor [
	<category: 'support'>
	| command |
	command := self factory on: target for: requestor.
	^command isEnabled
    ]

    isSelected: aNode [
	<category: 'support'>
	^isSelected ifNil: [false]
    ]

    test01LabelIsString [
	<category: 'tests'>
	self assert: self command label isString
    ]

    test02HasCorrectKeystroke [
	<category: 'tests'>
	self assert: self command keystroke isNil
    ]

    test03DoesntWantButton [
	<category: 'tests'>
	self deny: self command wantsButton
    ]
]



TestCase subclass: OBDefinitionPanelTest [
    | announcer panel |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    announce: aClass [
	<category: 'emulating'>
	^announcer announce: aClass
    ]

    announcer [
	<category: 'emulating'>
	^announcer
    ]

    assertMenu: aMenu hasItemSending: aSelector [
	<category: 'support'>
	aMenu items anySatisfy: [:ea | ea selector = aSelector]
    ]

    menu [
	<category: 'support'>
	^(OBFakeBuilder build: panel) getMenu: false
    ]

    scanCommands: ann [
	<category: 'emulating'>
	ann 
	    addFactory: ((OBPluggableService action: 
			[:node | 
			self assert: (node isKindOf: OBTextSelection)]) 
		    label: 'test')
    ]

    setUp [
	<category: 'support'>
	announcer := OBAnnouncer new.
	panel := OBDefinitionPanel inBrowser: self
    ]

    test01MenuHasEditingItems [
	<category: 'tests'>
        | menu |
        menu := self menu.
        self assertMenu: menu hasItemSending: #find.
        self assertMenu: menu hasItemSending: #findAgain.
        self assertMenu: menu hasItemSending: #setSearchString.
        self assertMenu: menu hasItemSending: #again.
        self assertMenu: menu hasItemSending: #undo.
        self assertMenu: menu hasItemSending: #copySelection.
        self assertMenu: menu hasItemSending: #cut.
        self assertMenu: menu hasItemSending: #paste.
        self assertMenu: menu hasItemSending: #pasteRecent.
        self assertMenu: menu hasItemSending: #accept.
        self assertMenu: menu hasItemSending: #cancel
    ]

    test02MenuIncludesCommands [
	<category: 'tests'>
	| menu |
	announcer observe: OBTextCommandScan
	    do: [:ann | ann addFactory: (OBPluggableCommand new label: 'test')].
	menu := self menu.
	self deny: (menu itemWithWording: 'test') isNil
    ]

    test03CommandsGetExecuted [
	<category: 'tests'>
	| menu executed |
	executed := false.
	announcer observe: OBTextCommandScan
	    do: 
		[:ann | 
		ann 
		    addFactory: ((OBPluggableCommand action: [executed := true]) label: 'test')].
	menu := self menu.
	(menu itemWithWording: 'test') click.
	self assert: executed
    ]

    test04InactiveCommandsAreHidden [
	<category: 'tests'>
	| menu |
	announcer observe: OBTextCommandScan
	    do: 
		[:ann | 
		ann 
		    addFactory: ((OBPluggableCommand action: [] active: [false]) label: 'test')].
	menu := self menu.
	self assert: (menu itemWithWording: 'test') isNil
    ]

    test05SilentChangeAllowedIfNotDirty [
	<category: 'tests'>
	| ann |
	ann := announcer announce: OBAboutToChangeSilently.
	self deny: ann isVetoed
    ]

    test06SilentChangeVetoedIfDirty [
	<category: 'tests'>
	| ann morph |
	morph := OBFakeBuilder build: panel.
	panel definition: (OBTextDefinition text: 'foo').
	morph text: 'bar'.
	ann := announcer announce: OBAboutToChangeSilently.
	self assert: ann isVetoed
    ]
]



TestCase subclass: OBFanTest [
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    filterNodes: aCollection showingB: aBoolean [
	<category: 'support'>
	^aBoolean 
	    ifTrue: [aCollection]
	    ifFalse: [aCollection reject: [:ea | ea name first = $b]]
    ]

    testAncestorOfIn [
	<category: 'tests'>
	| root twig leaf ancestor |
	root := OBFakeNode parent: nil item: #a.
	root metaNode: OBFakeNode metagraph.
	twig := OBFakeNode parent: root item: #b.
	leaf := OBFakeNode parent: twig item: #c.
	ancestor := root asFan ancestorOf: leaf in: [:i | self assert: i = 2].
	self assert: ancestor = twig
    ]

    testAncestorOfSelf [
	<category: 'tests'>
	| root leaf ancestor |
	root := OBFake2Node tree: #(#b #(#a #b #c)).
	leaf := OBFake2Node tree: #b.
	root metaNode: OBFake2Node metagraph.
	ancestor := root asFan ancestorOf: leaf in: [:i | self assert: i = 2].
	self assert: ancestor = leaf
    ]

    testAncestorWithFilter [
	<category: 'tests'>
	| root leaf ancestor filter parent child show fan |
	show := false.
	root := OBFake2Node tree: #(#r #(#(#a #()) #(#b #(#d #e #f)) #c)).
	leaf := OBFake2Node tree: #e.
	filter := (OBPluggableFilter new)
		    nodes: [:nodes :ignored | self filterNodes: nodes showingB: show];
		    note: 
			    [:p :c | 
			    parent := p.
			    child := c.
			    show := true];
		    yourself.
	root metaNode: (OBFake2Node metagraph addFilter: filter).
	fan := root asFan.
	ancestor := fan ancestorOf: leaf in: [:i | self assert: i = 2].
	self assert: ancestor name = #b.
	self assert: parent == root.
	self assert: child == ancestor.
	self assert: (fan children at: 2) == ancestor
    ]
]



TestCase subclass: OBMetaNodeTest [
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    children [
	<category: 'callbacks'>
	^#(#a #b #c) collect: [:ea | OBFakeNode parent: nil item: ea]
    ]

    left [
	<category: 'callbacks'>
	^#(#a #b #c) collect: [:ea | OBFakeNode parent: nil item: ea]
    ]

    metaNodeFilter: aSelector do: aBlock [
	<category: 'support'>
	| metanode filter |
	metanode := OBMetaNode named: 'root'.
	filter := OBPluggableFilter new perform: aSelector with: aBlock.
	metanode addFilter: filter.
	^metanode
    ]

    right [
	<category: 'callbacks'>
	^#(#d #e #f) collect: [:ea | OBFakeNode parent: nil item: ea]
    ]

    setMetaNode: aMetanode [
	<category: 'emulating'>
	
    ]

    testChildrenForNode [
	<category: 'tests'>
	| root child nodes |
	root := OBMetaNode named: 'root'.
	child := OBMetaNode named: 'child'.
	root - #children -> child.
	nodes := root childrenForNode: self.
	self assert: nodes size = 3.
	self assert: (nodes allSatisfy: [:ea | ea class == OBFakeNode]).
	self assert: (nodes collect: [:ea | ea item]) = #(#a #b #c)
    ]

    testConstruction [
	<category: 'tests'>
	| root child |
	root := OBMetaNode named: 'root'.
	child := OBMetaNode named: 'child'.
	root - #children -> child.
	self assert: root children anyOne == child.
	self assert: root edges anyOne selector = #children
    ]

    testConstructionWithLabel [
	<category: 'tests'>
	| root child edge |
	root := OBMetaNode named: 'root'.
	child := OBMetaNode named: 'child'.
	(root - #children) / 'kids' -> child.
	edge := root edges anyOne.
	self assert: root children anyOne == child.
	self assert: edge selector = #children.
	self assert: edge label = 'kids'
    ]

    testFiltersCanAddIcon [
	<category: 'tests'>
	| root result |
	root := self metaNodeFilter: #icon: do: [:icon :node | #testIcon].
	result := root iconForNode: self.
	self assert: result = #testIcon
    ]

    testFiltersCanAlterDisplayStrings [
	<category: 'tests'>
	| root name result |
	name := 'this name was changed'.
	root := self metaNodeFilter: #nodeDisplay: do: [:string :node | name].
	root displaySelector: #yourself.
	result := root displayStringForNode: self.
	self assert: result = name
    ]

    testFiltersCanChooseEdges [
	<category: 'tests'>
	| root nodes left right |
	root := self metaNodeFilter: #edges: do: [:edges :node | edges allButLast].
	left := OBMetaNode named: 'left'.
	right := OBMetaNode named: 'right'.
	root - #left -> left.
	root - #right -> right.
	nodes := root childrenForNode: self.
	self assert: (nodes collect: [:ea | ea item]) = #(#a #b #c)
    ]

    testFiltersCanChooseNodes [
	<category: 'tests'>
	| root nodes left right |
	root := self metaNodeFilter: #nodes: do: [:edges :node | edges allButLast].
	left := OBMetaNode named: 'left'.
	right := OBMetaNode named: 'right'.
	root - #left -> left.
	root - #right -> right.
	nodes := root childrenForNode: self.
	self assert: (nodes collect: [:ea | ea item]) = #(#a #b #d #e)
    ]

    testNodesForParent [
	<category: 'tests'>
	| root child nodes |
	root := OBMetaNode named: 'root'.
	child := OBMetaNode named: 'child'.
	root - #children -> child.
	nodes := root nodesForParent: self.
	self assert: nodes size = 3.
	self assert: (nodes allSatisfy: [:ea | ea class == OBFakeNode]).
	self assert: (nodes collect: [:ea | ea item]) = #(#a #b #c)
    ]
]



TestCase subclass: OBOpenTest [
    | browser |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    OBOpenTest class >> isAbstract [
	<category: 'testing'>
	^self name = #OBOpenTest
    ]

    create: aBlock [
	<category: 'actions'>
	self shouldnt: [browser := aBlock value] raise: OBBrowseRequest
    ]

    open: aBlock [
	<category: 'actions'>
	[aBlock value] on: OBBrowseRequest do: [:n | browser := n browser].
	self assert: browser notNil
    ]
]



OBOpenTest subclass: OBLibraryOpenTest [
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    metagraph [
	<category: 'accessing'>
	| fake |
	fake := OBMetaNode new.
	fake childAt: #children put: fake.
	^fake
    ]

    testGraphRootSelection [
	<category: 'tests'>
	| parent child |
	parent := OBFakeNode parent: nil item: 'parent'.
	child := OBFakeNode parent: parent item: 'a'.
	self create: 
		[OBBrowser 
		    metaNode: self metagraph
		    root: parent
		    selection: child].
	self shouldnt: [browser navigationPanel] raise: Error
    ]

    testGraphRootSelectionPanels [
	<category: 'tests'>
	| parent child panels |
	parent := OBFakeNode parent: nil item: 'parent'.
	child := OBFakeNode parent: parent item: 'a'.
	panels := Array with: OBColumnPanel new with: OBDefinitionPanel new.
	self create: 
		[OBBrowser 
		    metaNode: self metagraph
		    root: parent
		    selection: child
		    panels: panels].
	self assert: browser navigationPanel minPanes = 1.
	self assert: browser navigationPanel maxPanes = 1.
	self assert: browser root = parent.
	self assert: browser currentNode = child.
	self assert: browser panels size = panels size.
	self assert: (browser panels includesAllOf: panels)
    ]
]



TestCase subclass: OBPluggableCommandTest [
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    height [
	<category: 'emulating'>
	^16
    ]

    test01ExecuteEvaluatesAction [
	<category: 'tests'>
	| called factory command |
	called := false.
	factory := OBPluggableCommand action: [called := true].
	command := factory on: nil for: nil.
	command execute.
	self assert: called
    ]

    test02ActionCanBeAMessageSend [
	<category: 'tests'>
	| called factory send command |
	called := false.
	send := DirectedMessage receiver: [called := true] selector: #value.
	factory := OBPluggableCommand action: send.
	command := factory on: nil for: nil.
	command execute.
	self assert: called
    ]

    test03ActionReceivesRequestor [
	<category: 'tests'>
	| factory requestor command |
	requestor := nil.
	factory := OBPluggableCommand action: [:arg1 :arg2 | requestor := arg2].
	command := factory on: nil for: self.
	command execute.
	self assert: requestor == self
    ]

    test03ActionRecievesNode [
	<category: 'tests'>
	| factory node command |
	node := nil.
	factory := OBPluggableCommand action: [:arg1 :arg2 | node := arg1].
	command := factory on: self for: nil.
	command execute.
	self assert: node == self
    ]

    test04ConditionExecutesByDefault [
	<category: 'tests'>
	| factory command |
	factory := OBPluggableCommand action: [].
	command := factory on: nil for: nil.
	self assert: command isActive
    ]

    test06MenuItemExecutesAction [
	<category: 'tests'>
	| menu factory called command |
	called := false.
	menu := OBFakeMenu new.
	factory := OBPluggableCommand action: [called := true].
	command := factory on: nil for: nil.
	command addItemToMenu: menu.
	menu items first click.
	self assert: called
    ]

    test07MenuItemEnabledByDefault [
	<category: 'tests'>
	| menu factory command |
	menu := OBFakeMenu new.
	factory := OBPluggableCommand new.
	command := factory on: nil for: nil.
	command addItemToMenu: menu.
	self assert: menu items first isEnabled
    ]

    test08MenuItemReflectsCondition [
	<category: 'tests'>
	| factory command |
	factory := OBPluggableCommand new enabled: [false].
	command := factory on: nil for: self.
	self deny: command isEnabled
    ]

    test09MenuReflectsLabel [
	<category: 'tests'>
	| menu factory command |
	menu := OBFakeMenu new.
	factory := OBPluggableCommand new label: 'a fine factory'.
	command := factory on: nil for: self.
	command addItemToMenu: menu.
	self assert: menu items first label = 'a fine factory'
    ]

    test10MenuDisplaysKeystroke [
	<category: 'tests'>
	| menu factory command |
	menu := OBFakeMenu new.
	factory := (OBPluggableCommand new)
		    label: 'a fine factory';
		    keystroke: $f.
	command := factory on: nil for: self.
	command addItemToMenu: menu.
	self assert: menu items first label = 'a fine factory (f)'
    ]

    test11MenuDisplaysIcon [
	<category: 'tests'>
	| menu factory pref command |
	pref := OBPlatform current menuWithIcons.
	
	[OBPlatform current enableGently: #menuWithIcons.
	menu := OBFakeMenu new.
	factory := (OBPluggableCommand new)
		    label: 'a fine factory';
		    icon: #deleteIcon.
	command := factory on: nil for: self.
	command addItemToMenu: menu.
	self assert: menu lastItem icon notNil] 
		ensure: [OBPlatform current setPreference: #menuWithIcons toValue: pref]
    ]

    test13CommandIsMenuOnlyByDefault [
	<category: 'tests'>
	| factory |
	factory := OBPluggableCommand new.
	self deny: factory wantsButton
    ]

    test14CommandWithButtonLabelWantsButton [
	<category: 'tests'>
	| factory |
	factory := OBPluggableCommand new.
	factory buttonLabel: 'serv'.
	self assert: factory wantsButton
    ]

    test15CondReceivesRequestor [
	<category: 'tests'>
	| factory requestor command |
	requestor := nil.
	factory := OBPluggableCommand action: [] active: [:n :r | requestor := r].
	command := factory on: factory for: self.
	command isActive.
	self assert: requestor == self
    ]

    width [
	<category: 'emulating'>
	^16
    ]
]



TestCase subclass: OBRescueFilterTest [
    | children filter |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    nodes: aCollection [
	| nodes |
	nodes := aCollection collect: [:ea | OBFakeNode parent: nil item: ea].
	^filter nodesFrom: nodes forNode: self
    ]

    testIsRescuedFrom [
	| label |
	filter := OBRescueFilter new.
	self nodes: #(#a #b #c).
	self nodes: #(#a #c).
	self assert: (filter isChild: (OBFakeNode parent: nil item: #b) rescuedFrom: self)
    ]

    testRescue [
	| first second |
	filter := OBRescueFilter new.
	first := self nodes: #(#a #b #c).
	second := self nodes: #(#a #c).
	self assert: first asSet = second asSet
    ]

    testSecondRescue [
	| second third |
	filter := OBRescueFilter new.
	self nodes: #(#a #b #c).
	second := self nodes: #(#a #c).
	third := self nodes: #(#a #c).
	self assert: second asSet = third asSet
    ]

    testUnrescue [
	| third first |
	filter := OBRescueFilter new.
	first := self nodes: #(#a #b #c).
	self nodes: #(#a #c).
	third := self nodes: #(#a #b #c).
	self assert: first = third
    ]
]



TestCase subclass: OBSubtreeTest [
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    test2Generations [
	| root leaf state |
	root := OBFakeNode parent: nil item: ''.
	root metaNode: OBFakeNode metagraph.
	leaf := OBFakeNode parent: root item: #b.
	state := (OBSubtree from: root to: leaf) state.
	self assert: state first parent = root.
	self assert: state second = 2.
	self assert: state third parent = leaf.
	self assert: state fourth = 0
    ]

    test3Generations [
	| root twig leaf state |
	root := OBFakeNode parent: nil item: ''.
	root metaNode: OBFakeNode metagraph.
	twig := OBFakeNode parent: root item: #a.
	leaf := OBFakeNode parent: twig item: #b.
	state := (OBSubtree from: root to: leaf) state.
	self assert: state first parent = root.
	self assert: state second = 1.
	self assert: state third parent = twig.
	self assert: state fourth = 2.
	self assert: state fifth parent = leaf.
	self assert: state sixth = 0
    ]

    test4Generations [
	| root twig leaf state branch |
	root := OBFakeNode parent: nil item: ''.
	root metaNode: OBFakeNode metagraph.
	branch := OBFakeNode parent: root item: #a.
	twig := OBFakeNode parent: branch item: #b.
	leaf := OBFakeNode parent: twig item: #c.
	state := (OBSubtree from: root to: leaf) state.
	self assert: state first parent = root.
	self assert: state second = 1.
	self assert: state third parent = branch.
	self assert: state fourth = 2.
	self assert: state fifth parent = twig.
	self assert: state sixth = 3.
	self assert: state seventh parent = leaf.
	self assert: state eighth = 0
    ]

    testChildOfMatchingRoot [
	| root leaf subtree state |
	root := OBFake2Node tree: #(#b #(#a #b #c)).
	leaf := OBFake2Node tree: #b.
	root metaNode: OBFake2Node metagraph.
	subtree := OBSubtree from: root to: leaf.
	state := subtree instVarNamed: 'state'.
	self assert: state size = 4.
	self assert: state first parent = root.
	self assert: state second = 2.
	self assert: state third parent = leaf.
	self assert: state fourth = 0
    ]

    testChildOfRoot [
	| root leaf subtree state |
	root := OBFake2Node tree: #(#b #(#a #b #c)).
	leaf := OBFake2Node tree: #b.
	root metaNode: OBFake2Node metagraph.
	subtree := OBSubtree from: root to: leaf.
	state := subtree instVarNamed: 'state'.
	self assert: state size = 4.
	self assert: state first parent = root.
	self assert: state second = 2.
	self assert: state third parent = leaf.
	self assert: state fourth = 0
    ]

    testNoAncestor [
	| root leaf subtree |
	root := OBFakeNode parent: nil item: ''.
	root metaNode: OBFakeNode metagraph.
	leaf := OBFakeNode parent: root item: #x.
	subtree := OBSubtree from: root to: leaf.
	self assert: subtree isNil
    ]
]



TestCase subclass: OBSwitchTest [
    | selection |
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    activate [
	<category: 'emulating'>
	selection := 1
    ]

    list [
	<category: 'emulating'>
	^#(#a #b #c #d #e)
    ]

    listChanged [
	<category: 'emulating'>
	
    ]

    listForNode: aNode [
	<category: 'emulating'>
	^self list
    ]

    selectedNode [
	<category: 'emulating'>
	^OBFakeNode new
    ]

    selection [
	<category: 'emulating'>
	^selection
    ]

    selection: anInteger [
	<category: 'emulating'>
	selection := anInteger
    ]

    switch [
	<category: 'support'>
	^OBSwitch inColumn: self
    ]

    testGetSelection [
	<category: 'tests'>
	| switch |
	switch := OBSwitch new.
	switch filter: self.
	selection := 2.
	self assert: switch selection = 2
    ]

    testList [
	<category: 'tests'>
	| switch |
	switch := self switch.
	switch filter: self.
	self assert: switch list = self list
    ]

    testSendsActivateToFilter [
	<category: 'tests'>
	| switch |
	switch := OBSwitch new.
	selection := 3.
	switch filter: self.
	self assert: selection = 1
    ]

    testSetSelection [
	<category: 'tests'>
	| switch |
	switch := OBSwitch inColumn: self.
	switch filter: self.
	switch selection: 5.
	self assert: selection = 5
    ]

    testSwitchIsActiveWhenItHasAFilter [
	<category: 'tests'>
	| switch |
	switch := OBSwitch new.
	switch filter: self.
	self assert: switch isActive
    ]

    testSwitchStartsInactive [
	<category: 'tests'>
	| switch |
	switch := OBSwitch new.
	self deny: switch isActive
    ]
]



TestCase subclass: OBTextSelectionTest [
    
    <comment: nil>
    <category: 'OB-Tests-Core'>

    test01Text [
	<category: 'tests'>
	| selection |
	selection := OBTextSelection on: (3 to: 5) inText: 'abcdefghijk'.
	self assert: selection text = 'cde'
    ]

    test02FullText [
	<category: 'tests'>
	| selection |
	selection := OBTextSelection on: (3 to: 5) inText: 'abcdefghijk'.
	self assert: selection fullText = 'abcdefghijk'
    ]

    test03Selector [
	<category: 'tests'>
	| selection text |
	text := 'self foo: #a bar: #b.  '.
	selection := OBTextSelection on: (1 to: text size) inText: text.
	self assert: selection selector = #foo:bar:
    ]
]
