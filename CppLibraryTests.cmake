
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
    if(NOT ARG_STATIC AND NOT ARG_SHARED AND NOT ARG_HEADER_ONLY)
        message(FATAL_ERROR "Provide SHARED, STATIC or HEADER_ONLY library target!")
    elseif(ARG_SHARED AND TARGET ${ARG_SHARED})
        set(library_name ${ARG_SHARED})
        if(WIN32 AND NOT TARGET copy_dll_${library_name})
            add_custom_target(copy_dll_${library_name} ALL
                ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${library_name}> ${CMAKE_CURRENT_BINARY_DIR})
        endif()
    elseif(ARG_STATIC AND TARGET ${ARG_STATIC})
        set(library_name ${ARG_STATIC})
    elseif(ARG_HEADER_ONLY AND TARGET ${ARG_HEADER_ONLY})
        set(library_name ${ARG_HEADER_ONLY})
    endif()
    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "You must provide a list of test source files.")
    endif()
    #
    add_executable(${test_name} ${ARG_SOURCES} ${ARG_HEADERS})
    target_link_libraries(${test_name} PRIVATE ${library_name} ${ARG_DEPENDENCIES} ${gtest_target})
    if(WIN32 AND TARGET copy_dll_${library_name})
        add_dependencies(${test_name} copy_dll_${library_name})
    endif()
    gtest_discover_tests(${test_name} TEST_PREFIX ${test_prog}::)
endfunction()

function(add_cpp_library_basic_tests gtest_target)
    # Args:
    set(options "")
    set(params "STATIC;SHARED;HEADER_ONLY")
    set(lists "SOURCES;LIBRARIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    if(NOT ARG_STATIC AND NOT ARG_SHARED AND NOT ARG_HEADER_ONLY)
        message(FATAL_ERROR "Provide SHARED, STATIC or HEADER_ONLY library target!")
    elseif(ARG_SHARED AND TARGET ${ARG_SHARED})
        set(library_name ${ARG_SHARED})
        if(WIN32 AND NOT TARGET copy_dll_${library_name})
            add_custom_target(copy_dll_${library_name} ALL
                ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${library_name}> ${CMAKE_CURRENT_BINARY_DIR})
        endif()
    elseif(ARG_STATIC AND TARGET ${ARG_STATIC})
        set(library_name ${ARG_STATIC})
    elseif(ARG_HEADER_ONLY AND TARGET ${ARG_HEADER_ONLY})
        set(library_name ${ARG_HEADER_ONLY})
    endif()
    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "You must provide a list of test source files.")
    endif()
    foreach(filename ${ARG_SOURCES})
        get_filename_component(test_prog ${filename} NAME_WE)
        add_executable(${test_prog} ${filename})
        target_link_libraries(${test_prog} PRIVATE ${library_name} ${ARG_DEPENDENCIES} ${gtest_target})
        if(WIN32 AND TARGET copy_dll_${library_name})
            add_dependencies(${test_prog} copy_dll_${library_name})
        endif()
        gtest_discover_tests(${test_prog} TEST_PREFIX ${test_prog}::)
    endforeach()
endfunction()
#       if(WIN32 AND ARG_SHARED AND TARGET ${ARG_SHARED})
#            add_custom_command(TARGET ${test_prog} POST_BUILD
## If needed one day: COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:${test_prog}> $<TARGET_FILE_DIR:${test_prog}>
#              COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${library_name}> $<TARGET_FILE_DIR:${test_prog}>
#              COMMAND_EXPAND_LISTS
#            )
#       endif()
