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

]

