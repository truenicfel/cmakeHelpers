message(STATUS "Included git helpers cmake module! Requires git package.")
find_package(Git 2.22 REQUIRED)

# Get the git tag of a git repository
# Parameters:
# - PATH_TO_GIT_REPOSITORY: the path to the git repository
# Return values (variables set):
# - GIT_TAG: the tag name (string) or "n/a" if nothing was found
# - GIT_TAG_FOUND: True/False if a tag was found
function(getGitTag PATH_TO_GIT_REPOSITORY)
    set(RESULT_TAG "n/a")
    set(RESULT_FOUND False)
    if(GIT_FOUND AND EXISTS ${PATH_TO_GIT_REPOSITORY})
        execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags
                WORKING_DIRECTORY ${PATH_TO_GIT_REPOSITORY}
                OUTPUT_VARIABLE TAG
                RESULT_VARIABLE RETURN_VALUE
                ERROR_QUIET
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(RETURN_VALUE EQUAL "0")
            set(RESULT_TAG "${TAG}")
            set(RESULT_FOUND True)
        endif()
    endif()
    set(GIT_TAG "${RESULT_TAG}" PARENT_SCOPE)
    set(GIT_TAG_FOUND ${RESULT_FOUND} PARENT_SCOPE)
endfunction()

# Get the latest git tag that matches the standard version definition (v.X.X.X.X)
# Parameters:
# - PATH_TO_GIT_REPOSITORY: the path to the git repository
# Return values (variables set):
# VERSION_MAJOR: major version
# VERSION_MINOR: minor version
# VERSION_PATCH: patch version
# VERSION_TWEAK: tweak version
# VERSION_COMBINED: all of the above combined with dots
# COMMIT_NUMBER_AFTER_VERSION: the number of commits on top of the latest version tag
# GIT_TAG_VERSION_FOUND: True/False if operation was successful
function(getVersionFromGitTag PATH_TO_GIT_REPOSITORY)

    set(VERSION_MAJOR "")
    set(VERSION_MINOR "")
    set(VERSION_PATCH "")
    set(VERSION_TWEAK "")
    set(VERSION_COMBINED "")
    set(COMMIT_NUMBER_AFTER_VERSION "")
    set(GIT_TAG_VERSION_FOUND False)


    if(GIT_FOUND AND EXISTS ${PATH_TO_GIT_REPOSITORY})
        execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags --dirty --match "v*" --long
                WORKING_DIRECTORY ${PATH_TO_GIT_REPOSITORY}
                OUTPUT_VARIABLE DESCRIBE_OUTPUT
                RESULT_VARIABLE RETURN_VALUE_DESCRIBE
                ERROR_QUIET
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(RETURN_VALUE_DESCRIBE EQUAL "0")
            string(REPLACE "-" ";" ELEMENTS ${DESCRIBE_OUTPUT})
            list(GET ELEMENTS 0 VERSION)
            list(GET ELEMENTS 1 COMMIT_NUMBER_AFTER_VERSION)
            string(SUBSTRING ${VERSION} 1 -1 VERSION_CLEAN)

            string(REPLACE "." ";" VERSION_ELEMENTS ${VERSION_CLEAN})
            set(VERSION_COMBINED ${VERSION_CLEAN})
            list(LENGTH VERSION_ELEMENTS VERSION_ELEMENT_COUNT)
            if(VERSION_ELEMENT_COUNT GREATER 0)
                list(GET VERSION_ELEMENTS 0 VERSION_MAJOR)
                if(VERSION_ELEMENT_COUNT GREATER 1)
                    list(GET VERSION_ELEMENTS 1 VERSION_MINOR)
                    if(VERSION_ELEMENT_COUNT GREATER 2)
                        list(GET VERSION_ELEMENTS 2 VERSION_PATCH)
                        if(VERSION_ELEMENT_COUNT GREATER 3)
                            list(GET VERSION_ELEMENTS 0 VERSION_TWEAK)
                        endif()
                    endif()
                endif()
            endif()
            set(GIT_TAG_VERSION_FOUND True)
        endif()
    endif()

    set(VERSION_MAJOR ${VERSION_MAJOR} PARENT_SCOPE)
    set(VERSION_MINOR ${VERSION_MINOR} PARENT_SCOPE)
    set(VERSION_PATCH ${VERSION_PATCH} PARENT_SCOPE)
    set(VERSION_TWEAK ${VERSION_TWEAK} PARENT_SCOPE)
    set(VERSION_COMBINED ${VERSION_COMBINED} PARENT_SCOPE)
    set(COMMIT_NUMBER_AFTER_VERSION ${COMMIT_NUMBER_AFTER_VERSION} PARENT_SCOPE)
    set(GIT_TAG_VERSION_FOUND ${GIT_TAG_VERSION_FOUND} PARENT_SCOPE)

