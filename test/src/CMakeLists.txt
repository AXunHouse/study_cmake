#1. 设置生成目标文件 -- 静态库
add_library(add STATIC add.cpp)

#2. 设置头文件搜索路径 -I
target_include_directories(add PRIVATE "/wuwuwu/include/private")
target_include_directories(add PUBLIC "/zizizi/include/public")
target_include_directories(add INTERFACE "/xunxunxun/include/interface")

#3. 设置库文件搜索路径 -L
target_link_directories(add PRIVATE "/wuwuwu/lib/private")
target_link_directories(add PUBLIC "/wuwuwu/lib/public")
target_link_directories(add INTERFACE "/wuwuwu/lib/interface")

#4. 设置库文件依赖列表 -l
target_link_libraries(add INTERFACE "pthread")