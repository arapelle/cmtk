
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
set(params "LIB_NAME;LIB_PATH;NAMESPACE;BASE_DIR;VIRTUAL_ROOT")
set(lists "RESOURCES")
cmake_parse_arguments(ARG "${options}" "${params}" "${lists}" ${args})

set(rsc_lib_hpp_path "${ARG_LIB_PATH}/${ARG_LIB_NAME}.hpp")
set(rsc_lib_cpp_path "${ARG_LIB_PATH}/${ARG_LIB_NAME}.cpp")

# Write resource lib hpp file.
file(WRITE ${rsc_lib_hpp_path} "// ${rsc_lib_hpp_path}\n
#pragma once

#include <string_view>
#include <span>
#include <unordered_map>
#include <array>
#include <optional>
#include <cstdint>

namespace ${ARG_NAMESPACE}
{
std::optional<std::span<const std::byte>> find_serialized_resource(const std::string_view& rsc_path);

")
# Write resource lib cpp file.
file(WRITE ${rsc_lib_cpp_path} "#include \"${ARG_LIB_NAME}.hpp\"
#include <unordered_map>

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
    # Write resource var declaration.
    file(RELATIVE_PATH rel_rsc_path ${ARG_BASE_DIR} ${rsc_path})
    set(rel_rsc_path "${ARG_VIRTUAL_ROOT}${rel_rsc_path}")
    file(APPEND ${rsc_lib_hpp_path} "constexpr std::string_view ${rsc_stem}_path = \"${rel_rsc_path}\";
std::span<const std::byte, ${rsc_file_size}> ${rsc_stem}();\n
")
    file(APPEND ${rsc_lib_cpp_path} "        { ${rsc_stem}_path, ${rsc_stem}() },\n")
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
")
file(APPEND ${rsc_lib_hpp_path} "
}
")
