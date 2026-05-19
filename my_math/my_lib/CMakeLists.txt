#my_lib/CMakeLists.txt

#1. 收集库源代码
file(GLOB SRC_LIST "./src/*.cpp")

#2. 设置构建目标 -- 静态库
add_library(WU_Myth STATIC ${SRC_LIST})

#3. 设置库所需的头文件 -- -I
target_include_directories(WU_Myth PUBLIC ${CMAKE_CURRENT_LIST_DIR}/include)

#4. 设置默认输出路径 -- 编译后放在哪
set_target_properties(WU_Myth PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)