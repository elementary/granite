prefix=@PREFIX@
exec_prefix=@DOLLAR@{prefix}
libdir=@DOLLAR@{prefix}/lib
includedir=@DOLLAR@{prefix}/include

Name: @PKGNAME@
Description: Granite framework
Version: 0.1.1
Libs: -L@DOLLAR@{libdir} -lgranite
Cflags: -I@DOLLAR@{includedir}/${PKGNAME}
Requires: gtk+-3.0

