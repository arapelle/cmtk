
# Project

## Include
`cmtk/Project`

## Functions
### Function `disable_in_source_build()`

&ensp;&ensp;&ensp;&ensp;Check if the build directory is not a subdirectory of the source directory. If it is the case, a message is printed, and the configure phase is stopped.

### Function `set_build_type_ifndef()`

&ensp;&ensp;&ensp;&ensp;Set Release as value for BUILT_TYPE, if none was provided.

- [DEFAULT *default_type*]: 	The default build type if none is provided when CMake is invoked. It can be a name or the index in the BUILD_TYPES list.  (*0* used by default)
- [BUILD_TYPES *type_list*]:   The list of available build tpyes. (*Release, Debug, MinSizeRel, RelWithDebInfo* used by default)

### Function `set_project_name()`

&ensp;&ensp;&ensp;&ensp;Set project name variables : PROJECT_NAME, PROJECT_NAMESPACE and PROJECT_BASE_NAME.
If NAMESPACE and BASE_NAME are used, PROJECT_NAME is set to `${PROJECT_NAMESPACE}-${PROJECT_BASE_NAME}`.

- [NAME *name*] :  Name of the project. (Set PROJECT_NAME.)
- [NAMESPACE *namespace*] :  Namespace of the project. (Set PROJECT_NAMESPACE.)
- [BASE_NAME *base_name*] :  Base name of the project. (Set PROJECT_BASE_NAME.)

### Function `set_project_semantic_version(basicver)`

&ensp;&ensp;&ensp;&ensp;Set project version variables : `PROJECT_SEMANTIC_VERSION`, `PROJECT_VERSION`, `PROJECT_VERSION_MAJOR`,
 `PROJECT_VERSION_MINOR`, `PROJECT_VERSION_PATCH`, `PROJECT_VERSION_PRE_RELEASE`, `PROJECT_VERSION_BUILD_METADATA`.
- `PROJECT_SEMANTIC_VERSION` is set to `${basicver}-${pre_release}+${build_metadata}` if `${pre_release}` and `${build_metadata}` are not empty. 
- `PROJECT_SEMANTIC_VERSION` is set to `${basicver}-${pre_release}` if `${pre_release}` is not empty but `${build_metadata}` is. 
- `PROJECT_SEMANTIC_VERSION` is set to `${basicver}+${build_metadata}` if `${pre_release}` is empty but `${build_metadata}` is not.

&ensp;&ensp;&ensp;&ensp;Arguments:
- [PRE_RELEASE *pre_release*] :  Pre-release version of the project. (Set PROJECT_NAME.)
- [BUILD_METADATA *build_metadata*] :  Build metadata of the project. (Set PROJECT_NAMESPACE.)

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
