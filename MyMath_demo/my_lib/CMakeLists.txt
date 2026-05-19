#my_lib/CMakeLists.txt

#1. 收集源代码 (GLOB -- 不递归子目录)
file(GLOB SRC_LIST "./src/*.cpp")



#2. 添加构建目标(静态库和动态库)
add_library(MyMath_static STATIC ${SRC_LIST})
add_library(MyMath_shared SHARED ${SRC_LIST})



#3. 设置库的头文件搜索路径 -I (实则是设计使用要求)
target_include_directories(MyMath_static INTERFACE 
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_include_directories(MyMath_shared INTERFACE
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)



#4. 设置库的默认输出路径 -- 编译后在构建树中的位置
set_target_properties(MyMath_static MyMath_shared PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib 
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib 
)



#>  统一输出名字: 静态库会生成 libMyMath.a，动态库会生成 libMyMath.so
set_target_properties(MyMath_static PROPERTIES
        OUTPUT_NAME MyMath
)
set_target_properties(MyMath_shared PROPERTIES
        OUTPUT_NAME MyMath
        VerSION 1.5.5 #我这里随便写的
        SOVERSION 35 #我这里随便写的
        COMPILE_OPTIONS "-fPIC"
)



#5. 安装静态库和动态库
include(GNUInstallDirs) #引入模块，定义了一系列标准安装目录变量
install(TARGETS MyMath_static MyMath_shared #安装目标
        EXPORT MyMathTargets #[标记]当前目标属于导出集MathTargets。
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} #Windows DLL
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} #Linux .so / macOS .dylib
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} #静态库 .a / Windows .lib
)



#6. 安装头文件
install(DIRECTORY ./include/ #安装一个目录, 目录中包含include/下的所有东西, 注意末尾的 / 表示复制文件夹内的内容，而不是文件夹本身
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/MyMathInclude #安装到 /usr/local/include/MyMathInclude/ 下
        FILES_MATCHING PATTERN "*.h" #只复制 .h 头文件，忽略其他文件
)



#7. 导出"导出集合"到构建树 -- 用于不安装直接内部使用
#export() 生成的文件不会被安装到系统，只是留在构建目录中供临时使用, 即可以实现不install, 直接使用构建树中的库, 开发阶段很方便
export(EXPORT MyMathTargets #将导出集MyMathTargets生成为一个.cmake文件
        FILE ${CMAKE_CURRENT_BINARY_DIR}/MyMathTargets.cmake #生成一个.cmake文件放在当前构建目录下
)
#用途：你可以直接在另一个项目里 include() 这个文件，然后链接 MyMath::MyMath。
#但这只能用在开发阶段（两个项目共享同一个构建树或你手动指定路径），不便于发布



#8. 安装"导出集合"到安装树 -- 用于安装供外部使用
install(EXPORT MyMathTargets #安装一个导出集MyMathTargets
        FILE MyMathTargets.cmake #生成这个文件在一个临时位置, 之后复制到DESTAINATION中
        NAMESPACE MyMath:: #给导出集中的所有文件(目标, 其他配置文件)都加上命名空间前缀, 在其他外部项目链接时, 需要加上命名前缀, 避免冲突, eg: arget_link_libraries(... MyMath::MyMath)
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyMath #安装(复制)到 /usr/local/lib/cmake/MyMath/ 目录下
)
#用途: 任何外部项目只要知道这个文件的位置，就可以 include() 它来使用你的库。
#但 find_package(MyMath) 仍然不能直接找到它，
#因为 find_package 默认寻找的是 MyMathConfig.cmake 或 mymath-config.cmake，而不是 MyMathTargets.cmake

#第7-8步生成的是“目标描述文件”（MyMathTargets.cmake），它只告诉 CMake 库的二进制文件和头文件在哪；
#而第9-10步生成的是“包入口文件”（MyMathConfig.cmake），它负责版本检查、依赖处理，并引入目标描述文件。
#两者配合才能被 find_package 正确使用。



