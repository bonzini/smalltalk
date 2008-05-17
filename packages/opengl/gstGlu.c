/* 
 this file is distributed under the same terms as GNU Smalltalk
*/
#include "gstopengl.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define nil  vm_proxy->nilOOP

void gst_opengl_gluLoadSamplingMatrices (OOP nurb, OOP modelMatrix, OOP projectionMatrix, OOP viewportVertex)
{
  GLfloat model[16], *pmodel ;
  GLfloat projection[16], *pproj ;
  GLint viewport[4], *pvport ;

  pmodel = gst_opengl_oop_to_array (model, modelMatrix, 16);
  pproj = gst_opengl_oop_to_array (projection, projectionMatrix, 16);
  pvport = gst_opengl_oop_to_int_array (viewport, viewportVertex, 4);

  if (!pmodel || !pproj || !pvport)
    return;					/* Should fire an exception */

  gluLoadSamplingMatrices (vm_proxy->OOPToCObject(nurb), pmodel, pproj, pvport) ;
}

void gst_opengl_gluPickMatrix (GLdouble x, GLdouble y, GLdouble delX, GLdouble delY, OOP viewportVertex)
{
  GLint viewport[4], *pvport ;
  pvport = gst_opengl_oop_to_int_array (viewport, viewportVertex, 4);
  if (!pvport)
    return;					/* Should fire an exception */

  gluPickMatrix (x, y, delX, delY, pvport) ;
}

OOP gst_opengl_gluProject (GLdouble objX, GLdouble objY, GLdouble objZ, OOP modelMatrix, OOP projectionMatrix, OOP viewportVertex) 
{
  GLdouble winX, winY, winZ ;
  GLdouble model[16], *pmodel ;
  GLdouble projection[16], *pproj ;
  GLint viewport[4], *pvport ;
  OOP result = nil ;

  pmodel = gst_opengl_oop_to_dbl_array (model, modelMatrix, 16);
  pproj = gst_opengl_oop_to_dbl_array (projection, projectionMatrix, 16);
  pvport = gst_opengl_oop_to_int_array (viewport, viewportVertex, 4);

  if (!pmodel || !pproj || !pvport)
    return result;					/* Should fire an exception */

  if(GL_TRUE == gluProject (objX, objY, objZ, pmodel, pproj, pvport, &winX, &winY, &winZ))
	{
	  result = vm_proxy->objectAlloc(vm_proxy->arrayClass, 3) ; /* Create an array of 3 variables */  
	  vm_proxy->OOPAtPut(result, 0, vm_proxy->floatToOOP(winX)) ;
	  vm_proxy->OOPAtPut(result, 1, vm_proxy->floatToOOP(winY)) ;
	  vm_proxy->OOPAtPut(result, 2, vm_proxy->floatToOOP(winZ)) ;
	}
  return result ;
}

void gst_opengl_gluPwlCurve (OOP nurb, GLint count, OOP data, GLint stride, GLenum type)
{
  GLfloat* dataFloat, *p ;

  dataFloat = alloca (sizeof (GLfloat) * count);
  p = gst_opengl_oop_to_array (dataFloat, data, count);
  if (!p)
    return;

  gluPwlCurve (vm_proxy->OOPToCObject(nurb), count, p, stride, type) ;
}

OOP gst_opengl_gluUnProject (GLdouble winX, GLdouble winY, GLdouble winZ, OOP modelMatrix, OOP projectionMatrix, OOP viewportVertex)
{
  GLdouble objX, objY, objZ ;
  GLdouble model[16], *pmodel ;
  GLdouble projection[16], *pproj ;
  GLint viewport[4], *pvport ;
  OOP result = nil ;

  pmodel = gst_opengl_oop_to_dbl_array (model, modelMatrix, 16);
  pproj = gst_opengl_oop_to_dbl_array (projection, projectionMatrix, 16);
  pvport = gst_opengl_oop_to_int_array (viewport, viewportVertex, 4);

  if (!pmodel || !pproj || !pvport)
    return result;					/* Should fire an exception */

  if(GL_TRUE == gluUnProject (winX, winY, winZ, pmodel, pproj, pvport, &objX, &objY, &objZ)) 
	{
	  /* Create an array of 3 variables */  
	  result = vm_proxy->objectAlloc(vm_proxy->arrayClass, 3) ; 

	  vm_proxy->OOPAtPut(result, 0, vm_proxy->longDoubleToOOP(objX)) ;
	  vm_proxy->OOPAtPut(result, 1, vm_proxy->longDoubleToOOP(objY)) ;
	  vm_proxy->OOPAtPut(result, 2, vm_proxy->longDoubleToOOP(objZ)) ;
	  vm_proxy->registerOOP(result) ;
	}
  return result ;
}

