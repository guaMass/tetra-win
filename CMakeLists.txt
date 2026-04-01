cmake_minimum_required(VERSION 3.22)
project(tetranerf_cpp_extension LANGUAGES CXX)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

find_package(Python3 COMPONENTS Interpreter Development.Module REQUIRED)
if(NOT DEFINED PYTHON_EXECUTABLE)
  set(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}" CACHE FILEPATH "Python interpreter used to query PyTorch" FORCE)
endif()

find_package(Torch REQUIRED)
if(POLICY CMP0167)
  cmake_policy(SET CMP0167 OLD)
endif()
find_package(CGAL REQUIRED)

Python3_add_library(tetranerf_cpp_extension MODULE WITH_SOABI
  src/triangulation.cpp
  src/py_binding.cpp
)

target_compile_features(tetranerf_cpp_extension PRIVATE cxx_std_17)

target_link_libraries(tetranerf_cpp_extension
  PRIVATE
    CGAL::CGAL
    ${TORCH_LIBRARIES}
    Python3::Module
)

if(TORCH_INCLUDE_DIRS)
  target_include_directories(tetranerf_cpp_extension PRIVATE ${TORCH_INCLUDE_DIRS})
endif()

if(TORCH_LIBRARY_DIRS)
  target_link_directories(tetranerf_cpp_extension PRIVATE ${TORCH_LIBRARY_DIRS})
endif()

if(TORCH_COMPILE_OPTIONS)
  target_compile_options(tetranerf_cpp_extension PRIVATE ${TORCH_COMPILE_OPTIONS})
endif()

if(TORCH_COMPILE_DEFINITIONS)
  target_compile_definitions(tetranerf_cpp_extension PRIVATE ${TORCH_COMPILE_DEFINITIONS})
endif()

target_compile_definitions(tetranerf_cpp_extension PRIVATE TORCH_EXTENSION_NAME=tetranerf_cpp_extension)

if(MSVC)
  target_compile_options(tetranerf_cpp_extension PRIVATE /bigobj)
else()
  target_compile_options(tetranerf_cpp_extension PRIVATE -O3)
endif()

set(_extension_output_dir "${CMAKE_SOURCE_DIR}/tetranerf/utils/extension")

set_target_properties(tetranerf_cpp_extension PROPERTIES
  PREFIX ""
  ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
  LIBRARY_OUTPUT_DIRECTORY "${_extension_output_dir}"
  RUNTIME_OUTPUT_DIRECTORY "${_extension_output_dir}"
)

foreach(_cfg IN ITEMS Debug Release RelWithDebInfo MinSizeRel)
  string(TOUPPER "${_cfg}" _cfg_upper)
  set_target_properties(tetranerf_cpp_extension PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY_${_cfg_upper} "${_extension_output_dir}"
    RUNTIME_OUTPUT_DIRECTORY_${_cfg_upper} "${_extension_output_dir}"
  )
endforeach()
