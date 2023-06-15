
include(${CMAKE_CURRENT_LIST_DIR}/Utility.cmake)

function(add_cpp_library_examples)
    # Args:
    set(options "")
    set(params "STATIC;SHARED;HEADER_ONLY")
    set(lists "SOURCES;DEPENDENCIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    string(SHA1 bdir_hash "${CMAKE_CURRENT_BINARY_DIR}")
    fatal_if_none_is_def("Provide SHARED, STATIC or HEADER_ONLY library target!" 
                         ARG_STATIC ARG_SHARED ARG_HEADER_ONLY)
    if(ARG_SHARED AND TARGET ${ARG_SHARED})
        set(library_name ${ARG_SHARED})
        if(WIN32 AND NOT TARGET copy_dll_${bdir_hash})
            add_custom_target(copy_dll_${bdir_hash} ALL
                ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${library_name}> ${CMAKE_CURRENT_BINARY_DIR})
        endif()
    elseif(ARG_STATIC AND TARGET ${ARG_STATIC})
        set(library_name ${ARG_STATIC})
    elseif(ARG_HEADER_ONLY AND TARGET ${ARG_HEADER_ONLY})
        set(library_name ${ARG_HEADER_ONLY})
    endif()
    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "You must provide a list of example source files.")
    endif()
    #
    foreach(filename ${ARG_SOURCES})
        get_filename_component(example_prog ${filename} NAME_WE)
        add_executable(${example_prog} ${filename})
        target_link_libraries(${example_prog} PRIVATE ${library_name} ${ARG_DEPENDENCIES})
        if(WIN32 AND TARGET copy_dll_${bdir_hash})
            add_dependencies(${example_prog} copy_dll_${bdir_hash})
        endif()
    endforeach()
endfunction()
