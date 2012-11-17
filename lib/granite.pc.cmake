prefix=@PREFIX@
exec_prefix=@DOLLAR@{prefix}
libdir=@DOLLAR@{prefix}/lib
includedir=@DOLLAR@{prefix}/include

Name: @PKG_NAME@
Description: @PKG_DESC_NAME@ framework
Version: @PKG_VERSION@
Libs: -L@DOLLAR@{libdir} -l@PKG_NAME@
Cflags: -I@DOLLAR@{includedir}/@PKG_NAME@
Requires: cairo gee-1.0 glib-2.0 gio-unix-2.0 gobject-2.0 gthread-2.0 gdk-3.0 gdk-pixbuf-2.0 gtk+-3.0

