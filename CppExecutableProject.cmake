
include(${CMAKE_CURRENT_LIST_DIR}/CppProject.cmake)

function(add_public_cpp_executable)
    #-----
    # Args
    set(options "")
    set(params "CXX_STANDARD;INPUT_VERSION_HEADER;VERSION_HEADER;INCLUDE_DIR;SRC_DIR;EXAMPLE_DIR;TEST_DIR")
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
    #-----

    #-----
    # Project options
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
    #-----

    #-----
    # Add target binary
    include(GNUInstallDirs)

    set(project_object_target ${PROJECT_NAME}-object)
    set(project_target ${PROJECT_NAME})
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
    target_compile_features(${project_object_target} PUBLIC cxx_std_${FARG_CXX_STANDARD})
    set_property(TARGET ${project_object_target} PROPERTY POSITION_INDEPENDENT_CODE 1)
    if(MSVC)
        target_compile_options(${project_object_target} PRIVATE /Wall)
    elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
        target_compile_options(${project_object_target} PRIVATE -Wall -Wextra -pedantic)
    endif()

    # Binary target
    add_executable(${project_target} $<TARGET_OBJECTS:${project_object_target}>)
    target_compile_features(${project_shared_target} PUBLIC cxx_std_${FARG_CXX_STANDARD})
    set_target_properties(${project_target} PROPERTIES DEBUG_POSTFIX "-d")
    set(project_targets ${project_targets} ${project_target})
    #-----

    #-----
    # Install
    include(CMakePackageConfigHelpers)

    set(relative_install_cmake_package_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
    set(install_cmake_package_dir "${CMAKE_INSTALL_PREFIX}/${relative_install_cmake_package_dir}")

    install(TARGETS ${project_targets} EXPORT ${export_name})
    #-----
endfunction()
