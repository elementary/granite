# increase when you break the API
set (PKG_SOVERSION 2)

# Increase when you add functionality
set (PKG_SOMINOR 0.1)

set (VALA_SOURCES
    style-classes.vala
    Application.vala
    Drawing/Color.vala
    Drawing/BufferSurface.vala
    Drawing/Utilities.vala
    GtkPatch/AboutDialog.vala
    Services/Settings.vala
    Services/Logger.vala
    Services/Paths.vala
    Services/System.vala
    Services/Contractor.vala
    Services/ContractorProxy.vala
    Services/IconFactory.vala
    Services/SimpleCommand.vala
    Widgets/Utils.vala
    Widgets/WrapLabel.vala
    Widgets/AboutDialog.vala
    Widgets/ModeButton.vala
    Widgets/DatePicker.vala
    Widgets/Entries.vala
    Widgets/TimePicker.vala
    Widgets/CollapsiblePaned.vala
    Widgets/StaticNotebook.vala
    Widgets/DynamicNotebook.vala
    Widgets/CompositedWindow.vala
    Widgets/AppMenu.vala
    Widgets/Welcome.vala
    Widgets/ToolButtonWithMenu.vala
    Widgets/PopOver.vala
    Widgets/ContractorView.vala
    Widgets/ContractorMenu.vala
    Widgets/DecoratedWindow.vala
    Widgets/LightWindow.vala
    Widgets/StatusBar.vala
    Widgets/SidebarPaned.vala
    Widgets/SourceList.vala
    Widgets/CellRendererExpander.vala
    Widgets/CellRendererBadge.vala
    Widgets/ThinPaned.vala
    Widgets/OverlayBar.vala
)

set (C_SOURCES
    Widgets/widgets-utils.c
    Widgets/close-button.c
)

######################
# lib PC file
######################
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$") # You hear that? It's kittens being killed by the gods of cmake

configure_file (${CMAKE_SOURCE_DIR}/lib/config.h.cmake ${CMAKE_BINARY_DIR}/lib/config.h) # used from config.vala
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/${PKG_NAME}.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}.pc)

include (GNUInstallDirs)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}.pc DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/pkgconfig)

# Link all
set (CFLAGS ${DEPS_CFLAGS} ${DEPS_CFLAGS_OTHER})
add_definitions (${CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

set (LIBS ${DEPS_LIBRARIES} -lm)
set (LIB_PATHS ${DEPS_LIBRARY_DIRS})
link_directories (${LIB_PATHS})

include_directories (${CMAKE_CURRENT_SOURCE_DIR}/Widgets)

vala_precompile (VALA_C ${PKG_NAME}
    ${VALA_SOURCES}
PACKAGES
    ${PKG_DEPS}
GENERATE_HEADER
    ${PKG_NAME}
GENERATE_VAPI
    ${PKG_NAME}
CUSTOM_VAPIS
    ${CMAKE_CURRENT_SOURCE_DIR}/config.vapi
OPTIONS
    ${VALAC_OPTIONS}
)

install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}.vapi DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/vala/vapi)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/${PKG_NAME}.deps DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/vala/vapi)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}.h DESTINATION ${CMAKE_INSTALL_FULL_INCLUDEDIR}/${PKG_NAME})
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/Widgets/widgets-utils.h DESTINATION ${CMAKE_INSTALL_FULL_INCLUDEDIR}/${PKG_NAME})

set (LIB_FILES ${C_SOURCES} ${VALA_C})

add_library (${PKG_NAME} SHARED ${LIB_FILES})

target_link_libraries (${PKG_NAME} ${LIBS})

set_target_properties (${PKG_NAME} PROPERTIES
    VERSION ${PKG_SOVERSION}.${PKG_SOMINOR}
    SOVERSION ${PKG_SOVERSION})

install (TARGETS ${PKG_NAME} DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR})

###########################
# GObject Introspection
###########################

include (FindGObjectIntrospection)

if (INTROSPECTION_FOUND)
    include (GObjectIntrospectionMacros)
    add_target_gir (${PKG_NAME} ${PKG_GIR_NAME} ${PKG_NAME}.h "${VALA_C}" "${DEPS_CFLAGS}" ${API_VERSION} ${GI_PKG_DEPS})
endif ()