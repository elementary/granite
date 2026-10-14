# The first argument is the original icon name,
# the second is the link
categories = [
    ['actions', [
        ['document-edit-symbolic', 'adw-entry-edit-symbolic'],
        ['list-add-symbolic', 'value-increase-symbolic'],
        ['list-remove-symbolic', 'value-decrease-symbolic'],
        ['view-pin-symbolic-rtl', 'adw-tab-unpin-symbolic-rtl'],
        ['view-pin-symbolic', 'adw-tab-unpin-symbolic'],
        ['view-sidebar-end-symbolic', 'view-sidebar-start-rtl-symbolic'],
        ['view-sidebar-start-symbolic', 'view-sidebar-end-rtl-symbolic']
    ]],
    ['categories', [
        ['poi-street-symbolic', 'poi-car-symbolic']
    ]],
    ['status',[
        ['dialog-error-symbolic', 'process-error-symbolic']
    ]],
    ['ui', [
        ['check-checked-symbolic', 'adw-entry-apply-symbolic'],
        ['check-checked-symbolic', 'check-active-symbolic'],
        ['check-indeterminate-symbolic', 'check-mixed-symbolic'],
        ['pan-end-symbolic', 'pan-start-symbolic-rtl'],
        ['pan-start-symbolic', 'pan-end-symbolic-rtl'],
        ['pan-up-symbolic', 'adw-expander-arrow-symbolic']
    ]]
]

foreach category : categories
    folder = category[0]
    links = category[1]

    install_subdir(
        folder,
        install_dir: icon_dir / 'scalable'
    )

    if (links.length() < 1)
        continue
    endif

    foreach link : links
        origin = link[0]
        destination = link[1]

        if (fs.exists(folder / origin + '.svg'))
            install_symlink(
                destination + '.svg',
                install_dir: icon_dir / 'scalable' / folder,
                pointing_to: origin + '.svg',
            )
        else
            warning('@0@ does not exist'.format (origin))
        endif
    endforeach
endforeach
