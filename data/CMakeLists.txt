file (GLOB _cssfiles "${CMAKE_CURRENT_SOURCE_DIR}/style/*.css")
install (FILES ${_cssfiles}  DESTINATION share/granite/style)
