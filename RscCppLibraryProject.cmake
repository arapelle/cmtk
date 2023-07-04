
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
    include(GNUInstallDirs)
    # Args:
    set(options "STATIC;SHARED")
    set(params "NAME;VIRTUAL_ROOT;RESOURCES_BASE_DIR;BUILD_HEADERS_BASE_DIR;PARENT_NAMESPACE;INLINE_PARENT_NAMESPACE")
    set(lists "RESOURCES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    fatal_if_none_is_def("Library type ('STATIC' or 'SHARED') must be provided!" ARG_SHARED ARG_STATIC)
    fatal_ifndef("No NAME provided!" ARG_NAME)
    fatal_ifndef("No resource file provided!" ARG_RESOURCES)
    set_iftest(library_type IF ARG_SHARED THEN SHARED ELSE STATIC)
    set_ifndef(ARG_RESOURCES_BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    set_ifndef(ARG_BUILD_HEADERS_BASE_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
    if(ARG_INLINE_PARENT_NAMESPACE)
        fatal_ifdef("INLINE_PARENT_NAMESPACE should not be provided if PARENT_NAMESPACE is given." ARG_PARENT_NAMESPACE)
        set(inline_parent_ns TRUE)
        set(ARG_PARENT_NAMESPACE ${ARG_INLINE_PARENT_NAMESPACE})
    endif()
    # Ensure target cmtk_file_to_byte_array
    if(NOT TARGET cmtk_file_to_byte_array)
        _add_ftoba_executable()
    endif()
    # Resource h/cpp
    set(rsc_lib_path "${ARG_BUILD_HEADERS_BASE_DIR}/${ARG_PARENT_NAMESPACE}/${ARG_NAME}")
    set(rsc_lib_hpp_path "${rsc_lib_path}/${ARG_NAME}.hpp")
    set(rsc_lib_cpp_path "${rsc_lib_path}/${ARG_NAME}.cpp")
    set(rsc_hpp_paths)
    set(rsc_cpp_paths)
    set(rsc_targets)
    foreach(rsc_path ${ARG_RESOURCES})
        file(TO_CMAKE_PATH "${rsc_path}" rsc_path)
        get_filename_component(rsc_stem "${rsc_path}" NAME_WE)
        string(MAKE_C_IDENTIFIER "${rsc_stem}" rsc_stem)
        cmake_path(GET rsc_path PARENT_PATH rsc_dir)
        file(RELATIVE_PATH rsc_rel_dir ${ARG_RESOURCES_BASE_DIR} ${rsc_dir})
        set(rsc_cpp_path "${rsc_lib_path}/${rsc_rel_dir}/${rsc_stem}.cpp")
        set(rsc_hpp_path "${rsc_lib_path}/${rsc_rel_dir}/${rsc_stem}.hpp")
        add_custom_command(OUTPUT ${rsc_hpp_path} ${rsc_cpp_path}
            COMMAND ${CMAKE_COMMAND} -P
              ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/._script/cmtk_generate_rsc_hcpp.cmake 
                CMTK_FTOBA $<TARGET_FILE:cmtk_file_to_byte_array> LIB_PATH "${rsc_lib_path}" RSC_RELATIVE_DIR "${rsc_rel_dir}"
                RESOURCE "${rsc_path}" NAMESPACE "${ARG_NAME}" PARENT_NAMESPACE ${ARG_PARENT_NAMESPACE} INLINE ${inline_parent_ns}
            DEPENDS ${rsc_path}
        )
        add_custom_target(${rsc_stem}_rsc_hcpp ALL DEPENDS ${rsc_hpp_path} ${rsc_cpp_path})
        add_dependencies(${rsc_stem}_rsc_hcpp cmtk_file_to_byte_array)
        list(APPEND rsc_hpp_paths ${rsc_hpp_path})
        list(APPEND rsc_cpp_paths ${rsc_cpp_path})
        list(APPEND rsc_targets ${rsc_stem}_rsc_hcpp)
    endforeach()
    add_custom_command(OUTPUT ${rsc_lib_hpp_path} ${rsc_lib_cpp_path}
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/._script/cmtk_generate_rsc_lib_hcpp.cmake 
            -- LIB_NAME ${ARG_NAME} LIB_PATH ${rsc_lib_path} RESOURCES ${ARG_RESOURCES} NAMESPACE ${ARG_NAME}
               VIRTUAL_ROOT ${ARG_VIRTUAL_ROOT} BASE_DIR ${ARG_RESOURCES_BASE_DIR} PARENT_NAMESPACE ${ARG_PARENT_NAMESPACE}
               INLINE ${inline_parent_ns}
        DEPENDS ${rsc_hpp_paths} ${rsc_cpp_paths}
    )
    add_custom_target(${ARG_NAME}_rsc_lib_hcpp ALL DEPENDS ${rsc_lib_hpp_path} ${rsc_lib_cpp_path})
    list(APPEND rsc_targets ${ARG_NAME}_rsc_lib_hcpp)
    # Add library.
    add_library(${ARG_NAME} ${library_type} ${rsc_cpp_paths} ${rsc_lib_cpp_path})
    add_dependencies(${ARG_NAME} ${rsc_targets})
    target_compile_features(${ARG_NAME} PUBLIC cxx_std_20)
    target_sources(${ARG_NAME} PUBLIC
        FILE_SET HEADERS
        BASE_DIRS ${ARG_BUILD_HEADERS_BASE_DIR}
        FILES ${rsc_lib_hpp_path} ${rsc_hpp_paths}
    )
endfunction()
