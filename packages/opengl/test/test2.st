"this file is distributed under the GNU Lesser General Public License"



Eval [
    PackageLoader fileInPackage: 'OpenGL'.
    PackageLoader fileInPackage: 'GLUT'
]



Namespace current: OpenGL [

Object subclass: OpenGLTest [
    | aWindow windowNumber axeX axeY axeZ saveX |
    
    <category: 'OpenGL'>
    <comment: nil>

    init [
	"Define the position of the eye"

	<category: 'test'>
	axeX := false.
	axeY := false.
	axeZ := false.
	"Create the window and initialize callbacks"
	aWindow isNil 
	    ifTrue: 
		[aWindow := Glut new.
		aWindow glutInit: 'une sphere smalltalkienne'.
		aWindow glutInitDisplayMode: ((Glut glutRgb bitOr: Glut glutDouble) 
			    bitOr: Glut glutDepth).
		aWindow glutInitWindowSize: (Vertex x: 500 y: 500).
		aWindow glutInitWindowPosition: (Vertex x: 100 y: 100).
		windowNumber := aWindow glutCreateWindow: 'Une sphere...'.

		"Init window color and shading model"
		aWindow glClearColor: Color black.
		aWindow glShadeModel: OpenGLInterface glSmooth.
		aWindow 
		    glMaterialv: OpenGLInterface glFront
		    mode: OpenGLInterface glSpecular
		    value: (Array 
			    with: 1.0
			    with: 1.0
			    with: 1.0
			    with: 1.0).
		aWindow 
		    glMaterialf: OpenGLInterface glFront
		    mode: OpenGLInterface glShininess
		    value: 50.0.
		aWindow 
		    glLightv: OpenGLInterface glLight0
		    property: OpenGLInterface glPosition
		    value: (Array 
			    with: 1.0
			    with: 1.0
			    with: 1.0
			    with: 0.0).
		aWindow glEnable: OpenGLInterface glLighting.
		aWindow glEnable: OpenGLInterface glLight0.
		aWindow glEnable: OpenGLInterface glDepthTest.
		aWindow 
		    addCallback: Glut displayFuncEvent
		    to: self
		    selector: #display.
		aWindow 
		    addCallback: Glut reshapeFuncEvent
		    to: self
		    selector: #reshape:height:]
    ]

    mainIteration [
	aWindow mainIteration
    ]

    display [
	<category: 'test'>
	aWindow glClear: (OpenGLInterface glColorBufferBit bitOr: OpenGLInterface glDepthBufferBit).
	aWindow 
	    glutSolidSphere: 1.0
	    slices: 50
	    stacks: 16.
	aWindow glutSwapBuffers
    ]

    reshape: w height: h [
	<category: 'test'>
	aWindow glViewport: (Vertex x: 0 y: 0) extend: (Vertex x: w y: h).
	aWindow glMatrixMode: OpenGLInterface glProjection.
	aWindow glLoadIdentity.
	w <= h 
	    ifTrue: 
		[aWindow 
		    glOrtho: -1.5
		    right: 1.5
		    bottom: -1.5 * h / w
		    top: 1.5 * h / w
		    near: -10.0
		    far: 10.0]
	    ifFalse: 
		[aWindow 
		    glOrtho: -1.5 * w / h
		    right: 1.5 * w / h
		    bottom: -1.5
		    top: 1.5
		    near: -10.0
		    far: 10.0].
	aWindow glMatrixMode: OpenGLInterface glModelview.
	aWindow glLoadIdentity
    ]

    window [
	<category: 'access'>
	^aWindow
    ]

    window: a [
	<category: 'access'>
	aWindow := a
    ]
]

]



Namespace current: OpenGL [
    OpenGLTest new init; mainIteration.
    Processor activeProcess suspend

]

