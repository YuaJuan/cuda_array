#include"cuda_need.h"


void do_smooth(float **data,int imgsize);
void readData2D(char filePath[],float **data){
	int x = 0;
	int y = 0;
	float val = 0;
	char delimes[] = ",";
	char *split_result = NULL;
	char strLine[1024];
	FILE *fp;
	if ((fp = fopen(filePath, "r")) == NULL){
		printf("read %s file failed.\n",filePath);
		exit(-1);
	}

	while (!feof(fp)){
		fgets(strLine, 1024, fp);
			
		split_result = strtok(strLine, delimes);
		split_result = strtok(NULL, delimes);
		if (split_result == NULL)break;
		x = atoi(split_result);
	
		split_result = strtok(NULL, delimes);
		y = atoi(split_result);
	
		split_result = strtok(NULL, delimes);
		val = atof(split_result);		

		data[x][y] = val;
		//printf("%.2f", val);
	}
	fclose(fp);
}

void smooth_pre_data_cpu(char filePath[], int imgsize, float* total_cpu){
	float **data;
    clock_t start,end;
	float timeDelay;
   
	data = (float **)malloc(sizeof(float *)*imgsize);
	for (int i = 0; i < imgsize; i++)
		data[i] = (float *)malloc(sizeof(float)*imgsize);

	readData2D(filePath, data);
	start = clock();
	do_smooth(data,imgsize);
	end = clock();
	timeDelay = (double)(end - start) * 1000 / CLOCKS_PER_SEC;
	*total_cpu = *total_cpu + timeDelay;
	//printf("\nsmooth_cpu starting....\n");
	//printf("do_smooth_cpu:%.3fms\n",timeDelay);
}

void do_smooth(float **data,int imgsize){
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