endfunction()

# Get the current git hash in long format
# Parameters:
# - PATH_TO_GIT_REPOSITORY: the path to the git repository
# Return values (variables set):
# COMMIT_HASH: the hash
# COMMIT_HASH_FOUND: True/False if operation was successful
function(getGitHash PATH_TO_GIT_REPOSITORY)
    set(COMMIT_HASH_FOUND False)
    set(COMMIT_HASH "")

    if(GIT_FOUND AND EXISTS ${PATH_TO_GIT_REPOSITORY})

        execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
                WORKING_DIRECTORY ${PATH_TO_GIT_REPOSITORY}
                OUTPUT_VARIABLE COMMIT_HASH
                RESULT_VARIABLE RETURN_VALUE_REV
                ERROR_QUIET
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(RETURN_VALUE_REV EQUAL "0")
            set(COMMIT_HASH_FOUND True)
        endif()

    endif()

    set(COMMIT_HASH_FOUND ${COMMIT_HASH_FOUND} PARENT_SCOPE)
    set(COMMIT_HASH ${COMMIT_HASH} PARENT_SCOPE)

endfunction()

# Get the git branch of a git repository
# Parameters:
# - PATH_TO_GIT_REPOSITORY: the path to the git repository
# Return values (variables set):
# - GIT_BRANCH: the branch name (string) or "n/a" if nothing was found
# - GIT_BRANCH_FOUND: True/False if a branch was found
function(getGitBranch PATH_TO_GIT_REPOSITORY)
    set(RESULT_BRANCH "n/a")
    set(RESULT_FOUND False)
    if(GIT_FOUND AND EXISTS ${PATH_TO_GIT_REPOSITORY})
        execute_process(COMMAND ${GIT_EXECUTABLE} branch --show-current
                WORKING_DIRECTORY ${PATH_TO_GIT_REPOSITORY}
                OUTPUT_VARIABLE BRANCH
                RESULT_VARIABLE RETURN_VALUE
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(RETURN_VALUE EQUAL "0")
            set(RESULT_BRANCH "${BRANCH}")
            set(RESULT_FOUND True)
        endif()
    endif()
    set(GIT_BRANCH "${RESULT_BRANCH}" PARENT_SCOPE)
    set(GIT_BRANCH_FOUND ${RESULT_FOUND} PARENT_SCOPE)
endfunction()

# Prints information about a git repository to STATUS console output
# Information included is: latest version (from git tag), branch, commit hash and the path to the repo
# Requires parameter:
# PATH_TO_GIT_REPO: the path to the repository (if its not a git repository it will fail)
function(printGitRepoInfo PATH_TO_GIT_REPO)
    if(GIT_FOUND)
        getVersionFromGitTag(${PATH_TO_GIT_REPO})
        getGitHash(${PATH_TO_GIT_REPO})
        getGitBranch(${PATH_TO_GIT_REPO})

        if(GIT_TAG_VERSION_FOUND)
            set(VERSION "${VERSION_COMBINED} (${COMMIT_NUMBER_AFTER_VERSION} commits on top)")
        else()
            set(VERSION "unknown")
        endif()

        if(GIT_BRANCH_FOUND)
            if("${GIT_BRANCH}" STREQUAL "")
                set(BRANCH "detached head")
            else()
                set(BRANCH ${GIT_BRANCH})
            endif()
        else()
            set(BRANCH "unknown")
        endif()

        if(COMMIT_HASH_FOUND)
            set(HASH ${COMMIT_HASH})
        else()
            set(HASH "unknown")
        endif()
        message(STATUS "Found Submodule: '${PATH_TO_GIT_REPO}' (version: ${VERSION}, branch: ${BRANCH}, hash: ${HASH})")
    endif()

endfunction()

# Prints repository info of all available submodules
function(printSubmoduleStates)
    if(GIT_FOUND)
        execute_process(COMMAND ${GIT_EXECUTABLE} submodule status
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                OUTPUT_VARIABLE SUBMODULES
                RESULT_VARIABLE RETURN_VALUE
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(RETURN_VALUE EQUAL "0" AND NOT ${SUBMODULES} STREQUAL "")
            # split at line breaks
            string(REGEX REPLACE "[\r\n]" ";" SUBMODULES_LINES ${SUBMODULES})
            # iterate
            foreach(LINE ${SUBMODULES_LINES})
                # split at spaces
                string(REPLACE " " ";" LINE_LIST ${LINE})
                list(GET LINE_LIST 2 PATH_ELEMENT)

                set(PATH_TO_SUBMODULE "${CMAKE_CURRENT_SOURCE_DIR}/${PATH_ELEMENT}")

                printGitRepoInfo(${PATH_TO_SUBMODULE})

            endforeach()
        endif()
    endif()
endfunction()