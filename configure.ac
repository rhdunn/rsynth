AC_PREREQ(2.59)
AC_INIT([RSynth], [2.1], [msclrhd@gmail.com], [rsynth], [https://github.com/rhdunn/rsynth])
AM_INIT_AUTOMAKE()

AC_CONFIG_SRCDIR([say.c])
AC_CANONICAL_HOST
AC_CONFIG_HEADER(config.h)

PROGS="say"
dnl Set up link to the native play program
hplay=dummy
dbm=none
make_dist=/dev/null
prefix=/usr/local

dnl AC_PREFIX_PROGRAM(gcc)

if test -z "$CC" && test -n "$GCC" ; then
CC=$GCC
fi

dnl Checks for programs.
AC_PROG_CC

if test "$GCC" != yes; then
CFLAGS="-O"
fi

AC_ISC_POSIX
AC_PROG_MAKE_SET
AC_PROG_INSTALL
AC_PROG_RANLIB


dnl Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS(fcntl.h limits.h sys/types.h sys/file.h sys/ioctl.h sys/time.h unistd.h)
if test "$ac_cv_header_stdc" != yes; then
AC_CHECK_FUNCS(strchr memcpy)
AC_CHECK_HEADERS(memory.h malloc.h)
fi
AC_CHECK_FUNCS(ftruncate chsize truncate)

case "$host" in
*-sun-*) hplay=sun; AC_CHECK_HEADERS(sys/ioccom.h sys/audioio.h sun/audioio.h);;
*-sgi-*) hplay=sgi ;;
*-next-*) hplay=NeXT; AC_CHECK_HEADERS(libc.h) ;;
*-*-freebsd*) hplay=linux ;;
*-*-linux*) hplay=linux ;;
*-*-hpux*)  hplay=hpux ;;
*-*-*) echo "Unknown host type $host" ;;
esac

AC_MSG_WARN(prefix is $prefix)

if test "$hplay" = linux; then
 AC_CHECK_HEADERS(alsa/asoundlib.h,hplay=alsa,hplay=oss)
fi

if test "$hplay" = alsa; then

AC_MSG_CHECKING(Checking for new ALSA API)
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
#include <alsa/asoundlib.h>
]], [[
static snd_pcm_hw_params_t *hwparams;
static snd_pcm_uframes_t chunk;
snd_pcm_hw_params_get_buffer_size (hwparams,&chunk);
]])],[
new_alsa=yes
AC_MSG_RESULT(yes)
AC_DEFINE(RSYNTH_ALSA_PCM_POINTER_PARAMS_API,1,[New ALSA API passes pointers to parms])
],[
new_alsa=no
AC_MSG_RESULT(no)
])

if test $new_alsa = no; then
  AC_MSG_CHECKING(Checking for old ALSA API)
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
  #define ALSA_PCM_OLD_HW_PARAMS_API
  #include <alsa/asoundlib.h>
  ]], [[
  static snd_pcm_hw_params_t *hwparams;
  static snd_pcm_uframes_t chunk;
  chunk = snd_pcm_hw_params_get_buffer_size (hwparams);
  ]])],[
  AC_MSG_RESULT(yes)
  AC_DEFINE(ALSA_PCM_OLD_HW_PARAMS_API,1,[Old ALSA API without pointers])
  ],[
  AC_MSG_RESULT(no)
  ])
fi

AC_CHECK_LIB(asound,snd_pcm_open)
fi

if test "$hplay" = oss; then
 AC_CHECK_HEADERS(sys/soundcard.h machine/soundcard.h,break,hplay=dummy)
 if test -c /dev/dspW ; then
  AC_DEFINE(HAVE_DEV_DSPW,1,[Found /dev/dspW])
 fi
 if test -c /dev/audio ; then
  AC_DEFINE(HAVE_DEV_AUDIO,1,[Found /dev/audio])
 fi
 if test -c /dev/dsp ; then
  AC_DEFINE(HAVE_DEV_DSP,1,[Found /dev/dsp])
 fi
 if test -c /dev/sbdsp ; then
  AC_DEFINE(HAVE_DEV_SBDSP,1,[Found /dev/sbdsp])
 fi
