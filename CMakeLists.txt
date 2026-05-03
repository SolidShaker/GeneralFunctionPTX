cmake_minimum_required(VERSION 3.20)
project(PtxLoaderProject LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Suppress the FindCUDA deprecation warning
if(POLICY CMP0146)
    cmake_policy(SET CMP0146 NEW)
endif()

# Set CUDA architecture (T4 uses sm_75, V100 uses sm_70)
set(CMAKE_CUDA_ARCHITECTURES "75" CACHE STRING "CUDA architectures")

# Suppress nvcc deprecation warnings
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Wno-deprecated-gpu-targets")

# Use modern CUDAToolkit instead of deprecated FindCUDA
find_package(CUDAToolkit REQUIRED)

# Directory containing PTX files
set(KERNELS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src/kernels)

# Source files
file(GLOB SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cu)
add_executable(main ${SOURCES})

# Link CUDA toolkit libraries
target_link_libraries(main 
    CUDA::cuda_driver      # For CUDA Driver API
    CUDA::cudart_static    # For CUDA Runtime API (optional)
)

# Add include directories
target_include_directories(main PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CUDAToolkit_INCLUDE_DIRS}
)

# Copy PTX files to build directory for runtime access
file(GLOB PTX_FILES ${KERNELS_DIR}/*.ptx)
if(PTX_FILES)
    add_custom_command(TARGET main POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory
            $<TARGET_FILE_DIR:main>/kernels
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${PTX_FILES}
            $<TARGET_FILE_DIR:main>/kernels/
        COMMENT "Copying hand-written PTX kernels to executable directory"
    )
endif()

# Optional: Validate PTX files during build
find_program(PTXAS_EXECUTABLE ptxas)
if(PTXAS_EXECUTABLE AND PTX_FILES)
    foreach(PTX_FILE ${PTX_FILES})
        add_custom_command(TARGET main PRE_BUILD
            COMMAND ${PTXAS_EXECUTABLE} -arch=sm_75 ${PTX_FILE}
            COMMENT "Validating PTX syntax: ${PTX_FILE}"
        )
    endforeach()
endif()

message(STATUS "Hand-written PTX kernels will be copied from: ${KERNELS_DIR}")
