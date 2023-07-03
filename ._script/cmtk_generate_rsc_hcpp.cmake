
include(CMakePrintHelpers)

function(get_script_args script_args)
    set(sc_args)
    foreach(argi RANGE ${CMAKE_ARGC})
        set(arg ${CMAKE_ARGV${argi}})
        list(APPEND sc_args ${arg})
    endforeach()
    set(${script_args} ${sc_args} PARENT_SCOPE)
endfunction()

#--

get_script_args(args)
set(options "")
set(params "CMTK_FTOBA;LIB_PATH;NAMESPACE;RSC_RELATIVE_DIR;RESOURCE")
set(lists "")
cmake_parse_arguments(ARG "${options}" "${params}" "${lists}" ${args})

file(TO_CMAKE_PATH "${ARG_LIB_PATH}" ARG_LIB_PATH)
file(TO_CMAKE_PATH "${ARG_RSC_RELATIVE_DIR}" ARG_RSC_RELATIVE_DIR)

# Get resource file stem as c_identifier
get_filename_component(rsc_stem ${ARG_RESOURCE} NAME_WE)
string(MAKE_C_IDENTIFIER ${rsc_stem} rsc_stem)

# Get resource file size
file(SIZE ${ARG_RESOURCE} rsc_file_size)

# Determine sub-namespace:
if(NOT "${ARG_RSC_RELATIVE_DIR}" STREQUAL "")
    string(REPLACE "/" "::" sub_namespace_path "${ARG_RSC_RELATIVE_DIR}")
    set(sub_namespace_begin "namespace ${sub_namespace_path} \n{")
    set(sub_namespace_end "}\n")
endif()

# Write resource cpp file.
set(rsc_cpp_path "${ARG_LIB_PATH}/${ARG_RSC_RELATIVE_DIR}/${rsc_stem}.cpp")
file(WRITE ${rsc_cpp_path} "// ${rsc_cpp_path}
// resource ${ARG_RESOURCE}

#include \"${rsc_stem}.hpp\"
#include <array>
#include <cstdint>

namespace ${ARG_NAMESPACE}
{
${sub_namespace_begin}
const std::array<const uint8_t, ${rsc_file_size}>& ${rsc_stem}__()
{
    static const std::array<const uint8_t, ${rsc_file_size}> bytes = 
")
# Write beginning of resource variable definition.
execute_process(COMMAND ${ARG_CMTK_FTOBA} ${ARG_RESOURCE} ${rsc_cpp_path})
file(APPEND ${rsc_cpp_path} "
    return bytes;
}

std::span<const std::byte, ${rsc_file_size}> ${rsc_stem}() { return std::as_bytes(std::span( ${rsc_stem}__() )); }
${sub_namespace_end}
}
")

# Write resource hpp file.
set(rsc_hpp_path "${ARG_LIB_PATH}/${ARG_RSC_RELATIVE_DIR}/${rsc_stem}.hpp")
file(WRITE ${rsc_hpp_path} "#pragma once

#include <span>

namespace ${ARG_NAMESPACE}
{
${sub_namespace_begin}
std::span<const std::byte, ${rsc_file_size}> ${rsc_stem}();
${sub_namespace_end}
}
")
