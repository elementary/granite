macro(add_target_gir TARGET_NAME GIR_NAME HEADER CFLAGS GRANITE_VERSION)
    add_custom_target(${TARGET_NAME}-gir ALL DEPENDS ${TARGET_NAME})
    set(PACKAGES "")
    foreach(PKG ${ARGN})
        set(PACKAGES ${PACKAGES} --include=${PKG})
    endforeach()
    add_custom_command(TARGET ${TARGET_NAME}-gir COMMAND LD_LIBRARY_PATH="${CMAKE_CURRENT_BINARY_DIR}" g-ir-scanner ${CFLAGS} -n ${GIR_NAME} --quiet --library ${PKGNAME} ${PACKAGES} -o ${GIR_NAME}-${GRANITE_VERSION}.gir --nsversion=${GRANITE_VERSION} ${HEADER}
        COMMENT "Generating ${GIR_NAME}-${GRANITE_VERSION}.gir")
    add_custom_command(TARGET ${TARGET_NAME}-gir COMMAND g-ir-compiler ${GIR_NAME}-${GRANITE_VERSION}.gir -o ${GIR_NAME}-${GRANITE_VERSION}.typelib
        COMMENT "Generating ${GIR_NAME}-${GRANITE_VERSION}.typelib")
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${GRANITE_VERSION}.gir DESTINATION share/gir-1.0/)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${GRANITE_VERSION}.typelib DESTINATION lib/girepository-1.0/)
endmacro()
