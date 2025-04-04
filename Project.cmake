
include(${CMAKE_CURRENT_LIST_DIR}/Utility.cmake)

function(disable_in_source_build)
    file(REAL_PATH ${CMAKE_SOURCE_DIR} cmake_src_dir EXPAND_TILDE)
    file(REAL_PATH ${CMAKE_BINARY_DIR} cmake_bin_dir EXPAND_TILDE)
    string(FIND "${cmake_bin_dir}" "${cmake_src_dir}" index)
    if(${index} EQUAL 0)
        set(msg_details "CMAKE_SOURCE_DIR: ${CMAKE_SOURCE_DIR}\nCMAKE_BINARY_DIR: ${CMAKE_BINARY_DIR}")
        message(FATAL_ERROR "In source build is disabled!\nCMAKE_BINARY_DIR must not be located in CMAKE_SOURCE_DIR!\n${msg_details}")
    endif()
endfunction()

function(check_in_source_build)
    option(ENABLE_IN_SOURCE_BUILD "Enable (ON) or Disable (OFF) in source build." OFF)
    if(NOT ${ENABLE_IN_SOURCE_BUILD})
        disable_in_source_build()
    endif()
endfunction()

function(set_build_type_ifndef)
    # Args:
    set(options "")
    set(params "DEFAULT")
    set(lists "BUILD_TYPES")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    if(NOT DEFINED ARG_BUILD_TYPES)
        set(ARG_BUILD_TYPES "Release" "Debug" "MinSizeRel" "RelWithDebInfo")
    endif()
    set_ifndef(ARG_DEFAULT 0)
    if (${ARG_DEFAULT} MATCHES "^[0-9]+$")
        list(GET ARG_BUILD_TYPES ${ARG_DEFAULT} ARG_DEFAULT)
    else()
        list(FIND ARG_BUILD_TYPES ${ARG_DEFAULT} index)
        if(index EQUAL -1)
            message(FATAL_ERROR "Build type '${ARG_DEFAULT}' is not valid: ${ARG_BUILD_TYPES}.")
        endif()
    endif()
    if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
      message(STATUS "Setting build type to '${ARG_DEFAULT}' as none was specified.")
      set(CMAKE_BUILD_TYPE "${ARG_DEFAULT}" CACHE STRING "Choose the type of build." FORCE)
      set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${ARG_BUILD_TYPES})
    endif()
endfunction()

function(set_project_name)
    # Args:
    set(options "")
    set(params "NAME;NAMESPACE;BASE_NAME;FEATURE_NAME;CODE_NAME;CODE_NAMESPACE;CODE_FEATURE_NAME;")
    set(lists "")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    if(DEFINED ARG_BASE_NAME)
        fatal_ifdef("Use FEATURE_NAME, not FEATURE_NAME and BASE_NAME." ARG_FEATURE_NAME)
        message(DEPRECATION "BASE_NAME is deprecated. You should use FEATURE_NAME now.")
        set(ARG_FEATURE_NAME "${ARG_BASE_NAME}")
    endif()
    fatal_if_none_is_def("NAME or FEATURE_NAME is missing." ARG_NAME ARG_FEATURE_NAME)
    if(DEFINED ARG_NAME)
        fatal_ifdef("NAMESPACE and FEATURE_NAME must not be provided if NAME is provided." ARG_NAMESPACE ARG_FEATURE_NAME)
        set(pj_name "${ARG_NAME}")
        set(PROJECT_NAME "${pj_name}" PARENT_SCOPE)
        set_ifndef(ARG_CODE_NAME "${ARG_NAME}")
        set(PROJECT_CODE_NAME "${ARG_CODE_NAME}" PARENT_SCOPE)
    else()
        fatal_ifndef("FEATURE_NAME is provided but NAMESPACE is missing." ARG_NAMESPACE)
        set(PROJECT_NAMESPACE "${ARG_NAMESPACE}" PARENT_SCOPE)
        set(PROJECT_FEATURE_NAME "${ARG_FEATURE_NAME}" PARENT_SCOPE)
        if(DEFINED ARG_BASE_NAME)
            set(PROJECT_BASE_NAME "${ARG_FEATURE_NAME}" PARENT_SCOPE)
        endif()
        set_ifndef(ARG_CODE_NAMESPACE "${ARG_NAMESPACE}")
        set_ifndef(ARG_CODE_FEATURE_NAME "${ARG_FEATURE_NAME}")
        set(PROJECT_CODE_NAMESPACE "${ARG_CODE_NAMESPACE}" PARENT_SCOPE)
        set(PROJECT_CODE_FEATURE_NAME "${ARG_CODE_FEATURE_NAME}" PARENT_SCOPE)
        set(pj_name "${ARG_NAMESPACE}-${ARG_FEATURE_NAME}")
        set(PROJECT_NAME "${pj_name}" PARENT_SCOPE)
        set(PROJECT_CODE_NAME "${ARG_CODE_NAMESPACE}-${ARG_CODE_FEATURE_NAME}" PARENT_SCOPE)
    endif()
    make_upper_c_identifier("${pj_name}" upper_var_name)
    set(PROJECT_UPPER_VAR_NAME "${upper_var_name}" PARENT_SCOPE)
    make_lower_c_identifier("${pj_name}" lower_var_name)
    set(PROJECT_LOWER_VAR_NAME "${lower_var_name}" PARENT_SCOPE)
endfunction()