#9. 生成包配置文件(MyMathConfig.cmake)在构建树
include(CMakePackageConfigHelpers) #引入辅助模块，提供了 configure_package_config_file 和 write_basic_package_version_file 等函数。
configure_package_config_file( #读取一个模板文件（Config.cmake.in），替换其中的变量，生成最终的 MyMathConfig.cmake。
        ${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in #模板文件路径（需要开发者自己编写，通常放在项目根目录）
        ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfig.cmake #生成的配置文件路径（放在构建目录中)
        INSTALL_DESTINATION "lib/cmake/MyMath"
)
#作用：生成一个标准的 CMake 配置文件。
#这个文件通常会 include(MyMathTargets.cmake)，并提供版本信息、依赖检查等。
#这样 find_package(MyMath) 就能正常工作。
#configure_package_config_file 命令必须提供 INSTALL_DESTINATION 参数，
#这个参数指定了生成的 MyMathConfig.cmake 将来会被安装到哪个相对路径（相对于 CMAKE_INSTALL_PREFIX）。
#CMake 需要这个信息来正确处理宏 @PACKAGE_INIT@ 中的路径转换。
#注意：INSTALL_DESTINATION 的值应该和后续 install(FILES ... DESTINATION ...) 中的 DESTINATION 保持一致。



#10. 安装包配置文件(MyMathConfig.cmake)到安装树
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfig.cmake #安装这个文件
        DESTINATION "lib/cmake/MyMath" #安装到这里 -- 相对路径（不以 / 开头）
)
#DESTINATION 乍一看像一个相对路径，容易让人误以为它是相对于当前构建目录的。
#但实际上，install() 命令中的 DESTINATION 是相对于 CMAKE_INSTALL_PREFIX 的安装前缀，而不是相对于构建目录（CMAKE_CURRENT_BINARY_DIR）。
#默认值：在 Linux/macOS 上，CMAKE_INSTALL_PREFIX 默认是 /usr/local。在 Windows 上，默认是 C:/Program Files/${PROJECT_NAME}。
#含义：所有 install() 命令中的 DESTINATION 路径都会拼接到这个前缀后面，形成最终的绝对安装路径。




























# #my_lib/CMakeLists.txt

# #1. 收集源代码 (GLOB -- 不递归子目录)
# file(GLOB SRC_LIST "./src/*.cpp")



# #2. 添加构建目标(静态库)
# add_library(MyMath STATIC ${SRC_LIST})



# #3. 设置库的头文件搜索路径 -I (实则是设计使用要求)
# #INTERFACE 关键字：表示这个路径只传递给链接了这个库的目标（下游使用者），而MyMath的源文件编译的时候不需要链接这个头文件
# target_include_directories(MyMath INTERFACE #这里是对使用者的要求, 即我这个库生成时不需要, 但你下游消费者在链接使用我这个库的时候必须要包含头文件
#         "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"#告诉下游使用者：“你需要在我的安装目录下的 include 文件夹里找头文件”
# )
# #这里使用生成器表达式的原因是：同一个库，在“开发阶段（构建树中）”和“安装后（系统目录）”时，头文件的搜索路径是不同的。生成器表达式可以根据上下文自动选择正确的路径。
# #这里没有写 BUILD_INTERFACE：意味着在构建树中使用时，不会添加任何头文件路径。这是因为你的库在构建时可能根本不需要额外的头文件路径（所有头文件已经通过 PRIVATE 或 PUBLIC 方式添加过了），或者你认为使用者应该自己处理构建时的路径。
# #但更常见的做法是同时提供两个表达式：
# # target_include_directories(MyMath INTERFACE
# #     "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>" #在构建树中，其他目标（比如同项目的测试程序）能直接从 ./include 找到头文件。
# #     "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>" #当 MyMath 被安装后，其他项目通过 find_package 使用
# # )



# #4. 设置库的默认输出路径 -- 编译后在构建树中的位置
# #把生成的 libMyMath.a 文件放到 build/lib/ 下，而不是默认的 build/my_lib/ 或其他位置，这样所有库文件都集中在 lib/ 中，方便管理和后续打包。
# set_target_properties(MyMath PROPERTIES
#         ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib #顶层构建目录下的lib目录
# )



# #5. 安装静态库
# include(GNUInstallDirs) #引入模块，定义了一系列标准安装目录变量
# install(TARGETS MyMath #安装一个目标
#         EXPORT MyMathTargets #[标记]当前目标MyMath 属于导出集MathTargets, 告诉 CMake “将来我要导出 MyMathTargets 这个集合，里面包含 MyMath 这个目标”。
#         DESTINATION ${CMAKE_INSTALL_LIBDIR} #将目标MyMath安装到该目录下(/usr/local/lib)
# )



