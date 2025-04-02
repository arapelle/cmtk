
# CppExecutableProject

## Include
`cmtk/CppExecutableProject`

## Functions
### Function `add_cpp_executable(executable_target ...)`

&ensp;&ensp;&ensp;&ensp;Create a C++ executable target.

&ensp;&ensp;&ensp;&ensp;Positional arguments:
- *executable_target*: The executable target name.

&ensp;&ensp;&ensp;&ensp;Targets type arguments:
- [OBJECT *object_target_name*] : Name of the object target. (It can be used with test functions like add_cpp_executable_test().)

&ensp;&ensp;&ensp;&ensp;Targets options arguments:
- [DEFAULT_WARNING_OPTIONS] : 	Indicates if target_default_warning_options() must be called with the targtet, or not.
- [DEFAULT_ERROR_OPTIONS] : 	Indicates if target_default_error_options() must be called with the targtet, or not.
- [CXX_STANDARD *cxx_std*]: 	C++ version used (..., 11, 14, 17, 20, ...)
- [RUNTIME_OUTPUT_DIRECTORY *output_dir*]: 	Output directory of the built executable.

&ensp;&ensp;&ensp;&ensp;Targets sources arguments:
- [HEADERS *header_list*]: 	List of input headers of the target.
- SOURCES *source_list*: 	List of input sources of the target.
- MAIN *main_cpp_file*: 	The main source file of the target.
- [HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of source headers (used with FILE_SET).
- [BUILD_HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of build headers like generated headers (e.g. version.hpp) (used with FILE_SET).
