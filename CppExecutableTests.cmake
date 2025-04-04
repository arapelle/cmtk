
include(${CMAKE_CURRENT_LIST_DIR}/CppProject.cmake)

function(add_cpp_executable_test test_name library_target gtest_target)
    # Args:
    set(options "")
    set(params "DEFAULT_WARNING_OPTIONS;DEFAULT_ERROR_OPTIONS;CXX_STANDARD")
    set(lists "HEADERS;SOURCES;DEPENDENCIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 3 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    fatal_ifndef("You must provide a list of test source files." ARG_SOURCES)
    set_ifndef(ARG_DEFAULT_WARNING_OPTIONS ON)
    #
    add_executable(${test_name} ${ARG_SOURCES} ${ARG_HEADERS})
    target_link_libraries(${test_name} PRIVATE ${library_target} ${ARG_DEPENDENCIES} ${gtest_target})
    if(${ARG_DEFAULT_WARNING_OPTIONS})
        target_default_warning_options(${test_name})
    endif()
    if(${ARG_DEFAULT_ERROR_OPTIONS})
        target_default_error_options(${test_prog})
    endif()
    if(ARG_CXX_STANDARD)
    target_compile_features(${test_name} PRIVATE cxx_std_${ARG_CXX_STANDARD})
    endif()
    copy_runtime_dlls_if_win32(${test_name} RUNTIME_OUTPUT_SUBDIRECTORY ${test_name})
    gtest_discover_tests(${test_name} TEST_PREFIX ${library_target}::)
endfunction()

function(add_cpp_executable_basic_tests library_target gtest_target)
    # Args:
    set(options "")
    set(params "DEFAULT_WARNING_OPTIONS;DEFAULT_ERROR_OPTIONS;CXX_STANDARD")
    set(lists "SOURCES;DEPENDENCIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 2 "ARG" "${options}" "${params}" "${lists}")
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
        if(${ARG_DEFAULT_ERROR_OPTIONS})
            target_default_error_options(${test_prog})
        endif()
        if(ARG_CXX_STANDARD)
            target_compile_features(${test_prog} PRIVATE cxx_std_${ARG_CXX_STANDARD})
        endif()
        copy_runtime_dlls_if_win32(${test_prog} RUNTIME_OUTPUT_SUBDIRECTORY ${test_prog})
        gtest_discover_tests(${test_prog} TEST_PREFIX ${library_target}::)
    endforeach()
endfunction()