fi




dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_TYPE_OFF_T

dnl See if float can be used in protos followed by K&R definition
AC_MSG_CHECKING(if we can use float in prototypes)
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[]], [[
} int func (float a);
int func(a) float a; { ]])],[AC_MSG_RESULT(yes)],[
AC_DEFINE(NOPROTOFLOAT,1,[No float prototype])
AC_MSG_RESULT(no)
])

if test -d $prefix/include; then
 CPPFLAGS="$CPPFLAGS -I$prefix/include"
 AC_MSG_WARN(Using -I$prefix/include)
fi

if test -d $prefix/lib; then
 LIBS="-L$prefix/lib $LIBS"
 AC_MSG_WARN(Using -L$prefix/lib)
fi

AC_ARG_WITH(aDict,[  --with-aDict[=<path>]   American Dictionary],[
if test "$withval" != "" && test -r "$withval" ; then
 AC_MSG_NOTICE(Using $withval as American Dictionary)
 ADICT="$withval"
 BUILD="$BUILD aDict.db"
 DICTS="$DICTS aDict.db"
else
 AC_MSG_WARN(Cannot read $withval for American Dictionary)
fi])

AC_ARG_WITH(bDict,[  --with-bDict[=<path>]   British Dictionary],[
if test "$withval" != "" && test -r "$withval" ; then
 AC_MSG_NOTICE(Using $withval as British Dictionary)
 BDICT="$withval"
 BUILD="$BUILD bDict.db"
 DICTS="$DICTS bDict.db"
else
 AC_MSG_WARN(Cannot read $withval for British Dictionary)
fi])

AS_MESSAGE([checking for database libraries...])

AC_ARG_WITH(db,[  -with-db[=<path]    Try and use Berkeley DB],[
if test "$withval" != "" && test -d "$withval" ; then
 CPPFLAGS="-I$withval $CPPFLAGS"
 LIBS="-L$withval $LIBS"
fi])

if test "$with_db" != "no" ; then
  AC_CHECK_LIB(db,db_create)
  if test "$ac_cv_lib_db_db_create" = yes ; then
   AC_CHECK_HEADERS(db.h,db_h=yes)
  fi
  if test "$db_h" = yes ; then
   PROGS="$PROGS mkdictdb dlookup"
   AC_MSG_WARN(Using db)
  fi
fi

AC_ARG_WITH(gdbm,[  --with-gdbm[=<path>]    Try and use GNU gdbm (given source directory)],[
if test "$withval" != "" && test -d "$withval" ; then
 CPPFLAGS="-I$withval $CPPFLAGS"
 LIBS="-L$withval $LIBS"
else
 echo "--with-gdbm=$withval"
fi])

if test "$with_gdbm" != "no" ; then
 AC_CHECK_HEADERS(gdbm.h,gdbm_h=yes)
 if test "$gdbm_h" = yes; then
   AC_CHECK_LIB(gdbm,gdbm_open)
   if test "$ac_cv_lib_gdbm_gdbm_open" = yes ; then
    AC_MSG_WARN(Using gdbm)
    PROGS="$PROGS mkdictdb dlookup"
   fi
 fi
fi

if test "$db_h$gdbm_h" = ""; then
  AC_MSG_WARN(No db.h and no gdbm.h)
  BUILD=""
fi

AC_ARG_WITH(festival,[  --with-festival[=<path>]   Festival Directory],[
if test "$withval" != "" && test -d "$withval/lib/voices" ; then
 FESTIVAL="$withval"
 BUILD="$BUILD festival"
 EXTRA_INST="$EXTRA_INST install_festival"
else
 AC_MSG_WARN(Cannot find $withval/lib/voices directory)
fi])

DEFAULT_DICT=b

AC_ARG_WITH(defDict,[  --with-defDict[=<a|b>]   Default Dictionary, American (a) or British (b)],[
if test "$withval" != "" ; then
 DEFAULT_DICT="$withval"
else
 echo "Cannot read $withval"
fi])

