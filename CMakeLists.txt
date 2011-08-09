# Check http://webdev.elementaryos.org/docs/developer-guide/cmake for documentation

cmake_minimum_required (VERSION 2.6)
cmake_policy(VERSION 2.6)

project(granite)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala )
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/gobject-introspection )
set(RESOURCES_DIR ${CMAKE_INSTALL_PREFIX}/share/granite/)
set(GETTEXT_PACKAGE GRANITE)
configure_file (${CMAKE_SOURCE_DIR}/lib/config.h.cmake ${CMAKE_BINARY_DIR}/lib/config.h)

set(CPACK_PACKAGE_VERSION "0.1.1")
set(CPACK_SOURCE_GENERATOR "TBZ2")
set(CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")
set(CPACK_SOURCE_IGNORE_FILES "/build/;/.bzr/;/.bzrignore;~$;${CPACK_SOURCE_IGNORE_FILES}")
include(CPack)

add_custom_target(dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

add_subdirectory (lib)
add_subdirectory (po)
add_subdirectory (data)
