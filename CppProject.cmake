
include(${CMAKE_CURRENT_LIST_DIR}/Project.cmake)

function(generate_macro_version_header set_var macro_prefix output_file)
  include(GNUInstallDirs)
  set(output_dir "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}")
  file(MAKE_DIRECTORY "${output_dir}")
  set(${set_var} "${output_dir}/${output_file}" PARENT_SCOPE)
  to_upper_var_name(${macro_prefix} macro_prefix)
  file(GENERATE OUTPUT "${output_dir}/${output_file}"
      CONTENT
       "#pragma once

#define ${macro_prefix}_VERSION_MAJOR ${PROJECT_VERSION_MAJOR}
#define ${macro_prefix}_VERSION_MINOR ${PROJECT_VERSION_MINOR}
#define ${macro_prefix}_VERSION_PATCH ${PROJECT_VERSION_PATCH}
#define ${macro_prefix}_VERSION \"${PROJECT_VERSION}\"
")
endfunction()

function(generate_default_version_header name output_header)
  #----------------------------------------#
  # Declare args
  set(options "")
  set(params "OUTPUT_BINARY_DIR")
  set(lists "")
  # Parse args
  cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
  # Check/Set args:
  if(NOT ARG_OUTPUT_BINARY_DIR)
    set(ARG_OUTPUT_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/include/")
  endif()
  #----------------------------------------#
    to_upper_var_name(${name} upper_name)
    file(MAKE_DIRECTORY "${ARG_OUTPUT_BINARY_DIR}")
    file(GENERATE OUTPUT "${ARG_OUTPUT_BINARY_DIR}/${output_header}"
        CONTENT
         "#pragma once

#define ${upper_name}_VERSION_MAJOR ${PROJECT_VERSION_MAJOR}
#define ${upper_name}_VERSION_MINOR ${PROJECT_VERSION_MINOR}
#define ${upper_name}_VERSION_PATCH ${PROJECT_VERSION_PATCH}
#define ${upper_name}_VERSION \"${PROJECT_VERSION}\"
")
endfunction()

function(configure_version_header input_header output_header)
    #----------------------------------------#
    # Declare args
    set(options "")
    set(params "OUTPUT_BINARY_DIR")
    set(lists "")
    # Parse args
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    # Check/Set args:
    if(NOT ARG_OUTPUT_BINARY_DIR)
      set(ARG_OUTPUT_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/include/")
    endif()
    #----------------------------------------#
    if(EXISTS ${input_header} AND NOT IS_DIRECTORY ${input_header})
        configure_file(${input_header} "${ARG_OUTPUT_BINARY_DIR}/${output_header}")
    else()
        message(FATAL_ERROR "configure_version_header: ${ARG_INPUT_VERSION_HEADER} file does not exist.")
    endif()
endfunction()

function(configure_headers set_var)
  include(GNUInstallDirs)
  cmake_parse_arguments(PARSE_ARGV 1 "ARG" "" "BASE_DIR" "FILES")
  fatal_ifndef("You must provide files to configure (FILES)." ARG_FILES)
  set_ifndef(ARG_BASE_DIR ${CMAKE_INSTALL_INCLUDEDIR})
  file(REAL_PATH ${ARG_BASE_DIR} ARG_BASE_DIR)
  foreach(ihfile ${ARG_FILES})
    file(REAL_PATH ${ihfile} ihfile)
    file(RELATIVE_PATH orhpath ${ARG_BASE_DIR} ${ihfile})
    get_filename_component(orhext ${orhpath} LAST_EXT)
    if("${orhext}" STREQUAL ".in")
      get_filename_component(orhdir ${orhpath} DIRECTORY)
      get_filename_component(orhname ${orhpath} NAME_WLE)
      set(orhpath "${orhdir}/${orhname}")
    endif()
    set(oahpath "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${orhpath}")
    configure_file(${ihfile} ${oahpath})
    list(APPEND olist ${oahpath})
  endforeach()
  set(${set_var} "${olist}" PARENT_SCOPE)
endfunction()
