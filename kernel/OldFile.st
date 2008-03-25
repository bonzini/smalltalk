"======================================================================
|
|   File Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1988,92,94,95,99,2000,2001,2002,2005,2006,2007,2008
| Free Software Foundation, Inc.
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



Object subclass: OldFile [
    | vfsHandler |
    
    <category: 'Streams-Files'>
    <comment: 'I expose the syntax of file names, including paths.  I know how to
manipulate such a path by splitting it into its components.  In addition,
I expose information about files (both real and virtual) such as their
size and timestamps.'>

    OldFile class >> on: aVFSHandler [
        "Answer a new file with the given path. The handler that returns
         the information is aVFSHandler" 

        <category: 'instance creation'>
        ^self basicNew init: aVFSHandler
    ]

    OldFile class >> name: aName [
	"Answer a new file with the given path. The path is not validated until
	 some of the fields of the newly created objects are accessed"

	<category: 'instance creation'>
	^self on: (VFS.VFSHandler for: aName)
    ]

    printOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'printing'>
	aStream
	    nextPut: $<;
	    print: self class;
	    space;
	    display: self;
	    nextPut: $>
    ]

    displayOn: aStream [
	"Print a representation of the receiver on aStream."

	<category: 'printing'>
	| name string |
	name := self name.
	(name anySatisfy: [:each | '"(){}[]$\<>#'' `' includes: each]) 
	    ifFalse: 
		[aStream nextPutAll: name.
		^self].
	string := Directory pathSeparator = $/ 
		    ifTrue: ['''%1''' % {name copyReplaceAll: '''' with: '''\'''''}]
		    ifFalse: [
			{'"'.
			name.
			'"'} join].
	aStream nextPutAll: string
    ]

    , aName [
	"Answer an object of the same kind as the receiver, whose name
	 is suffixed with aName."

	^self class name: self name, aName
    ]

    asString [
	"Answer the name of the file identified by the receiver"

	<category: 'accessing'>
	^vfsHandler fullName
    ]

    name [
	"Answer the name of the file identified by the receiver"

	<category: 'accessing'>
	^vfsHandler fullName
    ]

    mode [
	"Answer the permission bits for the file identified by the receiver"

	<category: 'accessing'>
	^vfsHandler mode
    ]

    size [
	"Answer the size of the file identified by the receiver"

	<category: 'accessing'>
	^vfsHandler size
    ]

    mode: anInteger [
	"Set the permission bits for the file identified by the receiver to be
	 anInteger."

	<category: 'accessing'>
	vfsHandler mode: anInteger
    ]

    lastAccessTime: aDateTime [
	"Update the last access time of the file corresponding to the receiver,
	 to be aDateTime."

	<category: 'accessing'>
	vfsHandler lastAccessTime: aDateTime lastModifyTime: self lastModifyTime
    ]

    lastAccessTime: accessDateTime lastModifyTime: modifyDateTime [
	"Update the timestamps of the file corresponding to the receiver, to be
	 accessDateTime and modifyDateTime."

	<category: 'accessing'>
	vfsHandler lastAccessTime: accessDateTime lastModifyTime: modifyDateTime
    ]

    lastAccessTime [
	"Answer the last access time of the file identified by the receiver"

	<category: 'accessing'>
	^vfsHandler lastAccessTime
    ]

    lastChangeTime [
	"Answer the last change time of the file identified by the receiver
	 (the `last change time' has to do with permissions, ownership and the
	 like). On some operating systems, this could actually be the
	 file creation time."

	<category: 'accessing'>
	^vfsHandler lastChangeTime
    ]

    creationTime [
	"Answer the creation time of the file identified by the receiver.
	 On some operating systems, this could actually be the last change time
	 (the `last change time' has to do with permissions, ownership and the
	 like)."

	<category: 'accessing'>
	^vfsHandler creationTime
    ]

    lastModifyTime: aDateTime [
	"Update the last modification timestamp of the file corresponding to the
	 receiver, to be aDateTime."

	<category: 'accessing'>
	vfsHandler lastAccessTime: self lastAccessTime lastModifyTime: aDateTime
    ]

    lastModifyTime [
	"Answer the last modify time of the file identified by the receiver
	 (the `last modify time' has to do with the actual file contents)."

	<category: 'accessing'>
	^vfsHandler lastModifyTime
    ]

    refresh [
	"Refresh the statistics for the receiver"

	<category: 'accessing'>
	vfsHandler refresh
    ]

    exists [
	"Answer whether a file with the name contained in the receiver does exist."

	<category: 'testing'>
	^vfsHandler exists
    ]

    isSymbolicLink [
	"Answer whether a file with the name contained in the receiver does exist
	 and does not identify a directory."

	<category: 'testing'>
	^vfsHandler exists and: [vfsHandler isSymbolicLink]
    ]

    isFile [
	"Answer whether a file with the name contained in the receiver does exist
	 and does not identify a directory."

	<category: 'testing'>
	^vfsHandler exists and: [vfsHandler isDirectory not]
    ]

    isDirectory [
	"Answer whether a file with the name contained in the receiver does exist
	 and identifies a directory."

	<category: 'testing'>
	| dir errno |
	^vfsHandler exists and: [vfsHandler isDirectory]
    ]

    isReadable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is readable"

	<category: 'testing'>
	^vfsHandler exists and: [vfsHandler isReadable]
    ]

    isWriteable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is writeable"

	<category: 'testing'>
	^self exists and: [vfsHandler isWriteable]
    ]

    isExecutable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is executable"

	<category: 'testing'>
	^self isFile and: [vfsHandler isExecutable]
    ]

    isAccessible [
	"Answer whether a directory with the name contained in the receiver does
	 exist and can be accessed"

	<category: 'testing'>
	^self isDirectory and: [vfsHandler isAccessible]
    ]

    extension [
	"Answer the extension of the receiver"

	<category: 'file name management'>
	^File extensionFor: self name
    ]

    stripExtension [
	"Answer the path (if any) and file name of the receiver"

	<category: 'file name management'>
	^File stripExtensionFrom: self name
    ]

    stripPath [
	"Answer the file name and extension (if any) of the receiver"

	<category: 'file name management'>
	^File stripPathFrom: self name
    ]

    parent [
	"Answer the Directory object for the receiver's path"

	<category: 'file name management'>
	^self class name: (File pathFor: self name)
    ]

    path [
	"Answer the path (if any) of the receiver"

	<category: 'file name management'>
	^File pathFor: self name
    ]

    stripFileName [
	"Answer the path of the receiver, always including a directory
	 name (possibly `.') and the final directory separator"

	<category: 'file name management'>
	^File stripFileNameFor: self name
    ]

    fullName [
	"Answer the full name of the receiver, resolving the `.' and
	 `..' directory entries, and answer the result.  Answer nil if the
	 name is invalid (such as '/usr/../../badname')"

	<category: 'file name management'>
	^File fullNameFor: self name
    ]

    contents [
	"Open a read-only FileStream on the receiver, read its contents,
	 close the stream and answer the contents"

	<category: 'file operations'>
	| stream contents |
	stream := self readStream.
	contents := stream contents.
	stream close.
	^contents
    ]

    touch [
	"Update the timestamp of the file corresponding to the receiver."

	<category: 'file operations'>
	| now |
	self exists 
	    ifTrue: 
		[now := DateTime now.
		self lastAccessTime: now lastModifyTime: now]
	    ifFalse: [(self open: FileStream append) close]
    ]

    open: mode [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'file operations'>
	^vfsHandler open: mode
	    ifFail: [SystemExceptions.FileError signal: 'could not open ' , self name]
    ]

    openDescriptor: mode [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'file operations'>
	^vfsHandler openDescriptor: mode
	    ifFail: [SystemExceptions.FileError signal: 'could not open ' , self name]
    ]

    open: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods). Upon failure, evaluate aBlock."

	<category: 'file operations'>
	^vfsHandler open: mode ifFail: aBlock
    ]

    openDescriptor: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods). Upon failure, evaluate aBlock."

	<category: 'file operations'>
	^vfsHandler openDescriptor: mode ifFail: aBlock
    ]

    withReadStreamDo: aBlock [
	"Invoke aBlock with a reading stream open on me, closing it
	 when the dynamic extent of aBlock ends."
	<category: 'file operations'>
	| stream |
	stream := self readStream.
	^[aBlock value: stream] ensure: [stream close]
    ]

    fileIn [
	"File in the receiver"

	<category: 'file operations'>
	self withReadStreamDo: [ :fs | fs fileIn ]
    ]

    readStream [
	"Open a read-only FileStream on the receiver"

	<category: 'file operations'>
	^self open: FileStream read
    ]

    withWriteStreamDo: aBlock [
	"Invoke aBlock with a writing stream open on me, closing it
	 when the dynamic extent of aBlock ends."
	<category: 'file operations'>
	| stream |
	stream := self writeStream.
	^[aBlock value: stream] ensure: [stream close]
    ]

    writeStream [
	"Open a write-only FileStream on the receiver"

	<category: 'file operations'>
	^self open: FileStream write
    ]

    symlinkAs: destName [
	"Create destName as a symbolic link of the receiver.  The appropriate
	 relative path is computed automatically."

	<category: 'file operations'>
	| dest relPath |
	dest := VFS.VFSHandler for: destName.
	relPath := File computePathFrom: dest realFileName
		    to: vfsHandler realFileName.
	dest symlinkFrom: relPath
    ]

    pathFrom: dirName [
	"Compute the relative path from the directory dirName to the receiver"

	<category: 'file operations'>
	^File computePathFrom: (File fullNameFor: dirName asString) , '/somefile'
	    to: vfsHandler realFileName
    ]

    symlinkFrom: srcName [
	"Create the receiver as a symbolic link from srcName (relative to the
	 path of the receiver)."

	<category: 'file operations'>
	vfsHandler symlinkFrom: srcName
    ]

    remove [
	"Remove the file identified by the receiver"

	<category: 'file operations'>
	^vfsHandler remove
    ]

    renameTo: newName [
	"Rename the file identified by the receiver to newName"

	<category: 'file operations'>
	vfsHandler renameTo: newName
    ]

    init: aVFSHandler [
	"Private - Initialize the receiver's instance variables"

	<category: 'private'>
	vfsHandler := aVFSHandler
    ]

    pathTo: destName [
	"Compute the relative path from the receiver to destName."

	<category: 'accessing'>
	| destFullName |
	destFullName := File fullNameFor: destName asString.
	vfsHandler realFileName = destFullName ifTrue: [^'.'].
	^File computePathFrom: vfsHandler realFileName , '/somefile'
	    to: destFullName
    ]

    / aName [
	"Answer a File or Directory object as appropriate for a file named
	 'aName' in the directory represented by the receiver."

	^self at: aName
    ]

    at: aName [
	"Answer a File or Directory object as appropriate for a file named
	 'aName' in the directory represented by the receiver."

	<category: 'accessing'>
	| f |
	f := vfsHandler at: aName.
	^self class on: f
    ]

    includes: aName [
        "Answer whether a file named `aName' exists in the directory represented
         by the receiver."

        <category: 'accessing'>
        ^(vfsHandler at: aName) exists
    ]

    fullNameAt: aName [
	"Answer a String containing the full path to a file named `aName' which
	 resides in the directory represented by the receiver."

	<category: 'accessing'>
	^Directory append: aName to: self fullName
    ]

    nameAt: aName [
	"Answer a String containing the path to a file named `aName' which
	 resides in the directory represented by the receiver."

	<category: 'accessing'>
	^Directory append: aName to: self name
    ]

    allFilesMatching: aPattern do: aBlock [
	"Evaluate aBlock on the File objects that match aPattern (according to
	 String>>#match:) in the directory named by the receiver. Recursively
	 descend into directories."

	<category: 'enumerating'>
	self do: 
		[:name | 
		| f |
		f := self at: name.
		(aPattern match: name) ifTrue: [aBlock value: f].
		f isDirectory 
		    ifTrue: 
			[((#('.' '..') includes: name) or: [f isSymbolicLink]) 
			    ifFalse: [f allFilesMatching: aPattern do: aBlock]]]
    ]

    files [
	"Answer an Array with File objects for the contents of the directory
	 represented by the receiver."

	<category: 'enumerating'>
	^self select: [ :each | each isFile ]
    ]

    directories [
	"Answer an Array with Directory objects for the subdirectories
	 of the directory represented by the receiver."

	<category: 'enumerating'>
	^self select: [ :each | each isDirectory ]
    ]

    entries [
	"Answer an Array with File or Directory objects for the contents
	 of the directory represented by the receiver."

	<category: 'enumerating'>
	| ws |
	ws := WriteStream on: (Array new: 50).
	self do: [:each | ws nextPut: each].
	^ws contents
    ]

    entryNames [
	"Answer an Array with the names of the files in the directory
	 represented by the receiver."

	<category: 'enumerating'>
	| ws |
	ws := WriteStream on: (Array new: 50).
	self namesDo: [:each | ws nextPut: each].
	^ws contents
    ]

    do: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing its name."

	<category: 'enumerating'>
	self namesDo: [ :name |
	    aBlock value: (self at: name) ]
    ]

    namesDo: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing its name."

	<category: 'enumerating'>
	vfsHandler do: [ :name | aBlock value: name ]
    ]

    filesMatching: aPattern [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing a File or Directory object to aBlock. Returns the
	 *names* of the files for which aBlock returns true."

	<category: 'enumerating'>
	| ws |
	ws := WriteStream on: (Array new: 50).
	self namesDo: [ :name |
	    (aPattern match: name) ifTrue: [ ws nextPut: (self at: name) ] ].
	^ws contents
    ]

    reject: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing a File or Directory object to aBlock. Returns the
	 *names* of the files for which aBlock returns true."

	<category: 'enumerating'>
	| ws |
	ws := WriteStream on: (Array new: 50).
	self do: [ :each |
	    (aBlock value: each) ifFalse: [ ws nextPut: each ] ].
	^ws contents
    ]

    select: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing a File or Directory object to aBlock. Returns the
	 *names* of the files for which aBlock returns true."

	<category: 'enumerating'>
	| ws |
	ws := WriteStream on: (Array new: 50).
	self do: [ :each |
	    (aBlock value: each) ifTrue: [ ws nextPut: each ] ].
	^ws contents
    ]

    filesMatching: aPattern do: block [
	"Evaluate block on the File objects that match aPattern (according to
	 String>>#match:) in the directory named by the receiver."

	<category: 'enumerating'>
	self namesDo: [:name |
	    (aPattern match: name) ifTrue: [block value: (self at: name)]]
    ]

    namesMatching: aPattern do: block [
	"Evaluate block on the file names that match aPattern (according to
	 String>>#match:) in the directory named by the receiver."

	<category: 'enumerating'>
	vfsHandler 
	    do: [:name | (aPattern match: name) ifTrue: [block value: (self nameAt: name)]]
    ]
]

