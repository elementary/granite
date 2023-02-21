icon_sizes = ['48']

foreach i : icon_sizes
    install_data(
        'icons' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps',
        rename: 'io.elementary.' + meson.project_name() + '.svg'
    )
    install_data(
        'icons' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i + '@2' / 'apps',
        rename: 'io.elementary.' + meson.project_name() + '.svg'
    )
endforeach

i18n.merge_file(
    input: 'granite.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'xml',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo'),
)

gresource = gnome.compile_resources(
    'granite-resources',
    'granite.gresource.xml',
    source_dir: join_paths(meson.source_root(), 'data')
)
