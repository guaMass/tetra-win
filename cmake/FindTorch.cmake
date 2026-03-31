# Finds PyTorch from the active Python environment and exposes:
#   TORCH_LIBRARIES
#   TORCH_INCLUDE_DIRS
#   TORCH_LIBRARY_DIRS
#   TORCH_COMPILE_OPTIONS
#   TORCH_COMPILE_DEFINITIONS

if(NOT DEFINED PYTHON_EXECUTABLE)
  find_package(Python3 COMPONENTS Interpreter REQUIRED)
  set(PYTHON_EXECUTABLE "${Python3_EXECUTABLE}")
endif()

execute_process(
  COMMAND "${PYTHON_EXECUTABLE}" -c "import torch; print(torch.__version__, end='')"
  RESULT_VARIABLE _torch_status
  OUTPUT_VARIABLE TORCH_VERSION
)
if(NOT _torch_status EQUAL 0)
  message(FATAL_ERROR "Could not import torch using Python executable: ${PYTHON_EXECUTABLE}")
endif()

execute_process(
  COMMAND "${PYTHON_EXECUTABLE}" -c "import torch.utils; print(torch.utils.cmake_prefix_path, end='')"
  COMMAND_ERROR_IS_FATAL ANY
  OUTPUT_VARIABLE _torch_cmake_prefix
)
list(APPEND CMAKE_PREFIX_PATH "${_torch_cmake_prefix}")

find_package(Torch CONFIG REQUIRED)

execute_process(
  COMMAND "${PYTHON_EXECUTABLE}" -c "import torch.utils.cpp_extension as ext; print(';'.join(ext.include_paths(False)), end='')"
  COMMAND_ERROR_IS_FATAL ANY
  OUTPUT_VARIABLE TORCH_INCLUDE_DIRS
)
execute_process(
  COMMAND "${PYTHON_EXECUTABLE}" -c "import torch.utils.cpp_extension as ext; print(';'.join(ext.library_paths(False)), end='')"
  COMMAND_ERROR_IS_FATAL ANY
  OUTPUT_VARIABLE TORCH_LIBRARY_DIRS
)

set(_torch_config_libraries "${TORCH_LIBRARIES}")
set(TORCH_LIBRARIES)
if(TARGET Torch::Torch)
  list(APPEND TORCH_LIBRARIES Torch::Torch)
endif()
if(TARGET Torch::Python)
  list(APPEND TORCH_LIBRARIES Torch::Python)
endif()
if(NOT TORCH_LIBRARIES AND NOT _torch_config_libraries STREQUAL "")
  set(TORCH_LIBRARIES ${_torch_config_libraries})
endif()
if(NOT TORCH_LIBRARIES)
  message(FATAL_ERROR "Torch was found, but no usable CMake targets were exported.")
endif()

set(TORCH_COMPILE_OPTIONS)
if(DEFINED TORCH_CXX_FLAGS AND NOT TORCH_CXX_FLAGS STREQUAL "")
  separate_arguments(_torch_cxx_flags NATIVE_COMMAND "${TORCH_CXX_FLAGS}")
  list(APPEND TORCH_COMPILE_OPTIONS ${_torch_cxx_flags})
endif()

set(TORCH_COMPILE_DEFINITIONS
  __CUDA_NO_HALF_OPERATORS__
  __CUDA_NO_HALF_CONVERSIONS__
  __CUDA_NO_HALF2_OPERATORS__
)

message(STATUS "Found torch ${TORCH_VERSION}")
message(STATUS "Using torch cmake prefix: ${_torch_cmake_prefix}")
message(STATUS "Using torch include dirs: ${TORCH_INCLUDE_DIRS}")
message(STATUS "Using torch library dirs: ${TORCH_LIBRARY_DIRS}")
