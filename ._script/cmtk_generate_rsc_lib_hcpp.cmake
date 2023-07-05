
include(CMakePrintHelpers)

function(get_script_args script_args)
    set(sc_args)
    set(start_found False)
    foreach(argi RANGE ${CMAKE_ARGC})
        set(arg ${CMAKE_ARGV${argi}})
        if(start_found)
            list(APPEND sc_args ${arg})
        endif()
        if("${arg}" STREQUAL "--")
            set(start_found True)
        endif()
    endforeach()
    set(${script_args} ${sc_args} PARENT_SCOPE)
endfunction()

#--

get_script_args(args)
set(options "")
set(params "LIB_NAME;HEADER_LIB_PATH;SOURCE_LIB_PATH;PATHS_HEADER_PATH;NAMESPACE;BASE_DIR;VIRTUAL_ROOT;PARENT_NAMESPACE;INLINE")
set(lists "RESOURCES")
cmake_parse_arguments(ARG "${options}" "${params}" "${lists}" ${args})

set(rsc_lib_hpp_path "${ARG_HEADER_LIB_PATH}/${ARG_LIB_NAME}.hpp")
set(rsc_lib_cpp_path "${ARG_SOURCE_LIB_PATH}/${ARG_LIB_NAME}.cpp")
set(rsc_paths_hpp_path "${ARG_PATHS_HEADER_PATH}/paths.hpp")

# Determine parent namespace:
if(ARG_PARENT_NAMESPACE)
    if(ARG_INLINE)
        set(inline_decl "inline ")
    endif()
    set(parent_namespace_begin "${inline_decl}namespace ${ARG_PARENT_NAMESPACE} \n{")
    set(parent_namespace_end "}\n")
    set(parent_include_dir "${ARG_PARENT_NAMESPACE}/")
endif()

# Write resource paths hpp file.
file(WRITE ${rsc_paths_hpp_path} "#pragma once

#include <string_view>

${parent_namespace_begin}
namespace ${ARG_NAMESPACE}
{
")

# Write resource lib hpp file.
file(WRITE ${rsc_lib_hpp_path} "#pragma once

#include <span>
#include <optional>
#include <string_view>

${parent_namespace_begin}
namespace ${ARG_NAMESPACE}
{
std::optional<std::span<const std::byte>> find_serialized_resource(const std::string_view& rsc_path);

")
# Write resource lib cpp file.
file(WRITE ${rsc_lib_cpp_path} "#include <${parent_include_dir}${ARG_LIB_NAME}/${ARG_LIB_NAME}.hpp>
#include <${parent_include_dir}${ARG_LIB_NAME}/paths.hpp>
#include <unordered_map>
")
foreach(rsc_path ${ARG_RESOURCES})
    file(RELATIVE_PATH rel_rsc_path ${ARG_BASE_DIR} ${rsc_path})
    cmake_path(GET rel_rsc_path STEM rsc_stem)
    string(MAKE_C_IDENTIFIER ${rsc_stem} rsc_stem)
    cmake_path(REPLACE_FILENAME rel_rsc_path "${rsc_stem}.hpp")
    file(APPEND ${rsc_lib_cpp_path} "#include <${parent_include_dir}${ARG_LIB_NAME}/${rel_rsc_path}>\n")
endforeach()
file(APPEND ${rsc_lib_cpp_path} "
${parent_namespace_begin}
namespace ${ARG_NAMESPACE}
{
using resource_map_t = std::unordered_map<std::string_view, std::span<const std::byte>>;

const resource_map_t& resources__()
{
    static resource_map_t rsc_map =
    {
")

# Treat resource files.
foreach(rsc_path ${ARG_RESOURCES})
    # Get file size.
    file(SIZE ${rsc_path} rsc_file_size)
    # Get file stem.
    get_filename_component(rsc_stem ${rsc_path} NAME_WE)
    string(MAKE_C_IDENTIFIER ${rsc_stem} rsc_stem)
    # Determine sub-namespace:
    file(RELATIVE_PATH rel_rsc_path ${ARG_BASE_DIR} ${rsc_path})
    set(rel_rsc_vpath "${ARG_VIRTUAL_ROOT}${rel_rsc_path}")
    cmake_path(REMOVE_FILENAME rel_rsc_path)
    string(REPLACE "/" "::" sub_namespace_path "${rel_rsc_path}")
    if(NOT "${sub_namespace_path}" STREQUAL "")
        string(LENGTH "${sub_namespace_path}" sub_namespace_path_len)
        math(EXPR sub_namespace_path_len "${sub_namespace_path_len}-2")
        string(SUBSTRING "${sub_namespace_path}" 0 ${sub_namespace_path_len} sub_namespace_def)
        set(sub_namespace_begin "namespace ${sub_namespace_def}\n{\n")
        set(sub_namespace_end "\n}\n")
    else()
        set(sub_namespace_begin "")
        set(sub_namespace_end "")
    endif()
    # Write resource var declaration.
    #  in hpp
    file(APPEND ${rsc_paths_hpp_path} "${sub_namespace_begin}constexpr std::string_view ${rsc_stem}_path = \"${rel_rsc_vpath}\";${sub_namespace_end}
")
    #  in cpp
    file(APPEND ${rsc_lib_cpp_path} "        { ${sub_namespace_path}${rsc_stem}_path, ${sub_namespace_path}${rsc_stem}() },\n")
endforeach()

# End resource lib h/cpp files.
file(APPEND ${rsc_lib_cpp_path} "    };
    return rsc_map;
}

std::optional<std::span<const std::byte>> find_serialized_resource(const std::string_view& rsc_path)
{
    const auto& rsc_map = resources__();
    if (auto iter = rsc_map.find(rsc_path); iter != rsc_map.end()) [[likely]]
        return iter->second;
    return std::nullopt;
}
}
${parent_namespace_end}
")
file(APPEND ${rsc_lib_hpp_path} "}
${parent_namespace_end}
")
file(APPEND ${rsc_paths_hpp_path} "}
${parent_namespace_end}
")
