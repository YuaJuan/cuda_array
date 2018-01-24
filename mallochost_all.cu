#include"cuda_need.h"


void mallocHostAll(char filepath[], int datasize, float *kernel_HOST, float *total_HOST){
	float *data;
	float *host2dev;
	float *d_data;
	float *dev_host2dev;
	float delay;
	clock_t begintime, endtime, totalbegintime, totalendtime;

	cudaSetDeviceFlags(cudaDeviceMapHost);

	cudaHostAlloc((void**)&data, sizeof(float)*datasize*datasize, cudaHostAllocMapped | cudaHostAllocWriteCombined);
	cudaHostAlloc((void**)&host2dev, sizeof(float)*datasize*datasize, cudaHostAllocMapped | cudaHostAllocWriteCombined);
	//cudaHostAllocWriteCombined合并式写入，有效提高GPU读取这个内存，但是如果CPU也需要读取这个内存，会降低性能

	readData(filepath, data, datasize);
	totalbegintime = clock();
	cudaHostGetDevicePointer(&dev_host2dev, host2dev, 0);
	cudaHostGetDevicePointer(&d_data, data, 0);

	
	begintime = clock();
	dim3 dimBlock(32, 32);
	dim3 dimGrid((datasize + dimBlock.x - 1) / (dimBlock.x), (datasize + dimBlock.y - 1) / (dimBlock.y));
	smooth1D << <dimGrid, dimBlock >> >(d_data, dev_host2dev, datasize, WINSIZE);
	cudaThreadSynchronize();
	endtime = clock();
	totalendtime = clock();
	delay = (double)(endtime - begintime) * 1000 / CLOCKS_PER_SEC;
	*kernel_HOST = *kernel_HOST + delay;
	printf("in function kernel_HOSTALL:%.3f\n", delay);
	delay = (double)(totalendtime - totalbegintime) * 1000 / CLOCKS_PER_SEC;
	*total_HOST = *total_HOST + delay;
	printf("in funtcion total_HOSTALL:%.3f\n", delay);
	//cudaMemcpy(data, d_data, sizeof(float)*datasize*datasize, cudaMemcpyDeviceToHost);
//	for (int i = 0; i < datasize*datasize; i++){
//		if (i%datasize == 0)
//			printf("\n");
//		printf("%.3f ", host2dev[i]);
//	}
//	printf("\n");
/*	for (int i = 0; i <10; i++){
		if (i%datasize == 0)
			printf("\n");
		printf("%.3f ", host2dev[i]);
	}
	printf("\n");*/
	cudaFree(d_data);
	cudaFreeHost(dev_host2dev);

}
