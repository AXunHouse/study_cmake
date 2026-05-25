#my_lib/CMakeLists.txt
# ========================================================================================================================
# MyMath 库 - 静态库 + 动态库 双产物版本
# ========================================================================================================================


# ---- 1. 引入标准模板 ----
include(GNUInstallDirs) # 定义了一系列标准安装目录变量, eg: CMAKE_INSTALL_INCLUDEDIR
include(CMakePackageConfigHelpers) # 提供了一系列配置函数, eg: configure_package_config_file 和 write_basic_package_version_file
# 之前写在了下面, 这里调用了但是没出错的原因: 
# 这里用了生成器表达式 $<INSTALL_INTERFACE:...>，它的展开延迟到生成阶段。到了那时 GNUInstallDirs 已经被 include 了，所以变量有值, 大BUG


# ========================================================================================================================
# 构建产物
# ========================================================================================================================


# ---- 2. 收集源代码 (GLOB -- 不递归子目录) ---- 
file(GLOB SRC_LIST CONFIGURE_DEPENDS "./src/*.cpp") # CONFIGURE_DEPENDS: 每次构建时都重新扫描


# ---- 3. 添加构建目标 OBJECT 库 ---- 
# add_library(MyMath_static STATIC ${SRC_LIST}) # 直接这么写: 每个 .cpp 文件被编译两次（一次给静态库，一次给动态库），构建时间翻倍。
# add_library(MyMath_shared SHARED ${SRC_LIST})
add_library(MyMath_obj OBJECT ${SRC_LIST}) # OBJECT库, 即.o文件的汇总, 类似于g++ -c

set_target_properties(MyMath_obj PROPERTIES
        POSITION_INDEPENDENT_CODE ON # OBJECT库的.o 必须开fPIC, 因为你后面要打包成动态库
)       

target_include_directories(MyMath_obj PRIVATE  # OBJECT库既不传播也不需要, 后面也不继承, 所以直接PRIVATE即可
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)  
# 注意:MyMath_obj 不参与 install/EXPORT, 因为我只是用 $<TARGET_OBJECTS:...> 拿 .o,
# 不是用 target_link_libraries 链接它。下游永远只看到 shared/static,不会引用 obj   

add_library(MyMath_shared SHARED $<TARGET_OBJECTS:MyMath_obj>) #把 .o 们打包成 .so
add_library(MyMath_static STATIC $<TARGET_OBJECTS:MyMath_obj>) #把 .o 们打包成 .a
# !!![注意]: 这里的$<TARGET_OBJECTS:...> 只拿 .o 文件,不继承属性。
# 两种解决方案: 
#  A. 手动给 MyMath_shared MyMath_static两个目标 再设一遍属性 -- 我这里的方案
#  B. 用 target_link_libraries(MyMath_shared PUBLIC MyMath_obj) 真正"链接"OBJECT库, 这样属性会传播(CMake 3.12+)


# ---- 4. 设置库的头文件搜索路径 -I (实则是设计使用要求) ---- 
foreach(tgt MyMath_shared MyMath_static)
        target_include_directories(${tgt} INTERFACE
                "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
                "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
        ) 
endforeach()




# ---- 5. 设置两个目标的属性 ---- 
# ---- 5.1. 两个目标的公共属性 ---- 
set_target_properties(MyMath_shared MyMath_static PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib 
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib 
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# ---- 5.2. 动态库的独有属性 ---- 
set_target_properties(MyMath_shared PROPERTIES
        OUTPUT_NAME MyMath #磁盘上生成的文件名, libMyMath.so
        EXPORT_NAME MyMath #find_package 后的导入的目标名, [主名指向动态库策略]
        VERSION ${PROJECT_VERSION} # 5.5.5 -- 动态库的版本号
        SOVERSION ${PROJECT_VERSION_MAJOR} # 5 -- 动态库的主版本号
        # COMPILE_OPTIONS "-fPIC" -- 不推荐: -fPIC 是 GCC 特有的——不跨平台(Windows上没有这个概念), 而且SHARED库默认就开PIC, 多余了
)

# ---- 5.3. 静态库的独有属性 ---- 
set_target_properties(MyMath_static PROPERTIES
        OUTPUT_NAME MyMath #磁盘上生成的文件名, libMyMath.a
        EXPORT_NAME MyMath-static #find_package 后的导入的目标名
        POSITION_INDEPENDENT_CODE ON   # 正确做法: 给该变量设为ON, 而且给静态库也设PIC
        # 如果别人想把你的 libMyMath.a 链接进他的 .so，那么 .a 里的代码必须是 PIC 的。所以默认开 PIC 是友好的
)

# ---- 5.4. 给两个库加上别名 ---- 
# 加上后, 内部人员 和 下游外部人员 find_package 后的写法完全一致(MyMath::MyMath) -- [构建树和安装树的统一接口]
add_library(MyMath::MyMath ALIAS MyMath_shared)
add_library(MyMath::MyMath-static ALIAS MyMath_static)



# ========================================================================================================================
# 安装规则
# ========================================================================================================================


# ---- 6. 安装动态库 和 静态库 ---- 
install(TARGETS MyMath_static MyMath_shared #安装目标
        EXPORT MyMathTargets #[标记]当前目标属于[导出集合MathTargets] -- 它不是文件, 是 CMake内部的一个"逻辑分组"
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} #Windows DLL
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} #Linux .so / macOS .dylib
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} #静态库 .a / Windows .lib
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}  #在导出文件里记录头文件路径, 和第4步的意义一样, 冗余写增加鲁棒性
)


