
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
