"======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
|
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
|
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #Console
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Console Wrapper'! !

CStruct subclass: #ConsoleInformation
    declaration: #(
        (#consoleLines (#ptr #CObject))
        (#commandLines (#ptr #CObject))
        (#totalConsoleLines #int)
        (#consoleScrollBack #int)
        (#totalCommands #int)
        (#fontNumber #int)
        (#lineBuffer #int)
        (#vChars #int)
        (#backX #int)
        (#backY #int)
        (#prompt #string)
        (#command (#array #char 128))
        (#rCommand (#array #char 128))
        (#lCommand (#array #char 128))
        (#vCommand (#array #char 128))
        (#cursorPos #int)
        (#offset #int)
        (#insMode #int)
        (#consoleSurface (#ptr #CObject))
        (#outputScreen (#ptr #CObject))
        (#backGroundImage (#ptr #CObject))
        (#inputBackGround (#ptr #CObject))
        (#dispX #int)
        (#dispY #int)
        (#consoleAlpha #char)
        (#commandScrollBack #int))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'ConsoleInformation Wrapper'! !

CStruct subclass: #CommandInfo
    declaration: #(
        (#commandCallback (#ptr #CObject))
        (#commandWord #string)
        (#nextCommand (#ptr #CObject)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'CommandInfo Wrapper'! !

DLD addLibrary: 'libSDL_console'!

!Console class methodsFor: 'Constants'!

conCharsPerLine
    ^128!

conBlinkRate
    ^500!

conCharBorder
    ^4!

conDefaultPrompt
    ^']'!

conLineScroll
    ^2!

conScrollIndicator
    ^'^'!

conInsCursor
    ^'_'!

conOvrCursor
    ^'|'!

!Console class methodsFor: 'C call-outs'!

conEvents: aCobject0
    "void CON_Events(SDL_Event *event);"
    <cCall: 'CON_Events' returning: #void 
        args: #( #cObject )>!

conDrawConsole: aCobject0 
    "void CON_DrawConsole(ConsoleInformation *console);"
    <cCall: 'CON_DrawConsole' returning: #void 
        args: #( #cObject )>!

conInit: aString0 displayScreen: aCobject1 lines: aInt2 rect: aCobject3 
    "ConsoleInformation *CON_Init(const char *FontName, SDL_Surface *DisplayScreen, 
         int lines, SDL_Rect rect);"
    <cCall: 'CON_Init' returning: #cObject 
        args: #( #string #cObject #int #cObject  )>!

conDestroy: aCobject0 
    "void CON_Destroy(ConsoleInformation *console);"
    <cCall: 'CON_Destroy' returning: #void 
        args: #( #cObject )>!

conFree: aCobject0 
    "void CON_Free(ConsoleInformation *console);"
    <cCall: 'CON_Free' returning: #void 
        args: #( #cObject )>!

conOut: aCobject0 str: aString1 arg2: aVariadic2 
    "void CON_Out(ConsoleInformation *console, const char *str, ...);"
    <cCall: 'CON_Out' returning: #void 
        args: #( #cObject #string #variadic )>!

conAlpha: aCobject0 alpha: aChar1 
    "void CON_Alpha(ConsoleInformation *console, unsigned char alpha);"
    <cCall: 'CON_Alpha' returning: #void 
        args: #( #cObject #char )>!

conBackground: aCobject0 image: aString1 x: aInt2 y: aInt3 
    "int CON_Background(ConsoleInformation *console, const char *image, int x, int y);"
    <cCall: 'CON_Background' returning: #int 
        args: #( #cObject #string #int #int )>!

conPosition: aCobject0 x: aInt1 y: aInt2 
    "void CON_Position(ConsoleInformation *console, int x, int y);"
    <cCall: 'CON_Position' returning: #void 
        args: #( #cObject #int #int )>!

conResize: aCobject0 rect: aCobject1 
    "int CON_Resize(ConsoleInformation *console, SDL_Rect rect);"
    <cCall: 'CON_Resize' returning: #int 
        args: #( #cObject #cObject )>!

conNewlineConsole: aCobject0 
    "void CON_NewLineConsole(ConsoleInformation *console);"
    <cCall: 'CON_NewLineConsole' returning: #void 
        args: #( #cObject )>!

conNewlineCommand: aCobject0 
    "void CON_NewLineCommand(ConsoleInformation *console);"
    <cCall: 'CON_NewLineCommand' returning: #void 
        args: #( #cObject )>!

conUpdateConsole: aCobject0 
    "void CON_UpdateConsole(ConsoleInformation *console);"
    <cCall: 'CON_UpdateConsole' returning: #void 
        args: #( #cObject )>!

conTopMost: aCobject0 
    "void CON_Topmost(ConsoleInformation *console);"
    <cCall: 'CON_Topmost' returning: #void 
        args: #( #cObject )>!

conSetPrompt: aCobject0 newPrompt: aString1 
    "void CON_SetPrompt(ConsoleInformation *console, char* newprompt);"
    <cCall: 'CON_SetPrompt' returning: #void 
        args: #( #cObject #string )>!

cursorLeft: aCobject0 
    "void Cursor_Left(ConsoleInformation *console);"
    <cCall: 'Cursor_Left' returning: #void 
        args: #( #cObject )>!

cursorRight: aCobject0 
    "void Cursor_Right(ConsoleInformation *console);"
    <cCall: 'Cursor_Right' returning: #void 
        args: #( #cObject )>!

cursorHome: aCobject0 
    "void Cursor_Home(ConsoleInformation *console);"
    <cCall: 'Cursor_Home' returning: #void 
        args: #( #cObject )>!

cursorEnd: aCobject0 
    "void Cursor_End(ConsoleInformation *console);"
    <cCall: 'Cursor_End' returning: #void 
        args: #( #cObject )>!

cursorDel: aCobject0 
    "void Cursor_Del(ConsoleInformation *console);"
    <cCall: 'Cursor_Del' returning: #void 
        args: #( #cObject )>!

cursorBSpace: aCobject0 
    "void Cursor_BSpace(ConsoleInformation *console);"
    <cCall: 'Cursor_BSpace' returning: #void 
        args: #( #cObject )>!

cursorAdd: aCobject0 event: aCobject1 
    "void Cursor_Add(ConsoleInformation *console, SDL_Event *event);"
    <cCall: 'Cursor_Add' returning: #void 
        args: #( #cObject #cObject )>!

clearCommand: aCobject0 
    "void Clear_Command(ConsoleInformation *console);"
    <cCall: 'Clear_Command' returning: #void 
        args: #( #cObject )>!

clearHistory: aCobject0 
    "void Clear_History(ConsoleInformation *console);"
    <cCall: 'Clear_History' returning: #void 
        args: #( #cObject )>!

conSendFullCommand: aInt0 
    "void CON_SendFullCommand(int sendOn);"
    <cCall: 'CON_SendFullCommand' returning: #void 
        args: #( #int )>!

conCommandExecute: aCobject0 
    "void CON_CommandExecute(ConsoleInformation *console);"
    <cCall: 'CON_CommandExecute' returning: #void 
        args: #( #cObject )>!

conAddCommand: aCobject0 commandWord: aString1 
    "void CON_AddCommand(void (*CommandCallback)(ConsoleInformation *console, 
         char *Parameters), const char *CommandWord);"
    <cCall: 'CON_AddCommand' returning: #void 
        args: #( #cObject #string )>!

conTabCompletion: aCobject0 
    "void CON_TabCompletion(ConsoleInformation *console);"
    <cCall: 'CON_TabCompletion' returning: #void 
        args: #( #cObject )>!

conListCommands: aCobject0 
    "void CON_ListCommands(ConsoleInformation *console);"
    <cCall: 'CON_ListCommands' returning: #void 
        args: #( #cObject )>!

conDestroyCommands
    "void CON_DestroyCommands();"
    <cCall: 'CON_DestroyCommands' returning: #void 
        args: #( )>! !
