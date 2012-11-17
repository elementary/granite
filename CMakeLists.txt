# Check http://webdev.elementaryos.org/docs/developer-guide/cmake for documentation

cmake_minimum_required (VERSION 2.6)
cmake_policy (VERSION 2.6)
project (granite)

set (PKG_NAME ${CMAKE_PROJECT_NAME})
set (PKG_DESC_NAME Granite)
set (PKG_VERSION 0.2)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/)

set (RESOURCES_DIR ${CMAKE_INSTALL_PREFIX}/share/${PKG_NAME}/)
set (GETTEXT_PACKAGE ${PKG_NAME})

set (CPACK_PACKAGE_VERSION ${PKG_VERSION})
set (CPACK_SOURCE_GENERATOR "TGZ")
set (CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")
set (CPACK_SOURCE_IGNORE_FILES "/build/;/.bzr/;/.bzrignore;~$;${CPACK_SOURCE_IGNORE_FILES}")

include (CPack)
add_custom_target (dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

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
    gee-1.0)

set (PKG_DEPS_CHECK
    gtk+-3.0>=3.3.14
    gio-unix-2.0
    gthread-2.0
    gee-1.0)

add_subdirectory (lib)
add_subdirectory (doc)
add_subdirectory (po)
add_subdirectory (demo)
add_subdirectory (icons)

