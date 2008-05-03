"======================================================================
|
|   SdlDisplay wrapper class for libsdl
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones
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


Object subclass: SdlDisplay [
    <category: 'LibSDL-Wrapper'>
    <comment: 'I provide an object-oriented wrapper for some SDL_video
functions.  A Display can be connected to an EventSource and be used
as the destination for a Cairo surface.'>

    | surface size caption iconCaption |

    CurrentDisplay := nil.
    DefaultSize := nil.
    SdlDisplay class >> current [
	"Return the default display, creating one if none exists."

	<category: 'accessing'>
	"Creating the display will set CurrentDisplay too."
	CurrentDisplay isNil ifTrue: [ ^self new ].
	^CurrentDisplay
    ]

    SdlDisplay class >> current: aDisplay [
	"Set the default display."

	<category: 'accessing'>
	CurrentDisplay := aDisplay
    ]

    SdlDisplay class >> defaultSize [
	"Return the default size of the display, which is also the
	 size used when #current is called and there is no default
	 display."

	<category: 'accessing'>
	 ^ DefaultSize
    ]

    SdlDisplay class >> defaultSize: aPoint [
	"Set the default size of the display."

	<category: 'accessing'>
	DefaultSize := aPoint
    ]

    SdlDisplay class >> initialize [
	<category: 'private'>
	DefaultSize := 480 @ 640
    ]

    SdlDisplay class >> size: aPoint [
	"Return an SdlDisplay with the given width and height."

	<category: 'instance creation'>
	^self basicNew initialize: aPoint
    ]

    SdlDisplay class >> new [
	"Return an SdlDisplay with the default width and height."

	<category: 'instance creation'>
	^self size: DefaultSize
    ]

    sdlSurface [
	<category: 'private - accessing'>
	^surface
    ]

    sdlSurface: anSdlSurface [
	<category: 'private - accessing'>
	surface := anSdlSurface
    ]

    mapRed: r green: g blue: b [
	"Return an SDL color index for the given red/green/blue triplet."

	<category: 'drawing-SDL'>
	^ SdlVideo sdlMapRGB: surface format value r: r g: g b: b
    ]

    fillRect: aRect color: aColorNumber [
	"Fill a rectangle in the display with the color whose index is in
	 aColorNumber."

	<category: 'drawing-SDL'>
	| r |
	r := SDL.SdlRect new.
	[r x value: aRect left.
	r y value: aRect top.
	r w value: aRect width.
	r h value: aRect height.
	SdlVideo sdlFillRect: surface dstRect: r color: aColorNumber ]
	    ensure: [ r free ]
    ]

    critical: aBlock [
	"Execute aBlock while the surface is locked.  This must be
	 called while drawing on the surface directly (e.g. via Cairo)"

	<category: 'drawing-direct'>
	(SdlVideo sdlLockSurface: surface) == 0 ifFalse: [
	    self error: 'Could not lock surface ', surface].
	^ aBlock ensure: [SdlVideo sdlUnlockSurface: surface]
    ]

    extent [
	"Return the size of the display."
	^ size
    ]

    initialize: aPoint [
	"Initialize the display by hooking it up to the SdlEventSource."

	<category: 'initialization'>
	caption := 'GNU Smalltalk'.
	iconCaption := 'GST'.
	size := aPoint.

	SdlEventSource instance addDependent: self.

	"It's our first run - simulate returning from a saved image in
	order to set up the display window etc."
	CurrentDisplay isNil ifTrue: [ self class current: self ].
	self create
    ]

    caption [
	"Return the caption of the window when it is not minimized."

	<category: 'accessing'>
	^caption
    ]

    iconCaption [
	"Return the caption of the window when it is minimized."

	<category: 'accessing'>
	^iconCaption
    ]

    caption: aString [
	"Set the caption of the window when it is not minimized."

	<category: 'accessing'>
	caption := aString.
	self setCaptions.
    ]

    iconCaption: aString [
	"Set the caption of the window when it is minimized."

	<category: 'accessing'>
	iconCaption := aString.
	self setCaptions.
    ]

    caption: aCaptionString iconCaption: anIconCaptionString [
	"Set up the window to use aCaptionString as its caption when it is
	 not minimized, and anIconCaptionString when it is."

	<category: 'accessing'>
	caption := aCaptionString.
	iconCaption := anIconCaptionString.
	self setCaptions.
    ]

    create [
	"Private - Actually create the display.

	TODO: add more accessors to match SDL flags (e.g. fullscreen, double
	buffer, resizable, h/w surfaces)."

	<category: 'initialization'>
	| flags screen |
	screen := SdlVideo sdlSetVideoMode: size x height: size y bpp: 32 flags: self flags.
	self sdlSurface: screen.
	self setCaptions.
    ]

    flags [
	"Private - Return the SDL_SetVideoMode flags."

	<vategory: 'private'>
	^0 " bitOr: SdlVideo sdlFullScreen."
    ]

    update: aSymbol [
	"Private - Called back by SdlEventSource when returning from snapshot."

	<category: 'initialization'>
	self create.
    ]

    setCaptions [
	"Private - sets captions from my instance variables."

	<category: 'private'>
	SdlVideo sdlWMSetCaption: self caption icon: self iconCaption.
    ]
	
    flip [
	"Move the contents of the surface to the screen.  Optimized for
	 double-buffered surfaces, but always works."

	<category: 'drawing'>
	SdlVideo sdlFlip: self sdlSurface.
    ]

    isGLDisplay [
	"Return true if this is an OpenGL display and graphics should be
	 performed using OpenGL calls."

	<category: 'testing'>
	^false
    ]

    updateRectangle: aRect [
	"Move the contents of the given rectangle from the surface to the
	 screen."

	<category: 'drawing'>
	| x y |
        SdlVideo sdlUpdateRect: self sdlSurface
                 x: (x := aRect left floor)
                 y: (y := aRect top floor)
                 w: aRect right ceiling - x
                 h: aRect height ceiling - y.
    ]

    updateRectangles: upTo rects: sdlrects [
	"Private - Move the contents of the given SdlRect objects from the
	 surface to the screen."

	<category: 'drawing-SDL'>
	SdlVideo sdlUpdateRects: self sdlSurface
		 numRects: upTo
		 rects: sdlrects.
    ]
].

Object subclass: SdlGLDisplay [
    flags [
	"Private - Return the SDL_SetVideoMode flags."

	<vategory: 'private'>
	^super flags bitOr: SdlVideo sdlOpenGl
    ]

    critical: aBlock [
	"Execute aBlock while the surface is locked.  This is a no-op
	 for OpenGL, it just evaluates aBlock.  In the future we might
	 consider using a mutex for OpenGL operations."

	<category: 'drawing-direct'>
	^aBlock value
    ]

    flip [
	"Move the contents of the surface to the screen.  OpenGL surfaces
	 are always double-buffered."

	<category: 'drawing-SDL'>
	SdlVideo sdlGLSwapBuffers
    ]

    isGLDisplay [
	"Return true if this is an OpenGL display and graphics should be
	 performed using OpenGL calls."

	<category: 'testing'>
	^true
    ]

    updateRectangle: aRect [
	"Move the contents of the given rectangle from the surface to the
	 screen.  OpenGL actually always flips the entire surface."

	<category: 'drawing-SDL'>
	self flip
    ]

    updateRectangles: upTo rects: sdlrects [
	"Private - Move the contents of the given SdlRect objects from the
	 surface to the screen.  OpenGL actually always flips the entire
	 surface."

	<category: 'drawing-SDL'>
	self flip
    ]
]

Eval [
    SdlDisplay initialize
]
