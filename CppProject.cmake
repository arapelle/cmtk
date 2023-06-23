
include(${CMAKE_CURRENT_LIST_DIR}/Project.cmake)

function(generate_version_macro_header return_var macro_prefix header_path)
  include(GNUInstallDirs)
  cmake_parse_arguments(PARSE_ARGV 1 "ARG" "" "BINARY_BASE_DIR" "")
  set_ifndef(ARG_BINARY_BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}")
  file(MAKE_DIRECTORY "${ARG_BINARY_BASE_DIR}")
  set(${return_var} "${ARG_BINARY_BASE_DIR}/${header_path}" PARENT_SCOPE)
  to_upper_var_name(${macro_prefix} macro_prefix)
  file(GENERATE OUTPUT "${ARG_BINARY_BASE_DIR}/${header_path}"
      CONTENT
       "#pragma once

#define ${macro_prefix}_VERSION_MAJOR ${PROJECT_VERSION_MAJOR}
#define ${macro_prefix}_VERSION_MINOR ${PROJECT_VERSION_MINOR}
#define ${macro_prefix}_VERSION_PATCH ${PROJECT_VERSION_PATCH}
#define ${macro_prefix}_VERSION \"${PROJECT_VERSION}\"
")
endfunction()

function(configure_headers return_var)
  include(GNUInstallDirs)
  cmake_parse_arguments(PARSE_ARGV 1 "ARG" "" "BASE_DIR;BINARY_BASE_DIR" "FILES")
  fatal_ifndef("You must provide files to configure (FILES)." ARG_FILES)
  set_ifndef(ARG_BASE_DIR ${CMAKE_INSTALL_INCLUDEDIR})
  set_ifndef(ARG_BINARY_BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}")
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
    set(oahpath "${ARG_BINARY_BASE_DIR}/${orhpath}")
    configure_file(${ihfile} ${oahpath})
    list(APPEND olist ${oahpath})
  endforeach()
  set(${return_var} "${olist}" PARENT_SCOPE)
endfunction()

# set_spdlog_active_level_ifndef()
function(set_spdlog_active_level_ifndef)
    if(NOT SPDLOG_ACTIVE_LEVEL)
        set(level "TRACE")
        if(CMAKE_BUILD_TYPE)
            if(CMAKE_BUILD_TYPE STREQUAL "Debug")
                set(level "DEBUG")
            elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
                set(level "INFO")
            endif()
        endif()
        set(SPDLOG_ACTIVE_LEVEL "${level}" CACHE STRING "Choose the level of logging." FORCE)
        set_property(CACHE SPDLOG_ACTIVE_LEVEL PROPERTY STRINGS "TRACE" "DEBUG" "INFO" "WARN" "ERROR" "CRITICAL" "OFF")
    endif()
endfunction()

# target_default_warning_options()
function(target_default_warning_options target)
  if(MSVC)
      target_compile_options(${target} PRIVATE /Wall)
  elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
      target_compile_options(${target} PRIVATE -Wall -Wextra -pedantic)
  endif()
endfunction()
