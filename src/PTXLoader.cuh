#ifndef PTXLOADER_CUH
#define PTXLOADER_CUH


#include "CUDAIncludes.cuh"

#include <filesystem>
#include <fstream>
#include <vector>
#include <string>


class PTXLoader
{
    private:
        CUdevice device;
        CUcontext context;
        std::vector<CUmodule> modules;

    private:
        PTXLoader& operator=(const PTXLoader&) = delete;
        PTXLoader(const PTXLoader&) = delete;
        PTXLoader& operator=(PTXLoader&&) = delete;
        PTXLoader(PTXLoader&&) = delete;

    public:
        PTXLoader() = default;
        ~PTXLoader();

    public:
        void Init();
        CUfunction LoadKernel(const std::string& kernelName,
                              const std::string& functionName);

    private:
        std::string GetPtxPath(const std::string& kernelName) const;
};

#endif
