
# RscCppLibraryProject

## Include
`cmtk/RscCppLibraryProject`

## Functions
### Function `add_rsc_cpp_library(target_name SHARED|STATIC ...)`

&ensp;&ensp;&ensp;&ensp;Create a shared or static C++ library target embedding serialized resource files.

&ensp;&ensp;&ensp;&ensp;The function takes a list of resource files and copy its content in a C++ library.
For each resource file, a source file and a header file are generated. The header has the declaration of a
continuous container of bytes, whereas the source file has the definition of this container with the bytes 
of the resource file as content.

&ensp;&ensp;&ensp;&ensp;The function generates tool headers allowing the user to get information for each 
resource and to access the bytes of each serialized resource.
Indeed, a function `find_serialized_resource(resource_path)` returns an `optional<span<byte>>` corresponding 
to the given `resource_path`. This input path is the path of the resource relative to the resource base directory (cf. `RESOURCES_BASE_DIR`).
The optional is `nullopt` if no resource was found.

&ensp;&ensp;&ensp;&ensp;To generate the library, the function takes some arguments. The *NAME* determines 
two important aspects: the name of the main directory and the main C++ namespace of the generated code.
All generated files are in this directory (or a subdirectory), and every constants and functions are declared 
in this C++ namespace. (It is possible to provide a parent namespace which contains the main namespace. 
A parent directory containing the main directory is created too in this case.)
All resources must be under the same root base directory (default: ${CMAKE_CURRENT_SOURCE_DIR}). 
Each subdirectory in the relative resource path to this root is reproduced in the generated code tree.

&ensp;&ensp;&ensp;&ensp;The tool headers are directly under the main directory. The parent directory is never present 
in the resource paths.

&ensp;&ensp;&ensp;&ensp;To use the resource library, the paths to include must begin with the *main-directory/* 
(or *parent-namespace/main-directory*/ if you provide a parent namespace).

&ensp;&ensp;&ensp;&ensp;Target basic arguments:
- *target_name* :  The name of the library target. It determines the main directory containing the generated code files, 
and also the namespace containing all generated constants, types and functions.
- SHARED|STATIC : Indicates if the target must be a shared or a static library.

&ensp;&ensp;&ensp;&ensp;Resources arguments:
- RESOURCES *resource_files* :  A list of absolute paths to the resource files.
(You can use ${CMAKE_CURRENT_SOURCE_DIR} to provide absolute paths.)
- [RESOURCES_BASE_DIR *base_dir*] :  The common root directory containing all the resources. (*${CMAKE_CURRENT_SOURCE_DIR}* used by default.)

&ensp;&ensp;&ensp;&ensp;Generated code arguments:
- [CONTEXT_NAMESPACE *namespace*] :  A namespace containing the main namespace defined by *NAME*. It generates a directory parent to the main directory too.
- [INLINE_CONTEXT_NAMESPACE *namespace*] :  An inline namespace containing the main namespace defined by *NAME*. The parent directory is created too.
(Use INLINE_CONTEXT_NAMESPACE or CONTEXT_NAMESPACE, not both.)
- [VIRTUAL_ROOT *vroot*] :  A string prepending each generated resource path.
- [PRIVATE_RESOURCE_HEADERS] :  An option argument indicating that all generated resource headers cannot be used by a user of the library. (So, it is not installed with the library too.)
- [PRIVATE_RESOURCE_PATHS_HEADER] :  An option argument indicating that the generated headers providing resource paths cannot be used by a user of the library. (So, it is not installed with the library too.)

&ensp;&ensp;&ensp;&ensp;Generated code directories arguments:
- [BUILD_RESOURCE_HEADERS_BASE_DIR *base_dir*] :  The directory where the header file tree is generated. The main directory (or the parent directory if any) is a direct subdirectory of it. This directory is appended to BUILD_HEADERS_BASE_DIRS automatically. (*${CMAKE_CURRENT_BUILD_DIR}/include* used by default.)
- [BUILD_RESOURCE_SOURCES_BASE_DIR *base_dir*] :  The directory where the source file tree is generated. The main directory (or the parent directory if any) is a direct subdirectory of it. (*${CMAKE_CURRENT_BUILD_DIR}/src* used by default.)
- [PRIVATE_BUILD_RESOURCE_HEADERS_BASE_DIR *base_dir*] :  The directory where the private header file tree is generated. The main directory (or the parent directory if any) is a direct subdirectory of it. (*${CMAKE_CURRENT_BUILD_DIR}/private_include* used by default.)

&ensp;&ensp;&ensp;&ensp;The following arguments of [`add_cpp_library(target_name SHARED|STATIC ...)`](CppLibraryProject.md) are compatible with this function:
- CXX_STANDARD
- HEADERS
- SOURCES
- HEADERS_BASE_DIRS
- BUILD_HEADERS_BASE_DIRS
- LIBRARY_OUTPUT_DIRECTORY
- ARCHIVE_OUTPUT_DIRECTORY
- DEFAULT_WARNING_OPTIONS
- DEFAULT_ERROR_OPTIONS

<u>Example:</u><br />
Here, we have our source project tree:
```
myrsclib/
`-- CMakeList.txt
`-- rsc/
    `-- background.png
    `-- animals/
        `-- bird.png
        `-- cat.png
    `-- plants/
        `-- rose.png
        `-- daisy.png
```
The function `add_rsc_cpp_library()` is called with the following parameters:
```cmake
add_rsc_cpp_library(
    myrsclib SHARED
    RESOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/rsc/background.png
        ${CMAKE_CURRENT_SOURCE_DIR}/rsc/animals/bird.png
        ${CMAKE_CURRENT_SOURCE_DIR}/rsc/animals/cat.png
        ${CMAKE_CURRENT_SOURCE_DIR}/rsc/plants/rose.png
        ${CMAKE_CURRENT_SOURCE_DIR}/rsc/plants/daisy.png
    RESOURCES_BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/rsc" 
    VIRTUAL_ROOT "RSC:/"
    CXX_STANDARD 20
)
```
It will generate the following public install:
```
local/
`-- include/
    `--
    `-- paths.hpp
    `-- find_serialized_resource.hpp
    `-- background.hpp
    `-- animals/
        `-- bird.hpp
        `-- cat.hpp
    `-- plants/
        `-- rose.hpp
        `-- daisy.hpp
`-- lib/
    `-- myrsclib.so
```
Resource path to `bird.png` is `RSC:/animals/bird.png`.<br />
A resource can be found by calling `myrsclib::find_serialized_resource("RSC:/animals/bird.png")`.
