
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
    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "You must provide a list of test source files.")
    endif()
    #
    add_executable(${test_name} ${ARG_SOURCES} ${ARG_HEADERS})
    target_link_libraries(${test_name} PRIVATE ${ARG_OBJECT} ${ARG_DEPENDENCIES} ${gtest_target})
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
    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "You must provide a list of test source files.")
    endif()
    foreach(filename ${ARG_SOURCES})
        get_filename_component(test_prog ${filename} NAME_WE)
        add_executable(${test_prog} ${filename})
        target_link_libraries(${test_prog} PRIVATE ${ARG_OBJECT} ${ARG_DEPENDENCIES} ${gtest_target})
        gtest_discover_tests(${test_prog} TEST_PREFIX ${test_prog}::)
    endforeach()
endfunction()
