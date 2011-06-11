include $(top_srcdir)/Makefile.common

VAPIDIR = $(top_srcdir)/vapi

LIB_CURRENT=0
LIB_REVISION=0
LIB_AGE=0
LIB_VERSION_INFO="$(LIB_CURRENT):$(LIB_REVISION):$(LIB_AGE)"

libgraniteincludedir = $(includedir)/granite
libgraniteinclude_HEADERS = granite.h

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = granite.vapi

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = libgranite.pc

libgranitedir = $(libdir)

BUILT_SOURCES = libgranite_la_vala.stamp

lib_LTLIBRARIES = libgranite.la

libgranite_la_CFLAGS = \
	$(GRANITE_CORE_CFLAGS) \
	-include config.h \
	-w \
	$(NULL)

libgranite_la_LDFLAGS = \
	-version-info $(LIB_VERSION_INFO) \
	$(GRANITE_CORE_LDFLAGS) \
	$(NULL)

libgranite_la_VALAFLAGS = \
	$(GRANITE_CORE_VALAFLAGS) \
	--vapidir $(VAPIDIR) \
	$(NULL)

libgranite_la_LIBADD = \
	$(GRANITE_CORE_LIBS) \
	$(NULL)

libgranite_la_VALASOURCES = \
    Application.vala \
    AppFactory.vala \
	Drawing/Color.vala \
	Drawing/Utilities.vala \
	Drawing/BufferSurface.vala \
	Services/Logger.vala \
	Services/Paths.vala \
	Services/Preferences.vala \
	Services/System.vala \
	Widgets/AppMenu.vala \
	Widgets/DatePicker.vala \
	Widgets/Entries.vala \
	Widgets/TimePicker.vala \
	Widgets/ToolButtonWithMenu.vala \
	$(NULL)

libgranite_la_SOURCES = \
	libgranite_la_vala.stamp \
	$(libgranite_la_VALASOURCES:.vala=.c) \
	$(NULL)

granite.h granite.vapi: libgranite_la_vala.stamp

libgranite_la_vala.stamp: $(libgranite_la_VALASOURCES)
	$(AM_V_VALA)$(VALAC) $(libgranite_la_VALAFLAGS) -C -H granite.h --vapi granite.vapi --library granite $(filter %.vala %.c,$^)
	$(AM_V_at)touch $@

DISTCLEANFILES = \
	$(libgranite_la_SOURCES) \
	libgranite_la_vala.stamp \
	granite.vapi \
	granite.h \
	$(NULL)

EXTRA_DIST = \
	$(libgranite_la_VALASOURCES) \
	libgranite.pc.in \
	$(NULL)

