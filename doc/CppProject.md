
# CppProject

## Include
`cmtk/Project`

## Functions
### Function `generate_version_macro_header(varname macro_prefix header_path)`

&ensp;&ensp;&ensp;&ensp;Generate a C++ header file providing C-Macro giving the version of the project.
- *return_var* :  Variable in the calling scope containing the path to the generated header.
- *macro_prefix* : 	Prefix for version macros (e.g. TURBO_FILESYSTEM will generate TURBO_FILESYSTEM_VERSION_MAJOR, ...).
- *header_path* :  Path to include the version file (e.g. turbo/filesystem/version.hpp).
- [BINARY_BASE_DIR *dir*] :  Directory from which the version header is generated. (*${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}* used by default)

### Function `configure_headers(return_var)`

&ensp;&ensp;&ensp;&ensp;Apply `configure_file()` on a list of headers. The header hierarchy is preserved based on header based directories.
- *return_var* :  Variable in the calling scope containing the list of paths to the generated headers.
- FILES *headers* :  List of header files to configure.
- [BASE_DIR *dir*] :  Directory from which the relative path of input header is computed. (*${CMAKE_INSTALL_INCLUDEDIR}* used by default)
- [BINARY_BASE_DIR *dir*] :  Directory from which the hierachy of headers is generated. (*${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}* used by default)

### Function `set_SPDLOG_ACTIVE_LEVEL_ifndef()`

&ensp;&ensp;&ensp;&ensp;Set a cached variable SPDLOG_ACTIVE_LEVEL, if it is nod defined yet.
- [DEBUG *build_type_list*] :  List of build types for which SPDLOG_ACTIVE_LEVEL must be set to DEBUG. (*Debug* used by default)
- [INFO *build_type_list*] :  List of build types for which SPDLOG_ACTIVE_LEVEL must be set to INFO. (*Release* used by default)

### Function `target_default_warning_options(target)`

&ensp;&ensp;&ensp;&ensp;Add default warning compile options to a given target.
`/Wall` mith Visual compiler, or `-Wall -Wextra -pedantic` with g++.
