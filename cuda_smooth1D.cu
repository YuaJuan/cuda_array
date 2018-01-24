#include"cuda_need.h"

__global__ void smooth1D(float *data, float *out, int dataSize, int winsize){
	int t_x = blockIdx.y*blockDim.y + threadIdx.y;
	int t_y = blockIdx.x*blockDim.x + threadIdx.x;
	int offset = t_y*gridDim.x*blockDim.y + t_x;
	int tmp_offset = offset;
	int x = offset/dataSize;
	int y = offset%dataSize;
	float sum = 0.0;
	int count = 0;
	int tmp;

	if (x < dataSize&&y < dataSize){
		for (int i = 0; i < winsize; i++){
			tmp_offset += i*dataSize;
			for (int j = 0; j < winsize; j++){
				tmp = tmp_offset + j;
				x = tmp / dataSize;
				y = tmp%dataSize;
				if (x < dataSize&&y < dataSize){
					sum += data[tmp];
					count++;
				}
			}	
		}
		out[offset] = sum / count;
	}
}




void smooth1D_pre_data(char filePath[], int imgsize, float* memcpyHD_1D, float* memcpyDH_1D, float* kernel_1D, float* total_1D)
{

	float *d_data;
	float *d_out;
	float timeDelay;
	clock_t begintime, endtime;
    clock_t totalbegintime,totalendtime;
	float *data = new float[imgsize*imgsize];
	readData(filePath, data, imgsize);
	totalbegintime = clock();

    //printf("\ncuda_smooth1D begin....\n");
	cudaMalloc((void**)&d_data, sizeof(float)*imgsize*imgsize);
	cudaMalloc((void**)&d_out, sizeof(float)*imgsize*imgsize);
	
	begintime = clock();
	cudaMemcpy(d_data, data, sizeof(float)*imgsize*imgsize, cudaMemcpyHostToDevice);
	endtime = clock();
	timeDelay = (double)(endtime - begintime) * 1000 / CLOCKS_PER_SEC;
	*memcpyHD_1D = *memcpyHD_1D + timeDelay;
//	printf("in 1D memcpyHD time is :%.3fms\n", timeDelay);

	begintime = clock();
	dim3 dimBlock(32, 32);
	dim3 dimGrid((imgsize + dimBlock.x - 1) / (dimBlock.x), (imgsize + dimBlock.y - 1) / (dimBlock.y));
	smooth1D << <dimGrid, dimBlock >> >(d_data, d_out, imgsize, WINSIZE);
	
	endtime = clock();
	timeDelay = (double)(endtime - begintime) * 1000 / CLOCKS_PER_SEC;
	*kernel_1D = *kernel_1D + timeDelay;
//	printf("in 1D kernel time :%.3fms\n", timeDelay);

	begintime = clock();
	cudaMemcpy(data, d_out, sizeof(float)*imgsize*imgsize, cudaMemcpyDeviceToHost);
	endtime = clock();
    cudaThreadSynchronize();
	totalendtime = clock();
	timeDelay = (double)(endtime - begintime) * 1000 / CLOCKS_PER_SEC;
	*memcpyDH_1D = *memcpyDH_1D + timeDelay;
//	printf("1D memcpyDH time is :%.3fms\n", timeDelay);
	
	timeDelay = (double)(totalendtime - totalbegintime) * 1000 / CLOCKS_PER_SEC;
	*total_1D = *total_1D + timeDelay;
   // for(int i=0;i<10;i++)
    //  printf("%.3f ",data[i]);

  //  printf("\n");
   // printf("in 1D  total time is:%.3fms\n",timeDelay);
	//printf("\n\n");

}

