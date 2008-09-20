OBBuilder subclass: OBGtkBuilder [
    | color |
    
    <comment: nil>
    <import: GTK>
    <category: 'OmniBrowser-Gtk'>

    OBGtkBuilder class >> open: aModel [
	<category: 'opening'>
	^self build: aModel
    ]

    OBGtkBuilder class >> openWithExtent: aBrowser [
	<category: 'opening'>
	^(self build: aBrowser) openInWorldExtent: aBrowser extent
    ]

    button: aButtonModel with: aBlock [
	<category: 'building'>
	| button |
	button := GtkButton newWithLabel: aButtonModel.
	current 
	    packStart: button
	    expand: false
	    fill: false
	    padding: 0.
	self current: button do: aBlock.
	^button
    ]

    fixedButtonBar: aPanel with: aBlock [
	<category: 'building'>
	| buttonBar |
	buttonBar := OBGtkButtonBar new model: aPanel.
	current 
	    packStart: buttonBar
	    expand: false
	    fill: false
	    padding: 0.
	self current: buttonBar do: aBlock.
	^buttonBar
    ]

    horizontalGroupWith: aBlock [
	<category: 'building'>
	| layout |
	layout := GtkHBox new: true spacing: 0.
	current 
	    packStart: layout
	    expand: false
	    fill: false
	    padding: 0.
	self current: layout do: aBlock.
	^layout
    ]

    pane: aColumn with: aBlock [
	<category: 'building'>
	| pane |
	pane := (OBGtkPane new)
		    treePane: OBGtkTreePane new;
		    model: aColumn;
		    yourself.
	current ifNotNil: [current add: pane].
	self current: pane do: aBlock.
	^pane
    ]

    radioButtonBar: aPanel with: aBlock [
	<category: 'building'>
	| bar |
	^aPanel isActive 
	    ifTrue: 
		[bar := OBGtkRadioButtonBar new model: aPanel.
		current ifNotNil: [current button: bar].
		bar]
    ]

    scroller: aPanel with: aBlock [
	<category: 'building'>
	| scroller box |
	box := GtkHBox new: true spacing: 0.
	scroller := GtkScrolledWindow new: nil vadjustment: nil.
	scroller
	    setPolicy: Gtk gtkPolicyNever
	    vscrollbarPolicy: Gtk gtkPolicyAutomatic.
	scroller addWithViewport: box.
	current ifNotNil: [current add: scroller].
	self current: box do: aBlock.
	^scroller
    ]

    textarea: aPanel with: aBlock [
	<category: 'building'>
	| scroller text |
	text := OBGtkTextView new model: aPanel.
	scroller := GtkScrolledWindow new: nil vadjustment: nil.
	scroller
	    setPolicy: Gtk gtkPolicyAutomatic
	    vscrollbarPolicy: Gtk gtkPolicyAutomatic.
	scroller add: text.
	current ifNotNil: [current add: scroller].
	^self current: text do: aBlock
    ]

    textfield: aModel with: aBlock [
	<category: 'building'>
	| text |
	text := OBGtkTextEntry new model: aModel.
	current ifNotNil: 
		[current 
		    packStart: text
		    expand: false
		    fill: false
		    padding: true.
		self current: text do: aBlock].
	^text
    ]

    verticalGroupWith: aBlock [
	<category: 'building'>
	| box |
	box := GtkVBox new: false spacing: 0.
	current addVerticalGroup: box.
	self current: box do: aBlock
    ]

    window: aBrowser with: aBlock [
	<category: 'building'>
	| window |
	window := OBGtkWindow labelled: aBrowser labelString.
	window model: aBrowser.
	self current: window do: [aBlock value].
	^window
	    showAll;
	    yourself
    ]
]



OBPlatform subclass: OBGtkPlatform [
    
    <comment: nil>
    <import: GTK>
    <category: 'OmniBrowser-Gtk'>

    | optionalButtons |

    OBGtkPlatform class >> default [
	^self new
	    optionalButtons: true;
	    yourself
    ]

    handleBrowseRequest: request [
	^OBGtkBuilder open: request browser
    ]

    handleBrowseRequestWithExtent: request [
	^OBGtkBuilder openWithExtent: request browser
    ]

    handleChoiceRequest: request [
	^GtkInputDialog 
	    title: (request prompt ifNil: [''])
	    list: request labels
	    values: request values
    ]

    handleCloseRequest: aRequest [
	
    ]

    handleConfirmationRequest: request [
	^GtkInputDialog 
	    title: ''
	    text: request prompt
	    initialAnswer: request template
    ]

    handleInformRequest: request [
	^GtkMessageDialog question: request message
    ]

    handleTextRequest: request [
	^GtkInputDialog 
	    title: ''
	    text: request prompt
	    initialAnswer: request template
    ]

    optionalButtons [
	^optionalButtons
    ]

    optionalButtons: aBoolean [
	optionalButtons := aBoolean
    ]
]



