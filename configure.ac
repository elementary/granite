AC_INIT([granite], [0.1.0])
AC_DEFINE(RELEASE_NAME, "Library for elementary applications.", Codename of this release)

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_SRCDIR([.])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([1.11 foreign tar-pax])

dnl -- Populate top_srcdir variable
top_srcdir=$(readlink -f $0 | sed -e s/configure$//)

if test -d $top_srcdir/.bzr ; then
	VERSION_INFO=`bzr version-info --custom \
	--template="bzr {branch_nick} r{revno}"`
else
	VERSION_INFO="Release"
fi
AC_DEFINE_UNQUOTED(VERSION_INFO, "$VERSION_INFO", Version info for package)

dnl ==============================================
dnl Translation support
dnl ==============================================

GETTEXT_PACKAGE=granite
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE", [Gettext package])
ALL_LINGUAS=`ls ${top_srcdir}/po/*.po | sed 's/.po$//' | sed 's/.*\///' | tr '\n' ' '`

IT_PROG_INTLTOOL([0.35.0])
AM_GLIB_GNU_GETTEXT

dnl pkg-config
AC_PATH_PROG(PKG_CONFIG, pkg-config, no)
if test "x$PKG_CONFIG" = "xno"; then
        AC_MSG_ERROR([You need to install pkg-config])
fi

AC_PROG_INSTALL
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_LIBTOOL
AC_STDC_HEADERS

dnl ==============================================
dnl Set dependency versions
dnl ==============================================

GTK_MIN_VERSION=3.0.8
GLIB_MIN_VERSION=2.26.0
VALA_MIN_VERSION=0.10.0

dnl ==============================================
dnl Check that we meet the dependencies
dnl ==============================================
AM_PROG_VALAC([$VALA_MIN_VERSION])
if test "x$VALAC" = "x"; then
	AC_MSG_ERROR([You need a Vala $VALA_MIN_VERSION compiler])
fi

AM_SILENT_RULES([yes])

PKG_CHECK_MODULES(GRANITE_CORE, gobject-2.0 >= $GLIB_MIN_VERSION
                              glib-2.0 >= $GLIB_MIN_VERSION
                              gio-2.0 >= $GLIB_MIN_VERSION
                              gio-unix-2.0 >= $GLIB_MIN_VERSION
                              gtk+-3.0 >= $GTK_MIN_VERSION
                              gee-1.0
)

GRANITE_CORE_VALA_PKGS="--pkg gtk+-3.0 \
                      --pkg gio-unix-2.0 \
                      --pkg gee-1.0 \
                      --pkg posix"
AC_SUBST(GRANITE_CORE_VALA_PKGS)

GRANITE_CORE_VALAFLAGS="--thread $GRANITE_CORE_VALA_PKGS"
AC_SUBST(GRANITE_CORE_VALAFLAGS)

dnl Expansions
AS_AC_EXPAND([PKGDATADIR], [$datadir/$PACKAGE_NAME])
AS_AC_EXPAND([DATADIR], [$datadir])
AS_AC_EXPAND([LIBDIR], [$libdir])
AS_AC_EXPAND([LIBEXECDIR], [$libexecdir])
AS_AC_EXPAND([SCHEMADIR], [$PKGDATADIR/schemas])

AC_DEFINE_UNQUOTED(PKGDATADIR, "$PKGDATADIR", [Package base directory])
AC_DEFINE_UNQUOTED(SCHEMAFILEDIR, "$SCHEMADIR", [Directory with config schema])
AC_DEFINE_UNQUOTED(DATADIR, "$DATADIR", [Data directory])

dnl {{{ enable debug release configuration
AC_ARG_ENABLE(debug,
	AC_HELP_STRING([--enable-debug],
		[Use 'DEBUG' Configuration [default=YES]]),
		enable_debug=yes, enable_debug=no)
AM_CONDITIONAL(ENABLE_DEBUG, test "x$enable_debug" = "xyes")
if test "x$enable_debug" = "xyes" ; then
	GRANITE_CORE_VALAFLAGS+=" -g"
	CONFIG_REQUESTED="yes"
fi
dnl }}}

dnl {{{ enable release build configuration
AC_ARG_ENABLE(release,
	AC_HELP_STRING([--enable-release],
		[Use 'RELEASE' Configuration [default=NO]]),
		enable_release=yes, enable_release=no)
AM_CONDITIONAL(ENABLE_RELEASE, test x$enable_release = xyes)
if test "x$enable_release" = "xyes" ; then
	CONFIG_REQUESTED="yes"
fi
if test -z "$CONFIG_REQUESTED" ; then
	AM_CONDITIONAL(ENABLE_DEBUG, true)
fi
dnl }}}

AC_CONFIG_FILES([
Makefile
lib/Makefile
lib/libgranite.pc
m4/Makefile
po/Makefile.in
vapi/Makefile
])

AC_OUTPUT

cat <<EOF

${PACKAGE}-${VERSION}

  Build Environment
    Install Prefix:     ${prefix}

  Build/Development
    Release Build:      ${enable_release}

EOF
