
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
            GTest::gtest)
        gtest_discover_tests(${test_prog} TEST_PREFIX ${cpp_lib}::)
    endforeach()
endfunction()

function(generate_verbose_library_config_file package_config_file package_name version export_names)
    generate_package_config_file_beginning(${package_config_file} ${export_names})
    generate_package_config_file_end(${package_config_file} ${package_name})
    set(content "")
    string(APPEND content "
message(STATUS \"Found package ${package_name} ${version}\")

")
    file(APPEND ${package_config_file} ${content})
endfunction()

function(library_build_options library_name)
    # Args:
    set(options "STATIC;SHARED;HEADER_ONLY;EXAMPLE;TEST")
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
        if(ARG_HEADER_ONLY)
            message(FATAL_ERROR "There is no sense to have HEADER_ONLY and STATIC both at the same time.")
        else()
            option(${library_name}_BUILD_STATIC_LIB "Indicates if we build a STATIC library." ON)
        endif()
    endif()
    if(${ARG_SHARED})
        if(ARG_HEADER_ONLY)
            message(FATAL_ERROR "There is no sense to have HEADER_ONLY and SHARED both at the same time.")
        else()
            option(${library_name}_BUILD_SHARED_LIB "Indicates if we build a SHARED library." ON)
        endif()
    endif()
    if(${ARG_EXAMPLE} AND EXISTS "${PROJECT_SOURCE_DIR}/${example_dir}/CMakeLists.txt")
        option(${library_name}_BUILD_EXAMPLES "Indicates if we build the examples or not." OFF)
    endif()
    if(${ARG_TEST} AND EXISTS "${PROJECT_SOURCE_DIR}/${test_dir}/CMakeLists.txt")
        option(${library_name}_BUILD_TESTS "Indicates if we build the tests or not." OFF)
    endif()
    # Check static or shared:
    if(NOT ARG_HEADER_ONLY)
        if((NOT ${library_name}_BUILD_SHARED_LIB OR NOT ${${library_name}_BUILD_SHARED_LIB})
           AND
           (NOT ${library_name}_BUILD_STATIC_LIB OR NOT ${${library_name}_BUILD_STATIC_LIB}))
            message(FATAL_ERROR "You did not choose which target(s) to build (SHARED, STATIC).")
        endif()
    endif()
endfunction()

function(add_cpp_library library_name build_shared build_static)
    include(GNUInstallDirs)
    # Args:
    set(options "")
    set(params "CXX_STANDARD;INCLUDE_DIRECTORIES;INPUT_VERSION_HEADER;OUTPUT_VERSION_HEADER;"
                "OBJECT;SHARED;STATIC;BUILT_TARGETS;NAMESPACE;"
                "LIBRARY_OUTPUT_DIRECTORY;ARCHIVE_OUTPUT_DIRECTORY")
    set(lists "HEADERS;SOURCES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 3 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    if(NOT ${build_shared} AND NOT ${build_static})
        message(FATAL_ERROR "You did not choose which target(s) to build (build_shared, build_static).")
    endif()
    if(${build_shared} AND NOT ARG_SHARED)
        set(ARG_SHARED "${library_name}")
    endif()
    if(${build_static} AND NOT ARG_STATIC)
        set(ARG_STATIC "${library_name}-static")
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
        if(ARG_NAMESPACE)
            add_library(${ARG_NAMESPACE}${shared_target} ALIAS ${shared_target})
        endif()
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
        if(ARG_NAMESPACE)
            add_library(${ARG_NAMESPACE}${static_target} ALIAS ${static_target})
        endif()
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
    set(params "CXX_STANDARD;INCLUDE_DIRECTORIES;INPUT_VERSION_HEADER;OUTPUT_VERSION_HEADER;NAMESPACE;")
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
    if(ARG_NAMESPACE)
        add_library(${ARG_NAMESPACE}${library_name} ALIAS ${library_name})
    endif()
endfunction()

function(install_cpp_library_targets library)
    include(GNUInstallDirs)
    # Args:
    set(options "")
    set(params "NAMESPACE;EXPORT;COMPONENT")
    set(lists "TARGETS;INCLUDE_DIRECTORIES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Check and set args:
    if(NOT ARG_EXPORT)
        set(ARG_EXPORT "${library}")
    endif()
    if(NOT ARG_TARGETS)
        message(FATAL_ERROR "You must provide TARGETS")
    endif()
    if(NOT ARG_INCLUDE_DIRECTORIES)
        message(FATAL_ERROR "You must provide INCLUDE_DIRECTORIES")
    endif()
    # Set install directory paths:
    set(relative_install_cmake_package_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${library}")
    # Install targets:
    if(ARG_EXPORT)
        set(install_targets_args EXPORT ${ARG_EXPORT})
    endif()
    if(ARG_COMPONENT)
        list(APPEND install_targets_args LIBRARY COMPONENT ${ARG_COMPONENT})
    endif()
    install(TARGETS ${ARG_TARGETS} ${install_targets_args})
    # Install includes:
    foreach(include_dir ${ARG_INCLUDE_DIRECTORIES})
        install(DIRECTORY ${include_dir} DESTINATION include)
    endforeach()
    if(EXISTS ${PROJECT_BINARY_DIR}/include/${library})
        install(DIRECTORY ${PROJECT_BINARY_DIR}/include/${library} DESTINATION include)
    endif()
    # Install export:
    if(ARG_EXPORT)
        if(ARG_NAMESPACE)
            set(install_export_args NAMESPACE ${ARG_NAMESPACE})
        endif()
        if(ARG_COMPONENT)
            list(APPEND install_export_args COMPONENT ${ARG_COMPONENT})
        endif()
        install(EXPORT ${ARG_EXPORT} DESTINATION ${relative_install_cmake_package_dir} ${install_export_args})
    endif()
endfunction()

function(install_package package_name)
    include(GNUInstallDirs)
    include(CMakePackageConfigHelpers)
    # Args:
    set(options "NO_UNINSTALL_SCRIPT;UNINSTALL_ALL;BASIC_PACKAGE_CONFIG_FILE;VERBOSE_PACKAGE_CONFIG_FILE")
    set(params "VERSION;VERSION_COMPATIBILITY;INPUT_PACKAGE_CONFIG_FILE")
    set(lists "EXPORT_NAMES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Check and set args:
    if(NOT ARG_VERSION)
        set(ARG_VERSION ${PROJECT_VERSION})
    endif()
    if(NOT ARG_VERSION_COMPATIBILITY)
        set(ARG_VERSION_COMPATIBILITY SameMajorVersion)
    endif()
    if(ARG_BASIC_PACKAGE_CONFIG_FILE OR ARG_VERBOSE_PACKAGE_CONFIG_FILE)
        if(NOT ARG_EXPORT_NAMES)
            message(FATAL_ERROR "You have to provide EXPORT_NAMES when you use BASIC_PACKAGE_CONFIG_FILE or VERBOSE_PACKAGE_CONFIG_FILE!")
        endif()
    endif()
    if(ARG_NO_UNINSTALL AND ARG_UNINSTALL_ALL)
        message(FATAL_ERROR "Options NO_UNINSTALL and UNINSTALL_ALL are not compatible!")
    endif()
    # Set install directory paths:
    set(relative_install_cmake_package_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${package_name}")
    # Create package config file:
    set(config_cmake_in ${PROJECT_BINARY_DIR}/${package_name}-config.cmake.in)
    if(ARG_BASIC_PACKAGE_CONFIG_FILE)
        generate_basic_package_config_file(${PROJECT_BINARY_DIR}/${package_name}-config.cmake.in ${package_name} ${ARG_EXPORT_NAMES})
    elseif(ARG_VERBOSE_PACKAGE_CONFIG_FILE)
        generate_verbose_library_config_file(${PROJECT_BINARY_DIR}/${package_name}-config.cmake.in  ${package_name} ${ARG_VERSION} ${ARG_EXPORT_NAMES})
    elseif(ARG_INPUT_PACKAGE_CONFIG_FILE)
        set(config_cmake_in ${ARG_INPUT_PACKAGE_CONFIG_FILE})
    endif()
    configure_package_config_file(${config_cmake_in}
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
    if(NOT ARG_NO_UNINSTALL_SCRIPT)
        set(uninstall_options "")
        if(ARG_UNINSTALL_ALL)
            list(APPEND uninstall_options "ALL")
        endif()
        install_cmake_uninstall_script("${relative_install_cmake_package_dir}" ${uninstall_options})
    endif()
endfunction()

function(cpp_library_targets_link_libraries library_name)
    # Args:
    set(options "HEADER_ONLY")
    set(params "OBJECT;SHARED;STATIC")
    set(lists "PUBLIC;PRIVATE;INTERFACE")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    if(ARG_HEADER_ONLY)
        if(ARG_SHARED OR ARG_STATIC OR ARG_OBJECT)
            message(FATAL_ERROR "Parameters 'OBJECT', 'STATIC' or 'SHARED' have no sense with HEADER_ONLY.")
        endif()
        target_link_libraries(${library_name} INTERFACE ${ARG_PUBLIC} ${ARG_INTERFACE})
    else()
        if(NOT ARG_SHARED)
            set(ARG_SHARED "${library_name}")
        endif()
        if(NOT ARG_STATIC)
            set(ARG_STATIC "${library_name}-static")
        endif()
        if(NOT ARG_OBJECT)
            set(ARG_OBJECT "${library_name}-object")
        endif()
        if(NOT TARGET ${ARG_OBJECT})
            message(FATAL_ERROR "'${ARG_OBJECT}' is not a target.")
        endif()
        target_link_libraries(${ARG_OBJECT} PRIVATE ${ARG_PUBLIC} ${ARG_PRIVATE})
        if(TARGET ${ARG_STATIC})
            target_link_libraries(${ARG_STATIC} INTERFACE ${ARG_INTERFACE})
            target_link_libraries(${ARG_STATIC} PUBLIC ${ARG_PUBLIC})
        endif()
        if(TARGET ${ARG_SHARED})
            target_link_libraries(${ARG_SHARED} INTERFACE ${ARG_INTERFACE})
            target_link_libraries(${ARG_SHARED} PUBLIC ${ARG_PUBLIC})
        endif()
    endif()
endfunction()