function(set_project_semantic_version basicver)
    # Args:
    set(options "")
    set(params "PRE_RELEASE;BUILD_METADATA")
    set(lists "")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 0 "ARG" "${options}" "${params}" "${lists}")
    #:
    set(PROJECT_VERSION "${basicver}" PARENT_SCOPE)
    set(semantic_version "${basicver}")
    if(DEFINED ARG_PRE_RELEASE)
        string(APPEND semantic_version "-${ARG_PRE_RELEASE}")
    endif()
    if(DEFINED ARG_BUILD_METADATA)
        string(APPEND semantic_version "+${ARG_BUILD_METADATA}")
    endif()
    string(REPLACE "." ";" vlist "${basicver}")
    list(GET vlist 0 major)
    list(GET vlist 1 minor)
    list(GET vlist 2 patch)
    set(PROJECT_VERSION_MAJOR ${major} PARENT_SCOPE)
    set(PROJECT_VERSION_MINOR ${minor} PARENT_SCOPE)
    set(PROJECT_VERSION_PATCH ${patch} PARENT_SCOPE)
    set(PROJECT_VERSION_PRE_RELEASE "${ARG_PRE_RELEASE}" PARENT_SCOPE)
    set(PROJECT_VERSION_BUILD_METADATA "${ARG_BUILD_METADATA}" PARENT_SCOPE)
    set(PROJECT_SEMANTIC_VERSION "${semantic_version}" PARENT_SCOPE)
endfunction()

function(configure_files return_var)
  cmake_parse_arguments(PARSE_ARGV 1 "ARG" "" "BASE_DIR;BINARY_BASE_DIR" "FILES")
  fatal_ifndef("You must provide files to configure (FILES)." ARG_FILES)
  fatal_ifndef("You must provide an source base directory (BASE_DIR)." ARG_BASE_DIR)
  fatal_ifndef("You must provide a binary base directory (BINARY_BASE_DIR)." ARG_BINARY_BASE_DIR)
  file(REAL_PATH ${ARG_BASE_DIR} ARG_BASE_DIR)
  foreach(ifile ${ARG_FILES})
    file(REAL_PATH ${ifile} ifile)
    file(RELATIVE_PATH orpath ${ARG_BASE_DIR} ${ifile})
    get_filename_component(orext ${orpath} LAST_EXT)
    if("${orext}" STREQUAL ".in")
      get_filename_component(ordir ${orpath} DIRECTORY)
      get_filename_component(orname ${orpath} NAME_WLE)
      set(orpath "${ordir}/${orname}")
    endif()
    set(oapath "${ARG_BINARY_BASE_DIR}/${orpath}")
    configure_file(${ifile} ${oapath})
    list(APPEND olist ${oapath})
  endforeach()
  set(${return_var} "${olist}" PARENT_SCOPE)
endfunction()

function(install_uninstall_script package_name)
    include(GNUInstallDirs)
    # Args:
    set(options "ALL")
    set(params "FILENAME;PACKAGE_DIR;VERSION")
    set(lists "")
    # Parse args:
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" "${options}" "${params}" "${lists}")
    # Check args:
    set_ifndef(ARG_FILENAME "uninstall.cmake")
    set_ifndef(ARG_PACKAGE_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${package_name}")
    set_ifndef(ARG_VERSION "${PROJECT_VERSION}")
    set(rel_uninstall_path "${ARG_PACKAGE_DIR}/${ARG_FILENAME}")
    #
    set(uninstall_script_code "
        message(STATUS \"Installing: \${CMAKE_INSTALL_PREFIX}/${rel_uninstall_path}\")
        if(DEFINED CMAKE_INSTALL_MANIFEST_FILES)
            set(uninstall_script \${CMAKE_INSTALL_PREFIX}/${rel_uninstall_path})
            list(APPEND CMAKE_INSTALL_MANIFEST_FILES \${uninstall_script})
            set(files \${CMAKE_INSTALL_MANIFEST_FILES})
        ")
    if(ARG_ALL)
        string(APPEND uninstall_script_code "
            set(CMTK_INSTALL_FILES \${files})
            ")
    else()
        string(APPEND uninstall_script_code "
            if(CMTK_INSTALL_FILES)
                list(REMOVE_ITEM files \${CMTK_INSTALL_FILES})
            endif()
            list(APPEND CMTK_INSTALL_FILES \${files})
            ")
    endif()
    string(APPEND uninstall_script_code "
        file(APPEND \${CMAKE_INSTALL_PREFIX}/${rel_uninstall_path}
        \"
        message(STATUS \\\"Uninstall ${package_name} v${ARG_VERSION} ${CMAKE_BUILD_TYPE}\\\")
        foreach(file \${files})
            while(NOT \\\${file} STREQUAL \${CMAKE_INSTALL_PREFIX})
                if(EXISTS \\\${file} OR IS_SYMLINK \\\${file})
                    if(IS_DIRECTORY \\\${file})
                        file(GLOB dir_files \\\${file}/*)
                        list(LENGTH dir_files number_of_files)
                        if(\\\${number_of_files} EQUAL 0)
                          message(STATUS \\\"Removing  dir: \\\${file}\\\")
                          file(REMOVE_RECURSE \\\${file})
                        endif()
                    else()
                        message(STATUS \\\"Removing file: \\\${file}\\\")
                        file(REMOVE \\\${file})
                    endif()
                endif()
                get_filename_component(file \\\${file} DIRECTORY)
            endwhile()
        endforeach()
        \"
        )
    else()
        message(ERROR \"cmake_uninstall.cmake script cannot be created!\")
    endif()
        ")
    install(CODE ${uninstall_script_code})
endfunction()

function(clear_install_file_list)
    install(CODE "set(CMTK_INSTALL_FILES \${CMAKE_INSTALL_MANIFEST_FILES})")
endfunction()
