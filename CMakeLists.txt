cmake_minimum_required(VERSION 3.23)

project(CmakeHelpers)

if(NOT ${PROJECT_IS_TOP_LEVEL})
    find_package(Git 2.22 REQUIRED)
    list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})
    include(gitHelpers)
endif()


