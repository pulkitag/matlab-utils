#include <mex.h>
#include <omp.h>
#include <math.h>
#include <stdint.h>

typedef unsigned char uint8;
typedef unsigned int uint32;
#define min(x,y) ((x) < (y) ? (x) : (y))

// inds=mexFunction(data,thrs,fids,child,[nThreads])
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  /*
	Extract patches at given locations
  */
  int nr,nc,nd,nThreads,sz,stepSz;
  float *im;
  float *patches;
  int *dims, *eLocDims;
  uint32 *eLoc;
  int64_t maxNum,outDim,numPatches;

  //If mexError is encountered - is probably due to overflow of maxNum - check for it.
  if (nrhs < 3)
	 mexErrMsgTxt("Atleast 3 input arguments needed. patches = extract_patches(im,loc,patchSz,nThread)");

  if (mxGetClassID(prhs[0])!=mxSINGLE_CLASS)
	 mexErrMsgTxt("Image must be of type single");

  if (mxGetClassID(prhs[1])!=mxUINT32_CLASS)
	 mexErrMsgTxt("Locations must be of type uint32");
  
  if (mxGetNumberOfDimensions(prhs[0])!=3)
	 mexErrMsgTxt("3 dimensional array is expected");
  
  im   = (float *) mxGetData(prhs[0]);
  eLoc = (uint32 *)mxGetData(prhs[1]); //extratct Locations 2*numPatches
  sz   = (int) mxGetScalar(prhs[2]);
  nThreads = (nrhs<4) ? 100000 : (int) mxGetScalar(prhs[3]);
  nThreads = min(nThreads,omp_get_max_threads());
 
  //mexPrintf("Location 1 \n"); 
  dims       = (int *) mxGetDimensions(prhs[0]);
  eLocDims   = (int *) mxGetDimensions(prhs[1]);
  numPatches = (int)   eLocDims[1]; 
  nr = (int) mxGetM(prhs[0]);
  nc = (int) dims[1];
  nd = (int) dims[2];
  outDim = sz*sz*nd;

  if (eLocDims[0] != 2)
	 mexErrMsgTxt("Locations should be of dimensions 2*N");
 
  if (sz % 2==0)
	mexErrMsgTxt("Patch Size must be an odd number");
  if (sz > nr || sz > nc)
	mexErrMsgTxt("Patch Size should not be bigger than img dims");
 

  //mexPrintf("Location 2 \n");

  for (int i=0; i<numPatches; i++){
	 if(eLoc[i*2 +1] + sz -1 >= nr || eLoc[i*2] + sz-1 >= nc)
		mexErrMsgTxt("Given locations exceed image dimensions");
  } 
  //mexPrintf("Max: (rSt,rEn): (%d,%d) \n",rSt[rNum-1],rEn[rNum-1]);
  
  plhs[0] = mxCreateNumericMatrix(outDim,numPatches,mxSINGLE_CLASS,mxREAL);
  patches = (float *) mxGetPr(plhs[0]); // Store the patches
  maxNum = outDim*numPatches - 1;

  //mexPrintf("Location 4 \n");
  int count = 0;
  int patchCount = 0;
  int row,col;
  #pragma omp parallel for num_threads(nThreads)
  for (int n=0; n<numPatches; n++){
	count = 0;
	for (int d=0; d<nd; d++){
		row = eLoc[2*n] - 1; //Matlab to C++ Convention therefore -1
		col = eLoc[2*n + 1] - 1;
		for (int i=0; i<sz; i++){
			for (int j=0; j<sz; j++){
				patches[count + outDim*patchCount] = im[col*nr + row + j + d*nr*nc];
				count = count + 1;
			}
			col = col + 1;
		}
	}
	patchCount = patchCount + 1;
  }
 
}
