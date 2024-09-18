
include(${CMAKE_CURRENT_LIST_DIR}/Project.cmake)

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

# target_default_warning_options()
function(target_default_warning_options target)
  if(MSVC)
      target_compile_options(${target} PRIVATE /Wall)
  elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
      target_compile_options(${target} PRIVATE -Wall -Wextra -pedantic)
  endif()
endfunction()

macro(add_test_subdirectory_if_build dir_name)
  cmake_parse_arguments("M_ARG" "" "NAME;BUILD_OPTION_NAME;BUILD_OPTION_MSG;BUILD_OPTION_DEFAULT" "" ${ARGN})
  set_ifndef(M_ARG_NAME "${PROJECT_NAME}")
  if(NOT M_ARG_BUILD_OPTION_NAME)
    make_upper_c_identifier("${M_ARG_NAME}" upper_var_name)
    set(M_ARG_BUILD_OPTION_NAME "BUILD_${upper_var_name}_TESTS")
  endif()
  set_ifndef(M_ARG_BUILD_OPTION_MSG "Build ${M_ARG_NAME} tests or not.")
  set_ifndef(M_ARG_BUILD_OPTION_DEFAULT OFF)
  fatal_if_none_of(M_ARG_BUILD_OPTION_DEFAULT "ON" "OFF")
  option(${M_ARG_BUILD_OPTION_NAME} ${M_ARG_BUILD_OPTION_MSG} ${M_ARG_BUILD_OPTION_DEFAULT})
  if(${M_ARG_BUILD_OPTION_NAME})
    include(CTest)
    if(BUILD_TESTING)
      add_subdirectory(${dir_name})
    endif()
  endif()
endmacro()

macro(add_example_subdirectory_if_build dir_name)
  cmake_parse_arguments("M_ARG" "" "NAME;BUILD_OPTION_NAME;BUILD_OPTION_MSG;BUILD_OPTION_DEFAULT" "" ${ARGN})
  set_ifndef(M_ARG_NAME "${PROJECT_NAME}")
  if(NOT M_ARG_BUILD_OPTION_NAME)
    make_upper_c_identifier("${M_ARG_NAME}" upper_var_name)
    set(M_ARG_BUILD_OPTION_NAME "BUILD_${upper_var_name}_EXAMPLES")
  endif()
  set_ifndef(M_ARG_BUILD_OPTION_MSG "Build ${M_ARG_NAME} examples or not.")
  set_ifndef(M_ARG_BUILD_OPTION_DEFAULT OFF)
  fatal_if_none_of(M_ARG_BUILD_OPTION_DEFAULT "ON" "OFF")
  option(${M_ARG_BUILD_OPTION_NAME} ${M_ARG_BUILD_OPTION_MSG} ${M_ARG_BUILD_OPTION_DEFAULT})
  if(${M_ARG_BUILD_OPTION_NAME})
    add_subdirectory(${dir_name})
  endif()
endmacro()
