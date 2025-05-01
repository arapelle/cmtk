
# CppExecutableTests

## Include
`cmtk/CppExecutableTests`

## Functions
### Function `add_cpp_executable_test(test_name library_target gtest_target ...)`

Create an identified C++ test target for an executable. (Uses [Google Tests](https://github.com/google/googletest))

- *test_name*:  The test name (used to defined the test target too).
- *library_target*:  The name of the tested library target.
- *gtest_target*:  The google test target to link with (gtest, gtest_main, gmock or gmock_main).
- [HEADERS *header_list*]: 	The list of C++ headers to compile the test target.
- SOURCES *source_list*: 	The list of C++ sources to compile the test target.
- [DEPENDENCIES *dependency_list*]: 	The list of dependency targets.
- [CXX_STANDARD *cxx_std*] : 	C++ version used (..., 11, 14, 17, 20, 23, 26, ...)
- [DEFAULT_WARNING_OPTIONS ON|OFF] : 	Indicates if target_default_warning_options() must be called with the test target, or not. (*ON* used by default.)
- [DEFAULT_ERROR_OPTIONS ON|OFF] : 	Indicates if target_default_error_options() must be called with the test target, or not. (*ON* used by default.)

### Function `add_cpp_executable_basic_tests(library_target gtest_target ...)`

Create basic C++ test targets for an executable. (Uses [Google Tests](https://github.com/google/googletest))

- *library_target*:  The name of the tested library target.
- *gtest_target*:  The google test target to link with (gtest, gtest_main, gmock or gmock_main).
- SOURCES *source_list*: 	The list of C++ sources to compile independently.
- [DEPENDENCIES *dependency_list*]: 	The list of dependency targets.
- [CXX_STANDARD *cxx_std*] : 	C++ version used (..., 11, 14, 17, 20, 23, 26, ...)
- [DEFAULT_WARNING_OPTIONS ON|OFF] : 	Indicates if target_default_warning_options() must be called with the test target, or not. (*ON* used by default.)
- [DEFAULT_ERROR_OPTIONS ON|OFF] : 	Indicates if target_default_error_options() must be called with the test target, or not. (*ON* used by default.)
