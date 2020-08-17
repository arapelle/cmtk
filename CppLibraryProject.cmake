
include(${CMAKE_CURRENT_LIST_DIR}/CppProject.cmake)

function(add_cpp_library_examples)
    # Args:
    set(options "")
    set(params "STATIC;SHARED")
    set(lists "SOURCES;DEPENDENCIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    if(NOT ARG_STATIC AND NOT ARG_SHARED)
        message(FATAL_ERROR "Provide SHARED or STATIC library target!")
    elseif(ARG_SHARED AND TARGET ${ARG_SHARED})
        set(library_name ${ARG_SHARED})
    elseif(ARG_STATIC AND TARGET ${ARG_STATIC})
        set(library_name ${ARG_STATIC})
    endif()
    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "You must provide a list of example source files.")
    endif()
    #
    foreach(filename ${ARG_SOURCES})
        get_filename_component(example_prog ${filename} NAME_WE)
        add_executable(${example_prog} ${filename})
        target_link_libraries(${example_prog} PRIVATE ${library_name} ${ARG_DEPENDENCIES})
    endforeach()
endfunction()

function(add_cpp_library_tests)
    # Args:
    set(options "")
    set(params "STATIC;SHARED")
    set(lists "SOURCES;DEPENDENCIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    if(NOT ARG_STATIC AND NOT ARG_SHARED)
        message(FATAL_ERROR "Provide SHARED or STATIC library target!")
    elseif(ARG_SHARED AND TARGET ${ARG_SHARED})
        set(library_name ${ARG_SHARED})
    elseif(ARG_STATIC AND TARGET ${ARG_STATIC})
        set(library_name ${ARG_STATIC})
    endif()
    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "You must provide a list of test source files.")
    endif()
    # Find GTest:
    if(NOT GTest_FOUND)
        include(GoogleTest)
        find_package(GTest REQUIRED)
    endif()
    #
    foreach(filename ${ARG_SOURCES})
        get_filename_component(test_prog ${filename} NAME_WE)
        add_executable(${test_prog} ${filename})
        target_link_libraries(${test_prog} PRIVATE ${library_name} ${ARG_DEPENDENCIES}
            GTest::GTest)
        gtest_discover_tests(${test_prog} TEST_PREFIX ${cpp_lib}::)
    endforeach()
endfunction()

