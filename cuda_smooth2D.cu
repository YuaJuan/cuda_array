#include"cuda_need.h"

__global__ void smooth_pitch(float *data,float *out,size_t pitch,int dataSize,int winsize){	
	int x = blockIdx.y*blockDim.y + threadIdx.y;
	int y = blockIdx.x*blockDim.x + threadIdx.x;
	int temp_x, temp_y = 0;
	float sum = 0.0;
	int count = 0;
	float *row_a;
	
	if (x < dataSize&&y < dataSize){
		for (int i = 0; i < winsize; i++){
			temp_y = y + i;
			if (temp_y < dataSize)
				row_a = (float*)((char*)data + temp_y * pitch);
			else
				break;
			for (int j = 0; j < winsize; j++){
				temp_x = x+ j;
				if (temp_x < dataSize){
					sum += row_a[temp_x];
					count++;
				}
			}
			row_a = (float*)((char*)out + y*pitch);
			row_a[x] = sum;
		}
		
	}
}

void smooth2D_pre_data(char filepath[], int imgsize, float* memcpyHD_2D, float* memcpyDH_2D, float* kernel_2D, float* total_2D)
{	
	float *d_data;
	float *d_out;
	float timeDelay;

	size_t pitch;
    clock_t begintime, endtime,totalbegintime,totalendtime;

	float *data = new float[imgsize*imgsize];
	readData(filepath, data, imgsize);
	totalbegintime = clock();
//	printf("cuda_smooth2D begin.....\n");

    cudaMallocPitch((void**)&d_data, &pitch, imgsize*sizeof(float), imgsize);
	cudaMallocPitch((void**)&d_out, &pitch, imgsize*sizeof(float), imgsize);

	begintime = clock();
	
	cudaMemcpy2D(d_data, pitch, data, imgsize*sizeof(float), imgsize*sizeof(float), imgsize, cudaMemcpyHostToDevice);
	endtime = clock();
	timeDelay = (double)(endtime - begintime) * 1000 / CLOCKS_PER_SEC;
	*memcpyHD_2D = *memcpyHD_2D + timeDelay;
	//printf("in 2D memcpyHostToDevice time is :%.3fms\n", timeDelay);

	begintime = clock();
	// the gpu used maximum number of threads of per block:1024
	dim3 dimBlock(32, 32);
	//max of grid 2147483647
	dim3 dimGrid((imgsize + dimBlock.x - 1) / (dimBlock.x), (imgsize + dimBlock.y - 1) / (dimBlock.y));
	smooth_pitch << <dimGrid, dimBlock >> >(d_data, d_out, pitch, imgsize, WINSIZE);
	//smooth1D << <dimGrid, dimBlock >> >(d_data, d_out, DATASIZE, WINSIZE);
	endtime = clock();
	timeDelay = (double)(endtime - begintime) * 1000 / CLOCKS_PER_SEC;
	*kernel_2D = *kernel_2D + timeDelay;

	//printf("in 2D kernel function time :%.3fms\n", timeDelay);

	begintime = clock();
	cudaMemcpy2D(data, imgsize*sizeof(float), d_out, pitch, imgsize*sizeof(float), imgsize, cudaMemcpyDeviceToHost);
	endtime = clock();
	timeDelay = (double)(endtime - begintime) * 1000 / CLOCKS_PER_SEC;
	*memcpyDH_2D = *memcpyDH_2D + timeDelay;
	totalendtime = clock();
//	printf("in 2D memcpyDeviceToHost time is :%.3fms\n", timeDelay);
	timeDelay = (double)(totalendtime - totalbegintime) * 1000 / CLOCKS_PER_SEC;
	*total_2D = *total_2D + timeDelay;
//	printf("in 2D cuda_smooth2D total time is :%.3fms\n", timeDelay);
	//printf("\n\n");
}

