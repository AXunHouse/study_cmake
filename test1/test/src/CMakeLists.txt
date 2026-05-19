#1. 设置生成目标文件 -- 静态库
add_library(add STATIC add.cpp)

set_target_properties(add PROPERTIES
        #1. 编译类参数
        COMPILE_OPTIONS "-g"
        COMPILE_OPTIONS "-O3"
        COMPILE_OPTIONS "-fPIC"

        INCLUDE_DIRECTORIES "/wu/public_private"
        INTERFACE_INCLUDE_DIRECTORIES "/wu/interface"

        #2. 链接类参数
        LINK_DIRECTORIES "/zi/pub_pri"
        INTERFACE_LINK_DIRECTORIES "/zi/inter"

        LINK_LIBRARIES "xun/pub_pri"
        INTERFACE_LINK_LIBRARIES "xun/interface"


        #3. 输出类参数
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
        LIBRARY_OUTPUT_DIRECTORY  "${CMAKE_BINARY_DIR}/lib"

        #4. 安装类参数
        BUILD_RPATH "${CMAKE_BUILD_DIR}/lib"
        INSTALL_RPATH "${ORIGIN}/../lib"
        OUTPUT_NAME "wuadd"
        VERSION "1.22.3"
        SOVERSION "20"

)