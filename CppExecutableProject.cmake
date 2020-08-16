
include(${CMAKE_CURRENT_LIST_DIR}/CppProject.cmake)

function(add_cpp_executable executable_name)
    include(GNUInstallDirs)
    # Args:
    set(options "")
    set(params "CXX_STANDARD;INCLUDE_DIRECTORIES;INPUT_VERSION_HEADER;OUTPUT_VERSION_HEADER;"
                "RUNTIME_OUTPUT_DIRECTORY")
    set(lists "HEADERS;SOURCES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    if(NOT ARG_HEADERS)
        message(FATAL_ERROR "You must provide header files (HEADERS).")
    endif()
    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "You must provide source files (SOURCES).")
    endif()
    # Generate header version file, if wanted:
    if(ARG_OUTPUT_VERSION_HEADER)
        generate_version_header(INPUT_VERSION_HEADER ${ARG_INPUT_VERSION_HEADER}
                                OUTPUT_VERSION_HEADER ${PROJECT_BINARY_DIR}/include/${executable_name}/${ARG_OUTPUT_VERSION_HEADER})
    endif()
    # Build executable:
    add_executable(${executable_name} ${ARG_HEADERS} ${ARG_SOURCES})
    if(ARG_CXX_STANDARD)
        target_compile_features(${executable_name} PUBLIC cxx_std_${ARG_CXX_STANDARD})
    endif()
    target_include_directories(${executable_name} PUBLIC $<INSTALL_INTERFACE:include>)
    foreach(include_dir ${ARG_INCLUDE_DIRECTORIES})
        target_include_directories(${executable_name} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/${include_dir}>)
    endforeach()
    target_include_directories(${executable_name} PUBLIC $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>)
    set_target_properties(${executable_name} PROPERTIES DEBUG_POSTFIX "-d")
    if(ARG_RUNTIME_OUTPUT_DIRECTORY)
        set_target_properties(${executable_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${ARG_RUNTIME_OUTPUT_DIRECTORY})
    endif()
endfunction()
