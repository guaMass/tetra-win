# Compatibility shim for projects that still call find_package(CUDA).
# Prefer find_package(CUDAToolkit) in new CMake code.

find_package(CUDAToolkit REQUIRED)

set(CUDA_FOUND TRUE)
set(CUDA_VERSION "${CUDAToolkit_VERSION}")
set(CUDA_INCLUDE_DIRS "${CUDAToolkit_INCLUDE_DIRS}")
set(CUDA_LIBRARIES CUDA::cudart)

if(DEFINED CUDAToolkit_LIBRARY_ROOT)
  set(CUDA_TOOLKIT_ROOT_DIR "${CUDAToolkit_LIBRARY_ROOT}")
endif()

if(NOT TARGET CUDA::toolkit)
  add_library(CUDA::toolkit INTERFACE IMPORTED)
  target_link_libraries(CUDA::toolkit INTERFACE CUDA::cudart)
endif()
