
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
    set(options "PRIVATE_RSC_HEADERS;PRIVATE_RSC_PATHS_HEADER")
    set(params "PARENT_NAMESPACE;INLINE_PARENT_NAMESPACE;NAME;VIRTUAL_ROOT;RESOURCES_BASE_DIR;"
                "BUILD_RSC_HEADERS_BASE_DIR;PRIVATE_BUILD_RSC_HEADERS_BASE_DIR;BUILD_RSC_SOURCES_BASE_DIR;"
                     "SHARED;STATIC;OBJECT;BUILD_SHARED;BUILD_STATIC;"
                     "CXX_STANDARD;HEADERS_BASE_DIRS;BUILD_HEADERS_BASE_DIRS;"
                     "LIBRARY_OUTPUT_DIRECTORY;ARCHIVE_OUTPUT_DIRECTORY")
    set(lists "RESOURCES;HEADERS;SOURCES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    fatal_if_none_is_def("Library type ('STATIC' or 'SHARED') must be provided!" ARG_SHARED ARG_STATIC)
    fatal_ifndef("No NAME provided!" ARG_NAME)
    fatal_ifndef("No resource file provided!" ARG_RESOURCES)
    set_iftest(library_type IF ARG_SHARED THEN SHARED ELSE STATIC)
    set_ifndef(ARG_RESOURCES_BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    set_ifndef(ARG_BUILD_RSC_HEADERS_BASE_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
    set_ifndef(ARG_PRIVATE_BUILD_RSC_HEADERS_BASE_DIR ${CMAKE_CURRENT_BINARY_DIR}/private_${CMAKE_INSTALL_INCLUDEDIR})
    set_ifndef(ARG_BUILD_RSC_SOURCES_BASE_DIR ${CMAKE_CURRENT_BINARY_DIR}/src)
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
    set(rsc_lib_path "${ARG_BUILD_RSC_HEADERS_BASE_DIR}/${ARG_PARENT_NAMESPACE}/${ARG_NAME}")
    set(private_rsc_lib_path "${ARG_PRIVATE_BUILD_RSC_HEADERS_BASE_DIR}/${ARG_PARENT_NAMESPACE}/${ARG_NAME}")
    set_iftest(hdr_rsc_lib_path IF ARG_PRIVATE_RSC_HEADERS THEN ${private_rsc_lib_path} ELSE ${rsc_lib_path})
    set(src_rsc_lib_path "${ARG_BUILD_RSC_SOURCES_BASE_DIR}/${ARG_PARENT_NAMESPACE}/${ARG_NAME}")
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
                RESOURCE "${rsc_path}" NAMESPACE "${ARG_NAME}" PARENT_NAMESPACE ${ARG_PARENT_NAMESPACE} INLINE ${inline_parent_ns}
            DEPENDS ${rsc_path}
        )
        add_custom_target(${rsc_stem}_rsc_hcpp ALL DEPENDS ${rsc_hpp_path} ${rsc_cpp_path})
        add_dependencies(${rsc_stem}_rsc_hcpp cmtk_file_to_byte_array)
        list(APPEND rsc_hpp_paths ${rsc_hpp_path})
        list(APPEND rsc_cpp_paths ${rsc_cpp_path})
        list(APPEND rsc_targets ${rsc_stem}_rsc_hcpp)
    endforeach()
    set(rsc_lib_hpp_path "${rsc_lib_path}/${ARG_NAME}.hpp")
    set_iftest(rsc_paths_hpp_dir IF ARG_PRIVATE_RSC_PATHS_HEADER THEN "${private_rsc_lib_path}" ELSE "${rsc_lib_path}")
    set(rsc_paths_hpp_path "${rsc_paths_hpp_dir}/paths.hpp")
    set(rsc_lib_cpp_path "${src_rsc_lib_path}/${ARG_NAME}.cpp")
    add_custom_command(OUTPUT ${rsc_lib_hpp_path} ${rsc_paths_hpp_path} ${rsc_lib_cpp_path}
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/._script/cmtk_generate_rsc_lib_hcpp.cmake 
            -- LIB_NAME ${ARG_NAME} HEADER_LIB_PATH ${rsc_lib_path} SOURCE_LIB_PATH ${src_rsc_lib_path} PATHS_HEADER_PATH ${rsc_paths_hpp_dir} 
               RESOURCES ${ARG_RESOURCES} NAMESPACE ${ARG_NAME}
               VIRTUAL_ROOT ${ARG_VIRTUAL_ROOT} BASE_DIR ${ARG_RESOURCES_BASE_DIR} PARENT_NAMESPACE ${ARG_PARENT_NAMESPACE}
               INLINE ${inline_parent_ns}
        DEPENDS ${rsc_hpp_paths} ${rsc_cpp_paths}
    )
    add_custom_target(${ARG_NAME}_rsc_lib_hcpp ALL DEPENDS ${rsc_lib_hpp_path} ${rsc_lib_cpp_path})
    list(APPEND rsc_targets ${ARG_NAME}_rsc_lib_hcpp)
    # Add library.
    if(NOT ARG_OBJECT)
        _object_name_from_shared_static(ARG_OBJECT ARG_SHARED ARG_STATIC)
    endif()
    if(NOT ARG_PRIVATE_RSC_HEADERS)
        list(APPEND ARG_HEADERS ${rsc_hpp_paths})
    endif()
    if(NOT ARG_PRIVATE_RSC_PATHS_HEADER)
        list(APPEND ARG_HEADERS ${rsc_paths_hpp_path})
    endif()
    _add_classic_cpp_library(
        SHARED ${ARG_SHARED}
        STATIC ${ARG_STATIC}
        OBJECT ${ARG_OBJECT}
        BUILD_SHARED ${ARG_BUILD_SHARED}
        BUILD_STATIC ${ARG_BUILD_STATIC}
        HEADERS ${rsc_lib_hpp_path} ${ARG_HEADERS} 
        SOURCES ${rsc_lib_cpp_path} ${rsc_cpp_paths} ${ARG_SOURCES}
        CXX_STANDARD ${ARG_CXX_STANDARD}
        HEADERS_BASE_DIRS ${ARG_HEADERS_BASE_DIRS}
        BUILD_HEADERS_BASE_DIRS ${ARG_BUILD_HEADERS_BASE_DIRS} ${ARG_BUILD_RSC_HEADERS_BASE_DIR}
        LIBRARY_OUTPUT_DIRECTORY ${ARG_LIBRARY_OUTPUT_DIRECTORY}
        ARCHIVE_OUTPUT_DIRECTORY ${ARG_ARCHIVE_OUTPUT_DIRECTORY}
    )
    add_dependencies(${ARG_OBJECT} ${rsc_targets})
    if(ARG_PRIVATE_RSC_HEADERS)
        target_include_directories(${ARG_OBJECT} PRIVATE ${ARG_PRIVATE_BUILD_RSC_HEADERS_BASE_DIR})
    endif()
endfunction()
