/******************************** -*- C -*- ****************************
 *
 * Asynchronous events handling.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001,2002,2003,2005,2006,2008,2009 Free Software Foundation, Inc.
 * Free Software Foundation, Inc.
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
 * GNU Smalltalk; see the file COPYING.	 If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/


#include "gstpriv.h"


/* Holds the semaphores to be signaled when the operating system sends
   us a C-style signal.  */
volatile OOP _gst_sem_int_vec[NSIG];

/* Signals _gst_sem_int_vec[SIG] and removes the semaphore from the vector
   (because C-style signal handlers are one-shot).  */
static RETSIGTYPE signal_handler (int sig);


RETSIGTYPE
signal_handler (int sig)
{
  _gst_disable_interrupts (true);
  if (_gst_sem_int_vec[sig])
    {
      if (IS_CLASS (_gst_sem_int_vec[sig], _gst_semaphore_class))
	{
	  _gst_async_signal_and_unregister (_gst_sem_int_vec[sig]);
	  _gst_sem_int_vec[sig] = NULL;
	}
      else
	{
	  _gst_errorf
	    ("C signal trapped, but no semaphore was waiting");
	  raise (sig);
	}
    }

  _gst_enable_interrupts (true);
  _gst_set_signal_handler (sig, SIG_DFL);
  _gst_wakeup ();
}

void
_gst_async_interrupt_wait (OOP semaphoreOOP,
			   int sig)
{
  if (sig < 0 || sig >= NSIG)
    return;

  _gst_sem_int_vec[sig] = semaphoreOOP;
  _gst_register_oop (semaphoreOOP);
  _gst_set_signal_handler (sig, signal_handler);

  /* should probably package up the old interrupt state here for return
     so that it can be undone */
}


/* Glib event loop.  The event loop in GNU Smalltalk is split between two
   operating system threads using the low-level g_main_context functions
   (http://library.gnome.org/devel/glib/unstable/glib-The-Main-Event-Loop.html).

   Prepare/query/poll occur in a separate thread than the one
   executing Smalltalk code.  Before check, however, the thread releases
   the context and waits on a condition variable for the Smalltalk code to
   finish the check and dispatch phases.

   This ensures that all GTK+ code executes in a single OS thread (avoiding
   complicated usage of gdk_threads_{enter,leave}) and at the same time
   allows Smalltalk processes to run in the background while GTK+ events
   are polled.  */

static GMainLoop *loop;
static GThread *thread; 
static GMutex *mutex;
static GCond *cond;
static GCond *cond_dispatch;
static volatile gboolean queued, idle;

static GIOChannel **channel_map;

#ifdef G_WIN32_MSG_HANDLE
static HANDLE hWakeUpEvent;

static gint
gst_gtk_poll (GPollFD *fds,
	      guint    nfds,
	      gint     timeout)
{
  HANDLE handles[MAXIMUM_WAIT_OBJECTS];
  gint win32_timeout;
  gint poll_msgs = -1;
  GPollFD *f;
  DWORD ready;
  gint nhandles = 0;

  for (f = fds; f < &fds[nfds]; ++f)
      {
        HANDLE h;
        assert (f->fd >= 0);
        if (f->fd == G_WIN32_MSG_HANDLE)
          {
            assert (poll_msgs == -1 && nhandles == f - fds);
            poll_msgs = nhandles;
            continue;
          }
        else
          h = (HANDLE) f->fd;
        if (nhandles == MAXIMUM_WAIT_OBJECTS)
          {
            g_warning (G_STRLOC ": Too many handles to wait for!\n");
            break;
          }
        handles[nhandles++] = (HANDLE) f->fd;
      }

  if (nhandles == 0)
    {
      /* Wait for nothing (huh?) */
      return 0;
    }

  /* If the VM were idling, it tells us when it gets a message on its queue,
     so that we can avoid polling.  */
  if (poll_msgs != -1 && !idle)
    win32_timeout = (timeout == -1 || timeout > 20) ? 20 : timeout;
  else
    win32_timeout = (timeout == -1) ? INFINITE : timeout;

  ready = WaitForMultipleObjects (nhandles, handles, FALSE, win32_timeout);
  if (ready == WAIT_FAILED)
    {
      gchar *emsg = g_win32_error_message (GetLastError ());
      g_warning (G_STRLOC ": WaitForMultipleObjects() failed: %s", emsg);
      g_free (emsg);
    }

  for (f = fds; f < &fds[nfds]; ++f)
    f->revents = 0;

  if (poll_msgs != -1)
    {
      if (ready >= WAIT_OBJECT_0 + poll_msgs
	  && ready <= WAIT_OBJECT_0 + nhandles)
        ready++;

      else if (ready == WAIT_TIMEOUT
	       && win32_timeout != INFINITE)
        ready = WAIT_OBJECT_0 + poll_msgs;
    }

  if (ready == WAIT_FAILED)
    return -1;
  if (ready == WAIT_TIMEOUT)
    return 0;

  f = &fds[ready - WAIT_OBJECT_0];
  if (f->events & (G_IO_IN | G_IO_OUT))
    {
      if (f->events & G_IO_IN)
        f->revents |= G_IO_IN;
      else
        f->revents |= G_IO_OUT;
    }

  return 1;
}
#else
#define gst_gtk_poll g_poll
#endif


