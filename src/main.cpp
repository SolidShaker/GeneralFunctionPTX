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
        
        vecAdd = loader.LoadKernel("vectorAdd", "krVecAdd");

        if (vecAdd)
        {
            int N = 1024;
            const int threads_per_block = 256;
            const int blocks = (N + threads_per_block - 1) / threads_per_block;

            float* hA = new float[N];
            float* hB = new float[N];
            float* hC = new float[N];

            for (int i = 0; i < N; ++i) hA[i] = 1.f;
            for (int i = 0; i < N; ++i) hB[i] = 2.f;

            float *dA, *dB, *dC;
            cudaMalloc(&dA, N * sizeof(float));
            cudaMalloc(&dB, N * sizeof(float));
            cudaMalloc(&dC, N * sizeof(float));

            cudaMemcpy(dA, hA, N * sizeof(float), cudaMemcpyHostToDevice);
            cudaMemcpy(dB, hB, N * sizeof(float), cudaMemcpyHostToDevice);

            void* args[] = { &dA, &dB, &dC, &N };

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
            
            cudaMemcpy(hC, dC, N * sizeof(float), cudaMemcpyDeviceToHost);

            for (int i = 0; i < 10; ++i)
                std::cout << hC[i] << " ";

            cudaFree(dA);
            cudaFree(dB);
            cudaFree(dC);
        }
    } catch (const std::exception& e) 
    {
        REPORT(e.what());
        return 1;
    }
    
    return 0;
}
