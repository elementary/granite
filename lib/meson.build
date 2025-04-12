subdir('Icons')
subdir('Styles')

libgranite_sources = files(
    'DateTime.vala',
    'Constants.vala',
    'Init.vala',
    'StyleManager.vala',

    'Services/Application.vala',
    'Services/AsyncMutex.vala',
    'Services/ContractorProxy.vala',
    'Services/Portal.vala',
    'Services/Settings.vala',
    'Services/System.vala',

    'Widgets/AbstractSettingsPage.vala',
    'Widgets/AbstractSimpleSettingsPage.vala',
    'Widgets/AccelLabel.vala',
    'Widgets/ActionSheet.vala',
    'Widgets/Bin.vala',
    'Widgets/Box.vala',
    'Widgets/DatePicker.vala',
    'Widgets/Dialog.vala',
    'Widgets/HeaderLabel.vala',
    'Widgets/HyperTextView.vala',
    'Widgets/ListItem.vala',
    'Widgets/MessageDialog.vala',
    'Widgets/ModeSwitch.vala',
    'Widgets/OverlayBar.vala',
    'Widgets/Placeholder.vala',
    'Widgets/SettingsSidebarRow.vala',
    'Widgets/SettingsSidebar.vala',
    'Widgets/Settings.vala',
    'Widgets/SwitchModelButton.vala',
    'Widgets/TimePicker.vala',
    'Widgets/Toast.vala',
    'Widgets/Utils.vala',
    'Widgets/ValidatedEntry.vala'
)

# define all the names and versions
granite_gi_name = 'Granite'
granite_gi_version = '7.0'

granite_gi = granite_gi_name + '-' + granite_gi_version
granite_gir = granite_gi + '.gir'
granite_typelib = granite_gi + '.typelib'

include_dir = join_paths(
    get_option('prefix'),
    get_option('includedir'),
    meson.project_name()
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
    meson.project_name(),

    libgranite_sources,
    icons_resource,
    stylesheet_resource,
    config_vala,

    dependencies: [
        libgranite_deps,
        meson.get_compiler('c').find_library('m'),
        meson.get_compiler('vala').find_library('posix')
    ],

    vala_header: 'granite-7.h',
    vala_vapi: 'granite-7.vapi',
    vala_gir: granite_gir,

    version: meson.project_version(),
    install: true,
    install_dir: [true, include_dir, true, true],
)

install_data(
    'granite-7.deps',
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
    name: meson.project_name(),
    requires: libgranite_deps,
    subdirs: ['granite-7'],
    description: 'elementary\'s Application Framework',
    version: meson.project_version(),
    url: 'https://github.com/elementary/granite',
)
