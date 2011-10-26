prefix=@PREFIX@
exec_prefix=@DOLLAR@{prefix}
libdir=@DOLLAR@{prefix}/lib
includedir=@DOLLAR@{prefix}/include

Name: @PKGNAME@
Description: Granite framework
Version: @GRANITE_VERSION@
Libs: -L@DOLLAR@{libdir} -lgranite
Cflags: -I@DOLLAR@{includedir}/${PKGNAME}
Requires: gtk+-3.0

