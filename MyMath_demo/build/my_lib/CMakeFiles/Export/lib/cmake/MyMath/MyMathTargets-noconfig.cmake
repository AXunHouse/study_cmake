#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "MyMath::MyMath_static" for configuration ""
set_property(TARGET MyMath::MyMath_static APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(MyMath::MyMath_static PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "CXX"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libMyMath.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS MyMath::MyMath_static )
list(APPEND _IMPORT_CHECK_FILES_FOR_MyMath::MyMath_static "${_IMPORT_PREFIX}/lib/libMyMath.a" )

# Import target "MyMath::MyMath_shared" for configuration ""
set_property(TARGET MyMath::MyMath_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(MyMath::MyMath_shared PROPERTIES
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libMyMath.so.35"
  IMPORTED_SONAME_NOCONFIG "libMyMath.so.35"
  )

list(APPEND _IMPORT_CHECK_TARGETS MyMath::MyMath_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_MyMath::MyMath_shared "${_IMPORT_PREFIX}/lib/libMyMath.so.35" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
