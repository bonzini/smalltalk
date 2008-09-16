DirectedMessage extend [

    valueWithPossibleArgs: anArray [
	<category: '*omnibrowser-evaluating'>
	^receiver perform: selector withArguments: (self collectArguments: anArray)
    ]

]



Notification subclass: OBAnnouncerRequest [
    
    <category: 'OmniBrowser-Notifications'>
    <comment: nil>
]



Notification subclass: OBInteractionRequest [
    
    <category: 'OmniBrowser-Notifications'>
    <comment: 'OBInteractionRequest is an abstract superclass for notifications that request some interaction with the user. It''s useful for catching such notifications in an exception handler, while allowing other notifications to operate normally.'>

    defaultAction [
	<category: 'exceptionDescription'>
	^self handleWith: OBPlatform current
    ]

    handleWith: anObject [
	<category: 'dispatching'>
	self subclassResponsibility
    ]

    isBrowseRequest [
	<category: 'testing'>
	^false
    ]
]



OBInteractionRequest subclass: OBBrowseRequest [
    | browser |
    
    <category: 'OmniBrowser-Notifications'>
    <comment: 'This notification is raised whenever a browser needs to be opened. The default action is to open a SystemWindow in Morphic, but it can be caught in situations where that''s not appropriate. The OB test suite uses this extensively. '>

    OBBrowseRequest class >> signal: aBrowser [
	<category: 'exceptionInstantiator'>
	^(self new browser: aBrowser) signal
    ]

    browser [
	<category: 'accessing'>
	^browser
    ]

    browser: aBrowser [
	<category: 'accessing'>
	browser := aBrowser
    ]

    handleWith: anObject [
	<category: 'dispatching'>
	^anObject handleBrowseRequest: self
    ]

    isBrowseRequest [
	<category: 'testing'>
	^true
    ]
]



OBInteractionRequest subclass: OBChoiceRequest [
    | prompt labels values lines |
    
    <category: 'OmniBrowser-Notifications'>
    <comment: 'This notification is used to ask the user for to choose from a list of alternatives. Its defaultAction is to open a PopUpMenu. Test cases an intercept the notification and respond programmatically.

prompt	- A string describing the choice the user is asked to make.
labels	- A list of strings describing the alternatives.
values	- When the user chooses an alternative, the corresponding item from this list is returned'>

    OBChoiceRequest class >> labels: anArray [
	<category: 'exceptionInstantiator'>
	^self 
	    prompt: nil
	    labels: anArray
	    values: anArray
	    lines: #()
    ]

    OBChoiceRequest class >> labels: labelArray lines: lineArray [
	<category: 'exceptionInstantiator'>
	^self 
	    prompt: nil
	    labels: labelArray
	    values: labelArray
	    lines: lineArray
    ]

    OBChoiceRequest class >> prompt: aString labels: labelArray values: valueArray [
	<category: 'exceptionInstantiator'>
	^self 
	    prompt: aString
	    labels: labelArray
	    values: valueArray
	    lines: #()
    ]

    OBChoiceRequest class >> prompt: aString labels: labelArray values: valueArray lines: lineArray [
	<category: 'exceptionInstantiator'>
	^(self new 
	    setPrompt: aString
	    labels: labelArray
	    values: valueArray
	    lines: lineArray) signal
    ]

    handleWith: anObject [
	<category: 'dispatching'>
	^anObject handleChoiceRequest: self
    ]

    labels [
	<category: 'accessing'>
	^labels
    ]

    lines [
	<category: 'accessing'>
	^lines
    ]

    prompt [
	<category: 'accessing'>
	^prompt
    ]

    select: aString [
	<category: 'signaling'>
	| index |
	index := labels indexOf: aString.
	self resume: (values at: index ifAbsent: [nil])
    ]

    setPrompt: aString labels: labelArray values: valueArray lines: lineArray [
	<category: 'initializing'>
	prompt := aString.
	labels := labelArray.
	values := valueArray.
	lines := lineArray
    ]

    values [
	<category: 'accessing'>
	^values
    ]
]



OBInteractionRequest subclass: OBCloseRequest [
    | browser |
    
    <category: 'OmniBrowser-Notifications'>
    <comment: nil>

    OBCloseRequest class >> signal: aBrowser [
	<category: 'exceptionInstantiator'>
	^(self new browser: aBrowser) signal
    ]

    browser [
	<category: 'accessing'>
	^browser
    ]

    browser: aBrowser [
	<category: 'accessing'>
	browser := aBrowser
    ]

    handleWith: anObject [
	<category: 'dispatching'>
	^anObject handleCloseRequest: self
    ]
]



OBInteractionRequest subclass: OBConfirmationRequest [
    | prompt confirm cancel |
    
    <category: 'OmniBrowser-Notifications'>
    <comment: 'This notification is used to ask the user to confirm some kind potentially dangerous operation. Its default action is to open a PopUpMenu.

iVars:

prompt		- a string describing the situation the user is asked to confirm
confirm		- a string describing the action that will be taken if the user confirms
cancel		- a string describing the action that will be taken if the user does not confirm'>

    OBConfirmationRequest class >> newPrompt: prompt confirm: confirm cancel: cancel [
	<category: 'exceptionInstantiator'>
	^self new 
	    setPrompt: prompt
	    confirm: confirm
	    cancel: cancel
    ]

    OBConfirmationRequest class >> prompt: prompt [
	<category: 'exceptionInstantiator'>
	^self prompt: prompt confirm: 'Ok'
    ]

    OBConfirmationRequest class >> prompt: prompt confirm: confirm [
	<category: 'exceptionInstantiator'>
	^self 
	    prompt: prompt
	    confirm: confirm
	    cancel: 'Cancel'
    ]

    OBConfirmationRequest class >> prompt: prompt confirm: confirm cancel: cancel [
	<category: 'exceptionInstantiator'>
	^(self 
	    newPrompt: prompt
	    confirm: confirm
	    cancel: cancel) signal
    ]

    cancel [
	<category: 'responding'>
	^self resume: false
    ]

    cancelChoice [
	<category: 'accessing'>
	^cancel
    ]

    handleWith: anObject [
	<category: 'dispatching'>
	^anObject handleConfirmationRequest: self
    ]

    ok [
	<category: 'responding'>
	self resume: true
    ]

    okChoice [
	<category: 'accessing'>
	^confirm
    ]

    prompt [
	<category: 'accessing'>
	^prompt
    ]

    setPrompt: promptString confirm: confirmString cancel: cancelString [
	<category: 'initalizing'>
	prompt := promptString.
	confirm := confirmString.
	cancel := cancelString
    ]
]



OBInteractionRequest subclass: OBInformRequest [
    | message |
    
    <category: 'OmniBrowser-Notifications'>
    <comment: nil>

    OBInformRequest class >> message: aString [
	<category: 'exceptionInstantiator'>
	^((self new)
	    message: aString;
	    yourself) signal
    ]

    handleWith: anObject [
	<category: 'dispatching'>
	^anObject handleInformRequest: self
    ]

    message [
	<category: 'accessing'>
	^message
    ]

    message: aString [
	<category: 'accessing'>
	message := aString
    ]
]



OBInteractionRequest subclass: OBMultiLineTextRequest [
    | prompt template |
    
    <category: 'OmniBrowser-Notifications'>
    <comment: nil>

    OBMultiLineTextRequest class >> prompt: aString [
	<category: 'exceptionInstantiator'>
	^self prompt: aString template: ''
    ]

    OBMultiLineTextRequest class >> prompt: promptString template: templateString [
	<category: 'exceptionInstantiator'>
	^((self new)
	    prompt: promptString;
	    template: templateString) signal
    ]

    handleWith: anObject [
	<category: 'dispatching'>
	^anObject handleMultiLineTextRequest: self
    ]

    prompt [
	<category: 'accessing'>
	^prompt
    ]

    prompt: aString [
	<category: 'accessing'>
	prompt := aString
    ]

    template [
	<category: 'accessing'>
	^template
    ]

    template: aString [
	<category: 'accessing'>
	template := aString
    ]
]



OBInteractionRequest subclass: OBTextRequest [
    | prompt template |
    
    <category: 'OmniBrowser-Notifications'>
    <comment: 'This notification is used to ask the user to supply a short piece of text. Its defaultAction is to open a FillInTheBlank.

iVars:

prompt		- a string describing the text the user is asked to supply
template	- a default reply '>

    OBTextRequest class >> prompt: aString [
	<category: 'exceptionInstantiator'>
	^self prompt: aString template: ''
    ]

    OBTextRequest class >> prompt: promptString template: templateString [
	<category: 'exceptionInstantiator'>
	^((self new)
	    prompt: promptString;
	    template: templateString) signal
    ]

    handleWith: anObject [
	<category: 'dispatching'>
	^anObject handleTextRequest: self
    ]

    prompt [
	<category: 'accessing'>
	^prompt
    ]

    prompt: aString [
	<category: 'accessing'>
	prompt := aString
    ]

    template [
	<category: 'accessing'>
	^template
    ]

    template: aString [
	<category: 'accessing'>
	template := aString
    ]
]



OBObject subclass: OBAnnouncement [
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>
]



OBAnnouncement subclass: OBAboutToChange [
    | veto |
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>

    isVetoed [
	<category: 'vetos'>
	^veto notNil
    ]

    veto [
	<category: 'vetos'>
	veto := true
    ]
]



OBAnnouncement subclass: OBAboutToChangeSilently [
    | veto |
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>

    isVetoed [
	<category: 'vetos'>
	^veto notNil
    ]

    veto [
	<category: 'vetos'>
	veto := true
    ]
]



OBAnnouncement subclass: OBChildrenChanged [
    | node |
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>

    OBChildrenChanged class >> node: aNode [
	^self new node: aNode
    ]

    node [
	^node
    ]

    node: aNode [
	node := aNode
    ]
]



OBAnnouncement subclass: OBCommandScan [
    | factories |
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>

    addCommandsOn: aNode for: aRequestor to: aSet [
	<category: 'accessing'>
	| cmd |
	factories do: 
		[:ea | 
		cmd := ea on: aNode for: aRequestor.
		cmd isActive ifTrue: [aSet add: cmd]]
    ]

    addFactory: aCommandFactory [
	<category: 'accessing'>
	factories add: aCommandFactory
    ]

    clusterCommands: aCollection [
	<category: 'user interface'>
	| groups root name cluster |
	groups := IdentityDictionary new.
	root := OBCommandCluster new.
	aCollection do: 
		[:command | 
		name := command cluster.
		cluster := name ifNil: [root]
			    ifNotNil: [groups at: name ifAbsentPut: [command createCluster]].
		cluster addCommand: command].
	groups values do: [:ea | root addCommand: ea].
	^root
    ]

    commandsOn: aNode for: aRequestor [
	<category: 'accessing'>
	^factories collect: [:ea | ea on: aNode for: aRequestor]
    ]

    groupCommands: commands [
	<category: 'user interface'>
	| groups |
	groups := commands groupBy: [:svc | svc group]
		    having: [:group | group isEmpty not].
	groups := groups 
		    collect: [:ea | ea asArray sort: [:a :b | a label <= b label]].
	^groups asArray sort: [:a :b | a anyOne group <= b anyOne group]
    ]

    initialize [
	<category: 'initialize-release'>
	factories := OrderedCollection new
    ]

    populateMenu: aMenu withNodes: aCollection forRequestor: aRequestor [
	<category: 'user interface'>
	| commands cluster |
	commands := IdentitySet new.
	aCollection do: 
		[:node | 
		self 
		    addCommandsOn: node
		    for: aRequestor
		    to: commands].
	cluster := self clusterCommands: commands.
	cluster populateMenu: aMenu
    ]

    processKeystroke: aCharacter withNode: aNode for: aRequestor [
	<category: 'user interface'>
	| commands |
	commands := self commandsOn: aNode for: aRequestor.
	(commands select: [:cmd | cmd keystroke == aCharacter]) 
	    do: [:cmd | (cmd isActive and: [cmd isEnabled]) ifTrue: [cmd execute]]
    ]
]



