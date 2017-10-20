subdir('Drawing')
subdir('GtkPatch')
subdir('Services')
subdir('Widgets')
vapidir = join_paths (get_option('datadir'),'vala','vapi')
GIR_NAME= VERSIONED_CAMEL_CASE_NAME+'.gir'
TYPELIB_NAME= VERSIONED_CAMEL_CASE_NAME+'.typelib'
VAPI_NAME = VERSIONED_PROJECT_NAME+'.vapi'
INCLUDE_DIR = join_paths (get_option ('includedir'), VERSIONED_PROJECT_NAME)
conf = configuration_data()
conf.set('PREFIX', get_option('prefix'))
conf.set('exec_prefix', get_option('prefix'))
conf.set('libdir', join_paths (get_option ('prefix'),get_option ('libdir')))
conf.set('includedir', INCLUDE_DIR)
conf.set('DOLLAR', '$')
conf.set('PKG_NAME', PROJECT_NAME)
conf.set('PKG_VERSION', PROJECT_VERSION)

configure_file(input : 'granite.pc.cmake',
	output : 'granite.pc'.format(API_VERSION),
	configuration : conf,
	install : true,
	install_dir :  join_paths(get_option('libdir'), 'pkgconfig')
	)

install_data('granite.deps', install_dir : vapidir)

resdir = join_paths (get_option('datadir'),PROJECT_NAME)
confh = configuration_data ()
confh.set_quoted('PACKAGE_LOCALE_DIR', join_paths(get_option('prefix'), get_option('datadir'), 'locale'))
confh.set_quoted('GETTEXT_PACKAGE', PROJECT_NAME)
confh.set_quoted('RESOURCES_DIR', resdir)
conffile = configure_file(output : 'config.h',
	configuration : confh)
confh_dep = declare_dependency (sources : conffile)

valasources = files ([
	'StyleClass.vala',
	'Application.vala',
	'DateTime.vala'
])

sources = files ([
])

inc_libh = include_directories ('.')
inc_libh_dep = declare_dependency (include_directories : inc_libh)

lib = library(PROJECT_NAME,
	valasources
	+sources
	+drawing_files
	+gtkpatch_files
	+services_files
	+widgets_files,
	version : PROJECT_VERSION,
	vala_header : PROJECT_NAME+'.h',
	vala_vapi : VAPI_NAME,
	vala_gir : GIR_NAME,

	dependencies : [gtk, gio, gee, m_dep, inc_libh_dep, inc_rooth_dep, inc_libwidgetsh_dep],
	vala_args : [
		'--pkg', 'posix'
	],
	c_args : [
		'-include',
		join_paths (meson.build_root(),'lib','config.h')
	],
	install : true,
	install_dir : [
		get_option('libdir'),
		join_paths (get_option('includedir'),PROJECT_NAME),
		vapidir,
		true
	])

g_ir_compiler = find_program('g-ir-compiler')
custom_target('typelib',
	command: [
		g_ir_compiler,
		'--shared-library', 'lib'+PROJECT_NAME+'-@0@.so'.format (API_VERSION),
		'--output', '@OUTPUT@',
		join_paths(meson.current_build_dir(), GIR_NAME)
	],
	output: TYPELIB_NAME,
	depends: lib,
	install: true,
	install_dir: join_paths(get_option('libdir'), 'girepository-1.0'))

