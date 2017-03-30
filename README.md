# mulle-xcode-to-cmake

A little tool to convert [Xcode](https://developer.apple.com/xcode/) projects to [cmake](https://cmake.org/) CMakeLists.txt

You can specify the target to export. If you don't specify a target,  all targets are exported.
It doesn't do a perfect job, but it's better than doing it all by hand.
It can convert most targets, but it will do better with libraries and tools or
frameworks.


Fork      |  Build Status | Master Version
----------|---------------|-----------------------------------
[Mulle kybernetiK](//github.com/mulle-nat/mulle-xcode-to-cmake) | [![Build Status](https://travis-ci.org/mulle-nat/mulle-xcode-to-cmake.svg?branch=master)](https://travis-ci.org/mulle-nat/mulle-xcode-to-cmake) | ![Mulle kybernetiK tag](https://img.shields.io/github/tag/mulle-nat/mulle-xcode-to-cmake.svg) [![Build Status](https://travis-ci.org/mulle-nat/mulle-xcode-to-cmake.svg?branch=master)](https://travis-ci.org/mulle-nat/mulle-xcode-to-cmake)


## Install

Use the [homebrew](//brew.sh) package manager to install it, or build
it yourself with Xcode:

```
brew install mulle-kybernetik/software/mulle-xcode-to-cmake
```


## Usage

```
usage: mulle-xcode-to-cmake [options] <commands> <file.xcodeproj>

Options:
   -a          : always prefix cmake variables with target
   -b          : suppress boilerplate definitions
   -d          : create static and shared library
   -f          : suppress Foundation (implicitly added)
   -l <lang>   : specify language (c,c++,objc) for mulle-configuration (default: objc)
   -m          : include mulle-configuration (affects boilerplate)
   -n          : suppress find_library trace
   -p          : suppress project
   -r          : suppress reminder, what generated this file
   -s <suffix> : create standalone test library (framework/shared)
   -t <target> : target to export
   -u          : add UIKIt

Commands:
   export      : export CMakeLists.txt to stdout
   list        : list targets
   sexport     : export sources and private/public headers only

Environment:
   VERBOSE     : dump some info to stderr
```

### Examples

List all project targets:

```console
$ mulle-xcode-to-cmake list mulle-xcode-to-cmake.xcodeproj
mulle-xcode-to-cmake
mullepbx
```

Create "CMakeLists.txt" for target `mullepbx` leaving out some
boilerplate template code. Invoking `mulle-xcode-to-cmake -b export mulle-xcode-to-cmake.xcodeproj` yields:

```console
# Generated by mulle-xcode-to-cmake [2017-2-21 18:16:4]

project( mulle-xcode-to-cmake)

cmake_minimum_required (VERSION 3.4)


##
## mulle-xcode-to-cmake Files
##

set( MULLE_XCODE_TO_CMAKE_SOURCES
src/mulle-xcode-to-cmake/NSArray+Path.m
src/mulle-xcode-to-cmake/NSString+ExternalName.m
src/mulle-xcode-to-cmake/PBXHeadersBuildPhase+Export.m
src/mulle-xcode-to-cmake/PBXPathObject+HierarchyAndPaths.m
src/mulle-xcode-to-cmake/main.m
)

find_library( MULLEPBX_LIBRARY mullepbx)
message( STATUS "MULLEPBX_LIBRARY is ${MULLEPBX_LIBRARY}")

set( MULLE_XCODE_TO_CMAKE_STATIC_DEPENDENCIES
${MULLEPBX_LIBRARY}
)

find_library( FOUNDATION_LIBRARY Foundation)
message( STATUS "FOUNDATION_LIBRARY is ${FOUNDATION_LIBRARY}")

set( MULLE_XCODE_TO_CMAKE_DEPENDENCIES
${FOUNDATION_LIBRARY}
)


##
## mullepbx Files
##

set( MULLEPBX_PUBLIC_HEADERS
src/PBXReading/MullePBXUnarchiver.h
src/PBXReading/PBXObject.h
src/PBXWriting/MullePBXArchiver.h
src/PBXWriting/PBXObject+PBXEncoding.h
)

set( MULLEPBX_PROJECT_HEADERS
)

set( MULLEPBX_PRIVATE_HEADERS
src/PBXReading/NSObject+DecodeWithObjectStorage.h
src/PBXReading/NSString+KeyFromSetterSelector.h
src/PBXReading/NSString+LeadingDotExpansion.h
src/PBXReading/PBXProjectProxy.h
src/PBXWriting/MulleSortedKeyDictionary.h
)

set( MULLEPBX_SOURCES
src/PBXReading/MullePBXUnarchiver.m
src/PBXReading/NSObject+DecodeWithObjectStorage.m
src/PBXReading/NSString+KeyFromSetterSelector.m
src/PBXReading/NSString+LeadingDotExpansion.m
src/PBXReading/PBXObject.m
src/PBXReading/PBXProjectProxy.m
src/PBXWriting/MullePBXArchiver.m
src/PBXWriting/MulleSortedKeyDictionary.m
src/PBXWriting/PBXObject+PBXEncoding.m
)


##
## mulle-xcode-to-cmake
##

add_executable( mulle-xcode-to-cmake MACOSX_BUNDLE
${MULLE_XCODE_TO_CMAKE_SOURCES}
${MULLE_XCODE_TO_CMAKE_PUBLIC_HEADERS}
${MULLE_XCODE_TO_CMAKE_PROJECT_HEADERS}
${MULLE_XCODE_TO_CMAKE_PRIVATE_HEADERS}
${MULLE_XCODE_TO_CMAKE_RESOURCES}
)

target_include_directories( mulle-xcode-to-cmake
   PUBLIC
      src/PBXReading
      src/PBXWriting
)

add_dependencies( mulle-xcode-to-cmake mullepbx)

target_link_libraries( mulle-xcode-to-cmake
${MULLE_XCODE_TO_CMAKE_STATIC_DEPENDENCIES}
${MULLE_XCODE_TO_CMAKE_DEPENDENCIES}
)


##
## mullepbx
##

add_library( mullepbx STATIC
${MULLEPBX_SOURCES}
${MULLEPBX_PUBLIC_HEADERS}
${MULLEPBX_PROJECT_HEADERS}
${MULLEPBX_PRIVATE_HEADERS}
${MULLEPBX_RESOURCES}
)

target_include_directories( mullepbx
   PUBLIC
      src/PBXReading
      src/PBXWriting
)

install( TARGETS mullepbx DESTINATION "lib")
install( FILES ${MULLEPBX_PUBLIC_HEADERS} DESTINATION "include/mullepbx")
```

You have your own `CMakeLists.txt` template and just want to `include()`
the list of sources as they change in the Xcode project:

`mulle-xcode-to-cmake sexport mulle-xcode-to-cmake.xcodeproj` yields:

```console
##
## mulle-xcode-to-cmake Files
##

set( MULLE_XCODE_TO_CMAKE_SOURCES
src/mulle-xcode-to-cmake/NSArray+Path.m
src/mulle-xcode-to-cmake/NSString+ExternalName.m
src/mulle-xcode-to-cmake/PBXHeadersBuildPhase+Export.m
src/mulle-xcode-to-cmake/PBXPathObject+HierarchyAndPaths.m
src/mulle-xcode-to-cmake/main.m
)


##
## mullepbx Files
##

set( MULLEPBX_PUBLIC_HEADERS
src/PBXReading/MullePBXUnarchiver.h
src/PBXReading/PBXObject.h
src/PBXWriting/MullePBXArchiver.h
src/PBXWriting/PBXObject+PBXEncoding.h
)

set( MULLEPBX_SOURCES
src/PBXReading/MullePBXUnarchiver.m
src/PBXReading/NSObject+DecodeWithObjectStorage.m
src/PBXReading/NSString+KeyFromSetterSelector.m
src/PBXReading/NSString+LeadingDotExpansion.m
src/PBXReading/PBXObject.m
src/PBXReading/PBXProjectProxy.m
src/PBXWriting/MullePBXArchiver.m
src/PBXWriting/MulleSortedKeyDictionary.m
src/PBXWriting/PBXObject+PBXEncoding.m
)
```

### History

This is basically a stripped down version of `mulle_xcode_utility`.


### Releasenotes

##### 0.5.2

* add sexport command for generating source and header file lists
* added -l switch, also for mulle-objc to specify the project language
* fix a bug, when files are not group relative in Xcode

##### 0.4.1

* add a reminder how this file was generated. Actually useful sometimes.

##### 0.4.0

* whitespace in target names is converted to '-'
* bundle targets are supported now
* added -n flag
* fix framework resource copy stage


##### 0.3.0

* don't emit link commands for static library targets
* add -s option
* slight reorganization of code
* output filepaths sorted
* fix some bugs
* improved boiler-plate code


##### 0.2.0

* output resources too
* allow to specify multiple targets
* fix more bugs
* add -u option, but iOS builds don't work anway
* somewhat half hearted attempt to also support applications and bundles
* quote paths with whitespace

##### 0.1.0

* Fix some bugs. Add -p and -f options.


#### 0.0

* Quickly hacked together from mulle-xcode-settings.



### Author

Coded by Nat!
