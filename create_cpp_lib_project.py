#!/usr/bin/python3

import os
import shutil
import argparse
import re
import tkinter as tk
from tkinter import messagebox
from tkinter import simpledialog

# python current dir
python_current_dir = os.path.dirname(os.path.realpath(__file__))

# hide main window
root = tk.Tk()
root.withdraw()

#-----------
# Parse args
#-----------
argparser = argparse.ArgumentParser()
argparser.add_argument('project_name', nargs='?', type=str, help='Project name')
argparser.add_argument('--cmake', metavar='cmake-path', type=str, default="cmake", help='Path or alias to CMake')
pargs = argparser.parse_args()

#---------------
# CMake Metadata
#---------------
import subprocess
import json
if not pargs.cmake or not shutil.which(pargs.cmake):
    messagebox.showerror("CMake not found!", "CMake cannot be found.\nUse option --cmake.\n\n{}".format(argparser.format_usage()))
    exit(-1)
result = subprocess.run("{} -E capabilities".format(pargs.cmake).split(), stdout=subprocess.PIPE)
cmake_metadata = result.stdout.decode('utf-8')
cmake_metadata = json.loads(cmake_metadata)
# print(json.dumps(cmake_metadata, sort_keys=True, indent=2))
cmake_version = cmake_metadata["version"]
cmake_major = cmake_version["major"]
cmake_minor = cmake_version["minor"]
if cmake_major < 3 or cmake_minor < 13:
    messagebox.showerror("Update your CMake!", "Your CMake version is too low: {}.{}.\nUse CMake 3.13 or later!".format(cmake_major, cmake_minor))
#---

#---------------
# Default values
#---------------
default_project_version = "0.1.0"
default_cpp_version = "17"
# default_cmake_build_in_tree = False
default_cmake_project_config_type = "VERBOSE"
default_gitignore = True
default_license_type = "MIT"
default_license_copyright_holders = "<copyright holders>"

#-------------------------
# Check and set parameters
#-------------------------

def cancel_project_creation(res = 0):
    print("Project creation canceled.")
    exit(res)

def ask_parameter(label:str, default_value:str):
    return simpledialog.askstring(label, label + ": ", initialvalue=default_value)

def ask_bool_parameter(label:str):
    return messagebox.askyesnocancel(label, label + ": ")

def init_parameter(label:str, default_value, check_fn, input_value=None, ask_fn=None):
    parameter_is_bool = type(default_value) == type(True)
    if ask_fn is None:
        if parameter_is_bool:
            ask_fn = lambda: ask_bool_parameter(label)
        else:
            ask_fn = lambda: ask_parameter(label, default_value)
    param = None if parameter_is_bool else default_value.__new__(type(default_value))
    if input_value is not None:
        param = input_value
    while not check_fn(param):
        param = ask_fn()
        if param is None:
            cancel_project_creation()
    print("Parameter '{}': '{}'".format(label, param))
    return param

def init_bool_parameter(label:str, input_value=None):
    check_fn = lambda option: option != None and type(option) == type(True)
    return init_parameter(label, False, check_fn, input_value, ask_bool_parameter)

# Project: Project name
project_name = init_parameter("Project name", "", lambda pname: len(pname) > 0, pargs.project_name)

# Project: Project version
def check_project_version(project_version):
    regexp = re.compile('[0-9]+.[0-9]+.[0-9]+')
    return regexp.fullmatch(project_version) != None
project_version = init_parameter("Project version", default_project_version, check_project_version)

# CMakeLists.txt: C++ version
cml_cpp_version = init_parameter("C++ version", default_cpp_version, lambda version: version in ["11","14","17","20"])

# CMakeLists.txt: Build in tree
cml_build_in_tree = init_parameter("Allowing build-in tree", False, lambda option: option != None)
cml_build_in_tree = "check_cmake_binary_dir()\n" if cml_build_in_tree else ""

# CMakeLists.txt: Create version header
cml_create_version_header_code = init_bool_parameter("Do you want a version header file?")
cml_create_version_header_code = "    VERSION_HEADER \"version.hpp\"\n" if cml_create_version_header_code else ""

# CMakeLists.txt: cmake_project_config_type = "VERBOSE" # BASIC | VERBOSE (| CUSTOM (in version 0.2.0))
cml_cmake_project_config_type = init_parameter("Project config type (BASIC | VERBOSE)", default_cmake_project_config_type, lambda type: type in ["BASIC", "VERBOSE"])

# Git: gitignore
git_create_gitignore = init_bool_parameter("Do you want a .gitignore file?")

# License: (only MIT available for the moment)
license_create_license_file = init_bool_parameter("Do you want a license file?")
license_file_name = ""
license_copyright_holders = ""
if license_create_license_file:
    license_file_name = init_parameter("License file name?", "LICENSE.md", lambda pname: len(pname) > 0)
    license_copyright_holders = init_parameter("Who are the copyright holders?", "", lambda pname: len(pname) > 0)

# Readme: file name
readme_create_readme_file = init_bool_parameter("Do you want a readme file?")
readme_file_name = ""
if readme_create_readme_file:
    readme_file_name = init_parameter("Readme file name?", "README.md", lambda pname: len(pname) > 0)

#-----------------
# Create file tree
#-----------------

if os.path.exists(project_name):
    print("Remove dir '{}'".format(project_name))
    shutil.rmtree(project_name)
print("Create dir '{}'".format(project_name))
os.makedirs(project_name)

shutil.copytree(python_current_dir + "/cmake", project_name + "/cmake")

