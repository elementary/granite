macro(add_target_gir TARGET_NAME GIR_NAME HEADER C_FILES CFLAGS PKG_VERSION)
    set(PACKAGES "")
    foreach(PKG ${ARGN})
        set(PACKAGES ${PACKAGES} --include=${PKG})
    endforeach()
    install(CODE "set(ENV{LD_LIBRARY_PATH} \"${CMAKE_CURRENT_BINARY_DIR}:\$ENV{LD_LIBRARY_PATH}\")
    execute_process(COMMAND g-ir-scanner ${CFLAGS} -n ${GIR_NAME}
            --library ${PKG_NAME} ${PACKAGES}
            --warn-all
            -o ${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${PKG_VERSION}.gir
            -L${CMAKE_CURRENT_BINARY_DIR}
            --nsversion=${PKG_VERSION} ${CMAKE_CURRENT_BINARY_DIR}/${HEADER} ${C_FILES})")
    install(CODE "execute_process(COMMAND g-ir-compiler ${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${PKG_VERSION}.gir -o ${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${PKG_VERSION}.typelib)")
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${PKG_VERSION}.gir DESTINATION share/gir-1.0/)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${PKG_VERSION}.typelib DESTINATION lib/girepository-1.0/)
endmacro()
