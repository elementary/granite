sassc = find_program('sassc')

sassc_opts = [ '-a', '-M', '-t', 'compact' ]

stylesheet_deps = custom_target(
    'Granite.scss',
    input: 'Index.scss',
    output: 'gtk.css',
    command: [
        sassc,
        sassc_opts,
        '@INPUT@',
        '@OUTPUT@',
    ],
    install: true,
    install_dir: get_option('datadir') / 'themes' / 'Granite' / 'gtk-4.0'
)

stylesheet_resource = gnome.compile_resources(
    'styles-resource',
    'styles.gresource.xml',
    source_dir: [
        meson.current_build_dir(),
        meson.current_source_dir(),
    ],
    dependencies: stylesheet_deps
)
