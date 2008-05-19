/******************************** -*- C -*- ****************************
 *
 *	OpenGLU gluNurbs bindings.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2008 Free Software Foundation, Inc.
 * Written by Olivier Blanc.
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

#include "gstopengl.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define nil  vm_proxy->nilOOP

/* Number of known callbacks */
#define N_GLU_CALLBACKS 13

/* Receivers for the callbacks; initialized in module init func */
static OOP gluNurbReceiver[N_GLU_CALLBACKS] ;

/* Selectors; initialized in module init func */
static OOP gluNurbSelector[N_GLU_CALLBACKS] ;

/* Callback constants definition */
static GLenum gluNurbFunctions[N_GLU_CALLBACKS] = {
  GLU_NURBS_ERROR,
  GLU_NURBS_BEGIN,
  GLU_NURBS_VERTEX,
  GLU_NURBS_NORMAL,
  GLU_NURBS_COLOR,
  GLU_NURBS_TEXTURE_COORD,
  GLU_NURBS_END,
  GLU_NURBS_BEGIN_DATA,
  GLU_NURBS_VERTEX_DATA,
  GLU_NURBS_NORMAL_DATA,
  GLU_NURBS_COLOR_DATA,
  GLU_NURBS_TEXTURE_COORD_DATA,
  GLU_NURBS_END_DATA
} ;


/* Retreive the callback index from the Callback contant definition */
int gst_glu_nurbCallback_getCallbackIndex(GLenum which)
{
  int i ;
  for (i = 0 ; i < N_GLU_CALLBACKS ; ++i) {
	/* If function is found, return index */
	if (gluNurbFunctions[i] == which) {
	  return i ;
	}
  }
  return -1 ;
}

/* Send the callback message to the receiver */
void gst_glu_nurbCallback_sendMessage(GLenum which, OOP* args, int nArgs)
{
  /* Get the callback index */
  int index = gst_glu_nurbCallback_getCallbackIndex(which) ;

  if(index == -1) return ;
  /* verify the receiver and the selector */
  if(gluNurbReceiver[index] != nil && 
	 gluNurbSelector[index] != nil) 
	{
	  /* Send the callback message */
	  if(nArgs > 0) 
		vm_proxy->nvmsgSend(gluNurbReceiver[index], 
									gluNurbSelector[index],
									args, nArgs) ;
	  else
		vm_proxy->perform(gluNurbReceiver[index], 
								  gluNurbSelector[index]) ;
	}
}
/* Define the C Callback functions and call the sendMessage function */
void gst_glu_nurbCallback_Nurbs_Error (GLenum errorCode)
{
  OOP* args = alloca ( sizeof(OOP) * 1) ;
  args[0] = vm_proxy->intToOOP(errorCode) ;
  gst_glu_nurbCallback_sendMessage(GLU_NURBS_ERROR, args, 1) ;
}

void gst_glu_nurbCallback_Nurbs_Begin ( GLenum type )
{
  OOP* args = alloca ( sizeof(OOP) * 1) ;
  args[0] = vm_proxy->intToOOP(type) ;
  gst_glu_nurbCallback_sendMessage(GLU_NURBS_BEGIN, args, 1) ;
}

void gst_glu_nurbCallback_Nurbs_Vertex ( GLfloat* vertex )
{
  OOP* args = alloca ( sizeof(OOP) * 3 ) ;
  args[0] = vm_proxy->floatToOOP( vertex[0] ) ;
  args[1] = vm_proxy->floatToOOP( vertex[1] ) ;
  args[2] = vm_proxy->floatToOOP( vertex[2] ) ;
  gst_glu_nurbCallback_sendMessage(GLU_NURBS_VERTEX, args, 3) ;
}

void gst_glu_nurbCallback_Nurbs_Normal ( GLfloat* normal )
{
  OOP* args = alloca ( sizeof(OOP) * 3 ) ;
  args[0] = vm_proxy->floatToOOP( normal[0] ) ;
  args[1] = vm_proxy->floatToOOP( normal[1] ) ;
  args[2] = vm_proxy->floatToOOP( normal[2] ) ;
  gst_glu_nurbCallback_sendMessage(GLU_NURBS_NORMAL, args, 3) ;
}

void gst_glu_nurbCallback_Nurbs_Color ( GLfloat* color)
{
  OOP* args = alloca ( sizeof(OOP) * 3 ) ;
  args[0] = vm_proxy->floatToOOP( color[0] ) ;
  args[1] = vm_proxy->floatToOOP( color[1] ) ;
  args[2] = vm_proxy->floatToOOP( color[2] ) ;
  gst_glu_nurbCallback_sendMessage(GLU_NURBS_COLOR, args, 3) ;
}

void gst_glu_nurbCallback_Nurbs_Texture_Coord ( GLfloat* tCrd )
{
  OOP* args = alloca ( sizeof(OOP) * 3 ) ;
  args[0] = vm_proxy->floatToOOP( tCrd[0] ) ;
  args[1] = vm_proxy->floatToOOP( tCrd[1] ) ;
  args[2] = vm_proxy->floatToOOP( tCrd[2] ) ;
  gst_glu_nurbCallback_sendMessage(GLU_NURBS_TEXTURE_COORD, args, 3) ;
}

