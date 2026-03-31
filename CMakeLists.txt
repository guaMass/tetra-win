cmake_minimum_required(VERSION 3.22)
project(tetranerf_cpp_extension LANGUAGES CXX)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

find_package(Python3 COMPONENTS Interpreter REQUIRED)
if(NOT DEFINED PYTHON_EXECUTABLE)
  set(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}" CACHE FILEPATH "Python interpreter used to query PyTorch" FORCE)
endif()

find_package(Torch REQUIRED)
find_package(CGAL REQUIRED)

include(FetchContent)
FetchContent_Declare(
  pybind11
  GIT_REPOSITORY https://github.com/pybind/pybind11.git
  GIT_TAG v2.11.1
)
FetchContent_MakeAvailable(pybind11)

pybind11_add_module(tetranerf_cpp_extension
  src/triangulation.cpp
  src/py_binding.cpp
)

target_compile_features(tetranerf_cpp_extension PRIVATE cxx_std_17)

target_link_libraries(tetranerf_cpp_extension
  PRIVATE
    CGAL::CGAL
    ${TORCH_LIBRARIES}
)

if(TORCH_INCLUDE_DIRS)
  target_include_directories(tetranerf_cpp_extension PRIVATE ${TORCH_INCLUDE_DIRS})
endif()

if(TORCH_COMPILE_OPTIONS)
  target_compile_options(tetranerf_cpp_extension PRIVATE ${TORCH_COMPILE_OPTIONS})
endif()

if(TORCH_COMPILE_DEFINITIONS)
  target_compile_definitions(tetranerf_cpp_extension PRIVATE ${TORCH_COMPILE_DEFINITIONS})
endif()

if(MSVC)
  target_compile_options(tetranerf_cpp_extension PRIVATE /bigobj)
else()
  target_compile_options(tetranerf_cpp_extension PRIVATE -O3)
endif()

set_target_properties(tetranerf_cpp_extension PROPERTIES
  ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/tetranerf/utils/extension"
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