# ---- 7. 安装头文件 ----
install(DIRECTORY ./include/ #安装一个目录, 目录中包含include/下的所有东西, 注意末尾的 / 表示复制文件夹内的内容，而不是文件夹本身
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/MyMathInclude #安装到 /usr/local/include/MyMathInclude/ 下
        FILES_MATCHING PATTERN "*.h" #只复制 .h 头文件，忽略其他文件
)


# ---- 8. 生成一份Targets.cmake放在构建树(用于: 不安装, 供内部人员使用) ---- 
# !!![理解]: MyMathTargets.cmake —— 由导出集合"打印"出来的实体文件
export(EXPORT MyMathTargets
       FILE ${CMAKE_CURRENT_BINARY_DIR}/MyMathTargets.cmake #生成一个Targets.cmake文件放在当前构建目录下
)
#用途: 开发阶段中, (两个项目共享同一个构建树或你手动指定路径)
#      可以直接在另一个项目里 include() 这个文件，后面就能直接target_link_libraries 这个 MyMath::MyMath。



# ---- 9. 生成一份Targets.cmake 放在安装树(用于: 安装, 供外部人员使用) ----
install(EXPORT MyMathTargets
        FILE MyMathTargets.cmake #生成一个Targets.cmake文件
        NAMESPACE MyMath:: #给导出集中的所有文件(目标, 其他配置文件)都加上命名空间前缀, 在其他外部项目链接时需要加上命名前缀, 避免冲突
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyMath #安装到 /usr/local/lib(或lib64)/cmake/MyMath/ 目录下
)


# ---- 10. 生成一份Config.cmake 在构建树 ----
configure_package_config_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in #输入的模板文件路径（需要开发者自己编写）, cmake会替换其中的变量生成一份config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfig.cmake #生成的配置文件路径（放在构建目录中)
        INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/MyMath" #都统一用变量, 别硬编码, 不同的OS的位置不一样, 比如开发机这里就是lib64而非lib
)

# ---- 11. 生成一份Version.cmake 在构建树 ----
write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfigVersion.cmake #生成的版本文件路径（放在构建目录中)
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion #兼容策略: 主版本号相同即兼容
)


# ---- 12. 安装Config.cmake 和 Version.cmake 到安装树 ---- 
install(FILES 
        ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfig.cmake 
        ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfigVersion.cmake
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/MyMath"
)





























# #my_lib/CMakeLists.txt

# #1. 收集源代码 (GLOB -- 不递归子目录)
# # CONFIGURE_DEPENDS: 每次构建时都重新扫描
# file(GLOB SRC_LIST CONFIGURE_DEPENDS "./src/*.cpp")



# #2. 添加构建目标(静态库)
# add_library(MyMath STATIC ${SRC_LIST})



