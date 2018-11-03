project(
    'granite',
    'vala', 'c',
    version: '5.2.0'
)

if meson.get_compiler('vala').version() < '0.40.0'
    error('vala compiler version 0.40.0 or newer is required.')
endif

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: ['c']
)

add_project_arguments(
    '--abi-stability',
    '--hide-internal',
    '--target-glib=2.50',
    '--thread',
    language: ['vala']
)

libgranite_deps = [
    dependency('gee-0.8'),
    dependency('gio-unix-2.0'),
    dependency('gtk+-3.0', version: '>=3.22'),
]

resources_dir = join_paths(
    get_option('prefix'),
    get_option('datadir'),
    meson.project_name()
)

conf = configuration_data()
conf.set('RESOURCES_DIR', resources_dir)

config_header = configure_file(
    input: 'lib/config.h.in',
    output: 'config.h',
    configuration: conf
)

pkgconfig = import('pkgconfig')
i18n = import('i18n')

subdir('lib')
subdir('demo')
subdir('icons')
subdir('po')
subdir('doc')

