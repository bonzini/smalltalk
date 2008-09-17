OBBuilder subclass: OBFakeBuilder [
    
    <comment: nil>
    <category: 'OB-Fake-Widgets'>

    addChild: anObject [
	<category: 'accessing'>
	current := anObject
    ]

    button: aModel with: aBlock [
	<category: 'building'>
	^self current: (OBFakeButton model: aModel) do: aBlock
    ]

    current: aWidget do: aBlock [
	<category: 'accessing'>
	current addChild: aWidget.
	^super current: aWidget do: aBlock
    ]

    enrichedTextarea: aPanel with: aBlock [
	<category: 'building'>
	^self current: (OBFakeText model: aPanel) do: aBlock
    ]

    fixedButtonBar: aPanel with: aBlock [
	<category: 'building'>
	
    ]

    initialize [
	<category: 'initialize-release'>
	current := self
    ]

    pane: aColumn with: aBlock [
	<category: 'building'>
	^self current: (OBFakePane model: aColumn)
	    do: 
		[self current: (OBFakeList model: aColumn) do: [].
		aBlock value]
    ]

    radioButtonBar: aSwitch with: aBlock [
	<category: 'building'>
	^self current: (OBFakeRadioButtonBar model: aSwitch) do: aBlock
    ]

    scroller: aPanel with: aBlock [
	<category: 'building'>
	^self current: (OBFakeScroller model: aPanel) do: aBlock
    ]

    textarea: aPanel with: aBlock [
	<category: 'building'>
	^self current: (OBFakeText model: aPanel) do: aBlock
    ]

    textfield: aPanel with: aBlock [
	<category: 'building'>
	^self current: (OBFakeText model: aPanel) do: aBlock
    ]

    verticalGroupWith: aBlock [
	<category: 'building'>
	^aBlock value
    ]

    window: aBrowser with: aBlock [
	<category: 'building'>
	^self current: (OBFakeWindow model: aBrowser label: aBrowser defaultLabel)
	    do: aBlock
    ]
]



