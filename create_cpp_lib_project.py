#!/usr/bin/python3

import os
import shutil
import argparse
import tkinter as tk
from tkinter import messagebox
from tkinter import simpledialog

python_current_dir = os.path.dirname(os.path.realpath(__file__))

argparser = argparse.ArgumentParser()
argparser.add_argument('-p', '--project-name', metavar='name', type=str, default="", help='Project name')
argparser.add_argument('--cmake', metavar='cmake-path', type=str, default="cmake", help='Path or alias to call cmake')
pargs = argparser.parse_args()

# CMake Metadata
import subprocess
import json
result = subprocess.run("{} -E capabilities".format(pargs.cmake).split(), stdout=subprocess.PIPE)
cmake_metadata = result.stdout.decode('utf-8')
cmake_metadata = json.loads(cmake_metadata)
# print(json.dumps(cmake_metadata, sort_keys=True, indent=2))
cmake_version = cmake_metadata["version"]
cmake_major = cmake_version["major"]
cmake_minor = cmake_version["minor"]
#---

# hide main window
root = tk.Tk()
root.withdraw()

project_name = pargs.project_name
while not project_name:
    project_name = simpledialog.askstring("Project Name", "Project name: ")

print("Project name: '{}'".format(project_name))

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

# Write test CMakeLists.txt
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
check_cmake_binary_dir()\n\
set_build_type_if_undefined()\n\
\n\
#-----\n\
# C++ PROJECT\n\
\n\
project({pname}\n\
        VERSION 0.1.0\n\
#        DESCRIPTION \"\"\n\
#        HOMEPAGE_URL \"\"\n\
        LANGUAGES CXX)\n\
\n\
include(CTest)\n\
\n\
add_public_cpp_library(VERSION_HEADER \"version.hpp\"\n\
                       VERBOSE_PACKAGE_CONFIG_FILE)\n\
\n\
#-----\n".format(pname=project_name, cmake_major=cmake_major, cmake_minor=cmake_minor)
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
