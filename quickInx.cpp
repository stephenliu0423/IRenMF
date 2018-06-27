/* helloworld.cpp */
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
	double *userW = mxGetPr(prhs[0]);
	double *inx = (double *)mxGetData(prhs[1]);
	
	int m=mxGetM(prhs[0]), k = mxGetN(prhs[0]), n=mxGetM(prhs[1]);
	//printf("%i, %i\n", k, n);
	
	plhs[0] = mxCreateDoubleMatrix(n,k, mxREAL);
	double *outdata=mxGetPr(plhs[0]);
	
	for(int j=0; j<k; j++)
	{
		for(int i=0; i<n; i++)
		{
			outdata[i+j*n] = userW[int(inx[i]-1)+j*m];
		}
	}
}