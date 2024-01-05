
include(${CMAKE_CURRENT_LIST_DIR}/Utility.cmake)

function(add_cpp_library_example example_name)
    # Args:
    set(options "")
    set(params "STATIC;SHARED;HEADER_ONLY")
    set(lists "HEADERS;SOURCES;DEPENDENCIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    string(SHA1 bdir_hash "${CMAKE_CURRENT_BINARY_DIR}")
    fatal_if_none_is_def("Provide SHARED, STATIC or HEADER_ONLY library target!" 
                         ARG_STATIC ARG_SHARED ARG_HEADER_ONLY)
    if(ARG_SHARED AND TARGET ${ARG_SHARED})
        set(library_name ${ARG_SHARED})
    elseif(ARG_STATIC AND TARGET ${ARG_STATIC})
        set(library_name ${ARG_STATIC})
    elseif(ARG_HEADER_ONLY AND TARGET ${ARG_HEADER_ONLY})
        set(library_name ${ARG_HEADER_ONLY})
    endif()
    fatal_ifndef("You must provide a list of example source files." ARG_SOURCES)
    #
    add_executable(${example_name} ${ARG_SOURCES} ${ARG_HEADERS})
    target_link_libraries(${example_name} PRIVATE ${library_name} ${ARG_DEPENDENCIES})
    if(WIN32)
        set_target_properties(${example_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${example_name}")
        add_custom_command(TARGET ${example_name} POST_BUILD 
            COMMAND ${CMAKE_COMMAND} -E touch $<TARGET_FILE_DIR:${example_name}>/.dummy.txt
            COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:${example_name}> $<TARGET_FILE_DIR:${example_name}>/.dummy.txt $<TARGET_FILE_DIR:${example_name}>
            COMMAND_EXPAND_LISTS)
    endif()
endfunction()

function(add_cpp_library_basic_examples)
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
    elseif(ARG_STATIC AND TARGET ${ARG_STATIC})
        set(library_name ${ARG_STATIC})
    elseif(ARG_HEADER_ONLY AND TARGET ${ARG_HEADER_ONLY})
        set(library_name ${ARG_HEADER_ONLY})
    endif()
    fatal_ifndef("You must provide a list of example source files." ARG_SOURCES)
    #
    foreach(filename ${ARG_SOURCES})
        get_filename_component(example_prog ${filename} NAME_WE)
        add_executable(${example_prog} ${filename})
        target_link_libraries(${example_prog} PRIVATE ${library_name} ${ARG_DEPENDENCIES})
        if(WIN32)
            set_target_properties(${example_prog} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${example_prog}")
            add_custom_command(TARGET ${example_prog} POST_BUILD 
                              COMMAND ${CMAKE_COMMAND} -E touch $<TARGET_FILE_DIR:${example_prog}>/.dummy.txt
                              COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:${example_prog}> $<TARGET_FILE_DIR:${example_prog}>/.dummy.txt $<TARGET_FILE_DIR:${example_prog}>
                              COMMAND_EXPAND_LISTS)
        endif()
    endforeach()
endfunction()
