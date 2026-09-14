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

install_data(
    'index.theme',
    install_dir: icon_dir
)

install_subdir(
    '16',
    install_dir: icon_dir / '16x16/emblems'
)

install_symlink(
    '16x16@2',
    install_dir: icon_dir,
    pointing_to: '16x16'
)

install_subdir(
    'scalable/actions',
    install_dir: icon_dir / 'scalable'
)

install_subdir(
    'scalable/categories',
    install_dir: icon_dir / 'scalable'
)

install_subdir(
    'scalable/status',
    install_dir: icon_dir / 'scalable'
)

install_subdir(
    'scalable/ui',
    install_dir: icon_dir / 'scalable'
)
