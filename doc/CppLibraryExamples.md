
# CppLibraryExamples

## Include
`cmtk/CppLibraryExamples`

## Functions
### Function `add_cpp_library_example(example_name library_target ...)`

&ensp;&ensp;&ensp;&ensp;Create an identified C++ example target for a library.

- *example_name*:  The example target name.
- *library_target*:  The name of the tested library target.
- [HEADERS *header_list*]: 	The list of C++ headers to compile the example target.
- SOURCES *source_list*: 	The list of C++ sources to compile the example target.
- [DEPENDENCIES *dependency_list*]: 	The list of dependency targets.
- [CXX_STANDARD *cxx_std*] : 	C++ version used (..., 11, 14, 17, 20, 23, 26, ...)
- [DEFAULT_WARNING_OPTIONS ON|OFF] : 	Indicates if target_default_warning_options() must be called with the example target, or not. (*ON* used by default.)
- [DEFAULT_ERROR_OPTIONS ON|OFF] : 	Indicates if target_default_error_options() must be called with the test target, or not. (*ON* used by default.)

### Function `add_cpp_library_basic_examples(library_target ...)`

&ensp;&ensp;&ensp;&ensp;Create C++ example targets for a library.

- *library_target*:  The name of the tested library target.
- SOURCES *source_list*: 	The list of C++ sources to compile independently.
- [DEPENDENCIES *dependency_list*]: 	The list of dependency targets.
- [CXX_STANDARD *cxx_std*] : 	C++ version used (..., 11, 14, 17, 20, 23, 26, ...)
- [DEFAULT_WARNING_OPTIONS ON|OFF] : 	Indicates if target_default_warning_options() must be called with the example target, or not. (*ON* used by default.)
- [DEFAULT_ERROR_OPTIONS ON|OFF] : 	Indicates if target_default_error_options() must be called with the test target, or not. (*ON* used by default.)
