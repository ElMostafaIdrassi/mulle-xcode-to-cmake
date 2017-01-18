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
	-p          : suppress project
	-s <suffix> : create standalone test library (framework/shared)
	-t <target> : target to export
	-u          : add UIKIt

Commands:
	export      : export CMakeLists.txt to stdout
	list        : list targets

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
boilerplate template code:

```console
project( mullepbx)

cmake_minimum_required (VERSION 3.4)


##
## mullepbx Files
##

set( PUBLIC_HEADERS
src/PBXReading/MullePBXUnarchiver.h
src/PBXReading/PBXObject.h
src/PBXWriting/MullePBXArchiver.h
src/PBXWriting/PBXObject+PBXEncoding.h
)

set( PROJECT_HEADERS
)

set( PRIVATE_HEADERS
src/PBXReading/NSObject+DecodeWithObjectStorage.h
src/PBXReading/NSString+KeyFromSetterSelector.h
src/PBXReading/NSString+LeadingDotExpansion.h
src/PBXReading/PBXProjectProxy.h
src/PBXWriting/MulleSortedKeyDictionary.h
)

set( SOURCES
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
## mullepbx
##

add_library( mullepbx STATIC
${SOURCES}
${PUBLIC_HEADERS}
${PROJECT_HEADERS}
${PRIVATE_HEADERS}
)

target_include_directories( mullepbx
   PUBLIC
      src/PBXReading
      src/PBXWriting
)
```


### History

This is basically a stripped down version of `mulle_xcode_utility`.


### Releasenotes

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
