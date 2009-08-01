"======================================================================
|
|   WaitQueue Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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



LinkedList subclass: WaitQueue [
    | value |
    
    <category: 'Language-Processes'>
    <comment: 'My instances represent a wait queue with an attached
SmallInteger register.  I am the fundamental synchronization primitive.'>

    WaitQueue class >> new [
	"Answer a new semaphore"

	<category: 'instance creation'>
	^self basicNew initialize
    ]

    waitingProcesses [
	"Answer an Array of processes currently waiting on the receiver."

	<category: 'accessing'>
	^self asArray
    ]

    printOn: aStream [
	"Print a human-readable represention of the receiver on aStream."

	<category: 'printing'>
	aStream
	    nextPutAll: self class name;
	    nextPutAll: '(%1: value=%2, %3 waiting processes)' 
			% 
			    {self name printString.
			    value. self size}
    ]

    initialize [
	<category: 'private'>
	value := 0
    ]

    value [
	<category: 'accessing'>
	^value
    ]

    semaphoreNotify [
	"Resume one of the processes that were waiting on the semaphore if
	 there were any.  Do not leave a signal on the semaphore if no
	 process is waiting."

	<category: 'builtins'>
	<primitive: VMpr_Semaphore_notify>
	^self primitiveFailed
    ]

    semaphoreNotifyAll [
	"Resume all the processes that were waiting on the semaphore if there
	 were any.  Do not leave a signal on the semaphore if no process is
	 waiting."

	<category: 'builtins'>
	<primitive: VMpr_Semaphore_notifyAll>
	^self primitiveFailed
    ]

    semaphoreSignal [
	"Signal the receiver, resuming a waiting process' if there is one"

	<category: 'builtins'>
	<primitive: VMpr_Semaphore_signal>
	^self primitiveFailed
    ]

    semaphoreWait [
	"Wait for the receiver to be signalled, suspending the executing process
	 if it is not yet"

	<category: 'builtins'>
	<primitive: VMpr_Semaphore_wait>
	^self primitiveFailed
    ]

    semaphoreWaitAfterSignalling: aSemaphore [
	"Signal aSemaphore then, atomically, wait for the receiver to be
	 signalled, suspending the executing process if it is not yet.  This
	 is needed to avoid race conditions when the #notify and #notifyAll
	 are used before waiting on receiver: otherwise, if a process sends
	 any of the two between the time aSemaphore is signaled and the time
	 the process starts waiting on the receiver, the notification is lost."

	<category: 'builtins'>
	<primitive: VMpr_Semaphore_waitAfterSignalling>
	^self primitiveFailed
    ]

    semaphoreLock [
	"Without putting the receiver to sleep, force processes that try to wait
	 on the semaphore to block.  Answer whether this was the case even before."

	<category: 'builtins'>
	<primitive: VMpr_Semaphore_lock>
	^self primitiveFailed
    ]
]

