#ifndef CUDAINCLUDES_CUH
#define CUDAINCLUDES_CUH

#include <cuda.h>
#include <cuda_runtime.h>


#include <iostream>
#define REPORT(msg) do { \
    std::cerr << "[INFO] " \
    << msg << " | FILE " \
    << __FILE__ << " | LINE " \
    << __LINE__ << " |" << std::endl; \
} while(0)

#include <exception>
#include <string>
#define ASSERT(cond, msg) do { \
    if (!(cond)) { \
        throw std::runtime_error(std::string("[ERROR] ") + (msg) + \
                                 " | FILE "  + std::string(__FILE__) + \
                                 " | LINE "  + std::to_string(__LINE__) + \
                                 " |"); \
    } \
} while(0)

#endif