GTK.GtkMenu subclass: OBGtkMenu [
    
    <comment: nil>
    <import: GTK>
    <category: 'OmniBrowser-Gtk'>

    new [
        ^self new castTo: self type
    ]

    add: aString target: anObject selector: aSymbol enabled: aBoolean icon: anIconSymbol [
	| item |
	item := (GtkMenuItem newWithLabel: aString)
		    connectSignal: 'activate'
			to: anObject
			selector: aSymbol;
		    show;
		    yourself.
	self append: item
    ]

    addLine [
	self append: GtkMenuItem new
    ]

    addSubmenu: aSymbol enabled: aBoolean [
	| submenu menu |
	submenu := GtkMenuItem newWithLabel: aSymbol asString.
	menu := OBGtkMenu new.
	submenu submenu: menu.
	self append: submenu.
	^menu
    ]
]




Object subclass: GtkMainWindow [
    | window container menuBar toolBar centralWidget statusBar |
    
    <category: 'Gtk-Tools'>
    <comment: nil>
    <import: GTK>

    GtkMainWindow class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    GtkMainWindow class >> open [
	<category: 'user interface'>
	^(self new)
	    showAll;
	    yourself
    ]

    GtkMainWindow class >> openSized: aPoint [
	<category: 'user interface'>
	^(self new)
	    resize: aPoint;
	    showAll;
	    yourself
    ]

    aboutSqueak [
	<category: 'events'>
	(GtkAboutDialog new)
	    aboutDialogName: ((Smalltalk version =~ '(.*) version') at: 1);
	    version: ((Smalltalk version =~ 'version (.*)') at: 1);
	    website: 'http://smalltalk.gnu.org';
	    programName: ((Smalltalk version =~ '(.*) version') at: 1);
	    runAndDestroy
    ]

    addMenuItem: aString [
	<category: 'menubar'>
	self menuBar append: (GtkMenuItem newWithLabel: aString)
    ]

    addMenuItem: aString withSubmenu: aGtkMenu [
	<category: 'menubar'>
	self menuBar append: ((GtkMenuItem newWithLabel: aString)
				setSubmenu: aGtkMenu;
				yourself)
    ]

    appendSeparator [
	<category: 'toolbar'>
	self appendToolItem: GtkSeparatorToolItem new
    ]

    appendToolItem: aGtkToolItem [
	<category: 'toolbar'>
	self toolBar insert: aGtkToolItem pos: -1
    ]

    appendWidget: aGtkWidget [
	<category: 'toolbar'>
	self appendToolItem: (GtkToolItem new add: aGtkWidget)
    ]

    centralWidget [
	<category: 'accessing'>
	^centralWidget
    ]

    centralWidget: aGtkWidget [
	<category: 'accessing'>
	centralWidget := aGtkWidget
    ]

    close [
	<category: 'events'>
	window hide
    ]

    container [
	<category: 'accessing'>
	^container ifNil: [container := GtkVBox new: false spacing: 0]
    ]

    createMenuEntry: anArray [
	<category: 'menubar'>
	| menu |
	menu := GtkMenu new.
	anArray do: 
		[:each | 
		menu append: (each ifEmpty: [GtkSeparatorMenuItem new]
			    ifNotEmpty: 
				[(GtkMenuItem newWithLabel: (each at: 1))
				    connectSignal: 'activate'
					to: self
					selector: (each at: 2);
				    yourself])].
	^menu
    ]

    initialize [
	<category: 'initialization'>
	window := GtkWindow new: Gtk gtkWindowToplevel
    ]

    menuBar [
	<category: 'accessing'>
	^menuBar ifNil: [menuBar := GtkMenuBar new]
    ]

    menuBar: aGtkMenuBar [
	<category: 'accessing'>
	menuBar := aGtkMenuBar
    ]

    resize: aPoint [
	<category: 'user interface'>
	window resize: aPoint
    ]

    showAll [
	<category: 'user interface'>
	
	{menuBar. toolBar. centralWidget.  statusBar} keysAndValuesDo: 
	    [:i :each | 
		each ifNotNil: [
		    self container
			packStart: each expand: i = 3
			fill: true padding: 0]].

	window add: self container.
	window showAll
    ]

    statusBar [
	<category: 'accessing'>
	^statusBar ifNil: [statusBar := GtkStatusbar new]
    ]

    statusBar: aGtkStatusBar [
	<category: 'accessing'>
	statusBar := aGtkStatusBar
    ]

    statusMessage: aString [
	<category: 'statusbar'>
	self statusBar at: 0 push: aString
    ]

    title [
	<category: 'accessing'>
	^window getTitle
    ]

    title: aString [
	<category: 'accessing'>
	window setTitle: aString
    ]

    toolBar [
	<category: 'accessing'>
	^toolBar ifNil: [toolBar := GtkToolbar new]
    ]

    toolBar: aGtkToolBar [
	<category: 'accessing'>
	toolBar := aGtkToolBar
    ]
]



