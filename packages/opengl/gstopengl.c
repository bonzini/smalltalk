/* 
 this file is distributed under the same terms as GNU Smalltalk
*/
#include "gstopengl.h"

VMProxy *vm_proxy = NULL ;

void
gst_initModule(VMProxy *proxy)
{
  vm_proxy = proxy;

  gst_initModule_gl ();
  gst_initModule_glu ();
}

