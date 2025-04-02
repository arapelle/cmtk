
# CppProject

## Include
`cmtk/Project`

## Functions & Macros
### Function `configure_headers(return_var)`

&ensp;&ensp;&ensp;&ensp;Apply `configure_file()` on a list of headers. The header hierarchy is preserved based on the provided header base directory.
- *return_var* :  Variable in the calling scope containing the list of paths to the generated headers.
- FILES *headers* :  List of header files to configure.
- [BASE_DIR *dir*] :  Directory from which the relative path of input header is computed. (*${CMAKE_INSTALL_INCLUDEDIR}* used by default)
- [BINARY_BASE_DIR *dir*] :  Directory from which the hierarchy of headers is generated. (*${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}* used by default)

### Function `configure_sources(return_var)`

&ensp;&ensp;&ensp;&ensp;Apply `configure_file()` on a list of sources. The source hierarchy is preserved based on the provided source base directory.
- *return_var* :  Variable in the calling scope containing the list of paths to the generated sources.
- FILES *sourcess* :  List of source files to configure.
- [BASE_DIR *dir*] :  Directory from which the relative path of input header is computed. (*src* used by default)
- [BINARY_BASE_DIR *dir*] :  Directory from which the hierarchy of sources is generated. (*${CMAKE_CURRENT_BINARY_DIR}/src* used by default)

### Function `target_default_warning_options(target)`

&ensp;&ensp;&ensp;&ensp;Add default warning compile options to a given target.
`/Wall` mith Visual compiler, or `-Wall -Wextra -pedantic -Wshadow -Wmisleading-indentation -Wconversion -Wold-style-cast` with g++.

### Function `target_default_error_options(target)`

&ensp;&ensp;&ensp;&ensp;Add default error compile options to a given target.
`-pedantic-errors -Werror=old-style-cast` with g++.

### macro `add_test_subdirectory_if_build(dir_name ...)`

&ensp;&ensp;&ensp;&ensp;Create a cached option indicating if the provided test subdirectory must be added or not. Then add this test subdirectory accordingly to the option.
- *dir_name* :  The test subdirectory to treat.
- [NAME *name*] :  The name to use to define the option name and its message (if they are not provided). (*${PROJECT_NAME}* used by default)
- [BUILD_OPTION_NAME *name*] :  The name of the option. (*BUILD_${UPPER_NAME}_TESTS* used by default, where ${UPPER_NAME} is the upper value of ${NAME})
- [BUILD_OPTION_MSG *msg*] :  The message of the option. (*Build ${NAME} tests or not.* used by default)
- [BUILD_OPTION_DEFAULT *ON|OFF*] :  The default value of the option (ON or OFF). (*OFF* used by default)

### macro `add_example_subdirectory_if_build(dir_name ...)`

&ensp;&ensp;&ensp;&ensp;Create a cached option indicating if the provided example subdirectory must be added or not. Then add this example subdirectory accordingly to the option.
- *dir_name* :  The example subdirectory to treat.
- [NAME *name*] :  The name to use to define the option name and its message (if they are not provided). (*${PROJECT_NAME}* used by default)
- [BUILD_OPTION_NAME *name*] :  The name of the option. (*BUILD_${UPPER_NAME}_EXAMPLES* used by default, where ${UPPER_NAME} is the upper value of ${NAME})
- [BUILD_OPTION_MSG *msg*] :  The message of the option. (*Build ${NAME} examples or not.* used by default)
- [BUILD_OPTION_DEFAULT *ON|OFF*] :  The default value of the option (ON or OFF). (*OFF* used by default)

### function `copy_runtime_dlls_if_win32(target_name)`

&ensp;&ensp;&ensp;&ensp;Copy the runtime dlls of a valid target to its runtime directory. Set the RUNTIME_OUTPUT_DIRECTORY of the target to 
"${CMAKE_CURRENT_BINARY_DIR}/${RUNTIME_OUTPUT_SUBDIRECTORY}" (below).
- *target_name* :  The name of the target.
- [RUNTIME_OUTPUT_SUBDIRECTORY *dir*] :  The subdirectory path used to defined the RUNTIME_OUTPUT_DIRECTORY of the target. (Empty string used by default)
