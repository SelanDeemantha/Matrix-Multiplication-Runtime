#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>

#define BLOCK_SIZE 256

__global__ void gpu_square_matrix_mult(int *d_a, int *d_b, int *d_result, int n) 
{
    __shared__ int tile_a[BLOCK_SIZE][BLOCK_SIZE];
    __shared__ int tile_b[BLOCK_SIZE][BLOCK_SIZE];

    int row = blockIdx.y * BLOCK_SIZE + threadIdx.y;
    int col = blockIdx.x * BLOCK_SIZE + threadIdx.x;
    int tmp = 0;
    int idx;

    for (int sub = 0; sub < gridDim.x; ++sub) 
    {
        idx = row * n + sub * BLOCK_SIZE + threadIdx.x;
        if(idx >= n*n)
        {
           
            tile_a[threadIdx.y][threadIdx.x] = 0;
        }
        else
        {
            tile_a[threadIdx.y][threadIdx.x] = d_a[idx];
        }

        idx = (sub * BLOCK_SIZE + threadIdx.y) * n + col;
        if(idx >= n*n)
        {
            tile_b[threadIdx.y][threadIdx.x] = 0;
        }  
        else
        {
            tile_b[threadIdx.y][threadIdx.x] = d_b[idx];
        }
        __syncthreads();

        for (int k = 0; k < BLOCK_SIZE; ++k) 
        {
            tmp += tile_a[threadIdx.y][k] * tile_b[k][threadIdx.x];
        }
        __syncthreads();
    }
    if(row < n && col < n)
    {
        d_result[row * n + col] = tmp;
    }
}

__global__ void gpu_matrix_transpose(int* mat_in, int* mat_out, unsigned int rows, unsigned int cols) 
{
    unsigned int idx = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int idy = blockIdx.y * blockDim.y + threadIdx.y;

    if (idx < cols && idy < rows) 
    {
        unsigned int pos = idy * cols + idx;
        unsigned int trans_pos = idx * rows + idy;
        mat_out[trans_pos] = mat_in[pos];
    }
}

int main(int argc, char const *argv[])
{
    if(argc != 2)
	exit(2);
    int N = atoi(argv[1]);    

   
    srand(3333);
    
    int *h_a, *h_b, *h_c;
    cudaMallocHost((void **) &h_a, sizeof(int)*N*N);
    cudaMallocHost((void **) &h_b, sizeof(int)*N*N);
    cudaMallocHost((void **) &h_c, sizeof(int)*N*N);
    
   
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            h_a[i * N + j] = rand() % 10;
	  h_b[i * N + j] = rand() % 10;
        }
    }


    int *d_a, *d_b, *d_c;
    cudaMalloc((void **) &d_a, sizeof(int)*N*N);
    cudaMalloc((void **) &d_b, sizeof(int)*N*N);
    cudaMalloc((void **) &d_c, sizeof(int)*N*N);

 
    cudaMemcpy(d_a, h_a, sizeof(int)*N*N, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, sizeof(int)*N*N, cudaMemcpyHostToDevice);

    unsigned int grid_rows = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;
    unsigned int grid_cols = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;
    dim3 dimGrid(grid_cols, grid_rows);
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);

	clock_t begin = clock();
	    gpu_square_matrix_mult<<<dimGrid, dimBlock>>>(d_a, d_b, d_c, N);    
	clock_t end = clock();
	double time_spent = (double)(end - begin) / (CLOCKS_PER_SEC / 1000);

    fprintf(stdout, "%f", time_spent);

    cudaMemcpy(h_c, d_c, sizeof(int)*N*N, cudaMemcpyDeviceToHost);
    cudaThreadSynchronize();

    
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    cudaFreeHost(h_a);
    cudaFreeHost(h_b);
    cudaFreeHost(h_c);
    return 0;
}

