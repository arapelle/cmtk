
# FindOrFetchGTest

## Include
`cmtk/FindOrFetchGTest`

## Macros
### Macro `find_or_fetch_GTest()`

&ensp;&ensp;&ensp;&ensp;Call `FetchContent_Declare(googletest ... FIND_PACKAGE_ARGS ` *`VERSION`* `)` and `FetchContent_MakeAvailable(googletest)`. (A uninstall CMake script is installed with GTest when it is installed (so only if `find_package` did not find it).     `include(GoogleTest)` is done automatically.)

- [VERSION *version*] :  The GTest version we are looking for. (*1.14.0* used by default)
- [TAG *tag*] :  The GTest version we are looking for. It is used to precise which GTest archive to download if needed. (See available tags [here](https://github.com/google/googletest/tags).)
(*v${VERSION}* used by default)
