set (PKGNAME granite)
set (PKGNAME_ GRANITE)
set (${PKGNAME_}_VERSION 0.1.1) # increase when you break the API
set (${PKGNAME_}_SOVERSION 0) # Increase when you add functionality
#
# granite.pc
#
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$") # You hear that? It's kittens being killed by the gods of cmake
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/${PKGNAME}.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}.pc)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}.pc DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig/)

# Check for the deps
find_package(PkgConfig)
set(PKG_DEPS gtk+-3.0 gio-unix-2.0)
pkg_check_modules(DEPS REQUIRED ${PKG_DEPS})

# Link all
set(CFLAGS ${DEPS_CFLAGS} ${DEPS_CFLAGS_OTHER})
add_definitions(${CFLAGS} "-DGETTEXT_PACKAGE=\"GRANITE\"")

set(LIBS
	${DEP_LIBRARIES}
)
link_libraries(${LIBS})

set(LIB_PATHS
	${DEPS_LIBRARY_DIRS}
)
link_directories(${LIB_PATHS})

#VALA stuff
find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.12.0" MINIMUM)

include(ValaPrecompile)
vala_precompile(VALA_C
    Widgets/ModeButton.vala
    Widgets/DatePicker.vala
    Widgets/Entries.vala
    Widgets/TimePicker.vala
    Widgets/CollapsiblePaned.vala
    Widgets/CompositedWindow.vala
    Widgets/AppMenu.vala
    Widgets/Welcome.vala
    Widgets/ToolButtonWithMenu.vala
    Services/Settings.vala
    Services/Logger.vala
    Services/Paths.vala
    Services/System.vala
    AppFactory.vala
    Application.vala
    Drawing/Color.vala
    Drawing/BufferSurface.vala
    Drawing/Utilities.vala
    config.vapi
PACKAGES
    ${PKG_DEPS}
    posix
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
    ${VALA_C}
)

if(BUILD_STATIC MATCHES "Yes")
ADD_LIBRARY(${PKGNAME}-static STATIC ${VALA_C})
# The library target "foo" already has a default OUTPUT_NAME of "foo", so we don't need to change it.
# The library target "foo-static" has a default OUTPUT_NAME of "foo-static", so change it.
SET_TARGET_PROPERTIES(${PKGNAME}-static PROPERTIES OUTPUT_NAME ${PKGNAME})
install (TARGETS ${PKGNAME}-static DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/)
endif(BUILD_STATIC MATCHES "Yes")

set_target_properties (${PKGNAME} PROPERTIES
    VERSION ${GRANITE_VERSION}
    SOVERSION ${GRANITE_SOVERSION}
                       )


install (TARGETS ${PKGNAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/)

add_custom_target(docs)
add_custom_command (TARGET docs COMMAND rm ${CMAKE_CURRENT_BINARY_DIR}/docs -R -f)
add_custom_command (TARGET docs COMMAND valadoc -o docs --doclet-arg=${CMAKE_CURRENT_BINARY_DIR}/granite.h ${CMAKE_CURRENT_SOURCE_DIR}/*/*.vala ${CMAKE_CURRENT_SOURCE_DIR}/*.vapi ${CMAKE_CURRENT_SOURCE_DIR}/*.vala --pkg=posix --pkg=gtk+-3.0 --pkg=gio-unix-2.0 --package-name=granite --package-version=0.1.1 --doclet=gtkdoc)

add_custom_target (valadocs)
add_custom_command (TARGET valadocs COMMAND rm ${CMAKE_CURRENT_BINARY_DIR}/docs_vala -R -f)
add_custom_command (TARGET valadocs COMMAND VALADOC_HEADER=${CMAKE_CURRENT_SOURCE_DIR}/docs/header.html valadoc -o docs_vala ${CMAKE_CURRENT_SOURCE_DIR}/*/*.vala ${CMAKE_CURRENT_SOURCE_DIR}/*.vapi ${CMAKE_CURRENT_SOURCE_DIR}/*.vala --pkg=posix --pkg=gtk+-3.0 --pkg=gio-unix-2.0 --package-name=Granite --package-version=0.1.1 --force)
