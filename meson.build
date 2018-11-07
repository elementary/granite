project(
    'granite',
    'vala', 'c',
    version: '5.2.1'
)

if meson.get_compiler('vala').version() < '0.40.0'
    error('vala compiler version 0.40.0 or newer is required.')
endif

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: ['c']
)

if build_machine.system() == 'linux'
    vala_os_arg = ['--define=LINUX']
elif build_machine.system() == 'dragonfly'
    vala_os_arg = ['--define=DRAGON_FLY']
elif build_machine.system() == 'freebsd'
    vala_os_arg = ['--define=FREE_BSD']
elif build_machine.system() == 'netbsd'
    vala_os_arg = ['--define=NET_BSD']
else
    vala_os_arg = []
endif

add_project_arguments(
    vala_os_arg,
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

pkgconfig = import('pkgconfig')
i18n = import('i18n')

subdir('lib')
subdir('demo')
subdir('icons')
subdir('po')
subdir('doc')

