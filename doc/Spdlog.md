
# Spdlog

## Include
`cmtk/Spdlog`

## Functions

### Function `set_SPDLOG_ACTIVE_LEVEL_ifndef()`

&ensp;&ensp;&ensp;&ensp;Set a cached variable SPDLOG_ACTIVE_LEVEL, if it is nod defined yet.
- [TRACE *build_type_list*] :  List of build types for which SPDLOG_ACTIVE_LEVEL must be set to SPDLOG_LEVEL_TRACE.
- [DEBUG *build_type_list*] :  List of build types for which SPDLOG_ACTIVE_LEVEL must be set to SPDLOG_LEVEL_DEBUG. (*Debug* used by default)
- [INFO *build_type_list*] :  List of build types for which SPDLOG_ACTIVE_LEVEL must be set to SPDLOG_LEVEL_INFO. (*Release* used by default)

### Function `target_SPDLOG_ACTIVE_LEVEL_definition(target [PUBLIC|PRIVATE|INTERFACE] [level])`

&ensp;&ensp;&ensp;&ensp;Add compile definition SPDLOG_ACTIVE_LEVEL to *target*.

- *target* :  The target to add the compile definition to.
- [*level*] :  The spdlog level value of the compile definition. If this argument is used, SPDLOG_ACTIVE_LEVEL definition is defined with the value ${level}. Otherwise, it is defined with ${SPDLOG_ACTIVE_LEVEL}.
- [PUBLIC|PRIVATE|INTERFACE] :  The scope of the compile definition. (default: *PRIVATE*)
