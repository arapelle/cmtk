
# CppExecutableTests

## Include
`cmtk/CppExecutableTests`

## Functions
### `add_cpp_executable_test(test_name gtest_target ...)`

Create an identified C++ test target for an executable. (Uses [Google Tests](https://github.com/google/googletest))

- *test_name*:  The test target name.
- *gtest_target*:  The google test target to link with (gtest, gtest_main, gmock or gmock_main).
- OBJECT *object_target*: 	The object target.
- [HEADERS *header_list*]: 	The list of C++ headers to compile the test target.
- SOURCES *source_list*: 	The list of C++ sources to compile the test target.
- [LIBRARIES *dependency_list*]: 	The list of dependency library targets.

### `add_cpp_executable_basic_tests(gtest_target ...)`

Create basic C++ test targets for an executable. (Uses [Google Tests](https://github.com/google/googletest))

- *gtest_target*:  The google test target to link with (gtest, gtest_main, gmock or gmock_main).
- OBJECT *object_target*: 	The object target.
- SOURCES *source_list*: 	The list of C++ sources to compile independently.
- [LIBRARIES *dependency_list*]: 	The list of dependency library targets.
