/* socketx.c - Extend WinSock functions to handle other objects than sockets
   Contributed by Freddie Akeroyd.

   Copyright 2007 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along
   with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  */

#include <socketx.h>

#ifdef __MSVCRT__

/* internal to Microsoft CRTLIB */
typedef struct
{
  long osfhnd;		/* underlying OS file HANDLE */
  char osfile;		/* attributes of file (e.g., open in text mode?) */
  char pipech;		/* one char buffer for handles opened on pipes */
#ifdef _MT
  int lockinitflag;
  CRITICAL_SECTION lock;
#endif				/* _MT */
} ioinfo;

#define IOINFO_L2E          5
#define IOINFO_ARRAY_ELTS   (1 << IOINFO_L2E)
#define _pioinfo(i)	    ( __pioinfo[(i) >> IOINFO_L2E] + \
			     ((i) & (IOINFO_ARRAY_ELTS - 1)) )
#define _osfile(i)	    (_pioinfo(i)->osfile)
#define _osfhnd(i)	    (_pioinfo(i)->osfhnd)

#define FOPEN  		    0x01

#ifdef __declspec
extern __attribute__ ((dllimport)) ioinfo * __pioinfo[];
#else
extern __declspec(dllimport) ioinfo * __pioinfo[];
#endif

static int
my_free_osfhnd (int filehandle)
{
  if ((_osfile (filehandle) & FOPEN) &&
      (_osfhnd (filehandle) != (long) INVALID_HANDLE_VALUE))
    {
      switch (filehandle)
	{
	case 0:
	  SetStdHandle (STD_INPUT_HANDLE, NULL);
	  break;
	case 1:
	  SetStdHandle (STD_OUTPUT_HANDLE, NULL);
	  break;
	case 2:
	  SetStdHandle (STD_ERROR_HANDLE, NULL);
	  break;
	}
      _osfhnd (filehandle) = (long) INVALID_HANDLE_VALUE;
      return (0);
    }
  else
    {
      errno = EBADF;		/* bad handle */
      _doserrno = 0L;		/* not an OS error */
      return -1;
    }
}

int
win_close (int filehandle)
{
  char buf[sizeof (int)];
  int bufsize = sizeof (buf);
  SOCKET sock = _get_osfhandle (fd);

  if (getsockopt (sock, SOL_SOCKET, SO_TYPE, buf, &bufsize) == 0)
    {
      int result = 0;
      if (closesocket (sock) == SOCKET_ERROR)
	result = -1;

      my_free_osfhnd (fd);
      _osfile (fd) = 0;
      return result;
    }
  else
    return _close (fd);
}

#endif

