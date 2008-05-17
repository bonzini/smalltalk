"this file is distributed under the GNU Lesser General Public License"

"  list.st "

"  This program demonstrates hox to make and execute a "

"  display list. Note that attributes, such as current color and"

"  matrix, are changed. "



Eval [
    PackageLoader fileInPackage: 'OpenGL'.
    PackageLoader fileInPackage: 'GLUT'
]



Namespace current: OpenGL [

Object subclass: List [
    | aWindow windowNumber listName |
    
    <category: 'OpenGL'>
    <comment: nil>

    init [
	<category: 'init'>
	aWindow := Glut new.
	aWindow glutInit: 'une surface smalltalkienne'.
	aWindow glutInitDisplayMode: ((Glut glutRgb bitOr: Glut glutSingle) 
		    bitOr: Glut glutDepth).
	aWindow glutInitWindowSize: (Point x: 650 y: 50).
	aWindow glutInitWindowPosition: (Point x: 100 y: 100).
	windowNumber := aWindow glutCreateWindow: 'Une surface nurbs'.
	listName := aWindow glGenLists: 1.
	aWindow glNewList: listName mode: OpenGLInterface glCompile.
	aWindow glColor: Color red.
	aWindow glBegin: OpenGLInterface glTriangles.
	aWindow glVertex: (Vertex x: 0.0 y: 0.0).
	aWindow glVertex: (Vertex x: 1.0 y: 0.0).
	aWindow glVertex: (Vertex x: 0.0 y: 1.0).
	aWindow glEnd.
	aWindow glTranslate: (Vertex 
		    x: 1.5
		    y: 0.0
		    z: 0.0).
	aWindow glEndList.
	aWindow glShadeModel: OpenGLInterface glFlat.
	aWindow 
	    addCallback: Glut displayFuncEvent
	    to: self
	    selector: #display.
	aWindow 
	    addCallback: Glut reshapeFuncEvent
	    to: self
	    selector: #reshape:height:
    ]

    reshape: w height: h [
	<category: 'init'>
	aWindow glViewport: (Vertex x: 0 y: 0) extend: (Vertex x: w y: h).
	aWindow glMatrixMode: OpenGLInterface glProjection.
	aWindow glLoadIdentity.
	w <= h 
	    ifTrue: 
		[aWindow 
		    gluOrtho2D: 0.0
		    right: 2.0
		    bottom: -0.5 * h / w
		    top: 1.5 * h / w]
	    ifFalse: 
		[aWindow 
		    gluOrtho2D: 0.0
		    right: 2.0 * w / h
		    bottom: -0.5
		    top: 1.5].
	aWindow glMatrixMode: OpenGLInterface glModelview.
	aWindow glLoadIdentity
    ]

    drawLine [
	<category: 'init'>
	aWindow glBegin: OpenGLInterface glLines.
	aWindow glVertex: (Vertex x: 0.0 y: 0.5).
	aWindow glVertex: (Vertex x: 15.0 y: 0.5).
	aWindow glEnd
    ]

    mainIteration [
	aWindow mainIteration
    ]

    display [
	<category: 'init'>
	aWindow glClear: OpenGLInterface glColorBufferBit.
	aWindow glColor: Color green.
	(1 to: 10) do: [:i | aWindow glCallList: listName].
	self drawLine.
	aWindow glFlush
    ]
]

]



Namespace current: OpenGL [
    List new init; mainIteration.
    Processor activeProcess suspend

]