function(generate_verbose_library_config_file package_config_file)
    generate_basic_package_config_file(${package_config_file})
    file(APPEND ${package_config_file}
         "
get_target_property(project_confs ${PROJECT_NAME} IMPORTED_CONFIGURATIONS)
if(project_confs)
    foreach(project_conf \${project_confs})
        # Get shared
        get_target_property(shared-path ${PROJECT_NAME} IMPORTED_LOCATION_\${project_conf})
        get_filename_component(shared-name \${shared-path} NAME)
        # Get static
        get_target_property(static-path ${PROJECT_NAME}-static IMPORTED_LOCATION_\${project_conf})
        get_filename_component(static-name \${static-path} NAME)
        message(STATUS \"Found ${PROJECT_NAME} \${project_conf}: (found version \\\"${PROJECT_VERSION}\\\"): \${shared-name} \${static-name}\")
    endforeach()
endif()
")
endfunction()

function(library_build_options library_name)
    # Args:
    set(options "STATIC;SHARED;EXAMPLE;TEST")
    set(params "TEST_DIR;EXAMPLE_DIR")
    set(lists "")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Set default value if needed:
    if(NOT ARG_TEST_DIR)
        set(test_dir "test")
    else()
        set(test_dir "${ARG_TEST_DIR}")
    endif()
    if(NOT ARG_EXAMPLE_DIR)
        set(example_dir "example")
    else()
        set(example_dir "${ARG_EXAMPLE_DIR}")
    endif()
    # Options:
    if(${ARG_STATIC})
        option(${library_name}_BUILD_STATIC_LIB "Indicates if we build a STATIC library." ON)
    endif()
    if(${ARG_SHARED})
        option(${library_name}_BUILD_SHARED_LIB "Indicates if we build a SHARED library." ON)
    endif()
    if(${ARG_EXAMPLE} AND EXISTS "${PROJECT_SOURCE_DIR}/${example_dir}/CMakeLists.txt")
        option(${library_name}_BUILD_EXAMPLES "Indicates if we build the examples or not." OFF)
    endif()
    if(${ARG_TEST} AND EXISTS "${PROJECT_SOURCE_DIR}/${test_dir}/CMakeLists.txt")
        option(${library_name}_BUILD_TESTS "Indicates if we build the tests or not." OFF)
    endif()
    # Check static or shared:
    if(NOT ${${library_name}_BUILD_SHARED_LIB} AND NOT ${${library_name}_BUILD_STATIC_LIB})
        message(FATAL_ERROR "You did not choose which target(s) to build (SHARED, STATIC).")
    endif()
endfunction()

function(add_cpp_library library_name build_shared build_static)
    include(GNUInstallDirs)
    # Args:
    set(options "")
    set(params "CXX_STANDARD;INCLUDE_DIRECTORIES;INPUT_VERSION_HEADER;OUTPUT_VERSION_HEADER;"
                "OBJECT;SHARED;STATIC;BUILT_TARGETS;"
                "LIBRARY_OUTPUT_DIRECTORY;ARCHIVE_OUTPUT_DIRECTORY")
    set(lists "HEADERS;SOURCES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 3 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    if(NOT ${build_shared} AND NOT ${build_static})
        message(FATAL_ERROR "You did not choose which target(s) to build (build_shared, build_static).")
    endif()
    if(${build_shared} AND NOT ARG_SHARED)
        message(FATAL_ERROR "You want to build a shared library but you did not provide the shared target name (SHARED).")
    endif()
    if(${build_static} AND NOT ARG_STATIC)
        message(FATAL_ERROR "You want to build a static library but you did not provide the static target name (STATIC).")
    endif()
    if(NOT ARG_OBJECT)
        set(ARG_OBJECT "${library_name}-object")
    endif()
    if(NOT ARG_HEADERS)
        message(FATAL_ERROR "You must provide header files (HEADERS).")
    endif()
    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "You must provide source files (SOURCES).")
    endif()
    # Set target name variables:
    set(object_target ${ARG_OBJECT})
    set(shared_target ${ARG_SHARED})
    set(static_target ${ARG_STATIC})
    # Generate header version file, if wanted:
    if(ARG_OUTPUT_VERSION_HEADER)
        generate_version_header(INPUT_VERSION_HEADER ${ARG_INPUT_VERSION_HEADER}
                                OUTPUT_VERSION_HEADER ${PROJECT_BINARY_DIR}/include/${library_name}/${ARG_OUTPUT_VERSION_HEADER})
    endif()
    # Object target:
    add_library(${object_target} OBJECT ${ARG_HEADERS} ${ARG_SOURCES})
    foreach(include_dir ${ARG_INCLUDE_DIRECTORIES})
        target_include_directories(${object_target} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/${include_dir}>)
    endforeach()
    target_include_directories(${object_target} PUBLIC $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>)
    target_compile_features(${object_target} PUBLIC cxx_std_${ARG_CXX_STANDARD})
    set_property(TARGET ${object_target} PROPERTY POSITION_INDEPENDENT_CODE 1)
    if(MSVC)
        target_compile_options(${object_target} PRIVATE /Wall)
    elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
        target_compile_options(${object_target} PRIVATE -Wall -Wextra -pedantic)
    endif()
    # Shared target:
    if(${build_shared})
        add_library(${shared_target} SHARED $<TARGET_OBJECTS:${object_target}>)
        target_compile_features(${shared_target} PUBLIC cxx_std_${ARG_CXX_STANDARD})
        target_include_directories(${shared_target} PUBLIC $<INSTALL_INTERFACE:include>)
        foreach(include_dir ${ARG_INCLUDE_DIRECTORIES})
            target_include_directories(${shared_target} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/${include_dir}>)
        endforeach()
        target_include_directories(${shared_target} INTERFACE $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>)
        set_target_properties(${shared_target} PROPERTIES DEBUG_POSTFIX "-d" SOVERSION ${PROJECT_VERSION})
        set(library_targets ${library_targets} ${shared_target})
        if(ARG_LIBRARY_OUTPUT_DIRECTORY)
            set_target_properties(${shared_target} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${ARG_LIBRARY_OUTPUT_DIRECTORY})
        endif()
    endif()
    # Static target:
    if(${build_static})
        add_library(${static_target} STATIC $<TARGET_OBJECTS:${object_target}>)
        target_compile_features(${static_target} PUBLIC cxx_std_${ARG_CXX_STANDARD})
        target_include_directories(${static_target} PUBLIC $<INSTALL_INTERFACE:include>)
        foreach(include_dir ${ARG_INCLUDE_DIRECTORIES})
            target_include_directories(${static_target} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/${include_dir}>)
        endforeach()
        target_include_directories(${static_target} INTERFACE $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>)
        set_target_properties(${static_target} PROPERTIES DEBUG_POSTFIX "-d")
        set(library_targets ${library_targets} ${static_target})
        if(ARG_ARCHIVE_OUTPUT_DIRECTORY)
            set_target_properties(${static_target} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${ARG_ARCHIVE_OUTPUT_DIRECTORY})
        endif()
    endif()
    # Returns built targets:
    if(ARG_BUILT_TARGETS)
        set(${ARG_BUILT_TARGETS} ${${ARG_BUILT_TARGETS}} ${library_targets} PARENT_SCOPE)
    endif()
endfunction()

function(add_cpp_honly_library library_name)
    include(GNUInstallDirs)
    # Args:
    set(options "")
    set(params "INCLUDE_DIRECTORIES;INPUT_VERSION_HEADER;OUTPUT_VERSION_HEADER;")
    set(lists "")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Generate header version file, if wanted:
    if(ARG_OUTPUT_VERSION_HEADER)
        generate_version_header(INPUT_VERSION_HEADER ${ARG_INPUT_VERSION_HEADER}
                                OUTPUT_VERSION_HEADER ${PROJECT_BINARY_DIR}/include/${library_name}/${ARG_OUTPUT_VERSION_HEADER})
    endif()
    # Interface target:
    add_library(${library_name} INTERFACE)
    target_include_directories(${library_name} INTERFACE $<INSTALL_INTERFACE:include>)
    foreach(include_dir ${ARG_INCLUDE_DIRECTORIES})
        target_include_directories(${library_name} INTERFACE $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/${include_dir}>)
    endforeach()
    target_include_directories(${library_name} INTERFACE $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>)
    if(ARG_CXX_STANDARD)
        target_compile_features(${library_name} INTERFACE cxx_std_${ARG_CXX_STANDARD})
    endif()
endfunction()

function(install_cpp_library export_name targets)
    include(GNUInstallDirs)
    include(CMakePackageConfigHelpers)
    # Args:
    set(options "NO_UNINSTALL_SCRIPT;BASIC_PACKAGE_CONFIG_FILE;VERBOSE_PACKAGE_CONFIG_FILE;INPUT_PACKAGE_CONFIG_FILE")
    set(params "INCLUDE_DIRECTORY;VERSION;VERSION_COMPATIBILITY")
    set(lists "")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 2 "ARG" "${options}" "${params}" "${lists}")
    # Check and set args:
    if(NOT ARG_INCLUDE_DIRECTORY)
        message(FATAL_ERROR "Provide INCLUDE_DIRECTORY!")
    endif()
    if(NOT ARG_VERSION)
        set(ARG_VERSION ${PROJECT_VERSION})
    endif()
    if(NOT ARG_VERSION_COMPATIBILITY)
        set(ARG_VERSION_COMPATIBILITY SameMajorVersion)
    endif()
    # Set install directory paths:
    set(relative_install_cmake_package_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${export_name}")
    set(install_cmake_package_dir "${CMAKE_INSTALL_PREFIX}/${relative_install_cmake_package_dir}")
    # Install targets:
    install(TARGETS ${targets} EXPORT ${export_name})
    install(DIRECTORY ${ARG_INCLUDE_DIRECTORY}/${export_name} DESTINATION include)
    install(DIRECTORY ${PROJECT_BINARY_DIR}/include/${export_name} DESTINATION include)
    install(EXPORT ${export_name} DESTINATION ${relative_install_cmake_package_dir})
    # Create package config file:
    if(ARG_BASIC_PACKAGE_CONFIG_FILE)
        generate_basic_package_config_file(${PROJECT_BINARY_DIR}/${export_name}-config.cmake)
    elseif(ARG_VERBOSE_PACKAGE_CONFIG_FILE)
        generate_verbose_library_config_file(${PROJECT_BINARY_DIR}/${export_name}-config.cmake)
    elseif(ARG_INPUT_PACKAGE_CONFIG_FILE)
        configure_package_config_file(${ARG_INPUT_PACKAGE_CONFIG_FILE}
            "${PROJECT_BINARY_DIR}/${export_name}-config.cmake"
            INSTALL_DESTINATION ${relative_install_cmake_package_dir}
            NO_SET_AND_CHECK_MACRO # ??
            NO_CHECK_REQUIRED_COMPONENTS_MACRO) # ??
    endif()
    # Create package version file:
    write_basic_package_version_file("${PROJECT_BINARY_DIR}/${export_name}-config-version.cmake"
        VERSION ${ARG_VERSION}
        COMPATIBILITY ${ARG_VERSION_COMPATIBILITY})
    # Install package files:
    install(FILES
        ${PROJECT_BINARY_DIR}/${export_name}-config.cmake
        ${PROJECT_BINARY_DIR}/${export_name}-config-version.cmake
        DESTINATION ${install_cmake_package_dir})
    # Uninstall script
    if(NOT NO_UNINSTALL_SCRIPT)
        install_cmake_uninstall_script(${install_cmake_package_dir})
    endif()
endfunction()
