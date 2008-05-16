Glut extend [

    | callbacks |

    Glut class >> createMenuEvent [
	<category: 'Events definition'>
	^1
    ]

    Glut class >> timerFuncEvent [
	<category: 'Events definition'>
	^2
    ]

    Glut class >> idleFuncEvent [
	<category: 'Events definition'>
	^3
    ]

    Glut class >> keyboardFuncEvent [
	<category: 'Events definition'>
	^4
    ]

    Glut class >> specialFuncEvent [
	<category: 'Events definition'>
	^5
    ]

    Glut class >> reshapeFuncEvent [
	<category: 'Events definition'>
	^6
    ]

    Glut class >> visibilityFuncEvent [
	<category: 'Events definition'>
	^7
    ]

    Glut class >> displayFuncEvent [
	<category: 'Events definition'>
	^8
    ]

    Glut class >> mouseFuncEvent [
	<category: 'Events definition'>
	^9
    ]

    Glut class >> motionFuncEvent [
	<category: 'Events definition'>
	^10
    ]

    Glut class >> passiveMotionFuncEvent [
	<category: 'Events definition'>
	^11
    ]

    Glut class >> entryFuncEvent [
	<category: 'Events definition'>
	^12
    ]

    Glut class >> keyboardUpFuncEvent [
	<category: 'Events definition'>
	^13
    ]

    Glut class >> specialUpFuncEvent [
	<category: 'Events definition'>
	^14
    ]

    Glut class >> joystickFuncEvent [
	<category: 'Events definition'>
	^15
    ]

    Glut class >> menuStateFuncEvent [
	<category: 'Events definition'>
	^16
    ]

    Glut class >> menuStatusFuncEvent [
	<category: 'Events definition'>
	^17
    ]

    Glut class >> overlayDisplayFuncEvent [
	<category: 'Events definition'>
	^18
    ]

    Glut class >> windowStatusFuncEvent [
	<category: 'Events definition'>
	^19
    ]

    Glut class >> spaceballMotionFuncEvent [
	<category: 'Events definition'>
	^20
    ]

    Glut class >> spaceballRotateFuncEvent [
	<category: 'Events definition'>
	^21
    ]

    Glut class >> spaceballButtonFuncEvent [
	<category: 'Events definition'>
	^22
    ]

    Glut class >> buttonBoxFuncEvent [
	<category: 'Events definition'>
	^23
    ]

    Glut class >> dialsFuncEvent [
	<category: 'Events definition'>
	^24
    ]

    Glut class >> tabletMotionFuncEvent [
	<category: 'Events definition'>
	^25
    ]

    Glut class >> tabletButtonFuncEvent [
	<category: 'Events definition'>
	^26
    ]

    Glut class >> mouseWheelFuncEvent [
	<category: 'Events definition'>
	^27
    ]

    Glut class >> closeFuncEvent [
	<category: 'Events definition'>
	^28
    ]

    Glut class >> wMCloseFuncEvent [
	<category: 'Events definition'>
	^29
    ]

    Glut class >> menuDestroyFuncEvent [
	<category: 'Events definition'>
	^30
    ]

    Glut class >> lastEventIndex [
	<category: 'Events definition'>
	^30
    ]

    callbacks [
	<category: 'callbacks definition'>
	^callbacks
    ]

    addCallback: anEvent to: anObject selector: aSelector [
	<category: 'callbacks definition'>
	callbacks isNil 
	    ifTrue: [callbacks := Array new: Glut lastEventIndex withAll: nil].
	callbacks at: anEvent put: (Array with: anObject with: aSelector).
	self connect: anEvent.
	^self
    ]

    getCallback: anEvent [
	<category: 'callbacks definition'>
	^callbacks at: anEvent
    ]

    connect: event [
	<category: 'Main interactions'>
	<cCall: 'openglutConnectSignal' 
		returning: #void
		args: #( #selfSmalltalk  #int )>
	
    ]

]

