
EchoWithColor(COLOR GREEN "-- Configure Test Projects")

find_package(GTest)
set (PROJECT_LIBCOPP_TEST_LIB_LINK "")

# =========== find gtest ===========
if (GTEST_FOUND)
    EchoWithColor(COLOR GREEN "-- GTest Found: ${GTEST_LIBRARIES}")
	add_compiler_define(COPP_MACRO_TEST_ENABLE_GTEST=1)
	set (PROJECT_LIBCOPP_TEST_LIB_LINK ${GTEST_LIBRARIES})
    include_directories(${GTEST_INCLUDE_DIRS})

# =========== enable find boost.test ===========
elseif(LIBCOPP_TEST_ENABLE_BOOST_UNIT_TEST)
    
    find_package(Boost COMPONENTS unit_test_framework)
    set(Boost_AUTO_LIBS "${Boost_LIBRARIES}")
    
    if(Boost_FOUND)
        set(Boost_USE_STATIC_LIBS ON)
        find_package(Boost COMPONENTS unit_test_framework)
        if(NOT Boost_FOUND)
            set(Boost_USE_STATIC_LIBS OFF)
            find_package(Boost COMPONENTS unit_test_framework)
        elseif(NOT "${Boost_LIBRARIES}" EQUAL "${Boost_AUTO_LIBS}")
            set(Boost_USE_STATIC_LIBS OFF)
            find_package(Boost COMPONENTS unit_test_framework)
        endif()
        
        add_compiler_define(COPP_MACRO_TEST_ENABLE_BOOST_TEST=1)
        set (PROJECT_LIBCOPP_TEST_LIB_LINK ${Boost_LIBRARIES})
        include_directories(${Boost_INCLUDE_DIRS})
        EchoWithColor(COLOR GREEN "-- Boost.test Found: ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY}")
        
        if (NOT Boost_USE_STATIC_LIBS)
            EchoWithColor(COLOR GREEN "-- Boost.test using dynamic library define BOOST_TEST_DYN_LINK")
            add_compiler_define(BOOST_TEST_DYN_LINK)
        endif()
    else()
        EchoWithColor(COLOR RED "-- Enable boost unit test but boost.test not found.")
    endif()
endif()

include_directories(${PROJECT_TEST_INC_DIR})

file(GLOB_RECURSE COPP_TEST_SRC_LIST 
    ${PROJECT_TEST_SRC_DIR}/*.h 
    ${PROJECT_TEST_SRC_DIR}/*.hpp 
    ${PROJECT_TEST_SRC_DIR}/*.c 
    ${PROJECT_TEST_SRC_DIR}/*.cpp
    ${PROJECT_TEST_SRC_DIR}/*.cc 
    ${PROJECT_TEST_SRC_DIR}/*.cxx
)
source_group_by_dir(COPP_TEST_SRC_LIST)


# ================ multi thread ================
if ( NOT MSVC )
    add_definitions(-D_POSIX_MT_)
    set (PROJECT_LIBCOPP_TEST_LIB_LINK ${PROJECT_LIBCOPP_TEST_LIB_LINK} pthread)
endif()

# ============ test - coroutine test frame ============
set(EXECUTABLE_OUTPUT_PATH "${PROJECT_BINARY_DIR}/test")
if (MSVC)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${EXECUTABLE_OUTPUT_PATH})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${EXECUTABLE_OUTPUT_PATH})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${EXECUTABLE_OUTPUT_PATH})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL ${EXECUTABLE_OUTPUT_PATH})
endif()

add_executable(coroutine_test ${COPP_TEST_SRC_LIST})
target_link_libraries(coroutine_test 
    ${PROJECT_LIBCOTASK_LIB_LINK}
    ${PROJECT_LIBCOPP_LIB_LINK} 
    ${PROJECT_LIBCOPP_TEST_LIB_LINK}
    ${COMPILER_OPTION_EXTERN_CXX_LIBS}
)

add_custom_target(run_test_coroutine_test
    "./coroutine_test${CMAKE_EXECUTABLE_SUFFIX}"
    WORKING_DIRECTORY ${EXECUTABLE_OUTPUT_PATH}
)
add_dependencies(run_test run_test_coroutine_test)
add_dependencies(run_test_coroutine_test coroutine_test)

if (_VALGRIND_EXECUTABLE)
    add_custom_target(run_memcheck_coroutine_test
        ${_VALGRIND_EXECUTABLE} "--tool=memcheck" "--log-file=coroutine_test.memcheck.log" --leak-check=full --show-leak-kinds=all --malloc-fill=ef --free-fill=e5 "./coroutine_test"
        WORKING_DIRECTORY ${EXECUTABLE_OUTPUT_PATH}
    )
    add_dependencies(memcheck run_memcheck_coroutine_test)
    add_dependencies(run_memcheck_coroutine_test coroutine_test)
endif()