# Core library CMakeLists.txt

add_library(dsquant
    statistics.cpp
)

target_include_directories(dsquant PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_compile_features(dsquant PUBLIC cxx_std_23)

install(TARGETS dsquant
    EXPORT dsquantTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT dsquantTargets
    FILE dsquantTargets.cmake
    NAMESPACE dsquant::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/dsquant
)
