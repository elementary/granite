find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.11.3" MINIMUM)
include(ValaPrecompile)

include_directories(${CMAKE_CURRENT_BINARY_DIR}/../lib/)

# pkgconfig, real C code

set(CMAKE_INCLUDE_CURRENT_DIR ON)
# TODO: configure_file(config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)

find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED gtk+-3.0)

set(CFLAGS ${DEPS_CFLAGS} ${DEPS_CFLAGS_OTHER} )
set(LIB_PATHS ${DEPS_LIBRARY_DIRS})

link_directories(${LIB_PATHS} ${CMAKE_CURRENT_BINARY_DIR}/../lib/)
add_definitions(${CFLAGS})

vala_precompile(VALA_C
    main.vala
CUSTOM_VAPIS
    ${CMAKE_CURRENT_BINARY_DIR}/../lib/granite.vapi
PACKAGES
    gtk+-3.0
OPTIONS
    --thread
)
add_executable(demo ${VALA_C})
target_link_libraries(demo granite ${DEPS_LIBRARIES})
