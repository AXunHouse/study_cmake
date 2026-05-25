# wzx_base/wu_math/CMakeLists.txt

# 1. 收集源文件
file(GLOB WU_MATH_SRC_LIST CONFIGURE_DEPENDS
     "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
)

# 2. 添加构建目标 -- 静态库
add_library(wu_math STATIC ${WU_MATH_SRC_LIST})


#3. 设置目标的头文件搜索路径 -I
target_include_directories(wu_math PUBLIC
    #$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    "${CMAKE_CURRENT_SOURCE_DIR}/include" #不用生成器表达式, 写死即可, 因为不安装头文件
)

#4. 设置目标的其他属性
set_target_properties(wu_math PROPERTIES
    OUTPUT_NAME wu_math #磁盘上生成的文件名, libwu_math.a
    EXPORT_NAME wu_math #find_package 后的导入的目标名
    POSITION_INDEPENDENT_CODE ON 
    #build 静态库直接输出到源码目录的 同级lib/下
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib"
)

#5. 安装到同级lib目录下 -- 不安装, 在build时直接放进去
# install(TARGETS wu_math
#         ARCHIVE DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}/lib" #绝对路径 -- wzx_base/wu_math/lib
# )

# 不安装头文件, 不写各种配置文件, 我的头文件路径和库路径是众所周知的, 直接link即可