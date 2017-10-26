include_directories (${CMAKE_CURRENT_BINARY_DIR}/../lib)

set (CMAKE_INCLUDE_CURRENT_DIR ON)
set (CFLAGS ${DEPS_CFLAGS} ${DEPS_CFLAGS_OTHER} )
set (LIB_PATHS ${DEPS_LIBRARY_DIRS})

link_directories (${LIB_PATHS} ${CMAKE_CURRENT_BINARY_DIR}/../lib)
add_definitions (${CFLAGS} "-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

set (EXEC_NAME ${PKG_NAME}-demo)

vala_precompile (VALA_C ${EXEC_NAME}
    GraniteDemo.vala
    Views/AlertViewView.vala
    Views/AvatarView.vala
    Views/CSSView.vala
    Views/DateTimePickerView.vala
    Views/DynamicNotebookView.vala
    Views/MessageDialogView.vala
    Views/ModeButtonView.vala
    Views/OverlayBarView.vala
    Views/SeekBarView.vala
    Views/SourceListView.vala
    Views/StorageView.vala
    Views/ToastView.vala
    Views/WelcomeView.vala
    Views/AsyncImageView.vala
    Views/SettingsView/SettingsView.vala
    Views/SettingsView/SettingsPage.vala
    Views/SettingsView/SimpleSettingsPage.vala
CUSTOM_VAPIS
    ${CMAKE_CURRENT_BINARY_DIR}/../lib/${PKG_NAME}.vapi
PACKAGES
    ${PKG_DEPS}
OPTIONS
    ${VALAC_OPTIONS}
)

add_executable (${EXEC_NAME} ${VALA_C})
target_link_libraries (${EXEC_NAME} ${PKG_NAME} ${DEPS_LIBRARIES})
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/granite-demo.desktop DESTINATION share/applications)
