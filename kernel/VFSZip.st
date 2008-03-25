"======================================================================
|
|   Virtual File System (new classes)
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
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

Namespace current: Kernel [

FilePath subclass: FileWrapper [
    | file |
    
    <category: 'Streams-Files'>
    <comment: 'FileWrapper gives information for
virtual files that refer to a real file on disk.'>

    FileWrapper class >> initialize [
	"Register the receiver with ObjectMemory"

	<category: 'initializing'>
	ObjectMemory addDependent: self.
    ]

    FileWrapper class >> update: aspect [
	"Private - Remove the files before quitting, and register the virtual
	 filesystems specified by the subclasses upon image load."

	<category: 'initializing'>
	aspect == #aboutToQuit ifTrue: [self broadcast: #release]
    ]

    FileWrapper class >> on: file [
	"Create an instance of this class representing the contents of the given
	 file, under the virtual filesystem fsName."

	<category: 'instance creation'>
	^self new file: file
    ]

    asString [
	"Answer the container file containing me."
	<category: 'accessing'>
	^self file asString
    ]

    isAbsolute [
        "Answer whether the receiver identifies an absolute path."

	^self file isAbsolute
    ]

    full [
	"Answer the size of the file identified by the receiver"

	<category: 'delegation'>
	self isAbsolute ifTrue: [ ^self ].
	^self class on: self file full
    ]

    size [
	"Answer the size of the file identified by the receiver"

	<category: 'delegation'>
	^self file size
    ]

    lastAccessTime [
	"Answer the last access time of the file identified by the receiver"

	<category: 'delegation'>
	^self file lastAccessTime
    ]

    lastChangeTime [
	"Answer the last change time of the file identified by the receiver
	 (the `last change time' has to do with permissions, ownership and the
	 like). On some operating systems, this could actually be the
	 file creation time."

	<category: 'delegation'>
	^self file lastChangeTime
    ]

    creationTime [
	"Answer the creation time of the file identified by the receiver.
	 On some operating systems, this could actually be the last change time
	 (the `last change time' has to do with permissions, ownership and the
	 like)."

	<category: 'delegation'>
	^self file creationTime
    ]

    lastModifyTime [
	"Answer the last modify time of the file identified by the receiver
	 (the `last modify time' has to do with the actual file contents)."

	<category: 'delegation'>
	^self file lastModifyTime
    ]

    isReadable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is readable"

	<category: 'delegation'>
	^self file isReadable
    ]

    isWriteable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is writeable"

	<category: 'delegation'>
	^self file isWritable
    ]

    isExecutable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is executable"

	<category: 'delegation'>
	^self file isExecutable
    ]

    open: class mode: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'delegation'>
	^self file 
	    open: class
	    mode: mode
	    ifFail: aBlock
    ]

    remove [
	"Remove the file with the given path name"

	<category: 'delegation'>
	self file remove
    ]

    file [
	<category: 'private'>
	^file
    ]

    file: aFilePath [
	<category: 'private'>
	file := aFilePath.
    ]
]

]


Namespace current: Kernel [

FileWrapper subclass: ArchiveFile [
    | tmpFiles topLevelFiles allFiles extractedFiles |
    
    <category: 'Streams-Files'>
    <comment: 'ArchiveFile handles
virtual filesystems that have a directory structure of
their own.  The directories and files in the archive are
instances of ArchiveMember, but the functionality
resides entirely in ArchiveFile because the members
will still ask the archive to get directory information
on them, to extract them to a real file, and so on.'>

    displayOn: aStream [
	"Print a representation of the file identified by the receiver."
	super displayOn: aStream.
	aStream nextPut: $#.
	self class printOn: aStream
    ]

    isDirectory [
	"Answer true.  The archive can always be considered as a directory."

	<category: 'querying'>
	^true
    ]

    isAccessible [
	"Answer whether a directory with the name contained in the receiver does
	 exist and can be accessed"

	<category: 'querying'>
	^self isReadable
    ]

    at: aName [
	"Answer a FilePath for a file named `aName' residing in the directory
	 represented by the receiver."

	<category: 'directory operations'>
	| handler data |
	allFiles isNil ifTrue: [self refresh].
	data := allFiles at: aName ifAbsent: [nil].
	handler := data at: 5 ifAbsent: [nil].
	handler isNil ifFalse: [^handler].
	tmpFiles isNil 
	    ifTrue: 
		[tmpFiles := LookupTable new.
		FileWrapper addDependent: self.
		self addToBeFinalized].
	^tmpFiles at: aName
	    ifAbsentPut: 
		[(TmpFileArchiveMember new)
		    name: aName;
		    archive: self]
    ]

    namesDo: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing its name."

	<category: 'directory operations'>
	topLevelFiles isNil ifTrue: [self refresh].
	topLevelFiles do: aBlock
    ]

    release [
	"Release the resources used by the receiver that don't survive when
	 reloading a snapshot."

	<category: 'directory operations'>
	tmpFiles isNil 
	    ifFalse: 
		[tmpFiles do: [:each | each release].
		tmpFiles := nil].
	extractedFiles isNil 
	    ifFalse: 
		[extractedFiles do: [:each | self primUnlink: each].
		extractedFiles := nil].
	super release
    ]

    fillMember: anArchiveMember [
	"Extract the information on anArchiveMember.  Answer
	 false if it actually does not exist in the archive; otherwise,
	 answer true after having told anArchiveMember about them
	 by sending #size:stCtime:stMtime:stAtime:isDirectory: to it."

	<category: 'ArchiveMember protocol'>
	| data |
	allFiles isNil ifTrue: [self refresh].
	data := allFiles at: anArchiveMember name ifAbsent: [nil].
	data isNil ifTrue: [^false].
	anArchiveMember fillFrom: data.
	^true
    ]

    member: anArchiveMember do: aBlock [
	"Evaluate aBlock once for each file in the directory represented by
	 anArchiveMember, passing its name."

	<category: 'ArchiveMember protocol'>
	| data |
	allFiles isNil ifTrue: [self refresh].
	data := allFiles at: anArchiveMember name ifAbsent: [nil].
	data isNil ifTrue: [^SystemExceptions.FileError signal: 'File not found'].
	(data at: 1) isNil 
	    ifTrue: [^SystemExceptions.FileError signal: 'Not a directory'].
	(data at: 1) do: aBlock
    ]

    refresh [
	"Extract the directory listing from the archive"

	<category: 'ArchiveMember protocol'>
	| pipe line parentPath name current currentPath directoryTree directory |
	super refresh.
	current := currentPath := nil.
	allFiles := LookupTable new.
	directoryTree := LookupTable new.
	self files do: 
		[:data | 
		| path size date mode member |
		mode := self convertMode: (data at: 4).
		data at: 4 put: mode.
		path := data at: 1.
		path last = $/ ifTrue: [path := path copyFrom: 1 to: path size - 1].

		"Look up the tree for the directory in which the file resides.
		 We keep a simple 1-element cache."
		parentPath := File pathFor: path.
		name := File stripPathFrom: path.
		parentPath = currentPath 
		    ifFalse: 
			[currentPath := parentPath.
			current := self findDirectory: path into: directoryTree].

		"Create an item in the tree for directories, and
		 add an association to the allFiles SortedCollection"
		directory := (mode bitAnd: 61440) = 16384 
			    ifTrue: [current at: name put: LookupTable new]
			    ifFalse: [current at: name put: nil].
		data at: 1 put: directory.
		allFiles at: path put: data.
		member := data at: 5 ifAbsent: [nil].
		member notNil ifTrue: [member fillFrom: data]].

	"Leave the LookupTables to be garbage collected, we are now interested
	 in the file names only."
	topLevelFiles := directoryTree keys asArray.
	allFiles 
	    do: [:data | (data at: 1) isNil ifFalse: [data at: 1 put: (data at: 1) keys asArray]]
    ]

    member: anArchiveMember mode: bits [
	"Set the permission bits for the file in anArchiveMember."

	<category: 'ArchiveMember protocol'>
	self subclassResponsibility
    ]

    removeMember: anArchiveMember [
	"Remove the member represented by anArchiveMember."

	<category: 'ArchiveMember protocol'>
	self subclassResponsibility
    ]

    updateMember: anArchiveMember [
	"Update the member represented by anArchiveMember by
	 copying the file into which it was extracted back to the
	 archive."

	<category: 'ArchiveMember protocol'>
	self subclassResponsibility
    ]

    extractMember: anArchiveMember [
	"Extract the contents of anArchiveMember into a file
	 that resides on disk, and answer the name of the file."

	<category: 'TmpFileArchiveMember protocol'>
	extractedFiles isNil ifTrue: [extractedFiles := IdentityDictionary new].
	^extractedFiles at: anArchiveMember
	    ifAbsentPut: 
		[| temp |
		temp := FileStream openTemporaryFile: Directory temporary , '/vfs'.
		self extractMember: anArchiveMember into: temp.
		File name: temp name]
    ]

    extractMember: anArchiveMember into: file [
	"Extract the contents of anArchiveMember into a file
	 that resides on disk, and answer the name of the file."

	<category: 'TmpFileArchiveMember protocol'>
	self subclassResponsibility
    ]

    convertMode: mode [
	"Convert the mode from a string, character or boolean to an octal number."

	<category: 'private'>
	mode isNumber ifTrue: [^mode].
	mode isString ifTrue: [^self convertModeString: mode].
	mode isCharacter ifTrue: [^self convertMode: mode == $d].
	^mode ifTrue: [16877] ifFalse: [420]
    ]

    convertModeString: modeString [
	"Convert the mode from a string to an octal number."

	<category: 'private'>
	| mode |
	mode := 0.
	(modeString at: 1) = $l ifTrue: [mode := 40960].
	(modeString at: 1) = $d ifTrue: [mode := 16384].
	(modeString at: 4) asLowercase = $s ifTrue: [mode := mode + 2048].
	(modeString at: 7) asLowercase = $s ifTrue: [mode := mode + 1024].
	(modeString at: 10) asLowercase = $t ifTrue: [mode := mode + 512].
	modeString 
	    from: 2
	    to: 10
	    keysAndValuesDo: [:i :ch | ch isLowercase ifTrue: [mode := mode setBit: 11 - i]].
	^mode
    ]

    findDirectory: path into: tree [
	"Look up into tree (which is a tree of Dictionaries) the directory
	 that is the parent of the file named `path'."

	<category: 'private'>
	| current last |
	current := tree.
	last := 1.
	path keysAndValuesDo: 
		[:i :each | 
		| element |
		each = $/ 
		    ifTrue: 
			[last = i 
			    ifFalse: 
				[element := path copyFrom: last to: i - 1.
				current := current at: element
					    ifAbsentPut: 
						["The list command might output files but not
						 directories.  No problem, we create them along
						 the way."

						| directory |
						directory := LookupTable new.
						allFiles at: (path copyFrom: 1 to: i - 1)
						    put: 
							{0.
							self creationTime.
							directory}.
						directory]].
			last := i + 1]].
	^current
    ]
]

]



Namespace current: Kernel [

FilePath subclass: ArchiveMember [
    | archive name mode size stCtime stMtime stAtime |
    
    <category: 'Streams-Files'>
    <comment: 'TmpFileArchiveMember is a handler
class for members of archive files that creates temporary files when
extracting files from an archive.'>

    archive: anArchiveFile [
	"Set the archive of which the receiver is a member."

	<category: 'initializing'>
	archive := anArchiveFile
    ]

    full [
	"Answer the size of the file identified by the receiver"

	<category: 'delegation'>
	^self archive full at: self name
    ]

    fillFrom: data [
	"Called back by the receiver's archive when the ArchiveMember
	 asks for file information."

	<category: 'initializing'>
	self 
	    size: (data at: 2)
	    stMtime: (data at: 3)
	    mode: (data at: 4)
    ]

    size: bytes stMtime: mtime mode: modeBits [
	"Set the file information for the receiver."

	<category: 'initializing'>
	size := bytes.
	stCtime := self archive lastModifyTime.
	stMtime := mtime.
	stAtime := self archive lastAccessTime.
	mode := modeBits
    ]

    size: bytes stCtime: ctime stMtime: mtime stAtime: atime mode: modeBits [
	"Set the file information for the receiver."

	<category: 'initializing'>
	size := bytes.
	stCtime := ctime.
	stMtime := mtime.
	stAtime := atime.
	mode := modeBits
    ]

    asString [
	"Answer the name of the file identified by the receiver as answered by
	 File>>#name."

	<category: 'accessing'>
	^self name
    ]

    displayOn: aStream [
	"Print a representation of the file identified by the receiver."
	self archive displayOn: aStream.
	aStream nextPut: $/.
	super displayOn: aStream
    ]

    isAbsolute [
        "Answer whether the receiver identifies an absolute path."

	^self archive isAbsolute
    ]

    name [
	"Answer the receiver's file name."

	<category: 'accessing'>
	^name
    ]

    name: aName [
	"Set the receiver's file name to aName."

	<category: 'accessing'>
	name := aName
    ]

    archive [
	"Answer the archive of which the receiver is a member."

	<category: 'accessing'>
	^archive
    ]

    size [
	"Answer the size of the file identified by the receiver"

	<category: 'accessing'>
	size isNil ifTrue: [self refresh].
	^size
    ]

    lastAccessTime [
	"Answer the last access time of the file identified by the receiver"

	<category: 'accessing'>
	stAtime isNil ifTrue: [self refresh].
	^stAtime
    ]

    lastChangeTime [
	"Answer the last change time of the file identified by the receiver
	 (the `last change time' has to do with permissions, ownership and the
	 like). On some operating systems, this could actually be the
	 file creation time."

	<category: 'accessing'>
	stCtime isNil ifTrue: [self refresh].
	^stCtime
    ]

    creationTime [
	"Answer the creation time of the file identified by the receiver.
	 On some operating systems, this could actually be the last change time
	 (the `last change time' has to do with permissions, ownership and the
	 like)."

	<category: 'accessing'>
	stCtime isNil ifTrue: [self refresh].
	^stCtime
    ]

    lastModifyTime [
	"Answer the last modify time of the file identified by the receiver
	 (the `last modify time' has to do with the actual file contents)."

	<category: 'accessing'>
	stMtime isNil ifTrue: [self refresh].
	^stMtime
    ]

    refresh [
	"Refresh the statistics for the receiver"

	<category: 'accessing'>
	self archive fillMember: self
    ]

    exists [
	"Answer whether a file with the name contained in the receiver does exist."

	<category: 'testing'>
	^self archive fillMember: self
    ]

    mode [
	"Answer the octal permissions for the file."

	<category: 'testing'>
	size isNil ifTrue: [self refresh].
	^mode bitAnd: 4095
    ]

    mode: mode [
	"Set the octal permissions for the file to be `mode'."

	<category: 'testing'>
	self archive member: self mode: (mode bitAnd: 4095)
    ]

    isDirectory [
	"Answer whether a file with the name contained in the receiver does exist
	 and identifies a directory."

	<category: 'testing'>
	size isNil ifTrue: [self refresh].
	^(mode bitAnd: 61440) = 16384
    ]

    isReadable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is readable"

	<category: 'testing'>
	^true
    ]

    isWriteable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is writeable"

	<category: 'testing'>
	^true
    ]

    isExecutable [
	"Answer whether a file with the name contained in the receiver does exist
	 and is executable"

	<category: 'testing'>
	^false
    ]

    isAccessible [
	"Answer whether a directory with the name contained in the receiver does exist
	 and is accessible"

	<category: 'testing'>
	^true
    ]

    open: class mode: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'file operations'>
	self subclassResponsibility
    ]

    update: aspect [
	"Private - Update the in-archive version of the file before closing."

	<category: 'file operations'>
	aspect == #beforeClosing 
	    ifTrue: [self archive updateMember: self] aspect == #afterClosing
	    ifTrue: 
		[self archive refresh.
		self refresh]
    ]

    remove [
	"Remove the file with the given path name"

	<category: 'file operations'>
	self archive removeMember: self.
	File checkError
    ]

    renameTo: newFileName [
	"Rename the file with the given path name oldFileName to newFileName"

	<category: 'file operations'>
	self notYetImplemented
    ]

    at: aName [
	"Answer a FilePath for a file named `aName' residing in the directory
	 represented by the receiver."

	<category: 'directory operations'>
	^self archive at: (Directory append: aName to: self name)
    ]

    createDirectory: dirName [
	"Create a subdirectory of the receiver, naming it dirName."

	<category: 'directory operations'>
	self archive createDirectory: (Directory append: dirName to: self name)
    ]

    namesDo: aBlock [
	"Evaluate aBlock once for each file in the directory represented by the
	 receiver, passing its name."

	<category: 'directory operations'>
	self archive member: self do: aBlock
    ]
]

]



