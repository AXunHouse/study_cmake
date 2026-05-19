#1. 
cmake_minimum_required(VERSION 3.16)

#2. 
project(TestWWW
    LANGUAGES CXX)

#3. 添加子目录到构建树，cmake会自动进入到源码树子目录，执行位于子目录里的CMakeLists.txt文件
add_subdirectory(src)

#4. 
add_executable(main main.cpp)

#5. 
target_link_libraries(main PRIVATE add)
#等价于 -- set_target_properties(main LINK_LIBRARIES add)