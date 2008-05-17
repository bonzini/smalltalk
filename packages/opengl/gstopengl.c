/* 
 this file is distributed under the same terms as GNU Smalltalk
*/
#include "gstopengl.h"
#include <limits.h>

VMProxy *vm_proxy = NULL ;

void
gst_opengl_scale_array (GLfloat *dest, OOP sourceOOP)
{
  enum gst_indexed_kind kind;
  int i, n;

  n = vm_proxy->basicSize (sourceOOP);
  kind = vm_proxy->OOPIndexedKind (sourceOOP);
  switch (kind)
    {

#define SCALE(min, max)							  \
  for (i = 0; i < n; i++)						  \
    if (min == 0)							  \
      dest[i] = (dest[i] - (float)(min)) / ((float)(max) - (float)(min)); \
    else								  \
      dest[i] = (dest[i] - (float)(min)) / ((float)(max) - (float)(min))  \
		* 2.0 - 1.0;						  \
  break;

      case GST_ISP_SCHAR:
	SCALE (SCHAR_MIN, SCHAR_MAX);
      case GST_ISP_UCHAR:
	SCALE (0, UCHAR_MAX);
      case GST_ISP_SHORT:
	SCALE (SHRT_MIN, SHRT_MAX);
      case GST_ISP_USHORT:
	SCALE (0, USHRT_MAX);
      case GST_ISP_INT:
	SCALE (INT_MIN, INT_MAX);
      case GST_ISP_UINT:
	SCALE (0, UINT_MAX);
      default:
	break;
    }
}

GLdouble *
gst_opengl_oop_to_dbl_array (GLdouble *dest, OOP sourceOOP, int n)
{
  enum gst_indexed_kind kind;
  void *base;
  int i, size;

  size = vm_proxy->basicSize (sourceOOP);
  if (size < n)
    return NULL;

  kind = vm_proxy->OOPIndexedKind (sourceOOP);
  base = vm_proxy->OOPIndexedBase (sourceOOP);
  switch (kind)
    {

#define LOOP(type)						\
  {								\
    type *p = base;						\
    for (i = 0; i < n; i++)					\
      dest[i] = p[i];						\
  }								\
  break;

      case GST_ISP_SCHAR:
	LOOP (signed char);
      case GST_ISP_UCHAR:
	LOOP (unsigned char);
      case GST_ISP_SHORT:
	LOOP (short);
      case GST_ISP_USHORT:
	LOOP (unsigned short);
      case GST_ISP_INT:
	LOOP (int);
      case GST_ISP_UINT:
	LOOP (unsigned int);
      case GST_ISP_FLOAT:
	LOOP (float);
      case GST_ISP_DOUBLE:
	return base;

      case GST_ISP_POINTER:
	{
	  OOP *p = base;
	  for (i = 0; i < n; i++)
	    dest[i] = vm_proxy->OOPToFloat (p[i]);
	  break;
	}

      default:
	return NULL;
    }

  return dest;
}

GLfloat *
gst_opengl_oop_to_array_2 (GLfloat *dest, OOP sourceOOP, int min, int max)
{
  enum gst_indexed_kind kind;
  void *base;
  int i, n;

  n = vm_proxy->basicSize (sourceOOP);
  if (n < min)
    return NULL;
  if (n > max)
    n = max;

  kind = vm_proxy->OOPIndexedKind (sourceOOP);
  base = vm_proxy->OOPIndexedBase (sourceOOP);
  switch (kind)
    {

#define LOOP(type)						\
  {								\
    type *p = base;						\
    for (i = 0; i < n; i++)					\
      dest[i] = p[i];						\
  }								\
  break;

      case GST_ISP_SCHAR:
	LOOP (signed char);
      case GST_ISP_UCHAR:
	LOOP (unsigned char);
      case GST_ISP_SHORT:
	LOOP (short);
      case GST_ISP_USHORT:
	LOOP (unsigned short);
      case GST_ISP_INT:
	LOOP (int);
      case GST_ISP_UINT:
	LOOP (unsigned int);
      case GST_ISP_FLOAT:
	if (n == max)
	  return base;
	LOOP (float);
      case GST_ISP_DOUBLE:
	LOOP (double);

      case GST_ISP_POINTER:
	{
	  OOP *p = base;
	  for (i = 0; i < n; i++)
	    dest[i] = vm_proxy->OOPToFloat (p[i]);
	  break;
	}

      default:
	return NULL;
    }

  return dest;
}

GLfloat *
gst_opengl_oop_to_array (GLfloat *dest, OOP sourceOOP, int n)
{
  return gst_opengl_oop_to_array_2 (dest, sourceOOP, n, n);
}

GLint *
gst_opengl_oop_to_int_array (GLint *dest, OOP sourceOOP, int n)
{
  enum gst_indexed_kind kind;
  void *base;
  int i, size;

  size = vm_proxy->basicSize (sourceOOP);
  if (size < n)
    return NULL;

  kind = vm_proxy->OOPIndexedKind (sourceOOP);
  base = vm_proxy->OOPIndexedBase (sourceOOP);
  switch (kind)
    {

#define LOOP(type)						\
  {								\
    type *p = base;						\
    for (i = 0; i < n; i++)					\
      dest[i] = p[i];						\
  }								\
  break;

      case GST_ISP_SCHAR:
	LOOP (signed char);
      case GST_ISP_UCHAR:
	LOOP (unsigned char);
      case GST_ISP_SHORT:
	LOOP (short);
      case GST_ISP_USHORT:
	LOOP (unsigned short);
      case GST_ISP_INT:
      case GST_ISP_UINT:
	return base;
      case GST_ISP_FLOAT:
	LOOP (float);
      case GST_ISP_DOUBLE:
	LOOP (double);

      case GST_ISP_POINTER:
	{
	  OOP *p = base;
	  for (i = 0; i < n; i++)
	    dest[i] = vm_proxy->OOPToFloat (p[i]);
	  break;
	}

      default:
	return NULL;
    }

  return dest;
}



void
gst_initModule(VMProxy *proxy)
{
  vm_proxy = proxy;

  gst_initModule_gl ();
  gst_initModule_glu ();
}

