
include(${CMAKE_CURRENT_LIST_DIR}/Utility.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/FindOrFetchGTest.cmake)

function(add_cpp_library_test test_name gtest_target)
    # Args:
    set(options "")
    set(params "STATIC;SHARED;HEADER_ONLY")
    set(lists "HEADERS;SOURCES;LIBRARIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 2 "ARG" "${options}" "${params}" "${lists}")
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
    fatal_ifndef("You must provide a list of test source files." ARG_SOURCES)
    #
    add_executable(${test_name} ${ARG_SOURCES} ${ARG_HEADERS})
    target_link_libraries(${test_name} PRIVATE ${library_name} ${ARG_DEPENDENCIES} ${gtest_target})
    if(WIN32)
        set_target_properties(${test_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${test_name}")
        add_custom_command(TARGET ${test_name} POST_BUILD 
            COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:${test_name}> $<TARGET_FILE_DIR:${test_name}>
            COMMAND_EXPAND_LISTS)
    endif()
    gtest_discover_tests(${test_name} TEST_PREFIX ${library_name}::)
endfunction()

function(add_cpp_library_basic_tests gtest_target)
    # Args:
    set(options "")
    set(params "STATIC;SHARED;HEADER_ONLY")
    set(lists "SOURCES;LIBRARIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
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
    fatal_ifndef("You must provide a list of test source files." ARG_SOURCES)
    #
    foreach(filename ${ARG_SOURCES})
        get_filename_component(test_prog ${filename} NAME_WE)
        set(test_prog "${library_name}-${test_prog}")
        add_executable(${test_prog} ${filename})
        target_link_libraries(${test_prog} PRIVATE ${library_name} ${ARG_DEPENDENCIES} ${gtest_target})
        if(WIN32)
            set_target_properties(${test_prog} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${test_prog}")
            add_custom_command(TARGET ${test_prog} POST_BUILD 
                              COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:${test_prog}> $<TARGET_FILE_DIR:${test_prog}>
                              COMMAND_EXPAND_LISTS)
        endif()
        gtest_discover_tests(${test_prog} TEST_PREFIX ${library_name}::)
    endforeach()
endfunction()
