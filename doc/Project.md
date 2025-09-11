
# Project

## Include
`cmtk/Project`

## Functions
### Function `disable_in_source_build()`

&ensp;&ensp;&ensp;&ensp;Check if the build directory is not a subdirectory of the source directory. If it is the case, a message is printed, and the configure phase is stopped.

### Function `check_in_source_build()`

&ensp;&ensp;&ensp;&ensp;Check if the build directory is not a subdirectory of the source directory, if the option ENABLE_IN_SOURCE_BUILD is ON. If it is the case, a message is printed, and the configure phase is stopped.

### Function `set_build_type_ifndef()`

&ensp;&ensp;&ensp;&ensp;Set Release as value for BUILT_TYPE, if none was provided.

- [DEFAULT *default_type*]: 	The default build type if none is provided when CMake is invoked. It can be a name or the index in the BUILD_TYPES list.  (*0* used by default)
- [BUILD_TYPES *type_list*]:   The list of available build types. (*Release, Debug, MinSizeRel, RelWithDebInfo* used by default)

### Function `set_project_name()`

&ensp;&ensp;&ensp;&ensp;Set project name variables : PROJECT_NAME, PROJECT_NAMESPACE and PACKAGE_SUBJECT_NAME.
If NAMESPACE and SUBJECT_NAME are used, PROJECT_NAME is set to `${PROJECT_NAMESPACE}-${PACKAGE_SUBJECT_NAME}`.

- [NAME *name*] :  Name of the project. (Set PROJECT_NAME.)
- [NAMESPACE *namespace*] :  Namespace of the project. (Set PROJECT_NAMESPACE.)
- [SUBJECT_NAME *subject_name*] :  Subject name of the project. (Set PROJECT_SUBJECT_NAME.)
- [CODE_NAME *code_name*] :  Name of the project used in code sources. (Set PROJECT_CODE_NAME which is set to *${PROJECT_NAME}* by default.)
- [CODE_NAMESPACE *code_namespace*] :  Namespace of the project used in code sources. (Set PROJECT_CODE_NAMESPACE which is set to *${PROJECT_NAMESPACE}* by default.)
- [CODE_SUBJECT_NAME *code_subject_name*] :  Subject name of the project used in code sources. (Set PROJECT_CODE_SUBJECT_NAME which is set to *${PROJECT_SUBJECT_NAME}* by default.)

### Function `set_package_name()`

&ensp;&ensp;&ensp;&ensp;Set package name variables: PACKAGE_NAME, PACKAGE_NAMESPACE and PACKAGE_SUBJECT_NAME.
If NAMESPACE and SUBJECT_NAME are used, PACKAGE_NAME is set to `${PACKAGE_NAMESPACE}-${PACKAGE_SUBJECT_NAME}`.

- [NAME *name*] :  Name of the package. (Set PACKAGE_NAME.)
- [NAMESPACE *namespace*] :  Namespace of the package. (Set PACKAGE_NAMESPACE.)
- [SUBJECT_NAME *subject_name*] :  Subject name of the package. (Set PACKAGE_SUBJECT_NAME.)
- [CODE_NAME *code_name*] :  Name of the package used in code sources. (Set PACKAGE_CODE_NAME which is set to *${PACKAGE_NAME}* by default.)
- [CODE_NAMESPACE *code_namespace*] :  Namespace of the package used in code sources. (Set PACKAGE_CODE_NAMESPACE which is set to *${PACKAGE_NAMESPACE}* by default.)
- [CODE_SUBJECT_NAME *code_subject_name*] :  Subject name of the package used in code sources. (Set PACKAGE_CODE_SUBJECT_NAME which is set to *${PACKAGE_SUBJECT_NAME}* by default.)

### Function `set_project_semantic_version(basicver)`

&ensp;&ensp;&ensp;&ensp;Set project version variables : `PROJECT_SEMANTIC_VERSION`, `PROJECT_VERSION`, `PROJECT_VERSION_MAJOR`,
 `PROJECT_VERSION_MINOR`, `PROJECT_VERSION_PATCH`, `PROJECT_VERSION_PRE_RELEASE`, `PROJECT_VERSION_BUILD_METADATA`.
