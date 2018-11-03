executable(
    'granite-demo',

    'GraniteDemo.vala',
    
    'Views/AlertViewView.vala',
    'Views/AsyncImageView.vala',
    'Views/AvatarView.vala',
    'Views/CSSView.vala',
    'Views/DateTimePickerView.vala',
    'Views/DynamicNotebookView.vala',
    'Views/MessageDialogView.vala',
    'Views/ModeButtonView.vala',
    'Views/OverlayBarView.vala',
    'Views/SeekBarView.vala',
    'Views/SettingsView/SettingsPage.vala',
    'Views/SettingsView/SettingsView.vala',
    'Views/SettingsView/SimpleSettingsPage.vala',
    'Views/SourceListView.vala',
    'Views/StorageView.vala',
    'Views/ToastView.vala',
    'Views/UtilsView.vala',
    'Views/WelcomeView.vala',

    dependencies: [libgranite_dep],

    include_directories: [include_directories('../lib')],

    link_with: libgranite,
    install: true,
)

applications_dir = join_paths(
    get_option('prefix'),
    get_option('datadir'),
    'applications'
)

install_data(
    'granite-demo.desktop',
    install_dir: applications_dir
)

