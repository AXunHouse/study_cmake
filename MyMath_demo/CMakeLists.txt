#顶层CMakeLists.txt

#1. 限制最低版本
cmake_minimum_required(VERSION 3.16)

#2. 设置目标的名字
project(InstallMyMath
    LANGUAGES CXX  #最佳实践 -- 不调用C的编译器
)

#3. 调用子目录的CMakeLists.txt
add_subdirectory(./my_lib)