libgranite_sources = files(
    'Application.vala',
    'DateTime.vala',
    'StyleClass.vala',

    'Drawing/BufferSurface.vala',
    'Drawing/Color.vala',
    'Drawing/Utilities.vala',

    'GtkPatch/AboutDialog.vala',

    'Services/ContractorProxy.vala',
    'Services/IconFactory.vala',
    'Services/Logger.vala',
    'Services/Paths.vala',
    'Services/Settings.vala',
    'Services/SimpleCommand.vala',
    'Services/System.vala',

    'Widgets/AboutDialog.vala',
    'Widgets/AbstractSettingsPage.vala',
    'Widgets/AbstractSimpleSettingsPage.vala',
    'Widgets/AlertView.vala',
    'Widgets/AppMenu.vala',
    'Widgets/AsyncImage.vala',
    'Widgets/Avatar.vala',
    'Widgets/CellRendererBadge.vala',
    'Widgets/CellRendererExpander.vala',
    'Widgets/CollapsiblePaned.vala',
    'Widgets/CompositedWindow.vala',
    'Widgets/DatePicker.vala',
    'Widgets/DynamicNotebook.vala',
    'Widgets/HeaderLabel.vala',
    'Widgets/MessageDialog.vala',
    'Widgets/ModeButton.vala',
    'Widgets/ModeSwitch.vala',
    'Widgets/OverlayBar.vala',
    'Widgets/SeekBar.vala',
    'Widgets/SettingsSidebarRow.vala',
    'Widgets/SettingsSidebar.vala',
    'Widgets/SourceList.vala',
    'Widgets/StorageBar.vala',
    'Widgets/TimePicker.vala',
    'Widgets/Toast.vala',
    'Widgets/Utils.vala',
    'Widgets/WelcomeButton.vala',
    'Widgets/Welcome.vala',

    'Widgets/widgets-utils.c',
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

# compile shared library, generate GIR, header, and vapi file
libgranite = library(
    'granite',

    libgranite_sources,

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

install_data(
    'Widgets/widgets-utils.h',
    install_dir: include_dir
)

# typelib generation isn't automated yet
g_ir_compiler = find_program('g-ir-compiler')
custom_target(
    granite_typelib,
    command: [
        g_ir_compiler,
        '--shared-library',
        libgranite.full_path(),
        '--output',
        '@OUTPUT@',
        join_paths(meson.current_build_dir(), granite_gir),
    ],
    output: granite_typelib,
    depends: libgranite,
    install: true,
    install_dir: join_paths(get_option('libdir'), 'girepository-1.0'),
)

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
