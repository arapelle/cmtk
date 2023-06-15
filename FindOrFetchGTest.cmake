
# include(${CMAKE_CURRENT_LIST_DIR}/Utility.cmake)

macro(find_or_fetch_GTest)
    if(NOT TARGET GTest::gtest_main)
        cmake_parse_arguments("ARG" "QUIET" "TAG" "" ${ARGN})
        include(GoogleTest)
        set(fp_args)
        if(ARG_QUIET)
            list(APPEND fp_args "QUIET")
        endif()
        find_package(GTest ${fp_args})
        if(NOT GTest_FOUND)
            if(NOT ARG_TAG)
                set(ARG_TAG "v1.13.0")
            endif()
            include(FetchContent)
            FetchContent_Declare(
              googletest
              URL https://github.com/google/googletest/archive/refs/tags/${ARG_TAG}.zip
            )
            set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
            FetchContent_MakeAvailable(googletest)
        endif()
    endif()
endmacro()
