cmake_minimum_required(VERSION 3.18)
project(PtxLoaderProject LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(CUDA REQUIRED)

set(KERNELS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src/kernels)
file(GLOB PTX_FILES
    ${KERNELS_DIR}/*.ptx
)

file(GLOB SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.*)
add_executable(main ${SOURCES})


target_link_libraries(main 
    ${CUDA_LIBRARIES}
    ${CUDA_cuda_LIBRARY}  # For Driver API
)

# Add include directories
target_include_directories(main PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CUDA_INCLUDE_DIRS}
)

# --- Copy PTX files to build directory for runtime access ---
add_custom_command(TARGET main POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory
        $<TARGET_FILE_DIR:main>/kernels
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${PTX_FILES}
        $<TARGET_FILE_DIR:main>/kernels/
    COMMENT "Copying hand-written PTX kernels to executable directory"
)

# --- Optional: Validate PTX files during build ---
# This runs ptxas (PTX assembler) to validate syntax without generating cubin
find_program(PTXAS_EXECUTABLE ptxas)
if(PTXAS_EXECUTABLE)
    foreach(PTX_FILE ${PTX_FILES})
        add_custom_command(TARGET main PRE_BUILD
            COMMAND ${PTXAS_EXECUTABLE} -arch=sm_75 ${PTX_FILE}
            COMMENT "Validating PTX syntax: ${PTX_FILE}"
        )
    endforeach()
endif()

message(STATUS "Hand-written PTX kernels will be copied from: ${KERNELS_DIR}")