void gst_glu_nurbCallback_Nurbs_End ( )
{
  gst_glu_nurbCallback_sendMessage(GLU_NURBS_END, &nil, 0) ;
}

void gst_glu_nurbCallback_Nurbs_Begin_Data ( GLenum type, void* data )
{
  OOP* args = alloca ( sizeof(OOP) * 2) ;
  args[0] = vm_proxy->intToOOP(type) ;
  args[1] = (OOP) data ;
  gst_glu_nurbCallback_sendMessage(GLU_NURBS_BEGIN_DATA, args, 2) ;
}

void gst_glu_nurbCallback_Nurbs_Vertex_Data ( GLfloat* vertex, void* data )
{
  OOP* args = alloca ( sizeof(OOP) * 4 ) ;
  args[0] = vm_proxy->floatToOOP( vertex[0] ) ;
  args[1] = vm_proxy->floatToOOP( vertex[1] ) ;
  args[2] = vm_proxy->floatToOOP( vertex[2] ) ;
  args[3] = (OOP) data ;
  gst_glu_nurbCallback_sendMessage(GLU_NURBS_VERTEX_DATA, args, 4) ;
}

void gst_glu_nurbCallback_Nurbs_Normal_Data ( GLfloat* normal, void* data )
{
  OOP* args = alloca ( sizeof(OOP) * 4 ) ;
  args[0] = vm_proxy->floatToOOP( normal[0] ) ;
  args[1] = vm_proxy->floatToOOP( normal[1] ) ;
  args[2] = vm_proxy->floatToOOP( normal[2] ) ;
  args[3] = (OOP) data ;
  gst_glu_nurbCallback_sendMessage(GLU_NURBS_NORMAL_DATA, args, 4) ;
}

void gst_glu_nurbCallback_Nurbs_Color_Data ( GLfloat* color, void* data)
{
  OOP* args = alloca ( sizeof(OOP) * 4 ) ;
  args[0] = vm_proxy->floatToOOP( color[0] ) ;
  args[1] = vm_proxy->floatToOOP( color[1] ) ;
  args[2] = vm_proxy->floatToOOP( color[2] ) ;
  args[3] = (OOP) data ;
  gst_glu_nurbCallback_sendMessage(GLU_NURBS_COLOR_DATA, args, 4) ;
}

void gst_glu_nurbCallback_Nurbs_Texture_Coord_Data ( GLfloat* tCrd, void* data )
{
  OOP* args = alloca ( sizeof(OOP) * 4 ) ;
  args[0] = vm_proxy->floatToOOP( tCrd[0] ) ;
  args[1] = vm_proxy->floatToOOP( tCrd[1] ) ;
  args[2] = vm_proxy->floatToOOP( tCrd[2] ) ;
  args[3] = (OOP) data ;
  gst_glu_nurbCallback_sendMessage(GLU_NURBS_TEXTURE_COORD_DATA, args, 4) ;
}

void gst_glu_nurbCallback_Nurbs_End_Data (void* data )
{
  OOP* args = alloca ( sizeof(OOP) * 1 ) ;
  args[0] = (OOP) data ;
  gst_glu_nurbCallback_sendMessage(GLU_NURBS_END_DATA, args, 1) ;
}


