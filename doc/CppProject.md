
# CppProject

## Include
`cmtk/Project`

## Functions
### `generate_version_macro_header(varname macro_prefix header_path)`

&ensp;&ensp;&ensp;&ensp;Generate a C++ header file providing C-Macro giving the version of the project.
- *macro_prefix* : 	Prefix for version macros (e.g. TURBO_FILESYSTEM will generate TURBO_FILESYSTEM_VERSION_MAJOR, ...).
- *header_path* :  Path to include the version file (e.g. turbo/filesystem/version.hpp).
