
OpenGLInterface extend [
    glutWireCube: aScale [
	<category: 'GLUT'>
	<cCall: 'glutWireCube' returning: #void args: #( #double )>
	
    ]

    glutSolidCube: aScale [
	<category: 'GLUT'>
	<cCall: 'glutSolidCube' returning: #void args: #( #double )>
	
    ]

    glutWireSphere: radius slices: slices stacks: stacks [
	<category: 'GLUT'>
	<cCall: 'glutWireSphere' returning: #void args: #( #double #int #int )>
	
    ]

    glutSolidSphere: radius slices: slices stacks: stacks [
	<category: 'GLUT'>
	<cCall: 'glutSolidSphere' returning: #void args: #( #double #int #int )>
	
    ]

    glutWireCone: base height: height slices: slices stacks: stacks [
	<category: 'GLUT'>
	<cCall: 'glutWireCone' returning: #void args: #( #double #double #int #int )>
	
    ]

    glutSolidCone: base height: height slices: slices stacks: stacks [
	<category: 'GLUT'>
	<cCall: 'glutSolidCone' returning: #void args: #( #double #double #int #int )>
	
    ]

    glutWireTorus: innerRadius outerRadius: outerRadius sides: sides stacks: stacks [
	<category: 'GLUT'>
	<cCall: 'glutWireCone' returning: #void args: #( #double #double #int #int )>
	
    ]

    glutSolidTorus: innerRadius outerRadius: outerRadius sides: sides stacks: stacks [
	<category: 'GLUT'>
	<cCall: 'glutSolidTorus' returning: #void args: #( #double #double #int #int )>
	
    ]

    glutWireDodecahedron [
	<category: 'GLUT'>
	<cCall: 'glutWireDodecahedron' returning: #void args: #( )>
	
    ]

    glutSolidDodecahedron [
	<category: 'GLUT'>
	<cCall: 'glutSolidDodecahedron' returning: #void args: #( )>
	
    ]

    glutWireOctahedron [
	<category: 'GLUT'>
	<cCall: 'glutWireOctahedron' returning: #void args: #( )>
	
    ]

    glutSolidOctahedron [
	<category: 'GLUT'>
	<cCall: 'glutSolidOctahedron' returning: #void args: #( )>
	
    ]

    glutWireTetrahedron [
	<category: 'GLUT'>
	<cCall: 'glutWireTetrahedron' returning: #void args: #( )>
	
    ]

    glutSolidTetrahedron [
	<category: 'GLUT'>
	<cCall: 'glutSolidTetrahedron' returning: #void args: #( )>
	
    ]

    glutWireIcosahedron [
	<category: 'GLUT'>
	<cCall: 'glutWireIcosahedron' returning: #void args: #( )>
	
    ]

    glutSolidIcosahedron [
	<category: 'GLUT'>
	<cCall: 'glutSolidIcosahedron' returning: #void args: #( )>
	
    ]

    glutWireTeapot: aScale [
	<category: 'GLUT'>
	<cCall: 'glutWireTeapot' returning: #void args: #( #double )>
	
    ]

    glutSolidTeapot: aScale [
	<category: 'GLUT'>
	<cCall: 'glutSolidTeapot' returning: #void args: #( #double )>
	
    ]
]
