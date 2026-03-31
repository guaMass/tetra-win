# Wrapper to force use of CMake's built-in FindCUDA implementation.
# Torch's CMake scripts still rely on legacy FindCUDA variables/macros.
include("${CMAKE_ROOT}/Modules/FindCUDA.cmake")
