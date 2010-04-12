/***********************************************************************
 *
 *	Regular expression interface definitions for GNU Smalltalk 
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002, 2006, 2008 Free Software Foundation, Inc.
 * Written by Paolo Bonzini and Dragomir Milevojevic.
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

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "gstpriv.h"
#include "re.h"

#if STDC_HEADERS
#include <stdlib.h>
#include <string.h>
#endif

/* Regex caching facility */

#define REGEX_CACHE_SIZE 10

typedef struct RegexCacheEntry
{
  OOP patternOOP;
  GRegex *regex;
}
RegexCacheEntry;

static GRegex *compileRegex (OOP patternOOP, int flags);
static GRegex *lookupRegex (OOP patternOOP);
static void markRegexAsMRU (int i);
static void init_re (void);

static RegexCacheEntry cache[REGEX_CACHE_SIZE];

/* Smalltalk globals */
static OOP regexClassOOP, resultsClassOOP;

gchar *
g_regex_escape_nul (const gchar *string, gint length)
{
  GString *escaped;
  const char *p, *piece_start, *end;
  gint backslashes;

  g_return_val_if_fail (string != NULL, NULL);

  if (length < 0)
    return g_strdup (string);

  end = string + length;
  p = piece_start = string;
  escaped = g_string_sized_new (length + 1);

  backslashes = 0;
  while (p < end)
    {
      switch (*p)
	{
        case '\0':
	  if (p != piece_start)
            {
              /* copy the previous piece, and maybe add a backslash. */
              g_string_append_len (escaped, piece_start, p - piece_start);
            }
	  if ((backslashes & 1) == 0)
            g_string_append_c (escaped, '\\');
          g_string_append_c (escaped, 'x');
          g_string_append_c (escaped, '0');
          g_string_append_c (escaped, '0');
	  piece_start = ++p;
          backslashes = 0;
          break;
	case '\\':
          backslashes++;
	  ++p;
	  break;
	default:
          backslashes = 0;
	  p = g_utf8_next_char (p);
          break;
        }
  }

  if (piece_start < end)
    g_string_append_len (escaped, piece_start, end - piece_start);

  return g_string_free (escaped, FALSE);
}

/* Compile a pattern that's stored into an OOP.  Answer an error, or NULL. */
GRegex *
compileRegex (OOP patternOOP, int flags)
{
  int patternLength;
  char *pattern;
  GRegex *regex;

  pattern = &STRING_OOP_AT (OOP_TO_OBJ (patternOOP), 1);
  patternLength = _gst_basic_size (patternOOP);

  /* Compile pattern.  Regex objects are escaped ahead of time.  */
  if (OOP_CLASS (patternOOP) == regexClassOOP)
    pattern = g_strndup (pattern, patternLength);
  else
    pattern = g_regex_escape_nul (pattern, patternLength);

  regex = g_regex_new (pattern,
		       flags | G_REGEX_RAW | G_REGEX_NEWLINE_LF,
		       0, NULL);

  g_free (pattern);
  return regex;
}

/* Move the i-th entry of the cache to the first position */
void
markRegexAsMRU (int i)
{
  RegexCacheEntry saved;
  int j;

  saved = cache[i];
  for (j = i; j > 0; j--)
    cache[j] = cache[j - 1];

  cache[0] = saved;
}

/* If patternOOP is not a Regex, answer a newly compiled regex.  Else look
   it up in the cache and move it to its top (so that it is marked as
   most recently used).  The returned regex reference count is in either
   case correct so the coller can just unref it.  */
GRegex *
lookupRegex (OOP patternOOP)
{
  int i;
  if (!IS_OOP_READONLY (patternOOP))
    return compileRegex (patternOOP, 0);

  /* Search for the Regex object in the cache */
  for (i = 0; i < REGEX_CACHE_SIZE; i++)
    if (cache[i].patternOOP == patternOOP)
      break;

  if (i == REGEX_CACHE_SIZE)
    {
      GRegex *compiled = compileRegex (patternOOP, G_REGEX_OPTIMIZE);
      if (!compiled)
        return NULL;

      /* Kick out the least recently used regexp */
      if (cache[--i].patternOOP)
        {
          _gst_unregister_oop (cache[i].patternOOP);
          g_regex_unref (cache[i].regex);
        }

      /* Register the objects we're caching with the virtual machine */
      _gst_register_oop (patternOOP);
      cache[i].patternOOP = patternOOP;
      cache[i].regex = compiled;
    }

  /* Mark the object as most recently used */
  markRegexAsMRU (i);
  return g_regex_ref (cache[0].regex);
}

/* Create a Regex object.  We look for one that points to the same string
   in the cache (so that we can optimize a loop that repeatedly calls
   asRegex; if none is found, we create one ex-novo.
   Note that Regex and String objects have the same layout; only, Regexes
   are read-only so that we can support this kind of "interning" them.  */
