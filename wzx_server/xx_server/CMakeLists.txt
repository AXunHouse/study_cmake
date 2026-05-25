# demo/test_src/CMakeLists.txt

add_executable(xx_server main.cpp)

# -l
target_link_libraries(xx_server PRIVATE
    wu_log
    wu_math
)

#不用写 target_include_directorie, 因为 wu_log / wu_math 把 include 路径声明成了 PUBLIC，link 上来自动继承


set_target_properties(xx_server PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} #这里我也直接写回源码树
)