# SDL2 CMake package config shim for the AROS SDL2 port, which installs
# only libSDL2.a, the SDL2/ headers and sdl2-config.  Recreates what
# find_package(SDL2 CONFIG) consumers expect.
if(TARGET SDL2::SDL2)
    return()
endif()

set(SDL2_INCLUDE_DIRS "${CMAKE_SYSROOT}/include/SDL2")
set(SDL2_INCLUDE_DIR "${SDL2_INCLUDE_DIRS}")
set(SDL2_LIBRARIES "${CMAKE_SYSROOT}/lib/libSDL2.a")
set(SDL2_LIBRARY "${SDL2_LIBRARIES}")
set(SDL2MAIN_LIBRARY "")
set(SDL2_FOUND TRUE)

add_library(SDL2::SDL2 STATIC IMPORTED)
set_target_properties(SDL2::SDL2 PROPERTIES
    IMPORTED_LOCATION "${SDL2_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${SDL2_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${CMAKE_SYSROOT}/lib/libGL.a")
add_library(SDL2::SDL2-static ALIAS SDL2::SDL2)
add_library(SDL2::SDL2main INTERFACE IMPORTED)
