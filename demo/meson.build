executable(
    'granite-7-demo',

    'GraniteDemo.vala',
    'DemoPage.vala',

    'Views/AccelLabelView.vala',
    'Views/ApplicationView.vala',
    'Views/BoxView.vala',
    'Views/ControlsView.vala',
    'Views/CSSView.vala',
    'Views/DateTimePickerView.vala',
    'Views/DialogsView.vala',
    'Views/FormView.vala',
    'Views/HyperTextViewGrid.vala',
    'Views/ListsView.vala',
    'Views/MapsView.vala',
    'Views/OverlayBarView.vala',
    'Views/SettingsUrisView.vala',
    'Views/StyleManagerView.vala',
    'Views/ToastView.vala',
    'Views/ToastOverlayView.vala',
    'Views/UtilsView.vala',
    'Views/WelcomeView.vala',

    dependencies: [
        libgranite_dep,
        dependency('shumate-1.0')
    ],

    install: true,
)

applications_dir = join_paths(
    get_option('prefix'),
    get_option('datadir'),
    'applications'
)

install_data(
    'io.elementary.granite-7.demo.desktop',
    install_dir: applications_dir
)

