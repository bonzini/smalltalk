"======================================================================
|
|   Semaphore Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2008
| Free Software Foundation, Inc.
| Written by Steve Byrne.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Object subclass: Semaphore [
    | waitQueue name |
    
    <category: 'Language-Processes'>
    <comment: 'My instances represent counting semaphores.  I provide methods for signalling
the semaphore''s availability, and methods for waiting for its availability.
I also provide some methods for implementing critical sections.'>

    Semaphore class >> new [
	"Answer a new semaphore"

	<category: 'instance creation'>
	^self basicNew initialize
    ]

    Semaphore class >> forMutualExclusion [
	"Answer a new semaphore with a signal on it. These semaphores are a useful
	 shortcut when you use semaphores as critical sections."

	<category: 'instance creation'>
	^(self new)
	    signal;
	    yourself
    ]

    critical: aBlock [
	"Wait for the receiver to be free, execute aBlock and signal the receiver
	 again. Return the result of evaluating aBlock."

	"Look out for race conditions!"

	<category: 'mutual exclusion'>
	| caught |
	caught := false.
	^[
	    [
		"Note that it is *wrong* to set the variable to true before
		 obtaining the semaphore, but the exception handler straightens
		 that.  On the other hand, setting the variable to true after the
		 wait would be wrong if the process was preempted and terminated
		 after the wait (hence, with `caught' still set to false and the
	         semaphore obtained)."
	        caught := true.
	        self wait ] on: ProcessBeingTerminated do: [ :ex |
		    ex waitQueue isNil ifFalse: [ caught := false ].
		    ex pass ].
	    aBlock value ]
		ensure: [caught ifTrue: [self signal] ]
    ]

    name [
	"Answer a user-friendly name for the receiver"

	<category: 'accessing'>
	^name
    ]

    name: aString [
	"Answer a user-friendly name for the receiver"

	<category: 'accessing'>
	name := aString
    ]

    waitingProcesses [
	"Answer an Array of processes currently waiting on the receiver."

	<category: 'accessing'>
	^waitQueue waitingProcesses
    ]

    wouldBlock [
	"Answer whether waiting on the receiver would suspend the current process."

	<category: 'accessing'>
	^waitQueue value <= 0
    ]

    printOn: aStream [
	"Print a human-readable represention of the receiver on aStream."

	<category: 'printing'>
	aStream
	    nextPutAll: self class name;
	    nextPutAll: '(%1: %<free|held>2, %3 %<available signals|waiting processes>2)' 
			% 
			    {self name printString.
			    self signals > 0.
			    self signals abs}
    ]

    initialize [
	<category: 'private'>
	waitQueue := WaitQueue new
    ]

    signals [
	"Answer the number of processes that can be accomodated or if negative
	 the number of waiting processes."

	<category: 'private'>
	| oldV v |
	v := waitQueue value.
	v <= 0 ifTrue: [ ^waitQueue size negated ].
	^v
    ]

    signal [
	"Signal the receiver, resuming a waiting process' if there is one"

	<category: 'builtins'>
	| v |
	waitQueue atomicFetchAndIncrement = 0 ifTrue: [
	    "Free the semaphore.  Let other processes reset to -1 in #wait."
	    waitQueue value: 1.
	    waitQueue wake: 1 ]
    ]

    wait [
	"Wait for the receiver to be signalled, suspending the executing process
	 if it is not yet."

	<category: 'builtins'>
	| oldV |
	"This is an extension of class mutex3 presented in `Futexes are tricky'
	 by Ulrich Drepper.  Instead of using values 0 (unlocked), 1 (locked
	 without waiters), 2 (locked possibly with waiters) I use >0 for extra
	 signals, 0 for locked without waiters, -1 for locked possibly with
	 waiters."
	[
	    oldV := waitQueue value.
	    oldV <= 0 ifTrue: [
		"Mark that the semaphore is not free and has waiters."
		oldV = -1 ifFalse: [ oldV := waitQueue fetchAndSet: -1 ].
		"Even if there were waiters, the semaphore might have been
		 freed exactly during the #fetchAndSet:.  So check oldV again."

		[ oldV <= 0 ] whileTrue: [
		    "Seems to be busy, but wait only if the semaphore hasn't
		     been freed in the meanwhile."
		    waitQueue wait: -1.
		    "We are (trying to) take ownership, so try to set the value
		     to -1."
		    oldV := waitQueue fetchAndSet: -1.

		    "The semaphore might have been taken by someone else between
		     the wait and the #fetchAndSet:, so loop." ].

		"Done."
		^self]

	    "There were excess signals, try to remove one and exit if the
	     value hasn't changed."
	    (waitQueue atomicTest: oldV andSet: oldV - 1) == oldV
		ifTrue: [^self].
	] repeat
    ]

    lock [
	"Without putting the receiver to sleep, force processes that try to wait
	 on the semaphore to block.  Answer whether this was the case even before."

	<category: 'builtins'>
	^(waitQueue fetchAndOr: -1) < 1
    ]
]

