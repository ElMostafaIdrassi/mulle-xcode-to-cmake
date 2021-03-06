# Generated on 2017-10-4 13:33:17 by version 0.6.5 of mulle-xcode-to-cmake
# Command line:
#    mulle-xcode-to-cmake -2 export mulle-xcode-to-cmake.xcodeproj

project( mulle-xcode-to-cmake)

cmake_minimum_required (VERSION 3.4)

#
# mulle-bootstrap environment
#

# check if compiling with mulle-bootstrap (works since 2.6)

if( NOT MULLE_BOOTSTRAP_VERSION)
  include_directories( BEFORE SYSTEM
dependencies/include
addictions/include
)

  set( CMAKE_FRAMEWORK_PATH
dependencies/Frameworks
addictions/Frameworks
${CMAKE_FRAMEWORK_PATH}
)

  set( CMAKE_LIBRARY_PATH
dependencies/lib
addictions/lib
${CMAKE_LIBRARY_PATH}
)

set( DEPENDENCIES_DIR dependencies)
set( ADDICTIONS_DIR addictions)

endif()


#
# Platform specific definitions
#

if( APPLE)
   # # CMAKE_OSX_SYSROOT must be set for CMAKE_OSX_DEPLOYMENT_TARGET (cmake bug)
   # if( NOT CMAKE_OSX_SYSROOT)
   #    set( CMAKE_OSX_SYSROOT "/" CACHE STRING "SDK for OSX" FORCE)   # means current OS X
   # endif()
   #
   # # baseline set to 10.6 for rpath
   # if( NOT CMAKE_OSX_DEPLOYMENT_TARGET)
   #   set(CMAKE_OSX_DEPLOYMENT_TARGET "10.6" CACHE STRING "Deployment target for OSX" FORCE)
   # endif()

   set( CMAKE_POSITION_INDEPENDENT_CODE FALSE)

   set( BEGIN_ALL_LOAD "-all_load")
   set( END_ALL_LOAD)
else()
   set( CMAKE_POSITION_INDEPENDENT_CODE TRUE)

   if( WIN32)
   # windows
   else()
   # linux / gcc
      set( BEGIN_ALL_LOAD "-Wl,--whole-archive")
      set( END_ALL_LOAD "-Wl,--no-whole-archive")
   endif()
endif()

##
## Produce CMakeSourcesAndHeaders.txt with:
##   mulle-xcode-to-cmake -t 'mulle-xcode-to-cmake' -t 'mullepbx' sexport > CMakeSourcesAndHeaders.txt
##

include( CMakeSourcesAndHeaders.txt)

# uncomment this for mulle-objc to search libraries first
# set( CMAKE_FIND_FRAMEWORK "LAST")

set( MULLEPBX_LIBRARY mullepbx)
message( STATUS "MULLEPBX_LIBRARY is ${MULLEPBX_LIBRARY}")

set( MULLE_XCODE_TO_CMAKE_STATIC_DEPENDENCIES
${MULLEPBX_LIBRARY}
)

if(APPLE)
    find_library( FOUNDATION_LIBRARY Foundation)
    message( STATUS "FOUNDATION_LIBRARY is ${FOUNDATION_LIBRARY}")
else()

	# Without this, execute_process() does not work under GNUstep shell on Windows
	# =>  	objc_def_flags and objc_def_link_flags are empty 
	# =>	RESULT_VARIABLE contains "%1 is not a valid win32 app"
	if(WIN32)
		set(EXECUTE_PROCESS_PRECOMMAND "sh")
	endif()

    find_program(GNUstepConfig "gnustep-config")
    if(GNUstepConfig)
        message(STATUS "Using GNUstep (${GNUstepConfig})")
        execute_process(COMMAND ${EXECUTE_PROCESS_PRECOMMAND} "${GNUstepConfig}" "--objc-flags"
            OUTPUT_VARIABLE objc_def_flags
            OUTPUT_STRIP_TRAILING_WHITESPACE)
        execute_process(COMMAND ${EXECUTE_PROCESS_PRECOMMAND} "${GNUstepConfig}" "--base-libs"
            OUTPUT_VARIABLE objc_def_link_flags
            OUTPUT_STRIP_TRAILING_WHITESPACE)
        set(objc_flags      "${objc_def_flags}")
        set(objc_link_flags "${objc_def_link_flags}")
    else()
        find_library( OBJC_LIBRARY NAMES "objc2" "objc")
        find_library( FOUNDATION_LIBRARY gnustep-base)
        find_path( FOUNDATION_HEADERS NAMES "Foundation/Foundation.h" HINTS
            ${CMAKE_PREFIX_PATH}/include/GNUstep
            /usr/include/GNUstep)
        include_directories(${FOUNDATION_HEADERS})
        message( STATUS "FOUNDATION_LIBRARY is ${FOUNDATION_LIBRARY}")
        message( STATUS "FOUNDATION_HEADERS at ${FOUNDATION_HEADERS}")
    endif()
endif()

set( MULLE_XCODE_TO_CMAKE_DEPENDENCIES
${FOUNDATION_LIBRARY}
)

# uncomment this for mulle-objc to search libraries first
# set( CMAKE_FIND_FRAMEWORK "LAST")


##
## mulle-xcode-to-cmake
##

add_executable( mulle-xcode-to-cmake
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
${BEGIN_ALL_LOAD}
${MULLE_XCODE_TO_CMAKE_STATIC_DEPENDENCIES}
${END_ALL_LOAD}
${MULLE_XCODE_TO_CMAKE_DEPENDENCIES}
)
if(GNUstepConfig)
    set_target_properties( mulle-xcode-to-cmake PROPERTIES
        LANGUAGE C COMPILE_FLAGS "${objc_flags}"
        LINK_FLAGS "${objc_link_flags}")
elseif(NOT APPLE)
	target_link_libraries( mulle-xcode-to-cmake ${OBJC_LIBRARY})
endif()


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
if(GNUstepConfig)
    set_target_properties( mullepbx PROPERTIES
        LANGUAGE C COMPILE_FLAGS "${objc_flags}"
        LINK_FLAGS "${objc_link_flags}")
endif()

install( TARGETS mullepbx DESTINATION "lib")
install( FILES ${MULLEPBX_PUBLIC_HEADERS} DESTINATION "include/mullepbx")

install( TARGETS mulle-xcode-to-cmake DESTINATION "bin")
