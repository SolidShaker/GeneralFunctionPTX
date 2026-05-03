#include "CUDAIncludes.cuh"
#include "PTXLoader.cuh"


#include <exception>

int main()
{
    CUfunction vecAdd;

    try
    {
        PTXLoader loader;
        loader.Init();
        
        vecAdd = loader.LoadKernel("vectorAdd", "krVectorAdd");

        if (vecAdd)
        {
            int N = 1024;
            const int threads_per_block = 256;
            const int blocks = (N + threads_per_block - 1) / threads_per_block;

            float *d_a, *d_b, *d_c;
            cudaMalloc(&d_a, N * sizeof(float));
            cudaMalloc(&d_b, N * sizeof(float));
            cudaMalloc(&d_c, N * sizeof(float));


            void* args[] = { &d_a, &d_b, &d_c, &N };

            CUresult result = cuLaunchKernel(vecAdd,
                                            blocks, 1, 1,        
                                            threads_per_block, 1, 1,  
                                            0,                  
                                            nullptr,            
                                            args,               
                                            nullptr);           
            
            ASSERT(result == CUDA_SUCCESS, "Failed to launch kernel");
            REPORT("Kernel launched successfully");
            cuCtxSynchronize();
            
            cudaFree(d_a);
            cudaFree(d_b);
            cudaFree(d_c);
        }
    } catch (const std::exception& e) 
    {
        REPORT(e.what());
        return 1;
    }
    
    return 0;
}