/* Pointers to the Glu Nurbs callback functions */
static GLUfuncptr gst_glu_nurbCallback[N_GLU_CALLBACKS] = {
  (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Error,
  (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Begin,
  (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Vertex,
  (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Normal,
  (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Color,
  (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Texture_Coord,
  (GLUfuncptr) gst_glu_nurbCallback_Nurbs_End,
  (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Begin_Data,
  (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Vertex_Data,
  (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Normal_Data,
  (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Color_Data,
  (GLUfuncptr) gst_glu_nurbCallback_Nurbs_Texture_Coord_Data,
  (GLUfuncptr) gst_glu_nurbCallback_Nurbs_End_Data
} ;



void gst_opengl_gluNurbsCallback (OOP nurb, GLenum which, OOP receiver, OOP selector)
{ 
  int index = gst_glu_nurbCallback_getCallbackIndex(which) ;

  if(index == -1) 
	return ;

  /* Unregister previous receiver and selector callback */
  if(gluNurbReceiver[index] != nil) 
	{
	  vm_proxy->unregisterOOP(gluNurbReceiver[index]) ;
	  gluNurbReceiver[index] = nil ;
	}
  if(gluNurbSelector[index] != nil) 
	{
	  vm_proxy->unregisterOOP(gluNurbSelector[index]) ;
	  gluNurbSelector[index] = nil ;
	}
  /* Verify if selector and receiver are not nil. Else clear the callback */
  if(receiver != nil && selector != nil ) 
	{
	  /* Assign new receiver and selector and register them*/
	  gluNurbReceiver[index] = receiver ;
	  gluNurbSelector[index] = selector ;
	  vm_proxy->registerOOP(gluNurbReceiver[index]) ;
	  vm_proxy->registerOOP(gluNurbSelector[index]) ;

	  /* Setting up the callback pointer */
	  gluNurbsCallback (vm_proxy->OOPToCObject(nurb), which, gst_glu_nurbCallback[index]) ;
	}
  else 
	{
	  gluNurbReceiver[index] = nil ;
	  gluNurbSelector[index] = nil ;

	  /* Cleaning up the callback */
	  gluNurbsCallback (vm_proxy->OOPToCObject(nurb), which, NULL) ;
	}
}

int gst_opengl_gluNurbsCurve (GLUnurbs *nurb, 
				GLint knotCount, OOP knots, GLint stride,
				OOP control,
				GLint order, GLenum type)
{
  GLfloat* knotsFloat ;
  GLfloat* controlFloat ;
  size_t nObjs, size ;

  size = gst_opengl_glMap_size (type);
  if (!size)
    return GL_INVALID_ENUM;

  /* Retreive knots and put them in an array */
  knotsFloat = alloca (sizeof(GLfloat) * knotCount) ;
  knotsFloat = gst_opengl_oop_to_array (knotsFloat, knots, knotCount) ;
  if(!knotsFloat) 
	return GL_INVALID_VALUE;		/* Should fire an interrupt */

  /* Retreive control points and put them in an array */
  nObjs = (order - 1) * stride + size;
  controlFloat = alloca (sizeof(GLfloat) * nObjs) ;
  controlFloat = gst_opengl_oop_to_array (controlFloat, control, nObjs ) ;
  if(!controlFloat)
	return GL_INVALID_VALUE;		/* Should fire an interrupt */
  
  gluNurbsCurve (nurb, knotCount, knotsFloat, stride, controlFloat, order, type) ;

  return 0;
}

int gst_opengl_gluNurbsSurface (GLUnurbs *nurb, 
				GLint sKnotCount, OOP sKnots,
				GLint tKnotCount, OOP tKnots,
				GLint sStride, GLint tStride, 
				OOP control,
				GLint sOrder, GLint tOrder, GLenum type)
{
  GLfloat* sKnotsFloat ;
  GLfloat* tKnotsFloat ;
  GLfloat* controlFloat ;
  size_t nObjs, size ;

  size = gst_opengl_glMap_size (type);
  if (!size)
    return GL_INVALID_ENUM;

  /* Retreive sKnots and put them in an array */
  sKnotsFloat = alloca (sizeof(GLfloat) * sKnotCount) ;
  sKnotsFloat = gst_opengl_oop_to_array (sKnotsFloat, sKnots, sKnotCount) ;
  if(!sKnotsFloat) 
	return GL_INVALID_VALUE;		/* Should fire an interrupt */

  /* Retreive tKnots and put them in an array */
  tKnotsFloat = alloca (sizeof(GLfloat) * tKnotCount) ;
  tKnotsFloat = gst_opengl_oop_to_array (tKnotsFloat, tKnots, sKnotCount) ;
  if(!tKnotsFloat) 
	return GL_INVALID_VALUE;		/* Should fire an interrupt */
  
  /* Retreive control points and put them in an array */
  nObjs = (sOrder - 1) * sStride + (tOrder - 1) * tStride + size;
  controlFloat = alloca (sizeof(GLfloat) * nObjs) ;
  controlFloat = gst_opengl_oop_to_array (controlFloat, control, nObjs ) ;
  if(!controlFloat)
	return GL_INVALID_VALUE;		/* Should fire an interrupt */
  
  gluNurbsSurface (nurb, sKnotCount, sKnotsFloat, tKnotCount,
		   tKnotsFloat, sStride, tStride,
		   controlFloat, sOrder, tOrder, type) ;

  return 0;
}

/* Init module */
void gst_initModule_gluNurbs() {
  int i ;
  vm_proxy = vm_proxy ;

  /* Initialize the Nurbs callback selector and receivers */
  for (i = 0 ; i <N_GLU_CALLBACKS ; ++i )
	gluNurbReceiver[i] = gluNurbSelector[i] = nil ;

  /* Define C Functions */
  vm_proxy->defineCFunc ("gluNurbsCallback", gst_opengl_gluNurbsCallback) ;
  // vm_proxy->defineCFunc ("gluNurbsCallbackData", gluNurbsCallbackData) ;
  // vm_proxy->defineCFunc ("gluNurbsCallbackDataEXT", gluNurbsCallbackDataEXT) ;
  // vm_proxy->defineCFunc ("gluGetNurbsProperty", gluGetNurbsProperty) ;
  vm_proxy->defineCFunc ("gluNewNurbsRenderer", gluNewNurbsRenderer) ;
  vm_proxy->defineCFunc ("gluDeleteNurbsRenderer", gluDeleteNurbsRenderer) ;
  vm_proxy->defineCFunc ("gluNurbsProperty", gluNurbsProperty) ;
  vm_proxy->defineCFunc ("gluNurbsCurve", gst_opengl_gluNurbsCurve) ;
  vm_proxy->defineCFunc ("gluNurbsSurface", gst_opengl_gluNurbsSurface) ;

}
