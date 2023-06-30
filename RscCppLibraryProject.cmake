
include(${CMAKE_CURRENT_LIST_DIR}/CppLibraryProject.cmake)

function(_add_ftoba_executable)
    set(ftoba_dir_path "${CMAKE_CURRENT_BINARY_DIR}/.cmtk_tools")
    set(ftoba_cpp_path "${ftoba_dir_path}/cmtk_file_to_byte_array.cpp")
    add_custom_command(OUTPUT ${ftoba_cpp_path}
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/._script/cmtk_generate_ftoba_cpp.cmake ${ftoba_cpp_path}
    )
    add_executable(cmtk_file_to_byte_array ${ftoba_cpp_path})
    target_compile_features(cmtk_file_to_byte_array PUBLIC cxx_std_17)
    set_target_properties(cmtk_file_to_byte_array PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${ftoba_dir_path}")
endfunction()

function(add_rsc_cpp_library rsc_lib_name)
    # Args:
    set(options "STATIC;SHARED")
    set(params "BASE_DIR;VIRTUAL_ROOT;NAMESPACE")
    set(lists "")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    if(ARG_SHARED)
        set(library_type SHARED)
    elseif(ARG_STATIC)
        set(library_type STATIC)
    else()
        message(FATAL_ERROR "Library type ('STATIC' or 'SHARED') must be provided!")
    endif()
    if(NOT ARG_BASE_DIR)
        set(ARG_BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()
    if(NOT ARG_NAMESPACE)
        set(ARG_NAMESPACE "${rsc_lib_name}")
    endif()
    if(NOT ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "No resource file provided!")
    endif()
    # Check target cmtk_file_to_byte_array
    if(NOT TARGET cmtk_file_to_byte_array)
        _add_ftoba_executable()
    endif()
    # Resource h/cpp 
    set(rsc_lib_path "${CMAKE_CURRENT_BINARY_DIR}/${rsc_lib_name}")
    set(rsc_lib_hpp_path "${rsc_lib_path}/${rsc_lib_name}.hpp")
    set(rsc_lib_cpp_path "${rsc_lib_path}/${rsc_lib_name}.cpp")
    set(rsc_cpp_paths)
    set(rsc_targets)
    foreach(rsc_path ${ARG_UNPARSED_ARGUMENTS})
        file(TO_CMAKE_PATH "${rsc_path}" rsc_path)
        get_filename_component(rsc_stem "${rsc_path}" NAME_WE)
        string(MAKE_C_IDENTIFIER "${rsc_stem}" rsc_stem)
        cmake_path(GET rsc_path PARENT_PATH rsc_dir)
        file(RELATIVE_PATH rsc_rel_dir ${ARG_BASE_DIR} ${rsc_dir})
        set(rsc_cpp_path "${rsc_lib_path}/${rsc_rel_dir}/${rsc_stem}.cpp")
        add_custom_command(OUTPUT ${rsc_cpp_path}
            COMMAND ${CMAKE_COMMAND} -P
              ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/._script/cmtk_generate_rsc_cpp.cmake 
                CMTK_FTOBA $<TARGET_FILE:cmtk_file_to_byte_array> LIB_PATH "${rsc_lib_path}" RSC_RELATIVE_DIR "${rsc_rel_dir}"
                RESOURCE "${rsc_path}" NAMESPACE "${ARG_NAMESPACE}"
            DEPENDS ${rsc_path}
        )
        add_custom_target(${rsc_stem}_rsc_cpp ALL DEPENDS ${rsc_cpp_path})
        add_dependencies(${rsc_stem}_rsc_cpp cmtk_file_to_byte_array)
        list(APPEND rsc_cpp_paths ${rsc_cpp_path})
        list(APPEND rsc_targets ${rsc_stem}_rsc_cpp)
    endforeach()
    add_custom_command(OUTPUT ${rsc_lib_hpp_path} ${rsc_lib_cpp_path}
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/._script/cmtk_generate_rsc_lib_hcpp.cmake 
            -- LIB_NAME ${rsc_lib_name} LIB_PATH ${rsc_lib_path} RESOURCES ${ARG_UNPARSED_ARGUMENTS} NAMESPACE ${ARG_NAMESPACE}
               VIRTUAL_ROOT ${ARG_VIRTUAL_ROOT} BASE_DIR ${ARG_BASE_DIR}
        DEPENDS ${rsc_cpp_paths}
    )
    add_custom_target(${rsc_stem}_rsc_hpp ALL DEPENDS ${rsc_lib_hpp_path})
    list(APPEND rsc_targets ${rsc_stem}_rsc_hpp)
    # Add library.
    add_library(${rsc_lib_name} ${library_type} ${rsc_cpp_paths} ${rsc_lib_cpp_path})
    add_dependencies(${rsc_lib_name} ${rsc_targets})
    target_compile_features(${rsc_lib_name} PUBLIC cxx_std_20)
    target_sources(${rsc_lib_name} PUBLIC
        FILE_SET HEADERS
        BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}
        FILES ${rsc_lib_hpp_path}
    )
endfunction()
