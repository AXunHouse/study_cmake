file(REMOVE_RECURSE
  "../lib/libMyMath.a"
  "../lib/libMyMath.pdb"
)

# Per-language clean rules from dependency scanning.
foreach(lang CXX)
  include(CMakeFiles/MyMath_static.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