static void
main_context_acquire_wait (GMainContext *context)
{
  while (!g_main_context_wait (context, cond, mutex));
}

static void
main_context_signal (GMainContext *context)
{
  /* Restart the polling thread.  Note that #iterate is asynchronous, so
     this might execute before the Smalltalk code finishes running!  This
     allows debugging GTK+ signal handlers.  */
  g_mutex_lock (mutex);
  queued = false;
  g_cond_broadcast (cond_dispatch);
  g_mutex_unlock (mutex);
}

static GPollFD *fds;
static int allocated_nfds, nfds;
static int maxprio;

void
_gst_main_context_iterate (void)
{
  GMainContext *context = g_main_loop_get_context (loop);

  g_mutex_lock (mutex);
  if (!fds || !queued)
    {
      g_mutex_unlock (mutex);
      return;
    }

  /* No need to keep the mutex except during g_main_context_acquire_wait
     and g_main_context_release_signal, i.e. except while we operate on
     cond.  */
  main_context_acquire_wait (context);
  g_mutex_unlock (mutex);
  g_main_context_check (context, maxprio, fds, nfds);
  g_main_context_dispatch (context);
  g_main_context_release (context);
  main_context_signal (context);
}

static gpointer
main_loop_thread (gpointer arg)
{
  GMainLoop *ourLoop = arg;
  GMainContext *context = g_main_loop_get_context (ourLoop);

  if (!fds)
    {
      fds = g_new (GPollFD, 20);
      allocated_nfds = 20;
    }

  /* Mostly based on g_main_context_iterate (a static function in gmain.c)
     except that we have to use our own mutex and that g_main_context_dispatch
     is replaced by signaling semaphoreOOP.  */

  g_mutex_lock (mutex);
  while (g_main_loop_is_running (ourLoop))
    {
      int timeout;

      main_context_acquire_wait (context);
      g_main_context_prepare (context, &maxprio);
      while ((nfds = g_main_context_query (context, maxprio,
                                           &timeout, fds, allocated_nfds))
             > allocated_nfds)
        {
          g_free (fds);
          fds = g_new (GPollFD, nfds);
          allocated_nfds = nfds;
        }

      /* Release the context so that the other thread can dispatch while
         this one polls.  g_main_context_release unlocks the mutex for us.  */
      g_mutex_unlock (mutex);
      g_main_context_release (context);

      gst_gtk_poll (fds, nfds, timeout);

      /* Dispatch on the other thread and wait for it to rendez-vous.  */
      g_mutex_lock (mutex);
      
      queued = true;
      _gst_main_loop_dispatch ();

#ifdef G_WIN32_MSG_HANDLE
      SetEvent (hWakeUpEvent);
#else
      g_cond_broadcast (cond_dispatch);
#endif
      do
        g_cond_wait (cond_dispatch, mutex);
      while (queued);
    }

  g_main_loop_unref (ourLoop);
  thread = NULL;
  g_mutex_unlock (mutex);
  return NULL;
}

void
_gst_pause (int usec)
{
  if (!loop)
    return;

  _gst_disable_interrupts (false);

  idle = true;
  {
#ifdef G_WIN32_MSG_HANDLE
    /* This is a bit more complicated for Win32 because we want to avoid
       polling.  So in _gst_pause we look for messages and wake up the
       main loop if we find some.  */ 
    DWORD rc;
    rc = MsgWaitForMultipleObjects (1, &hWakeUpEvent, FALSE,
                                    usec == -1 ? INFINITE : usec / 1000,
                                    QS_ALLEVENTS);

    ResetEvent (hWakeUpEvent);
    if (rc != WAIT_TIMEOUT)
      g_main_context_wakeup (g_main_loop_get_context (loop));
#else
    GTimeVal tv, *ptv;
    if (usec == -1)
      ptv = NULL;
    else
      {
        g_get_current_time (&tv);
        g_time_val_add (&tv, usec);
        ptv = &tv;
      }
    g_mutex_lock (mutex);
    while (!queued)
      g_cond_timed_wait (cond_dispatch, mutex, ptv);
    g_mutex_unlock (mutex);
#endif
  }
}

void
_gst_wakeup (void)
{
  if (!loop)
    return;

  idle = false;
#ifdef G_WIN32_MSG_HANDLE
  /* Wake up _gst_pause which, in turn, will wake up the main loop.  */
  SetEvent (hWakeUpEvent);
#else
  g_main_context_wakeup (g_main_loop_get_context (loop));
#endif
}


