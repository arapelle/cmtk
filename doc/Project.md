
# Project

## Include
`cmtk/Project`

## Functions
### `disable_in_source_build()`

    Check if the build directory is not a subdirectory of the source directory. If it is the case, a message is printed, and the configure phase is stopped.

### `set_build_type_ifndef()`

    Set Release as value for BUILT_TYPE, if none was provided.

    - [DEFAULT *default_type*]: 	The default build type if none is provided when CMake is invoked. It can be a name or the index in the BUILD_TYPES list.  (*0* used by default)
    - [BUILD_TYPES *type_list*]:   The list of available build tpyes. (*Release, Debug, MinSizeRel, RelWithDebInfo* used by default)

### `install_cmake_uninstall_script(install_cmake_package_dir)`

    Add installation code which creates a uninstall CMake script of the project.

    - [ALL] : A uninstall script of a project will remove only the installed project files. This option forces to include all installed files in the uninstall script. (It is generally used by a super project which has subprojects (like git submodules), calling themselves this CMake function, to uninstall all subprojects files.

