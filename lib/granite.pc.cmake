prefix=@PREFIX@
exec_prefix=@DOLLAR@{prefix}
libdir=@DOLLAR@{prefix}/lib
includedir=@DOLLAR@{prefix}/include

Name: @PKGNAME@
Description: Granite framework
Version: @GRANITE_VERSION@
Libs: -L@DOLLAR@{libdir} -lgranite
Cflags: -I@DOLLAR@{includedir}/${PKGNAME}
Requires: cairo gee-1.0 glib-2.0 gio-unix-2.0 gobject-2.0 gthread-2.0 gdk-3.0 gdk-pixbuf-2.0 gtk+-3.0

