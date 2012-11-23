# increase when you break the API
set (PKG_SOVERSION 1)

# Increase when you add functionality
set (PKG_SOMINOR 0.1)

######################
# lib PC file
######################
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$") # You hear that? It's kittens being killed by the gods of cmake

configure_file (${CMAKE_SOURCE_DIR}/lib/config.h.cmake ${CMAKE_BINARY_DIR}/lib/config.h) # used from config.vala
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/${PKG_NAME}.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}.pc)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}.pc DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig)

# Link all
set (CFLAGS ${DEPS_CFLAGS} ${DEPS_CFLAGS_OTHER})
add_definitions (${CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

set (LIBS ${DEPS_LIBRARIES})
set (LIB_PATHS ${DEPS_LIBRARY_DIRS})
link_directories (${LIB_PATHS})

include_directories (${CMAKE_CURRENT_SOURCE_DIR}/Widgets)

set (GI_NAME ${GI_PKG_NAME}-${GI_PKG_VERSION})
set (GIR_FILENAME ${GI_NAME}.gir)

vala_precompile (VALA_C
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
    Widgets/ThinPaned.vala
    Main.vala
    config.vapi
PACKAGES
    ${PKG_DEPS}
GENERATE_HEADER
    ${PKG_NAME}
GENERATE_VAPI
    ${PKG_NAME}
OPTIONS
    --thread
)

install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}.vapi DESTINATION ${CMAKE_INSTALL_PREFIX}/share/vala/vapi)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/${PKG_NAME}.deps DESTINATION ${CMAKE_INSTALL_PREFIX}/share/vala/vapi)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}.h DESTINATION ${CMAKE_INSTALL_PREFIX}/include/${PKG_NAME})
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/Widgets/widgets-utils.h DESTINATION ${CMAKE_INSTALL_PREFIX}/include/${PKG_NAME})

set (LIB_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/Widgets/widgets-utils.c
    ${CMAKE_CURRENT_SOURCE_DIR}/Widgets/close-button.c
    ${VALA_C})

add_library (${PKG_NAME} SHARED ${LIB_FILES})

target_link_libraries (${PKG_NAME} ${LIBS} -lm)

set_target_properties (${PKG_NAME} PROPERTIES
    VERSION ${PKG_SOVERSION}.${PKG_SOMINOR}
    SOVERSION ${PKG_SOVERSION})

install (TARGETS ${PKG_NAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/)

###########################
# GObject Introspection
###########################

include (FindGObjectIntrospection)

if (INTROSPECTION_FOUND)
    include (GObjectIntrospectionMacros)
    add_target_gir (${PKG_NAME} ${GI_PKG_NAME} ${PKG_NAME}.h "${VALA_C}" "${DEPS_CFLAGS}" ${GI_PKG_VERSION} ${GI_PKG_DEPS})
endif ()
