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
  GLfloat model[16] ;
  GLfloat projection[16] ;
  GLint viewport[4] ;
  size_t nObjs, i ;

  /* Retreive model matrix (4x4) */
  nObjs = vm_proxy->OOPSize(modelMatrix) ;
  if(nObjs < 16) 
	return ;					/* Should fire an interrupt */
  for(i = 0 ; i < 16 ; ++i)
	model[i] = vm_proxy->OOPToFloat(vm_proxy->OOPAt(modelMatrix, i)) ;

  /* Retreive projection matrix (4x4) */
  nObjs = vm_proxy->OOPSize(projectionMatrix) ;
  if(nObjs < 16) 
	return ;					/* Should fire an interrupt */
  for(i = 0 ; i < 16 ; ++i)
	projection[i] = vm_proxy->OOPToFloat(vm_proxy->OOPAt(projectionMatrix, i)) ;

  /* Retreive viewport (4) */
  nObjs = vm_proxy->OOPSize(viewportVertex) ;
  if(nObjs < 4) 
	return ;					/* Should fire an interrupt */
  for(i = 0 ; i < 4 ; ++i)
	viewport[i] = vm_proxy->OOPToInt(vm_proxy->OOPAt(viewportVertex, i)) ;


  gluLoadSamplingMatrices (vm_proxy->OOPToCObject(nurb), model, projection, viewport) ;
}

void gst_opengl_gluPickMatrix (GLdouble x, GLdouble y, GLdouble delX, GLdouble delY, OOP viewportOO)
{
  int nObjs, i ;
  GLint viewport[4] ;
  nObjs = vm_proxy->OOPSize(viewportOO) ;
  if(nObjs != 4)
	return ;					/* Should fire an interrupt */
  for(i = 0 ; i < 4 ; ++i)
	viewport[i] = vm_proxy->OOPToInt(vm_proxy->OOPAt(viewportOO, i)) ;
  gluPickMatrix (x, y, delX, delY, viewport) ;
}

OOP gst_opengl_gluProject (GLdouble objX, GLdouble objY, GLdouble objZ, const GLdouble *model, const GLdouble *proj, const GLint *view) 
{
  GLdouble winX, winY, winZ ;
  OOP result = nil ;					/* An array of 3 doubles */

  if(GL_TRUE == gluProject (objX, objY, objZ, model, proj, view, &winX, &winY, &winZ))
	{
	  result = vm_proxy->objectAlloc(vm_proxy->arrayClass, 3) ; /* Create an array of 3 variables */  
	  vm_proxy->OOPAtPut(result, 0,
								 vm_proxy->longDoubleToOOP(winX)) ;
	  vm_proxy->OOPAtPut(result, 1,
								 vm_proxy->longDoubleToOOP(winY)) ;
	  vm_proxy->OOPAtPut(result, 2,
								 vm_proxy->longDoubleToOOP(winZ)) ;
	}
  return result ;
}

void gst_opengl_gluPwlCurve (OOP nurb, GLint count, OOP data, GLint stride, GLenum type)
{
  GLfloat* dataFloat ;
  size_t nObjs = 0 ;
  size_t i ;					/* index */
  /* Retreive data and put them in an array */
  nObjs = vm_proxy->OOPSize(data) ;
  if(nObjs < count) 
	return ;					/* Should fire an interrupt */
  dataFloat = alloca (sizeof(GLfloat) * count) ;
  for(i = 0 ; i < count ; ++i)
	dataFloat[i] = vm_proxy->OOPToFloat(vm_proxy->OOPAt(data, i)) ;

  gluPwlCurve (vm_proxy->OOPToCObject(nurb),
			   count,
			   dataFloat,
			   stride, 
			   type) ;
}

