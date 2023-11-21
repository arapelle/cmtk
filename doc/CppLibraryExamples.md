
# CppLibraryExamples

## Include
`cmtk/CppExecutableTests`

## Functions
### Function `add_cpp_library_example(target_name ...)`

&ensp;&ensp;&ensp;&ensp;Create an identified C++ example target for a library.

- [STATIC *static_target*]: 	The static library target.
- [SHARED *shared_target*]: 	The shared library target.
- [HEADER_ONLY *header_only_target*]: 	The header-only library target.
- [HEADERS *header_list*]: 	The list of C++ headers to compile the example target.
- SOURCES *source_list*: 	The list of C++ sources to compile the example target.
- [LIBRARIES *dependency_list*]: 	The list of dependency library targets.

### Function `add_cpp_library_basic_examples(...)`

&ensp;&ensp;&ensp;&ensp;Create C++ example targets for a library.

- [STATIC *static_target*]: 	The static library target.
- [SHARED *shared_target*]: 	The shared library target.
- [HEADER_ONLY *header_only_target*]: 	The header-only library target.
- SOURCES *source_list*: 	The list of C++ sources to compile independently.
- [LIBRARIES *dependency_list*]: 	The list of dependency library targets.
