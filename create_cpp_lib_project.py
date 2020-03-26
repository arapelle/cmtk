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
    path = "{}/{}".format(project_name, subdir)
    print("Create dir '{}'".format(path))
    os.makedirs(path)

# Write README file
with open(project_name + "/README.md", "w") as readme_file:
    readme_file.write(project_name + "\n")

# Write project header
header_path = "{1}/{0}/{1}.hpp".format(project_include_dir, project_name)
with open(header_path, "w") as header_file:
    content = "#pragma once \n\
\n\
#include <string>\n\
\n\
std::string libname();\n".format(project_name)
    header_file.write(content)

# Write project source
source_path = "{1}/{0}/{1}.cpp".format(src_dir, project_name)
with open(source_path, "w") as source_file:
    content = "#include <{0}/{0}.hpp> \n\
\n\
std::string libname()\n\
{{\n\
    return \"{0}\";\n\
}}\n".format(project_name)
    source_file.write(content)

# Write test CMakeLists.txt
test_cmakelists_path = "{0}/{1}/CMakeLists.txt".format(project_name, test_dir)
with open(test_cmakelists_path, "w") as test_cmakelists_file:
    content = "\nadd_public_cpp_library_tests(${PROJECT_NAME})\n"
    test_cmakelists_file.write(content)

# Write test CMakeLists.txt
example_cmakelists_path = "{0}/{1}/CMakeLists.txt".format(project_name, example_dir)
with open(example_cmakelists_path, "w") as example_cmakelists_file:
    content = "\nadd_public_cpp_library_examples(${PROJECT_NAME})\n"
    example_cmakelists_file.write(content)

# Write project CMakeLists.txt
project_cmakelists_path = "{0}/CMakeLists.txt".format(project_name)
with open(project_cmakelists_path, "w") as project_cmakelists_file:
    content = "\n\
cmake_minimum_required(VERSION {1}.{2})\n\
\n\
list(PREPEND CMAKE_MODULE_PATH ${{CMAKE_SOURCE_DIR}}/cmake/modules)\n\
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
project({0}\n\
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
#-----\n".format(project_name, cmake_major, cmake_minor)
    project_cmakelists_file.write(content)

print("EXIT SUCCESS")
