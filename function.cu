#include"cuda_need.h"
void readData(char filePath[], float *data,int imgsize){
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

		data[y + x*imgsize] = val;
		//printf("%.2f", val);
	}
	fclose(fp);
}

void writeExcel(float time)
{
	FILE *fp = NULL;
	fp = fopen("D:\\data.xls", "a");
	fprintf(fp, "%.3f\t", time);
		//fprintf(fp, "%c\t%d\n", 'e', 2);
	fclose(fp);
}

void writeExcelLine(){
	FILE *fp = NULL;
	fp = fopen("D:\\data.xls", "a+");
	fprintf(fp, "\n");
	fclose(fp);
}

int putString2Csv(char str[], char filename[], int mode)
{
	FILE *_fp;
	//try to open file  
	if ((_fp = fopen(filename, "a")) == NULL)
	{
		printf("fopen called error");
		exit(-1);
	}

	int _mode = mode;

	switch (_mode)
	{
	case 1:
	{
						 fputs(str, _fp);
						 fputs("\t", _fp);
	}break;
	case 0:
	{
						   fputs("\n", _fp);
	}break;
	default:break;
	}
	if (fclose(_fp) != 0)
	{
		printf("fclose called error");
		exit(-1);
	}

	return 1;
}

void putStringToCsv(char str[],char filename[]){
	FILE *fp;
	if((fp=fopen(filename,"a"))==NULL){
		printf("fopen called error");
		exit(-1);
	}
	fputs(str,fp);
	
    fclose(fp);
}


void readData2D(char filePath[], float **data){
	int x = 0;
	int y = 0;
	float val = 0;
	char delimes[] = ",";
	char *split_result = NULL;
	char strLine[1024];
	FILE *fp;
	if ((fp = fopen(filePath, "r")) == NULL){
		printf("read %s file failed.\n", filePath);
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