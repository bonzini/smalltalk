/* 
 this file is distributed under the same terms as GNU Smalltalk
*/
#include "gstopengl.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define nil  vm_proxy->nilOOP


static int
gst_opengl_glClearColorv (OOP colorOOP)
{
  GLfloat color[4];
  GLfloat *p;

  color[3] = 1.0;
  p = gst_opengl_oop_to_array_2 (color, colorOOP, 3, 4);
  gst_opengl_scale_array (p, colorOOP);
  if (!p)
    return GL_INVALID_VALUE;

  glClearColor (p[0], p[1], p[2], p[3]);
  return 0;
}

static int
gst_opengl_glColorv (OOP colorOOP)
{
  GLfloat color[4];
  GLfloat *p;

  color[3] = 1.0;
  p = gst_opengl_oop_to_array_2 (color, colorOOP, 3, 4);
  gst_opengl_scale_array (p, colorOOP);
  if (!p)
    return GL_INVALID_VALUE;

  glColor4fv (p);
  return 0;
}

static int
gst_opengl_glRotatev (GLfloat angle, OOP axisOOP)
{
  GLfloat axis[3];
  GLfloat *p;

  p = gst_opengl_oop_to_array (axis, axisOOP, 3);
  if (!p)
    return GL_INVALID_VALUE;

  glRotatef (angle, p[0], p[1], p[2]);
  return 0;
}

static int
gst_opengl_glTranslatev (OOP distOOP)
{
  GLfloat dist[3];
  GLfloat *p;

  dist[2] = 0.0;
  p = gst_opengl_oop_to_array_2 (dist, distOOP, 2, 3);
  if (!p)
    return GL_INVALID_VALUE;

  glTranslatef (p[0], p[1], p[2]);
  return 0;
}

static int
gst_opengl_glScalev (OOP scaleOOP)
{
  GLfloat scale[3];
  GLfloat *p;

  scale[2] = 1.0;
  p = gst_opengl_oop_to_array_2 (scale, scaleOOP, 2, 3);
  if (!p)
    return GL_INVALID_VALUE;

  glScalef (p[0], p[1], p[2]);
  return 0;
}

static int
gst_opengl_glNormalv (OOP normalOOP)
{
  GLfloat normal[3];
  GLfloat *p;

  p = gst_opengl_oop_to_array (normal, normalOOP, 3);
  if (!p)
    return GL_INVALID_VALUE;

  glNormal3fv (p);
  return 0;
}

static int
gst_opengl_glVertexv (OOP vertexOOP)
{
  GLfloat vertex[4];
  GLfloat *p;

  vertex[2] = 0.0;
  vertex[3] = 1.0;
  p = gst_opengl_oop_to_array_2 (vertex, vertexOOP, 2, 4);
  if (!p)
    return GL_INVALID_VALUE;

  glVertex4fv (p);
  return 0;
}

static int
gst_opengl_glMultMatrixv (OOP matrixOOP)
{
  GLfloat matrix[16];
  GLfloat *p = gst_opengl_oop_to_array (matrix, matrixOOP, 16);
  if (!p)
    return GL_INVALID_VALUE;

  glMultMatrixf (p);
  return 0;
}

static int
gst_opengl_glMultTransposeMatrixv (OOP matrixOOP)
{
  GLfloat matrix[16];
  GLfloat *p = gst_opengl_oop_to_array (matrix, matrixOOP, 16);
  if (!p)
    return GL_INVALID_VALUE;

  glMultTransposeMatrixf (p);
  return 0;
}

static int
gst_opengl_glMap1v (GLenum target, GLdouble u1, GLdouble u2, GLint stride,
		    GLint order, OOP pointsOOP)
{
  int npoints = (order - 1) * stride + 3;
  GLfloat *points = (GLfloat *) alloca (sizeof (GLfloat) * npoints);
  GLfloat *p = gst_opengl_oop_to_array (points, pointsOOP, npoints);
  if (!p)
    return GL_INVALID_VALUE;

  glMap1f (target, u1, u2, stride, order, p);
  return 0;
}

static int
gst_opengl_glMap2v (GLenum target, GLdouble u1, GLdouble u2, GLint ustride,
		    GLint uorder, GLdouble v1, GLdouble v2, GLint vstride,
		    GLint vorder, OOP pointsOOP)
{
  int npoints = (uorder - 1) * ustride + (vorder - 1) * vstride + 3;
  GLfloat *points = (GLfloat *) alloca (sizeof (GLfloat) * npoints);
  GLfloat *p = gst_opengl_oop_to_array (points, pointsOOP, npoints);

  if (!p)
    return GL_INVALID_VALUE;

  glMap2f (target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, p);
  return 0;
}

static int
gst_opengl_glLoadMatrixv (OOP matrixOOP)
{
  GLfloat matrix[16];
  GLfloat *p = gst_opengl_oop_to_array (matrix, matrixOOP, 16);
  if (!p)
    return GL_INVALID_VALUE;

  glLoadMatrixf (p);
  return 0;
}

static int
gst_opengl_glLoadTransposeMatrixv (OOP matrixOOP)
{
  GLfloat matrix[16];
  GLfloat *p = gst_opengl_oop_to_array (matrix, matrixOOP, 16);
  if (!p)
    return GL_INVALID_VALUE;

  glLoadTransposeMatrixf (p);
  return 0;
}

static int
gst_opengl_glLightv_size (GLenum pname)
{
  switch (pname)
    {
    case GL_AMBIENT:
    case GL_DIFFUSE:
    case GL_SPECULAR:
    case GL_POSITION:
      return 4;

    case GL_SPOT_DIRECTION:
      return 3;

    case GL_SPOT_EXPONENT:
    case GL_SPOT_CUTOFF:
    case GL_CONSTANT_ATTENUATION:
    case GL_LINEAR_ATTENUATION:
    case GL_QUADRATIC_ATTENUATION:
      return 1;

    default:
      return 0;
    }
}

