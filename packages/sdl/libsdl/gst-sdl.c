/******************************** -*- C -*- ****************************
 *
 *	libsdl bindings for GNU Smalltalk.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2008, 2009 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later
 * version.
 *
 * Linking GNU Smalltalk statically or dynamically with other modules is
 * making a combined work based on GNU Smalltalk.  Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the Free Software Foundation
 * give you permission to combine GNU Smalltalk with free software
 * programs or libraries that are released under the GNU LGPL and with
 * independent programs running under the GNU Smalltalk virtual machine.
 *
 * You may copy and distribute such a system following the terms of the
 * GNU GPL for GNU Smalltalk and the licenses of the other code
 * concerned, provided that you include the source code of that other
 * code when and as the GNU GPL requires distribution of source code.
 *
 * Note that people who make modified versions of GNU Smalltalk are not
 * obligated to grant this special exception for their modified
 * versions; it is their choice whether to do so.  The GNU General
 * Public License gives permission to release a modified version without
 * this exception; this exception also makes it possible to release a
 * modified version which carries forward this exception.
 *
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/


#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "gst-sdl.h"

#ifdef WIN32
#include <windows.h>
#endif

VMProxy *vmProxy;

/* MacOS versions are Objective-C, so they are in sdlmain_cocoa.m.  */
#ifndef __APPLE__
int
gst_SDL_Init (Uint32 flags)
{
  int rc = SDL_Init (flags);
  if (rc < 0)
    return rc;

#ifdef _WIN32
  /* Some more work is needed under Win32.  */
  SDL_SetModuleHandle (GetModuleHandle(NULL));
#endif

  atexit (SDL_Quit);
  return rc;
}
#endif

static OOP event_source_oop;
static SDL_Event event;

static mst_Boolean
gst_SDL_poll (int ms)
{
  int res;
  if (ms < 0)
    return SDL_WaitEvent(&event);

  res = SDL_PollEvent(&event);
  if (res || ms == 0)
    return res;
  SDL_Delay(ms);
  return SDL_PollEvent(&event);
}

static void
gst_SDL_dispatch (void)
{
#ifdef __APPLE__
  if (event.type == SDL_QUIT)
    gst_SDL_quit();
#endif

  if (event.type != SDL_NOEVENT && event_source_oop != vmProxy->nilOOP)
    {
      OOP byteArrayOOP = vmProxy->byteArrayToOOP((char *)&event, sizeof(event));
      event.type = SDL_NOEVENT;
      vmProxy->strMsgSend(event_source_oop, "dispatchEvent:", byteArrayOOP, NULL);
    }
}

static void
gst_SDL_SetEventLoopHandler (OOP eventSourceOOP)
{
  if (eventSourceOOP != vmProxy->nilOOP)
    vmProxy->unregisterOOP (eventSourceOOP);

  vmProxy->registerOOP (eventSourceOOP);
  event_source_oop = eventSourceOOP;
  vmProxy->setEventLoopHandlers(gst_SDL_poll, gst_SDL_dispatch);
#ifdef __APPLE__
  gst_SDL_run();
#endif
}


/* Module initialization function.  */

void
gst_initModule (VMProxy * proxy)
{
  vmProxy = proxy;
  vmProxy->defineCFunc ("SDL_Init", gst_SDL_Init);
  vmProxy->defineCFunc ("SDL_SetEventLoopHandler", gst_SDL_SetEventLoopHandler);
}