void
_gst_init_async_events ()
{
  int maxfd;

  /* One-time initialization.  */
  mutex = g_mutex_new ();
  cond = g_cond_new ();
  cond_dispatch = g_cond_new ();

  loop = g_main_loop_new (NULL, TRUE);

  /* Add a second reference to be released when the thread exits.  The first
     one is kept by the global variable.  */
  g_main_loop_ref (loop);
  thread = g_thread_create (main_loop_thread, loop, TRUE, NULL);

#if G_WIN32_MSG_HANDLE
  hWakeUpEvent = CreateEvent (NULL, FALSE, FALSE, NULL);
#endif

#if defined _SC_OPEN_MAX
  maxfd = sysconf (_SC_OPEN_MAX);
#elif defined OPEN_MAX
  maxfd = OPEN_MAX;
#else
  maxfd = 4096;
#endif

  channel_map = g_new (GIOChannel *, maxfd);
}


static GSource *timeout_source;

static void
g_destroy_notify_unregister (gpointer data)
{
  OOP semaphoreOOP = (OOP) data;
  _gst_unregister_oop (semaphoreOOP);
}

static gboolean
g_timeout_func_signal (gpointer data)
{
  OOP semaphoreOOP = (OOP) data;
  _gst_sync_signal (semaphoreOOP, true);
  g_source_unref (timeout_source);
  timeout_source = NULL;
  return FALSE;
}

void
_gst_async_timed_wait (OOP semaphoreOOP,
		       int interval)
{
  GMainContext *context = g_main_loop_get_context (loop);
  GSource *source;

  if (timeout_source)
    {
      g_source_destroy (timeout_source);
      g_source_unref (timeout_source);
      timeout_source = NULL;
    }

  _gst_register_oop (semaphoreOOP);
  source = g_timeout_source_new (interval);
  g_source_set_callback (source, g_timeout_func_signal, semaphoreOOP,
                         g_destroy_notify_unregister);
  g_source_attach (source, context);
  timeout_source = source;
}

mst_Boolean
_gst_is_timeout_programmed (void)
{
  return !!timeout_source;
}


static GIOChannel *
map_io_channel (int fd,
                GIOChannel *channel)
{
  if (!channel_map[fd])
    return channel_map[fd] = channel;
  else
    return channel_map[fd];
}

static void
unmap_io_channel (int fd)
{
  GIOChannel *io_channel;
  io_channel = channel_map[fd];
  channel_map[fd] = NULL;
  g_io_channel_unref (io_channel);
}

GIOChannel *
get_io_channel (int fd)
{
  GIOChannel *io_channel = map_io_channel (fd, NULL);
  if (!io_channel)
    {
#ifdef G_WIN32_MSG_HANDLE
      io_channel = g_io_channel_win32_new_fd (fd);
#else
      io_channel = g_io_channel_unix_new (fd);
#endif
      map_io_channel (fd, io_channel);

      /* Pass through.  */
      g_io_channel_set_encoding (io_channel, NULL, NULL);
      g_io_channel_set_buffered (io_channel, false);
    }

  return io_channel;
}

void
_gst_register_socket (int fd)
{
  GIOChannel *io_channel = map_io_channel (fd, NULL);
  if (!io_channel)
    {
#ifdef G_WIN32_MSG_HANDLE
      io_channel = g_io_channel_win32_new_socket (_get_osfhandle (fd));
#else
      io_channel = g_io_channel_unix_new (fd);
#endif
      map_io_channel (fd, io_channel);

      /* Pass through.  */
      g_io_channel_set_encoding (io_channel, NULL, NULL);
      g_io_channel_set_buffered (io_channel, false);
    }
}

static gboolean
g_io_func_dummy (GIOChannel *source,
                  GIOCondition condition,
                  gpointer data)
{
  return FALSE;
}

static gboolean
g_io_func_signal (GIOChannel *source,
                  GIOCondition condition,
                  gpointer data)
{
  OOP semaphoreOOP = (OOP) data;
  _gst_sync_signal (semaphoreOOP, true);
  return FALSE;
}

