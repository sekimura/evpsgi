#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.52)
m4_include([version.m4])
AC_INIT([evpsgi], [1.0.0], [sekimura@gmail.com])
AC_CONFIG_SRCDIR([evpsgi.c])
AM_INIT_AUTOMAKE(AC_PACKAGE_NAME, AC_PACKAGE_VERSION)
AC_CONFIG_HEADER([config.h])

# Checks for programs.
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_INSTALL

# Detect target build environment
# Checks for libraries.

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([netdb.h stdlib.h sys/time.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_CONST
AC_TYPE_SIZE_T

# Checks for library functions.
AC_CHECK_FUNCS([strchr strcspn])


trylibeventdir=""
AC_ARG_WITH(libevent2,
       [  --with-libevent2=PATH     Specify path to libevent2 installation ],
       [
                if test "x$withval" != "xno" ; then
                        trylibeventdir=$withval
                fi
       ]
)

dnl ------------------------------------------------------
dnl libevent detection.  swiped from Tor.  modified a bit.

LIBEVENT_URL=http://www.monkey.org/~provos/libevent/

AC_CACHE_CHECK([for libevent version2 directory], ac_cv_libevent_dir, [
  saved_LIBS="$LIBS"
  saved_LDFLAGS="$LDFLAGS"
  saved_CFLAGS="$CFLAGS"
  le_found=no
  for ledir in $trylibeventdir "" $prefix /usr/local ; do
    LDFLAGS="$saved_LDFLAGS"
    LIBS="$saved_LIBS -levent"

    # Skip the directory if it isn't there.
    if test ! -z "$ledir" -a ! -d "$ledir" ; then
       continue;
    fi
    if test ! -z "$ledir" ; then
      if test -d "$ledir/lib" ; then
        LDFLAGS="-L$ledir/lib $LDFLAGS"
      else
        LDFLAGS="-L$ledir $LDFLAGS"
      fi
      if test -d "$ledir/include" ; then
        CFLAGS="-I$ledir/include $CFLAGS"
      else
        CFLAGS="-I$ledir $CFLAGS"
      fi
    fi
    # Can I compile and link it?
    AC_TRY_LINK([#include <sys/time.h>
#include <sys/types.h>
#include <event2/event.h>], [ event_init(); ],
       [ libevent_linked=yes ], [ libevent_linked=no ])
    if test $libevent_linked = yes; then
       if test ! -z "$ledir" ; then
         ac_cv_libevent_dir=$ledir
       else
         ac_cv_libevent_dir="(system)"
       fi
       le_found=yes
       break
    fi
  done
  LIBS="$saved_LIBS"
  LDFLAGS="$saved_LDFLAGS"
  CFLAGS="$saved_CFLAGS"
  if test $le_found = no ; then
    AC_MSG_ERROR([libevent version2 is required.  You can get it from $LIBEVENT_URL

      If it's already installed, specify its path using --with-libevent2=/dir/
])
  fi
])
LIBS="$LIBS -levent"
if test $ac_cv_libevent_dir != "(system)"; then
  if test -d "$ac_cv_libevent_dir/lib" ; then
    LDFLAGS="-L$ac_cv_libevent_dir/lib $LDFLAGS"
    le_libdir="$ac_cv_libevent_dir/lib"
  else
    LDFLAGS="-L$ac_cv_libevent_dir $LDFLAGS"
    le_libdir="$ac_cv_libevent_dir"
  fi
  if test -d "$ac_cv_libevent_dir/include" ; then
    CFLAGS="-I$ac_cv_libevent_dir/include $CFLAGS"
  else
    CFLAGS="-I$ac_cv_libevent_dir $CFLAGS"
  fi
fi

dnl ------------------------------------------------------
dnl -- perl detection to embed
tryperlpath=`which perl`
AC_ARG_WITH(perl,
       [  --with-perl=PATH     Specify path to perl installation ],
       [
                if test "x$withval" != "x" ; then
                        tryperlpath=$withval
                fi
       ]
)

perl_LIBS=`$tryperlpath ./embed_util.pl --libs`
perl_LDFLAGS=`$tryperlpath ./embed_util.pl --ldflags`
LIBS="$LIBS $perl_LIBS"
LDFLAGS="$LDFLAGS $perl_LDFLAGS"
CFLAGS="$CFLAGS `$tryperlpath -MExtUtils::Embed -e ccopts`"

dnl -- hmm it depends on MacPorts actually. I'll find out a better way later
LDFLAGS=`echo $LDFLAGS | sed -e 's/-arch ppc//'`
CFLAGS=`echo $CFLAGS | sed -e 's/-arch ppc//'`

dnl ----------------------------------------------------------------------------

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
