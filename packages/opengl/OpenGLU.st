OpenGLInterface extend [

    gluLookAt: anEye center: aCenter up: aDirection [
	<category: 'GLU'>
	self 
	    gluLookAt: anEye x
	    y: anEye y
	    z: anEye z
	    center: aCenter x
	    y: aCenter y
	    z: aCenter z
	    up: aDirection x
	    y: aDirection y
	    z: aDirection z
    ]

    gluLookAt: anEyeX y: anEyeY z: anEyeZ center: aCenterX y: aCenterY z: aCenterZ up: aDirectionX y: aDirectionY z: aDirectionZ [
	<category: 'GLU'>
	<cCall: 'gluLookAt' returning: #void args: #( #double #double #double #double #double #double #double #double #double )>
	
    ]

    gluOrtho2D: left right: right bottom: bottom top: top [
	<category: 'GLU'>
	<cCall: 'gluOrtho2D' returning: #void args: #( #double #double #double #double )>
	
    ]

    gluPerspective: fovy aspect: aspect near: zNear far: zFar [
	<category: 'GLU'>
	<cCall: 'gluPerspective' returning: #void args: #( #double #double #double #double)>
	
    ]

    gluBeginSurface: aNurb [
	<category: 'GLU'>
	^aNurb gluBeginSurface
    ]

    gluEndSurface: aNurb [
	<category: 'GLU'>
	^aNurb gluEndSurface
    ]

    gluUnProject: x y: y z: z modelview: mvMatrix projection: projMatrix viewport: aViewport [
	<category: 'GLU'>
	<cCall: 'gluUnProject' returning: #smalltalk args: #( #double #double #double #smalltalk #smalltalk #smalltalk )>
	
    ]

    gluUnProject: aVertex modelview: mvMatrix projection: projMatrix viewport: aViewport [
	<category: 'GLU'>
	self 
	    gluUnProject: aVertex x
	    y: aVertex y
	    z: aVertex z
	    modelview: mvMatrix
	    projection: projMatrix
	    viewport: aViewport
    ]

    unProject: x y: y z: z modelview: mvMatrix projection: projMatrix viewport: aViewport [
	<category: 'GLU'>
	| anArray |
	anArray := self 
		    gluUnProject: x asFloat
		    y: y asFloat
		    z: z asFloat
		    modelview: mvMatrix
		    projection: projMatrix
		    viewport: aViewport.
	^Vertex new load: anArray
    ]

]

