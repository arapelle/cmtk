
# CppLibraryProject

## Include
`cmtk/CppLibraryProject`

## Functions

### Function `shared_or_static_option(cache_var_name SHARED|STATIC)`

&ensp;&ensp;&ensp;&ensp;Create a cache option with SHARED or STATIC as possible value, SHARED or STATIC as default value, and the following description message: "Choose the type of library.".
- *cache_var_name* :  The name of the cache option to create.

### Function `add_cpp_library(target_name SHARED|STATIC ...)`

&ensp;&ensp;&ensp;&ensp;Create a shared or static C++ library target.

&ensp;&ensp;&ensp;&ensp;Target basic arguments:
- target_name : The name of the library target.
- SHARED|STATIC : Indicates if the target must be a shared or a static library.

&ensp;&ensp;&ensp;&ensp;Target options arguments:
- [DEFAULT_WARNING_OPTIONS] : 	Indicates if target_default_warning_options() must be called with the targtet, or not.
- [DEFAULT_ERROR_OPTIONS] : 	Indicates if target_default_error_options() must be called with the targtet, or not.
- [CXX_STANDARD *cxx_std*] : 	C++ version used (..., 11, 14, 17, 20, 23, 26, ...)
- [LIBRARY_OUTPUT_DIRECTORY *output_dir*] : 	Output directory of the built shared library.
- [ARCHIVE_OUTPUT_DIRECTORY *output_dir*] : 	Output directory of the built static library.

&ensp;&ensp;&ensp;&ensp;Target sources arguments:
- HEADERS *header_list*: 	List of input headers of the target.
- SOURCES *source_list*: 	List of input sources of the target.
- [HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of source headers (used with FILE_SET).
- [BUILD_HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of build headers like generated headers (e.g. version.hpp) (used with FILE_SET).

### Function `add_cpp_library(target_name HEADER_ONLY ...)`

&ensp;&ensp;&ensp;&ensp;Create a header only C++ library target.

&ensp;&ensp;&ensp;&ensp;Target basic arguments:
- target_name : The name of the library target.

&ensp;&ensp;&ensp;&ensp;Targets options arguments:
- [CXX_STANDARD *cxx_std*] : 	C++ version used (..., 11, 14, 17, 20, 23, 26, ...)

&ensp;&ensp;&ensp;&ensp;Targets sources arguments:
- HEADERS *header_list*: 	List of input headers of the target.
- [HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of source headers (used with FILE_SET).
- [BUILD_HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of build headers like generated headers (e.g. version.hpp) (used with FILE_SET).
