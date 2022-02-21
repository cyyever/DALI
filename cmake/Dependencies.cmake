# Copyright (c) 2017-2019, 2021, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##################################################################
# CUDA Toolkit libraries (including NVJPEG)
##################################################################

find_package(CUDAToolkit REQUIRED)
CUDA_find_library(CUDART_LIB cudart_static)
list(APPEND DALI_EXCLUDES libcudart_static.a)

# For NVJPEG
if (BUILD_NVJPEG)

  # load using dlopen or link statically here
  if (NOT WITH_DYNAMIC_CUDA_TOOLKIT)
    if(TARGET CUDA::nvjpeg_static)
      list(APPEND DALI_LIBS CUDA::nvjpeg_static)
    else()
      list(APPEND DALI_LIBS CUDA::nvjpeg)
    endif()
  endif (NOT WITH_DYNAMIC_CUDA_TOOLKIT)

  add_compile_definitions(DALI_USE_NVJPEG)
  add_compile_definitions(NVJPEG_LIBRARY_0_2_0)
  add_compile_definitions(NVJPEG_PREALLOCATE_API)
endif()

if (BUILD_NVJPEG2K)
  CUDA_find_library(NVJPEG2K_LIBRARY nvjpeg2k_static)
  if (${NVJPEG2K_LIBRARY} STREQUAL "NVJPEG2K_LIBRARY-NOTFOUND")
    message(WARNING "nvJPEG2k not found - disabled")
    set(BUILD_NVJPEG2K OFF CACHE BOOL INTERNAL)
    set(BUILD_NVJPEG2K OFF)
  else()
    list(APPEND DALI_LIBS ${NVJPEG2K_LIBRARY})
    list(APPEND DALI_EXCLUDES libnvjpeg2k_static.a)
  endif()
endif ()

# NVIDIA NPP library
if (NOT WITH_DYNAMIC_CUDA_TOOLKIT)
  CUDA_find_library(CUDA_nppicc_LIBRARY nppicc_static)
  CUDA_find_library(CUDA_nppig_LIBRARY nppig_static)
  CUDA_find_library(CUDA_nppc_LIBRARY nppc_static)
  list(APPEND DALI_LIBS ${CUDA_nppicc_LIBRARY})
  list(APPEND DALI_EXCLUDES libnppicc_static.a)
  list(APPEND DALI_LIBS ${CUDA_nppig_LIBRARY})
  list(APPEND DALI_EXCLUDES libnppig_static.a)
  list(APPEND DALI_LIBS ${CUDA_nppc_LIBRARY})
  list(APPEND DALI_EXCLUDES libnppc_static.a)
endif ()

# cuFFT library
if (NOT WITH_DYNAMIC_CUDA_TOOLKIT)
  CUDA_find_library(CUDA_cufft_LIBRARY cufft_static)
  list(APPEND DALI_EXCLUDES libcufft_static.a)
endif ()

# CULIBOS needed when using static CUDA libs
if (NOT WITH_DYNAMIC_CUDA_TOOLKIT)
  if(TARGET CUDA::culibos)
    list(APPEND DALI_LIBS CUDA::culibos)
    list(APPEND DALI_EXCLUDES libculibos.a)
  endif()
endif()

if (LINK_LIBCUDA)
  CUDA_find_library_stub(CUDA_cuda_LIBRARY cuda)
  list(APPEND DALI_LIBS ${CUDA_cuda_LIBRARY})

  CUDA_find_library_stub(CUDA_nvml_LIBRARY nvidia-ml)
  list(APPEND DALI_LIBS ${CUDA_nvml_LIBRARY})
endif()

# NVTX for profiling
if (NVTX_ENABLED)
  if(${CUDA_VERSION} VERSION_LESS "10.0")
     CUDA_find_library(CUDA_nvToolsExt_LIBRARY nvToolsExt)
     list(APPEND DALI_LIBS ${CUDA_nvToolsExt_LIBRARY})
  endif()
endif()

# verbose
if (VERBOSE_LOGS)
  add_compile_definitions(DALI_VERBOSE_LOGS)
endif()


include(cmake/Dependencies.common.cmake)

##################################################################
# protobuf
##################################################################
# link statically

if (BUILD_PROTOBUF)
  if(NOT DEFINED Protobuf_USE_STATIC_LIBS)
    set(Protobuf_USE_STATIC_LIBS YES)
  endif(NOT DEFINED Protobuf_USE_STATIC_LIBS)
  find_package(Protobuf 2.0 REQUIRED)
  if(${Protobuf_VERSION} VERSION_LESS "3.0")
    message(STATUS "TensorFlow TFRecord file format support is not available with Protobuf 2")
  else()
    message(STATUS "Enabling TensorFlow TFRecord file format support")
    add_compile_definitions(DALI_BUILD_PROTO3=1)
    set(BUILD_PROTO3 ON CACHE STRING "Build proto3")
  endif()

  include_directories(SYSTEM ${Protobuf_INCLUDE_DIRS})
  list(APPEND DALI_LIBS ${Protobuf_LIBRARY})
  # hide things from the protobuf, all we export is only is API generated from our proto files
  list(APPEND DALI_EXCLUDES libprotobuf.a)
endif()

find_package(Threads REQUIRED)
set(DALI_SYSTEM_LIBS rt Threads::Threads m dl)
list(APPEND DALI_LIBS ${CUDART_LIB} ${DALI_SYSTEM_LIBS})

##################################################################
# Exclude stdlib
##################################################################
list(APPEND DALI_EXCLUDES libsupc++.a;libstdc++.a;libstdc++_nonshared.a;)


##################################################################
# Turing Optical flow API
##################################################################
if(BUILD_NVOF)
  include_directories(${PROJECT_SOURCE_DIR}/third_party/turing_of)
endif()

include_directories(SYSTEM ${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES})
