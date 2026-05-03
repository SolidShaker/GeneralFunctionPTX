#include "PTXLoader.cuh"



PTXLoader::~PTXLoader()
{
    for (auto& module : modules) 
        cuModuleUnload(module);
    
    cuCtxDestroy(context);
}

void
PTXLoader::Init()
{
        CUresult result = cuInit(0);
        ASSERT(result == CUDA_SUCCESS, "Failed to initialize CUDA Driver API");
        
        result = cuDeviceGet(&device, 0);
        ASSERT(result == CUDA_SUCCESS, "Failed to get CUDA devuce");
        
        result = cuCtxCreate(&context, 0, device);
        ASSERT(result == CUDA_SUCCESS, "Failed to create CUDA context");

        REPORT("CUDA Driver API initialized. Device: " << device);
}

CUfunction
PTXLoader::LoadKernel(const std::string& kernelName,
                      const std::string& functionName)
{
    std::string ptxPath = GetPtxPath(kernelName);

    if (!std::filesystem::exists(ptxPath)) 
    {
        REPORT("PTX file not found: " << ptxPath);
        return nullptr;
    }

    CUmodule module;
    CUresult result = cuModuleLoad(&module, ptxPath.c_str());
    if (result != CUDA_SUCCESS) 
    {
        REPORT("Failed to load PTX file: " << ptxPath);
        const char* error_str;
        cuGetErrorString(result, &error_str);
        REPORT("CUDA Error: " << error_str);
        return nullptr;
    }

    CUfunction function;
    result = cuModuleGetFunction(&function, module, functionName.c_str());
    if (result != CUDA_SUCCESS) 
    {
        REPORT("Failed to get function: " << functionName);
        cuModuleUnload(module);
        return nullptr;
    }

    modules.push_back(module);
    REPORT("Loaded kernel '" << function_name << "' from " << ptxPath);
        
    return function;
}

std::string
PTXLoader::GetPtxPath(const std::string& kernelName) const
{
    std::vector<std::string> possible_paths = 
    {
        "kernels/" + kernelName + ".ptx",                     
        "../kernels/" + kernelName + ".ptx",                  
        "src/kernels/" + kernelName + ".ptx",                 
        "../../src/kernels/" + kernelName + ".ptx",          
    };
    
    for (const auto& path : possible_paths) 
        if (std::filesystem::exists(path)) 
            return path;
    
    return possible_paths[0];
}


