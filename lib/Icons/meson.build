icons_resource = gnome.compile_resources(
    'icons-resource',
    'icons.gresource.xml'
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
