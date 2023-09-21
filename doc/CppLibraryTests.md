
# CppLibraryTests

## Include
`cmtk/CppLibraryTests`

## Functions

### Function `add_cpp_library_test(test_name gtest_target ...)`

&ensp;&ensp;&ensp;&ensp;Create an identified C++ test target for a library. (Uses [Google Tests](https://github.com/google/googletest))

- *test_name*:  The test target name.
- *gtest_target*:  The google test target to link with (gtest, gtest_main, gmock or gmock_main).
- [STATIC *static_target*]: 	The static library target.
- [SHARED *shared_target*]: 	The shared library target.
- [HEADER_ONLY *header_only_target*]:  The header-only library target.
- [HEADERS *header_list*]: 	The list of C++ headers to compile the test target.
- SOURCES *source_list*: 	The list of C++ sources to compile the test target.
- [LIBRARIES *dependency_list*]: 	The list of dependency library targets.

### Function `add_cpp_library_basic_tests(gtest_target ...)`

&ensp;&ensp;&ensp;&ensp;Create basic C++ test targets for a library. (Uses [Google Tests](https://github.com/google/googletest))

- *gtest_target*:  The google test target to link with (gtest, gtest_main, gmock or gmock_main).
- [STATIC *static_target*]: 	The static library target.
- [SHARED *shared_target*]: 	The shared library target.
- [HEADER_ONLY *header_only_target*]:  The header-only library target.
- SOURCES *source_list*: 	The list of C++ sources to compile independently.
- [LIBRARIES *dependency_list*]: 	The list of dependency library targets.
