
include(${CMAKE_CURRENT_LIST_DIR}/CppProject.cmake)

function(CMTKNS_add_cpp_library_example example_name library_target)
    # Args:
    set(options "")
    set(params "DEFAULT_WARNING_OPTIONS;CXX_STANDARD")
    set(lists "HEADERS;SOURCES;DEPENDENCIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 2 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    fatal_ifndef("You must provide a list of example source files." ARG_SOURCES)
    set_ifndef(ARG_DEFAULT_WARNING_OPTIONS ON)
    #
    add_executable(${example_name} ${ARG_SOURCES} ${ARG_HEADERS})
    target_link_libraries(${example_name} PRIVATE ${library_target} ${ARG_DEPENDENCIES})
    if(${ARG_DEFAULT_WARNING_OPTIONS})
        target_default_warning_options(${example_name})
    endif()
    if(ARG_CXX_STANDARD)
      target_compile_features(${example_name} PRIVATE cxx_std_${ARG_CXX_STANDARD})
    endif()
    if(WIN32) # copy_runtime_dlls_if_win32(target_name RUNTIME_OUTPUT_SUBDIRECTORY subdir)
        set_target_properties(${example_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${example_name}")
        add_custom_command(TARGET ${example_name} POST_BUILD 
            COMMAND ${CMAKE_COMMAND} -E touch $<TARGET_FILE_DIR:${example_name}>/.dummy.txt
            COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:${example_name}> $<TARGET_FILE_DIR:${example_name}>/.dummy.txt $<TARGET_FILE_DIR:${example_name}>
            COMMAND_EXPAND_LISTS)
    endif()
endfunction()

function(CMTKNS_add_cpp_library_basic_examples library_target)
    # Args:
    set(options "")
    set(params "DEFAULT_WARNING_OPTIONS;CXX_STANDARD")
    set(lists "SOURCES;DEPENDENCIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    fatal_ifndef("You must provide a list of example source files." ARG_SOURCES)
    set_ifndef(ARG_DEFAULT_WARNING_OPTIONS ON)
    #
    foreach(filename ${ARG_SOURCES})
        get_filename_component(example_prog ${filename} NAME_WE)
        add_executable(${example_prog} ${filename})
        target_link_libraries(${example_prog} PRIVATE ${library_target} ${ARG_DEPENDENCIES})
        if(${ARG_DEFAULT_WARNING_OPTIONS})
            target_default_warning_options(${example_prog})
        endif()
        if(ARG_CXX_STANDARD)
            target_compile_features(${example_prog} PRIVATE cxx_std_${ARG_CXX_STANDARD})
        endif()
        if(WIN32)
            set_target_properties(${example_prog} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${example_prog}")
            add_custom_command(TARGET ${example_prog} POST_BUILD 
                              COMMAND ${CMAKE_COMMAND} -E touch $<TARGET_FILE_DIR:${example_prog}>/.dummy.txt
                              COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:${example_prog}> $<TARGET_FILE_DIR:${example_prog}>/.dummy.txt $<TARGET_FILE_DIR:${example_prog}>
                              COMMAND_EXPAND_LISTS)
        endif()
    endforeach()
endfunction()