OOP gst_opengl_gluUnProject4 (GLdouble winX, GLdouble winY, GLdouble winZ, GLdouble clipW, 
				OOP modelMatrix, OOP projectionMatrix, OOP viewportVertex, 
				GLdouble nearVal, GLdouble farVal)
{
  GLdouble objX, objY, objZ, objW ;
  GLdouble model[16], *pmodel ;
  GLdouble projection[16], *pproj ;
  GLint viewport[4], *pvport ;
  OOP result = nil ;

  pmodel = gst_opengl_oop_to_dbl_array (model, modelMatrix, 16);
  pproj = gst_opengl_oop_to_dbl_array (projection, projectionMatrix, 16);
  pvport = gst_opengl_oop_to_int_array (viewport, viewportVertex, 4);

  if (!pmodel || !pproj || !pvport)
    return nil;					/* Should fire an exception */

  if(GL_TRUE == gluUnProject4 (winX, winY, winZ, clipW, model, projection, viewport, nearVal, farVal, &objX, &objY, &objZ, &objW)) 
	{
	  result = vm_proxy->objectAlloc(vm_proxy->arrayClass, 4) ; /* Create an array of 4 variables */  

	  vm_proxy->OOPAtPut(result, 0, vm_proxy->longDoubleToOOP(objX)) ;
	  vm_proxy->OOPAtPut(result, 1, vm_proxy->longDoubleToOOP(objY)) ;
	  vm_proxy->OOPAtPut(result, 2, vm_proxy->longDoubleToOOP(objZ)) ;
	  vm_proxy->OOPAtPut(result, 3, vm_proxy->longDoubleToOOP(objW)) ;
	}
  return result ;
}


/* Init module */
void gst_initModule_glu() {

  /* Define C Functions */
  vm_proxy->defineCFunc ("gluBeginCurve", gluBeginCurve) ;
  vm_proxy->defineCFunc ("gluBeginPolygon", gluBeginPolygon) ;
  vm_proxy->defineCFunc ("gluBeginSurface", gluBeginSurface) ;
  vm_proxy->defineCFunc ("gluBeginTrim", gluBeginTrim) ;
  vm_proxy->defineCFunc ("gluBuild1DMipmapLevels", gluBuild1DMipmapLevels) ;
  vm_proxy->defineCFunc ("gluBuild1DMipmaps", gluBuild1DMipmaps) ;
  vm_proxy->defineCFunc ("gluBuild2DMipmapLevels", gluBuild2DMipmapLevels) ;
  vm_proxy->defineCFunc ("gluBuild2DMipmaps", gluBuild2DMipmaps) ;
  vm_proxy->defineCFunc ("gluBuild3DMipmapLevels", gluBuild3DMipmapLevels) ;
  vm_proxy->defineCFunc ("gluBuild3DMipmaps", gluBuild3DMipmaps) ;
  vm_proxy->defineCFunc ("gluCheckExtension", gluCheckExtension) ;
  vm_proxy->defineCFunc ("gluCylinder", gluCylinder) ;
  vm_proxy->defineCFunc ("gluDeleteQuadric", gluDeleteQuadric) ;
  vm_proxy->defineCFunc ("gluDeleteTess", gluDeleteTess) ;
  vm_proxy->defineCFunc ("gluDisk", gluDisk) ;
  vm_proxy->defineCFunc ("gluEndCurve", gluEndCurve) ;
  vm_proxy->defineCFunc ("gluEndPolygon", gluEndPolygon) ;
  vm_proxy->defineCFunc ("gluEndSurface", gluEndSurface) ;
  vm_proxy->defineCFunc ("gluEndTrim", gluEndTrim) ;
  vm_proxy->defineCFunc ("gluGetTessProperty", gluGetTessProperty) ;
  vm_proxy->defineCFunc ("gluLoadSamplingMatrices", gst_opengl_gluLoadSamplingMatrices) ;
  vm_proxy->defineCFunc ("gluLookAt", gluLookAt) ;
  vm_proxy->defineCFunc ("gluNextContour", gluNextContour) ;
  vm_proxy->defineCFunc ("gluOrtho2D", gluOrtho2D) ;
  vm_proxy->defineCFunc ("gluPartialDisk", gluPartialDisk) ;
  vm_proxy->defineCFunc ("gluPerspective", gluPerspective) ;
  vm_proxy->defineCFunc ("gluPickMatrix", gst_opengl_gluPickMatrix) ;
  vm_proxy->defineCFunc ("gluProject", gst_opengl_gluProject) ;
  vm_proxy->defineCFunc ("gluPwlCurve", gst_opengl_gluPwlCurve) ;
  // vm_proxy->defineCFunc ("gluQuadricCallback", gst_opengl_gluQuadricCallback) ;
  vm_proxy->defineCFunc ("gluQuadricDrawStyle", gluQuadricDrawStyle) ;
  vm_proxy->defineCFunc ("gluQuadricNormals", gluQuadricNormals) ;
  vm_proxy->defineCFunc ("gluQuadricOrientation", gluQuadricOrientation) ;
  vm_proxy->defineCFunc ("gluQuadricTexture", gluQuadricTexture) ;
  vm_proxy->defineCFunc ("gluScaleImage", gluScaleImage) ;
  vm_proxy->defineCFunc ("gluSphere", gluSphere) ;
  vm_proxy->defineCFunc ("gluUnProject", gst_opengl_gluUnProject) ;
  vm_proxy->defineCFunc ("gluUnProject4", gst_opengl_gluUnProject4) ;
}