Namespace current: Kernel [

ArchiveMember subclass: TmpFileArchiveMember [
    | file |
    
    <category: 'Streams-Files'>
    <comment: nil>

    release [
	"Release the resources used by the receiver that don't survive when
	 reloading a snapshot."

	"Remove the file that was temporarily holding the file contents"

	<category: 'finalization'>
	self extracted ifTrue: [ file remove. file := nil ].
	super release
    ]

    open: class mode: mode ifFail: aBlock [
	"Open the receiver in the given mode (as answered by FileStream's
	 class constant methods)"

	<category: 'directory operations'>
	| fileStream |
	self file isNil ifTrue: [^aBlock value].
	fileStream := file open: class mode: mode ifFail: [^aBlock value].
	mode == FileStream read ifFalse: [fileStream addDependent: self].
	fileStream setFile: self.
	^fileStream
    ]

    extracted [
	"Answer whether the file has already been extracted to disk."
	^file notNil
    ]

    file [
	"Answer the real file name which holds the file contents,
	 or nil if it does not apply."

	<category: 'directory operations'>
	file isNil ifFalse: [^file].
	self exists ifFalse: [^nil].
	file := self archive extractMember: self.
	^file
    ]
]

]


Namespace current: Kernel [

ArchiveFile subclass: ZipFile [
    
    <category: 'Streams-Files'>
    <comment: 'ZipFile transparently extracts
files from a ZIP archive.'>

    createDirectory: dirName [
	"Create a subdirectory of the receiver, naming it dirName."

	<category: 'members'>
	self notYetImplemented
    ]

    member: anArchiveMember mode: bits [
	"Set the permission bits for the file in anArchiveMember."

	<category: 'members'>
	self notYetImplemented
    ]

    extractMember: anArchiveMember into: temp [
	"Extract the contents of anArchiveMember into a file
	 that resides on disk, and answer the name of the file."

	<category: 'members'>
	Smalltalk 
	    system: 'unzip -p %1 %2 > %3' % 
			{self file name.
			anArchiveMember name.
			temp name}
    ]

    removeMember: anArchiveMember [
	"Remove the member represented by anArchiveMember."

	<category: 'members'>
	Smalltalk 
	    system: 'zip -d %1 %2' % 
			{self file name.
			anArchiveMember name}
    ]

    updateMember: anArchiveMember [
	"Update the member represented by anArchiveMember by
	 copying the file into which it was extracted back to the
	 archive."

	<category: 'members'>
	self notYetImplemented
    ]

    centralDirectoryOf: f [
	<category: 'members'>
	| r beginCD size comLen buf ofsCD |
	size := f size.
	r := 21.

	"Great idea, that of putting a variable-length item at the end.  Luckily,
	 we can make a sanity check of the data and find the correct spot of the
	 central directory's final record."
	size - 22 to: size - 65535 - 22
	    by: -257
	    do: 
		[:pos | 
		buf := (f copyFrom: pos to: pos + r) asByteArray.
		beginCD := buf indexOfSubCollection: #[80 75 5 6] ifAbsent: [0].
		beginCD = 0 
		    ifFalse: 
			[comLen := (buf at: beginCD + 21) * 256 + (buf at: beginCD + 20).
			pos + beginCD + 21 + comLen = size 
			    ifTrue: 
				[ofsCD := (buf at: beginCD + 19) * 16777216 
					    + ((buf at: beginCD + 18) * 65536) + ((buf at: beginCD + 17) * 256) 
					    + (buf at: beginCD + 16).
				^(f copyFrom: ofsCD to: pos + beginCD - 2) asByteArray]].
		r := 278].
	self error: 'invalid data in ZIP file'
    ]

    files [
	"Extract the directory listing from the archive"

	<category: 'members'>
	^Generator on: 
		[:gen | 
		| f cd data path date method dataSize fileSize fnsize extra comment attr ofs |
		f := self open: FileStream read
			    ifFail: [self error: 'cannot open file for input'].
		cd := ByteStream on: (self centralDirectoryOf: f).
		f close.
		date := DateTime now.
		[cd atEnd] whileFalse: 
			[cd skip: 10.
			method := cd nextUshort.
			data := method = 0 ifTrue: [Array new: 5] ifFalse: [Array new: 4].
			data at: 3 put: date.
			cd skip: 12.
			data at: 2 put: cd nextUlong.
			fnsize := cd nextUshort.
			extra := cd nextUshort.
			comment := cd nextUshort.
			cd skip: 4.
			attr := cd nextUlong.
			ofs := cd nextUlong.
			data at: 1 put: (cd next: fnsize).
			cd skip: extra + comment.
			data at: 4 put: (attr bitAnd: 16) = 16.
			method = 0 
			    ifTrue: 
				[data at: 5
				    put: ((StoredZipMember new)
					    name: (data at: 1);
					    archive: self;
					    offset: ofs;
					    yourself)].
			gen yield: data]]
    ]
]

]



