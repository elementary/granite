subdir('Views')
granite_demo_files = files ([
	'GraniteDemo.vala'
])

executable ('granite-demo',
	granite_demo_files+demo_views+demo_settingsview,
	dependencies : [ gtk, gee, inc_libh_dep, confh_dep ],
	c_args : [
		'-include',
		'config.h'
	],
	link_with: lib,
	install: true)
