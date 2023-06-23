
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

### `configure_headers(return_var)`

&ensp;&ensp;&ensp;&ensp;Apply `configure_file()` on a list of headers. The header hierarchy is preserved based on header based directories.
- *return_var* :  Variable in the calling scope containing the list of paths to the generated headers.
- FILES *headers* :  List of header files to configure.
- [BASE_DIR *dir*] :  Directory from which the relative path of input header is computed. (*${CMAKE_INSTALL_INCLUDEDIR}* used by default)
- [BINARY_BASE_DIR *dir*] :  Directory from which the hierachy of headers is generated. (*${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}* used by default)
