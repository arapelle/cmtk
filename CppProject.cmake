
include(${CMAKE_CURRENT_LIST_DIR}/Project.cmake)

function(configure_headers return_var)
  include(GNUInstallDirs)
  cmake_parse_arguments(PARSE_ARGV 1 "ARG" "" "BASE_DIR;BINARY_BASE_DIR" "FILES")
  fatal_ifndef("You must provide files to configure (FILES)." ARG_FILES)
  set_ifndef(ARG_BASE_DIR ${CMAKE_INSTALL_INCLUDEDIR})
  set_ifndef(ARG_BINARY_BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}")
  configure_files(configured_files BASE_DIR "${ARG_BASE_DIR}" BINARY_BASE_DIR "${ARG_BINARY_BASE_DIR}" FILES ${ARG_FILES})
  set(${return_var} "${configured_files}" PARENT_SCOPE)
endfunction()

function(configure_sources return_var)
  cmake_parse_arguments(PARSE_ARGV 1 "ARG" "" "BASE_DIR;BINARY_BASE_DIR" "FILES")
  fatal_ifndef("You must provide files to configure (FILES)." ARG_FILES)
  set_ifndef(ARG_BASE_DIR "src")
  set_ifndef(ARG_BINARY_BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}/src")
  configure_files(configured_files BASE_DIR "${ARG_BASE_DIR}" BINARY_BASE_DIR "${ARG_BINARY_BASE_DIR}" FILES ${ARG_FILES})
  set(${return_var} "${configured_files}" PARENT_SCOPE)
endfunction()

function(cxx_standard_option cxx_std_var_name)
    # Args:
    set(options "")
    set(params "MIN;MAX;DEFAULT")
    set(lists "")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    set(cxx_stds "98" "11" "14" "17" "20" "23" "26")
    ## default MIN & MAX
    list(GET cxx_stds 0 default_min)
    list(LENGTH cxx_stds nb_cxx_stds)
    math(EXPR last_index "${nb_cxx_stds} - 1")
    list(GET cxx_stds ${last_index} default_max)
    set_ifndef(ARG_MIN ${default_min})
    set_ifndef(ARG_MAX ${default_max})
    ## check MIN
    list(FIND cxx_stds ${ARG_MIN} min_index)
    if(${min_index} EQUAL -1)
      message(FATAL_ERROR "MIN must be one of the following values: ${cxx_stds}. MIN=${ARG_MIN}.")
    endif()
    ## check MAX
    list(FIND cxx_stds ${ARG_MAX} max_index)
    if(${max_index} EQUAL -1)
      message(FATAL_ERROR "MAX must be one of the following values: ${cxx_stds}. MAX=${ARG_MAX}.")
    endif()
    ## check MIN younger or equal to MAX
    if(${min_index} GREATER ${max_index})
      message(FATAL_ERROR "MIN must be younger or equal to MAX: MIN=${ARG_MIN}, MAX=${ARG_MAX}.")
    endif()
    ## list C++ standard choices
    set(choices)
    foreach(cxx_std ${cxx_stds})
      list(FIND cxx_stds ${cxx_std} cxx_std_index)
      if(${cxx_std_index} GREATER_EQUAL ${min_index} AND ${cxx_std_index} LESS_EQUAL ${max_index})
        list(APPEND choices "${cxx_std}")
      endif()
    endforeach()
    ## default DEFAULT
    if(${CMAKE_CXX_STANDARD})
      set_ifndef(ARG_DEFAULT ${CMAKE_CXX_STANDARD})
    else()
      set_ifndef(ARG_DEFAULT ${ARG_MIN})
    endif()
    ## check DEFAULT
    if(NOT ${ARG_DEFAULT} IN_LIST choices)
      message(FATAL_ERROR "DEFAULT must be one of the following values: ${choices}. DEFAULT=${ARG_DEFAULT}.")
    endif()
    # define C++ standard option OR check the already set value
    if(NOT DEFINED ${cxx_std_var_name})
      set(${cxx_std_var_name} "${ARG_DEFAULT}" CACHE STRING "Choose the C++ standard among: ${choices}." FORCE)
      set_property(CACHE ${cxx_std_var_name} PROPERTY STRINGS ${choices})
    else()
      list(FIND cxx_stds ${${cxx_std_var_name}} cache_var_index)
      if(${min_index} GREATER ${cache_var_index})
        message(FATAL_ERROR "${cxx_std_var_name} must be older or equal to MIN: MIN=${ARG_MIN}, ${cxx_std_var_name}=${${cxx_std_var_name}}.")
      endif()
      if(${max_index} LESS ${cache_var_index})
        message(FATAL_ERROR "${cxx_std_var_name} must be younger or equal to MAX: MAX=${ARG_MAX}, ${cxx_std_var_name}=${${cxx_std_var_name}}.")
      endif()
    endif()
endfunction()

function(target_default_warning_options target)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
      target_compile_options(${target} PRIVATE /Wall)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      target_compile_options(${target} PRIVATE -Wall -Wextra -pedantic -Wshadow -Wmisleading-indentation -Wold-style-cast)
  endif()
endfunction()

function(target_default_error_options target)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      target_compile_options(${target} PRIVATE -pedantic-errors -Werror=old-style-cast)
  endif()
endfunction()

function(copy_runtime_dlls_if_win32 target_name)
  if(WIN32)
    cmake_parse_arguments("M_ARG" "" "RUNTIME_OUTPUT_SUBDIRECTORY" "" ${ARGN})
    if(DEFINED M_ARG_RUNTIME_OUTPUT_SUBDIRECTORY)
      set_target_properties(${target_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${M_ARG_RUNTIME_OUTPUT_SUBDIRECTORY}")
    endif()
    add_custom_command(TARGET ${target_name} POST_BUILD 
        COMMAND ${CMAKE_COMMAND} -E touch $<TARGET_FILE_DIR:${target_name}>/.dummy.txt
        COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:${target_name}> $<TARGET_FILE_DIR:${target_name}>/.dummy.txt $<TARGET_FILE_DIR:${target_name}>
        COMMAND_EXPAND_LISTS)
  endif()
endfunction()

# args:
#  target_names
#  EXPORT <export-name>
#  [CMAKE_FILES_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PACKAGE_NAME}]
#  [NAMESPACE <ns>]
function(install_cpp_targets)
  include(GNUInstallDirs)
  # Args:
  set(params "EXPORT;CMAKE_FILES_DESTINATION;NAMESPACE")
  set(lists "TARGETS")
  # Parse args:
  cmake_parse_arguments(PARSE_ARGV 0 "ARG" "" "${params}" "${lists}")
  # Check/Set args:
  fatal_ifndef("A list of TARGETS is required." ARG_TARGETS)
  fatal_ifndef("EXPORT name is required (e.g. \${PACKAGE_NAME}-targets)" ARG_EXPORT)
  set_ifndef(ARG_CMAKE_FILES_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PACKAGE_NAME}")
  set_iftest(namespace_opt IF ARG_NAMESPACE THEN NAMESPACE ${ARG_NAMESPACE})
  # Install targets:
  install(TARGETS ${ARG_TARGETS} EXPORT ${ARG_EXPORT}
          FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
          )
  # Install export:
  install(EXPORT ${ARG_EXPORT} DESTINATION ${ARG_CMAKE_FILES_DESTINATION} ${namespace_opt})
#  export(EXPORT ${ARG_EXPORT} FILE ${CMAKE_CURRENT_BINARY_DIR}/${ARG_EXPORT}.cmake ${namespace_opt})
endfunction()