Namespace current: Kernel [

TmpFileArchiveMember subclass: StoredZipMember [
    | offset |
    
    <category: 'Streams-Files'>
    <comment: 'ArchiveMember is the handler
class for stored ZIP archive members, which are optimized.'>

    offset [
	<category: 'accessing'>
	^offset
    ]

    offset: anInteger [
	<category: 'accessing'>
	offset := anInteger
    ]

    open: class mode: mode ifFail: aBlock [
	<category: 'opening'>
	| fileStream |
	(mode = FileStream read or: [ self extracted ])
	    ifFalse: [^super open: class mode: mode ifFail: aBlock].

	fileStream := self archive 
		    open: class
		    mode: mode
		    ifFail: [^aBlock value].
	fileStream skip: self offset + 26.
	fileStream skip: fileStream nextUshort + fileStream nextUshort.
	fileStream setFile: self.
	^LimitedStream 
	    on: fileStream
	    from: fileStream position
	    to: fileStream position + self size - 1
    ]
]

]


Namespace current: Kernel [

Stream subclass: LimitedStream [
    | stream offset limit |
    
    <category: 'Streams-Files'>
    <comment: 'I provide a view of a part of a substream.'>

    LimitedStream class >> on: aStream from: start to: end [
	<category: 'instance creation'>
	^(self new)
	    stream: aStream;
	    offset: start;
	    limit: end + 1;
	    yourself
    ]

    atEnd [
	<category: 'stream operations'>
	^stream position >= limit or: [stream atEnd]
    ]

    copyFrom: start to: end [
	<category: 'stream operations'>
	(start between: 0 and: limit - offset) 
	    ifFalse: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: start].
	(end between: 0 and: limit - offset) 
	    ifFalse: [SystemExceptions.IndexOutOfRange signalOn: self withIndex: end].
	^stream copyFrom: offset + start to: offset + end
    ]

    isPositionable [
	<category: 'stream operations'>
	^true
    ]

    next [
	<category: 'stream operations'>
	self atEnd ifTrue: [^self pastEnd].
	^stream next
    ]

    nextHunk [
	<category: 'stream operations'>
	^stream next: (1024 min: limit - stream position)
    ]

    peek [
	<category: 'stream operations'>
	self atEnd ifTrue: [^nil].
	^stream peek
    ]

    peekFor: aCharacter [
	<category: 'stream operations'>
	self atEnd ifTrue: [^false].
	^stream peek
    ]

    position [
	<category: 'stream operations'>
	^stream position - offset
    ]

    position: anInteger [
	<category: 'stream operations'>
	(anInteger between: 0 and: limit - offset) 
	    ifTrue: [stream position: offset + anInteger]
	    ifFalse: 
		[SystemExceptions.IndexOutOfRange signalOn: self withIndex: anInteger]
    ]

    setToEnd [
	<category: 'stream operations'>
	stream position: limit
    ]

    size [
	<category: 'stream operations'>
	^limit - offset
    ]

    skip: anInteger [
	<category: 'stream operations'>
	self position: anInteger + self position
    ]

    printOn: aStream [
	<category: 'printing'>
	aStream
	    print: stream;
	    nextPut: $[;
	    print: offset;
	    nextPut: $:;
	    print: limit;
	    nextPut: $]
    ]

    name [
	<category: 'accessing'>
	^stream name
    ]

    species [
	<category: 'accessing'>
	^stream species
    ]

    stream: aStream [
	<category: 'accessing'>
	stream := aStream
    ]

    limit: anInteger [
	<category: 'accessing'>
	limit := anInteger
    ]

    offset: anInteger [
	<category: 'accessing'>
	offset := anInteger
    ]

    fileIn [
        "File in the contents of the receiver.
         During a file in operation, global variables (starting with an
         uppercase letter) that are not declared don't yield an `unknown
         variable' error. Instead, they are defined as nil in the `Undeclared'
         dictionary (a global variable residing in Smalltalk).
         As soon as you add the variable to a namespace (for example by creating
         a class) the Association will be removed from Undeclared and reused
         in the namespace, so that the old references will automagically point
         to the new value."

        <category: 'built ins'>
        | pos |
        stream isPipe ifTrue: [ ^super fileIn ].
        ^self
            fileInLine: 1
            file: stream file full
            fileName: stream name
            at: self position
    ]

]

]


FilePath extend [
    zip [
        <category: 'virtual filesystems'>
        ^Kernel.ZipFile on: self
    ]
]
