libgranite_sources = files(
    'Application.vala',
    'DateTime.vala',
    'Constants.vala',
    'Init.vala',

    'Drawing/BufferSurface.vala',
    'Drawing/Color.vala',
    'Drawing/Utilities.vala',

    'Services/Application.vala',
    'Services/AsyncMutex.vala',
    'Services/ContractorProxy.vala',
    'Services/IconFactory.vala',
    'Services/Logger.vala',
    'Services/Paths.vala',
    'Services/Portal.vala',
    'Services/Settings.vala',
    'Services/SimpleCommand.vala',
    'Services/System.vala',

    'Widgets/AbstractSettingsPage.vala',
    'Widgets/AbstractSimpleSettingsPage.vala',
    'Widgets/AccelLabel.vala',
    'Widgets/AlertView.vala',
    'Widgets/AsyncImage.vala',
    'Widgets/Avatar.vala',
    'Widgets/CellRendererBadge.vala',
    'Widgets/CellRendererExpander.vala',
    'Widgets/CollapsiblePaned.vala',
    'Widgets/CompositedWindow.vala',
    'Widgets/DatePicker.vala',
    'Widgets/Dialog.vala',
    'Widgets/DynamicNotebook.vala',
    'Widgets/HeaderLabel.vala',
    'Widgets/MessageDialog.vala',
    'Widgets/ModeButton.vala',
    'Widgets/ModeSwitch.vala',
    'Widgets/OverlayBar.vala',
    'Widgets/SeekBar.vala',
    'Widgets/SettingsSidebarRow.vala',
    'Widgets/SettingsSidebar.vala',
    'Widgets/Settings.vala',
    'Widgets/SourceList.vala',
    'Widgets/StorageBar.vala',
    'Widgets/SwitchModelButton.vala',
    'Widgets/TimePicker.vala',
    'Widgets/Toast.vala',
    'Widgets/Utils.vala',
    'Widgets/ValidatedEntry.vala',
    'Widgets/WelcomeButton.vala',
    'Widgets/Welcome.vala',
)

# define all the names and versions
granite_gi_name = 'Granite'
granite_gi_version = '1.0'

granite_gi = granite_gi_name + '-' + granite_gi_version
granite_gir = granite_gi + '.gir'
granite_typelib = granite_gi + '.typelib'

include_dir = join_paths(
    get_option('prefix'),
    get_option('includedir'),
    'granite'
)

config_data = configuration_data()
config_data.set('GETTEXT_PACKAGE', meson.project_name())
config_data.set('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
config_vala = configure_file(
    input: 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

# compile shared library, generate GIR, header, and vapi file
libgranite = library(
    'granite',

    libgranite_sources,
    config_vala,

    dependencies: [
        libgranite_deps,
        meson.get_compiler('c').find_library('m'),
        meson.get_compiler('vala').find_library('posix')
    ],

    vala_header: 'granite.h',
    vala_vapi: 'granite.vapi',
    vala_gir: granite_gir,

    version: meson.project_version(),
    install: true,
    install_dir: [true, include_dir, true, true],
)

install_data(
    'granite.deps',
    install_dir: join_paths(get_option('datadir'), 'vala', 'vapi')
)

if get_option('introspection')
    # typelib generation isn't automated yet
    g_ir_compiler = find_program('g-ir-compiler')
    custom_target(
        granite_typelib,
        command: [
            g_ir_compiler,
            '--shared-library',
            '@PLAINNAME@',
            '--output',
            '@OUTPUT@',
            join_paths(meson.current_build_dir(), granite_gir),
        ],
        input: libgranite,
        output: granite_typelib,
        depends: libgranite,
        install: true,
        install_dir: join_paths(get_option('libdir'), 'girepository-1.0'),
    )
endif

libgranite_dep = declare_dependency(
    link_with: libgranite,
    dependencies: libgranite_deps,
    include_directories: [include_directories('.')],
)

# generate pkgconfig file
granite_pc = pkgconfig.generate(
    libgranite,
    name: 'granite',
    requires: libgranite_deps,
    subdirs: ['granite'],
    description: 'elementary\'s Application Framework',
    version: meson.project_version(),
    url: 'https://github.com/elementary/granite',
)