CPPFLAGS="-I. -I$srcdir $CPPFLAGS"

AC_CHECK_LIB(M,atan)
AC_CHECK_LIB(m,atan)


if test "$hplay" = sgi; then
AC_CHECK_LIB(audio,ALopenport)
fi

dnl Check for sndfile header and library
AC_CHECK_HEADERS(sndfile.h,sndfile_h=yes)
if test "$sndfile_h" = yes; then
   AC_CHECK_LIB(sndfile,sf_open)
   if test "$ac_cv_lib_sndfile_sfopen" = yes ; then
    AC_MSG_WARN(Found libsndfile)
   fi
fi

dnl Checking for X11
AC_PATH_XTRA
if test -n "$x_includes" ; then
CPPFLAGS="$CPPFLAGS -I$x_includes"
fi

AC_CHECK_LIB(socket,socket,XLIBS="-lsocket $XLIBS")
AC_CHECK_LIB(nsl,inet_addr,XLIBS="-lnsl $XLIBS")
AC_CHECK_LIB(X11,XauReadAuth,[
XLIBS="$X_LIBS -lX11 $XLIBS"
AC_DEFINE(HAVE_LIBX11,1,[Found -lX11])
],,$X_LIBS $XLIBS $LIBS)

AC_CHECK_LIB(Xt,XtAppAddInput,[
XLIBS="$X_LIBS -lXt $XLIBS"
AC_DEFINE(HAVE_LIBXT,1,[Found -lXt])
],,$X_LIBS $XLIBS $LIBS)

dnl See if we can find nas audio library
AC_CHECK_HEADERS(audio/audiolib.h)
if test "$ac_cv_header_audio_audiolib_h" = yes ; then
  AC_CHECK_LIB(audio,AuOpenServer,[
  XLIBS="$XLIBS -laudio"
  AC_DEFINE(HAVE_NAS,1,[Found NAS -laudio])
  ],,$XLIBS $LIBS)
  if test "$ac_cv_lib_audio_AuOpenServer" = yes; then
   if test "$hplay" = dummy; then
    hplay="na"
    LIBS="$XLIBS $LIBS"
    XLIBS=""
   else
    PROGS="$PROGS nasay"
   fi
 fi
fi

dnl Check for obscure but speed-enhancing sun hack
if test "$hplay" = sun; then
AC_LINK_IFELSE([AC_LANG_PROGRAM([[]], [[nonstandard_arithmetic();]])],[AC_DEFINE(HAVE_NONSTDARITH,1,[Sun hack])],[])
fi

dnl Checks for library functions.
AC_PROG_GCC_TRADITIONAL
AC_TYPE_SIGNAL

AC_MSG_CHECKING(for GNU make)
if make -v 2>/dev/null | grep -i 'GNU *Make' > /dev/null ; then
make_dist=$srcdir/config/make_dist
AC_MSG_RESULT(yes)
else
AC_MSG_RESULT(no)
fi

AC_SUBST(CC)
AC_SUBST(RANLIB)
AC_SUBST(INSTALL)
AC_SUBST(INSTALL_PROGRAM)
AC_SUBST(INSTALL_DATA)
AC_SUBST(BUILD)
AC_SUBST(EXTRA_INST)
AC_SUBST(PERL)
AC_SUBST(FESTIVAL)
AC_SUBST(ADICT)
AC_SUBST(BDICT)
AC_SUBST(DICTS)
AC_SUBST(DEFAULT_DICT)
AC_SUBST(XLIBS)
AC_SUBST(PROGS)
AC_SUBST(NOPROTOFLOAT)
AC_SUBST(HAVE_NONSTDARITH)
AC_SUBST_FILE(make_dist)

ac_sources="config/${hplay}play.c"
ac_dests="hplay.c"
while test -n "$ac_sources"; do
  set $ac_dests; ac_dest=$1; shift; ac_dests=$*
  set $ac_sources; ac_source=$1; shift; ac_sources=$*
  ac_config_links_1="$ac_config_links_1 $ac_dest:$ac_source"
done
AC_CONFIG_LINKS([$ac_config_links_1])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT

