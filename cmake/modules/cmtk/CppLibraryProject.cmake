
include(${CMAKE_CURRENT_LIST_DIR}/Project.cmake)

function(add_public_cpp_library_examples cpp_lib)
    set(example_output_dir ${CMAKE_BUILD_TYPE})
    set(cpp_lib_object ${cpp_lib}-object)
    set(cpp_lib_shared ${cpp_lib})
    set(cpp_lib_static ${cpp_lib}-static)
    if(TARGET ${cpp_lib_shared})
        set(cpp_lib ${cpp_lib_shared})
    else()
        set(cpp_lib ${cpp_lib_static})
    endif()

    file(GLOB cpp_program_files "*.cpp")
    foreach(filename ${cpp_program_files})
        get_filename_component(example_prog ${filename} NAME_WE)
        add_executable(${example_prog} ${filename})
        set_target_properties(${example_prog} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${example_output_dir})
        target_compile_features(${example_prog} PRIVATE cxx_std_17)
        target_include_directories(${example_prog} PRIVATE
            $<TARGET_PROPERTY:${cpp_lib},INCLUDE_DIRECTORIES>
            $<TARGET_PROPERTY:${cpp_lib_object},INCLUDE_DIRECTORIES>)
        target_link_libraries(${example_prog} PRIVATE $<TARGET_NAME:${cpp_lib}>)
    endforeach()
endfunction()

function(add_public_cpp_library_tests cpp_lib)
    set(test_output_dir ${CMAKE_BUILD_TYPE})
    set(cpp_lib_object ${cpp_lib}-object)
    set(cpp_lib_shared ${cpp_lib})
    set(cpp_lib_static ${cpp_lib}-static)
    if(TARGET ${cpp_lib_shared})
        set(cpp_lib ${cpp_lib_shared})
    else()
        set(cpp_lib ${cpp_lib_static})
    endif()

    if(NOT GTest_FOUND)
        include(GoogleTest)
        find_package(GTest REQUIRED)
    endif()

    file(GLOB cpp_program_files "*.cpp")
    foreach(filename ${cpp_program_files})
        get_filename_component(test_prog ${filename} NAME_WE)
        add_executable(${test_prog} ${filename})
        set_target_properties(${test_prog} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${test_output_dir})
        target_compile_features(${test_prog} PRIVATE cxx_std_17)
        target_include_directories(${test_prog} PRIVATE
            $<TARGET_PROPERTY:${cpp_lib},INCLUDE_DIRECTORIES>
            $<TARGET_PROPERTY:${cpp_lib_object},INCLUDE_DIRECTORIES>)
        target_link_libraries(${test_prog} PRIVATE $<TARGET_NAME:${cpp_lib}> GTest::GTest)
        gtest_discover_tests(${test_prog} TEST_PREFIX ${cpp_lib}::)
    endforeach()
endfunction()

function(generate_verbose_public_library_config_file package_config_file)
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

