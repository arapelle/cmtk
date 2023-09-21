
# Utility

## Include
`cmtk/Utility`

## Macros & Functions
### Macro `fatal_ifdef(msg ...)`

&ensp;&ensp;&ensp;&ensp;Raise a fatal error if one of the given names is a defined variable. (e.g. `fatal_ifdef("FATAL ERROR!" PROBLEM BOMB)`)

- *msg* :  The error message to display if needed.

### Macro `fatal_ifndef()`

&ensp;&ensp;&ensp;&ensp;Raise a fatal error if one of the given names is NOT a defined variable. (e.g. `fatal_ifndef("FATAL ERROR!" ID_VAR BUILD_TYPE)`)

- *msg* :  The error message to display if needed.

### Function `fatal_if_none_is_def()`

&ensp;&ensp;&ensp;&ensp;Raise a fatal error if none of the given names is a defined variable. (e.g. `fatal_ifndef("FATAL ERROR!" EXPECTED)`)

- *msg* :  The error message to display if needed.

### Macro `set_ifndef(var_name value)`

&ensp;&ensp;&ensp;&ensp;Set a variable if it is not defined yet.

- *var_name* :  The named of the variable.
- *value* :  The value to give to the variable if it is not defined.

### Macro `set_iftest(var_name)`

&ensp;&ensp;&ensp;&ensp;Set a variable according to a test. It the test is `true` a value is set, else another one.

- *var_name* :  The named of the variable.
- IF *test* : The test to evaluate.
- THEN *value* : The value to assign if the test is `true`.
- [ELSE *value*] : The value to assign if the test is `false`.

### Function `trioption(varname help_text initial)`

&ensp;&ensp;&ensp;&ensp;Define a cached variable with three possible states : `ON`, `OFF` and `UNDEFINED`.

- *varname* :  The name of the cached variable.
- *help_text* :  The description of the cached variable.
- *initial* :  The initial value of the cached variable.

### Function `option_or_set_ifdef(variable help_text initial ascendant_variable)`

&ensp;&ensp;&ensp;&ensp;Set a *variable* according to *ascendant variable*, or create an option. If the *ascendant 
variable* is not defined or if its value is `UNDEFINED` we create an option instead of setting the value of 
this *ascendant variable* to *variable*.

- *variable* :  The name of the variable/option to set/create.
- *help_text* :  The description of the cached variable, if we create an option.
- *initial* :  The initial value of the cached variable, if we create an option.
- *ascendant_variable* :  The ascendant variable to evaluate.

### Function `trioption_or_set_ifdef()`

&ensp;&ensp;&ensp;&ensp;Set a *variable* according to *ascendant variable*, or create a trioption. If the *ascendant 
variable* is not defined or if its value is `UNDEFINED` we create an trioption instead of setting the value of 
this *ascendant variable* to *variable*.

- *variable* :  The name of the variable/trioption to set/create.
- *help_text* :  The description of the cached variable, if we create an trioption.
- *initial* :  The initial value of the cached variable, if we create an trioption.
- *ascendant_variable* :  The ascendant variable to evaluate.

### Macro `make_lower_c_identifier(str return_var)`

&ensp;&ensp;&ensp;&ensp;Convert a string to a C identifier in lower case.

- *str*: The string to convert.
- *return_var* :  Variable in the calling scope containing the generated string.

### Macro `make_upper_c_identifier(str return_var)`

&ensp;&ensp;&ensp;&ensp;Convert a string to a C identifier in upper case.

- *str*: The string to convert.
- *return_var* :  Variable in the calling scope containing the generated string.

### Macro `find_package_if_not_target(target package_name)`

&ensp;&ensp;&ensp;&ensp;Call `find_package(package_name ${ARGN})` if *target* is not a TARGET.

- *target*: The target we are looking for.
- *package_name* :  The package to find if *target* is not a TARGET.
