
macro(to_var_name str output_var)
  string(REGEX REPLACE "[\ -]" "_" ${output_var} ${str})
endmacro()

macro(to_lower_var_name str output_var)
  to_var_name(${str} ${output_var})
  string(TOLOWER ${${output_var}} ${output_var})
endmacro()

macro(to_upper_var_name str output_var)
  to_var_name(${str} ${output_var})
  string(TOUPPER ${${output_var}} ${output_var})
endmacro()

function(target_simple_cpp_dependency target build_type dependency_target)
    string(TOUPPER ${build_type} build_type)
    target_include_directories(${target} PRIVATE $<TARGET_PROPERTY:${dependency_target},INTERFACE_INCLUDE_DIRECTORIES>)
    target_link_libraries(${target} PRIVATE $<TARGET_PROPERTY:${dependency_target},IMPORTED_LOCATION_${build_type}>)
endfunction()

function(target_simple_cpp_dependencies target build_type dependency_targets)
    foreach(dependency_target ${dependency_targets})
        target_simple_cpp_dependency(target ${build_type} ${dependency_target})
    endforeach()
endfunction()
