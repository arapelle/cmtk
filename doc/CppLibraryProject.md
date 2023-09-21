
# CppLibraryProject

## Include
`cmtk/CppLibraryProject`

## Functions
### Function `add_cpp_library(SHARED ... STATIC ...)`

&ensp;&ensp;&ensp;&ensp;Create C++ library shared and/or static targets.

&ensp;&ensp;&ensp;&ensp;Targets type arguments:
- [OBJECT *object_target_name*] : Name of the object library target.
- [SHARED *shared_target_name*] : Name of the shared library target.
- [STATIC *static_target_name*] : Name of the static library target.
- [BUILD_SHARED *val*] : Indicate if the SHARED library must be built. (ON, OFF or UNDEFINED).
It is determined by a cache option value, if UNDEFINED is given. (OPTION is an alias of UNDEFINED)
If a variable name is given, it is determined by the variable value if the variable is DEFINED.
If it is not DEFINED, it is determined by an option value.
- [BUILD_STATIC *val*] : Indicate if the STATIC library must be built. (ON, OFF or UNDEFINED).
It is determined by a cache option value, if UNDEFINED is given. (OPTION is an alias of UNDEFINED)
If a variable name is given, it is determined by the variable value if the variable is DEFINED.
If it is not DEFINED, it is determined by an option value.

&ensp;&ensp;&ensp;&ensp;Targets options arguments:
- [CXX_STANDARD *cxx_std*] : 	C++ version used (..., 11, 14, 17, 20, 23, ...)
- [LIBRARY_OUTPUT_DIRECTORY *output_dir*] : 	Output directory of the built shared library.
- [ARCHIVE_OUTPUT_DIRECTORY *output_dir*] : 	Output directory of the built static library.

&ensp;&ensp;&ensp;&ensp;Targets sources arguments:
- HEADERS *header_list*: 	List of input headers of the target.
- SOURCES *source_list*: 	List of input sources of the target.
- [HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of source headers (used with FILE_SET).
- [BUILD_HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of build headers like generated headers (e.g. version.hpp) (used with FILE_SET).

### Function `add_cpp_library(HEADER_ONLY ...)`

&ensp;&ensp;&ensp;&ensp;Create a C++ header only library target.

&ensp;&ensp;&ensp;&ensp;Targets type arguments:
- [HEADER_ONLY *honly_target_name*] : Name of the header only (INTERFACE) library target.
- [NAMESPACE *ns*] : Add an alias target with *ns* as prefix for each shared and static target.

&ensp;&ensp;&ensp;&ensp;Targets options arguments:
- [CXX_STANDARD *cxx_std*] : 	C++ version used (..., 11, 14, 17, 20, 23, ...)

&ensp;&ensp;&ensp;&ensp;Targets sources arguments:
- HEADERS *header_list*: 	List of input headers of the target.
- [HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of source headers (used with FILE_SET).
- [BUILD_HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of build headers like generated headers (e.g. version.hpp) (used with FILE_SET).

### Function `cpp_library_targets_link_libraries(...)`

&ensp;&ensp;&ensp;&ensp;Make shared and/or static targets of a C++ library link with dependency libraries.

- [OBJECT *object_target_name*] : 	Name of the object library target.
- [STATIC *static_target_name*] : 	Name of the static library target.
- [SHARED *shared_target_name*] : 	Name of the shared library target.
- [PUBLIC *target_list*] : 	List of public targets.
- [INTERFACE *target_list*] : 	List of interface targets.
- [PRIVATE *target_list*] : 	List of private targets.

### Function `install_cpp_library(...)`

&ensp;&ensp;&ensp;&ensp;Install C++ library targets.
- [SHARED *shared_target_name*] : Name of the shared library target.
- [STATIC *static_target_name*] : Name of the static library target.
- [HEADER_ONLY *honly_target_name*] : Name of the header only (INTERFACE) library target.
- EXPORT *export_name* : 	Export name.
- [NAMESPACE *namespace*]: 	Targets namespace.
- [DESTINATION *destination*]: EXPORT destination.

### Function `install_library_package(package_name ...)`

&ensp;&ensp;&ensp;&ensp;Install C++ package

- INPUT_PACKAGE_CONFIG_FILE *package-config.cmake.in*: 	A package config file will be created by using configure_package_config_file() on the provided *package-config.cmake.in*.
- [VERSION *version*]: 	The version of the package. (*PROJECT_VERSION* used by default)
- [VERSION_COMPATIBILITY *compatibility*]: 	The compatibility with previous versions (cf. CMake function [write_basic_package_version_file](https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html#command:write_basic_package_version_file)). (*SameMajorVersion* used by default)