OOP
_gst_re_make_cacheable (OOP patternOOP)
{
  OOP regexOOP;
  const char *pattern;
  char *regex;
  GRegex *compiled;
  int patternLength;
  int i;

  if (!regexClassOOP)
    init_re ();

  /* Search in the cache */
  patternLength = _gst_basic_size (patternOOP);
  pattern = &STRING_OOP_AT (OOP_TO_OBJ (patternOOP), 1);

  if (OOP_CLASS (patternOOP) == regexClassOOP)
    return patternOOP;

  for (i = 0; i < REGEX_CACHE_SIZE; i++)
    {
      if (!cache[i].regex)
	break;

      regexOOP = cache[i].patternOOP;
      regex = &STRING_OOP_AT (OOP_TO_OBJ (regexOOP), 1);
      if (_gst_basic_size (regexOOP) == patternLength &&
	  memcmp (regex, pattern, patternLength) == 0)
	{
	  markRegexAsMRU (i);
	  return regexOOP;
	}
    }
 
  /* No way, must allocate a new Regex object */
  if (memchr (pattern, 0, patternLength))
    {
      gchar *string = g_regex_escape_nul (pattern, patternLength);
      patternLength = strlen (string);
      regexOOP = _gst_object_alloc (regexClassOOP, patternLength);
      regex = &STRING_OOP_AT (OOP_TO_OBJ (regexOOP), 1);
      memcpy (regex, string, patternLength);
      g_free (string);
    }
  else
    {
      regexOOP = _gst_object_alloc (regexClassOOP, patternLength);
      regex = &STRING_OOP_AT (OOP_TO_OBJ (regexOOP), 1);
      memcpy (regex, pattern, patternLength);
    }

  /* Put it in the cache (we must compile it to check that it
   * is well-formed).
   */
  compiled = lookupRegex (regexOOP);
  if (compiled)
    {
      g_regex_unref (compiled);
      return regexOOP;
    }
  else
    return _gst_nil_oop;
}


typedef struct _gst_interval
{
  OBJ_HEADER;
  OOP fromOOP;
  OOP toOOP;
  OOP stepOOP;
} *gst_interval;

typedef struct _gst_registers
{
  OBJ_HEADER;
  OOP subjectOOP;
  OOP fromOOP;
  OOP toOOP;
  OOP registersOOP;
  OOP matchOOP;
  OOP cacheOOP;
} *gst_registers;

static OOP
make_re_results (OOP srcOOP, GMatchInfo *info)
{
  OOP resultsOOP;
  gst_registers results;
  int start, end;
  int i, count, num_captures;

  resultsOOP = _gst_object_alloc (resultsClassOOP, 0);
  results = (gst_registers) OOP_TO_OBJ (resultsOOP);
  results->subjectOOP = srcOOP;

  g_match_info_fetch_pos (info, 0, &start, &end);
  results->fromOOP = FROM_INT (start + 1);
  results->toOOP = FROM_INT (end);

  num_captures = g_regex_get_capture_count (g_match_info_get_regex (info));
  if (num_captures > 0)
    {
      OOP registersOOP = _gst_object_alloc (_gst_array_class, num_captures);
      results = (gst_registers) OOP_TO_OBJ (resultsOOP);
      results->registersOOP = registersOOP;
    }

  count = g_match_info_get_match_count (info);
  for (i = 1; i < count; i++)
    {
      OOP intervalOOP;
      g_match_info_fetch_pos (info, i, &start, &end);
      if (start == -1)
	intervalOOP = _gst_nil_oop;
      else
	{
          gst_interval interval;
	  intervalOOP = _gst_object_alloc (_gst_interval_class, 0);
          interval = (gst_interval) OOP_TO_OBJ (intervalOOP);
          interval->fromOOP = FROM_INT (start + 1);
          interval->toOOP = FROM_INT (end);
          interval->stepOOP = FROM_INT (1);
	}

      /* We need to reload results as it may be invalidated by GC.  */
      results = (gst_registers) OOP_TO_OBJ (resultsOOP);
      _gst_oop_at_put (results->registersOOP, i - 1, intervalOOP);
    }

  return resultsOOP;
}

/* Search helper function */

OOP
_gst_re_search (OOP srcOOP, OOP patternOOP, int from, int to)
{
  size_t size;
  int res;
  const char *src;
  GRegex *regex;
  GMatchInfo *info;
  OOP resultOOP;

  if (!regexClassOOP)
    init_re ();

  regex = lookupRegex (patternOOP);
  if (!regex)
    return NULL;

  /* now search */
  src = &STRING_OOP_AT (OOP_TO_OBJ (srcOOP), 1);
  size = _gst_basic_size (srcOOP);
  res = g_regex_match_full (regex, src, to, from - 1, 0,
                            &info, NULL);

  g_regex_unref (regex);
  resultOOP = res ? make_re_results (srcOOP, info) : _gst_nil_oop;
  g_match_info_free(info);
  return resultOOP;
}


/* Match helper function */

int
_gst_re_match (OOP srcOOP, OOP patternOOP, int from, int to)
{
  int res = 0;
  const char *src;
  GRegex *regex;
  GMatchInfo *info;
  size_t size;
  int start, end;

  if (!regexClassOOP)
    init_re ();

  regex = lookupRegex (patternOOP);
  if (!regex)
    return -100;

  /* now search */
  src = &STRING_OOP_AT (OOP_TO_OBJ (srcOOP), 1);
  size = _gst_basic_size (srcOOP);
  res = g_regex_match_full (regex, src, to, from - 1, 
                            G_REGEX_MATCH_ANCHORED,
                            &info, NULL);
  if (res)
    g_match_info_fetch_pos (info, 0, &start, &end);
  else
    end = -1;

  g_match_info_free (info);
  g_regex_unref (regex);
  return end;
}


/* Initialize regex.c */
static void
init_re (void)
{
  regexClassOOP = _gst_class_name_to_oop ("Regex");
  resultsClassOOP = _gst_class_name_to_oop ("Kernel.MatchingRegexResults");
}
