#include"cuda_need.h"


int main(){
	int num = 8;
	int loop_times = 5;
	int imgsize;
	int datasize[]={500,1000,1500,2000,2500,3000,4000,5000,7000,9000,11000,13000,15000};
//
//    int datasize[]={500,11000};
	char filepath[1024];
    char csvfilepath[]="./test1.txt";	
	char strtemp[1024];
//	sprintf(strtemp, "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", "imgsize", "memcpyHD_1D", "memcpyDH_1D", "kernel_1D", "total_1D",
//		"memcpyHD_2D", "memcpyDH_2D", "kernel_2D", "total_2D", "total_cpu");

   sprintf(strtemp,"%s\t%s\t%s\n","imgsize","kernel_host","total_host");
	putStringToCsv(strtemp, csvfilepath);
	
	char str_num[20];
	for (int i =8; i < 11; i++){
		float memcpyHD_1D = 0.0, memcpyDH_1D = 0.0, kernel_1D = 0.0, total_1D = 0.0;
		float memcpyHD_2D = 0.0, memcpyDH_2D = 0.0, kernel_2D = 0.0, total_2D = 0.0;
		float memcpyHD_HOST = 0.0, memcpyDH_HOST = 0.0, kernel_HOST = 0.0, total_HOST = 0.0;
		float total_cpu = 0.0;
		memset(filepath, 0, 1024);
		imgsize = datasize[i];
		strcat(filepath,"/home/ajuan/sparkArray/data/data");
		//strcat(filepath, "D:\\data\\data");
		sprintf(str_num, "%d", datasize[i]);
		strcat(filepath, str_num);
		printf("now deal with file %s\n", filepath);
		for (int i = 0; i < loop_times; i++){
		//	smooth1D_pre_data(filepath, imgsize, &memcpyHD_1D, &memcpyDH_1D, &kernel_1D, &total_1D);
		//	smooth2D_pre_data(filepath, imgsize, &memcpyHD_2D, &memcpyDH_2D, &kernel_2D, &total_2D);
		//	smooth_pre_data_cpu(filepath, imgsize,&total_cpu);	
		//	mallocHost(filepath, imgsize, &kernel_HOST, &total_HOST);
			mallocHostAll(filepath, imgsize, &kernel_HOST, &total_HOST);
			
		}

		
	//	sprintf(strtemp, "%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n", imgsize, memcpyHD_1D / loop_times, memcpyDH_1D / loop_times, 
	//		kernel_1D / loop_times, total_1D / loop_times,memcpyHD_2D / loop_times, memcpyDH_2D / loop_times, 
	//		kernel_2D / loop_times, total_2D / loop_times, total_cpu / loop_times);
		sprintf(strtemp,"%d\t%.3f\t%.3f\n",imgsize,kernel_HOST/loop_times,total_HOST/loop_times);
		putStringToCsv(strtemp, csvfilepath);


/*		printf("#####################################################\n");
		printf("memcpyHD_1D time is :%.3f\n", memcpyHD_1D / loop_times);
		printf("kernel1D time is :%.3f\n", kernel_1D / loop_times);
		printf("memcpyDH_1D time is :%.3f\n", memcpyDH_1D / loop_times);
		printf("total_1D time is :%.3f\n\n", total_1D / loop_times);
		

		printf("#####################################################\n");
		printf("memcpyHD_2D time is :%.3f\n", memcpyHD_2D / loop_times);
		printf("kernel2D time is :%.3f\n", kernel_2D / loop_times);
		printf("memcpyDH_2D time is :%.3f\n", memcpyDH_2D / loop_times);
		printf("total_2D time is :%.3f\n\n", total_2D / loop_times);

		printf("#####################################################\n");
		printf("total time is :%.3f\n", total_cpu / loop_times);
*/
		printf("\n*********************************************\n");
		printf("kernel_host:%.3f\n", kernel_HOST/loop_times);
		printf("total_host:%.3f\n", total_HOST/loop_times);
	}
	
}





