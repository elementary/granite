sassc = find_program('sassc')

sassc_opts = [ '-a', '-M', '-t', 'compact' ]

stylesheet_deps = custom_target(
    'Granite.scss',
    input: 'Index.scss',
    output: 'Granite.css',
    command: [
        sassc,
        sassc_opts,
        '@INPUT@',
        '@OUTPUT@',
    ]
)

stylesheet_dark_deps = custom_target(
    'Granite-dark.scss',
    input: 'Index-dark.scss',
    output: 'Granite-dark.css',
    command: [
        sassc,
        sassc_opts,
        '@INPUT@',
        '@OUTPUT@',
    ]
)

stylesheet_resource = gnome.compile_resources(
    'styles-resource',
    'styles.gresource.xml',
    source_dir: [
        meson.current_build_dir(),
        meson.current_source_dir(),
    ],
    dependencies: [
        stylesheet_deps,
        stylesheet_dark_deps
    ]
)
