" OpenGL class "



Object subclass: OpenGLInterface [
    <category: 'OpenGL'>
    <comment: 'My instances are interfaces to OpenGL library with access to GL,  and Glu.
See OpenGL programming guide for more informations.'>

    Current := nil.
    OpenGLInterface class >> current [
	Current isNil ifTrue: [ Current := self new ].
	^Current
    ]

    glClearColor: aColor [
	<category: 'GL'>
	self 
	    cacheGlClearColor: aColor red
	    green: aColor green
	    blue: aColor blue
    ]

    cacheGlClearColor: aRed green: aGreen blue: aBlue [
	<category: 'GL'>
	<cCall: 'glClearColor' returning: #void args: #( #float #float #float )>
	
    ]

    glShadeModel: aModel [
	<category: 'GL'>
	<cCall: 'glShadeModel' returning: #void args: #( #int )>
	
    ]

    glClear: aClear [
	<category: 'GL'>
	<cCall: 'glClear' returning: #void args: #( #int )>
	
    ]

    glColor3f: aColor [
	<category: 'GL'>
	self 
	    glColor3f: aColor red
	    green: aColor green
	    blue: aColor blue
    ]

    glColor3f: aRed green: aGreen blue: aBlue [
	<category: 'GL'>
	<cCall: 'glColor3f' returning: #void args: #( #float #float #float )>
	
    ]

    glLoadIdentity [
	<category: 'GL'>
	<cCall: 'glLoadIdentity' returning: #void args: #()>
	
    ]

    glScalef: aVertex [
	<category: 'GL'>
	self 
	    glScalef: aVertex x
	    y: aVertex y
	    z: aVertex z
    ]

    glScalef: anX y: anY z: anZ [
	<category: 'GL'>
	<cCall: 'glScalef' returning: #void args: #( #float #float #float )>
	
    ]

    glFlush [
	<category: 'GL'>
	<cCall: 'glFlush' returning: #void args: #()>
	
    ]

    glFrustum: left right: right bottom: bottom top: top near: near far: far [
	<category: 'GL'>
	<cCall: 'glFrustum' returning: #void args: #( #double #double #double #double #double #double )>
	
    ]

    glOrtho: left right: right bottom: bottom top: top near: near far: far [
	<category: 'GL'>
	<cCall: 'glOrtho' returning: #void args: #( #double #double #double #double #double #double )>
	
    ]

    glViewport: aVertex extend: extend [
	<category: 'GL'>
	self 
	    glViewport: aVertex x asInteger
	    y: aVertex y asInteger
	    width: extend x asInteger
	    height: extend y asInteger
    ]

    glViewport: x y: y width: width height: height [
	<category: 'GL'>
	<cCall: 'glViewport' returning: #void args: #(#int #int #int #int)>
	
    ]

    glRotatef: angle direction: aVertex [
	<category: 'GL'>
	^self 
	    glRotatef: angle
	    x: aVertex x
	    y: aVertex y
	    z: aVertex z
    ]

    glRotatef: angle x: anX y: aY z: aZ [
	<category: 'GL'>
	<cCall: 'glRotatef' returning: #void args: #( #float #float #float #float)>
	
    ]

    glRotated: angle x: anX y: aY z: aZ [
	<category: 'GL'>
	<cCall: 'glRotated' returning: #void args: #( #double #double #double #double)>
	
    ]

    glTranslatef: aVertex [
	<category: 'GL'>
	self 
	    glTranslatef: aVertex x
	    y: aVertex y
	    z: aVertex z
    ]

    glTranslatef: x y: y z: z [
	<category: 'GL'>
	<cCall: 'glTranslatef' returning: #void args: #( #float #float #float)>
	
    ]

    glTranslated: aVertex [
	<category: 'GL'>
	self 
	    glTranslated: aVertex x
	    y: aVertex y
	    z: aVertex z
    ]

    glTranslated: aX y: aY z: aZ [
	<category: 'GL'>
	<cCall: 'glTranslated' returning: #void args: #( #int #int #int )>
	
    ]

    glLightPosition: number position: aVertex [
	<category: 'GL'>
	self 
	    glLightfv: number
	    property: OpenGLInterface glPosition
	    value: aVertex
    ]

    glLightfv: lightNumber property: aProp value: anArray [
	<category: 'GL'>
	<cCall: 'glLightfv' returning: #void args: #( #int #int #cObject )>
	
    ]

    glLightiv: lightNumber property: aProp value: anArray [
	<category: 'GL'>
	<cCall: 'glLightiv' returning: #void args: #( #int #int #cObject )>
	
    ]

    glEnable: aProperty [
	<category: 'GL'>
	<cCall: 'glEnable' returning: #void args: #( #int )>
	
    ]

    glDisable: aProperty [
	<category: 'GL'>
	<cCall: 'glDisable' returning: #void args: #( #int )>
	
    ]

    glColorMaterial: aFace mode: aMode [
	<category: 'GL'>
	<cCall: 'glColorMaterial' returning: #void args: #( #int #int )>
	
    ]

    glMaterialf: aFace mode: aMode value: aValue [
	<category: 'GL'>
	<cCall: 'glMaterialf' returning: #void args: #( #int #int #float )>
	
    ]

    glMaterialfv: aFace mode: aMode value: anArray [
	<category: 'GL'>
	<cCall: 'glMaterialfv' returning: #void args: #( #int #int #cObject )>
	
    ]

    glMaterialiv: aFace mode: aMode value: anArray [
	<category: 'GL'>
	<cCall: 'glMaterialiv' returning: #void args: #( #int #int #cObject )>
	
    ]

    glEvalCoord2f: aX y: aY [
	<category: 'GL'>
	<cCall: 'glEvalCoord2f' returning: #void args: #( #float #float )>
	
    ]

    glBegin: type [
	<category: 'GL'>
	<cCall: 'glBegin' returning: #void args: #(#int)>
	
    ]

    glEnd [
	<category: 'GL'>
	<cCall: 'glEnd' returning: #void args: #()>
	
    ]

    glPointSize: size [
	<category: 'GL'>
	<cCall: 'glPointSize' returning: #void args: #(#float)>
	
    ]

    glVertex2f: aPoint [
	<category: 'GL'>
	self glVertex2f: aPoint x y: aPoint y
    ]

    glVertex2f: aX y: aY [
	<category: 'GL'>
	<cCall: 'glVertex2f' returning: #void args: #(#float #float)>
	
    ]

    glVertex3f: aPoint [
	<category: 'GL'>
	self 
	    glVertex3f: aPoint x
	    y: aPoint y
	    z: aPoint z
    ]

    glVertex3f: aX y: aY z: aZ [
	<category: 'GL'>
	<cCall: 'glVertex3f' returning: #void args: #(#float #float #float)>
	
    ]

    glNormal3f: aPoint [
	<category: 'GL'>
	self 
	    glNormal3f: aPoint x
	    y: aPoint y
	    z: aPoint z
    ]

    glNormal3f: aX y: aY z: aZ [
	<category: 'GL'>
	<cCall: 'glNormal3f' returning: #void args: #(#float #float #float)>
	
    ]

    glPixelStorei: param value: aValue [
	<category: 'GL'>
	<cCall: 'glPixelStorei' returning: #void args: #(#int #int)>
	
    ]

    glPixelStoref: param value: aValue [
	<category: 'GL'>
	<cCall: 'glPixelStoref' returning: #void args: #(#int #float)>
	
    ]

    glMatrixMode [
	<category: 'Matrix manipulation'>
	^(self getIntegerv: OpenGLInterface glMatrixMode) at: 1
    ]

    glMatrixMode: mode [
	<category: 'Matrix manipulation'>
	<cCall: 'glMatrixMode' returning: #void args: #( #int )>
	
    ]

    glPushMatrix [
	<category: 'Matrix manipulation'>
	<cCall: 'glPushMatrix' returning: #void args: #( )>
	
    ]

    glPopMatrix [
	<category: 'Matrix manipulation'>
	<cCall: 'glPopMatrix' returning: #void args: #( )>
	
    ]

    loadMatrixf: aMatrix [
	<category: 'Matrix manipulation'>
	<cCall: 'glLoadMatrixf' retuning: #void args: #(#cObject)>
	
    ]

    multMatrixf: aMatrix [
	<category: 'Matrix manipulation'>
	<cCall: 'glMultMatrixf' retuning: #void args: #(#cObject)>
	
    ]

    loadMatrixd: aMatrix [
	<category: 'Matrix manipulation'>
	<cCall: 'glLoadMatrixd' retuning: #void args: #(#cObject)>
	
    ]

    multMatrixd: aMatrix [
	<category: 'Matrix manipulation'>
	<cCall: 'glMultMatrixd' retuning: #void args: #(#cObject)>
	
    ]

    multiplyMatrix: aMatrix for: aMode [
	"Save the current matrix mode, sets the requested mode, multiply the"

	"matrix, get back to the corrent matrix mode"

	<category: 'Matrix manipulation'>
	| currentMode |
	currentMode := self matrixMode.
	self matrixMode: aMode.
	self multMatrix: aMatrix.
	self matrixMode: currentMode
    ]

    setMatrix: aMatrix for: aMode [
	"Save the current matrix mode, sets the requested mode, sets the"

	"matrix, get back to the corrent matrix mode"

	<category: 'Matrix manipulation'>
	| currentMode |
	currentMode := self matrixMode.
	self matrixMode: aMode.
	self loadMatrix: aMatrix.
	self matrixMode: currentMode
    ]

    getModelviewMatrix [
	<category: 'Matrix retreiving'>
	^self getMatrixFor: OpenGLInterface glModelviewMatrix
    ]

    getProjectionMatrix [
	<category: 'Matrix retreiving'>
	^self getMatrixFor: OpenGLInterface glProjectionMatrix
    ]

    getTextureMatrix [
	<category: 'Matrix retreiving'>
	^self getMatrixFor: OpenGLInterface glTextureMatrix
    ]

    getMatrixFor: aMode [
	<category: 'Matrix retreiving'>
	^Matrix16f new loadFrom: (self glGetFloatv: aMode)
    ]

    glIsList: listNum [
	<category: 'Display List'>
	<cCall: 'glIsList' returning: #boolean args: #( #int ) >
	
    ]

    glDeleteLists: listNum range: range [
	<category: 'Display List'>
	<cCall: 'glDeleteLists' returning: #void args: #( #int #int ) >
	
    ]

    glGenLists: range [
	<category: 'Display List'>
	<cCall: 'glGenLists' returning: #int args: #( #int )>
	
    ]

    glNewList: list mode: mode [
	<category: 'Display List'>
	<cCall: 'glNewList' returning: #void args: #( #int #int ) >
	
    ]

    glEndList [
	<category: 'Display List'>
	<cCall: 'glEndList' returning: #void args: #( ) >
	
    ]

    glCallList: list [
	<category: 'Display List'>
	<cCall: 'glCallList' returning: #void args: #( #int ) >
	
    ]

    glCallLists: n type: type lists: lists [
	<category: 'Display List'>
	<cCall: 'glCallLists' returning: #void args: #( #int #int #cObject ) >
	
    ]

    glListBase: base [
	<category: 'Display List'>
	<cCall: 'glListBase' returning: #void args: #( #int ) >
	
    ]

    glTexEnvf: target property: aProperty value: aValue [
	<category: 'Textures'>
	<cCall: 'glTexEnvf' returning: #void args: #(#int #int #float)>
	
    ]

    glTexEnvi: target property: aProperty value: aValue [
	<category: 'Textures'>
	<cCall: 'glTexEnvi' returning: #void args: #(#int #int #int)>
	
    ]

    glTexParameteri: target property: aProperty value: aValue [
	<category: 'Textures'>
	<cCall: 'glTexParameteri' returning: #void args: #(#int #int #int)>
	
    ]

    glTexImage1D: target level: level internalFormat: internalFormat width: aWidht border: aBorder format: aFormat type: aType pixels: pixels [
	<category: 'Textures'>
	<cCall: 'glTexImage1D' returning: #void args: #(#int #int #int #int #int #int #int #byteArray)>
	
    ]

    glTexImage2D: target level: level internalFormat: internalFormat width: aWidht height: aHeight border: aBorder format: aFormat type: aType pixels: pixels [
	<category: 'Textures'>
	<cCall: 'glTexImage2D' returning: #void args: #(#int #int #int #int #int #int #int #int #byteArray)>
	
    ]

    glTexGeni: coord property: pName value: aValue [
	<category: 'Textures'>
	<cCall: 'glTexGeni' returning: #void args: #(#int #int #int)>
	
    ]

    glTexGenf: coord property: pName value: aValue [
	<category: 'Textures'>
	<cCall: 'glTexGeni' returning: #void args: #(#int #int #float)>
	
    ]

    glMap1f: target u1: u1 u2: u2 ustride: uStride uorder: uOrdrer points: arrayOfPoints [
	<category: 'Map'>
	<cCall: 'glMap1f' returning: #void args: #(#int #float #float #int #int #cObject)>
	
    ]

    glMap1d: target u1: u1 u2: u2 ustride: uStride uorder: uOrdrer points: arrayOfPoints [
	<category: 'Map'>
	<cCall: 'glMap1d' returning: #void args: #(#int #double #double #int #int #cObject)>
	
    ]

    glMap2f: target u1: u1 u2: u2 ustride: uStride uorder: uOrdrer v1: v1 v2: v2 vstride: vStride vorder: vOrder points: arrayOfPoints [
	<category: 'Map'>
	<cCall: 'glMap2f' returning: #void args: #(#int #float #float #int #int #float #float #int #int #cObject)>
	
    ]

    glMap2d: target u1: u1 u2: u2 ustride: uStride uorder: uOrdrer v1: v1 v2: v2 vstride: vStride vorder: vOrder points: arrayOfPoints [
	<category: 'Map'>
	<cCall: 'glMap2d' returning: #void args: #(#int #double #double #int #int #double #double #int #int #cObject)>
	
    ]

    glMapGrid2f: nu u1: u1 u2: u2 nv: nv v1: v1 v2: v2 [
	<category: 'Map'>
	<cCall: 'glMapGrid2f' returning: #void args: #(#int #float #float #int #float #float )>
	
    ]

    glMapGrid2d: nu u1: u1 u2: u2 nv: nv v1: v1 v2: v2 [
	<category: 'Map'>
	<cCall: 'glMapGrid2f' returning: #void args: #(#int #double #double #int #double #double )>
	
    ]

    glEvalMesh2: mode i1: aI1 i2: aI2 j1: aJ1 j2: aJ2 [
	<category: 'Map'>
	<cCall: 'glEvalMesh2' returning: #void args: #(#int #int #int #int #int )>
	
    ]

    glGetFloatv: mode [
	"the returned value is an array of floating point values"

	<category: 'Get functions'>
	<cCall: 'glGetFloatv' returning: #smalltalk args: #(#int)>
	
    ]

    glGetIntegerv: mode [
	"the returned value is an array of integer"

	<category: 'Get functions'>
	<cCall: 'glGetIntegerv' returning: #smalltalk args: #(#int)>
	
    ]
]