include_dir = "include"
project_include_dir = include_dir + "/" + project_name
src_dir = "src"
test_dir = "test"
example_dir = "example"
subdirs = [project_include_dir, src_dir, test_dir, example_dir]
for subdir in subdirs:
    path = "{proot}/{sub}".format(proot=project_name, sub=subdir)
    print("Create dir '{}'".format(path))
    os.makedirs(path)

# Write README file
with open(project_name + "/README.md", "w") as readme_file:
    readme_file.write(project_name + "\n")

# Write project header
header_path = "{pname}/{include}/{pname}.hpp".format(include=project_include_dir, pname=project_name)
with open(header_path, "w") as header_file:
    content = "#pragma once \n\
\n\
#include <string>\n\
\n\
std::string libname();\n".format(project_name)
    header_file.write(content)

# Write project source
source_path = "{pname}/{src}/{pname}.cpp".format(src=src_dir, pname=project_name)
with open(source_path, "w") as source_file:
    content = "#include <{pname}/{pname}.hpp> \n\
\n\
std::string libname()\n\
{{\n\
    return \"{pname}\";\n\
}}\n".format(pname=project_name)
    source_file.write(content)

# Write test CMakeLists.txt
test_cmakelists_path = "{proot}/{sub}/CMakeLists.txt".format(proot=project_name, sub=test_dir)
with open(test_cmakelists_path, "w") as test_cmakelists_file:
    content = "\nadd_public_cpp_library_tests(${PROJECT_NAME})\n"
    test_cmakelists_file.write(content)

# Write example CMakeLists.txt
example_cmakelists_path = "{proot}/{sub}/CMakeLists.txt".format(proot=project_name, sub=example_dir)
with open(example_cmakelists_path, "w") as example_cmakelists_file:
    content = "\nadd_public_cpp_library_examples(${PROJECT_NAME})\n"
    example_cmakelists_file.write(content)

# Write project CMakeLists.txt
project_cmakelists_path = "{}/CMakeLists.txt".format(project_name)
with open(project_cmakelists_path, "w") as project_cmakelists_file:
    content = "\n\
cmake_minimum_required(VERSION {cmake_major}.{cmake_minor})\n\
\n\
list(PREPEND CMAKE_MODULE_PATH ${{CMAKE_SOURCE_DIR}}/cmake/include)\n\
\n\
# Standard includes\n\
include(CMakePrintHelpers)\n\
# Custom include\n\
include(cmtk/CppLibraryProject)\n\
\n\
#-----\n\
# PROJECT\n\
\n\
{check_cmake_binary_dir_code}\
set_build_type_if_undefined()\n\
\n\
#-----\n\
# C++ PROJECT\n\
\n\
project({pname}\n\
        VERSION {pversion}\n\
#        DESCRIPTION \"\"\n\
#        HOMEPAGE_URL \"\"\n\
        LANGUAGES CXX)\n\
\n\
include(CTest)\n\
\n\
add_public_cpp_library(\n\
{create_version_header_code}\
    {cmake_project_config_type}_PACKAGE_CONFIG_FILE\n\
)\n\
\n\
#-----\n".format(pname=project_name, pversion=project_version, cmake_major=cmake_major, cmake_minor=cmake_minor, \
                 check_cmake_binary_dir_code=cml_build_in_tree, \
                 create_version_header_code=cml_create_version_header_code, \
                 cmake_project_config_type=cml_cmake_project_config_type)
    project_cmakelists_file.write(content)

# Write cmake_quick_install.cmake
cmake_quick_install_path = "{}/cmake_quick_install.cmake".format(project_name)
with open(cmake_quick_install_path, "w") as cmake_quick_install_file:
    content="# cmake -P cmake_quick_install.cmake\n\
\n\
set(project \"{project_name}\")\n\
\n\
if(WIN32)\n\
    set(temp_dir $ENV{{TEMP}})\n\
elseif(UNIX)\n\
    set(temp_dir /tmp)\n\
else()\n\
    message(FATAL_ERROR \"No temporary directory found!\")\n\
endif()\n\
\n\
file(TO_NATIVE_PATH \"/\" path_sep)\n\
set(src_dir ${{CMAKE_CURRENT_LIST_DIR}})\n\
set(build_dir ${{temp_dir}}${{path_sep}}${{project}}-build)\n\
set(error_file ${{build_dir}}${{path_sep}}quick_install_error)\n\
\n\
if(EXISTS ${{error_file}})\n\
    message(STATUS \"Previous call to quick_install.cmake failed. Cleaning...\")\n\
    file(REMOVE_RECURSE ${{build_dir}})\n\
endif()\n\
\n\
message(STATUS \"*  CONFIGURATION\")\n\
execute_process(COMMAND ${{CMAKE_COMMAND}} -DCMAKE_BUILD_TYPE=${{CMAKE_BUILD_TYPE}} -S ${{src_dir}} -B ${{build_dir}}  RESULT_VARIABLE cmd_res)\n\
if(NOT cmd_res EQUAL 0)\n\
    file(TOUCH ${{error_file}})\n\
    return()\n\
endif()\n\
\n\
message(STATUS \"*  BUILD\")\n\
execute_process(COMMAND ${{CMAKE_COMMAND}} --build ${{build_dir}}  RESULT_VARIABLE cmd_res)\n\
if(NOT cmd_res EQUAL 0)\n\
    file(TOUCH ${{error_file}})\n\
    return()\n\
endif()\n\
\n\
message(STATUS \"*  INSTALL\")\n\
execute_process(COMMAND ${{CMAKE_COMMAND}} --install ${{build_dir}})\n\
if(NOT cmd_res EQUAL 0)\n\
    file(TOUCH ${{error_file}})\n\
endif()\n".format(project_name=project_name)
    cmake_quick_install_file.write(content)

print("EXIT SUCCESS")