gint
_gst_sync_file_polling (int fd,
                        int io_cond)
{
#ifdef G_WIN32_MSG_HANDLE
  GIOChannel *channel = get_io_channel (fd);
#endif
  GPollFD pfd;
  GIOCondition condition;
  int result;
  switch (io_cond)
    {
    case 0:
      condition = G_IO_IN;
      break;
    case 1:
      condition = G_IO_OUT;
      break;
    case 2:
      condition = G_IO_PRI;
      break;
    default:
      return -1;
    }
#ifdef G_WIN32_MSG_HANDLE
  g_io_channel_win32_make_pollfd (channel, condition, &pfd);
  result = g_io_channel_win32_poll (&pfd, 1, 0);
#else
  pfd.fd = fd;
  pfd.events = condition;
  pfd.revents = 0;
  do
    {
      errno = 0;
      pfd.revents = 0;
      result = g_poll (&pfd, 1, 0);
    }
  while ((result == -1) && (errno == EINTR));
#endif
  if (result == -1)
    return -1;
  if (pfd.revents & pfd.events)
    return 1;
  if (pfd.revents & (G_IO_ERR | G_IO_HUP | G_IO_NVAL))
    {
      errno = 0;
      return -1;
    }

  return 0;
}

void
_gst_async_file_polling (int fd,
                         int io_cond,
                         OOP semaphoreOOP)
{
  GIOChannel *channel = get_io_channel (fd);
  GMainContext *context = g_main_loop_get_context (loop);
  GIOCondition condition;
  GSource *source;

  switch (io_cond)
    {
    case 0:
      condition = G_IO_IN;
      break;
    case 1:
      condition = G_IO_OUT;
      break;
    case 2:
      condition = G_IO_PRI;
      break;
    default:
      return;
    }

  source = g_io_create_watch (channel, condition);
  if (semaphoreOOP)
    {
      _gst_register_oop (semaphoreOOP);
      g_source_set_callback (source, (GSourceFunc) g_io_func_signal,
                             semaphoreOOP, g_destroy_notify_unregister);
      _gst_sync_wait (semaphoreOOP);
    }
  else
    g_source_set_callback (source, (GSourceFunc) g_io_func_dummy, NULL, NULL);
  g_source_attach (source, context);
  g_source_unref (source);
}

ssize_t
_gst_read (int fd,
           gchar *buf,
           gsize count)
{
  GIOChannel *channel = get_io_channel (fd);
  GIOStatus status;
  gsize bytes_read;
  GError *error = NULL;
  
  status = g_io_channel_read_chars (channel, buf, count, &bytes_read, &error);
  switch (status)
    {
    case G_IO_STATUS_AGAIN:
      errno = EAGAIN;
      return -1;
      break;
    case G_IO_STATUS_ERROR:
      return -1;
    default:
      return bytes_read;
    }
}

gint
_gst_close (int fd)
{
  GIOChannel *channel = get_io_channel (fd);
  g_io_channel_close (channel);
  unmap_io_channel (fd);
  return 0;
}

ssize_t
_gst_pwrite (int fd,
            gchar *buf,
            gsize count,
            off_t offset)
{
  GIOChannel *channel = get_io_channel (fd);
  ssize_t result;
  
  if (!channel->is_seekable)
    {
      errno = ESPIPE;
      return -1;
    }
#if HAVE_PREAD
  result = pwrite (fd, buf, count, offset);
#else
    {
      off_t save = lseek (fd, offset, SEEK_SET);
      int save_errno;
      if (save != -1)
        {
          result = _gst_write (fd, buf, count);
          save_errno = errno;
          lseek (fd, save, SEEK_SET);
          errno = save_errno;
        }
      else
        result = -1;
    }
#endif

  return result;
}

ssize_t
_gst_pread (int fd,
            gchar *buf,
            gsize count,
            off_t offset)
{
  GIOChannel *channel = get_io_channel (fd);
  ssize_t result;
  
  if (!channel->is_seekable)
    {
      errno = ESPIPE;
      return -1;
    }
#if HAVE_PREAD
  result = pread (fd, buf, count, offset);
#else
    {
      off_t save = lseek (fd, offset, SEEK_SET);
      int save_errno;
      if (save != -1)
        {
          result = _gst_read (fd, buf, count);
          save_errno = errno;
          lseek (fd, save, SEEK_SET);
          errno = save_errno;
        }
      else
        result = -1;
    }
#endif

  return result;
}

mst_Boolean
_gst_is_pipe (int fd)
{
  GIOChannel *channel = get_io_channel (fd);
  return !channel->is_seekable;
}

off_t
_gst_lseek (int fd,
            off_t offset,
            GSeekType type)
{
  GIOChannel *channel = get_io_channel (fd);
  if (!channel->is_seekable)
    {
      errno = ESPIPE;
      return -1;
    }

  return lseek (fd, offset, type);
}

ssize_t
_gst_write (int fd,
            gchar *buf,
            gsize count)
{
  GIOChannel *channel = get_io_channel (fd);
  GIOStatus status;
  gsize bytes_write;
  GError *error = NULL;
  
  status = g_io_channel_write_chars (channel, buf, count, &bytes_write, &error);
  switch (status)
    {
    case G_IO_STATUS_AGAIN:
      errno = EAGAIN;
      return -1;
      break;
    case G_IO_STATUS_ERROR:
      return -1;
    default:
      return bytes_write;
    }
}
