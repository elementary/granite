open_menu_sizes = ['16', '22', '24', '32', '48']
appointment_sizes = ['16', '24']

# open-menu.svg
foreach size : open_menu_sizes
    sizexsize = '@0@x@0@'.format(size)
    path = join_paths(sizexsize, 'open-menu.svg')
    install_dir = join_paths(icons_dir, sizexsize, 'actions')

    install_data(
        path,
        install_dir: install_dir
    )
endforeach

# open-menu-symbolic.svg
install_data(
    'scalable/open-menu-symbolic.svg',
    install_dir: join_paths(icons_dir, 'scalable', 'actions')
)

# appointment.svg
foreach size : appointment_sizes
    sizexsize = '@0@x@0@'.format(size)
    path = join_paths(sizexsize, 'appointment.svg')
    install_dir = join_paths(icons_dir, sizexsize, 'actions')

    install_data(
        path,
        install_dir: install_dir
    )
endforeach

