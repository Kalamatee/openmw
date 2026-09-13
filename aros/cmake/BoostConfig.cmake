# Boost CMake package config shim for the AROS Boost port, which installs
# the headers to <sysroot>/include/boost and the b2 built static libraries
# to <sysroot>/lib without any CMake package files.
if(TARGET Boost::headers)
    return()
endif()

set(Boost_INCLUDE_DIRS "${CMAKE_SYSROOT}/include")
set(Boost_INCLUDE_DIR "${Boost_INCLUDE_DIRS}")
set(Boost_LIBRARY_DIRS "${CMAKE_SYSROOT}/lib")
set(Boost_FOUND TRUE)
set(Boost_USE_STATIC_LIBS ON)

add_library(Boost::headers INTERFACE IMPORTED)
set_target_properties(Boost::headers PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Boost_INCLUDE_DIRS}")
add_library(Boost::boost ALIAS Boost::headers)

# Extra link libraries some components need (iostreams' compression filters).
set(_boost_iostreams_deps "${CMAKE_SYSROOT}/lib/libz.a;${CMAKE_SYSROOT}/lib/libbz2.a;${CMAKE_SYSROOT}/lib/liblzma.a;${CMAKE_SYSROOT}/lib/libzstd.a")

set(Boost_LIBRARIES)
foreach(_comp ${Boost_FIND_COMPONENTS})
    set(_lib "${CMAKE_SYSROOT}/lib/libboost_${_comp}.a")
    if(EXISTS "${_lib}")
        add_library(Boost::${_comp} STATIC IMPORTED)
        set_target_properties(Boost::${_comp} PROPERTIES
            IMPORTED_LOCATION "${_lib}"
            INTERFACE_INCLUDE_DIRECTORIES "${Boost_INCLUDE_DIRS}")
        if(_comp STREQUAL "iostreams")
            set_target_properties(Boost::${_comp} PROPERTIES
                INTERFACE_LINK_LIBRARIES "${_boost_iostreams_deps}")
        endif()
        set(Boost_${_comp}_FOUND TRUE)
        string(TOUPPER "${_comp}" _comp_uc)
        set(Boost_${_comp_uc}_LIBRARY "${_lib}")
        list(APPEND Boost_LIBRARIES Boost::${_comp})
    elseif(Boost_FIND_REQUIRED_${_comp})
        set(Boost_FOUND FALSE)
        set(Boost_NOT_FOUND_MESSAGE "Boost component ${_comp} not found (${_lib})")
    else()
        set(Boost_${_comp}_FOUND FALSE)
    endif()
endforeach()