OOP gst_opengl_gluUnProject (GLdouble winX, GLdouble winY, GLdouble winZ, OOP modelMatrix, OOP projectionMatrix, OOP viewportVertex)
{
  GLdouble model[16], projection[16] ;
  GLint viewport[4] ;
  GLdouble objX, objY, objZ ;
  OOP result = nil ;			/* An array of 3 doubles */
  size_t nObjs, i ;

  /* Retreive model matrix (4x4) */
  nObjs = vm_proxy->OOPSize(modelMatrix) ;
  if(nObjs < 16) 
	return result ;				/* Should fire an interrupt */
  for(i = 0 ; i < 16 ; ++i)
	model[i] = vm_proxy->OOPToFloat(vm_proxy->OOPAt(modelMatrix, i)) ;

  /* Retreive projection matrix (4x4) */
  nObjs = vm_proxy->OOPSize(projectionMatrix) ;
  if(nObjs < 16) 
	return result ;				/* Should fire an interrupt */
  for(i = 0 ; i < 16 ; ++i)
	projection[i] = vm_proxy->OOPToFloat(vm_proxy->OOPAt(projectionMatrix, i)) ;

  /* Retreive viewport (4) */
  nObjs = vm_proxy->OOPSize(viewportVertex) ;
  if(nObjs < 4) 
	return result ;				/* Should fire an interrupt */
  for(i = 0 ; i < 4 ; ++i)
	viewport[i] = (int) vm_proxy->OOPToFloat(vm_proxy->OOPAt(viewportVertex, i)) ;


  if(GL_TRUE == gluUnProject (winX, winY, winZ, model, projection, viewport, &objX, &objY, &objZ)) 
	{
	  /* Create an array of 3 variables */  
	  result = vm_proxy->objectAlloc(vm_proxy->arrayClass, 3) ; 

	  vm_proxy->OOPAtPut(result, 0,
								 vm_proxy->longDoubleToOOP(objX)) ;
	  vm_proxy->OOPAtPut(result, 1,
								 vm_proxy->longDoubleToOOP(objY)) ;
	  vm_proxy->OOPAtPut(result, 2,
								 vm_proxy->longDoubleToOOP(objZ)) ;
	  vm_proxy->registerOOP(result) ;
	}
  return result ;
}

OOP gst_opengl_gluUnProject4 (GLdouble winX, GLdouble winY, GLdouble winZ, GLdouble clipW, 
								OOP modelMatrix, OOP projectionMatrix, OOP viewportVertex, 
								GLdouble nearVal, GLdouble farVal)
{
  GLdouble model[16], projection[16] ;
  GLint viewport[4] ;
  GLdouble objX, objY, objZ, objW ;
  OOP result = nil ;			/* An array of 3 doubles */
  size_t nObjs, i ;

  /* Retreive model matrix (4x4) */
  nObjs = vm_proxy->OOPSize(modelMatrix) ;
  if(nObjs < 16) 
	return result ;				/* Should fire an interrupt */
  for(i = 0 ; i < 16 ; ++i)
	model[i] = vm_proxy->OOPToFloat(vm_proxy->OOPAt(modelMatrix, i)) ;

  /* Retreive projection matrix (4x4) */
  nObjs = vm_proxy->OOPSize(projectionMatrix) ;
  if(nObjs < 16) 
	return result ;				/* Should fire an interrupt */
  for(i = 0 ; i < 16 ; ++i)
	projection[i] = vm_proxy->OOPToFloat(vm_proxy->OOPAt(projectionMatrix, i)) ;

  /* Retreive viewport (4) */
  nObjs = vm_proxy->OOPSize(viewportVertex) ;
  if(nObjs < 4) 
	return result ;				/* Should fire an interrupt */
  for(i = 0 ; i < 4 ; ++i)
	viewport[i] = vm_proxy->OOPToInt(vm_proxy->OOPAt(viewportVertex, i)) ;


  if(GL_TRUE == gluUnProject4 (winX, winY, winZ, clipW, model, projection, viewport, nearVal, farVal, &objX, &objY, &objZ, &objW)) 
	{
	  result = vm_proxy->objectAlloc(vm_proxy->arrayClass, 4) ; /* Create an array of 4 variables */  

	  vm_proxy->OOPAtPut(result, 0,
								 vm_proxy->longDoubleToOOP(objX)) ;
	  vm_proxy->OOPAtPut(result, 1,
								 vm_proxy->longDoubleToOOP(objY)) ;
	  vm_proxy->OOPAtPut(result, 2,
								 vm_proxy->longDoubleToOOP(objZ)) ;
	  vm_proxy->OOPAtPut(result, 3,
								 vm_proxy->longDoubleToOOP(objW)) ;
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
