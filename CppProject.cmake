
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
    set(params "INPUT_VERSION_HEADER;OUTPUT_VERSION_HEADER")
    set(lists "")
    # Parse args
    cmake_parse_arguments(PARSE_ARGV 0 "FARG" "${options}" "${params}" "${lists}")
    #----------------------------------------#

    if(FARG_OUTPUT_VERSION_HEADER)
        if(FARG_INPUT_VERSION_HEADER)
            if(EXISTS ${FARG_INPUT_VERSION_HEADER} AND NOT IS_DIRECTORY ${FARG_INPUT_VERSION_HEADER})
                configure_file(${FARG_INPUT_VERSION_HEADER} ${FARG_OUTPUT_VERSION_HEADER})
            else()
                message(FATAL_ERROR "${FARG_INPUT_VERSION_HEADER} does not exist.")
            endif()
        else()
            generate_default_version_header(${FARG_OUTPUT_VERSION_HEADER})
        endif()
    endif()
endfunction()
