#app/CMakeLists.txt

#1. 收集库源代码
file(GLOB SRC_LIST "./*.cpp")

#2. 设置构建目标
add_executable(main ${SRC_LIST})

#3. 设置依赖库 -- -l
target_link_libraries(main PRIVATE WU_Myth)

#4. 设置输出路径
set_target_properties(main PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)


