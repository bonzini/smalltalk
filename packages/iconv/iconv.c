/***********************************************************************
 *
 *      C interface to i18n functions
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002, 2004, 2005, 2006, 2013 Free Software Foundation, Inc.
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
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#include "config.h"
#include "gstpub.h"
#include <stdio.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <iconv.h>
#include <errno.h>

static VMProxy *vmProxy; 

mst_Boolean
iconvWrapper (iconv_t handle, OOP readBufferOOP, int readPos,
	      int readCount, OOP writeBufferOOP, int writeCount,
	      OOP bytesLeftOOP)
{
  const char *inbuf;
  size_t inbytesleft;
  char *outbuf;
  size_t outbytesleft;
  int save_errno;

  gst_object bytesLeft, readBuffer, writeBuffer;

  readBuffer = OOP_TO_OBJ (readBufferOOP);
  inbuf = &STRING_OOP_AT (readBuffer, readPos);
  inbytesleft = readCount;

  writeBuffer = OOP_TO_OBJ (writeBufferOOP);
  outbuf = &STRING_OOP_AT (writeBuffer, 1);
  outbytesleft = writeCount;

  iconv (handle, &inbuf, &inbytesleft, &outbuf, &outbytesleft);
  save_errno = errno;
  errno = 0;

  bytesLeft = OOP_TO_OBJ (bytesLeftOOP);
  ARRAY_OOP_AT (bytesLeft, 1) = vmProxy->intToOOP (inbytesleft);
  ARRAY_OOP_AT (bytesLeft, 2) = vmProxy->intToOOP (outbytesleft);
  return (save_errno != EILSEQ);
}

iconv_t iconvInvalid(void)
{
  return (iconv_t) -1;
}

void
gst_initModule (VMProxy * proxy)
{
  vmProxy = proxy;
  vmProxy->defineCFunc ("iconv_invalid", iconvInvalid);
  vmProxy->defineCFunc ("iconv_open", iconv_open);
  vmProxy->defineCFunc ("iconv_close", iconv_close);
  vmProxy->defineCFunc ("iconvWrapper", iconvWrapper);
}
