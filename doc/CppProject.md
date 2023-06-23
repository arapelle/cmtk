
# CppProject

## Include
`cmtk/Project`

## Functions
### `generate_version_macro_header(varname macro_prefix header_path)`

&ensp;&ensp;&ensp;&ensp;Generate a C++ header file providing C-Macro giving the version of the project.
- *return_var* :  Variable in the calling scope containing the path to the generated header.
- *macro_prefix* : 	Prefix for version macros (e.g. TURBO_FILESYSTEM will generate TURBO_FILESYSTEM_VERSION_MAJOR, ...).
- *header_path* :  Path to include the version file (e.g. turbo/filesystem/version.hpp).
- [BINARY_BASE_DIR *dir*] :  Directory from which the version header is generated. (*${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}* used by default)
