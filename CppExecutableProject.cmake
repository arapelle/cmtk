
include(${CMAKE_CURRENT_LIST_DIR}/CppProject.cmake)

function(add_cpp_executable executable_name)
    include(GNUInstallDirs)
    # Args:
    set(options "")
    set(params "CXX_STANDARD;HEADERS_BASE_DIRS;BUILD_HEADERS_BASE_DIRS;"
                "RUNTIME_OUTPUT_DIRECTORY")
    set(lists "HEADERS;SOURCES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "You must provide source files (SOURCES).")
    endif()
    # Build executable:
    add_executable(${executable_name} ${ARG_SOURCES})
    target_default_warning_options(${executable_name})
    if(ARG_CXX_STANDARD)
        target_compile_features(${executable_name} PUBLIC cxx_std_${ARG_CXX_STANDARD})
    endif()
    if(ARG_HEADERS)
        set_ifndef(ARG_HEADERS_BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
        set_ifndef(ARG_BUILD_HEADERS_BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
        target_sources(${executable_name} PUBLIC FILE_SET HEADERS BASE_DIRS ${ARG_HEADERS_BASE_DIRS} ${ARG_BUILD_HEADERS_BASE_DIRS} FILES ${ARG_HEADERS})
    endif()
    set_target_properties(${executable_name} PROPERTIES DEBUG_POSTFIX "-d")
    if(ARG_RUNTIME_OUTPUT_DIRECTORY)
        set_target_properties(${executable_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${ARG_RUNTIME_OUTPUT_DIRECTORY})
    endif()
endfunction()