- `PROJECT_SEMANTIC_VERSION` is set to `${basicver}-${pre_release}+${build_metadata}` if `${pre_release}` and `${build_metadata}` are not empty. 
- `PROJECT_SEMANTIC_VERSION` is set to `${basicver}-${pre_release}` if `${pre_release}` is not empty but `${build_metadata}` is. 
- `PROJECT_SEMANTIC_VERSION` is set to `${basicver}+${build_metadata}` if `${pre_release}` is empty but `${build_metadata}` is not.

&ensp;&ensp;&ensp;&ensp;Arguments:
- [PRE_RELEASE *pre_release*] :  Pre-release version of the project. (Set PROJECT_VERSION_PRE_RELEASE.)
- [BUILD_METADATA *build_metadata*] :  Build metadata of the project. (Set PROJECT_VERSION_BUILD_METADATA.)

### Function `set_package_semantic_version(basicver)`

&ensp;&ensp;&ensp;&ensp;Set package version variables : `PACKAGE_SEMANTIC_VERSION`, `PACKAGE_VERSION`, `PACKAGE_VERSION_MAJOR`,
 `PACKAGE_VERSION_MINOR`, `PACKAGE_VERSION_PATCH`, `PACKAGE_VERSION_PRE_RELEASE`, `PACKAGE_VERSION_BUILD_METADATA`.
- `PACKAGE_SEMANTIC_VERSION` is set to `${basicver}-${pre_release}+${build_metadata}` if `${pre_release}` and `${build_metadata}` are not empty. 
- `PACKAGE_SEMANTIC_VERSION` is set to `${basicver}-${pre_release}` if `${pre_release}` is not empty but `${build_metadata}` is. 
- `PACKAGE_SEMANTIC_VERSION` is set to `${basicver}+${build_metadata}` if `${pre_release}` is empty but `${build_metadata}` is not.

&ensp;&ensp;&ensp;&ensp;Arguments:
- [PRE_RELEASE *pre_release*] :  Pre-release version of the package. (Set PACKAGE_VERSION_PRE_RELEASE.)
- [BUILD_METADATA *build_metadata*] :  Build metadata of the package. (Set PACKAGE_VERSION_BUILD_METADATA.)

### Function `configure_files(return_var)`

&ensp;&ensp;&ensp;&ensp;Apply `configure_file()` on a list of files. The file hierarchy is preserved based on the provided base directory.
- *return_var* :  Variable in the calling scope containing the list of paths to the generated files.
- FILES *files* :  List of files to configure.
- BASE_DIR *dir* :  Directory from which the relative path of input file is computed.
- BINARY_BASE_DIR *dir* :  Directory from which the hierarchy of files is generated.

### Function `install_package(package_name ...)`

&ensp;&ensp;&ensp;&ensp;Install C++ package

- INPUT_PACKAGE_CONFIG_FILE *package-config.cmake.in*: 	A package config file will be created by using configure_package_config_file() on the provided *package-config.cmake.in*.
- [VERSION *version*]: 	The version of the package. (*PROJECT_VERSION* used by default)
- [VERSION_COMPATIBILITY *compatibility*]: 	The compatibility with previous versions (cf. CMake function [write_basic_package_version_file](https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html#command:write_basic_package_version_file)). (*SameMajorVersion* used by default)
- [CMAKE_FILES_DESTINATION *destination*]: Destination directory where to install the CMake files.

### Function `install_uninstall_script(package_name)`

&ensp;&ensp;&ensp;&ensp;Add installation code which creates a uninstall CMake script of the project.

- *package_name* :  Name of the installed package.
- [VERSION *version*] :  Version of the installed package. (*${PROJECT_VERSION}* used by default)
- [FILENAME] : File name of the generated uninstall script. (*cmake_uninstall.cmake* used by default)
- [PACKAGE_DIR] : Directory, relative to the prefix install directory, where the generated script will be installed. (*`${CMAKE_INSTALL_LIBDIR}/cmake/${package_name}`* used by default)
- [ALL] : A uninstall script of a project will remove only the installed project files. This option forces to include all installed files in the uninstall script. (It is generally used by a super project which has subprojects (like git submodules), calling themselves this CMake function, to uninstall all subprojects files.

### Function `clear_install_file_list()`

&ensp;&ensp;&ensp;&ensp;Clear the internal list of installed files used by CMTK. 
This avoid adding files of installed external libraries (downloaded with FetchDeclare()) to the uninstall script of the project.
