# Check http://webdev.elementaryos.org/docs/developer-guide/cmake for documentation

cmake_minimum_required (VERSION 2.8)
cmake_policy (VERSION 2.8)
project (granite C)

set (PKG_NAME ${CMAKE_PROJECT_NAME})
set (PKG_VERSION 0.5)
set (API_VERSION 1.0)

# Used to create GObject introspection files
set (PKG_GIR_NAME Granite)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/)

set (RESOURCES_DIR ${CMAKE_INSTALL_PREFIX}/share/${PKG_NAME}/)
set (GETTEXT_PACKAGE ${PKG_NAME})

set (CPACK_PACKAGE_VERSION ${PKG_VERSION})
set (CPACK_SOURCE_GENERATOR "TGZ")
set (CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")
set (CPACK_SOURCE_IGNORE_FILES "/build/;/.bzr/;/.bzrignore;~$;${CPACK_SOURCE_IGNORE_FILES}")

include (CPack)
add_custom_target (dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

find_package (Vala REQUIRED)
include (ValaVersion)
include (ValaPrecompile)

ensure_vala_version ("0.23.2" MINIMUM)

#
# Packages in PKG_DEPS are used with the vala compiler and other related tools (not versioned.)
# Packages in PKG_DEPS_CHECK are used with PKG-Config and for linking, etc. They can contain versions.
#
# Both should contain *the same packages*, except for those whose VAPI file has a different name. In
# such case, PKG_DEPS would use the name of the VAPI, and PKG_DEPS_CHECK would use the name of the
# package known by pkg-config.
#
set (PKG_DEPS
    gtk+-3.0
    gio-unix-2.0
    posix
    gee-0.8)

set (PKG_DEPS_CHECK
    gtk+-3.0>=3.14
    gio-unix-2.0
    gthread-2.0
    gee-0.8)

# GI dependencies
set (GI_PKG_DEPS Gtk-3.0 Gee-0.8)

# Check for the deps
find_package (PkgConfig)
pkg_check_modules (DEPS REQUIRED ${PKG_DEPS_CHECK})

set (VALAC_OPTIONS
     --thread
     --target-glib=2.32)

if (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set (VALAC_OPTIONS ${VALAC_OPTIONS} --define=LINUX)
elseif (${CMAKE_SYSTEM_NAME} MATCHES "DragonFly")
    set (VALAC_OPTIONS ${VALAC_OPTIONS} --define=DRAGON_FLY)
elseif (${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD")
    set (VALAC_OPTIONS ${VALAC_OPTIONS} --define=FFREE_BSD)
elseif (${CMAKE_SYSTEM_NAME} MATCHES "NetBSD")
    set (VALAC_OPTIONS ${VALAC_OPTIONS} --define=NET_BSD)
elseif (${CMAKE_SYSTEM_NAME} MATCHES "OpenBSD")
    set (VALAC_OPTIONS ${VALAC_OPTIONS} --define=OPEN_BSD)
endif ()

add_subdirectory (lib)
add_subdirectory (demo)
add_subdirectory (doc)
add_subdirectory (po)
add_subdirectory (icons)
