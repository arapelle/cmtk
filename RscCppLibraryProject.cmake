
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

function(add_rsc_cpp_library target_name library_type)
    include(GNUInstallDirs)
    # Args:
    set(options "PRIVATE_RESOURCE_HEADERS;PRIVATE_RESOURCE_PATHS_HEADER")
    set(params "CONTEXT_NAMESPACE;INLINE_CONTEXT_NAMESPACE;NAMESPACE;VIRTUAL_ROOT;"
                "RESOURCES_BASE_DIR;
                 BUILD_RESOURCE_HEADERS_BASE_DIR;
                 BUILD_RESOURCE_SOURCES_BASE_DIR;
                 PRIVATE_BUILD_RESOURCE_HEADERS_BASE_DIR;"
                # classic cpp parameters:
                "CXX_STANDARD;HEADERS_BASE_DIRS;BUILD_HEADERS_BASE_DIRS;"
                "LIBRARY_OUTPUT_DIRECTORY;ARCHIVE_OUTPUT_DIRECTORY")
    set(lists "RESOURCES;HEADERS;SOURCES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    fatal_ifndef("No NAMESPACE provided!" ARG_NAMESPACE)
    fatal_ifndef("No resource file provided!" ARG_RESOURCES)
    set_ifndef(ARG_RESOURCES_BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    set_ifndef(ARG_BUILD_RESOURCE_HEADERS_BASE_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
    set_ifndef(ARG_PRIVATE_BUILD_RESOURCE_HEADERS_BASE_DIR ${CMAKE_CURRENT_BINARY_DIR}/private_${CMAKE_INSTALL_INCLUDEDIR})
    set_ifndef(ARG_BUILD_RESOURCE_SOURCES_BASE_DIR ${CMAKE_CURRENT_BINARY_DIR}/src)
    if(ARG_INLINE_CONTEXT_NAMESPACE)
        fatal_ifdef("INLINE_CONTEXT_NAMESPACE should not be provided if CONTEXT_NAMESPACE is given." ARG_CONTEXT_NAMESPACE)
        set(inline_parent_ns TRUE)
        set(ARG_CONTEXT_NAMESPACE ${ARG_INLINE_CONTEXT_NAMESPACE})
    endif()
    # Ensure target cmtk_file_to_byte_array
    if(NOT TARGET cmtk_file_to_byte_array)
        _add_ftoba_executable()
    endif()
    # Resource h/cpp
    set(rsc_lib_path "${ARG_BUILD_RESOURCE_HEADERS_BASE_DIR}/${ARG_CONTEXT_NAMESPACE}/${ARG_NAMESPACE}")
    set(private_rsc_lib_path "${ARG_PRIVATE_BUILD_RESOURCE_HEADERS_BASE_DIR}/${ARG_CONTEXT_NAMESPACE}/${ARG_NAMESPACE}")
    set_iftest(hdr_rsc_lib_path IF ARG_PRIVATE_RESOURCE_HEADERS THEN ${private_rsc_lib_path} ELSE ${rsc_lib_path})
    set(src_rsc_lib_path "${ARG_BUILD_RESOURCE_SOURCES_BASE_DIR}/${ARG_CONTEXT_NAMESPACE}/${ARG_NAMESPACE}")
    make_lower_c_identifier("${target_name}" target_prefix)
    set(rsc_hpp_paths)
    set(rsc_cpp_paths)
    set(rsc_targets)
    foreach(rsc_path ${ARG_RESOURCES})
        file(TO_CMAKE_PATH "${rsc_path}" rsc_path)
        get_filename_component(rsc_stem "${rsc_path}" NAME_WE)
        string(MAKE_C_IDENTIFIER "${rsc_stem}" rsc_stem)
        cmake_path(GET rsc_path PARENT_PATH rsc_dir)
        file(RELATIVE_PATH rsc_rel_dir ${ARG_RESOURCES_BASE_DIR} ${rsc_dir})
        set(rsc_cpp_path "${src_rsc_lib_path}/${rsc_rel_dir}/${rsc_stem}.cpp")
        set(rsc_hpp_path "${hdr_rsc_lib_path}/${rsc_rel_dir}/${rsc_stem}.hpp")
        add_custom_command(OUTPUT ${rsc_hpp_path} ${rsc_cpp_path}
            COMMAND ${CMAKE_COMMAND} -P
              ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/._script/cmtk_generate_rsc_hcpp.cmake 
                CMTK_FTOBA $<TARGET_FILE:cmtk_file_to_byte_array> HEADER_LIB_PATH "${hdr_rsc_lib_path}" SOURCE_LIB_PATH "${src_rsc_lib_path}" RSC_RELATIVE_DIR "${rsc_rel_dir}"
                RESOURCE "${rsc_path}" NAMESPACE "${ARG_NAMESPACE}" PARENT_NAMESPACE ${ARG_CONTEXT_NAMESPACE} INLINE ${inline_parent_ns}
            DEPENDS ${rsc_path}
        )
        add_custom_target(${target_prefix}_${rsc_stem}_rsc_hcpp ALL DEPENDS ${rsc_hpp_path} ${rsc_cpp_path})
        add_dependencies(${target_prefix}_${rsc_stem}_rsc_hcpp cmtk_file_to_byte_array)
        list(APPEND rsc_hpp_paths ${rsc_hpp_path})
        list(APPEND rsc_cpp_paths ${rsc_cpp_path})
        list(APPEND rsc_targets ${target_prefix}_${rsc_stem}_rsc_hcpp)
    endforeach()
    set(rsc_lib_hpp_path "${rsc_lib_path}/find_serialized_resource.hpp")
    set_iftest(rsc_paths_hpp_dir IF ARG_PRIVATE_RESOURCE_PATHS_HEADER THEN "${private_rsc_lib_path}" ELSE "${rsc_lib_path}")
    set(rsc_paths_hpp_path "${rsc_paths_hpp_dir}/paths.hpp")
    set(rsc_lib_cpp_path "${src_rsc_lib_path}/find_serialized_resource.cpp")
    add_custom_command(OUTPUT ${rsc_lib_hpp_path} ${rsc_paths_hpp_path} ${rsc_lib_cpp_path}
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/._script/cmtk_generate_rsc_lib_hcpp.cmake 
            -- LIB_NAME ${ARG_NAMESPACE} HEADER_LIB_PATH ${rsc_lib_path} SOURCE_LIB_PATH ${src_rsc_lib_path} PATHS_HEADER_PATH ${rsc_paths_hpp_dir} 
               RESOURCES ${ARG_RESOURCES} NAMESPACE ${ARG_NAMESPACE}
               VIRTUAL_ROOT ${ARG_VIRTUAL_ROOT} BASE_DIR ${ARG_RESOURCES_BASE_DIR} PARENT_NAMESPACE ${ARG_CONTEXT_NAMESPACE}
               INLINE ${inline_parent_ns}
        DEPENDS ${rsc_hpp_paths} ${rsc_cpp_paths}
    )
    add_custom_target(${target_prefix}_rsc_lib_hcpp ALL DEPENDS ${rsc_lib_hpp_path} ${rsc_lib_cpp_path})
    list(APPEND rsc_targets ${target_prefix}_rsc_lib_hcpp)
    # Add library.
    if(NOT ARG_PRIVATE_RESOURCE_HEADERS)
        list(APPEND ARG_HEADERS ${rsc_hpp_paths})
    endif()
    if(NOT ARG_PRIVATE_RESOURCE_PATHS_HEADER)
        list(APPEND ARG_HEADERS ${rsc_paths_hpp_path})
    endif()
    _cmtk_add_compiled_cpp_library(${target_name} ${library_type} 
        HEADERS ${rsc_lib_hpp_path} ${ARG_HEADERS} 
        SOURCES ${rsc_lib_cpp_path} ${rsc_cpp_paths} ${ARG_SOURCES}
        CXX_STANDARD ${ARG_CXX_STANDARD}
        HEADERS_BASE_DIRS ${ARG_HEADERS_BASE_DIRS}
        BUILD_HEADERS_BASE_DIRS ${ARG_BUILD_HEADERS_BASE_DIRS} ${ARG_BUILD_RESOURCE_HEADERS_BASE_DIR}
        LIBRARY_OUTPUT_DIRECTORY ${ARG_LIBRARY_OUTPUT_DIRECTORY}
        ARCHIVE_OUTPUT_DIRECTORY ${ARG_ARCHIVE_OUTPUT_DIRECTORY}
    )
    add_dependencies(${target_name} ${rsc_targets})
    if(ARG_PRIVATE_RESOURCE_HEADERS)
        target_include_directories(${target_name} PRIVATE ${ARG_PRIVATE_BUILD_RESOURCE_HEADERS_BASE_DIR})
    endif()
endfunction()
