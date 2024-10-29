
include(${CMAKE_CURRENT_LIST_DIR}/CppProject.cmake)

function(shared_or_static_option cache_var_name shared_or_static)
  fatal_if_none_of(shared_or_static "SHARED" "STATIC")
  set(${cache_var_name} "${shared_or_static}" CACHE STRING "Choose the type of library.")
  set_property(CACHE ${cache_var_name} PROPERTY STRINGS "SHARED" "STATIC")
endfunction()

function(_cmtk_add_honly_cpp_library library_name)
    include(GNUInstallDirs)
    # Args:
    set(options "")
    set(params "CXX_STANDARD")
    set(lists "HEADERS;HEADERS_BASE_DIRS;BUILD_HEADERS_BASE_DIRS;")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    fatal_ifndef("You must provide header files (HEADERS)." ARG_HEADERS)
    set_ifndef(ARG_HEADERS_BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
    set_ifndef(ARG_BUILD_HEADERS_BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
    # Interface target:
    add_library(${library_name} INTERFACE)
    target_sources(${library_name} PUBLIC FILE_SET HEADERS BASE_DIRS ${ARG_HEADERS_BASE_DIRS} ${ARG_BUILD_HEADERS_BASE_DIRS} FILES ${ARG_HEADERS})
    if(ARG_CXX_STANDARD)
      target_compile_features(${target_name} INTERFACE cxx_std_${ARG_CXX_STANDARD})
    endif()
endfunction()

function(_cmtk_add_compiled_cpp_library target_name library_type)
  include(GNUInstallDirs)
  # Args:
  set(options "DEFAULT_WARNING_OPTIONS")
  set(params "CXX_STANDARD;LIBRARY_OUTPUT_DIRECTORY;ARCHIVE_OUTPUT_DIRECTORY")
  set(lists "SOURCES;HEADERS;HEADERS_BASE_DIRS;BUILD_HEADERS_BASE_DIRS")
  # Parse args:
  cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
  fatal_ifndef("You must provide source files (SOURCES)." ARG_SOURCES)
  set_ifndef(ARG_HEADERS_BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
  set_ifndef(ARG_BUILD_HEADERS_BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
  #
  add_library(${target_name} ${library_type} ${ARG_SOURCES})
  if(DEFINED ARG_HEADERS)
    target_sources(${target_name} PUBLIC FILE_SET HEADERS BASE_DIRS ${ARG_HEADERS_BASE_DIRS} ${ARG_BUILD_HEADERS_BASE_DIRS} FILES ${ARG_HEADERS})
  endif()
  if(ARG_CXX_STANDARD)
    target_compile_features(${target_name} PUBLIC cxx_std_${ARG_CXX_STANDARD})
  endif()
  if(ARG_DEFAULT_WARNING_OPTIONS)
    target_default_warning_options(${target_name})
  endif()
  set_target_properties(${target_name} PROPERTIES DEBUG_POSTFIX "-d")
  if("${library_type}" STREQUAL "SHARED" AND ARG_LIBRARY_OUTPUT_DIRECTORY)
    set_target_properties(${target_name} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${ARG_LIBRARY_OUTPUT_DIRECTORY})
  elseif("${library_type}" STREQUAL "STATIC" AND ARG_LIBRARY_OUTPUT_DIRECTORY)
    set_target_properties(${target_name} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${ARG_ARCHIVE_OUTPUT_DIRECTORY})
  endif()
endfunction()

function(add_cpp_library target_name library_type)
    if("${library_type}" STREQUAL "SHARED" OR "${library_type}" STREQUAL "STATIC")
      _cmtk_add_compiled_cpp_library(${target_name} ${library_type} ${ARGN})
    elseif("${library_type}" STREQUAL "HEADER_ONLY")
      _cmtk_add_honly_cpp_library(${target_name} ${ARGN})
    else()
      message(FATAL_ERROR "Unknown library type: ${library_type}.")
    endif()
endfunction()

# args:
#  target_names
#  EXPORT <export-name>
#  [CMAKE_FILES_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}]
#  [NAMESPACE <ns>]
function(install_cpp_libraries)
  include(GNUInstallDirs)
  # Args:
  set(params "EXPORT;CMAKE_FILES_DESTINATION;NAMESPACE")
  set(lists "TARGETS")
  # Parse args:
  cmake_parse_arguments(PARSE_ARGV 0 "ARG" "" "${params}" "${lists}")
  # Check/Set args:
  fatal_ifndef("A list of TARGETS is required." ARG_TARGETS)
  fatal_ifndef("EXPORT name is required (e.g. \${PROJECT_NAME}-targets)" ARG_EXPORT)
  set_ifndef(ARG_CMAKE_FILES_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
  set_iftest(namespace_opt IF ARG_NAMESPACE THEN NAMESPACE ${ARG_NAMESPACE})
  # Install targets:
  install(TARGETS ${ARG_TARGETS} EXPORT ${ARG_EXPORT}
          FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
          )
  # Install export:
  install(EXPORT ${ARG_EXPORT} DESTINATION ${ARG_CMAKE_FILES_DESTINATION} ${namespace_opt})
  export(EXPORT ${ARG_EXPORT} FILE ${CMAKE_CURRENT_BINARY_DIR}/${ARG_EXPORT}.cmake ${namespace_opt})
endfunction()

function(install_library_package package_name)
    include(GNUInstallDirs)
    include(CMakePackageConfigHelpers)
    # Args:
    set(options "")
    set(params "VERSION;VERSION_COMPATIBILITY;INPUT_PACKAGE_CONFIG_FILE;CMAKE_FILES_DESTINATION")
    set(lists "")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Check and set args:
    fatal_ifndef("INPUT_PACKAGE_CONFIG_FILE is required (e.g. CMake-package-config.cmake.in)" ARG_INPUT_PACKAGE_CONFIG_FILE)
    set_ifndef(ARG_VERSION ${PROJECT_VERSION})
    set_ifndef(ARG_VERSION_COMPATIBILITY SameMajorVersion)
    set_ifndef(ARG_CMAKE_FILES_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${package_name}")
    # Create package config file:
    configure_package_config_file(${ARG_INPUT_PACKAGE_CONFIG_FILE}
        "${PROJECT_BINARY_DIR}/${package_name}-config.cmake"
        INSTALL_DESTINATION ${ARG_CMAKE_FILES_DESTINATION})
    # Create package version file:
    write_basic_package_version_file("${PROJECT_BINARY_DIR}/${package_name}-config-version.cmake"
        VERSION ${ARG_VERSION}
        COMPATIBILITY ${ARG_VERSION_COMPATIBILITY})
    # Install package files:
    install(FILES
        ${PROJECT_BINARY_DIR}/${package_name}-config.cmake
        ${PROJECT_BINARY_DIR}/${package_name}-config-version.cmake
        DESTINATION ${ARG_CMAKE_FILES_DESTINATION})
endfunction()
