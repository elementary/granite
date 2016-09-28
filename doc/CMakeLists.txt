# Serialize deps packages for valadoc
foreach (pkg ${PKG_DEPS})
    list (APPEND VALADOC_PKG_OPTS "--pkg=${pkg}")
endforeach ()

# Source files to scan
set (SRC_DIR "${CMAKE_SOURCE_DIR}/lib")
file (GLOB SRC_FILES ${SRC_DIR}/*.vala ${SRC_DIR}/*/*.vala)

set (BASE_VALADOC_COMMAND
    valadoc
    ${VALADOC_PKG_OPTS}
    ${SRC_FILES}
    --vapidir=${SRC_DIR}
    --pkg config
    --verbose
    --target-glib=2.32
    --package-name=${PKG_NAME}
    --package-version=${PKG_VERSION})

#########################
# C API Documentation
#########################

add_custom_target (cdocs)
add_dependencies (cdocs ${PKG_NAME}) # we need the lib's C header file, and thus valac must run first

set (C_API_DOC_DIR ${CMAKE_CURRENT_BINARY_DIR}/cdocs)

add_custom_command (TARGET cdocs COMMAND rm ${C_API_DOC_DIR} -R -f) # delete previous files
add_custom_command (TARGET cdocs COMMAND ${BASE_VALADOC_COMMAND} ${VALADOC_PKG_OPTS} -o ${C_API_DOC_DIR}
    --doclet-arg=${CMAKE_BINARY_DIR}/lib/${PKG_NAME}.h --doclet=gtkdoc)

#########################
# Vala API documentation
#########################

add_custom_target (valadocs)
set (VALA_API_DOC_DIR "${CMAKE_CURRENT_BINARY_DIR}/valadocs")

add_custom_command (TARGET valadocs COMMAND rm ${CMAKE_CURRENT_BINARY_DIR}/images -R -f)
add_custom_command (TARGET valadocs COMMAND cp ${CMAKE_SOURCE_DIR}/doc/images/ ${CMAKE_CURRENT_BINARY_DIR}/images -R)

add_custom_command (TARGET valadocs COMMAND rm ${VALA_API_DOC_DIR} -R -f) # delete previous files
add_custom_command (TARGET valadocs COMMAND ${BASE_VALADOC_COMMAND} --doclet=html -o ${VALA_API_DOC_DIR})

#########################
# All the documents
#########################

add_custom_target (docs)
add_dependencies (docs cdocs valadocs)
