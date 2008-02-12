Object extend [
   restoreFromSnapshot: anObject [
        <category: '*Seaside-Core'>
	self basicSize = anObject basicSize
	    ifFalse: [ self become: (self class basicNew: anObject basicSize) ].
	self class instSize = anObject class instSize
	    ifFalse: [ self halt ].
        1 to: self class instSize do: [ :i |
	    self instVarAt: i put: (anObject instVarAt: i) ].
        1 to: self basicSize do: [ :i |
	    self basicAt: i put: (anObject basicAt: i) ]
    ]
]