static int
gst_opengl_glLightv (GLenum face, GLenum pname, OOP paramsOOP)
{
  GLfloat *params;
  int size = gst_opengl_glLightv_size (pname);
  if (size == 0)
    return GL_INVALID_ENUM;

  params = (GLfloat *) alloca (sizeof (GLfloat) * size);
  params = gst_opengl_oop_to_array (params, paramsOOP, size);
  if (!params)
    return GL_INVALID_VALUE;

  glLightfv (face, pname, params);
  return 0;
}


static int
gst_opengl_glMaterialv_size (GLenum pname)
{
  switch (pname)
    {
    case GL_AMBIENT_AND_DIFFUSE:
    case GL_AMBIENT:
    case GL_DIFFUSE:
    case GL_SPECULAR:
    case GL_EMISSION:
      return 4;

    case GL_COLOR_INDEXES:
      return 3;

    case GL_SHININESS:
      return 1;

    default:
      return 0;
    }
}


static int
gst_opengl_glMaterialv (GLenum face, GLenum pname, OOP paramsOOP)
{
  GLfloat *params;
  int size = gst_opengl_glMaterialv_size (pname);
  if (size == 0)
    return GL_INVALID_ENUM;

  params = (GLfloat *) alloca (sizeof (GLfloat) * size);
  params = gst_opengl_oop_to_array (params, paramsOOP, size);
  if (!params)
    return GL_INVALID_VALUE;

  glMaterialfv (face, pname, params);
  return 0;
}

static int
gst_opengl_glGetv_size (GLenum pname)
{
  switch (pname)
    {
    case GL_MODELVIEW_MATRIX:
    case GL_PROJECTION_MATRIX:
    case GL_TEXTURE_MATRIX:
      return 16;
    case GL_VIEWPORT:
      return 4;
    case GL_MODELVIEW_STACK_DEPTH:
    case GL_PROJECTION_STACK_DEPTH:
    case GL_TEXTURE_STACK_DEPTH:
      return 1;
    default:
      return 0;
    }
}

static OOP
gst_opengl_glGetDoublev ( GLenum pname )
{
  GLdouble *params;
  int i, size;
  OOP anArray = nil;

  size = gst_opengl_glGetv_size (pname);
  if (size > 0)
    {
      /* Allocating an Array object */
      anArray = vm_proxy->objectAlloc (vm_proxy->arrayClass, size);
      vm_proxy->registerOOP (anArray);

      /* retreiving datas from OpenGL */
      params = (GLdouble *) alloca (sizeof (GLdouble) * size);
      glGetDoublev (pname, params);

      /* Converting datas to Smalltalk Float object */
      for (i = 0; i < size; ++i)
	vm_proxy->OOPAtPut (anArray, i, vm_proxy->floatToOOP (params[i]));
    }
  return anArray;
}

static OOP
gst_opengl_glGetFloatv ( GLenum pname )
{
  GLfloat *params;
  int i, size;
  OOP anArray = nil;

  size = gst_opengl_glGetv_size (pname);
  if (size > 0)
    {
      /* Allocating an Array object */
      anArray = vm_proxy->objectAlloc (vm_proxy->arrayClass, size);
      vm_proxy->registerOOP (anArray);

      /* retreiving datas from OpenGL */
      params = (GLfloat *) alloca (sizeof (GLfloat) * size);
      glGetFloatv (pname, params);

      /* Converting datas to Smalltalk Float object */
      for (i = 0; i < size; ++i)
	vm_proxy->OOPAtPut (anArray, i, vm_proxy->floatToOOP (params[i]));
    }
  return anArray;
}

static OOP
gst_opengl_glGetIntegerv ( GLenum pname )
{
  GLint *params;
  int i, size;
  OOP anArray = nil;

  size = gst_opengl_glGetv_size (pname);
  if (size > 0)
    {
      /* Allocating an Array object */
      anArray = vm_proxy->objectAlloc (vm_proxy->arrayClass, size);
      vm_proxy->registerOOP (anArray);

      /* retrieving datas from OpenGL */
      params = (GLint *) alloca (sizeof (GLint) * size);
      glGetIntegerv (pname, params);

      /* Converting datas to Smalltalk int object */
      for (i = 0; i < size; ++i)
	vm_proxy->OOPAtPut (anArray, i, vm_proxy->intToOOP (params[i]));
    }
  return anArray;
}