# #6. 安装头文件
# install(DIRECTORY ./include/ #安装一个目录, 目录中包含include/下的所有东西, 注意末尾的 / 表示复制文件夹内的内容，而不是文件夹本身
#         DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/MyMathInclude #安装到 /usr/local/include/MyMathInclude/ 下
#         FILES_MATCHING PATTERN "*.h" #只复制 .h 头文件，忽略其他文件
# )



# #7. 导出"导出集合"到构建树 -- 用于不安装直接内部使用
# #export() 生成的文件不会被安装到系统，只是留在构建目录中供临时使用, 即可以实现不install, 直接使用构建树中的库, 开发阶段很方便
# export(EXPORT MyMathTargets #将导出集MyMathTargets生成为一个.cmake文件
#         FILE ${CMAKE_CURRENT_BINARY_DIR}/MyMathTargets.cmake #生成一个.cmake文件放在当前构建目录下
# )
# #用途：你可以直接在另一个项目里 include() 这个文件，然后链接 MyMath::MyMath。
# #但这只能用在开发阶段（两个项目共享同一个构建树或你手动指定路径），不便于发布



# #8. 安装"导出集合"到安装树 -- 用于安装供外部使用
# install(EXPORT MyMathTargets #安装一个导出集MyMathTargets
#         FILE MyMathTargets.cmake #生成这个文件在一个临时位置, 之后复制到DESTAINATION中
#         NAMESPACE MyMath:: #给导出集中的所有文件(目标, 其他配置文件)都加上命名空间前缀, 在其他外部项目链接时, 需要加上命名前缀, 避免冲突, eg: arget_link_libraries(... MyMath::MyMath)
#         DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyMath #安装(复制)到 /usr/local/lib/cmake/MyMath/ 目录下
# )
# #用途: 任何外部项目只要知道这个文件的位置，就可以 include() 它来使用你的库。
# #但 find_package(MyMath) 仍然不能直接找到它，
# #因为 find_package 默认寻找的是 MyMathConfig.cmake 或 mymath-config.cmake，而不是 MyMathTargets.cmake

# #第7-8步生成的是“目标描述文件”（MyMathTargets.cmake），它只告诉 CMake 库的二进制文件和头文件在哪；
# #而第9-10步生成的是“包入口文件”（MyMathConfig.cmake），它负责版本检查、依赖处理，并引入目标描述文件。
# #两者配合才能被 find_package 正确使用。



# #9. 生成包配置文件(MyMathConfig.cmake)在构建树
# include(CMakePackageConfigHelpers) #引入辅助模块，提供了 configure_package_config_file 和 write_basic_package_version_file 等函数。
# configure_package_config_file( #读取一个模板文件（Config.cmake.in），替换其中的变量，生成最终的 MyMathConfig.cmake。
#         ${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in #模板文件路径（需要开发者自己编写，通常放在项目根目录）
#         ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfig.cmake #生成的配置文件路径（放在构建目录中)
#         INSTALL_DESTINATION "lib/cmake/MyMath"
# )
# #作用：生成一个标准的 CMake 配置文件。
# #这个文件通常会 include(MyMathTargets.cmake)，并提供版本信息、依赖检查等。
# #这样 find_package(MyMath) 就能正常工作。
# #configure_package_config_file 命令必须提供 INSTALL_DESTINATION 参数，
# #这个参数指定了生成的 MyMathConfig.cmake 将来会被安装到哪个相对路径（相对于 CMAKE_INSTALL_PREFIX）。
# #CMake 需要这个信息来正确处理宏 @PACKAGE_INIT@ 中的路径转换。
# #注意：INSTALL_DESTINATION 的值应该和后续 install(FILES ... DESTINATION ...) 中的 DESTINATION 保持一致。



# #10. 安装包配置文件(MyMathConfig.cmake)到安装树
# install(FILES ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfig.cmake #安装这个文件
#         DESTINATION "lib/cmake/MyMath" #安装到这里 -- 相对路径（不以 / 开头）
# )
# #DESTINATION 乍一看像一个相对路径，容易让人误以为它是相对于当前构建目录的。
# #但实际上，install() 命令中的 DESTINATION 是相对于 CMAKE_INSTALL_PREFIX 的安装前缀，而不是相对于构建目录（CMAKE_CURRENT_BINARY_DIR）。
# #默认值：在 Linux/macOS 上，CMAKE_INSTALL_PREFIX 默认是 /usr/local。在 Windows 上，默认是 C:/Program Files/${PROJECT_NAME}。
# #含义：所有 install() 命令中的 DESTINATION 路径都会拼接到这个前缀后面，形成最终的绝对安装路径。