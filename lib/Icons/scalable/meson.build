links = [
    # The first argument is the original icon name,
    # the second is the link
    ['actions/document-edit-symbolic', 'actions/adw-entry-edit-symbolic'],
    ['actions/list-add-symbolic.svg', 'actions/value-increase-symbolic'],
    ['actions/list-remove-symbolic', 'actions/value-decrease-symbolic'],
    ['actions/view-pin-symbolic-rtl.svg', 'actions/adw-tab-unpin-symbolic-rtl'],
    ['actions/view-pin-symbolic.svg', 'actions/adw-tab-unpin-symbolic'],
    ['actions/view-sidebar-end-symbolic.svg', 'actions/view-sidebar-start-rtl-symbolic'],
    ['actions/view-sidebar-start-symbolic.svg', 'actions/view-sidebar-end-rtl-symbolic'],

    ['ui/poi-street-symbolic', 'ui/poi-car-symbolic'],

    ['status/dialog-error-symbolic', 'status/process-error-symbolic'],

    ['ui/check-checked-symbolic', 'ui/adw-entry-apply-symbolic'],
    ['ui/check-checked-symbolic', 'ui/check-active-symbolic'],
    ['ui/check-indeterminate-symbolic', 'ui/check-mixed-symbolic'],
    ['ui/pan-end-symbolic', 'ui/pan-start-symbolic-rtl'],
    ['ui/pan-start-symbolic', 'ui/pan-end-symbolic-rtl'],
    ['ui/pan-up-symbolic', 'ui/adw-expander-arrow-symbolic'],
]

foreach link : links
    origin = link[0]
    destination = link[1]

    if (fs.exists(size / origin + '.svg'))
        install_symlink(
            'scalable' / destination + '.svg',
            install_dir: icon_dir,
            pointing_to: origin + '.svg',
        )
    else
        warning('@0@ does not exist'.format (size / origin))
    endif
endforeach

install_subdir(
    'actions',
    install_dir: icon_dir / 'scalable'
)

install_subdir(
    'categories',
    install_dir: icon_dir / 'scalable'
)

install_subdir(
    'status',
    install_dir: icon_dir / 'scalable'
)

install_subdir(
    'ui',
    install_dir: icon_dir / 'scalable'
)
