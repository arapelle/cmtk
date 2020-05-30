
include(${CMAKE_CURRENT_LIST_DIR}/Project.cmake)

function(generate_default_version_header version_file)
    to_upper_var_name(${PROJECT_NAME} upper_project_var_name)
    file(GENERATE OUTPUT ${version_file}
        CONTENT
         "#pragma once

#define ${upper_project_var_name}_VERSION_MAJOR ${PROJECT_VERSION_MAJOR}
#define ${upper_project_var_name}_VERSION_MINOR ${PROJECT_VERSION_MINOR}
#define ${upper_project_var_name}_VERSION_PATCH ${PROJECT_VERSION_PATCH}
#define ${upper_project_var_name}_VERSION \"${PROJECT_VERSION}\"
")
endfunction()

function(generate_version_header)
    #----------------------------------------#
    # Declare args
    set(options "")
    set(params "INPUT_VERSION_HEADER;VERSION_HEADER")
    set(lists "")
    # Parse args
    cmake_parse_arguments(PARSE_ARGV 0 "FARG" "${options}" "${params}" "${lists}")
    #----------------------------------------#

    if(FARG_VERSION_HEADER)
        if(FARG_INPUT_VERSION_HEADER)
            if(EXISTS ${FARG_INPUT_VERSION_HEADER} AND NOT IS_DIRECTORY ${FARG_INPUT_VERSION_HEADER})
                configure_file(${FARG_INPUT_VERSION_HEADER} ${FARG_VERSION_HEADER})
            else()
                message(FATAL_ERROR "${FARG_INPUT_VERSION_HEADER} does not exist.")
            endif()
        else()
            generate_default_version_header(${FARG_VERSION_HEADER})
        endif()
    endif()
endfunction()

function(target_package_libraries target scope package version build_type)
    # parse args:
    set(options "")
    set(one_value_args "")
    set(multi_value_args LIBRARIES FIND_PACKAGE)
    cmake_parse_arguments(PARSE_ARGV 5 FARG "${options}" "${one_value_args}" "${multi_value_args}")
    # set args:
    if(FARG_LIBRARIES)
        set(dep_libs ${FARG_LIBRARIES})
    else()
        set(dep_libs ${FARG_UNPARSED_ARGUMENTS})
    endif()
    if(FARG_FIND_PACKAGE)
        set(find_package_args ${FARG_FIND_PACKAGE})
    else()
        set(find_package_args "REQUIRED")
    endif()
#    cmake_print_variables(dep_libs find_package_args)
    # find package if needed:
    if (NOT DEFINED "${package}_${version}_FOUND")
        find_package(${package} ${version} ${find_package_args})
        set(${package}_${version}_FOUND "${${package}_VERSION}" PARENT_SCOPE)
    endif()
    # link target with dependencies
    foreach(dep_lib ${dep_libs})
        # get properties:
        get_target_property(lib_include_dirs     ${dep_lib} INTERFACE_INCLUDE_DIRECTORIES)
        get_target_property(lib_compile_defs     ${dep_lib} INTERFACE_COMPILE_DEFINITIONS)
        get_target_property(lib_compile_features ${dep_lib} INTERFACE_COMPILE_FEATURES)
        get_target_property(lib_compile_options  ${dep_lib} INTERFACE_COMPILE_OPTIONS)
        get_target_property(lib_link_dirs        ${dep_lib} INTERFACE_LINK_DIRECTORIES)
        get_target_property(lib_location         ${dep_lib} IMPORTED_LOCATION_${build_type})
        get_target_property(lib_link_libs        ${dep_lib} INTERFACE_LINK_LIBRARIES)
        get_target_property(lib_link_options     ${dep_lib} INTERFACE_LINK_OPTIONS)
        get_target_property(lib_prec_headers     ${dep_lib} INTERFACE_PRECOMPILE_HEADERS)
        # link dependency:
        if(lib_include_dirs)
            target_include_directories(${target} ${scope} ${lib_include_dirs})
        endif()
        if(lib_compile_defs)
            target_compile_definitions(${target} ${scope} ${lib_compile_defs})
        endif()
        if(lib_compile_features)
            target_compile_features(${target} ${scope} ${lib_compile_features})
        endif()
        if(lib_compile_options)
            target_compile_options(${target} ${scope} ${lib_compile_options})
        endif()
        if(lib_link_dirs)
            target_link_directories(${target} ${scope} ${lib_link_dirs})
        endif()
        if(lib_location)
            target_link_libraries(${target} ${scope} ${lib_location})
        endif()
        if(lib_link_libs)
            target_link_libraries(${target} ${scope} ${lib_link_libs})
        endif()
        if(lib_link_options)
            target_link_options(${target} ${scope} ${lib_link_options})
        endif()
        if(lib_prec_headers)
            target_link_options(${target} ${scope} ${lib_prec_headers})
        endif()
    endforeach()
endfunction()
