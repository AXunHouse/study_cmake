file(REMOVE_RECURSE
  "../lib/libMyMath.pdb"
  "../lib/libMyMath.so"
  "../lib/libMyMath.so.5"
  "../lib/libMyMath.so.5.5.5"
)

# Per-language clean rules from dependency scanning.
foreach(lang CXX)
  include(CMakeFiles/MyMath_shared.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
