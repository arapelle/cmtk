
include(${CMAKE_CURRENT_LIST_DIR}/Project.cmake)

macro(find_or_fetch_GTest)
    include(GoogleTest)
    if(NOT TARGET GTest::gtest_main)
        cmake_parse_arguments("M_ARG" "" "VERSION;TAG" "" ${ARGN})
        set_ifndef(M_ARG_VERSION "1.14.0")
        set_ifndef(M_ARG_TAG "v${M_ARG_VERSION}")
        include(FetchContent)
        FetchContent_Declare(
            googletest
            URL https://github.com/google/googletest/archive/refs/tags/${M_ARG_TAG}.zip
            DOWNLOAD_EXTRACT_TIMESTAMP false
            FIND_PACKAGE_ARGS ${M_ARG_VERSION} CONFIG NAMES GTest 
        )
        set(gtest_force_shared_crt ON CACHE BOOL "Use shared (DLL) run-time lib even when Google Test is built as static lib." FORCE)
        FetchContent_MakeAvailable(googletest)
        if(EXISTS ${FETCHCONTENT_BASE_DIR}/googletest-build)
            install_uninstall_script(GTest)
        endif()
    endif()
endmacro()
