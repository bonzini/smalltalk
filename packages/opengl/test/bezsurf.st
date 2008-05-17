"this file is distributed under the GNU Lesser General Public License"



Eval [
    PackageLoader fileInPackage: 'OpenGL'.
    PackageLoader fileInPackage: 'GLUT'
]



Namespace current: OpenGL [

Object subclass: OpenGLTest [
    | aWindow windowNumber eyePosition axeX axeY axeZ saveX |
    
    <category: 'OpenGL'>
    <comment: nil>

    controlPoints [
	<category: 'test'>
	^#(-1.5 -1.5 4.0 -0.5 -1.5 2.0 0.5 -1.5 -1.0 1.5 -1.5 2.0 -1.5 -0.5 1.0 -0.5 -0.5 3.0 0.5 -0.5 0.0 1.5 -0.5 -1.0 -1.5 0.5 4.0 -0.5 0.5 0.0 0.5 0.5 3.0 1.5 0.5 4.0 -1.5 1.5 -2.0 -0.5 1.5 -2.0 0.5 1.5 0.0 1.5 1.5 -1.0)
    ]

    init [
	"Define the position of the eye"

	<category: 'test'>
	eyePosition := Vertex 
		    x: 0.0
		    y: 0.0
		    z: 5.0.
	axeX := false.
	axeY := false.
	axeZ := false.

	"Create the window and initialize callbacks"
	aWindow isNil 
	    ifTrue: 
		[aWindow := Glut new.
		aWindow glutInit: 'une surface smalltalkienne'.
		aWindow glutInitDisplayMode: ((Glut glutRgb bitOr: Glut glutSingle) 
			    bitOr: Glut glutDepth).
		aWindow glutInitWindowSize: (Point x: 500 y: 500).
		aWindow glutInitWindowPosition: (Point x: 100 y: 100).
		windowNumber := aWindow glutCreateWindow: 'Une sphere...'.

		"Init window color and shading model"
		aWindow glClearColor: Color black.

		"self controlPoints inspect."
		aWindow 
		    glMap2: OpenGLInterface glMap2Vertex3
		    u1: 0.0
		    u2: 1.0
		    ustride: 3
		    uorder: 4
		    v1: 0.0
		    v2: 1.0
		    vstride: 12
		    vorder: 4
		    points: self controlPoints.
		aWindow glEnable: OpenGLInterface glMap2Vertex3.
		aWindow 
		    glMapGrid2f: 20
		    u1: 0.0
		    u2: 1.0
		    nv: 20
		    v1: 0.0
		    v2: 1.0.
		aWindow glEnable: OpenGLInterface glDepthTest.
		aWindow glShadeModel: OpenGLInterface glFlat.
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
	aWindow glColor: Color white.
	aWindow glPushMatrix.
	aWindow 
	    glRotatef: 85.0
	    x: 1.0
	    y: 1.0
	    z: 1.0.
	(0 to: 8) do: 
		[:j | 
		aWindow glBegin: OpenGLInterface glLineStrip.
		(0 to: 30) do: [:i | aWindow glEvalCoord2f: i / 30.0 y: j / 8.0].
		aWindow glEnd.
		aWindow glBegin: OpenGLInterface glLineStrip.
		(0 to: 30) do: [:i | aWindow glEvalCoord2f: j / 8.0 y: i / 30.0].
		aWindow glEnd].
	"aWindow glutWireTeapot: 1.0."
	aWindow glPopMatrix.
	aWindow glFlush
    ]

    reshape: w height: h [
	<category: 'test'>
	aWindow glViewport: (Point x: 0 y: 0) extend: (Point x: w y: h).
	aWindow glMatrixMode: OpenGLInterface glProjection.
	aWindow glLoadIdentity.
	w <= h 
	    ifTrue: 
		[aWindow 
		    glOrtho: -4.0
		    right: 4.0
		    bottom: -4.0 * h / w
		    top: 4.0 * h / w
		    near: -4.0
		    far: 4.0]
	    ifFalse: 
		[aWindow 
		    glOrtho: -4.0 * w / h
		    right: 4.0 * w / h
		    bottom: -4.0
		    top: 4.0
		    near: -4.0
		    far: 4.0].
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

