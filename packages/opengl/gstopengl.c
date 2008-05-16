/* 
 this file is distributed under the same terms as GNU Smalltalk
*/
#include "config.h"
#include "gstpub.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include GL_GL_H
#include GL_GLU_H

static VMProxy *vm_proxy = NULL ;

void
gst_initModule(proxy)
	 VMProxy *proxy ;
{
  vm_proxy = proxy;
}

