cmake_minimum_required(VERSION 3.16)

project(json_test
    LANGUAGES CXX
)

find_package(jsoncpp CONFIG REQUIRED)

add_executable(main main.cpp)

target_link_libraries(main PRIVATE JsonCpp::JsonCpp)

set_target_properties(main PROPERTIES
        EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin
)

#jsoncpp 的别名到底叫什么？
#1.9.x 之后官方生成 jsoncpp_lib（静态）和 jsoncpp_shared（动态）。
# 我们可以选择链接静态库或者动态库
#早期发行版可能只有 JsonCpp或带命名空间 JsonCpp::JsonCpp，从生成的配置文件代码可知：优先链接静态库
#查看生成的 jsoncppTargets-*.cmake 可以确认实际目标名称。