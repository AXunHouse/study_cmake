#顶层CMakeLists.txt

#1. 设置最低版本号
cmake_minimum_required(VERSION 3.16)

#2. 设置项目名字
project(TestMyMath
    LANGUAGES CXX)

#3. 递归调用子目录的cml.txt
add_subdirectory(./my_lib)
add_subdirectory(./app)