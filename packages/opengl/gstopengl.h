/* 
 this file is distributed under the same terms as GNU Smalltalk
*/
#ifndef GSTOPENGL_H
#define GSTOPENGL_H 1

#include "config.h"
#include "gstpub.h"

#include GL_GL_H
#include GL_GLU_H

/* Internal convenience typedefs, same as _GLUfuncptr which is
   not provided by Apple's glu.h. */
#ifdef __cplusplus
typedef GLvoid (*GLUfuncptr)();
#else
typedef GLvoid (*GLUfuncptr)(GLvoid);
#endif 

extern VMProxy *vm_proxy;

extern void gst_initModule_glu (void);
extern void gst_initModule_gl (void);

#endif
