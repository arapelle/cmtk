# Concept

This CMake ToolKit (CMTK) provides helping CMake functions to manage simple C++ CMake projects easily.
It is used by the [cmtkgen](https://github.com/arapelle/cmtkgen) tools which generate start-up C++ projects.

See [task board](https://app.gitkraken.com/glo/board/Xn4YJC5qdgApg_KM) for future updates and features.

<u>Current version</u>: 0.4.2

# Requirements #
- ### Binaries:

  - CMake 3.16 or later

# Modules

- ### Project

  - ##### check_cmake_binary_dir()

    Check if the build directory is not a subdirectory of the source directory. If it is the case, a message is printed, and the configure phase is stopped.

  - ##### set_build_type_if_undefined()

    Set Release as value for BUILT_TYPE, if none was provided.

  - ##### generate_basic_package_config_file(package_config_file  export_names)

    Generate a basic config file *package_config_file* for the package which include a CMake file for each *export_name* provided.

  - ##### install_cmake_uninstall_script(install_cmake_package_dir)

    Add installation code which creates a uninstall CMake script of the project. 
    
    - [ALL] : A uninstall script of a project will remove only the installed project files. This option forces to include all installed files in the uninstall script. (It is generally used by a super project which has subprojects (like git submodules), calling themselves this CMake function, to uninstall all subprojects files.

- ### CppProject

  - ##### generate_version_header([INPUT_VERSION_HEADER version.hpp.in] OUTPUT_VERSION_HEADER version.hpp)

    Generate a C++ header file providing C-Macro giving the version of the project. If INPUT_VERSION_HEADER is not provided, a default contents is created.

  - ##### generate_default_version_header(version_file)

    Generates a C++ header file providing C-Macro giving the version of the project with default contents. 

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

  - ##### library_build_options(library_name ...)

    Define CMake options (cache entries) for a library.

    - STATIC: 	Add option *<library_name>_BUILD_STATIC_LIB*.
    - SHARED: 	Add option *<library_name>_BUILD_SHARED_LIB*.
    - HEADER_ONLY: 	Indicates that the library is header only. So, STATIC or SHARED is not required.
    - [EXAMPLE] : 	Add option *<library_name>_BUILD_EXAMPLES*.
    - [TEST] : 	Add option *<library_name>_BUILD_TESTS*.
    - [EXAMPLE_DIR *dir*] : 	Name of the directory containing the examples. (default: example)
    - [TEST_DIR *dir*] : 	Name of the directory containing the tests. (default: test)

  - ##### add_cpp_library(library_name  build_shared  build_static ...)

    Create C++ library targets (shared and/or static).
    - [CXX_STANDARD *cxx_std*] : 	C++ version used (..., 11, 14, 17, 20, ...)
    - INCLUDE_DIRECTORIES *include_dirs*: 	Include directories needed by the library.
    - [OBJECT *object_target_name*] : 	Name of the object library target. (default: *<library_name>*-object)
    - SHARED *shared_target_name* : 	Name of the shared library target. (required if build_shared is True)
    - STATIC *object_target_name* : 	Name of the static library target. (required if build_static is True)
    - [INPUT_VERSION_HEADER *version_hpp_in*] : 	Input version file to configure with CMake variables.
    - [OUTPUT_VERSION_HEADER *version_hpp*] : 	Output version file generated.
    - [LIBRARY_OUTPUT_DIRECTORY *output_dir*] : 	Output directory of the built shared library.
    - [ARCHIVE_OUTPUT_DIRECTORY *output_dir*] : 	Output directory of the built static library.
    - [BUILT_TARGETS *built_targets_var*] : 	Variable to set with the names of the built targets.
    - HEADERS *header_list*: 	List of input headers of the target.
    - SOURCES *source_list*: 	List of input sources of the target.
    
  - ##### add_cpp_honly_library(library_name ...)
  
    Create a C++ header only library target. 
  
    - INCLUDE_DIRECTORIES *include_dirs*: 	Include directories needed by the library.
    - [INPUT_VERSION_HEADER *version_hpp_in*] : 	Input version file to configure with CMake variables.
    - [OUTPUT_VERSION_HEADER *version_hpp*] : 	Output version file generated.
  
  - **cpp_library_targets_link_libraries(library_name ...)**
  
    Make targets of a C++ library link with dependency libraries.
  
    	- [HEADER_ONLY] : 	Indicate that the library is header only. (There is only an *interface* target no *object*, *static* or *shared* target.)
    	- [OBJECT *object_target_name*] : 	Name of the object library target. (default: *<library_name>*-object)
    	- [STATIC *static_target_name*] : 	Name of the static library target. (default: *<library_name>*-static)
    	- [SHARED *shared_target_name*] : 	Name of the shared library target. (default: *<library_name>*)
    	- [PUBLIC *target_list*] : 	List of public targets.
    	- [PROTECTED *target_list*] : 	List of protected targets.
    	- [PRIVATE *target_list*] : 	List of private targets.
  
  - ##### install_cpp_library_targets(library ...)
  
    Install C++ library targets.
  
    - NAMESPACE *namespace*: 	Targets namespace.
    - [EXPORT *export_name*] : 	Export name.
    - [COMPONENT *component_name*] : 	Component name.
    - TARGETS *targets*: 	List of targets.
  
    - INCLUDE_DIRECTORIES *include_dirs*: 	Include directories needed by the library.
  
  - ##### install_package(package_name ...)
  
    Install C++ package
  
    - [NO_UNINSTALL_SCRIPT] : 	If this option is given, no uninstall CMake script will be installed.
    - BASIC_PACKAGE_CONFIG_FILE: 	A basic package config file will be created by using *generate_basic_package_config_file()*.
    - VERBOSE_PACKAGE_CONFIG_FILE: 	A verbose package config file will be created by using generate_verbose_library_config_file()*. (cf. below)
    - INPUT_PACKAGE_CONFIG_FILE *package-config.cmake.in*: 	A package config file will be created by using configure_package_config_file() on the provided *package-config.cmake.in*.
    - VERSION *version*: 	The version of the package.
    - VERSION_COMPATIBILITY *compatibility*: 	The compatibility with previous versions. (cf. [write_basic_package_version_file](https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html))
    - EXPORT_NAMES *export_names*: 	The list of exports to install. (Only required when BASIC_PACKAGE_CONFIG_FILE or VERBOSE_PACKAGE_CONFIG_FILE is used.)
  
  - ##### generate_verbose_library_config_file(package_config_file  package_name  version  export_names)
  
    Generate a verbose config file which display information about the package when it is found by CMake.
  
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