OBObject subclass: OBFakeMenu [
    | target items |
    
    <category: 'OB-Fake-Widgets'>
    <comment: nil>

    add: aString action: aSymbol [
	<category: 'emulating'>
	items add: (OBFakeMenuItem 
		    label: aString
		    target: target
		    selector: aSymbol
		    enabled: true
		    icon: #blank)
    ]

    add: aString target: anObject selector: aSymbol enabled: aBoolean icon: icon [
	<category: 'emulating'>
	items add: (OBFakeMenuItem 
		    label: aString
		    target: anObject
		    selector: aSymbol
		    enabled: aBoolean
		    icon: icon)
    ]

    addLine [
	<category: 'emulating'>
	
    ]

    addSubmenu: aString enabled: aBoolean [
	<category: 'emulating'>
	| submenu |
	submenu := self class new.
	items add: (OBFakeMenuItem 
		    label: aString
		    enabled: aBoolean
		    submenu: submenu).
	^submenu
    ]

    defaultTarget: anObject [
	<category: 'emulating'>
	target := anObject
    ]

    initialize [
	<category: 'initialize-release'>
	items := OrderedCollection new
    ]

    itemWithWording: aString [
	<category: 'emulating'>
	^items detect: [:ea | ea label = aString] ifNone: [nil]
    ]

    items [
	<category: 'accessing'>
	^items
    ]

    lastItem [
	<category: 'accessing'>
	^items last
    ]
]



OBObject subclass: OBFakeMenuItem [
    | enabled icon label selector target submenu |
    
    <category: 'OB-Fake-Widgets'>
    <comment: nil>

    OBFakeMenuItem class >> label: aString enabled: aBoolean submenu: aMenu [
	<category: 'instance creation'>
	^(self new)
	    label: aString;
	    isEnabled: aBoolean;
	    submenu: aMenu;
	    yourself
    ]

    OBFakeMenuItem class >> label: aString target: anObject selector: aSymbol enabled: aBoolean icon: icon [
	<category: 'instance creation'>
	^(self new)
	    label: aString;
	    target: anObject;
	    selector: aSymbol;
	    isEnabled: aBoolean;
	    icon: icon;
	    yourself
    ]

    click [
	<category: 'simulating'>
	(enabled and: [selector notNil]) ifTrue: [target perform: selector]
    ]

    icon [
	<category: 'accessing'>
	^icon
    ]

    icon: anObject [
	<category: 'accessing'>
	icon := anObject
    ]

    isEnabled [
	<category: 'accessing'>
	^enabled
    ]

    isEnabled: aBoolean [
	<category: 'accessing'>
	enabled := aBoolean
    ]

    label [
	<category: 'accessing'>
	^label
    ]

    label: anObject [
	<category: 'accessing'>
	label := anObject
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: 'Item';
	    nextPut: $<;
	    print: label;
	    nextPut: $>
    ]

    selector [
	<category: 'accessing'>
	^selector
    ]

    selector: anObject [
	<category: 'accessing'>
	selector := anObject
    ]

    submenu [
	<category: 'accessing'>
	^submenu
    ]

    submenu: anObject [
	<category: 'accessing'>
	submenu := anObject
    ]

    target [
	<category: 'accessing'>
	^target
    ]

    target: anObject [
	<category: 'accessing'>
	target := anObject
    ]
]



OBObject subclass: OBFakeWidget [
    | model children |
    
    <category: 'OB-Fake-Widgets'>
    <comment: nil>

    OBFakeWidget class >> model: anObject [
	^self new model: anObject
    ]

    addChild: aWidget [
	<category: 'accessing'>
	children add: aWidget
    ]

    basicUpdate [
	<category: 'simulating'>
	
    ]

    children [
	<category: 'accessing'>
	^children
    ]

    findDeeplyA: aClass [
	<category: 'accessing'>
	self withAllChildrenDo: [:ea | (ea isMemberOf: aClass) ifTrue: [^ea]].
	^nil
    ]

    initialize [
	<category: 'initialize-release'>
	children := OrderedCollection new
    ]

    model [
	<category: 'accessing'>
	^model
    ]

    model: aModel [
	<category: 'accessing'>
	model ifNotNil: [model removeDependent: self].
	model := aModel.
	model addDependent: self
    ]

    printDebugIdOn: aStream [
	<category: 'printing'>
	aStream print: self identityHash
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    nextPutAll: (self class name allButFirst: 2);
	    nextPut: $<.
	self printDebugIdOn: aStream.
	aStream nextPut: $>
    ]

    setBalloonText: stringOrText [
	<category: 'simulating'>
	self setBalloonText: stringOrText maxLineLength: 20
    ]

    setBalloonText: stringOrText maxLineLength: aLength [
	"as a Fake widget is a morph, it should accep a balloon message"

	<category: 'simulating'>
	
    ]

    update [
	<category: 'simulating'>
	self basicUpdate.
	children do: [:ea | ea update]
    ]

    withAllChildrenDo: aBlock [
	<category: 'accessing'>
	aBlock value: self.
	children do: [:ea | ea withAllChildrenDo: aBlock]
    ]
]



OBFakeWidget subclass: OBFakeButton [
    | label bar isOn |
    
    <category: 'OB-Fake-Widgets'>
    <comment: nil>

    OBFakeButton class >> label: aString bar: aButtonBar [
	^self new setLabel: aString bar: aButtonBar
    ]

    click [
	<category: 'simulating'>
	bar select: self
    ]

    deselect [
	<category: 'selection'>
	isOn := false
    ]

    isOn [
	<category: 'examining'>
	^isOn
    ]

    label [
	<category: 'examining'>
	^label
    ]

    printDebugIdOn: aStream [
	<category: 'printing'>
	aStream print: label
    ]

    select [
	<category: 'selection'>
	isOn := true
    ]

    setLabel: aString bar: aButtonBar [
	<category: 'initalize-release'>
	label := aString.
	bar := aButtonBar
    ]
]



OBFakeWidget subclass: OBFakeList [
    | list selectionIndex |
    
    <category: 'OB-Fake-Widgets'>
    <comment: nil>

    basicUpdate [
	<category: 'simulating'>
	self updateList.
	self updateSelectionIndex
    ]

    canDrop: aNode on: aString [
	<category: 'examining'>
	^model canDrop: aNode on: (model nodeForItem: aString)
    ]

    changeModelSelection: anInteger [
	<category: 'simulating'>
	model selection: anInteger
    ]

    doubleClickSelector: aSymbol [
	<category: 'simulating'>
	
    ]

    drop: aNode on: aString [
	<category: 'examining'>
	^model drop: aNode on: (model nodeForItem: aString)
    ]

    getListDelicately [
	<category: 'examining'>
	^list ifNil: [Array new]
    ]

    getListObtrusively [
	<category: 'examining'>
	^list := model list
    ]

    getMenu: shiftKeyState [
	<category: 'examining'>
	| menu |
	menu := OBFakeMenu new defaultTarget: model.
	model menu: menu.
	^menu
    ]

    selection [
	<category: 'examining'>
	selectionIndex = 0 ifTrue: [^nil].
	list ifNotNil: [^list at: selectionIndex].
	^model listAt: selectionIndex
    ]

    update: aSelector [
	<category: 'emulating'>
	aSelector = #list ifTrue: [^self updateList].
	aSelector = #selection ifTrue: [^self updateSelectionIndex]
    ]

    updateList [
	<category: 'private'>
	list := model list.
	selectionIndex := model selection
    ]

    updateSelectionIndex [
	<category: 'private'>
	selectionIndex := model selection
    ]
]



OBFakeWidget subclass: OBFakePane [
    
    <category: 'OB-Fake-Widgets'>
    <comment: nil>

    addSwitch [
	children add: (OBFakeBuilder build: model switch)
    ]

    hasSwitch [
	^children size > 1
    ]

    list [
	^children first
    ]

    removeSwitch [
	children removeLast
    ]

    update: aSymbol [
	aSymbol = #switch ifTrue: [self updateSwitch]
    ]

    updateSwitch [
	self hasSwitch 
	    ifTrue: [model wantsButton ifFalse: [self removeSwitch]]
	    ifFalse: [model wantsButton ifTrue: [self addSwitch]]
    ]
]



OBFakeWidget subclass: OBFakeRadioButtonBar [
    | buttons selection |
    
    <category: 'OB-Fake-Widgets'>
    <comment: nil>

    basicUpdate [
	self updateList.
	self updateSelection
    ]

    buttonAt: index do: aBlock [
	aBlock value: (children at: index ifAbsent: [^self])
    ]

    select: aButton [
	model selection: (children indexOf: aButton)
    ]

    selectIndex: index [
	self buttonAt: selection do: [:button | button deselect].
	selection := index.
	self buttonAt: selection do: [:button | button select]
    ]

    update: aSymbol [
	aSymbol == #list ifTrue: [self updateList].
	aSymbol == #selection ifTrue: [self updateSelection]
    ]

    updateList [
	children := model list collect: [:ea | OBFakeButton label: ea bar: self].
	selection := model selection
    ]

    updateSelection [
	self selectIndex: model selection
    ]
]



OBFakeWidget subclass: OBFakeScroller [
    
    <category: 'OB-Fake-Widgets'>
    <comment: nil>

    update: aSymbol [
	aSymbol = #sizing ifTrue: [^self updateSizing].
	aSymbol = #columns ifTrue: [^self updatePanes]
    ]

    updatePanes [
	| builder |
	builder := OBFakeBuilder new.
	children := model columns collect: [:ea | ea buildOn: builder]
    ]
]



OBFakeWidget subclass: OBFakeText [
    | text selection hasEditingConflicts |
    
    <category: 'OB-Fake-Widgets'>
    <comment: nil>

    accept [
	<category: 'simulating'>
	model accept: text notifying: self.
	self canDiscardEdits: true.
	hasEditingConflicts := false
    ]

    basicUpdate [
	<category: 'emulating'>
	text := model text.
	self getSelection.
	self canDiscardEdits: true.
	hasEditingConflicts := false
    ]

    canDiscardEdits [
	<category: 'emulating'>
	^model canDiscardEdits
    ]

    canDiscardEdits: aBoolean [
	<category: 'simulating'>
	model canDiscardEdits: aBoolean
    ]

    getMenu: shiftKeyState [
	<category: 'examining'>
	| menu |
	menu := OBFakeMenu new defaultTarget: model.
	model menu: menu shifted: shiftKeyState selection: self selectionNode.
	^menu
    ]

    getSelection [
	<category: 'simulating'>
	^selection := model selection
    ]

    hasEditingConflicts [
	<category: 'examining'>
	^hasEditingConflicts
    ]

    selectionNode [
	<category: 'emulating'>
        ^OBTextSelection on: self selectionInterval inText: self text
    ]

    selectionInterval [
	<category: 'emulating'>
	^selection
    ]

    text [
	<category: 'examining'>
	^text
    ]

    text: aString [
	<category: 'simulating'>
	text := aString.
	self canDiscardEdits: false
    ]

    update: aSymbol [
	<category: 'examining'>
	aSymbol = #text ifTrue: [self basicUpdate].
	aSymbol = #selection ifTrue: [self getSelection].
	aSymbol = #codeChangedElsewhere ifTrue: [hasEditingConflicts := true]
    ]
]



OBFakeWidget subclass: OBFakeWindow [
    | label |
    
    <category: 'OB-Fake-Widgets'>
    <comment: nil>

    OBFakeWindow class >> model: anObject label: aString [
	^(super model: anObject) label: aString
    ]

    close [
	<category: 'simulating'>
	model okToChange ifTrue: [^self].
	model
	    windowIsClosing;
	    release.
	model := nil
    ]

    label [
	<category: 'examining'>
	^label
    ]

    label: aString [
	<category: 'accessing'>
	label := aString
    ]

    printDebugIdOn: aStream [
	<category: 'printing'>
	aStream print: label
    ]

    update: aSymbol [
	<category: 'emulating'>
	aSymbol = #relabel ifTrue: [model ifNotNil: [label := model labelString]]
    ]
]


OBPlatform subclass: OBFakePlatform [
    | menuWithIcons optionalButtons |
    OBFakePlatform class >> default [
	^self new
    ]

    enableGently: aSymbol [
	self setPreference: aSymbol toValue: true
    ]

    handleInformRequest: req [
    ]

    menuWithIcons [
	^menuWithIcons ifNil: [false ]
    ]

    menuWithIcons: aBoolean [
	menuWithIcons := aBoolean
    ]

    optionalButtons [
	^optionalButtons ifNil: [false ]
    ]

    optionalButtons: aBoolean [
	optionalButtons := aBoolean
    ]

    setPreference: aSymbol toValue: anObject [
	self perform: (aSymbol, ':') asSymbol with: anObject
    ]
]
