
include(${CMAKE_CURRENT_LIST_DIR}/CppProject.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/CppLibraryExamples.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/CppLibraryTests.cmake)

function(_object_name_from_shared_static object_var shared_var static_var)
  if(${shared_var})
    set(object_name "${${shared_var}}")
    if(${static_var} AND ${static_var} STRLESS ${shared_var})
      set(object_name "${${static_var}}")
    endif()
  elseif(${static_var})
    set(object_name "${${static_var}}")
  endif()
  string(APPEND object_name "-object")
  set(${object_var} ${object_name} PARENT_SCOPE)
endfunction()

macro(_add_cpp_library_object)
  add_library(${ARG_OBJECT} OBJECT ${ARG_SOURCES})
  target_sources(${ARG_OBJECT} PUBLIC FILE_SET HEADERS BASE_DIRS ${ARG_HEADERS_BASE_DIRS} ${ARG_BUILD_HEADERS_BASE_DIRS} FILES ${ARG_HEADERS})
  if(ARG_CXX_STANDARD)
    target_compile_features(${ARG_OBJECT} PUBLIC cxx_std_${ARG_CXX_STANDARD})
  endif()
  target_default_warning_options(${ARG_OBJECT})
  set_property(TARGET ${ARG_OBJECT} PROPERTY POSITION_INDEPENDENT_CODE 1)
endmacro()

macro(_add_cpp_library_shared)
  add_library(${ARG_SHARED} SHARED $<TARGET_OBJECTS:${ARG_OBJECT}>)
  target_sources(${ARG_SHARED} PUBLIC FILE_SET HEADERS BASE_DIRS ${ARG_HEADERS_BASE_DIRS} ${ARG_BUILD_HEADERS_BASE_DIRS} FILES ${ARG_HEADERS})
  set_target_properties(${ARG_SHARED} PROPERTIES DEBUG_POSTFIX "-d" SOVERSION ${PROJECT_VERSION})
  if(ARG_LIBRARY_OUTPUT_DIRECTORY)
      set_target_properties(${ARG_SHARED} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${ARG_LIBRARY_OUTPUT_DIRECTORY})
  endif()
endmacro()

macro(_add_cpp_library_static)
  add_library(${ARG_STATIC} STATIC $<TARGET_OBJECTS:${ARG_OBJECT}>)
  target_sources(${ARG_STATIC} PUBLIC FILE_SET HEADERS BASE_DIRS ${ARG_HEADERS_BASE_DIRS} ${ARG_BUILD_HEADERS_BASE_DIRS} FILES ${ARG_HEADERS})
  set_target_properties(${ARG_STATIC} PROPERTIES DEBUG_POSTFIX "-d")
  if(ARG_ARCHIVE_OUTPUT_DIRECTORY)
      set_target_properties(${ARG_STATIC} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${ARG_ARCHIVE_OUTPUT_DIRECTORY})
  endif()
endmacro()

