
include(${CMAKE_CURRENT_LIST_DIR}/Utility.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/FindOrFetchGTest.cmake)

function(add_cpp_executable_test test_name gtest_target)
    # Args:
    set(options "")
    set(params "OBJECT")
    set(lists "HEADERS;SOURCES;LIBRARIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 2 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    fatal_if_none_is_def("Provide OBJECT target!" ARG_OBJECT)
    fatal_ifndef("You must provide a list of test source files." ARG_SOURCES)
    #
    add_executable(${test_name} ${ARG_SOURCES} ${ARG_HEADERS})
    target_link_libraries(${test_name} PRIVATE ${ARG_OBJECT} ${ARG_DEPENDENCIES} ${gtest_target})
    if(WIN32)
        set_target_properties(${test_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${test_name}")
        add_custom_command(TARGET ${test_name} POST_BUILD 
                           COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:${test_name}> $<TARGET_FILE_DIR:${test_name}>
                           COMMAND_EXPAND_LISTS)
    endif()
    gtest_discover_tests(${test_name} TEST_PREFIX ${test_prog}::)
endfunction()

function(add_cpp_executable_basic_tests gtest_target)
    # Args:
    set(options "")
    set(params "OBJECT")
    set(lists "SOURCES;LIBRARIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    fatal_if_none_is_def("Provide OBJECT target!" ARG_OBJECT)
    fatal_ifndef("You must provide a list of test source files." ARG_SOURCES)
    foreach(filename ${ARG_SOURCES})
        get_filename_component(test_prog ${filename} NAME_WE)
        add_executable(${test_prog} ${filename})
        target_link_libraries(${test_prog} PRIVATE ${ARG_OBJECT} ${ARG_DEPENDENCIES} ${gtest_target})
        if(WIN32)
            set_target_properties(${test_prog} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${test_prog}")
            add_custom_command(TARGET ${test_prog} POST_BUILD 
                               COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:${test_prog}> $<TARGET_FILE_DIR:${test_prog}>
                               COMMAND_EXPAND_LISTS)
        endif()
        gtest_discover_tests(${test_prog} TEST_PREFIX ${test_prog}::)
    endforeach()
endfunction()