OBCommandScan subclass: OBNodeCommandScan [
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>
]



OBCommandScan subclass: OBTextCommandScan [
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>
]



OBAnnouncement subclass: OBDefinitionChanged [
    | definition node |
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>

    OBDefinitionChanged class >> definition: aDefinition [
	^(self new)
	    definition: aDefinition;
	    yourself
    ]

    OBDefinitionChanged class >> node: aNode definition: aDefinition [
	^(self new)
	    node: aNode;
	    definition: aDefinition;
	    yourself
    ]

    definition [
	^definition
    ]

    definition: aDefinition [
	definition := aDefinition
    ]

    node [
	^node
    ]

    node: aNode [
	node := aNode
    ]
]



OBAnnouncement subclass: OBNodeChanged [
    | node |
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>

    OBNodeChanged class >> node: aNode [
	^self new node: aNode
    ]

    node [
	^node
    ]

    node: aNode [
	node := aNode
    ]
]



OBAnnouncement subclass: OBNodeCreated [
    | node |
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>

    OBNodeCreated class >> node: aNode [
	^self new node: aNode
    ]

    node [
	^node
    ]

    node: aNode [
	node := aNode
    ]
]



OBAnnouncement subclass: OBNodeDeleted [
    | node |
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>

    OBNodeDeleted class >> node: aNode [
	^self new node: aNode
    ]

    node [
	^node
    ]

    node: aNode [
	node := aNode
    ]
]



OBAnnouncement subclass: OBRefreshRequired [
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>
]



OBAnnouncement subclass: OBSelectingNode [
    | node |
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>

    OBSelectingNode class >> node: aNode [
	^self new node: aNode
    ]

    node [
	^node
    ]

    node: aNode [
	node := aNode
    ]
]



OBAnnouncement subclass: OBSelectionChanged [
    | node column deselectedNode |
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>

    OBSelectionChanged class >> column: aColumn [
	<category: 'instance creation'>
	^self new column: aColumn
    ]

    OBSelectionChanged class >> node: aNode [
	^self new node: aNode
    ]

    column [
	<category: 'accessing'>
	^column
    ]

    column: aColumn [
	<category: 'accessing'>
	column := aColumn
    ]

    deselectedNode [
	<category: 'accessing'>
	^deselectedNode
    ]

    deselectedNode: aNode [
	<category: 'accessing'>
	deselectedNode := aNode
    ]

    node [
	<category: 'accessing'>
	^column ifNil: [node] ifNotNil: [column selectedNode]
    ]

    node: aNode [
	<category: 'accessing'>
	node := aNode
    ]
]



OBObject subclass: OBAnnouncer [
    | subscriptions |
    
    <category: 'OmniBrowser-Announcements'>
    <comment: nil>

    OBAnnouncer class >> current [
	<category: 'instance creation'>
	^OBAnnouncerRequest signal
    ]

    OBAnnouncer class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    announce: anObject [
	<category: 'subscription'>
	| ann |
	ann := anObject asAnnouncement.
	subscriptions keysAndValuesDo: 
		[:class :actions | 
		(ann isKindOf: class) 
		    ifTrue: [actions do: [:each | each value: ann]]].
	^ann
    ]

    initialize [
	<category: 'initialize-release'>
	subscriptions := IdentityDictionary new
    ]

    observe: aClass do: aValuable [
	<category: 'subscription'>
	| actions |
	actions := subscriptions at: aClass ifAbsent: [Array new].
	subscriptions at: aClass put: (actions copyWith: aValuable)
    ]

    observe: aClass send: aSelector to: anObject [
	<category: 'subscription'>
	self observe: aClass
	    do: (DirectedMessage receiver: anObject selector: aSelector)
    ]

    unsubscribe: anObject [
	<category: 'subscription'>
	subscriptions keysAndValuesDo: 
		[:class :actions | 
		subscriptions at: class
		    put: (actions reject: [:ea | ea receiver == anObject])].
	subscriptions removeAllKeysSuchThat: [:key |
	    (subscriptions at: key) isEmpty]
    ]
]



OBObject subclass: OBBrowser [
    | panels announcer cmdFactories |
    
    <category: 'OmniBrowser-Kernel'>
    <comment: 'OBBrowser is the core of OmniBrower. It''s the root object for each browser and the model for the SystemWindows which display them. Its main responsibily is managing panels, particularly passing update messages between them.

On the class side, OBBrowser provides some default settings for creating and opening browsers. Subclasses can override these settings to acheive customized behavior.

iVars:

panels	- A collection of objects which manage submorphs of the browser''s SystemWindow.

cVars:

MetaGraphs - A dictionary matching names to metagraphs'>

    OBBrowser class >> defaultMetaNode [
	<category: 'configuration'>
	self subclassResponsibility
    ]

    OBBrowser class >> defaultRootNode [
	<category: 'configuration'>
	self subclassResponsibility
    ]

    OBBrowser class >> definitionPanel [
	<category: 'configuration'>
	^OBDefinitionPanel new
    ]

    OBBrowser class >> maxPanes [
	<category: 'configuration'>
	^self paneCount
    ]

    OBBrowser class >> metaNode: metaNode node: rootNode [
	<category: 'instance creation'>
	^self 
	    metaNode: metaNode
	    root: rootNode
	    selection: nil
	    panels: self panels
    ]

    OBBrowser class >> metaNode: metaNode root: rootNode selection: selectedNode [
	<category: 'instance creation'>
	^self 
	    metaNode: metaNode
	    root: rootNode
	    selection: selectedNode
	    panels: self panels
    ]

    OBBrowser class >> metaNode: metaNode root: rootNode selection: selectedNode panels: panels [
	<category: 'instance creation'>
	| browser |
	browser := self basicNew initialize.
	panels do: [:ea | browser addPanel: ea].
	browser setMetaNode: metaNode node: rootNode.
	selectedNode ifNotNil: [browser jumpTo: selectedNode].
	^browser
    ]

    OBBrowser class >> minPanes [
	<category: 'configuration'>
	^self paneCount
    ]

    OBBrowser class >> navigationPanel [
	<category: 'configuration'>
	^OBColumnPanel minPanes: self minPanes maxPanes: self maxPanes
    ]

    OBBrowser class >> new [
	<category: 'instance creation'>
	^self 
	    metaNode: self defaultMetaNode
	    root: self defaultRootNode
	    selection: nil
	    panels: self panels
    ]

    OBBrowser class >> open [
	<category: 'auto opening'>
	^self new open
    ]

    OBBrowser class >> openRoot: aNode [
	<category: 'auto opening'>
	^(self root: aNode) open
    ]

    OBBrowser class >> openRoot: rootNode selection: selectedNode [
	<category: 'auto opening'>
	^(self root: rootNode selection: selectedNode) open
    ]

    OBBrowser class >> optionalButtonPanel [
	<category: 'configuration'>
	^OBPlatform current optionalButtons ifTrue: [OBFixedButtonPanel new]
    ]

    OBBrowser class >> optionalButtons [
	<category: 'configuration'>
	^#()
    ]

    OBBrowser class >> paneCount [
	<category: 'configuration'>
	^4
    ]

    OBBrowser class >> panels [
	<category: 'configuration'>
	^(Array 
	    with: self navigationPanel
	    with: self optionalButtonPanel
	    with: self definitionPanel) reject: [:ea | ea isNil]
    ]

    OBBrowser class >> root: aNode [
	<category: 'instance creation'>
	^self root: aNode selection: nil
    ]

    OBBrowser class >> root: rootNode selection: selectedNode [
	<category: 'instance creation'>
	^self 
	    metaNode: self defaultMetaNode
	    root: rootNode
	    selection: selectedNode
	    panels: self panels
    ]

    OBBrowser class >> selection: selectedNode [
	<category: 'instance creation'>
	^self root: self defaultRootNode selection: selectedNode
    ]

    OBBrowser class >> title [
	<category: 'configuration'>
	^'OmniBrowser'
    ]

    OBBrowser class >> titleForRoot: aNode [
	<category: 'configuration'>
	^self title
    ]

    addPanel: aPanel [
	<category: 'accessing'>
	panels add: aPanel.
	aPanel browser: self
    ]

    announce: anObject [
	<category: 'updating'>
	^self announcer announce: anObject
    ]

    announcer [
	<category: 'accessing'>
	^announcer
    ]

    buildGroup: aCollection on: aBuilder [
	<category: 'building'>
	^aBuilder 
	    verticalGroupWith: [aCollection do: [:ea | ea buildOn: aBuilder]]
    ]

    buildOn: aBuilder [
	<category: 'building'>
	| group |
	^aBuilder window: self
	    with: 
		[group := OrderedCollection with: panels first.
		panels allButFirst do: 
			[:panel | 
			group last vResizing = #spaceFill 
			    ifTrue: 
				[self buildGroup: group on: aBuilder.
				group := OrderedCollection new].
			group add: panel].
		self buildGroup: group on: aBuilder]
    ]

    close [
	<category: 'opening'>
	^OBCloseRequest signal: self
    ]

    cmdFactories [
	<category: 'accessing'>
	^cmdFactories
    ]

    commandSelectors [
	<category: 'initializing'>
	| all obsolete commands |
	all := self class allSelectors.
	obsolete := Set new.
	all 
	    do: [:ea | (ea startsWith: 'obsolete') ifTrue: [obsolete add: (self perform: ea)]].
	commands := all select: [:ea | ea startsWith: 'cmd'].
	^commands reject: [:ea | obsolete includes: ea]
    ]

    currentNode [
	<category: 'accessing'>
	^self navigationPanel currentNode
    ]

    currentOrRootNode [
	<category: 'accessing'>
	^self navigationPanel currentOrRootNode
    ]

    defaultBackgroundColor [
	<category: 'building'>
	^Color gray veryMuchLighter
    ]

    defaultLabel [
	<category: 'accessing'>
	^self class titleForRoot: self root
    ]

    dontTranscribe [
	<category: 'updating'>
	self announcer unsubscribe: self.
	self subscribe
    ]

    initialize [
	<category: 'initializing'>
	panels := OrderedCollection new.
	announcer := OBAnnouncer new.
	cmdFactories := #().
	self subscribe
    ]

    initializeCommands [
	<category: 'initializing'>
	cmdFactories := Array streamContents: 
			[:stream | 
			self commandSelectors do: 
				[:selector | 
				| result |
				result := self perform: selector.
				result isCollection 
				    ifTrue: [stream nextPutAll: result]
				    ifFalse: [stream nextPut: result]]]
    ]

    jumpTo: aNode [
	<category: 'navigating'>
	self navigationPanel jumpTo: aNode
    ]

    jumpToRoot [
	<category: 'navigating'>
	^self navigationPanel jumpToRoot
    ]

    labelString [
	<category: 'callbacks'>
	| label |
	label := self navigationPanel labelString.
	^label ifNil: [self defaultLabel]
	    ifNotNil: [self defaultLabel , ': ' , label]
    ]

    navigationPanel [
	<category: 'accessing'>
	^panels detect: [:ea | ea isNavigation]
	    ifNone: [self error: 'No navigation panel configured']
    ]

    okToChange [
	<category: 'callbacks'>
	^(self announcer announce: OBAboutToChange) isVetoed not
    ]

    open [
	<category: 'opening'>
	^OBBrowseRequest signal: self
    ]

    panels [
	<category: 'accessing'>
	^panels
    ]

    relabel: ann [
	<category: 'updating'>
	self changed: #relabel
    ]

    root [
	<category: 'navigating'>
	^self navigationPanel root
    ]

    scanNodeCommands: ann [
	<category: 'updating'>
	(cmdFactories select: [:ea | ea takesNodes]) 
	    do: [:ea | ann addFactory: ea]
    ]

    scanTextCommands: ann [
	<category: 'updating'>
	(cmdFactories select: [:ea | ea takesText]) do: [:ea | ann addFactory: ea]
    ]

    selectionPath [
	<category: 'accessing'>
	^self navigationPanel selectionPath
    ]

    setMetaNode: aMetaNode node: aNode [
	<category: 'initializing'>
	self navigationPanel setMetaNode: aMetaNode node: aNode.
	self initializeCommands
    ]

    signalRefresh [
	<category: 'updating'>
	self announcer announce: OBRefreshRequired
    ]

    subscribe [
	<category: 'updating'>
	(self announcer)
	    observe: OBSelectionChanged
		send: #relabel:
		to: self;
	    observe: OBNodeCommandScan
		send: #scanNodeCommands:
		to: self;
	    observe: OBTextCommandScan
		send: #scanTextCommands:
		to: self
    ]

    transcribe [
	<category: 'updating'>
	self announcer observe: OBAnnouncement
	    do: 
		[:ann | 
		Transcript
		    cr;
		    show: ann]
    ]
]