function(add_public_cpp_library)
    #-----
    # Args
    set(options "BASIC_PACKAGE_CONFIG_FILE;VERBOSE_PACKAGE_CONFIG_FILE")
    set(params "CXX_STANDARD;INPUT_VERSION_HEADER;VERSION_HEADER;INPUT_PACKAGE_CONFIG_FILE;INCLUDE_DIR;SRC_DIR;EXAMPLE_DIR;TEST_DIR")
    set(lists "")

    # Parse args
    cmake_parse_arguments(PARSE_ARGV 0 "FARG" "${options}" "${params}" "${lists}")

    # Set default value if needed
    if(NOT FARG_CXX_STANDARD)
        set(FARG_CXX_STANDARD 17)
    endif()
    foreach(idir include src example test)
        string(TOUPPER ${idir} uidir)
        if(FARG_${uidir}_DIR)
            set(${idir}_dir ${FARG_${uidir}_DIR})
        else()
            set(${idir}_dir ${idir})
        endif()
    endforeach()

    # Check args values
    if(NOT FARG_BASIC_PACKAGE_CONFIG_FILE AND NOT FARG_VERBOSE_PACKAGE_CONFIG_FILE AND NOT FARG_INPUT_PACKAGE_CONFIG_FILE)
        message(FATAL_ERROR "Package config file argument is missing. [BASIC_PACKAGE_CONFIG_FILE|VERBOSE_PACKAGE_CONFIG_FILE|INPUT_PACKAGE_CONFIG_FILE]")
    endif()
    #-----

    #-----
    # Configure C++ standard
    set(CMAKE_CXX_STANDARD ${FARG_CXX_STANDARD})
    set(CMAKE_CXX_STANDARD_REQUIRED ON)

    #-----
    # Project options
    option(${PROJECT_NAME}_BUILD_SHARED_LIB "Indicates if we build a SHARED library." ON)
    option(${PROJECT_NAME}_BUILD_STATIC_LIB "Indicates if we build a STATIC library." ON)
    if(EXISTS "${PROJECT_SOURCE_DIR}/test/CMakeLists.txt")
        option(${PROJECT_NAME}_BUILD_TESTS "Indicates if we build the tests or not." OFF)
    endif()
    if(EXISTS "${PROJECT_SOURCE_DIR}/example/CMakeLists.txt")
        option(${PROJECT_NAME}_BUILD_EXAMPLES "Indicates if we build the examples or not." OFF)
    endif()

    #-----
    # Output paths
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BUILD_TYPE}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BUILD_TYPE}/lib)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BUILD_TYPE}/lib)

    #-----
    # Status
    message(STATUS "PROJECT : ${PROJECT_NAME} v${PROJECT_VERSION}")
    message(STATUS "BUILD   : ${CMAKE_BUILD_TYPE}")
    message(STATUS "CPPCOMP : ${CMAKE_CXX_COMPILER} ${CMAKE_CXX_COMPILER_VERSION}")

    if(NOT ${${PROJECT_NAME}_BUILD_SHARED_LIB} AND NOT ${${PROJECT_NAME}_BUILD_STATIC_LIB})
        message(FATAL_ERROR "You did not choose which target(s) to build (SHARED, STATIC).")
    endif()
    #-----

    #-----
    # Add target library
    include(GNUInstallDirs)

    set(project_object_target ${PROJECT_NAME}-object)
    set(project_shared_target ${PROJECT_NAME})
    set(project_static_target ${PROJECT_NAME}-static)
    set(export_name ${PROJECT_NAME})

    # Generate header version file, if wanted
    if(FARG_VERSION_HEADER)
        if(IS_ABSOLUTE ${FARG_VERSION_HEADER})
            message(FATAL_ERROR "Provide a relative path for generated version file!")
        endif()
        generate_version_header(INPUT_VERSION_HEADER ${FARG_INPUT_VERSION_HEADER}
                                VERSION_HEADER ${PROJECT_BINARY_DIR}/include/${PROJECT_NAME}/${FARG_VERSION_HEADER})
    endif()

    # Object target
    file(GLOB_RECURSE target_header_files ${include_dir}/*)
    file(GLOB_RECURSE target_src_files ${src_dir}/*)
    add_library(${project_object_target} OBJECT ${target_header_files} ${target_src_files})
    target_include_directories(${project_object_target} PUBLIC
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/${include_dir}>
        $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>)
    set_property(TARGET ${project_object_target} PROPERTY POSITION_INDEPENDENT_CODE 1)
    if(MSVC)
        target_compile_options(${project_object_target} PRIVATE /Wall)
    elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
        target_compile_options(${project_object_target} PRIVATE -Wall -Wextra -pedantic)
    endif()

    # Shared target
    if(${${PROJECT_NAME}_BUILD_SHARED_LIB})
        add_library(${project_shared_target} SHARED $<TARGET_OBJECTS:${project_object_target}>)
        target_include_directories(${project_shared_target} PUBLIC $<INSTALL_INTERFACE:include>)
        set_target_properties(${project_shared_target} PROPERTIES DEBUG_POSTFIX "-d" SOVERSION ${PROJECT_VERSION})
        set(project_targets ${project_targets} ${project_shared_target})
    endif()

    # Static target
    if(${${PROJECT_NAME}_BUILD_STATIC_LIB})
        add_library(${project_static_target} STATIC $<TARGET_OBJECTS:${project_object_target}>)
        target_include_directories(${project_static_target} PUBLIC $<INSTALL_INTERFACE:include>)
        set_target_properties(${project_static_target} PROPERTIES DEBUG_POSTFIX "-d")
        set(project_targets ${project_targets} ${project_static_target})
    endif()
    #-----

    #-----
    # Examples
    if(EXISTS "${PROJECT_SOURCE_DIR}/${example_dir}/CMakeLists.txt" AND ${${PROJECT_NAME}_BUILD_EXAMPLES})
        add_subdirectory(${example_dir})
    endif()

    #-----
    # Tests
    if(EXISTS "${PROJECT_SOURCE_DIR}/${test_dir}/CMakeLists.txt" AND BUILD_TESTING AND ${${PROJECT_NAME}_BUILD_TESTS})
        add_subdirectory(${test_dir})
    endif()
    #-----

    #-----
    # Install
    include(CMakePackageConfigHelpers)

    set(relative_install_cmake_package_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
    set(install_cmake_package_dir "${CMAKE_INSTALL_PREFIX}/${relative_install_cmake_package_dir}")

    install(TARGETS ${project_targets} EXPORT ${export_name})
    install(DIRECTORY ${include_dir}/${PROJECT_NAME} DESTINATION include)
    install(DIRECTORY ${PROJECT_BINARY_DIR}/include/${PROJECT_NAME} DESTINATION include)
    install(EXPORT ${export_name} DESTINATION ${relative_install_cmake_package_dir})

    # Package config file
    if(FARG_BASIC_PACKAGE_CONFIG_FILE)
        generate_basic_package_config_file(${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake)
    elseif(FARG_VERBOSE_PACKAGE_CONFIG_FILE)
        generate_verbose_public_library_config_file(${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake)
    elseif(FARG_INPUT_PACKAGE_CONFIG_FILE)
        configure_package_config_file(${FARG_INPUT_PACKAGE_CONFIG_FILE}
            "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
            INSTALL_DESTINATION ${relative_install_cmake_package_dir}
            NO_SET_AND_CHECK_MACRO
            NO_CHECK_REQUIRED_COMPONENTS_MACRO)
    endif()

    # Package version file
    write_basic_package_version_file("${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion)

    install(FILES
        ${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake
        ${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
        DESTINATION ${install_cmake_package_dir})

    # Uninstall script
    install_cmake_uninstall_script(${install_cmake_package_dir})
    #-----
endfunction()
