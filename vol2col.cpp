#include <mex.h>
#include <omp.h>
#include <math.h>
#include <stdint.h>

typedef unsigned char uint8;
typedef unsigned int uint32;
#define min(x,y) ((x) < (y) ? (x) : (y))

// inds=mexFunction(data,thrs,fids,child,[nThreads])
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  int nr,nc,nd,nThreads,sz,stepSz;
  int b,rNum,cNum;
  float *im;
  float *patches;
  int *dims;
  uint32 *loc;
  int64_t maxNum,outDim,numPatches;

  //If mexError is encountered - is probably due to overflow of maxNum - check for it.
  if (nrhs < 3)
	 mexErrMsgTxt("Atleast 3 input arguments required. patches = vol2col(im,patchSz,stepSz,nThread)");

  if (mxGetClassID(prhs[0])!=mxSINGLE_CLASS)
	 mexErrMsgTxt("Image must be of type single");

  if (mxGetNumberOfDimensions(prhs[0])!=3)
	 mexErrMsgTxt("3 dimensional array is expected");
  
  im = (float *) mxGetData(prhs[0]);
  sz = (int) mxGetScalar(prhs[1]);
  stepSz = (int) mxGetScalar(prhs[2]);
  nThreads = (nrhs<4) ? 100000 : (int) mxGetScalar(prhs[3]);
  nThreads = min(nThreads,omp_get_max_threads());
 
  //mexPrintf("Location 1 \n"); 
  dims = (int *) mxGetDimensions(prhs[0]);
  nr = (int) mxGetM(prhs[0]);
  nc = (int) dims[1];
  nd = (int) dims[2];
  outDim = sz*sz*nd;
  //mexPrintf("Size is (%d,%d,%d) and outDim is %d \n",nr,nc,nd,outDim);
 
  if (sz % 2==0)
	mexErrMsgTxt("Patch Size must be an odd number");
  if (sz > nr || sz > nc)
	mexErrMsgTxt("Patch Size should not be bigger than img dims");
 
  b = (sz-1)/2;
  rNum = (int) (floor(float(nr-1 -2*b)/float(stepSz)) + 1);
  cNum = (int) (floor(float(nc-1 -2*b)/float(stepSz)) + 1);
  numPatches = rNum*cNum;

  //mexPrintf("Location 2 \n");
  int rSt[rNum],rEn[rNum],cSt[cNum],cEn[cNum];

  for (int i=0; i<rNum; i++){
	rSt[i] = i*stepSz;
	rEn[i] = rSt[i] + sz -1;
	//mexPrintf("(rSt,rEn): (%d,%d) \n",rSt[i],rEn[i]);
  } 
  //mexPrintf("Max: (rSt,rEn): (%d,%d) \n",rSt[rNum-1],rEn[rNum-1]);
  
 for (int i=0; i<cNum; i++){
	cSt[i] =  i*stepSz;
	cEn[i] = cSt[i] + sz - 1;
	//mexPrintf("(cSt,cEn): (%d,%d) \n",cSt[i],cEn[i]);
  } 
  //mexPrintf("Max: (cSt,cEn): (%d,%d) \n",cSt[cNum-1],cEn[cNum-1]);
  
  //mexPrintf("Location 3 \n");	
  plhs[0] = mxCreateNumericMatrix(outDim,numPatches,mxSINGLE_CLASS,mxREAL);
  plhs[1] = mxCreateNumericMatrix(2,numPatches,mxUINT32_CLASS,mxREAL);
  patches = (float *) mxGetPr(plhs[0]); // Store the patches
  loc = (uint32 *) mxGetPr(plhs[1]);
  maxNum = outDim*numPatches - 1;

  //mexPrintf("Location 4 \n");
  int count = 0;
  int patchCount = 0;
  int col;
  #pragma omp parallel for num_threads(nThreads)
  for (int c=0; c<cNum; c++){
	for (int r=0; r<rNum; r++){
		count = 0;
		loc[patchCount*2] = rSt[r] + b + 1; //+1 for matlab indexing
		loc[patchCount*2+1] = cSt[c] + b +1;
		for (int d=0; d<nd; d++){
			col = cSt[c];	
			for (int i=0; i<sz; i++){
				for (int j=0; j<sz; j++){
					patches[count + outDim*patchCount] = im[col*nr + rSt[r] + j + d*nr*nc];
					count = count + 1;
				}
				col = col + 1;
			}
		}
		patchCount = patchCount + 1;
	}
  }
 
}