OBObject subclass: OBBuilder [
    | current |
    
    <category: 'OmniBrowser-Kernel'>
    <comment: nil>

    OBBuilder class >> build: aModel [
	| builder |
	builder := self new.
	^aModel buildOn: builder
    ]

    button: aModel with: aBlock [
	<category: 'building'>
	self subclassResponsibility
    ]

    current: aWidget [
	<category: 'accessing'>
	current := aWidget
    ]

    current: anObject do: aBlock [
	<category: 'accessing'>
	| saved |
	
	[saved := current.
	current := anObject.
	aBlock value] 
		ensure: [current := saved].
	^anObject
    ]

    fixedButtonBar: aPanel with: aBlock [
	<category: 'building'>
	self subclassResponsibility
    ]

    horizontalGroupWith: aBlock [
	<category: 'building'>
	self subclassResponsibility
    ]

    pane: aColumn with: aBlock [
	<category: 'building'>
	self subclassResponsibility
    ]

    radioButtonBar: aPanel with: aBlock [
	<category: 'building'>
	self subclassResponsibility
    ]

    root [
	<category: 'accessing'>
	^current
    ]

    scroller: aPanel with: aBlock [
	<category: 'building'>
	self subclassResponsibility
    ]

    textarea: aPanel with: aBlock [
	<category: 'building'>
	self subclassResponsibility
    ]

    textfield: aModel with: aBlock [
	<category: 'building'>
	self subclassResponsibility
    ]

    verticalGroupWith: aBlock [
	<category: 'building'>
	self subclassResponsibility
    ]

    window: aBrowser with: aBlock [
	<category: 'building'>
	self subclassResponsibility
    ]
]



