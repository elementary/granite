executable(
    'granite-demo',

    'GraniteDemo.vala',

    'Views/AccelLabelView.vala',
    'Views/AlertViewView.vala',
    'Views/ApplicationView.vala',
    'Views/AsyncImageView.vala',
    'Views/CSSView.vala',
    'Views/DateTimePickerView.vala',
    'Views/DialogsView.vala',
    'Views/DynamicNotebookView.vala',
    'Views/FormView.vala',
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

    install: true,
)

applications_dir = join_paths(
    get_option('prefix'),
    get_option('datadir'),
    'applications'
)

install_data(
    'io.elementary.granite.demo.desktop',
    install_dir: applications_dir
)