void gst_initModule_gl()
{
  vm_proxy->defineCFunc ("glAccum", glAccum);
  vm_proxy->defineCFunc ("glActiveTexture", glActiveTexture);
  vm_proxy->defineCFunc ("glAlphaFunc", glAlphaFunc);
  vm_proxy->defineCFunc ("glArrayElement", glArrayElement);
  vm_proxy->defineCFunc ("glBegin", glBegin);
  vm_proxy->defineCFunc ("glBindTexture", glBindTexture);
  vm_proxy->defineCFunc ("glBlendEquation", glBlendEquation);
  vm_proxy->defineCFunc ("glBlendFunc", glBlendFunc);
  vm_proxy->defineCFunc ("glCallList", glCallList); 
  vm_proxy->defineCFunc ("glCallLists", glCallLists); 
  vm_proxy->defineCFunc ("glClear", glClear); 
  vm_proxy->defineCFunc ("glClearAccum", glClearAccum);
  vm_proxy->defineCFunc ("glClearColor", glClearColor);
  vm_proxy->defineCFunc ("glClearColorv", gst_opengl_glClearColorv);
  vm_proxy->defineCFunc ("glClearDepth", glClearDepth);
  vm_proxy->defineCFunc ("glClearIndex", glClearIndex);
  vm_proxy->defineCFunc ("glClearStencil", glClearStencil);
  vm_proxy->defineCFunc ("glClientActiveTexture", glClientActiveTexture);
  vm_proxy->defineCFunc ("glClipPlane", glClipPlane);
  vm_proxy->defineCFunc ("glColor3b", glColor3b);
  vm_proxy->defineCFunc ("glColor3bv", glColor3bv);
  vm_proxy->defineCFunc ("glColor3d", glColor3d);
  vm_proxy->defineCFunc ("glColor3dv", glColor3dv);
  vm_proxy->defineCFunc ("glColor3f", glColor3f);
  vm_proxy->defineCFunc ("glColor3fv", glColor3fv);
  vm_proxy->defineCFunc ("glColor3i", glColor3i);
  vm_proxy->defineCFunc ("glColor3iv", glColor3iv);
  vm_proxy->defineCFunc ("glColor3s", glColor3s);
  vm_proxy->defineCFunc ("glColor3sv", glColor3sv);
  vm_proxy->defineCFunc ("glColor3ub", glColor3ub);
  vm_proxy->defineCFunc ("glColor3ubv", glColor3ubv);
  vm_proxy->defineCFunc ("glColor3ui", glColor3ui);
  vm_proxy->defineCFunc ("glColor3uiv", glColor3uiv);
  vm_proxy->defineCFunc ("glColor3us", glColor3us);
  vm_proxy->defineCFunc ("glColor3usv", glColor3usv);
  vm_proxy->defineCFunc ("glColor4bv", glColor4bv);
  vm_proxy->defineCFunc ("glColor4dv", glColor4dv);
  vm_proxy->defineCFunc ("glColor4fv", glColor4fv);
  vm_proxy->defineCFunc ("glColor4iv", glColor4iv);
  vm_proxy->defineCFunc ("glColor4sv", glColor4sv);
  vm_proxy->defineCFunc ("glColor4ubv", glColor4ubv);
  vm_proxy->defineCFunc ("glColor4uiv", glColor4uiv);
  vm_proxy->defineCFunc ("glColor4usv", glColor4usv);
  vm_proxy->defineCFunc ("glColorv", gst_opengl_glColorv);
  vm_proxy->defineCFunc ("glColorMask", glColorMask);
  vm_proxy->defineCFunc ("glColorMaterial", glColorMaterial);
  vm_proxy->defineCFunc ("glCompressedTexImage1D", glCompressedTexImage1D);
  vm_proxy->defineCFunc ("glCompressedTexImage2D", glCompressedTexImage2D);
  vm_proxy->defineCFunc ("glCompressedTexImage3D", glCompressedTexImage3D);
  vm_proxy->defineCFunc ("glCompressedTexSubImage1D", glCompressedTexSubImage1D);
  vm_proxy->defineCFunc ("glCompressedTexSubImage2D", glCompressedTexSubImage2D);
  vm_proxy->defineCFunc ("glCompressedTexSubImage3D", glCompressedTexSubImage3D);
  vm_proxy->defineCFunc ("glCullFace", glCullFace);
  vm_proxy->defineCFunc ("glDeleteLists", glDeleteLists);
  vm_proxy->defineCFunc ("glDeleteTextures", glDeleteTextures);
  vm_proxy->defineCFunc ("glDepthFunc", glDepthFunc);
  vm_proxy->defineCFunc ("glDepthMask", glDepthMask);
  vm_proxy->defineCFunc ("glDepthRange", glDepthRange);
  vm_proxy->defineCFunc ("glDisable", glDisable);
  vm_proxy->defineCFunc ("glDisableClientState", glDisableClientState);
  vm_proxy->defineCFunc ("glDrawArrays", glDrawArrays);
  vm_proxy->defineCFunc ("glDrawBuffer", glDrawBuffer);
  vm_proxy->defineCFunc ("glEdgeFlag", glEdgeFlag);
  vm_proxy->defineCFunc ("glEdgeFlagPointer", glEdgeFlagPointer);
  vm_proxy->defineCFunc ("glEdgeFlagv", glEdgeFlagv);
  vm_proxy->defineCFunc ("glEnable", glEnable);
  vm_proxy->defineCFunc ("glEnableClientState", glEnableClientState);
  vm_proxy->defineCFunc ("glEnd", glEnd); 
  vm_proxy->defineCFunc ("glEndList", glEndList);
  vm_proxy->defineCFunc ("glEvalCoord1d", glEvalCoord1d);
  vm_proxy->defineCFunc ("glEvalCoord1dv", glEvalCoord1dv);
  vm_proxy->defineCFunc ("glEvalCoord1f", glEvalCoord1f);
  vm_proxy->defineCFunc ("glEvalCoord1fv", glEvalCoord1fv);
  vm_proxy->defineCFunc ("glEvalCoord2d", glEvalCoord2d);
  vm_proxy->defineCFunc ("glEvalCoord2dv", glEvalCoord2dv);
  vm_proxy->defineCFunc ("glEvalCoord2f", glEvalCoord2f);
  vm_proxy->defineCFunc ("glEvalCoord2fv", glEvalCoord2fv);
  vm_proxy->defineCFunc ("glEvalMesh1", glEvalMesh1);
  vm_proxy->defineCFunc ("glEvalMesh2", glEvalMesh2);
  vm_proxy->defineCFunc ("glEvalPoint1", glEvalPoint1);
  vm_proxy->defineCFunc ("glEvalPoint2", glEvalPoint2);
  vm_proxy->defineCFunc ("glFeedbackBuffer", glFeedbackBuffer);
  vm_proxy->defineCFunc ("glFinish", glFinish);
  vm_proxy->defineCFunc ("glFlush", glFlush); 
  vm_proxy->defineCFunc ("glFogf", glFogf);
  vm_proxy->defineCFunc ("glFogfv", glFogfv);
  vm_proxy->defineCFunc ("glFogi", glFogi);
  vm_proxy->defineCFunc ("glFogiv", glFogiv);
  vm_proxy->defineCFunc ("glFrontFace", glFrontFace);
  vm_proxy->defineCFunc ("glFrustum", glFrustum);
  vm_proxy->defineCFunc ("glGenLists", glGenLists);
  vm_proxy->defineCFunc ("glGenTextures", glGenTextures);
  // vm_proxy->defineCFunc ("glGetBooleanv", glGetBooleanv);
  vm_proxy->defineCFunc ("glGetClipPlane", glGetClipPlane);
  vm_proxy->defineCFunc ("glGetCompressedTexImage", glGetCompressedTexImage);
  vm_proxy->defineCFunc ("glGetDoublev", gst_opengl_glGetDoublev); 
  vm_proxy->defineCFunc ("glGetError", glGetError);
  vm_proxy->defineCFunc ("glGetFloatv", gst_opengl_glGetFloatv);
  vm_proxy->defineCFunc ("glGetIntegerv", gst_opengl_glGetIntegerv);
  vm_proxy->defineCFunc ("glGetLightfv", glGetLightfv);
  vm_proxy->defineCFunc ("glGetLightiv", glGetLightiv);
  vm_proxy->defineCFunc ("glGetMapdv", glGetMapdv);
  vm_proxy->defineCFunc ("glGetMapfv", glGetMapfv);
  vm_proxy->defineCFunc ("glGetMapiv", glGetMapiv);
  vm_proxy->defineCFunc ("glGetMaterialfv", glGetMaterialfv);
  vm_proxy->defineCFunc ("glGetMaterialiv", glGetMaterialiv);
  vm_proxy->defineCFunc ("glGetPixelMapfv", glGetPixelMapfv);
  vm_proxy->defineCFunc ("glGetPixelMapuiv", glGetPixelMapuiv);
  vm_proxy->defineCFunc ("glGetPixelMapusv", glGetPixelMapusv);
  vm_proxy->defineCFunc ("glGetPointerv", glGetPointerv);
  vm_proxy->defineCFunc ("glGetPolygonStipple", glGetPolygonStipple);
  vm_proxy->defineCFunc ("glGetTexEnvfv", glGetTexEnvfv);
  vm_proxy->defineCFunc ("glGetTexEnviv", glGetTexEnviv);
  vm_proxy->defineCFunc ("glGetTexGendv", glGetTexGendv);
  vm_proxy->defineCFunc ("glGetTexGenfv", glGetTexGenfv);
  vm_proxy->defineCFunc ("glGetTexGeniv", glGetTexGeniv);
  vm_proxy->defineCFunc ("glGetTexImage", glGetTexImage);
  vm_proxy->defineCFunc ("glGetTexLevelParameterfv", glGetTexLevelParameterfv);
  vm_proxy->defineCFunc ("glGetTexLevelParameteriv", glGetTexLevelParameteriv);
  vm_proxy->defineCFunc ("glGetTexParameterfv", glGetTexParameterfv);
  vm_proxy->defineCFunc ("glGetTexParameteriv", glGetTexParameteriv);
  vm_proxy->defineCFunc ("glHint", glHint);
  vm_proxy->defineCFunc ("glIndexMask", glIndexMask);
  vm_proxy->defineCFunc ("glIndexd", glIndexd);
  vm_proxy->defineCFunc ("glIndexdv", glIndexdv);
  vm_proxy->defineCFunc ("glIndexf", glIndexf);
  vm_proxy->defineCFunc ("glIndexfv", glIndexfv);
  vm_proxy->defineCFunc ("glIndexi", glIndexi);
  vm_proxy->defineCFunc ("glIndexiv", glIndexiv);
  vm_proxy->defineCFunc ("glIndexs", glIndexs);
  vm_proxy->defineCFunc ("glIndexsv", glIndexsv);
  vm_proxy->defineCFunc ("glIndexub", glIndexub);
  vm_proxy->defineCFunc ("glIndexubv", glIndexubv);
  vm_proxy->defineCFunc ("glInitNames", glInitNames);
  vm_proxy->defineCFunc ("glIsEnabled", glIsEnabled);
  vm_proxy->defineCFunc ("glIsList", glIsList);
  vm_proxy->defineCFunc ("glIsTexture", glIsTexture);
  vm_proxy->defineCFunc ("glLightModelf", glLightModelf);
  vm_proxy->defineCFunc ("glLightModelfv", glLightModelfv);
  vm_proxy->defineCFunc ("glLightModeli", glLightModeli);
  vm_proxy->defineCFunc ("glLightModeliv", glLightModeliv);
  vm_proxy->defineCFunc ("glLightf", glLightf);
  vm_proxy->defineCFunc ("glLightfv", glLightfv);
  vm_proxy->defineCFunc ("glLighti", glLighti);
  vm_proxy->defineCFunc ("glLightiv", glLightiv);
  vm_proxy->defineCFunc ("glLightv", gst_opengl_glLightv);
  vm_proxy->defineCFunc ("glLineStipple", glLineStipple);
  vm_proxy->defineCFunc ("glLineWidth", glLineWidth);
  vm_proxy->defineCFunc ("glListBase", glListBase); 
  vm_proxy->defineCFunc ("glLoadIdentity", glLoadIdentity);
  vm_proxy->defineCFunc ("glLoadMatrixd", glLoadMatrixd);
  vm_proxy->defineCFunc ("glLoadMatrixf", glLoadMatrixf);
  vm_proxy->defineCFunc ("glLoadMatrixv", gst_opengl_glLoadMatrixv);
  vm_proxy->defineCFunc ("glLoadName", glLoadName);
  vm_proxy->defineCFunc ("glLoadTransposeMatrixd", glLoadTransposeMatrixd);
  vm_proxy->defineCFunc ("glLoadTransposeMatrixf", glLoadTransposeMatrixf);
  vm_proxy->defineCFunc ("glLoadTransposeMatrixv", gst_opengl_glLoadTransposeMatrixv);
  vm_proxy->defineCFunc ("glLogicOp", glLogicOp);
  vm_proxy->defineCFunc ("glMapGrid1d", glMapGrid1d); 
  vm_proxy->defineCFunc ("glMapGrid1f", glMapGrid1f); 
  vm_proxy->defineCFunc ("glMapGrid2d", glMapGrid2d); 
  vm_proxy->defineCFunc ("glMapGrid2f", glMapGrid2f); 
  vm_proxy->defineCFunc ("glMaterialf", glMaterialf);
  vm_proxy->defineCFunc ("glMaterialfv", glMaterialfv);
  vm_proxy->defineCFunc ("glMateriali", glMateriali);
  vm_proxy->defineCFunc ("glMaterialiv", glMaterialiv);
  vm_proxy->defineCFunc ("glMaterialv", gst_opengl_glMaterialv);
  vm_proxy->defineCFunc ("glMatrixMode", glMatrixMode);
  vm_proxy->defineCFunc ("glMultMatrixd", glMultMatrixd);
  vm_proxy->defineCFunc ("glMultMatrixf", glMultMatrixf);
  vm_proxy->defineCFunc ("glMultMatrixv", gst_opengl_glMultMatrixv);
  vm_proxy->defineCFunc ("glMultTransposeMatrixd", glMultTransposeMatrixd);
  vm_proxy->defineCFunc ("glMultTransposeMatrixf", glMultTransposeMatrixf);
  vm_proxy->defineCFunc ("glMultTransposeMatrixv", gst_opengl_glMultTransposeMatrixv);
  vm_proxy->defineCFunc ("glMultiTexCoord1d", glMultiTexCoord1d);
  vm_proxy->defineCFunc ("glMultiTexCoord1dv", glMultiTexCoord1dv);
  vm_proxy->defineCFunc ("glMultiTexCoord1f", glMultiTexCoord1f);
  vm_proxy->defineCFunc ("glMultiTexCoord1fv", glMultiTexCoord1fv);
  vm_proxy->defineCFunc ("glMultiTexCoord1i", glMultiTexCoord1i);
  vm_proxy->defineCFunc ("glMultiTexCoord1iv", glMultiTexCoord1iv);
  vm_proxy->defineCFunc ("glMultiTexCoord1s", glMultiTexCoord1s);
  vm_proxy->defineCFunc ("glMultiTexCoord1sv", glMultiTexCoord1sv);
  vm_proxy->defineCFunc ("glMultiTexCoord2d", glMultiTexCoord2d);
  vm_proxy->defineCFunc ("glMultiTexCoord2dv", glMultiTexCoord2dv);
  vm_proxy->defineCFunc ("glMultiTexCoord2f", glMultiTexCoord2f);
  vm_proxy->defineCFunc ("glMultiTexCoord2fv", glMultiTexCoord2fv);
  vm_proxy->defineCFunc ("glMultiTexCoord2i", glMultiTexCoord2i);
  vm_proxy->defineCFunc ("glMultiTexCoord2iv", glMultiTexCoord2iv);
  vm_proxy->defineCFunc ("glMultiTexCoord2s", glMultiTexCoord2s);
  vm_proxy->defineCFunc ("glMultiTexCoord2sv", glMultiTexCoord2sv);
  vm_proxy->defineCFunc ("glMultiTexCoord3d", glMultiTexCoord3d);
  vm_proxy->defineCFunc ("glMultiTexCoord3dv", glMultiTexCoord3dv);
  vm_proxy->defineCFunc ("glMultiTexCoord3f", glMultiTexCoord3f);
  vm_proxy->defineCFunc ("glMultiTexCoord3fv", glMultiTexCoord3fv);
  vm_proxy->defineCFunc ("glMultiTexCoord3i", glMultiTexCoord3i);
  vm_proxy->defineCFunc ("glMultiTexCoord3iv", glMultiTexCoord3iv);
  vm_proxy->defineCFunc ("glMultiTexCoord3s", glMultiTexCoord3s);
  vm_proxy->defineCFunc ("glMultiTexCoord3sv", glMultiTexCoord3sv);
  vm_proxy->defineCFunc ("glMultiTexCoord4d", glMultiTexCoord4d);
  vm_proxy->defineCFunc ("glMultiTexCoord4dv", glMultiTexCoord4dv);
  vm_proxy->defineCFunc ("glMultiTexCoord4f", glMultiTexCoord4f);
  vm_proxy->defineCFunc ("glMultiTexCoord4fv", glMultiTexCoord4fv);
  vm_proxy->defineCFunc ("glMultiTexCoord4i", glMultiTexCoord4i);
  vm_proxy->defineCFunc ("glMultiTexCoord4iv", glMultiTexCoord4iv);
  vm_proxy->defineCFunc ("glMultiTexCoord4s", glMultiTexCoord4s);
  vm_proxy->defineCFunc ("glMultiTexCoord4sv", glMultiTexCoord4sv);
  vm_proxy->defineCFunc ("glNewList", glNewList);
  vm_proxy->defineCFunc ("glNormal3b", glNormal3b);
  vm_proxy->defineCFunc ("glNormal3bv", glNormal3bv);
  vm_proxy->defineCFunc ("glNormal3d", glNormal3d);
  vm_proxy->defineCFunc ("glNormal3dv", glNormal3dv);
  vm_proxy->defineCFunc ("glNormal3f", glNormal3f);
  vm_proxy->defineCFunc ("glNormal3fv", glNormal3fv);
  vm_proxy->defineCFunc ("glNormal3i", glNormal3i);
  vm_proxy->defineCFunc ("glNormal3iv", glNormal3iv);
  vm_proxy->defineCFunc ("glNormal3s", glNormal3s);
  vm_proxy->defineCFunc ("glNormal3sv", glNormal3sv);
  vm_proxy->defineCFunc ("glNormalv", gst_opengl_glNormalv);
  vm_proxy->defineCFunc ("glOrtho", glOrtho);
  vm_proxy->defineCFunc ("glPassThrough", glPassThrough);
  vm_proxy->defineCFunc ("glPixelStoref", glPixelStoref); 
  vm_proxy->defineCFunc ("glPixelStorei", glPixelStorei);
  vm_proxy->defineCFunc ("glPixelTransferf", glPixelTransferf);
  vm_proxy->defineCFunc ("glPixelTransferi", glPixelTransferi);
  vm_proxy->defineCFunc ("glPixelZoom", glPixelZoom);
  vm_proxy->defineCFunc ("glPointSize", glPointSize);
  vm_proxy->defineCFunc ("glPolygonMode", glPolygonMode);
  vm_proxy->defineCFunc ("glPolygonOffset", glPolygonOffset);
  vm_proxy->defineCFunc ("glPolygonStipple", glPolygonStipple);
  vm_proxy->defineCFunc ("glPopAttrib", glPopAttrib);
  vm_proxy->defineCFunc ("glPopClientAttrib", glPopClientAttrib);
  vm_proxy->defineCFunc ("glPopMatrix", glPopMatrix);
  vm_proxy->defineCFunc ("glPopName", glPopName);
  vm_proxy->defineCFunc ("glPushAttrib", glPushAttrib);
  vm_proxy->defineCFunc ("glPushClientAttrib", glPushClientAttrib);
  vm_proxy->defineCFunc ("glPushMatrix", glPushMatrix); 
  vm_proxy->defineCFunc ("glPushName", glPushName);
  vm_proxy->defineCFunc ("glRasterPos2d", glRasterPos2d);
  vm_proxy->defineCFunc ("glRasterPos2dv", glRasterPos2dv);
  vm_proxy->defineCFunc ("glRasterPos2f", glRasterPos2f);
  vm_proxy->defineCFunc ("glRasterPos2fv", glRasterPos2fv);
  vm_proxy->defineCFunc ("glRasterPos2i", glRasterPos2i);
  vm_proxy->defineCFunc ("glRasterPos2iv", glRasterPos2iv);
  vm_proxy->defineCFunc ("glRasterPos2s", glRasterPos2s);
  vm_proxy->defineCFunc ("glRasterPos2sv", glRasterPos2sv);
  vm_proxy->defineCFunc ("glRasterPos3d", glRasterPos3d);
  vm_proxy->defineCFunc ("glRasterPos3dv", glRasterPos3dv);
  vm_proxy->defineCFunc ("glRasterPos3f", glRasterPos3f);
  vm_proxy->defineCFunc ("glRasterPos3fv", glRasterPos3fv);
  vm_proxy->defineCFunc ("glRasterPos3i", glRasterPos3i);
  vm_proxy->defineCFunc ("glRasterPos3iv", glRasterPos3iv);
  vm_proxy->defineCFunc ("glRasterPos3s", glRasterPos3s);
  vm_proxy->defineCFunc ("glRasterPos3sv", glRasterPos3sv);
  vm_proxy->defineCFunc ("glRasterPos4d", glRasterPos4d);
  vm_proxy->defineCFunc ("glRasterPos4dv", glRasterPos4dv);
  vm_proxy->defineCFunc ("glRasterPos4f", glRasterPos4f);
  vm_proxy->defineCFunc ("glRasterPos4fv", glRasterPos4fv);
  vm_proxy->defineCFunc ("glRasterPos4i", glRasterPos4i);
  vm_proxy->defineCFunc ("glRasterPos4iv", glRasterPos4iv);
  vm_proxy->defineCFunc ("glRasterPos4s", glRasterPos4s);
  vm_proxy->defineCFunc ("glRasterPos4sv", glRasterPos4sv);
  vm_proxy->defineCFunc ("glReadBuffer", glReadBuffer);
  vm_proxy->defineCFunc ("glRectd", glRectd);
  vm_proxy->defineCFunc ("glRectdv", glRectdv);
  vm_proxy->defineCFunc ("glRectf", glRectf);
  vm_proxy->defineCFunc ("glRectfv", glRectfv);
  vm_proxy->defineCFunc ("glRecti", glRecti);
  vm_proxy->defineCFunc ("glRectiv", glRectiv);
  vm_proxy->defineCFunc ("glRects", glRects);
  vm_proxy->defineCFunc ("glRectsv", glRectsv);
  vm_proxy->defineCFunc ("glRenderMode", glRenderMode);
  vm_proxy->defineCFunc ("glResetHistogram", glResetHistogram);
  vm_proxy->defineCFunc ("glResetMinmax", glResetMinmax);
  vm_proxy->defineCFunc ("glRotatev", gst_opengl_glRotatev);
  vm_proxy->defineCFunc ("glRotated", glRotated);
  vm_proxy->defineCFunc ("glRotatef", glRotatef);
  vm_proxy->defineCFunc ("glSampleCoverage", glSampleCoverage);
  vm_proxy->defineCFunc ("glScalev", gst_opengl_glScalev);
  vm_proxy->defineCFunc ("glScaled", glScaled);
  vm_proxy->defineCFunc ("glScalef", glScalef);
  vm_proxy->defineCFunc ("glScissor", glScissor);
  vm_proxy->defineCFunc ("glSelectBuffer", glSelectBuffer);
  vm_proxy->defineCFunc ("glShadeModel", glShadeModel);
  vm_proxy->defineCFunc ("glStencilFunc", glStencilFunc);
  vm_proxy->defineCFunc ("glStencilMask", glStencilMask);
  vm_proxy->defineCFunc ("glStencilOp", glStencilOp);
  vm_proxy->defineCFunc ("glTexCoord1d", glTexCoord1d);
  vm_proxy->defineCFunc ("glTexCoord1dv", glTexCoord1dv);
  vm_proxy->defineCFunc ("glTexCoord1f", glTexCoord1f);
  vm_proxy->defineCFunc ("glTexCoord1fv", glTexCoord1fv);
  vm_proxy->defineCFunc ("glTexCoord1i", glTexCoord1i);
  vm_proxy->defineCFunc ("glTexCoord1iv", glTexCoord1iv);
  vm_proxy->defineCFunc ("glTexCoord1s", glTexCoord1s);
  vm_proxy->defineCFunc ("glTexCoord1sv", glTexCoord1sv);
  vm_proxy->defineCFunc ("glTexCoord2d", glTexCoord2d);
  vm_proxy->defineCFunc ("glTexCoord2dv", glTexCoord2dv);
  vm_proxy->defineCFunc ("glTexCoord2f", glTexCoord2f);
  vm_proxy->defineCFunc ("glTexCoord2fv", glTexCoord2fv);
  vm_proxy->defineCFunc ("glTexCoord2i", glTexCoord2i);
  vm_proxy->defineCFunc ("glTexCoord2iv", glTexCoord2iv);
  vm_proxy->defineCFunc ("glTexCoord2s", glTexCoord2s);
  vm_proxy->defineCFunc ("glTexCoord2sv", glTexCoord2sv);
  vm_proxy->defineCFunc ("glTexCoord3d", glTexCoord3d);
  vm_proxy->defineCFunc ("glTexCoord3dv", glTexCoord3dv);
  vm_proxy->defineCFunc ("glTexCoord3f", glTexCoord3f);
  vm_proxy->defineCFunc ("glTexCoord3fv", glTexCoord3fv);
  vm_proxy->defineCFunc ("glTexCoord3i", glTexCoord3i);
  vm_proxy->defineCFunc ("glTexCoord3iv", glTexCoord3iv);
  vm_proxy->defineCFunc ("glTexCoord3s", glTexCoord3s);
  vm_proxy->defineCFunc ("glTexCoord3sv", glTexCoord3sv);
  vm_proxy->defineCFunc ("glTexCoord4d", glTexCoord4d);
  vm_proxy->defineCFunc ("glTexCoord4dv", glTexCoord4dv);
  vm_proxy->defineCFunc ("glTexCoord4f", glTexCoord4f);
  vm_proxy->defineCFunc ("glTexCoord4fv", glTexCoord4fv);
  vm_proxy->defineCFunc ("glTexCoord4i", glTexCoord4i);
  vm_proxy->defineCFunc ("glTexCoord4iv", glTexCoord4iv);
  vm_proxy->defineCFunc ("glTexCoord4s", glTexCoord4s);
  vm_proxy->defineCFunc ("glTexCoord4sv", glTexCoord4sv);
  vm_proxy->defineCFunc ("glTexEnvf", glTexEnvf);
  vm_proxy->defineCFunc ("glTexEnvfv", glTexEnvfv);
  vm_proxy->defineCFunc ("glTexEnvi", glTexEnvi);
  vm_proxy->defineCFunc ("glTexEnviv", glTexEnviv);
  vm_proxy->defineCFunc ("glTexGend", glTexGend);
  vm_proxy->defineCFunc ("glTexGendv", glTexGendv);
  vm_proxy->defineCFunc ("glTexGenf", glTexGenf);
  vm_proxy->defineCFunc ("glTexGenfv", glTexGenfv);
  vm_proxy->defineCFunc ("glTexGeni", glTexGeni);
  vm_proxy->defineCFunc ("glTexGeniv", glTexGeniv);
  vm_proxy->defineCFunc ("glTexImage1D", glTexImage1D);
  vm_proxy->defineCFunc ("glTexImage2D", glTexImage2D);
  vm_proxy->defineCFunc ("glTexImage2D", glTexImage2D);
  vm_proxy->defineCFunc ("glTexParameterf", glTexParameterf);
  vm_proxy->defineCFunc ("glTexParameterfv", glTexParameterfv);
  vm_proxy->defineCFunc ("glTexParameteri", glTexParameteri);
  vm_proxy->defineCFunc ("glTexParameteriv", glTexParameteriv);
  vm_proxy->defineCFunc ("glTranslatev", gst_opengl_glTranslatev);
  vm_proxy->defineCFunc ("glTranslated", glTranslated);
  vm_proxy->defineCFunc ("glTranslatef", glTranslatef);
  vm_proxy->defineCFunc ("glVertex2d", glVertex2d);
  vm_proxy->defineCFunc ("glVertex2dv", glVertex2dv);
  vm_proxy->defineCFunc ("glVertex2f", glVertex2f);
  vm_proxy->defineCFunc ("glVertex2fv", glVertex2fv);
  vm_proxy->defineCFunc ("glVertex2i", glVertex2i);
  vm_proxy->defineCFunc ("glVertex2iv", glVertex2iv);
  vm_proxy->defineCFunc ("glVertex2s", glVertex2s);
  vm_proxy->defineCFunc ("glVertex2sv", glVertex2sv);
  vm_proxy->defineCFunc ("glVertex3d", glVertex3d);
  vm_proxy->defineCFunc ("glVertex3dv", glVertex3dv);
  vm_proxy->defineCFunc ("glVertex3f", glVertex3f);
  vm_proxy->defineCFunc ("glVertex3fv", glVertex3fv);
  vm_proxy->defineCFunc ("glVertex3i", glVertex3i);
  vm_proxy->defineCFunc ("glVertex3iv", glVertex3iv);
  vm_proxy->defineCFunc ("glVertex3s", glVertex3s);
  vm_proxy->defineCFunc ("glVertex3sv", glVertex3sv);
  vm_proxy->defineCFunc ("glVertex4d", glVertex4d);
  vm_proxy->defineCFunc ("glVertex4dv", glVertex4dv);
  vm_proxy->defineCFunc ("glVertex4f", glVertex4f);
  vm_proxy->defineCFunc ("glVertex4fv", glVertex4fv);
  vm_proxy->defineCFunc ("glVertex4i", glVertex4i);
  vm_proxy->defineCFunc ("glVertex4iv", glVertex4iv);
  vm_proxy->defineCFunc ("glVertex4s", glVertex4s);
  vm_proxy->defineCFunc ("glVertex4sv", glVertex4sv);
  vm_proxy->defineCFunc ("glVertexv", gst_opengl_glVertexv);
  vm_proxy->defineCFunc ("glViewport", glViewport);
  vm_proxy->defineCFunc("glCopyTexImage1D", glCopyTexImage1D);
  vm_proxy->defineCFunc("glCopyTexImage2D", glCopyTexImage2D);
  vm_proxy->defineCFunc("glCopyTexSubImage1D", glCopyTexSubImage1D);
  vm_proxy->defineCFunc("glCopyTexSubImage2D", glCopyTexSubImage2D);
  vm_proxy->defineCFunc("glMap1d", glMap1d);
  vm_proxy->defineCFunc("glMap1f", glMap1f);
  vm_proxy->defineCFunc("glMap1v", gst_opengl_glMap1v);
  vm_proxy->defineCFunc("glMap2d", glMap2d);
  vm_proxy->defineCFunc("glMap2f", glMap2f);
  vm_proxy->defineCFunc("glMap2v", gst_opengl_glMap2v);
  vm_proxy->defineCFunc("glTexSubImage1D", glTexSubImage1D);
  vm_proxy->defineCFunc("glTexSubImage2D", glTexSubImage2D);
  
#if 0
  vm_proxy->defineCFunc ("glActiveTextureARB", glActiveTextureARB);
  vm_proxy->defineCFunc ("glClientActiveTextureARB", glClientActiveTextureARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1dARB", glMultiTexCoord1dARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1dvARB", glMultiTexCoord1dvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1fARB", glMultiTexCoord1fARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1fvARB", glMultiTexCoord1fvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1iARB", glMultiTexCoord1iARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1ivARB", glMultiTexCoord1ivARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1sARB", glMultiTexCoord1sARB);
  vm_proxy->defineCFunc ("glMultiTexCoord1svARB", glMultiTexCoord1svARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2dARB", glMultiTexCoord2dARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2dvARB", glMultiTexCoord2dvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2fARB", glMultiTexCoord2fARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2fvARB", glMultiTexCoord2fvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2iARB", glMultiTexCoord2iARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2ivARB", glMultiTexCoord2ivARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2sARB", glMultiTexCoord2sARB);
  vm_proxy->defineCFunc ("glMultiTexCoord2svARB", glMultiTexCoord2svARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3dARB", glMultiTexCoord3dARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3dvARB", glMultiTexCoord3dvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3fARB", glMultiTexCoord3fARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3fvARB", glMultiTexCoord3fvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3iARB", glMultiTexCoord3iARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3ivARB", glMultiTexCoord3ivARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3sARB", glMultiTexCoord3sARB);
  vm_proxy->defineCFunc ("glMultiTexCoord3svARB", glMultiTexCoord3svARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4dARB", glMultiTexCoord4dARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4dvARB", glMultiTexCoord4dvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4fARB", glMultiTexCoord4fARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4fvARB", glMultiTexCoord4fvARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4iARB", glMultiTexCoord4iARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4ivARB", glMultiTexCoord4ivARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4sARB", glMultiTexCoord4sARB);
  vm_proxy->defineCFunc ("glMultiTexCoord4svARB", glMultiTexCoord4svARB);
#endif
  
#if 0
  vm_proxy->defineCFunc ("glDisableTraceMESA", glDisableTraceMESA);
  vm_proxy->defineCFunc ("glEnableTraceMESA", glEnableTraceMESA);
  vm_proxy->defineCFunc ("glEndTraceMESA", glEndTraceMESA);
  vm_proxy->defineCFunc ("glGetProgramRegisterfvMESA", glGetProgramRegisterfvMESA);
  vm_proxy->defineCFunc ("glProgramCallbackMESA", glProgramCallbackMESA);
  vm_proxy->defineCFunc ("glTraceAssertAttribMESA", glTraceAssertAttribMESA);
#endif
  
#if 0
  vm_proxy->defineCFunc ("glBlendEquationSeparateATI", glBlendEquationSeparateATI);
#endif
}