OBObject subclass: OBColumn [
    | panel switch fan selection |
    
    <category: 'OmniBrowser-Kernel'>
    <comment: 'An OBColumn manages a list of nodes, which it displays in a PluggableListMorph in the pane scroller at the top of the browser. All instances of OBColumn belong to an OBColumnPanel. It''s main responsibility is keeping its list - and those of its neighbours - up to date. Each column has a MetaNode, which provides the list contents. It uses a filter to meditate between its self and the MetaNode.

iVars:

panel		- the panel which owns the column
filter		- the filter which manages the column''s MetaNode.
parent		- the node selected in the column to the left of this column
children 	- the nodes which make up this column''s list
selection 	- the index of the node selected by the user'>

    OBColumn class >> inPanel: aBrowser [
	<category: 'instance creation'>
	^self new setPanel: aBrowser
    ]

    OBColumn class >> inPanel: aPanel metaNode: aMetaNode node: aNode [
	<category: 'instance creation'>
	^self new 
	    setPanel: aPanel
	    metaNode: aMetaNode
	    node: aNode
    ]

    addCommandsToMenu: aMenu [
	<category: 'commands'>
	| scan nodes |
	scan := self announce: OBNodeCommandScan.
	nodes := self hasSelection 
		    ifTrue: 
			[
			{self parent.
			self selectedNode}]
		    ifFalse: [{self parent}].
	scan 
	    populateMenu: aMenu
	    withNodes: nodes
	    forRequestor: self
    ]

    announce: anAnnouncement [
	<category: 'updating'>
	^self browser announce: anAnnouncement
    ]

    announcer [
	<category: 'accessing'>
	^panel announcer
    ]

    basicNext [
	<category: 'accessing'>
	^panel columnAfter: self
    ]

    basicParent: aNode [
	<category: 'accessing'>
	fan := OBFan parent: aNode.
	self switchFilter: fan switchFilter
    ]

    browser [
	<category: 'accessing'>
	^panel browser
    ]

    buildOn: aBuilder [
	<category: 'building'>
	^aBuilder pane: self with: [switch buildOn: aBuilder]
    ]

    canDrop: passenger on: node [
	<category: 'callbacks'>
	^node notNil and: [node wantsDroppedNode: passenger]
    ]

    children [
	<category: 'accessing'>
	^fan children
    ]

    childrenChanged: announcement [
	<category: 'updating'>
	self parent = announcement node ifTrue: [self refresh]
    ]

    clear [
	<category: 'updating'>
	self switchFilter: nil.
	fan := OBFan new.
	self clearSelection.
	self changed: #list.
	self changed: #selection
    ]

    clearSelection [
	<category: 'selecting'>
	selection := 0
    ]

    createNext [
	<category: 'updating'>
	| nextMetaNode created |
	nextMetaNode := self nextMetaNode.
	created := OBColumn 
		    inPanel: panel
		    metaNode: nextMetaNode
		    node: self selectedNode.
	panel pushColumn: created.
	^created
    ]

    descriptor [
	<category: 'printing'>
	self isEmpty ifTrue: [^'empty'].
	self hasSelection ifTrue: [^self selectedNode name].
	^''
    ]

    dragPassengerFor: item [
	<category: 'callbacks'>
        ^self nodeForItem: item
    ]

    drop: passenger on: target [
	<category: 'callbacks'>
	^[target acceptDroppedNode: passenger] on: OBAnnouncerRequest
	    do: [:notification | notification resume: self announcer]
    ]

    fan: aFan selection: index [
	<category: 'selecting'>
	fan := aFan.
	selection := index.
	self selectedNode ifNotNil: [:node | fan parent noteChild: node].
	self switchFilter: fan switchFilter.
	switch refresh.
	self changed: #list
    ]

    hasSelection [
	<category: 'testing'>
	^self selection > 0
    ]

    iconAt: index [
	<category: 'callbacks'>
	^(fan children at: index) icon
    ]

    includesNode: aNode [
	<category: 'testing'>
	^fan children includes: aNode
    ]

    isEmpty [
	<category: 'accessing'>
	^fan parent isNil
    ]

    isSelected: aNode [
	<category: 'testing'>
	^self selectedNode == aNode
    ]

    jumpTo: cNode [
	<category: 'accessing'>
	cNode ifNil: 
		[self clearSelection.
		self changed: #list.
		panel clearAfter: self]
	    ifNotNil: 
		[fan parent noteChild: cNode.
		self selectSilently: cNode.
		panel selectionChangedIn: self.
		switch currentNode: cNode.
		self changed: #list]
    ]

    keystroke: aChar from: aMorph [
	<category: 'callbacks'>
	| scan |
	self isEmpty ifTrue: [^self].
	scan := self announcer announce: OBNodeCommandScan.
	scan 
	    processKeystroke: aChar
	    withNode: self parent
	    for: self.
	self hasSelection 
	    ifTrue: 
		[scan 
		    processKeystroke: aChar
		    withNode: self selectedNode
		    for: self]
    ]

    list [
	<category: 'callbacks'>
	^fan children collect: [:ea | self parent displayStringForChild: ea]
    ]

    listAt: index [
	<category: 'callbacks'>
	^self parent 
	    displayStringForChild: (fan children at: index ifAbsent: [^''])
    ]

    listChanged [
	<category: 'updating'>
	self refreshAndSignal: true
    ]

    listSize [
	<category: 'callbacks'>
	^fan children ifNil: [0] ifNotNil: [fan children size]
    ]

    menu: aMenu [
	<category: 'callbacks'>
	self isEmpty ifFalse: [self addCommandsToMenu: aMenu].
	^aMenu
    ]

    metaNode [
	<category: 'accessing'>
	^self parent metaNode
    ]

    next [
	<category: 'accessing'>
	^self basicNext ifNil: 
		[(self hasSelection and: [self shouldBeLast not]) ifTrue: [self createNext]]
    ]

    nextMetaNode [
	<category: 'nodes'>
	^self selectedNode metaNode
    ]

    nodeChanged: ann [
	<category: 'updating'>
	(fan children includes: ann node) ifTrue: [self changed: #list]
    ]

    nodeDeleted: announcement [
	"This gets called if an action causes the currently selected node to be deleted."

	<category: 'updating'>
	self selectedNode = announcement node 
	    ifTrue: 
		[fan refresh.
		self changed: #list.
		self selection: 0]
    ]

    nodeForItem: aString [
	<category: 'callbacks'>
	^fan children 
	    detect: [:child | (self parent displayStringForChild: child) = aString]
	    ifNone: [aString]
    ]

    okToChange [
	<category: 'callbacks'>
	^(self announcer announce: OBAboutToChange) isVetoed not
    ]

    parent [
	<category: 'accessing'>
	^fan ifNotNil: [fan parent]
    ]

    parent: aNode [
	<category: 'accessing'>
	| cNode |
	self basicParent: aNode.
	cNode := fan autoSelection.
	self jumpTo: cNode
    ]

    printOn: aStream [
	<category: 'printing'>
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self descriptor.
	aStream nextPut: $)
    ]

    refresh [
	<category: 'updating'>
	self refreshAndSignal: false
    ]

    refresh: ann [
	<category: 'updating'>
	self refreshAndSignal: false
    ]

    refreshAndSignal: aBoolean [
	<category: 'updating'>
	| node shouldSignal |
	shouldSignal := aBoolean.
	self isEmpty ifTrue: [^self].
	node := self selectedNode.
	fan refresh 
	    ifTrue: 
		[self selectSilently: node.
		self hasSelection ifFalse: [shouldSignal := true]]
	    ifFalse: [^self].
	shouldSignal ifTrue: [self signalSelectionChanged].
	self changed: #list
    ]

    select: aNode [
	<category: 'selecting'>
	fan children 
	    doWithIndex: [:child :i | child = aNode ifTrue: [^self selection: i]].
	self selection: nil
    ]

    selectSilently: aNode [
	<category: 'selecting'>
	selection := fan indexOf: aNode
    ]

    selectedNode [
	<category: 'selecting'>
	^fan children at: self selection ifAbsent: []
    ]

    selection [
	<category: 'callbacks'>
	^selection ifNil: [0]
    ]

    selection: anInteger [
	<category: 'callbacks'>
	selection := anInteger.
	self signalSelectionChanged.
	self changed: #selection.
	switch currentNode: self selectedNode
    ]

    selectionChanged: ann [
	<category: 'updating'>
	
    ]

    setPanel: aPanel [
	<category: 'initializing'>
	panel := aPanel.
	switch := OBSwitch inColumn: self.
	self subscribe.
	fan := OBFan new.
	self clearSelection
    ]

    setPanel: aPanel metaNode: aMetanode node: aNode [
	<category: 'initializing'>
	switch := OBSwitch inColumn: self.
	panel := aPanel.
	aNode metaNode: aMetanode.
	self basicParent: aNode.
	self clearSelection.
	self subscribe
    ]

    shouldBeLast [
	<category: 'testing'>
	^self hasSelection not or: [self nextMetaNode hasChildren not]
    ]

    signalSelectionChanged [
	<category: 'updating'>
	self announcer announce: (OBSelectionChanged column: self)
    ]

    subscribe [
	<category: 'updating'>
	(self announcer)
	    observe: OBRefreshRequired
		send: #refresh:
		to: self;
	    observe: OBNodeChanged
		send: #nodeChanged:
		to: self;
	    observe: OBNodeDeleted
		send: #nodeDeleted:
		to: self;
	    observe: OBChildrenChanged
		send: #childrenChanged:
		to: self;
	    observe: OBSelectionChanged
		send: #selectionChanged:
		to: self
    ]

    switch [
	<category: 'accessing'>
	^switch
    ]

    switchFilter: aFilter [
	"We should only be sending #changed: if the filter is actually different
	 from the one the switch already has, but that causes some visually odd
	 behavior because of the way OBRadioButtonBar resizes its self when updating,
	 so for now we always just recreate the button bar."

	<category: 'accessing'>
	switch filter: aFilter.
	self changed: #switch
    ]

    wantsButton [
	<category: 'testing'>
	^switch isActive
    ]
]



OBObject subclass: OBCommand [
    | target requestor |
    
    <category: 'OmniBrowser-Commands'>
    <comment: nil>

    OBCommand class >> on: target for: requestor [
	<category: 'instance creation'>
	^self new setTarget: target requestor: requestor
    ]

    OBCommand class >> takesNodes [
	<category: 'testing'>
	^true
    ]

    OBCommand class >> takesText [
	<category: 'testing'>
	^false
    ]

    addItemToMenu: aMenu [
	<category: 'user interface'>
	self isActive 
	    ifTrue: 
		[aMenu 
		    add: self labelWithKeystroke
		    target: self
		    selector: #execute
		    enabled: self isEnabled
		    icon: self icon]
    ]

    buttonLabel [
	<category: 'accessing'>
	^self label
    ]

    cluster [
	<category: 'accessing'>
	^nil
    ]

    createCluster [
	<category: 'accessing'>
	^OBCommandCluster label: self cluster
    ]

    execute [
	<category: 'execution'>
	
    ]

    group [
	<category: 'accessing'>
	^#general
    ]

    icon [
	<category: 'accessing'>
	^nil
    ]

    isActive [
	<category: 'testing'>
	^false
    ]

    isEnabled [
	<category: 'testing'>
	^true
    ]

    keystroke [
	<category: 'accessing'>
	^nil
    ]

    label [
	<category: 'accessing'>
	self subclassResponsibility
    ]

    labelWithKeystroke [
	<category: 'accessing'>
	^self keystroke ifNil: [self label]
	    ifNotNil: [self label , ' (' , self keystroke asString , ')']
    ]

    longDescription [
	"Override this and return a string or a text for the fly-by-help (tooltip)"

	<category: 'accessing'>
	^nil
    ]

    on: anObject for: aRequestor [
	<category: 'accessing'>
	^self class on: anObject for: aRequestor
    ]

    order [
	<category: 'user interface'>
	^self label
    ]

    perform: aSelector orSendTo: anObject [
	<category: 'user interface'>
	self perform: aSelector
    ]

    select: aNode with: anAnnouncer [
	<category: 'user interface'>
	(anAnnouncer announce: OBAboutToChange) isVetoed 
	    ifFalse: [anAnnouncer announce: (OBSelectingNode node: aNode)]
    ]

    setTarget: anObject requestor: aRequestor [
	<category: 'initialize-release'>
	target := anObject.
	requestor := aRequestor
    ]

    takesNodes [
	<category: 'testing'>
	^true
    ]

    takesText [
	<category: 'testing'>
	^false
    ]

    wantsButton [
	"Put this here for compatibility. Eventually this will be obsolete"

	<category: 'testing'>
	^false
    ]
]



OBCommand subclass: OBPluggableCommand [
    | action active enabled label keystroke icon buttonLabel |
    
    <category: 'OmniBrowser-Commands'>
    <comment: nil>

    OBPluggableCommand class >> action: aValuable [
	^self new action: aValuable
    ]

    OBPluggableCommand class >> action: aValuable active: aValuable2 [
	^(self new)
	    action: aValuable;
	    active: aValuable2;
	    yourself
    ]

    OBPluggableCommand class >> new [
	^self basicNew initialize
    ]

    OBPluggableCommand class >> takesNodes [
	^true
    ]

    OBPluggableCommand class >> takesText [
	^false
    ]

    action: aValuable [
	<category: 'accessing'>
	action := aValuable
    ]

    active: aValuable [
	<category: 'accessing'>
	active := aValuable
    ]

    buttonLabel [
	<category: 'accessing'>
	^buttonLabel
    ]

    buttonLabel: aString [
	<category: 'accessing'>
	buttonLabel := aString
    ]

    enabled: aBlock [
	<category: 'accessing'>
	enabled := aBlock
    ]

    execute [
	<category: 'execute'>
	^action cull: target cull: requestor
    ]

    group [
	<category: 'accessing'>
	^#general
    ]

    icon [
	<category: 'accessing'>
	^icon
    ]

    icon: anIcon [
	<category: 'accessing'>
	icon := anIcon
    ]

    initialize [
	<category: 'initialize-release'>
	action := [].
	active := [true].
	enabled := [true].
	label := 'a command'
    ]

    isActive [
	<category: 'testing'>
	^active cull: target cull: requestor
    ]

    isEnabled [
	<category: 'testing'>
	^enabled cull: target cull: requestor
    ]

    keystroke [
	<category: 'accessing'>
	^keystroke
    ]

    keystroke: aCharacter [
	<category: 'accessing'>
	keystroke := aCharacter
    ]

    label [
	<category: 'accessing'>
	^label
    ]

    label: aString [
	<category: 'accessing'>
	label := aString
    ]

    labelWithKeystroke [
	<category: 'morphic'>
	^keystroke ifNil: [label]
	    ifNotNil: [label , ' (' , keystroke asString , ')']
    ]

    on: aNode for: aRequestor [
	<category: 'converting'>
	| inst |
	inst := self copy.
	inst setTarget: aNode requestor: aRequestor.
	^inst
    ]

    takesNodes [
	<category: 'testing'>
	^true
    ]

    useLineAfter [
	<category: 'testing'>
	^false
    ]

    wantsButton [
	<category: 'testing'>
	^self buttonLabel notNil
    ]
]



OBObject subclass: OBCommandCluster [
    | commands label |
    
    <category: 'OmniBrowser-Commands'>
    <comment: nil>

    OBCommandCluster class >> label: aString [
	^self new setLabel: aString
    ]

    addCommand: aCommand [
	<category: 'accessing'>
	commands add: aCommand
    ]

    addItemToMenu: aMenu [
	<category: 'accessing'>
	| submenu |
	submenu := aMenu addSubmenu: label enabled: self isEnabled.
	self populateMenu: submenu
    ]

    group [
	<category: 'accessing'>
	^#zclusters
    ]

    groupedCommands [
	<category: 'accessing'>
	| groups |
	groups := commands groupBy: [:svc | svc group]
		    having: [:group | group isEmpty not].
	groups := groups 
		    collect: [:ea | ea asArray sort: [:a :b | a label <= b label]].
	^groups asArray sort: [:a :b | a anyOne group <= b anyOne group]
    ]

    initialize [
	<category: 'accessing'>
	commands := IdentitySet new
    ]

    isEnabled [
	<category: 'accessing'>
	^commands anySatisfy: [:ea | ea isEnabled]
    ]

    label [
	<category: 'accessing'>
	^label
    ]

    populateMenu: aMenu [
	<category: 'accessing'>
	self groupedCommands 
	    do: [:group | group do: [:cmd | cmd addItemToMenu: aMenu]]
	    separatedBy: [aMenu addLine]
    ]

    setLabel: aSymbol [
	<category: 'initialize-release'>
	label := aSymbol
    ]
]



OBObject subclass: OBDefinition [
    
    <category: 'OmniBrowser-Utilities'>
    <comment: 'The responsibility of a definition is to express a node''s composition textually and respond to changes in the text by updating the node it represents. For example,a file browser might use a file definition to allow editing of a files contents.'>

    accept: aText notifying: aController [
	<category: 'callbacks'>
	^self text: aText
    ]

    allowsEditing [
	<category: 'testing'>
	^true
    ]

    asAnnouncement [
	<category: 'updating'>
	^OBDefinitionChanged definition: self
    ]

    doItContext [
	<category: 'callbacks'>
	^nil
    ]

    doItReceiver [
	<category: 'callbacks'>
	| class |
	class := self selectedClass.
	^class ifNotNil: [class theNonMetaClass] ifNil: [FakeClassPool new]
    ]

    isEditable [
	<category: 'testing'>
	^true
    ]

    selectedClass [
	<category: 'callbacks'>
	^nil
    ]

    selection [
	<category: 'callbacks'>
	^1 to: 0
    ]

    signalChange [
	<category: 'updating'>
	OBAnnouncer current announce: (OBDefinitionChanged definition: self)
    ]

    text [
	<category: 'callbacks'>
	^''
    ]

    text: aText [
	<category: 'callbacks'>
	^false
    ]

    textSelection [
	<category: 'callbacks'>
	^self selection
    ]
]



OBDefinition subclass: OBTextDefinition [
    | text |
    
    <category: 'OmniBrowser-Utilities'>
    <comment: nil>

    OBTextDefinition class >> text: aText [
	<category: 'instance creation'>
	^(self new)
	    setText: aText;
	    yourself
    ]

    setText: aText [
	<category: 'initialize-release'>
	text := aText
    ]

    text [
	<category: 'accessing'>
	^text
    ]
]



OBObject subclass: OBFan [
    | parent children |
    
    <category: 'OmniBrowser-Kernel'>
    <comment: nil>

    OBFan class >> parent: aNode [
	^self new setParent: aNode
    ]

    OBFan class >> parent: aNode children: aCollection [
	^self new setParent: aNode children: aCollection
    ]

    allChildren [
	<category: 'accessing'>
	^parent metaNode allChildrenForNode: parent
    ]

    ancestorOf: aNode from: aCollection in: aBlock [
	<category: 'selecting'>
	aCollection doWithIndex: 
		[:node :index | 
		(node isAncestorOf: aNode using: node metaNode ancestrySelector) 
		    ifTrue: 
			[aBlock value: index.
			^node]].
	^nil
    ]

    ancestorOf: aNode in: aBlock [
	<category: 'selecting'>
	| ancestor |
	ancestor := self 
		    ancestorOf: aNode
		    from: children
		    in: aBlock.
	ancestor ifNil: 
		[ancestor := parent childAncestorOf: aNode indexIn: aBlock.
		self refresh].
	ancestor ifNil: [aBlock value: 0].
	^ancestor
    ]

    autoSelection [
	<category: 'accessing'>
	| auto |
	auto := parent metaNode autoSelect.
	^auto 
	    ifNotNil: [children detect: [:ea | ea metaNode == auto] ifNone: [nil]]
    ]

    children [
	<category: 'accessing'>
	^children ifNil: [#()]
    ]

    indexOf: aNode [
	<category: 'selecting'>
	| index |
	index := children indexOf: aNode.
	index = 0 
	    ifTrue: 
		[index := self children 
			    indexOf: (self children detect: [:ea | ea = aNode] ifNone: [nil])].
	^index
    ]

    parent [
	<category: 'accessing'>
	^parent
    ]

    refresh [
	<category: 'accessing'>
	| oldChildren |
	oldChildren := children.
	children := parent childNodes.
	^children ~= oldChildren
    ]

    setParent: aNode [
	<category: 'initialize-release'>
	self setParent: aNode children: aNode childNodes
    ]

    setParent: aNode children: aCollection [
	<category: 'initialize-release'>
	parent := aNode.
	children := aCollection
    ]

    switchFilter [
	<category: 'accessing'>
	^parent metaNode switchFilter
    ]
]



OBObject subclass: OBFilter [
    | metaNode |
    
    <category: 'OmniBrowser-Filters'>
    <comment: 'A browser''s metagraph defines the way in which the user may traverse the graph of objects which make up the browser''s domain. But it''s not always desirable to have all the nodes made available by the metagraph to be visible in the browser. An filter provides a strategy for filtering out some of the nodes from the display. 

OBFilter provides a "null" filter - one that does no filtering at all - and serves as a superclass for other filters. '>

    buildOn: aBuilder [
	<category: 'user interface'>
	
    ]

    displayString: aString forNode: aNode [
	<category: 'filtering'>
	^aString
    ]

    displayString: aString forParent: pNode child: cNode [
	<category: 'filtering'>
	^aString
    ]

    edgesFrom: aCollection forNode: aNode [
	<category: 'filtering'>
	^aCollection
    ]

    icon: aSymbol forNode: aNode [
	<category: 'filtering'>
	^aSymbol
    ]

    metaNode [
	<category: 'accessing'>
	^metaNode
    ]

    nodesFrom: aCollection forNode: aNode [
	<category: 'filtering'>
	^aCollection
    ]

    noteParent: pNode child: cNode [
	<category: 'filtering'>
	
    ]

    setMetaNode: aMetaNode [
	<category: 'initalizing'>
	metaNode := aMetaNode
    ]

    wantsButton [
	<category: 'testing'>
	^false
    ]

    wantsSwitch [
	<category: 'testing'>
	^false
    ]
]



OBFilter subclass: OBModalFilter [
    | selection |
    
    <category: 'OmniBrowser-Filters'>
    <comment: 'OBModalFilter is used to implement the ''instance/?/class'' buttons in a standard class browser. In functional terms it filters the nodes of a column according to the edge of the metagraph that they correspond to. OBModalFilter displays an OBRadioButtonBar in its column''s pane, with one button per edge. Only nodes from the currently selected edge are allowed in the column.

iVars:

selection	- the currently selected edge'>

    activate [
	<category: 'callbacks'>
	
    ]

    edgesFrom: aCollection forNode: aNode [
	<category: 'filtering'>
	^Array with: (aCollection at: self selection)
    ]

    list [
	<category: 'callbacks'>
	^metaNode edges collect: [:edge | edge label]
    ]

    listForNode: aNode [
	<category: 'callbacks'>
	^self list
    ]

    noteParent: pNode child: cNode [
	<category: 'filtering'>
	pNode metaNode edges 
	    withIndexDo: [:edge :index | cNode metaNode = edge metaNode ifTrue: [selection := index]]
    ]

    selection [
	<category: 'callbacks'>
	^selection ifNil: [selection := 1]
    ]

    selection: anInteger [
	<category: 'callbacks'>
	selection := anInteger.
	self changed: #selection
    ]

    wantsButton [
	<category: 'queries'>
	^true
    ]

    wantsSwitch [
	<category: 'testing'>
	^true
    ]
]



OBFilter subclass: OBPluggableFilter [
    | edges nodeDisplay nodes parentDisplay note icon |
    
    <category: 'OmniBrowser-Filters'>
    <comment: nil>

    displayString: aString forNode: aNode [
	<category: 'filtering'>
	^nodeDisplay ifNil: [super displayString: aString forNode: aNode]
	    ifNotNil: [nodeDisplay value: aString value: aNode]
    ]

    displayString: aString forParent: pNode child: cNode [
	<category: 'filtering'>
	^parentDisplay ifNil: 
		[super 
		    displayString: aString
		    forParent: pNode
		    child: cNode]
	    ifNotNil: 
		[parentDisplay 
		    value: aString
		    value: pNode
		    value: cNode]
    ]

    edges [
	<category: 'accessing'>
	^edges
    ]

    edges: anObject [
	<category: 'accessing'>
	edges := anObject
    ]

    edgesFrom: aCollection forNode: aNode [
	<category: 'filtering'>
	^edges ifNil: [super edgesFrom: aCollection forNode: aNode]
	    ifNotNil: [edges value: aCollection value: aNode]
    ]

    icon [
	<category: 'accessing'>
	^icon
    ]

    icon: aBlock [
	<category: 'accessing'>
	icon := aBlock
    ]

    icon: aSymbol forNode: aNode [
	<category: 'filtering'>
	^icon ifNil: [super icon: aSymbol forNode: aNode]
	    ifNotNil: [icon value: aSymbol value: aNode]
    ]

    nodeDisplay [
	<category: 'accessing'>
	^nodeDisplay
    ]

    nodeDisplay: anObject [
	<category: 'accessing'>
	nodeDisplay := anObject
    ]

    nodes [
	<category: 'accessing'>
	^nodes
    ]

    nodes: anObject [
	<category: 'accessing'>
	nodes := anObject
    ]

    nodesFrom: aCollection forNode: aNode [
	<category: 'filtering'>
	^nodes ifNil: [super nodesFrom: aCollection forNode: aNode]
	    ifNotNil: [nodes value: aCollection value: aNode]
    ]

    note [
	<category: 'accessing'>
	^note
    ]

    note: aBlock [
	<category: 'accessing'>
	note := aBlock
    ]

    noteParent: pNode child: cNode [
	<category: 'filtering'>
	^note ifNil: [super noteParent: pNode child: cNode]
	    ifNotNil: [note value: pNode value: cNode]
    ]

    parentDisplay [
	<category: 'accessing'>
	^parentDisplay
    ]

    parentDisplay: anObject [
	<category: 'accessing'>
	parentDisplay := anObject
    ]
]



OBFilter subclass: OBRescueFilter [
    | cache rescued |
    
    <category: 'OmniBrowser-Filters'>
    <comment: 'TODO: removed support for #displayString:forParent:child:'>

    cache: aCollection for: aNode [
	<category: 'filtering'>
	| cached missing |
	cached := cache at: aNode
		    ifAbsent: [^self initCache: aCollection for: aNode].
	cache at: aNode put: aCollection.
	missing := rescued at: aNode ifAbsent: [Set new].
	missing removeAllSuchThat: [:ea | aCollection includes: ea].
	cached do: [:ea | (aCollection includes: ea) ifFalse: [missing add: ea]].
	missing isEmpty ifFalse: [rescued at: aNode put: missing].
	^missing asArray
    ]

    isChild: cNode rescuedFrom: pNode [
	<category: 'filtering'>
	^(rescued at: pNode ifAbsent: [#()]) includes: cNode
    ]

    initCache: aCollection for: aNode [
	<category: 'filtering'>
	cache at: aNode put: aCollection.
	^#()
    ]

    initialize [
	<category: 'private'>
	cache := Dictionary new.
	rescued := Dictionary new
    ]

    nodesFrom: aCollection forNode: aNode [
	<category: 'filtering'>
	^aCollection , (self cache: aCollection for: aNode)
    ]

    rescue: aCollection for: aNode [
	<category: 'private'>
	| previous |
	previous := rescued at: aNode ifAbsent: [#()].
	^rescued at: aNode put: previous , aCollection
    ]
]



OBObject subclass: OBMetaEdge [
    | label selector metaNode |
    
    <category: 'OmniBrowser-Kernel'>
    <comment: 'An OBMetaEdge is an edge in the browser''s metagraph. It represents a message sent to a node to obtain further nodes. It is refered to by the "parent" metanode, and refers to the "child" metanode.

iVars:

label 		-  a string describing the metaNode, for filters which allow the user 
			   to choose which edges to follow
selector	- when a node is selected by the user, this message will be 
			  sent to it to obtain its children
metaNode 	- a MetaNode corresponding to the nodes answered by the above message
		'>

    OBMetaEdge class >> label: aString selector: aSelector metaNode: aMetaNode [
	^self new 
	    setLabel: aString
	    selector: aSelector
	    metaNode: aMetaNode
    ]

    OBMetaEdge class >> selector: aSymbol [
	^self selector: aSymbol metaNode: nil
    ]

    OBMetaEdge class >> selector: aSelector metaNode: aMetaNode [
	^self new 
	    setLabel: aSelector asString
	    selector: aSelector
	    metaNode: aMetaNode
    ]

    -> aNode [
	<category: 'accessing'>
	metaNode := aNode
    ]

    / aString [
	<category: 'accessing'>
	label := aString
    ]

    label [
	<category: 'accessing'>
	^label
    ]

    metaNode [
	<category: 'accessing'>
	^metaNode
    ]

    nodesForParent: aNode [
	<category: 'accessing'>
	^(aNode perform: selector) do: [:ea | ea metaNode: metaNode]
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: selector printString , '->'.
	metaNode shortPrintOn: aStream
    ]

    selector [
	<category: 'accessing'>
	^selector
    ]

    setLabel: aString selector: aSelector metaNode: aMetaNode [
	<category: 'initializing'>
	label := aString.
	selector := aSelector.
	metaNode := aMetaNode
    ]
]



OBObject subclass: OBMetaNode [
    | name filters edges autoSelect ancestrySelector displaySelector |
    
    <category: 'OmniBrowser-Kernel'>
    <comment: 'A MetaNode represents a hypothetical node in the browser''s domain graph.

iVars:

filterClass			- the class used to filter this hypothetical node''s children
columnClass		- the class of column used to display this node''s children
edges				- messages that could be sent to the node to obtain children
actors				- providers of functionality for manipulating the node
displaySelector		- the message used to retreive a nodes display name'>

    OBMetaNode class >> named: aString [
	<category: 'instance creation'>
	^self new name: aString
    ]

    OBMetaNode class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    - aSelector [
	<category: 'children'>
	^edges add: (OBMetaEdge selector: aSelector)
    ]

    addFilter: aFilter [
	<category: 'accessing'>
	aFilter setMetaNode: self.
	filters add: aFilter
    ]

    allChildrenForNode: aNode [
	<category: 'nodes'>
	^edges gather: [:edge | edge nodesForParent: aNode]
    ]

    ancestrySelector [
	<category: 'accessing'>
	^ancestrySelector ifNil: [#isDescendantOf:]
    ]

    ancestrySelector: anObject [
	<category: 'accessing'>
	ancestrySelector := anObject
    ]

    autoSelect [
	<category: 'accessing'>
	^autoSelect ifNotNil: [autoSelect metaNode]
    ]

    autoSelect: aMetanode [
	<category: 'children'>
	autoSelect := edges detect: [:ea | ea metaNode == aMetanode] ifNone: [nil]
    ]

    childAt: aSelector labeled: aString put: aMetaNode [
	<category: 'children'>
	edges add: (OBMetaEdge 
		    label: aString
		    selector: aSelector
		    metaNode: aMetaNode)
    ]

    childAt: aSelector put: aMetaNode [
	<category: 'children'>
	edges add: (OBMetaEdge selector: aSelector metaNode: aMetaNode)
    ]

    childOf: parent ancestorOf: descendant indexIn: aBlock [
	<category: 'nodes'>
	(self childsPerEdgeFor: parent) do: 
		[:childsPerEdge | 
		childsPerEdge doWithIndex: 
			[:node :index | 
			(node isAncestorOf: descendant using: node metaNode ancestrySelector) 
			    ifTrue: 
				[filters do: [:f | f noteParent: parent child: node].
				aBlock value: index.
				^node]]].
	^nil
    ]

    children [
	<category: 'children'>
	^edges collect: [:edge | edge metaNode]
    ]

    childrenForNode: aNode [
	<category: 'nodes'>
	| chosenEdges |
	chosenEdges := self edgesForNode: aNode.
	^chosenEdges gather: 
		[:edge | 
		filters inject: (edge nodesForParent: aNode)
		    into: [:list :filter | filter nodesFrom: list forNode: aNode]]
    ]

    childsPerEdgeFor: aNode [
	"collects all childs and returns an array with one list of childs per edge.
	 all filters are applied to the child lists."

	<category: 'children'>
	^edges collect: 
		[:edge | 
		filters inject: (edge nodesForParent: aNode)
		    into: [:list :filter | filter nodesFrom: list forNode: aNode]]
    ]

    displaySelector [
	<category: 'accessing'>
	^displaySelector ifNil: [displaySelector := #name]
    ]

    displaySelector: aSelector [
	<category: 'accessing'>
	displaySelector := aSelector
    ]

    displayStringForNode: aNode [
	<category: 'filtering'>
	^filters inject: (aNode perform: self displaySelector)
	    into: [:string :filter | filter displayString: string forNode: aNode]
    ]

    displayStringForParent: pNode child: cNode [
	<category: 'filtering'>
	^filters inject: cNode displayString
	    into: 
		[:string :filter | 
		filter 
		    displayString: string
		    forParent: pNode
		    child: cNode]
    ]

    edges [
	<category: 'accessing'>
	^edges
    ]

    edgesForNode: aNode [
	<category: 'accessing'>
	^filters inject: edges
	    into: [:list :filter | filter edgesFrom: list forNode: aNode]
    ]

    hasChildren [
	<category: 'children'>
	^edges isEmpty not
    ]

    iconForNode: aNode [
	<category: 'filtering'>
	^filters inject: nil
	    into: [:icon :filter | filter icon: icon forNode: aNode]
    ]

    initialize [
	<category: 'initializing'>
	filters := OrderedCollection new.
	edges := OrderedCollection new
    ]

    metaNode [
	<category: 'filtering'>
	^self
    ]

    name [
	<category: 'accessing'>
	^name ifNil: ['MetaNode']
    ]

    name: aString [
	<category: 'accessing'>
	name := aString
    ]

    nodesForParent: aNode [
	<category: 'nodes'>
	^edges gather: [:edge | edge nodesForParent: aNode]
    ]

    noteParent: pNode child: cNode [
	<category: 'nodes'>
	filters do: [:ea | ea noteParent: pNode child: cNode]
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: self name;
	    cr.
	edges do: 
		[:e | 
		e printOn: aStream.
		aStream cr]
    ]

    shortPrintOn: aStream [
	<category: 'printing'>
	aStream nextPutAll: self name
    ]

    switchFilter [
	<category: 'filtering'>
	^filters detect: [:ea | ea wantsSwitch] ifNone: [nil]
    ]
]



OBObject subclass: OBNode [
    | metaNode |
    
    <category: 'OmniBrowser-Kernel'>
    <comment: 'A node is a wrapper for an object in the browser''s domain graph. OBNode is an abstract superclass for concrete nodes which might appear in the browser.

iVars:

metaNode - the MetaNode which produced this node'>

    OBNode class >> fromAssociation: anAssociationNode [
	^self on: anAssociationNode value
    ]

    = other [
	<category: 'comparing'>
	^self class = other class and: [self name = other name]
    ]

    accept: aText notifying: aController [
	<category: 'public'>
	^self text: aText
    ]

    ancestrySelector [
	<category: 'ancestry'>
	^#isDescendantOf:
    ]

    announce: anObject [
	<category: 'updating'>
	^OBAnnouncer current ifNotNil: [:announcer | announcer announce: anObject]
    ]

    announceChangedWith: anObject [
	<category: 'updating'>
	anObject announce: (OBNodeChanged node: self)
    ]

    announceChildrenChangedWith: anObject [
	<category: 'updating'>
	anObject announce: (OBChildrenChanged node: self)
    ]

    announceCreationWith: anObject [
	<category: 'updating'>
	anObject announce: (OBNodeCreated node: self)
    ]

    announceDeletionWith: anObject [
	<category: 'updating'>
	anObject announce: (OBNodeDeleted node: self)
    ]

    announceSelectionWith: anObject [
	<category: 'updating'>
	(anObject announce: OBAboutToChange) isVetoed 
	    ifFalse: [anObject announce: (OBSelectingNode node: self)]
    ]

    asFan [
	<category: 'converting'>
	^OBFan parent: self
    ]

    childAncestorOf: aNode indexIn: aBlock [
	<category: 'public'>
	^self metaNode 
	    childOf: self
	    ancestorOf: aNode
	    indexIn: aBlock
    ]

    childNodes [
	<category: 'public'>
	^metaNode childrenForNode: self
    ]

    definition [
	<category: 'public'>
	^self
    ]

    demandSelection [
	<category: 'updating'>
	^OBAnnouncer current announce: (OBNodeCreated node: self)
    ]

    displayString [
	<category: 'displaying'>
	^metaNode displayStringForNode: self
    ]

    displayStringForChild: aNode [
	<category: 'displaying'>
	^metaNode displayStringForParent: self child: aNode
    ]

    hash [
	<category: 'comparing'>
	^self name hash
    ]

    icon [
	<category: 'displaying'>
	^metaNode iconForNode: self
    ]

    icons [
	<category: 'accessing'>
	^#()
    ]

    isAncestorOf: aNode [
	<category: 'ancestry'>
	^self isAncestorOf: aNode using: self ancestrySelector
    ]

    isAncestorOf: aNode using: aSelector [
	<category: 'ancestry'>
	^aNode perform: aSelector with: self
    ]

    isDescendantOf: aNode [
	<category: 'ancestry'>
	^false
    ]

    metaNode [
	<category: 'accessing'>
	^metaNode
    ]

    metaNode: aMetaNode [
	<category: 'accessing'>
	metaNode := aMetaNode
    ]

    name [
	<category: 'public'>
	self subclassResponsibility
    ]

    noteChild: aNode [
	<category: 'public'>
	metaNode noteParent: self child: aNode
    ]

    referenceForMethod: selector ofClass: className [
	<category: 'utility'>
	| classIsMeta symbol |
	classIsMeta := className endsWith: ' class'.
	symbol := classIsMeta 
		    ifTrue: [(className allButLast: 6) asSymbol]
		    ifFalse: [className].
	^MethodReference new 
	    setClassSymbol: symbol
	    classIsMeta: classIsMeta
	    methodSymbol: selector
	    stringVersion: symbol , '>>' , selector
    ]

    signalChanged [
	<category: 'updating'>
	self announce: (OBNodeChanged node: self)
    ]

    signalChildrenChanged [
	<category: 'updating'>
	self announce: (OBChildrenChanged node: self)
    ]

    signalDeletion [
	<category: 'updating'>
	self announce: (OBNodeDeleted node: self)
    ]

    signalSelection [
	<category: 'updating'>
	(self announce: OBAboutToChange) isVetoed 
	    ifFalse: [self announce: (OBSelectingNode node: self)]
    ]

    text [
	<category: 'public'>
	^''
    ]

    text: aText [
	<category: 'public'>
	^false
    ]

    textSelection [
	<category: 'public'>
	^1 to: 0
    ]

    title [
	<category: 'displaying'>
	^nil
    ]

    acceptDroppedNode: aNode [
	<category: 'callbacks'>
        ^aNode perform: self dropSelector with: self
    ]

    dropSelector [
        <category: 'abstract'>
        ^#dropOnNode:
    ]

    wantsDroppedNode: aNode [
	<category: 'callbacks'>
        ^aNode respondsTo: self dropSelector
    ]
]



OBNode subclass: OBCollectionNode [
    | name collection |
    
    <category: 'OmniBrowser-Nodes'>
    <comment: 'OBCollectionNode is a trivial wrapper for a collection of nodes. It is typically used as an artificial root node for metagraphs that have no natural root.'>

    OBCollectionNode class >> on: aCollection [
	^self new setCollection: aCollection
    ]

    OBCollectionNode class >> on: aCollection named: aString [
	^(self on: aCollection)
	    name: aString;
	    yourself
    ]

    addChild: aNode [
	<category: 'navigating'>
	(collection includes: aNode) 
	    ifFalse: [collection := collection copyWith: aNode]
    ]

    children [
	<category: 'navigating'>
	^collection
    ]

    isAncestorOf: aNode [
	<category: 'ancestry'>
	^collection anySatisfy: [:ea | ea = aNode or: [ea isAncestorOf: aNode]]
    ]

    name [
	<category: 'displaying'>
	^name ifNil: [collection species name]
    ]

    name: aString [
	<category: 'displaying'>
	name := aString
    ]

    removeChild: aNode [
	<category: 'navigating'>
	(collection includes: aNode) 
	    ifTrue: [collection := collection copyWithout: aNode]
    ]

    setCollection: aCollection [
	<category: 'initalizing'>
	collection := aCollection
    ]
]



OBObject subclass: OBPanel [
    | browser |
    
    <category: 'OmniBrowser-Panels'>
    <comment: 'A panel is an object that manages part of the browser''s window. It provides a protocol for receiving notifications when the current domain node changes, and reacts to these changes.'>

    OBPanel class >> inBrowser: aBrowser [
	<category: 'instance creation'>
	^self new browser: aBrowser
    ]

    announce: aClass [
	<category: 'updating'>
	^self browser announce: aClass
    ]

    announcer [
	<category: 'accessing'>
	^browser announcer
    ]

    browser [
	<category: 'accessing'>
	^browser
    ]

    browser: aBrowser [
	<category: 'accessing'>
	browser := aBrowser.
	self subscribe
    ]

    definitionPanel [
	<category: 'accessing'>
	^nil
    ]

    isDefinition [
	<category: 'testing'>
	^false
    ]

    isNavigation [
	<category: 'testing'>
	^false
    ]

    subscribe [
	<category: 'updating'>
	
    ]
]



OBPanel subclass: OBColumnPanel [
    | root current columns minPanes maxPanes |
    
    <category: 'OmniBrowser-Panels'>
    <comment: 'OBColumnPanel handles navigation around the nodes of the object graph. It maintains a list of columns, which track the user''s path through the node tree. As nodes are selected, additional columns are added to the list, which appear as panes on the right of the panel. 

iVars:

columns	- A collection of OBColumns, each of which manages a single pane in the scroller.
minPanes - The minimum number of panes that should ever be visible.
maxPanes - The maximum number of panes that should ever be visible.
'>

    OBColumnPanel class >> minPanes: min maxPanes: max [
	<category: 'instance creation'>
	^self basicNew setMinPanes: min maxPanes: max
    ]

    OBColumnPanel class >> new [
	<category: 'instance creation'>
	^self minPanes: 1 maxPanes: 1
    ]

    buildOn: aBuilder [
	<category: 'building'>
	^aBuilder scroller: self with: [columns do: [:ea | ea buildOn: aBuilder]]
    ]

    clearAfter: aColumn [
	<category: 'accessing columns'>
	| start |
	aColumn ifNotNil: 
		[start := (columns indexOf: aColumn) + 1.
		start to: columns size do: [:i | (columns at: i) clear]]
    ]

    columnAfter: aColumn [
	<category: 'accessing columns'>
	^[self columns after: aColumn] on: Error do: [:err | nil]
    ]

    columnBefore: aColumn [
	<category: 'accessing columns'>
	^self columnBefore: aColumn ifAbsent: [nil]
    ]

    columnBefore: aColumn ifAbsent: aBlock [
	<category: 'accessing columns'>
	^[self columns before: aColumn] on: Error do: [:err | aBlock value]
    ]

    columns [
	<category: 'accessing'>
	^columns
    ]

    columns: anObject [
	<category: 'accessing'>
	columns := anObject
    ]

    currentColumn [
	<category: 'accessing columns'>
	^self columns reverse detect: [:ea | ea hasSelection] ifNone: []
    ]

    currentNode [
	<category: 'accessing'>
	^current
    ]

    currentOrRootNode [
	<category: 'accessing'>
	^current ifNil: [root]
    ]

    defaultBackgroundColor [
	<category: 'callbacks'>
	^browser defaultBackgroundColor
    ]

    emptyColumn [
	<category: 'accessing columns'>
	^OBColumn inPanel: self
    ]

    hasSelection [
	<category: 'accessing'>
	^false
    ]

    hopTo: aNode [
	<category: 'navigating'>
	| column |
	column := self columns last.
	
	[column
	    refreshAndSignal: false;
	    includesNode: aNode] 
		whileFalse: 
		    [column := self columnBefore: column ifAbsent: [^self jumpTo: aNode]].
	column select: aNode
    ]

    isNavigation [
	<category: 'testing'>
	^true
    ]

    isVariableHeight [
	<category: 'constructing'>
	^true
    ]

    jumpTo: aNode [
	<category: 'navigating'>
	| column |
	self selectAncestorsOf: aNode.
	column := self columns reverse detect: [:ea | ea selectedNode = aNode]
		    ifNone: [^self].
	self clearAfter: column next.
	self announcer announce: (OBSelectionChanged column: column)
    ]

    jumpToRoot [
	<category: 'navigating'>
	^self columns first selection: 0
    ]

    labelString [
	<category: 'accessing'>
	| label |
	self columns reverse do: 
		[:ea | 
		label := ea selectedNode ifNotNil: [:node | node title].
		label ifNotNil: [^label]].
	^nil
    ]

    maxPanes [
	<category: 'accessing'>
	^maxPanes
    ]

    minPanes [
	<category: 'accessing'>
	^minPanes
    ]

    nodeDeleted: ann [
	<category: 'updating'>
	ann node = self root 
	    ifTrue: 
		[current := nil.
		self columns first clear.
		self announcer announce: (OBSelectionChanged column: self)]
    ]

    okToReclaimPane [
	<category: 'updating'>
	columns size > minPanes ifFalse: [^false].
	^columns last isEmpty or: [(columns at: columns size - 1) shouldBeLast]
    ]

    popColumn [
	<category: 'accessing columns'>
	self announcer unsubscribe: self columns removeLast
    ]

    pushColumn: aColumn [
	<category: 'accessing columns'>
	self columns addLast: aColumn.
	self changed: #columns
    ]

    reclaimPanes [
	<category: 'updating'>
	| old |
	old := columns size.
	[self okToReclaimPane] whileTrue: [self popColumn].
	columns size = old ifFalse: [self changed: #columns]
    ]

    root [
	<category: 'navigating'>
	^root
    ]

    selectAncestorsOf: aNode [
	<category: 'navigating'>
	| subtree |
	subtree := OBSubtree from: root to: aNode.
	subtree ifNotNil: [self selectSubtree: subtree]
    ]

    selectNode: announcement [
	<category: 'updating'>
	^self hopTo: announcement node
    ]

    selectSubtree: aSubtree [
	<category: 'navigating'>
	aSubtree selectInColumns: columns
    ]

    selected: aColumn [
	<category: 'accessing columns'>
	aColumn next ifNotNil: [:next | next parent: aColumn selectedNode]
    ]

    selectedNode [
	<category: 'accessing'>
	^self currentNode
    ]

    selectionChanged: ann [
	<category: 'updating'>
	current := ann column selectedNode.
	self selectionChangedIn: ann column
    ]

    selectionChangedIn: aColumn [
	<category: 'updating'>
	aColumn hasSelection 
	    ifTrue: [self selected: aColumn]
	    ifFalse: [self clearAfter: aColumn].
	self reclaimPanes
    ]

    selectionPath [
	<category: 'accessing'>
	^(self columns select: [:e | e parent notNil]) allButFirst collect: [:e | e parent]
    ]

    setMetaNode: aMetaNode node: aNode [
	<category: 'initializing'>
	root := aNode.
	root metaNode: aMetaNode.
	self pushColumn: (OBColumn 
		    inPanel: self
		    metaNode: aMetaNode
		    node: root).
	minPanes - self columns size 
	    timesRepeat: [self pushColumn: self emptyColumn]
    ]

    setMinPanes: min maxPanes: max [
	<category: 'initializing'>
	columns := OrderedCollection new.
	minPanes := min.
	maxPanes := max
    ]

    sizing [
	<category: 'callbacks'>
	^(columns size max: minPanes) min: maxPanes
    ]

    subscribe [
	<category: 'updating'>
	(self announcer)
	    observe: OBSelectingNode
		send: #selectNode:
		to: self;
	    observe: OBSelectionChanged
		send: #selectionChanged:
		to: self;
	    observe: OBNodeCreated
		send: #selectNode:
		to: self;
	    observe: OBNodeDeleted
		send: #nodeDeleted:
		to: self
    ]

    vResizing [
	<category: 'building'>
	^#spaceFill
    ]
]



OBPanel subclass: OBFixedButtonPanel [
    
    <category: 'OmniBrowser-Panels'>
    <comment: 'OBFixedButtonPanel displays a horizontal row of buttons. In contrast to OBVarButtonPanel, the buttons do not change as nodes are selected in the navigation panel; instead they are enabled and disabled according to whether the actions they represent are applicable to the selected node.'>

    OBFixedButtonPanel class >> new [
	^self basicNew initialize
    ]

    buildOn: aBuilder [
	<category: 'building'>
	^aBuilder fixedButtonBar: self with: []
    ]

    color [
	<category: 'callbacks'>
	^browser defaultBackgroundColor
    ]

    commands [
	<category: 'callbacks'>
	| commands node buttons grouped groups |
	node := self currentNode.
	node ifNil: [^#()].
	commands := (self announce: OBNodeCommandScan) commandsOn: node for: self.
	buttons := commands select: [:ea | ea wantsButton].
	groups := (buttons collect: [:ea | ea group]) asSet 
		    asSortedCollection: [:a :b | a > b].
	grouped := groups collect: 
			[:ea | 
			(buttons select: [:b | b group = ea]) 
			    asSortedCollection: [:a :b | a order <= b order]].
	^grouped gather: [:ea | ea]
    ]

    currentNode [
	<category: 'callbacks'>
	^browser currentOrRootNode
    ]

    isSelected: aNode [
	<category: 'callbacks'>
	^true
    ]

    isVariableHeight [
	<category: 'constructing'>
	^false
    ]

    selectionChanged: ann [
	<category: 'callbacks'>
	self changed: #commands
    ]

    subscribe [
	<category: 'callbacks'>
	self announcer 
	    observe: OBSelectionChanged
	    send: #selectionChanged:
	    to: self.
	self announcer 
	    observe: OBNodeChanged
	    send: #selectionChanged:
	    to: self
    ]

    vResizing [
	<category: 'building'>
	^#rigid
    ]
]



OBPanel subclass: OBTextPanel [
    
    <category: 'OmniBrowser-Panels'>
    <comment: nil>

    addEditingItemsToMenu: aMenu shifted: aBoolean [
	<category: 'user interface'>
	| items |
	items := aBoolean 
		    ifTrue: [self shiftedYellowButtonMenu]
		    ifFalse: [self yellowButtonMenu].
	items do: 
		[:ea | 
		ea = #- 
		    ifFalse: [aMenu add: ea first action: ea second]
		    ifTrue: [aMenu addLine]]
    ]

    addMoreToMenu: aMenu [
	<category: 'user interface'>
	aMenu addLine.
	aMenu add: 'more...' translated action: #shiftedTextPaneMenuRequest
    ]

    addTextCommandsToMenu: aMenu selection: aTextSelection [
	<category: 'user interface'>
	| scan |
	scan := self announce: OBTextCommandScan.
	scan 
	    populateMenu: aMenu
	    withNodes: {aTextSelection}
	    forRequestor: self
    ]

    allowsEditing [
	<category: 'callbacks'>
	^true
    ]

    isEditable [
	<category: 'callbacks'>
	^true
    ]

    menu: aMenu shifted: aBoolean selection: aTextSelection [
	<category: 'callbacks'>
	self addEditingItemsToMenu: aMenu shifted: aBoolean.
	self addTextCommandsToMenu: aMenu selection: aTextSelection.
	self addMoreToMenu: aMenu.
	^aMenu
    ]

    perform: aSelector orSendTo: anObject [
	<category: 'callbacks'>
	| receiver |
	receiver := (self respondsTo: aSelector) ifTrue: [self] ifFalse: [anObject].
	receiver perform: aSelector
    ]

    shiftedYellowButtonMenu [
	<category: 'user interface'>
	^Array streamContents: 
		[:stream | 
		stream
		    nextPut: (Array with: 'explain' translated with: #explain);
		    nextPut: #-;
		    nextPut: (Array with: 'selectors containing it (W)' translated
				with: #methodNamesContainingIt);
		    nextPut: (Array with: 'method strings with it (E)' translated
				with: #methodStringsContainingit);
		    nextPut: (Array with: 'method source with it' translated
				with: #methodSourceContainingIt);
		    nextPut: (Array with: 'class names containing it' translated
				with: #classNamesContainingIt);
		    nextPut: (Array with: 'class comments with it' translated
				with: #classCommentsContainingIt);
		    nextPut: (Array with: 'change sets with it' translated
				with: #browseChangeSetsWithSelector);
		    nextPut: #-;
		    nextPut: (Array with: 'save contents to file...' translated
				with: #saveContentsInFile);
		    nextPut: #-;
		    nextPut: (Array with: 'more...' translated with: #yellowButtonActivity)]
    ]

    yellowButtonMenu [
	<category: 'user interface'>
	^Array streamContents: 
		[:stream | 
		stream
		    nextPut: (Array with: 'find...(f)' translated with: #find);
		    nextPut: (Array with: 'find again (g)' translated with: #findAgain);
		    nextPut: (Array with: 'set search string (h)' translated
				with: #setSearchString);
		    nextPut: #-;
		    nextPut: (Array with: 'do again (j)' translated with: #again);
		    nextPut: (Array with: 'undo (z)' translated with: #undo);
		    nextPut: #-;
		    nextPut: (Array with: 'copy (c)' translated with: #copySelection);
		    nextPut: (Array with: 'cut (x)' translated with: #cut);
		    nextPut: (Array with: 'paste (v)' translated with: #paste);
		    nextPut: (Array with: 'paste...' translated with: #pasteRecent);
		    nextPut: #-;
		    nextPut: (Array with: 'do it (d)' translated with: #doIt);
		    nextPut: (Array with: 'print it (p)' translated with: #printIt);
		    nextPut: (Array with: 'inspect it (i)' translated with: #inspectIt);
		    nextPut: (Array with: 'explore it (I)' translated with: #exploreIt);
		    nextPut: (Array with: 'debug it' translated with: #debugIt);
		    nextPut: #-;
		    nextPut: (Array with: 'accept (s)' translated with: #accept);
		    nextPut: (Array with: 'cancel (l)' translated with: #cancel)]
    ]
]



OBTextPanel subclass: OBDefinitionPanel [
    | canDiscardEdits node definition selection |
    
    <category: 'OmniBrowser-Panels'>
    <comment: 'OBDefinition serves as the model for the text pane of a typical browser. It''s main responsibility is to act as a relay between a PluggableTextMorph and a Definition supplied by the currently selected node.

iVars:

browser - The browser of which this panel is a part.
'>

    aboutToChange: ann [
	<category: 'updating'>
	| ok |
	self canDiscardEdits ifTrue: [^true].
	ok := OBConfirmationRequest 
		    prompt: 'Changes have not been saved.
Is it OK to discard those changes?'
		    confirm: 'Discard changes'.
	(ok isNil not and: [ok]) 
	    ifTrue: [self changed: #clearUserEdits]
	    ifFalse: [ann veto]
    ]

    aboutToChangeSilently: ann [
	<category: 'updating'>
	self canDiscardEdits ifFalse: [ann veto]
    ]

    accept: aText notifying: aController [
	<category: 'callbacks'>
	^self withDefinitionDo: 
		[:def | 
		[def accept: aText notifying: aController] on: OBAnnouncerRequest
		    do: [:notification | notification resume: self announcer]]
	    ifNil: [true]
    ]

    allowsEditing [
	<category: 'callbacks'>
	^definition notNil and: [definition allowsEditing]
    ]

    buildOn: aBuilder [
	<category: 'building'>
	^aBuilder textarea: self with: []
    ]

    canDiscardEdits [
	<category: 'updating'>
	^definition isNil or: [canDiscardEdits]
    ]

    canDiscardEdits: aBoolean [
	<category: 'updating'>
	canDiscardEdits := aBoolean
    ]

    definition: aDefinition [
	<category: 'accessing'>
	definition := aDefinition.
	canDiscardEdits := true.
	selection := nil.
	self changed: #text
    ]

    definitionChanged: ann [
	<category: 'updating'>
	self definition: ann definition.
    ]

    definitionPanel [
	<category: 'accessing'>
	^self
    ]

    doItContext [
	<category: 'callbacks'>
	^self 
	    withDefinitionDo: [:def | (def respondsTo: #doItContext) ifTrue: [def doItContext]]
	    ifNil: [nil]
    ]

    doItReceiver [
	<category: 'callbacks'>
	^self 
	    withDefinitionDo: [:def | (def respondsTo: #doItReceiver) ifTrue: [def doItReceiver]]
	    ifNil: [nil]
    ]

    environment [
	<category: 'accessing'>
	^self selectedClass environment
    ]

    getDefinition [
	<category: 'accessing'>
	^browser currentNode ifNotNil: [:n | n definition]
    ]

    isDefinition [
	<category: 'testing'>
	^true
    ]

    isEditable [
	<category: 'callbacks'>
	^definition notNil and: [definition isEditable]
    ]

    node: aNode [
	<category: 'accessing'>
	node := aNode.
	self definition: (aNode ifNotNil: [aNode definition])
    ]

    nodeChanged: ann [
	<category: 'updating'>
	node = ann node ifTrue: [self node: ann node]
    ]

    refresh: announcement [
	<category: 'updating'>
	| oldDefinition |
	definition ifNil: [^self].
	oldDefinition := definition.
	definition := self getDefinition ifNil: [oldDefinition].
	definition text = oldDefinition text ifFalse: [
	    self canDiscardEdits 
	        ifTrue: [self changed: #text]
	        ifFalse: [self changed: #codeChangedElsewhere] ].
	canDiscardEdits := true.
    ]

    selectedClass [
	<category: 'callbacks'>
	^self withDefinitionDo: 
		[:def | 
		(def respondsTo: #selectedClass) ifTrue: [def selectedClass]]
	    ifNil: [nil]
    ]

    selection [
	<category: 'callbacks'>
	^selection ifNil: 
		[selection := self withDefinitionDo: [:def | def textSelection]
			    ifNil: [1 to: 0]]
    ]

    selection: anInterval [
	<category: 'callbacks'>
	selection := anInterval.
	self changed: #selection
    ]

    selectionChanged: ann [
	<category: 'updating'>
	self node: ann column selectedNode
    ]

    subscribe [
	<category: 'updating'>
	(self announcer)
	    observe: OBAboutToChange
		send: #aboutToChange:
		to: self;
	    observe: OBAboutToChangeSilently
		send: #aboutToChangeSilently:
		to: self;
	    observe: OBSelectionChanged
		send: #selectionChanged:
		to: self;
	    observe: OBNodeChanged
		send: #nodeChanged:
		to: self;
	    observe: OBRefreshRequired
		send: #refresh:
		to: self;
	    observe: OBDefinitionChanged
		send: #definitionChanged:
		to: self
    ]

    text [
	<category: 'callbacks'>
	^self withDefinitionDo: [:def | def text] ifNil: ['']
    ]

    vResizing [
	<category: 'accessing'>
	^#spaceFill
    ]

    withDefinitionDo: workBlock ifNil: nilBlock [
	<category: 'accessing'>
	definition ifNil: [^nilBlock value].
	^workBlock value: definition
    ]
]



OBObject subclass: OBPlatform [
    
    <category: 'OmniBrowser-Kernel'>
    <comment: nil>

    Current := nil.

    OBPlatform class >> addPreference: aSymbol categories: anArray default: aBoolean balloonHelp: aString [
	<category: 'preferences'>
	^self subclassResponsibility
    ]

    OBPlatform class >> annotationPanes [
	<category: 'preferences'>
	^self subclassResponsibility
    ]

    OBPlatform class >> blankMenuIcon [
	<category: 'menu icons'>
	^self subclassResponsibility
    ]

    OBPlatform class >> chasingBrowsers [
	<category: 'preferences'>
	^self subclassResponsibility
    ]

    OBPlatform class >> classNamed: className [
	<category: 'smalltalk'>
	^self subclassResponsibility
    ]

    OBPlatform class >> classNames [
	<category: 'smalltalk'>
	^self subclassResponsibility
    ]

    OBPlatform class >> current [
	^Current ifNil: [self default]
    ]

    OBPlatform class >> current: aPlatform [
	Current := aPlatform
    ]

    OBPlatform class >> default [
	| classes |
	classes := self subclasses.
	^classes isEmpty 
	    ifTrue: [self error: 'No platform available']
	    ifFalse: [classes anyOne default]
    ]

    OBPlatform class >> defaultAnnotationRequests [
	<category: 'preferences'>
	^self subclassResponsibility
    ]

    OBPlatform class >> enableGently: attribute [
	<category: 'preferences'>
	^self subclassResponsibility
    ]

    OBPlatform class >> hasClassNamed: aSymbol [
	<category: 'smalltalk'>
	^self subclassResponsibility
    ]

    OBPlatform class >> lexiconWindowColor [
	<category: 'preferences'>
	^self subclassResponsibility
    ]

    OBPlatform class >> menuWithIcons [
	<category: 'preferences'>
	^self subclassResponsibility
    ]

    OBPlatform class >> mercuryPanel [
	<category: 'preferences'>
	^self subclassResponsibility
    ]

    OBPlatform class >> messageListWindowColor [
	<category: 'preferences'>
	^self subclassResponsibility
    ]

    OBPlatform class >> optionalButtons [
	<category: 'preferences'>
	^self subclassResponsibility
    ]

    OBPlatform class >> setPreference: attribute toValue: value [
	<category: 'preferences'>
	^self subclassResponsibility
    ]

    OBPlatform class >> smalltalkAssociationAt: aSymbol [
	<category: 'smalltalk'>
	^self subclassResponsibility
    ]

    OBPlatform class >> smalltalkAt: aSymbol [
	<category: 'smalltalk'>
	^self subclassResponsibility
    ]

    OBPlatform class >> smalltalkAt: aGlobalName ifAbsent: aBlock [
	<category: 'smalltalk'>
	^self subclassResponsibility
    ]

    OBPlatform class >> smalltalkAt: aGlobalName ifPresent: aBlock [
	<category: 'smalltalk'>
	^self subclassResponsibility
    ]

    OBPlatform class >> smalltalkEnvironment [
	<category: 'smalltalk'>
	^self subclassResponsibility
    ]

    OBPlatform class >> tryIcons: anArray [
	<category: 'menu icons'>
	^self subclassResponsibility
    ]
]



OBObject subclass: OBSubtree [
    | state |
    
    <category: 'OmniBrowser-Kernel'>
    <comment: nil>

    OBSubtree class >> from: root to: leaf [
	^self new initializeWithRoot: root leaf: leaf
    ]

    childOf: current ancestorOf: leaf indexOn: stream [
	| fan |
	fan := current asFan.
	stream nextPut: fan.
	^fan ancestorOf: leaf in: [:index | stream nextPut: index]
    ]

    initializeWithRoot: root leaf: leaf [
	| current |
	state := Array streamContents: 
			[:stream | 
			current := self 
				    childOf: root
				    ancestorOf: leaf
				    indexOn: stream.
			[current isNil or: [current = leaf]] whileFalse: 
				[current := self 
					    childOf: current
					    ancestorOf: leaf
					    indexOn: stream].
			current ifNotNil: 
				[current metaNode hasChildren 
				    ifTrue: 
					[stream
					    nextPut: current asFan;
					    nextPut: 0]]].
	^current ifNotNil: [self]
    ]

    selectInColumns: aCollection [
	| column stream |
	column := aCollection first.
	stream := state readStream.
	[stream atEnd] whileFalse: 
		[column fan: stream next selection: stream next.
		column := column next]
    ]

    state [
	^state
    ]
]



OBObject subclass: OBSwitch [
    | column filter |
    
    <category: 'OmniBrowser-Utilities'>
    <comment: nil>

    OBSwitch class >> inColumn: aColumn [
	<category: 'instance creation'>
	^self basicNew setColumn: aColumn filter: nil
    ]

    buildOn: aBuilder [
	^aBuilder radioButtonBar: self with: []
    ]

    currentNode: aNode [
	<category: 'updating'>
	self changed: #list
    ]

    filter [
	<category: 'accessing'>
	^filter
    ]

    filter: aFilter [
	filter := aFilter.
	filter ifNotNil: 
		[filter activate.
		self changed: #list]
    ]

    isActive [
	^filter notNil
    ]

    isEnabled: aButtonModel [
	<category: 'testing'>
	^true
    ]

    list [
	^filter ifNotNil: [filter listForNode: column selectedNode] ifNil: [#()]
    ]

    refresh [
	self changed: #selection
    ]

    selection [
	^filter ifNotNil: [filter selection] ifNil: [0]
    ]

    selection: anInteger [
	"self halt."

	filter ifNotNil: 
		[filter selection: anInteger.
		self changed: #selection.
		column listChanged]
    ]

    setColumn: aColumn filter: aFilter [
	column := aColumn.
	filter := aFilter
    ]
]



OBObject subclass: OBTextSelection [
    | selection text |
    
    <category: 'OmniBrowser-Utilities'>
    <comment: nil>

    OBTextSelection class >> on: anOBPluggableTextMorph [
	<category: 'instance creation'>
	^self new
    ]

    OBTextSelection class >> on: anInterval inText: aString [
	<category: 'instance creation'>
	^self new setSelection: anInterval inText: aString
    ]

    OBTextSelection class >> onAllOf: aString [
	<category: 'instance creation'>
	^self on: (1 to: aString size) inText: aString
    ]

    fullText [
	<category: 'accessing'>
	^text
    ]

    hasSelector [
	<category: 'accessing'>
	^self selector notNil
    ]

    selector [
	<category: 'accessing'>
	^self text asString findSelector
    ]

    setSelection: anInterval inText: aString [
	<category: 'accessing'>
	selection := anInterval.
	text := aString
    ]

    text [
	<category: 'accessing'>
	^text atAll: selection
    ]
]



Object extend [

    asAnnouncement [
	<category: '*omnibrowser-converting'>
	^self
    ]

]



Behavior extend [

    asAnnouncement [
	<category: '*omnibrowser-converting'>
	^self new
    ]

]

