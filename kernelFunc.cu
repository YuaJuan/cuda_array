#include"cuda_need.h"

__global__ void smooth1D(float *data, float *out, int dataSize, int winsize){
	int t_x = blockIdx.y*blockDim.y + threadIdx.y;
	int t_y = blockIdx.x*blockDim.x + threadIdx.x;
	int offset = t_y*gridDim.x*blockDim.y + t_x;
	int tmp_offset = offset;
	int x = offset / dataSize;
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


__global__ void smooth_pitch(float *data, float *out, size_t pitch, int dataSize, int winsize){
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
				temp_x = x + j;
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
