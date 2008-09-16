OBBuilderTest subclass: OBFakeBuilderTest [
    
    <comment: nil>
    <category: 'OB-Fake-Tests'>

    builderClass [
	<category: 'support'>
	^OBFakeBuilder
    ]

    test01BrowserCreatesWindow [
	<category: 'tests'>
	| widget |
	widget := self buildWindow.
	self assert: (widget isKindOf: OBFakeWindow).
	self assert: widget model == model
    ]

    test02BrowserAddsPanels [
	<category: 'tests'>
	| widget |
	widget := self buildWindow.
	self assert: widget children size = 2.
	self assert: (widget children first isKindOf: OBFakeScroller).
	self assert: (widget children second isKindOf: OBFakeText)
    ]

    test03ColumnPanelAddsColumns [
	<category: 'tests'>
	| widget |
	widget := self buildNavigationPanel.
	self assert: widget children size = 4.
	widget children do: [:ea | self assert: (ea isKindOf: OBFakePane)]
    ]

    test04ColumnAddsList [
	<category: 'tests'>
	| pane |
	pane := self build: self columnWithFilter.
	self assert: (pane isKindOf: OBFakePane).
	self assert: (pane children first isKindOf: OBFakeList)
    ]

    test05ColumnAddsButton [
	<category: 'tests'>
	| pane |
	pane := self build: self columnWithFilter.
	self assert: (pane isKindOf: OBFakePane).
	self assert: (pane children second isKindOf: OBFakeRadioButtonBar)
    ]

    test09HasLabel [
	<category: 'tests'>
	| widget |
	widget := self buildWindow.
	self assert: widget label = 'OmniBrowser'
    ]

    tests08SwitchCanBeBuiltAlone [
	<category: 'tests'>
	| widget |
	widget := self build: self switch.
	self assert: (widget isKindOf: OBFakeRadioButtonBar)
    ]
]


TestCase subclass: OBFakeMenuTest [
    
    <comment: nil>
    <category: 'OB-Fake-Tests'>

    testAddItem [
	| menu |
	menu := OBFakeMenu new.
	menu 
	    add: 'test item'
	    target: self
	    selector: #clickTestItem
	    enabled: true
	    icon: #blank.
	self deny: (menu itemWithWording: 'test item') isNil
    ]

    testAddSubmenu [
	| menu submenu |
	menu := OBFakeMenu new.
	submenu := menu addSubmenu: 'test item' enabled: true.
	self assert: menu class == submenu class
    ]
]

