# 顶层 wzx_server/CMakeLists.txt

cmake_minimum_required(VERSION 3.16)

project(wzx--server 
        LANGUAGES CXX
)

set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_CLEAN_FILES
    "${CMAKE_SOURCE_DIR}/wzx_base/wu_log/lib"
    "${CMAKE_SOURCE_DIR}/wzx_base/wu_math/lib"
)
# 这样 cmake --build build --target clean 会一起删掉。

add_subdirectory(wzx_base)
add_subdirectory(xx_server)