function(_add_classic_cpp_library)
  include(GNUInstallDirs)
  # Args:
  set(options "")
  set(params "SHARED;STATIC;OBJECT;BUILD_SHARED;BUILD_STATIC;"
             "CXX_STANDARD;HEADERS_BASE_DIRS;BUILD_HEADERS_BASE_DIRS;"
             "LIBRARY_OUTPUT_DIRECTORY;ARCHIVE_OUTPUT_DIRECTORY")
  set(lists "HEADERS;SOURCES")
  # Parse args:
  cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
  # Check/Set args:
  fatal_if_none_is_def("You did not choose which target(s) to build (SHARED, STATIC)." ARG_SHARED ARG_STATIC)
  if(NOT ARG_OBJECT)
    _object_name_from_shared_static(ARG_OBJECT ARG_SHARED ARG_STATIC)
  endif()
  fatal_ifndef("You must provide header files (HEADERS)." ARG_HEADERS)
  fatal_ifndef("You must provide source files (SOURCES)." ARG_SOURCES)
  set_ifndef(ARG_HEADERS_BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
  set_ifndef(ARG_BUILD_HEADERS_BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
  set_ifndef(ARG_BUILD_SHARED ON)
  if(${ARG_BUILD_SHARED} STREQUAL "OPTION")
    set(ARG_BUILD_SHARED "UNDEFINED")
  endif()
  set_ifndef(ARG_BUILD_STATIC ON)
  if(${ARG_BUILD_STATIC} STREQUAL "OPTION")
    set(ARG_BUILD_STATIC "UNDEFINED")
  endif()
  # Object target:
  _add_cpp_library_object()
  # Shared target:
  if(ARG_SHARED)
    option_or_set_ifdef(BUILD_${ARG_SHARED} "Indicates if we build a SHARED library." ON ARG_BUILD_SHARED)
    if(BUILD_${ARG_SHARED})
      _add_cpp_library_shared()
    endif()
  endif()
  # Static target:
  if(ARG_STATIC)
    option_or_set_ifdef(BUILD_${ARG_STATIC} "Indicates if we build a STATIC library." ON ARG_BUILD_STATIC)
    if(BUILD_${ARG_STATIC})
      _add_cpp_library_static()
    endif()
  endif()
endfunction()

function(_add_honly_cpp_library library_name)
    include(GNUInstallDirs)
    # Args:
    set(options "")
    set(params "CXX_STANDARD;HEADERS_BASE_DIRS;BUILD_HEADERS_BASE_DIRS;")
    set(lists "HEADERS")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    fatal_ifndef("You must provide header files (HEADERS)." ARG_HEADERS)
    set_ifndef(ARG_HEADERS_BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
    set_ifndef(ARG_BUILD_HEADERS_BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR})
    # Interface target:
    add_library(${library_name} INTERFACE)
    target_sources(${library_name} PUBLIC FILE_SET HEADERS BASE_DIRS ${ARG_HEADERS_BASE_DIRS} ${ARG_BUILD_HEADERS_BASE_DIRS} FILES ${ARG_HEADERS})
    if(ARG_CXX_STANDARD)
        target_compile_features(${library_name} INTERFACE cxx_std_${ARG_CXX_STANDARD})
    endif()
endfunction()

function(add_cpp_library)
    # Args:
    set(params "SHARED;STATIC;HEADER_ONLY")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "" "${params}" "")
    # Add C++ library:
    fatal_if_none_is_def("SHARED, STATIC or HEADER_ONLY is required." ARG_SHARED ARG_STATIC ARG_HEADER_ONLY)
    if(DEFINED ARG_SHARED OR DEFINED ARG_STATIC)
      _add_classic_cpp_library(${ARGN})
    else()
      _add_honly_cpp_library(${ARG_HEADER_ONLY} ${ARGN})
    endif()
endfunction()

# args:
#  HEADER_ONLY <target>
#  SHARED <target>
#  STATIC <target>
#  EXPORT <export-name>
#  [DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}]
#  [NAMESPACE <ns>]
function(install_cpp_library)
  include(GNUInstallDirs)
  # Args:
  set(params "HEADER_ONLY;SHARED;STATIC;EXPORT;DESTINATION;NAMESPACE")
  # Parse args:
  cmake_parse_arguments(PARSE_ARGV 0 "ARG" "" "${params}" "")
  # Check/Set args:
  fatal_if_none_is_def("You did not choose which target(s) to install (SHARED, STATIC, HEADER_ONLY)." ARG_SHARED ARG_STATIC ARG_HEADER_ONLY)
  fatal_ifndef("EXPORT name is required (e.g. \${PROJECT_NAME}-targets)" ARG_EXPORT)
  set_ifndef(ARG_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
  set_iftest(namespace_opt IF ARG_NAMESPACE THEN NAMESPACE ${ARG_NAMESPACE})
  # Install targets:
  if(DEFINED ARG_SHARED OR DEFINED ARG_STATIC)
    fatal_ifdef("The library to install is either a SHARED/STATIC library or a HEADER_ONLY library, not both." ARG_HEADER_ONLY)
  endif()
  set_ifndef(ARG_HEADER_ONLY "")
  set_ifndef(ARG_SHARED "")
  set_ifndef(ARG_STATIC "")
  if(TARGET "${ARG_HEADER_ONLY}")
    list(APPEND targets ${ARG_HEADER_ONLY})
  endif()
  if(TARGET "${ARG_SHARED}")
    list(APPEND targets ${ARG_SHARED})
  endif()
  if(TARGET "${ARG_STATIC}")
    list(APPEND targets ${ARG_STATIC})
  endif()
  install(TARGETS ${targets} EXPORT ${ARG_EXPORT}
          FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
          )
  # Install export:
  install(EXPORT ${ARG_EXPORT} DESTINATION ${ARG_DESTINATION} ${namespace_opt})
  export(EXPORT ${ARG_EXPORT} FILE ${CMAKE_CURRENT_BINARY_DIR}/${ARG_EXPORT}.cmake ${namespace_opt})
endfunction()

function(install_library_package package_name)
    include(GNUInstallDirs)
    include(CMakePackageConfigHelpers)
    # Args:
    set(options "")
    set(params "VERSION;VERSION_COMPATIBILITY;INPUT_PACKAGE_CONFIG_FILE")
    set(lists "UNINSTALL_SCRIPT") # UNINSTALL_SCRIPT [ALL]   
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Check and set args:
    fatal_ifndef("INPUT_PACKAGE_CONFIG_FILE is required (e.g. CMake-package-config.cmake.in)" ARG_INPUT_PACKAGE_CONFIG_FILE)
    set_ifndef(ARG_VERSION ${PROJECT_VERSION})
    set_ifndef(ARG_VERSION_COMPATIBILITY SameMajorVersion)
    # Set install directory paths:
    set(relative_install_cmake_package_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${package_name}")
    # Create package config file:
    configure_package_config_file(${ARG_INPUT_PACKAGE_CONFIG_FILE}
        "${PROJECT_BINARY_DIR}/${package_name}-config.cmake"
        INSTALL_DESTINATION ${relative_install_cmake_package_dir})
    # Create package version file:
    write_basic_package_version_file("${PROJECT_BINARY_DIR}/${package_name}-config-version.cmake"
        VERSION ${ARG_VERSION}
        COMPATIBILITY ${ARG_VERSION_COMPATIBILITY})
    # Install package files:
    install(FILES
        ${PROJECT_BINARY_DIR}/${package_name}-config.cmake
        ${PROJECT_BINARY_DIR}/${package_name}-config-version.cmake
        DESTINATION ${relative_install_cmake_package_dir})
    # Uninstall script
    if(ARG_UNINSTALL_SCRIPT)
        install_cmake_uninstall_script("${relative_install_cmake_package_dir}" ${ARG_UNINSTALL_SCRIPT})
    endif()
endfunction()

function(cpp_library_link_libraries)
  # Args:
  set(options "")
  set(params "OBJECT;SHARED;STATIC")
  set(lists "PUBLIC;PRIVATE;INTERFACE")
  # Parse args:
  cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
  fatal_if_none_is_def("At least one argument among 'STATIC', 'SHARED' is required " ARG_SHARED ARG_STATIC)
  if(NOT ARG_OBJECT)
    _object_name_from_shared_static(ARG_OBJECT ARG_SHARED ARG_STATIC)
  endif()
  if(TARGET ${ARG_OBJECT})
    target_link_libraries(${ARG_OBJECT} PRIVATE ${ARG_PUBLIC} ${ARG_PRIVATE})
  endif()
  if(TARGET ${ARG_STATIC})
    if(NOT TARGET ${ARG_OBJECT})
      target_link_libraries(${ARG_STATIC} PRIVATE ${ARG_PRIVATE})
    endif()
    target_link_libraries(${ARG_STATIC} INTERFACE ${ARG_INTERFACE})
    target_link_libraries(${ARG_STATIC} PUBLIC ${ARG_PUBLIC})
  endif()
  if(TARGET ${ARG_SHARED})
    if(NOT TARGET ${ARG_OBJECT})
      target_link_libraries(${ARG_SHARED} PRIVATE ${ARG_PRIVATE})
    endif()
    target_link_libraries(${ARG_SHARED} INTERFACE ${ARG_INTERFACE})
    target_link_libraries(${ARG_SHARED} PUBLIC ${ARG_PUBLIC})
  endif()
endfunction()
