set (PKGNAME granite)
set (PKGNAME_ GRANITE)
set (${PKGNAME_}_VERSION 0.2)

# increase when you break the API
set (${PKGNAME_}_SOVERSION 1)

# Increase when you add functionality
set (${PKGNAME_}_SOMINOR 0.1)

#

# granite.pc

#

set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$")
# You hear that? It's kittens being killed by the gods of cmake

configure_file (${CMAKE_CURRENT_SOURCE_DIR}/${PKGNAME}.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}.pc)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}.pc DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig/)
# Check for the deps

find_package(PkgConfig)
find_package(GObjectIntrospection 0.9.12)

set(PKG_DEPS gtk+-3.0 gio-unix-2.0)

pkg_check_modules(DEPS REQUIRED
    gtk+-3.0>=3.3.14
    gio-unix-2.0
    gthread-2.0
    gee-1.0)

# Link all

set(CFLAGS ${DEPS_CFLAGS} ${DEPS_CFLAGS_OTHER})
add_definitions(${CFLAGS} "-DGETTEXT_PACKAGE=\"granite\"")
set(LIBS
    ${DEPS_LIBRARIES}
)
set(LIB_PATHS
    ${DEPS_LIBRARY_DIRS}
)
link_directories(${LIB_PATHS})
#VALA stuff

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/Widgets/)
find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.16.0" MINIMUM)
include(ValaPrecompile)
vala_precompile(VALA_C
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
    posix
    gee-1.0
OPTIONS
    --thread
GENERATE_VAPI
    granite
GENERATE_HEADER
    granite
)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/granite.vapi DESTINATION ${CMAKE_INSTALL_PREFIX}/share/vala/vapi/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/granite.deps DESTINATION ${CMAKE_INSTALL_PREFIX}/share/vala/vapi/)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/granite.h DESTINATION ${CMAKE_INSTALL_PREFIX}/include/granite/)
add_library (${PKGNAME} SHARED    
    Widgets/close-button.c
    ${VALA_C}
)
target_link_libraries(${PKGNAME} ${LIBS} -lm)
if(BUILD_STATIC MATCHES "Yes")
ADD_LIBRARY(${PKGNAME}-static STATIC ${VALA_C})
target_link_libraries(${PKGNAME}-static ${LIBS})
# The library target "foo" already has a default OUTPUT_NAME of "foo", so we don't need to change it.

# The library target "foo-static" has a default OUTPUT_NAME of "foo-static", so change it.

SET_TARGET_PROPERTIES(${PKGNAME}-static PROPERTIES OUTPUT_NAME ${PKGNAME})
install (TARGETS ${PKGNAME}-static DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/)
endif(BUILD_STATIC MATCHES "Yes")
set_target_properties (${PKGNAME} PROPERTIES
    VERSION ${GRANITE_SOVERSION}.${GRANITE_SOMINOR}
    SOVERSION ${GRANITE_SOVERSION}
                       )
install (TARGETS ${PKGNAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/)

macro(_list_prefix _outvar _listvar _prefix)
  set(${_outvar})
  foreach(_item IN LISTS ${_listvar})
    list(APPEND ${_outvar} ${_prefix}${_item})
  endforeach()
endmacro(_list_prefix)

# GObject Introspection
if(INTROSPECTION_FOUND)
  include(GObjectIntrospectionMacros)
  add_target_gir(granite Granite granite.h "${VALA_C}" "${DEPS_CFLAGS}" 1.0 Gtk-3.0)
endif()

add_custom_target(docs)
add_custom_command (TARGET docs COMMAND rm ${CMAKE_CURRENT_BINARY_DIR}/docs -R -f)
add_custom_command (TARGET docs COMMAND valadoc -o docs --doclet-arg=${CMAKE_CURRENT_BINARY_DIR}/granite.h ${CMAKE_CURRENT_SOURCE_DIR}/*/*.vala ${CMAKE_CURRENT_SOURCE_DIR}/*.vapi ${CMAKE_CURRENT_SOURCE_DIR}/*.vala --pkg=posix --pkg=gtk+-3.0 --pkg=gee-1.0 --pkg=gio-unix-2.0 --package-name=granite --package-version=0.1.1 --doclet=gtkdoc)
add_custom_target (valadocs)
add_custom_command (TARGET valadocs COMMAND rm ${CMAKE_CURRENT_BINARY_DIR}/docs_vala -R -f)
add_custom_command (TARGET valadocs COMMAND rm ${CMAKE_CURRENT_BINARY_DIR}/images -R -f)
add_custom_command (TARGET valadocs COMMAND cp ${CMAKE_SOURCE_DIR}/doc/images/ ${CMAKE_CURRENT_BINARY_DIR}/images -R)
add_custom_command (TARGET valadocs COMMAND VALADOC_HEADER=${CMAKE_CURRENT_SOURCE_DIR}/docs/header.html valadoc -o docs_vala ${CMAKE_CURRENT_SOURCE_DIR}/*/*.vala ${CMAKE_CURRENT_SOURCE_DIR}/*.vapi ${CMAKE_CURRENT_SOURCE_DIR}/*.vala --pkg=glib-2.0 --pkg=gio-2.0 --pkg=posix --pkg=gtk+-3.0 --pkg=gee-1.0 --pkg=gio-unix-2.0 --package-name=${PKGNAME} --package-version=${GRANITE_VERSION} --force --doclet=html)

