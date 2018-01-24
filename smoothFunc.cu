
#include"cuda_need.h"

void smooth1D_pre_data(char filePath[], int imgsize, float* memcpyHD_1D, float* memcpyDH_1D, float* kernel_1D, float* total_1D)
{

	float *d_data;
	float *d_out;
	float timeDelay;
	clock_t begintime, endtime;
	clock_t totalbegintime, totalendtime;
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


void smooth2D_pre_data(char filepath[], int imgsize, float* memcpyHD_2D, float* memcpyDH_2D, float* kernel_2D, float* total_2D)
{
	float *d_data;
	float *d_out;
	float timeDelay;

	size_t pitch;
	clock_t begintime, endtime, totalbegintime, totalendtime;

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

void smooth_pre_data_cpu(char filePath[], int imgsize, float* total_cpu){
	float **data;
	int endtime, begintime;
	clock_t start, end;
	double timedelay;
	float timeDelay;

	data = (float **)malloc(sizeof(float *)*imgsize);
	for (int i = 0; i < imgsize; i++)
		data[i] = (float *)malloc(sizeof(float)*imgsize);

	readData2D(filePath, data);
	start = clock();
	do_smooth(data, imgsize);
	end = clock();
	timeDelay = (double)(end - start) * 1000 / CLOCKS_PER_SEC;
	*total_cpu = *total_cpu + timeDelay;
	printf("\nsmooth_cpu starting....\n");
	printf("do_smooth_cpu:%.3fms\n", timeDelay);
}

void do_smooth(float **data, int imgsize){
	int sum, count;
	int x, y;
	for (int i = 0; i < imgsize; i++)
	{
		for (int j = 0; j < imgsize; j++){
			sum = 0;
			count = 0;
			for (int m = 0; m < WINSIZE; m++){
				for (int n = 0; n < WINSIZE; n++){
					x = i + m;
					y = j + n;
					if (x < imgsize&&y < imgsize){
						sum += data[x][y];
						count++;
					}
				}
			}
			data[i][j] = sum / count;
		}
	}
}


void mallocHost(char filepath[], int datasize, float *kernel_HOST, float *total_HOST){
	float *data = new float[datasize*datasize];
	float *host2dev;
	float *d_data;
	float *dev_host2dev;
	float delay;
	clock_t begintime, endtime, totalbegintime, totalendtime;

	cudaSetDeviceFlags(cudaDeviceMapHost);
	cudaMalloc((void**)&d_data, sizeof(float)*datasize*datasize);
	readData(filepath, data, datasize);
	totalbegintime = clock();
	cudaMemcpy(d_data, data, sizeof(float)*datasize*datasize, cudaMemcpyHostToDevice);

	//	cudaHostAlloc((void**)&data, sizeof(float)*datasize*datasize, cudaHostAllocMapped | cudaHostAllocWriteCombined);
	cudaHostAlloc((void**)&host2dev, sizeof(float)*datasize*datasize, cudaHostAllocMapped | cudaHostAllocWriteCombined);
	//cudaHostAllocWriteCombined合并式写入，有效提高GPU读取这个内存，但是如果CPU也需要读取这个内存，会降低性能

	cudaHostGetDevicePointer(&dev_host2dev, host2dev, 0);
	//	cudaHostGetDevicePointer(&d_data, data, 0);


	begintime = clock();
	dim3 dimBlock(32, 32);
	dim3 dimGrid((datasize + dimBlock.x - 1) / (dimBlock.x), (datasize + dimBlock.y - 1) / (dimBlock.y));
	smooth1D << <dimGrid, dimBlock >> >(d_data, dev_host2dev, datasize, WINSIZE);
	cudaThreadSynchronize();
	endtime = clock();
	totalendtime = clock();
	delay = (double)(endtime - begintime) * 1000 / CLOCKS_PER_SEC;
	*kernel_HOST = *kernel_HOST + delay;
	printf("in function kernel_HOST:%.3f\n", delay);
	delay = (double)(totalendtime - totalbegintime) * 1000 / CLOCKS_PER_SEC;
	*total_HOST = *total_HOST + delay;
	printf("in funtcion total_HOST:%.3f\n", delay);
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


void mallocHostDefault(char filepath[], int datasize, float *memcpyDH_hostDefault,float *kernel_hostDefault, float *total_hostDefault){
	float *data=new float[datasize*datasize];
	float *d_data;
	float *out;
	float delay;
	clock_t begintime, endtime, totalbegintime, totalendtime;

	readData(filepath, data, datasize);
	totalbegintime = clock();
	cudaMalloc((void**)&d_data, sizeof(float)*datasize*datasize);
	begintime=clock();
	cudaMemcpy(d_data, data, sizeof(float)*datasize*datasize, cudaMemcpyHostToDevice);
	endtime=clock();
	delay=(double)(endtime-begintime)*1000/CLOCKS_PER_SEC;

//	printf("int function mallocHostDefault memcpyHD:%.3f\n",delay);
	cudaHostAlloc((void**)&out, sizeof(float)*datasize*datasize,cudaHostAllocDefault);

	begintime = clock();
	dim3 dimBlock(32, 32);
	dim3 dimGrid((datasize + dimBlock.x - 1) / (dimBlock.x), (datasize + dimBlock.y - 1) / (dimBlock.y));
	smooth1D << <dimGrid, dimBlock >> >(d_data, out, datasize, WINSIZE);
	cudaThreadSynchronize();
	endtime = clock();
	delay = (double)(endtime - begintime) * 1000 / CLOCKS_PER_SEC;
	*kernel_hostDefault = *kernel_hostDefault + delay;
//	printf("in function mallocHostDefault kernel :%.3f\n", delay);

	begintime = clock();
	cudaMemcpy(data, out, sizeof(float)*datasize*datasize, cudaMemcpyDeviceToHost);
	endtime = clock();
	totalendtime = clock();
	delay = (double)(endtime - begintime) * 1000 / CLOCKS_PER_SEC;
	*memcpyDH_hostDefault = *memcpyDH_hostDefault + delay;
	//printf("in function mallocHostDefault memcpyDH:%.3f\n", delay);
	delay = (double)(totalendtime - totalbegintime) * 1000 / CLOCKS_PER_SEC;
	*total_hostDefault = *total_hostDefault + delay;
	//printf("in function mallocHostDefault totaltime:%.3f\n", delay);

}