# #3. 设置库的头文件搜索路径 -I (实则是设计使用要求)
# # 生成器表达式 -- $<...>，在 CMake 配置阶段不展开，在生成构建系统时才展开
# # CMake 有两个阶段：
# # 配置阶段：跑 cmake ..，处理 if/foreach、变量替换
# # 生成阶段：产出 Makefile/Ninja 文件 -- 很多信息（如"我现在是 Debug 还是 Release？"“我现在在构建树还是被安装后？”）在第一阶段还不知道，必须留到第二阶段决定。生成器表达式就是为此而生。
# target_include_directories(MyMath INTERFACE #INTERFACE: 对使用者的要求, 自己build时不需要这头文件
#         "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>/include>" #在同一个cmake项目内的测试目标, 需要的头文件路径是 MyMath_demo/My_lib/include -- 启用BUILD_INTERFACE. (注意这里是add_subdir(). 这个变量会变成当前src)
#         "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>" #外部目标, 需要的头文件路径是 /usr/local/include -- 启用INSTALL_INTERFACE
# )
# # 导出文件里实际写的内容: 
# # 构建树的 MyMathTargets.cmake：只保留 BUILD_INTERFACE 的值
# # 安装树的 MyMathTargets.cmake：只保留 INSTALL_INTERFACE 的值


# #4. 设置目标属性 -- 库的默认输出路径 -- 编译后在构建树中的位置
# #把生成的 libMyMath.a 文件放到 build/lib/ 下，而不是默认的 build/my_lib/ 或其他位置，这样所有库文件都集中在 lib/ 中，方便管理和后续打包。
# set_target_properties(MyMath PROPERTIES
#         ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib #顶层构建目录下的lib目录
# )



# #5. 安装静态库
# include(GNUInstallDirs) #引入模块，定义了一系列标准安装目录变量
# install(TARGETS MyMath #安装一个目标
#         EXPORT MyMathTargets #[登记]当前目标MyMath 属于导出集MathTargets, 告诉 CMake “将来我要导出 MyMathTargets 这个集合，里面包含 MyMath 这个目标”。
#         DESTINATION ${CMAKE_INSTALL_LIBDIR} #将目标MyMath安装到该目录下(/usr/local/lib)
# )



# #6. 安装头文件
# install(DIRECTORY ./include/ #安装一个目录, 目录中包含include/下的所有东西, 注意末尾的 / 表示复制文件夹内的内容，而不是文件夹本身
#         DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/MyMathInclude #安装到 /usr/local/include/MyMathInclude/ 下
#         FILES_MATCHING PATTERN "*.h" #只复制 .h 头文件，忽略其他文件
# )



# #7. 导出"导出集合"到构建树 -- 用于不安装直接内部使用
# export(EXPORT MyMathTargets #将导出集MyMathTargets生成为一个.cmake文件
#         FILE ${CMAKE_CURRENT_BINARY_DIR}/MyMathTargets.cmake #生成一个.cmake文件放在当前构建目录下
#         NAMESPACE MyMath::
# )



# #8. 安装"导出集合"到安装树 -- 用于安装供外部使用
# install(EXPORT MyMathTargets #安装一个导出集MyMathTargets
#         FILE MyMathTargets.cmake #生成的文件名 -- 包目标文件
#         NAMESPACE MyMath:: #给导出集中的所有文件(目标, 其他配置文件)都加上命名空间前缀, 在其他外部项目链接时, 需要加上命名前缀, 避免冲突, eg: arget_link_libraries(... MyMath::MyMath)
#         DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyMath #安装(复制)到 /usr/local/lib/cmake/MyMath/ 目录下
# )


# #9. 生成包配置文件(MyMathConfig.cmake)在构建树
# include(CMakePackageConfigHelpers) #引入辅助模块，提供了 configure_package_config_file 和 write_basic_package_version_file 等函数。
# configure_package_config_file( #读取一个模板文件（Config.cmake.in），替换其中的变量，生成最终的 MyMathConfig.cmake。
#         ${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in #模板文件位置（需要开发者自己编写，通常放在项目根目录）
#         ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfig.cmake #生成的配置文件位置（放在构建目录中)
#         INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyMath #相对路径, 相对于CMAKE_INSTALL_PREFIX
# )



# #10. 安装包配置文件(MyMathConfig.cmake)到安装树
# install(FILES ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfig.cmake #安装这个文件
#         DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyMath #安装到这里 -- 相对路径（不以 / 开头）
# )
# #install() 命令中的 DESTINATION 是相对于 CMAKE_INSTALL_PREFIX 的安装前缀，而不是相对于构建目录（CMAKE_CURRENT_BINARY_DIR）。
# #默认值：在 Linux/macOS 上，CMAKE_INSTALL_PREFIX 默认是 /usr/local。在 Windows 上，默认是 C:/Program Files/${PROJECT_NAME}。