cmake_minimum_required(VERSION 3.16)

project(Test2
        LANGUAGES CXX
)

add_executable(main main.cpp)

set_target_properties(main PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

find_package(MyMath REQUIRED CONFIG)

#target_link_libraries(main PRIVATE MyMath::MyMath)
target_link_libraries(main PRIVATE MyMath::MyMath-static)
