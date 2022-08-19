# A collection of helpers (functions) for cmake

## How to use?

Simply add this repository as a git sumbodule to your project or simply copy the files to a directory. Afterwards do the following:
```
list(APPEND CMAKE_MODULE_PATH <path_to_cmake_helpers>)
include(<module>)
```

The `include(...)` command needs a name to a module contained in this repository.

## Modules

### Git Helpers

A collection of helpers for getting git branches, tags, version tags and commit hashes. To include use `include(gitHelpers)`.