project('granite', [ 'vala', 'c'], version : '0.4.2')

PROJECT_NAME = meson.project_name()
API_VERSION = '0'
PROJECT_VERSION = meson.project_version()
VERSIONED_PROJECT_NAME = PROJECT_NAME+'-'+API_VERSION
CAMEL_CASE_NAME = 'Granite'
VERSIONED_CAMEL_CASE_NAME = CAMEL_CASE_NAME +'-'+ API_VERSION

gtk = dependency('gtk+-3.0', version: '>=3.14')
gio = dependency('gio-unix-2.0')
gee = dependency ('gee-0.8')
thread = dependency ('gthread-2.0')
cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : false)

VALADEPS = 'gtk+-3.0\ngio-unix-2.0\ngthread-2.0\ngee-0.8'
PCDEPS = 'gtk+-3.0 gio-unix-2.0 gthread-2.0 gee-0.8'

inc_rooth = include_directories ('.')
inc_rooth_dep = declare_dependency (include_directories : inc_rooth)

add_global_arguments('--target-glib=2.50', language : 'vala')

#subdir('po')
subdir('lib')
subdir('icons')
#subdir('docs')
subdir('demo')
