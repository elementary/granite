valadoc = find_program('valadoc')
gd_scan = find_program('gtkdoc-scan')

valadoc_vala_dir = 'granite-vala'
valadoc_target = custom_target(
    'valadoc',
    command: [
        valadoc,
        '--pkg=gee-0.8',
        '--pkg=glib-2.0',
        '--pkg=gio-2.0',
        '--pkg=gio-unix-2.0',
        '--pkg=gobject-2.0',
        '--pkg=gtk+-3.0',
        '--pkg=posix',
        libgranite_sources,
        config_vala,
        '--target-glib=' + glib_min_version,
        '--package-name=' + meson.project_name(),
        '--package-version=' + meson.project_version(),
        '--verbose',
        '--force',
        '--use-svg-images',
        '-o', join_paths(meson.current_build_dir(), valadoc_vala_dir),
    ],

    build_by_default: true,
    output: valadoc_vala_dir,
    depends: libgranite,
)

valadoc_c_dir = 'granite'
cdoc_target = custom_target(
    'cdocs',
    command: [
        valadoc,
        '--pkg=gee-0.8',
        '--pkg=glib-2.0',
        '--pkg=gio-2.0',
        '--pkg=gio-unix-2.0',
        '--pkg=gobject-2.0',
        '--pkg=gtk+-3.0',
        '--pkg=posix',
        libgranite_sources,
        config_vala,
        '--target-glib=' + glib_min_version,
        '--package-name=' + meson.project_name(),
        '--package-version=' + meson.project_version(),
        '--verbose',
        '--force',
        '--use-svg-images',
        '-o', join_paths(meson.current_build_dir(), valadoc_c_dir),
        '--doclet-arg=' + 'lib/granite.h',
        '--doclet=gtkdoc'
    ],

    build_by_default: true,
    output: valadoc_c_dir,
    depends: libgranite
)
