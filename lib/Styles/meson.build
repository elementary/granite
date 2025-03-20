sassc = find_program('sassc')

sassc_opts = [ '-a', '-M', '-t', 'compact' ]

gtk_stylesheet_deps = custom_target(
    'Gtk.scss',
    input: 'Gtk.scss',
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

gtk_stylesheet_dark_deps = custom_target(
    'Gtk-dark.scss',
    input: 'Gtk-dark.scss',
    output: 'gtk-dark.css',
    command: [
        sassc,
        sassc_opts,
        '@INPUT@',
        '@OUTPUT@',
    ],
    install: true,
    install_dir: get_option('datadir') / 'themes' / 'Granite' / 'gtk-4.0'
)

granite_stylesheet_deps = custom_target(
    'Granite.scss',
    input: 'Granite.scss',
    output: 'granite.css',
    command: [
        sassc,
        sassc_opts,
        '@INPUT@',
        '@OUTPUT@',
    ],
    install: false,
    install_dir: get_option('datadir') / 'themes' / 'Granite' / 'gtk-4.0'
)

granite_stylesheet_dark_deps = custom_target(
    'Granite-dark.scss',
    input: 'Granite-dark.scss',
    output: 'granite-dark.css',
    command: [
        sassc,
        sassc_opts,
        '@INPUT@',
        '@OUTPUT@',
    ],
    install: false,
    install_dir: get_option('datadir') / 'themes' / 'Granite' / 'gtk-4.0'
)

stylesheet_resource = gnome.compile_resources(
    'styles-resource',
    'styles.gresource.xml',
    source_dir: [
        meson.current_build_dir(),
        meson.current_source_dir(),
    ],
    dependencies: [
        gtk_stylesheet_deps,
        gtk_stylesheet_dark_deps,
        granite_stylesheet_deps,
        granite_stylesheet_dark_deps
    ]
)
