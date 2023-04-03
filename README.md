# Concept

This CMake ToolKit (CMTK) provides helping CMake functions to manage simple C++ CMake projects easily.

<u>Current version</u>: 0.8

# Requirements #
- ### Binaries:

  - CMake 3.23 or later

# Modules

- ### Utility

  - ##### fatal_ifdef()
  - ##### fatal_ifndef()
  - ##### fatal_if_none_is_def()
  - ##### set_ifndef()
  - ##### set_iftest()
  - ##### trioption()
  - ##### option_or_set_ifdef()
  - ##### trioption_or_set_ifdef()

- ### Project

  - ##### check_cmake_binary_dir()

    Check if the build directory is not a subdirectory of the source directory. If it is the case, a message is printed, and the configure phase is stopped.

  - ##### set_build_type_ifndef()

    Set Release as value for BUILT_TYPE, if none was provided.

  - ##### install_cmake_uninstall_script(install_cmake_package_dir)

    Add installation code which creates a uninstall CMake script of the project.

    - [ALL] : A uninstall script of a project will remove only the installed project files. This option forces to include all installed files in the uninstall script. (It is generally used by a super project which has subprojects (like git submodules), calling themselves this CMake function, to uninstall all subprojects files.

- ### CppProject

  - ##### generate_macro_version_header(varname macro_prefix header_path)

    Generate a C++ header file providing C-Macro giving the version of the project.
    - macro_prefix : 	Prefix for version macros (e.g. TURBO_FILESYSTEM will generate TURBO_FILESYSTEM_VERSION_MAJOR, ...).
    - header_path :  Path to include the version file (e.g. turbo/filesystem/version.hpp).

- ### CppExecutableProject

  - ##### add_cpp_executable(...)

    Create a C++ executable target.

    - [CXX_STANDARD *cxx_std*] : 	C++ version used (..., 11, 14, 17, 20, ...)
    - [INPUT_VERSION_HEADER *version_hpp_in*] : 	Input version file to configure with CMake variables.
    - [OUTPUT_VERSION_HEADER *version_hpp*] : 	Output version file generated.
    - [RUNTIME_OUTPUT_DIRECTORY *output_dir*] : 	Output directory of the built executable.
    - HEADERS *header_list*: 	List of input headers of the target.
    - SOURCES *source_list*: 	List of input sources of the target.

- ### CppLibraryProject

  - ##### add_cpp_library(SHARED ... STATIC ...)

    Create C++ library shared and/or static targets.

    Targets type arguments:
    - [OBJECT *object_target_name*] : Name of the object library target.
    - [SHARED *shared_target_name*] : Name of the shared library target.
    - [STATIC *static_target_name*] : Name of the static library target.
    - [BUILD_SHARED *val*] : Indicate if a SHARED library must be build. (ON, OFF or UNDEFINED). If UNDEFINED, it is determined by cached option value. (cf. PUBLIC)
    - [BUILD_STATIC *val*] : Indicate if a STATIC library must be build. (ON, OFF or UNDEFINED). If UNDEFINED, it is determined by cached option value. (cf. PUBLIC)
    - [PUBLIC] : Create options for STATIC and SHARED buildings if necessary and depending on BUILD_SHARED and BUILD_STATIC. Option init values are ON.
    - [NAMESPACE *ns*] : Add an alias target with *ns* as prefix for each shared and static target.

    Targets options arguments:
    - [CXX_STANDARD *cxx_std*] : 	C++ version used (..., 11, 14, 17, 20, 23, ...)
    - [LIBRARY_OUTPUT_DIRECTORY *output_dir*] : 	Output directory of the built shared library.
    - [ARCHIVE_OUTPUT_DIRECTORY *output_dir*] : 	Output directory of the built static library.

    Targets sources arguments:
    - HEADERS *header_list*: 	List of input headers of the target.
    - SOURCES *source_list*: 	List of input sources of the target.
    - [HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of source headers (used with FILE_SET).
    - [BUILD_HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of build headers like generated headers (e.g. version.hpp) (used with FILE_SET).

  - ##### add_cpp_library(HEADER_ONLY ...)

    Create a C++ header only library target.

    Targets type arguments:
    - [HEADER_ONLY *honly_target_name*] : Name of the header only (INTERFACE) library target.
    - [NAMESPACE *ns*] : Add an alias target with *ns* as prefix for each shared and static target.

    Targets options arguments:
    - [CXX_STANDARD *cxx_std*] : 	C++ version used (..., 11, 14, 17, 20, 23, ...)

    Targets sources arguments:
    - HEADERS *header_list*: 	List of input headers of the target.
    - [HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of source headers (used with FILE_SET).
    - [BUILD_HEADERS_BASE_DIRS *base_dirs*]:  List of base directories of build headers like generated headers (e.g. version.hpp) (used with FILE_SET).

  - **cpp_library_targets_link_libraries(...)**

    Make shared and/or static targets of a C++ library link with dependency libraries.

    - [OBJECT *object_target_name*] : 	Name of the object library target.
    - [STATIC *static_target_name*] : 	Name of the static library target.
    - [SHARED *shared_target_name*] : 	Name of the shared library target.
    - [PUBLIC *target_list*] : 	List of public targets.
    - [INTERFACE *target_list*] : 	List of interface targets.
    - [PRIVATE *target_list*] : 	List of private targets.

  - ##### install_cpp_library(...)

    Install C++ library targets.
    - [SHARED *shared_target_name*] : Name of the shared library target.
    - [STATIC *static_target_name*] : Name of the static library target.
    - [HEADER_ONLY *honly_target_name*] : Name of the header only (INTERFACE) library target.
    - EXPORT *export_name* : 	Export name.
    - [NAMESPACE *namespace*]: 	Targets namespace.
    - [DESTINATION *destination*]: EXPORT destination.

  - ##### install_library_package(package_name ...)

    Install C++ package

    - [UNINSTALL_SCRIPT *opts*] : 	If this option is given, a uninstall CMake script will be installed. Arguments *opts* are passed to *install_cmake_uninstall_script()*.
    - INPUT_PACKAGE_CONFIG_FILE *package-config.cmake.in*: 	A package config file will be created by using configure_package_config_file() on the provided *package-config.cmake.in*.
    - [VERSION *version*]: 	The version of the package. (*PROJECT_VERSION* used by default)
    - [VERSION_COMPATIBILITY *compatibility*]: 	The compatibility with previous versions (cf. [write_basic_package_version_file](https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html)). (*SameMajorVersion* used by default)

  - ##### add_cpp_library_tests(...)

    Create C++ test targets for a library. (Uses [Google Tests](https://github.com/google/googletest))

    - STATIC *static_target*: 	The static library target.
    - SHARED *shared_target*: 	The shared library target.
    - SOURCES *source_list*: 	The list of C++ sources to compile independently.
    - DEPENDENCIES *dependency_list*: 	The list of dependency targets.

  - ##### add_cpp_library_examples(...)

    Create C++ example targets for a library.

    - STATIC *static_target*: 	The static library target.
    - SHARED *shared_target*: 	The shared library target.
    - SOURCES *source_list*: 	The list of C++ sources to compile independently.
    - DEPENDENCIES *dependency_list*: 	The list of dependency targets.

# License

[MIT License](./LICENSE.md) © cmtk
