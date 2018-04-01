#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int **A;
int **B;
int **C;
int N;
double runtime=0;

void freeMemory(){
	for(int i=0; i<N; i++){
		free(A[i]);
		free(B[i]);
		free(C[i]);
	}
	free(A);
	free(B);
	free(C);
}

int randomNumber(){
	return rand()%10 +1 ;
}

void fillMatrix(int **S){
	for(int i=0; i<N; i++){
		for(int j=0; j<N; j++){
			S[i][j]=randomNumber();
		}
	}
}

void setupMatrices(int n){
	N=n;
	A=(int**)malloc(N*sizeof(int*));
	for(int i=0; i<N; i++) A[i]=(int*)malloc(N*sizeof (int));

	B=(int**)malloc(N*sizeof(int*));
	for(int i=0; i<N; i++) B[i]=(int*)malloc(N*sizeof (int));

	C=(int**)malloc(N*sizeof(int*));
	for(int i=0; i<N; i++) C[i]=(int*)malloc(N*sizeof (int));


	fillMatrix(A);
	fillMatrix(B);
}




void multiplication(){
	clock_t begin = clock();
	for(int i=0; i<N; i++){
		for(int j=0; j<N; j++){
			int total=0;
			for(int k=0; k<N; k++){
				total+=*(*(A+i)+k) * *(*(B+k)+j);
			}
			C[i][j]=total;
		}
	}
	clock_t end = clock();
	runtime = (double)(end - begin) / CLOCKS_PER_SEC;

}

int ** showMatrix(int ** S){
	for(int i=0; i<N; i++){
		for(int j=0; j<N; j++){
			printf("%d ",*(*(S+i)+j));
		}
		printf("\n");
	}
}



int main(int arg0, char **arg1){
	srand(time(NULL));
	int size = atoi(arg1[1]);
	setupMatrices(size);
	multiplication();
	printf("%0.8lf\n",runtime);
	freeMemory();

	return 0;
}
