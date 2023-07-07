
include(${CMAKE_CURRENT_LIST_DIR}/CppProject.cmake)

function(add_cpp_executable executable_target)
    include(GNUInstallDirs)
    # Args:
    set(options "")
    set(params "MAIN;OBJECT;CXX_STANDARD;HEADERS_BASE_DIRS;BUILD_HEADERS_BASE_DIRS;"
                "RUNTIME_OUTPUT_DIRECTORY")
    set(lists "HEADERS;SOURCES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    fatal_ifndef("You must provide source files (SOURCES)." ARG_SOURCES)
    fatal_ifndef("You must provide a main source file (MAIN)." ARG_MAIN)
    # Build executable:
    if(ARG_OBJECT)
        add_library(${ARG_OBJECT} OBJECT ${ARG_SOURCES})
        add_executable(${executable_target} ${ARG_MAIN})
        target_link_libraries(${executable_target} PRIVATE ${ARG_OBJECT})
        set(current_target ${ARG_OBJECT})
    else()
        add_executable(${executable_target} ${ARG_SOURCES} ${ARG_MAIN})
        set(current_target ${executable_target})
    endif()
    target_default_warning_options(${current_target})
    if(ARG_CXX_STANDARD)
        target_compile_features(${current_target} PUBLIC cxx_std_${ARG_CXX_STANDARD})
    endif()
    if(ARG_HEADERS)
        set_ifndef(ARG_HEADERS_BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
        set_ifndef(ARG_BUILD_HEADERS_BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
        target_sources(${current_target} PUBLIC FILE_SET HEADERS BASE_DIRS ${ARG_HEADERS_BASE_DIRS} ${ARG_BUILD_HEADERS_BASE_DIRS} FILES ${ARG_HEADERS})
    endif()
    set_target_properties(${current_target} PROPERTIES DEBUG_POSTFIX "-d")
    if(ARG_RUNTIME_OUTPUT_DIRECTORY)
        set_target_properties(${current_target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${ARG_RUNTIME_OUTPUT_DIRECTORY})
    endif()
endfunction()
