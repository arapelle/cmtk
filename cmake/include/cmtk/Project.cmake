
include(${CMAKE_CURRENT_LIST_DIR}/Utility.cmake)

function(check_cmake_binary_dir)
    set(bin_dir ${CMAKE_BINARY_DIR})
    set(bin_dir_while TRUE)
    while(${bin_dir_while})
        if(${bin_dir} STREQUAL ${CMAKE_SOURCE_DIR})
            message(STATUS "CMAKE_SOURCE_DIR: ${CMAKE_SOURCE_DIR}")
            message(STATUS "CMAKE_BINARY_DIR: ${CMAKE_BINARY_DIR}")
            message(FATAL_ERROR "CMAKE_BINARY_DIR must not be located in CMAKE_SOURCE_DIR!")
        endif()
        get_filename_component(parent_bin_dir ${bin_dir} DIRECTORY)
        if(${parent_bin_dir} STREQUAL ${bin_dir})
            set(bin_dir_while FALSE)
        else()
            set(bin_dir ${parent_bin_dir})
        endif()
    endwhile()
endfunction()

function(set_build_type_if_undefined)
    if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
      message(STATUS "Setting build type to 'Release' as none was specified.")
      set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build." FORCE)
      set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
    endif()
endfunction()

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

function(generate_basic_package_config_file package_config_file)
    file(WRITE ${package_config_file}
         "include(\${CMAKE_CURRENT_LIST_DIR}/${PROJECT_NAME}.cmake)
")
endfunction()

function(install_cmake_uninstall_script install_cmake_package_dir)
    install(CODE
        "
        message(STATUS \"Installing: ${install_cmake_package_dir}/cmake_uninstall.cmake\")
        if(DEFINED CMAKE_INSTALL_MANIFEST_FILES)
            set(files \${CMAKE_INSTALL_MANIFEST_FILES} ${install_cmake_package_dir}/cmake_uninstall.cmake)
            file(APPEND ${install_cmake_package_dir}/cmake_uninstall.cmake
            \"
            message(STATUS \\\"Uninstall ${PROJECT_NAME} v${PROJECT_VERSION} ${CMAKE_BUILD_TYPE}\\\")
            foreach(file \${files})
                while(NOT \\\${file} STREQUAL \${CMAKE_INSTALL_PREFIX})
                    if(EXISTS \\\${file} OR IS_SYMLINK \\\${file})
                        if(IS_DIRECTORY \\\${file})
                            file(GLOB dir_files \\\${file}/*)
                            list(LENGTH dir_files number_of_files)
                            if(\\\${number_of_files} EQUAL 0)
                              message(STATUS \\\"Removing  dir: \\\${file}\\\")
                              file(REMOVE_RECURSE \\\${file})
                            endif()
                        else()
                            message(STATUS \\\"Removing file: \\\${file}\\\")
                            file(REMOVE \\\${file})
                        endif()
                    endif()
                    get_filename_component(file \\\${file} DIRECTORY)
                endwhile()
            endforeach()
            \"
            )
        else()
            message(ERROR \"cmake_uninstall.cmake script cannot be created!\")
        endif()
     "
    )
endfunction()
