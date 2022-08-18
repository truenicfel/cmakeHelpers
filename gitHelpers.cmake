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
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(RETURN_VALUE EQUAL "0")
            set(RESULT_TAG "${TAG}")
            set(RESULT_FOUND True)
        endif()
    endif()
    set(GIT_TAG "${RESULT_TAG}" PARENT_SCOPE)
    set(GIT_TAG_FOUND ${RESULT_FOUND} PARENT_SCOPE)
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
                list(GET LINE_LIST 1 HASH)
                list(GET LINE_LIST 2 PATH_ELEMENT)
                list(GET LINE_LIST 3 DESCRIBE)

                set(PATH_TO_SUBMODULE "${CMAKE_CURRENT_SOURCE_DIR}/${PATH_ELEMENT}")

                string(REPLACE "/" ";" PATH_LIST ${PATH_ELEMENT})
                list(LENGTH PATH_LIST LENGTH_PATH_LIST)
                math(EXPR INDEX_LAST "${LENGTH_PATH_LIST} - 1")
                list(GET PATH_LIST ${INDEX_LAST} SUBMODULE_NAME)
                # a print should look like this:
                # Submodule '<name>' in directory '<path>' on tag '<tag>'
                # or:
                # Submodule '<name>' in directory '<path>' on branch '<branch>' at '<hash>'
                getGitTag(${PATH_TO_SUBMODULE})
                if (GIT_TAG_FOUND)
                    message(STATUS "Submodule '${SUBMODULE_NAME}' in directory '${PATH_TO_SUBMODULE}' on tag '${GIT_TAG}'")
                else()
                    getGitBranch(${PATH_TO_SUBMODULE})
                    if (GIT_BRANCH_FOUND)
                        message(STATUS "Submodule '${SUBMODULE_NAME}' in directory '${PATH_TO_SUBMODULE}' on branch '${GIT_BRANCH}' at '${HASH}'")
                    else()
                        message(STATUS "Submodule '${SUBMODULE_NAME}' in directory '${PATH_TO_SUBMODULE}' on '${DESCRIBE}' at '${HASH}'")
                    endif ()
                endif ()
            endforeach()
        endif()
    endif()
endfunction()