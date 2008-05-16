/* 
 this file is distributed under the same terms as GNU Smalltalk
*/

#include "config.h"
#include "gstpub.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include GL_GLUT_H


#define nil  vm_proxy->nilOOP

static VMProxy *vm_proxy = NULL ;

void
gst_initModule(proxy)
         VMProxy *proxy ;
{
  vm_proxy = proxy;
}

