# A collection of helpers (functions) for cmake

## How to use?

### Fetch Content (CMake)

The easiest way to make the helpers available is to use Cmakes FetchContent. Note that instead of providing the commit 
hash one can also use the tag directly but tags might change and commit hashes do not.

```
include(FetchContent) # only necessary if not included already
FetchContent_Declare(cmake_helpers
        GIT_REPOSITORY https://github.com/truenicfel/cmakeHelpers
        GIT_TAG 3a93e28dfede98d438f797e95cf22c74743b55fb # v1.1.1
        )
FetchContent_MakeAvailable(cmake_helpers)
```

### Submodule

You can also include this repository as a submodule in your repository. And then call `add_subdirectory(...)`.

### Copy

You can also copy gitHelpers.cmake into any directory and then do the following:

```
list(APPEND CMAKE_MODULE_PATH [PATH_TO_THE_FILE_DIRECTORY])
include(gitHelpers)
```

## Modules

### Git Helpers

A collection of helpers for getting git branches, tags, version tags and commit hashes. To include use `include(gitHelpers)`.