prefix=@PREFIX@
exec_prefix=@DOLLAR@{prefix}
libdir=@DOLLAR@{prefix}/lib
includedir=@DOLLAR@{prefix}/include

Name: granite
Description: elementary's Application Framework
Version: @PKG_VERSION@
Libs: -L@DOLLAR@{libdir} -l@PKG_NAME@
Cflags: -I@DOLLAR@{includedir}/@PKG_NAME@
Requires: cairo gee-0.8 glib-2.0 gio-unix-2.0 gobject-2.0 gthread-2.0 gdk-3.0 gdk-pixbuf-2.0 gtk+-3.0

