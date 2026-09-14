icons_resource = gnome.compile_resources(
    'icons-resource',
    'icons.gresource.xml',
    source_dir: [
        'scalable/actions/',
        'scalable/categories/',
        'scalable/status/',
        'scalable/ui/'
    ]
)

icon_dir = get_option('datadir') / 'icons' / 'Granite'

install_subdir(
    'scalable',
    install_dir: icon_dir
)

install_data(
    'index.theme',
    install_dir: icon_dir
)
