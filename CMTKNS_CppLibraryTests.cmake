
include(${CMAKE_CURRENT_LIST_DIR}/CppProject.cmake)

function(CMTKNS_add_cpp_library_test test_name library_target gtest_target)
    # Args:
    set(options "")
    set(params "DEFAULT_WARNING_OPTIONS;CXX_STANDARD")
    set(lists "HEADERS;SOURCES;DEPENDENCIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    fatal_ifndef("You must provide a list of test source files." ARG_SOURCES)
    set_ifndef(ARG_DEFAULT_WARNING_OPTIONS ON)
    #
    add_executable(${test_name} ${ARG_SOURCES} ${ARG_HEADERS})
    target_link_libraries(${test_name} PRIVATE ${library_target} ${ARG_DEPENDENCIES} ${gtest_target})
    if(${ARG_DEFAULT_WARNING_OPTIONS})
        target_default_warning_options(${test_name})
    endif()
    if(ARG_CXX_STANDARD)
      target_compile_features(${test_name} PRIVATE cxx_std_${ARG_CXX_STANDARD})
    endif()
    if(WIN32)
        set_target_properties(${test_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${test_name}")
        add_custom_command(TARGET ${test_name} POST_BUILD 
            COMMAND ${CMAKE_COMMAND} -E touch $<TARGET_FILE_DIR:${test_name}>/.dummy.txt
            COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:${test_name}> $<TARGET_FILE_DIR:${test_name}>/.dummy.txt $<TARGET_FILE_DIR:${test_name}>
            COMMAND_EXPAND_LISTS)
    endif()
    gtest_discover_tests(${test_name} TEST_PREFIX ${library_target}::)
endfunction()

function(CMTKNS_add_cpp_library_basic_tests library_target gtest_target)
    # Args:
    set(options "")
    set(params "DEFAULT_WARNING_OPTIONS;CXX_STANDARD")
    set(lists "SOURCES;DEPENDENCIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    fatal_ifndef("You must provide a list of test source files." ARG_SOURCES)
    set_ifndef(ARG_DEFAULT_WARNING_OPTIONS ON)
    #
    foreach(filename ${ARG_SOURCES})
        get_filename_component(test_prog ${filename} NAME_WE)
        set(test_prog "${library_target}-${test_prog}")
        add_executable(${test_prog} ${filename})
        target_link_libraries(${test_prog} PRIVATE ${library_target} ${ARG_DEPENDENCIES} ${gtest_target})
        if(${ARG_DEFAULT_WARNING_OPTIONS})
            target_default_warning_options(${test_prog})
        endif()
        if(ARG_CXX_STANDARD)
            target_compile_features(${test_prog} PRIVATE cxx_std_${ARG_CXX_STANDARD})
        endif()
        if(WIN32)
            set_target_properties(${test_prog} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${test_prog}")
            add_custom_command(TARGET ${test_prog} POST_BUILD 
                              COMMAND ${CMAKE_COMMAND} -E touch $<TARGET_FILE_DIR:${test_prog}>/.dummy.txt
                              COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:${test_prog}> $<TARGET_FILE_DIR:${test_prog}>/.dummy.txt $<TARGET_FILE_DIR:${test_prog}>
                              COMMAND_EXPAND_LISTS)
        endif()
        gtest_discover_tests(${test_prog} TEST_PREFIX ${library_target}::)
    endforeach()
endfunction()