GtkMainWindow subclass: OBGtkWindow [
    | model |
    
    <category: 'OmniBrowser-Gtk'>
    <comment: nil>
    <import: GTK>

    OBGtkWindow class >> labelled: aString [
	^(self new)
	    title: aString;
	    yourself
    ]

    addVerticalGroup: aVerticalGroup [
	self centralWidget
	    ifNil: [self centralWidget: aVerticalGroup]
	    ifNotNil: [self centralWidget add: aVerticalGroup]
    ]

    model [
	^model
    ]

    model: anObject [
	model ifNotNil: [model removeDependent: self].
	model := anObject.
	model ifNotNil: [model addDependent: self]
    ]

    open [
	self showAll
    ]

    openInWorldExtent: aModel [
	^self
    ]

    update: aSymbol [
	aSymbol = #relabel ifTrue: [self title: model labelString].
	aSymbol = #close ifTrue: [self hideAll]
    ]
]



GTK.GtkHButtonBox subclass: OBGtkButtonBar [
    | model children |
    
    <category: 'OmniBrowser-Gtk'>
    <comment: nil>
    <import: GTK>

    OBGtkButtonBar class >> new [
	<category: 'instance creation'>
        ^(super new castTo: self type)
	    initialize;
	    yourself
    ]

    clear [
	children do: [:each | self remove: each]
    ]

    initialize [
	children := OrderedCollection new
    ]

    model: anObject [
	model ifNotNil: [model removeDependent: self].
	model := anObject.
	model ifNotNil: 
		[self refresh.
		model addDependent: self]
    ]

    refresh [
	| button |
	model commands do: 
		[:each | 
		children add: (button := GtkButton newWithLabel: each buttonLabel).
		self add: button.
		button 
		    connectSignal: 'clicked'
		    to: each
		    selector: #execute]
    ]

    update: aSymbol [
	aSymbol = #commands 
	    ifTrue: 
		[self
		    clear;
		    refresh]
    ]
]



OBGtkButtonBar subclass: OBEnhancementGtkButtonBar [
    
    <category: 'OmniBrowser-Gtk'>
    <comment: nil>
    <import: GTK>

    initialize [
	| button |
	super initialize.
	button := GtkButton newWithLabel: '<<'.
	self add: button.
	button 
	    connectSignal: 'clicked'
	    to: model
	    selector: #back.
	button := GtkButton newWithLabel: '>>'.
	self add: button.
	button 
	    connectSignal: 'clicked'
	    to: model
	    selector: #forward
    ]
]



GTK.GtkHButtonBox subclass: OBGtkRadioButtonBar [
    | model activeButton |
    
    <category: 'OmniBrowser-Gtk'>
    <comment: nil>
    <import: GTK>

    OBGtkRadioButtonBar class >> new [
	<category: 'instance creation'>
        ^super new castTo: self type
    ]

    model: anObject [
	model ifNotNil: [model removeDependent: self].
	model := anObject.
	model ifNotNil: 
		[self refresh.
		model addDependent: self]
    ]

    refresh [
	| first button index |
	index := 0.
	model list do: 
		[:each | 
		index := index + 1.
		button := GtkToggleButton label: each.
		first ifNil: [first := button].
		self add: button.
		button 
		    connectSignal: 'toggled'
		    to: self
		    selector: #selectionOn:buttonNumber:
		    userData: index].
	first active: true
    ]

    selectionOn: aGtkToggleButton buttonNumber: anInteger [
	activeButton ifNotNil: [activeButton active: false].
	model selection: anInteger.
	activeButton := aGtkToggleButton
    ]

    update: aSymbol [
	aSymbol = #commands ifTrue: [self refresh]
    ]
]



GTK.GtkEntry subclass: OBGtkTextEntry [
    | model |
    
    <category: 'OmniBrowser-Gtk'>
    <comment: nil>
    <import: GTK>

    OBGtkTextEntry class >> new [
        <category: 'instance creation'>
        ^(super new castTo: self type) initialize
    ]

    accept [
	model accept: self getText notifying: self
    ]

    initialize [
	self
	    connectSignal: 'populate-popup'
		to: self
		selector: #popupMenuOn:menu:;
	    connectSignal: 'activate'
		to: self
		selector: #accept
    ]

    model: anObject [
	model ifNotNil: [model removeDependent: self].
	model := anObject.
	model ifNotNil: 
		[self refresh.
		model addDependent: self]
    ]

    popupMenuOn: aGtkTextView menu: aGtkMenu [
	| menu |
	menu := (OBGtkTextMenu new)
		    model: model;
		    menu: aGtkMenu.
	model 
	    menu: menu
	    shifted: false
	    selection: (OBTextSelection on: (1 to: self getTextLength) inText: self getText)
    ]

    refresh [
	self setText: (model text ifNil: [String new]) displayString
    ]

    update: aSymbol [
	aSymbol ifNil: [^self].
	aSymbol = #text ifTrue: [self refresh]
    ]
]



Object subclass: OBGtkTextMenu [
    | model menu separator |
    
    <category: 'OmniBrowser-Gtk'>
    <comment: nil>
    <import: GTK>

    OBGtkTextMenu class >> new [
        <category: 'instance creation'>
        ^self basicNew initialize
    ]

    add: aString action: aSymbol [
	self 
	    add: aString
	    target: model
	    selector: aSymbol
	    enabled: true
	    icon: nil
    ]

    add: aString target: anObject selector: aSymbol enabled: aBoolean icon: anIconSymbol [
	| item |
	self separator.
	item := (GtkMenuItem newWithLabel: aString)
		    connectSignal: 'activate'
			to: anObject
			selector: aSymbol;
		    show;
		    yourself.
	menu append: item
    ]

    addLine [
	menu append: (GtkSeparatorMenuItem new show; yourself)
    ]

    addSubmenu: aSymbol enabled: aBoolean [
	| submenu newMenu |
	self separator.
	submenu := (GtkMenuItem newWithLabel: aSymbol asString)
		    show;
		    yourself.
	newMenu := (OBGtkMenu new)
		    show;
		    yourself.
	submenu setSubmenu: newMenu.
	menu append: submenu.
	^newMenu
    ]

    initialize [
	separator := false
    ]

    menu: aGtkMenu [
	menu := aGtkMenu
    ]

    model: anObject [
	model := anObject
    ]

    separator [
	separator 
	    ifFalse: 
		[separator := true.
		self addLine]
    ]
]



GTK.GtkTextView subclass: OBGtkTextView [
    | buffer text model |
    
    <category: 'OmniBrowser-Gtk'>
    <comment: nil>
    <import: GTK>

    OBGtkTextView class >> new [
        <category: 'instance creation'>
        ^(super new castTo: self type)
	    initialize;
	    yourself
    ]

    accept [
	model accept: self text notifying: self
    ]

    initialize [
	buffer := GtkTextBuffer new: nil.
	self setBuffer: buffer.
	self
	    connectSignal: 'populate-popup'
		to: self
		selector: #popupMenuOn:menu:;
	    connectSignal: 'key-press-event'
		to: self
		selector: #keyPressedOn:event
    ]

    keyPressedOn: aGtkTextView event: aGdkEventKey [
	"TODO: accelerators?"
	"aGdkEventKey state = #controlMask 
	    ifTrue: 
		[(GdkKeymapKey characterName: aGdkEventKey keyval) = 's' 
		    ifTrue: 
			[self accept.
			^true]]."
	^false
    ]

    model: anObject [
	model ifNotNil: [model removeDependent: self].
	model := anObject.
	model ifNotNil: 
		[self refresh.
		model addDependent: self]
    ]

    popupMenuOn: aGtkTextView menu: aGtkMenu [
	| menu text |
	menu := (OBGtkTextMenu new)
		    model: model;
		    menu: aGtkMenu.
	text := self text.
	model 
	    menu: menu
	    shifted: false
	    selection: (OBTextSelection on: (1 to: text size) inText: text)
	"aGtkMenu showAll"
    ]

    refresh [
	buffer setText: (model text ifNil: [String new]) asString
    ]

    text [
	| start end |
	start := GtkTextIter type gcNew.
	end := GtkTextIter type gcNew.
	buffer getIterAtOffset: start charOffset: 0.
	buffer getIterAtOffset: end charOffset: -1.
	^buffer getText: start end: end includeHiddenChars: false
    ]

    update: aSymbol [
	aSymbol ifNil: [^self].
	aSymbol = #text ifTrue: [self refresh].
    ]
]



GTK.GtkTreeView subclass: OBGtkTreePane [
    | table model update |
    
    <category: 'OmniBrowser-Gtk'>
    <comment: nil>
    <import: GTK>

    OBGtkTreePane class >> new [
        <category: 'instance creation'>
        ^(super new castTo: self type) initialize
    ]

    buttonPressOn: aGtkTreeView event: event [
	| menu buttonEvent |
	buttonEvent := event castTo: GTK.GdkEventButton type.
	buttonEvent button ~= 3 ifTrue: [^false].
	menu := OBGtkMenu new.
	model menu: menu.
	menu
	    showAll;
	    popupParentMenuShell: nil
		parentMenuItem: nil
		button: 0
		activateTime: 0.
	^true
    ]

    initialize [
	| col rend |
	update := false.
	table := GtkListStore new: 1 varargs: {GValue gTypeString}.
	col := GtkTreeViewColumn new.
	self insertColumn: col position: -1.
	col packStart: (rend := GtkCellRendererText new) expand: true.
	col
	    addAttribute: rend
	    attribute: 'text'
	    column: 0.
	self setModel: table.
	self setHeadersVisible: false.
	self 
	    connectSignal: 'button-press-event'
	    to: self
	    selector: #buttonPressOn:event:.
	self getSelection 
	    connectSignal: 'changed'
	    to: self
	    selector: #onTreeChanged
    ]

    model: anObject [
	model ifNotNil: [model removeDependent: self].
	model := anObject.
	self refresh.
	model ifNotNil: [model addDependent: self]
    ]

    onTreeChanged [
        | sel pos iter path |
        sel := self getSelection.
        iter := GtkTreeIter type gcNew.
        sel getSelected: nil iter: iter.

	"FIXME: There are race condition on the validity of the iterator."
        path := table getPath: iter.
        pos := [ path toString asInteger ] ensure: [ path free ].
	update := true.
        model selection: pos + 1.
	update := false
    ]

    refresh [
	| iter |
	table clear.
	model ifNotNil: [
	    iter := GtkTreeIter type gcNew.
	    model list do: [:each |
	        table append: iter.
	        table set: iter varargs: {0. each asString. -1}]].
    ]

    selectionIndex: anInteger [
	| selection path |
	update ifTrue: [^self].
	selection := self getSelection.
	selection unselectAll.
	model list isEmpty ifTrue: [^self].
	path := GtkTreePath newFromIndices: anInteger - 1 varargs: #(-1).
	[ selection selectPath: path ] ensure: [ path free ]
    ]

    update: aSymbol [
	aSymbol = #list ifTrue: [self refresh].
	aSymbol = #selection ifTrue: [self selectionIndex: model selection]
    ]
]



GTK.GtkVBox subclass: OBGtkPane [
    <category: 'Gtk-OmniBrowser'>
    <import: GTK>

    | tree model table button |

    OBGtkPane class >> new [
        <category: 'instance creation'>
        ^(self new: false spacing: 0) castTo: self type
    ]

    button: aRadioButtonBar [
	button ifNotNil: [self remove: button].
	button := aRadioButtonBar.
	self packStart: button expand: false fill: false padding: 0
    ]

    hasButton [
	^button isNil not
    ]

    list [
	^ tree
    ]

    model: anObject [
	model ifNotNil: [model removeDependent: self].
	model := anObject.
	model ifNotNil: [model addDependent: self].
	tree model: model
    ]

    refresh [
	model wantsButton
		ifTrue: [self add: button]
		ifFalse: [self remove: button]
    ]

    treePane: anObGtkTreePane [
	| scroll |
	tree := anObGtkTreePane.
	scroll := GtkScrolledWindow new: nil vadjustment: nil.
	scroll
	    setPolicy: Gtk gtkPolicyAutomatic
	    vscrollbarPolicy: Gtk gtkPolicyAutomatic;
	    add: tree.

	self add: scroll
    ]

    update: aSelector [
	aSelector = #switch ifFalse: [^ self].
	self hasButton = model wantsButton ifTrue: [^ self].
	button ifNotNil: [self refresh]
    ]
]

