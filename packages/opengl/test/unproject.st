"this file is distributed under the GNU Lesser General Public License"

"   unproject.st "

"   When the left mouse button is pressed, this program  "

"   reads the mouse position and determines two 3D points  "

"   from which it was transformed.  Very little is displayed. "



Eval [
    PackageLoader fileInPackage: 'OpenGL'.
    PackageLoader fileInPackage: 'GLUT'
]



Namespace current: OpenGL [

Object subclass: UnProject [
    | aWindow |
    
    <category: 'OpenGL'>
    <comment: nil>

    mainIteration [
	aWindow mainIteration
    ]

    display [
	<category: 'callbacks'>
	aWindow glClear: OpenGLInterface glColorBufferBit.
	aWindow glFlush
    ]

    reshape: w height: h [
	<category: 'callbacks'>
	aWindow glViewport: (Vertex x: 0 y: 0) extend: (Vertex x: w y: h).
	aWindow glMatrixMode: OpenGLInterface glProjection.
	aWindow glLoadIdentity.
	aWindow 
	    gluPerspective: 45.0
	    aspect: 1.0 * w / h
	    near: 1.0
	    far: 100.0.
	aWindow glMatrixMode: OpenGLInterface glModelview.
	aWindow glLoadIdentity
    ]

    mouse: aButton state: aState x: x y: y [
	<category: 'callbacks'>
	| viewport extent mvMatrix projMatrix realy anArray aVertex |
	(aButton = Glut glutLeftButton and: [aState = Glut glutDown]) 
	    ifTrue: 
		[anArray := aWindow glGetIntegerv: OpenGLInterface glViewport.
		viewport := Vertex 
			    x: (anArray at: 1)
			    y: (anArray at: 2)
			    z: (anArray at: 3)
			    w: (anArray at: 4).	"x"	"y"	"width"	"height"
		mvMatrix := Matrix16f new loadFrom: (aWindow glGetFloatv: OpenGLInterface glModelviewMatrix).
		projMatrix := Matrix16f new loadFrom: (aWindow glGetFloatv: OpenGLInterface glProjectionMatrix).
		realy := (viewport w - y - 1) asInteger.
		Transcript
		    show: 'Coordinates at cursor are (' , x printString , ',' 
				, realy printString , ')';
		    nl.
		aVertex := aWindow 
			    unProject: x
			    y: realy
			    z: 0.0
			    modelview: mvMatrix
			    projection: projMatrix
			    viewport: viewport.
		Transcript
		    show: 'World Coordinates at z=0.0 are ' , aVertex printString;
		    nl.
		aVertex := aWindow 
			    unProject: x
			    y: realy
			    z: 1.0
			    modelview: mvMatrix
			    projection: projMatrix
			    viewport: viewport.
		Transcript
		    show: 'World Coordinates at z=1.0 are ' , aVertex printString;
		    nl]
    ]

    init [
	<category: 'initialization'>
	aWindow := Glut new.
	aWindow glutInit: 'UnProject'.
	aWindow glutInitDisplayMode: (Glut glutRgb bitOr: Glut glutSingle).
	aWindow glutInitWindowSize: (Point x: 500 y: 500).
	aWindow glutInitWindowPosition: (Point x: 100 y: 100).
	aWindow glutCreateWindow: 'UnProject'.
	aWindow 
	    addCallback: Glut displayFuncEvent
	    to: self
	    selector: #display.
	aWindow 
	    addCallback: Glut reshapeFuncEvent
	    to: self
	    selector: #reshape:height:.
	aWindow 
	    addCallback: Glut mouseFuncEvent
	    to: self
	    selector: #mouse:state:x:y:
    ]
]

]



Namespace current: OpenGL [
    UnProject new init; mainIteration.
    Processor activeProcess suspend

]

