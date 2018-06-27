/* helloworld.cpp */
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
	double *userW = mxGetPr(prhs[0]);
    double *itemW = mxGetPr(prhs[1]);
    double *wMat  = mxGetPr(prhs[2]);
	
	int m=mxGetM(prhs[0]), r = mxGetN(prhs[0]), n=mxGetM(prhs[1]);
    int m1=mxGetM(prhs[2]), n1=mxGetN(prhs[2]);
	
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
	plhs[1] = mxCreateDoubleMatrix(m1,1, mxREAL);
    //plhs[2] = mxCreateSparse(m, n, m1, mxREAL);
    
	double *loss=mxGetPr(plhs[0]), *X=mxGetPr(plhs[1]); //*M=mxGetPr(plhs[2]);
	
    for(int k=0; k<m1; k++){
        int i=int(wMat[k])-1, j=int(wMat[k+m1])-1; 
        float w=wMat[k+2*m1];
        //printf("%i, %i, %g ", i, j, w);
        
        double val =0.0;
        for(int k1=0; k1<r; k1++){
            val += userW[i+k1*m]*itemW[j+k1*n];
        }
        X[k]=w*val;
        loss[0] += 0.5*X[k]*val-X[k]-val;
        //M[i+j*m]=X[k];
    }   
}