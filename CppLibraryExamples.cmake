
include(${CMAKE_CURRENT_LIST_DIR}/Utility.cmake)

function(add_cpp_library_examples)
    # Args:
    set(options "")
    set(params "STATIC;SHARED")
    set(lists "SOURCES;DEPENDENCIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    if(NOT ARG_STATIC AND NOT ARG_SHARED)
        message(FATAL_ERROR "Provide SHARED or STATIC library target!")
    elseif(ARG_SHARED AND TARGET ${ARG_SHARED})
        set(library_name ${ARG_SHARED})
    elseif(ARG_STATIC AND TARGET ${ARG_STATIC})
        set(library_name ${ARG_STATIC})
    else()
        message(FATAL_ERROR "No SHARED or STATIC library target found!")
    endif()
    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "You must provide a list of example source files.")
    endif()
    #
    foreach(filename ${ARG_SOURCES})
        get_filename_component(example_prog ${filename} NAME_WE)
        add_executable(${example_prog} ${filename})
        target_link_libraries(${example_prog} PRIVATE ${library_name} ${ARG_DEPENDENCIES})
    endforeach()
endfunction()
