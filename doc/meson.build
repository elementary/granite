valadoc = find_program('valadoc', required: false)
gd_scan = find_program('gtkdoc-scan', required: false)

if not valadoc.found()
    message('valadoc is not installed. building valadocs is not possible.')
endif

if valadoc.found()
    custom_target(
        'valadoc',
        command: [
            valadoc,
            '--pkg=gee-0.8',
            '--pkg=gio-unix-2.0',
            '--pkg=gtk+-3.0',
            '--pkg=posix',
            libgranite_sources,
            '--vapidir=../lib',
            '--pkg=config',
            '--target-glib=2.50',
            '--package-name=' + granite_gi_name,
            '--package-version=' + granite_gi_version,
            '--verbose',
            '-o', 'valadocs',
            '--doclet=html'
        ],

        output: 'valadoc',
        depends: libgranite,
    )
endif

if not gd_scan.found()
    message('gtkdoc-scan is not installed. building gtk-docs is not possible.')
endif

if valadoc.found() and gd_scan.found()
    custom_target(
        'cdocs',
        command: [
            valadoc,
            '--pkg=gee-0.8',
            '--pkg=gio-unix-2.0',
            '--pkg=gtk+-3.0',
            '--pkg=posix',
            libgranite_sources,
            '--vapidir=../lib',
            '--pkg=config',
            '--target-glib=2.50',
            '--package-name=' + granite_gi_name,
            '--package-version=' + granite_gi_version,
            '--verbose',
            '-o', 'cdocs',
            '--doclet-arg=' + 'lib/granite.h',
            '--doclet=gtkdoc'
        ],

        output: 'cdocs',
        depends: libgranite,
    )
endif

