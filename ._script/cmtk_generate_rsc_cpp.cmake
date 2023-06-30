
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

# Get path to resource library header
set(rsc_p_dir "${ARG_RSC_RELATIVE_DIR}")
cmake_path(GET ARG_LIB_PATH FILENAME path_to_hpp)
set(path_to_hpp "${path_to_hpp}.hpp")
while(NOT "${rsc_p_dir}" STREQUAL "")
    set(path_to_hpp "../${path_to_hpp}")
    cmake_path(GET rsc_p_dir PARENT_PATH rsc_p_dir)
endwhile()

# Get resource file stem as c_identifier
get_filename_component(rsc_stem ${ARG_RESOURCE} NAME_WE)
string(MAKE_C_IDENTIFIER ${rsc_stem} rsc_stem)

# Get resource file size
file(SIZE ${ARG_RESOURCE} rsc_file_size)

# Write resource cpp file.
set(rsc_cpp_path "${ARG_LIB_PATH}/${ARG_RSC_RELATIVE_DIR}/${rsc_stem}.cpp")
file(WRITE ${rsc_cpp_path} "// ${rsc_cpp_path}
// resource ${ARG_RESOURCE}

#include \"${path_to_hpp}\"

namespace ${ARG_NAMESPACE}
{
const std::array<uint8_t, ${rsc_file_size}> ${rsc_stem} =
")
# Write beginning of resource variable definition.
execute_process(COMMAND ${ARG_CMTK_FTOBA} ${ARG_RESOURCE} ${rsc_cpp_path})
file(APPEND ${rsc_cpp_path} "}\n")
