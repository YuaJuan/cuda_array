#include <stdio.h>  
#include <stdlib.h>  
#include <cuda_runtime.h> 
#include"time.h"
#include<string.h>
#include<iostream>
#include<string.h>
#include<cstring>

using namespace std;



#define WINSIZE 5
#define CHECK(res) if(res!=cudaSuccess){exit(-1);} 

__global__ void smooth_pitch(float *data, float *out, size_t pitch, int dataSize, int winsize);
__global__ void smooth1D(float *data, float *out, int dataSize, int winsize);
void readData(char filePath[], float *data, int imgsize);
void smooth1D_pre_data(char filePath[], int imgsize, float* memcpyHD_1D, float* memcpyDH_1D, float* kernel_1D, float* total_1D);
void smooth2D_pre_data(char filePath[], int imgsize, float* memcpyHD_2D, float* memcpyDH_2D, float* kernel_2D, float* total_2D);
void smooth_pre_data_cpu(char filePath[], int imgsize, float* total_cpu);
void writeExcel(float time);
void writeExcelLine();
void mallocHost(char filepath[], int imgsize,float *kernel_HOST,float *total_HOST);
void mallocHostAll(char filepath[], int imgsize,float *kernel_HOST,float *total_HOST);
void mallocHostDefault(char filepath[], int datasize, float *memcpyDH_hostDefault, float *kernel_hostDefault, float *total_hostDefault);
void putStringToCsv(char str[],char filename[]);
void do_smooth(float **data, int imgsize);
int putString2Csv(char str[],char filename[],int mode);
void readData2D(char filePath[], float **data);



