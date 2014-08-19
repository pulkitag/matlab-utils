#include <mex.h>
#include <omp.h>
#include <math.h>

typedef unsigned char uint8;
typedef unsigned int uint32;
#define min(x,y) ((x) < (y) ? (x) : (y))

// inds=mexFunction(data,thrs,fids,child,[nThreads])
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  int nr,nc,nThreads,sz,stepSz,outDim;
  int b,rNum,cNum,numPatches;
  float *im;
  float *patches;
  uint32 *loc;

  if (mxGetClassID(prhs[0])!=mxSINGLE_CLASS)
	 mexErrMsgTxt("Image must be of type single");
  
  im = (float *) mxGetData(prhs[0]);
  sz = (int) mxGetScalar(prhs[1]);
  stepSz = (int) mxGetScalar(prhs[2]);
  nThreads = (nrhs<6) ? 100000 : (int) mxGetScalar(prhs[3]);
  nThreads = min(nThreads,omp_get_max_threads());
 
  //mexPrintf("Location 1 \n"); 
  nr = (int) mxGetM(prhs[0]);
  nc = (int) mxGetN(prhs[0]);
  outDim = sz*sz;
 
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

  for (int i=0; i<cNum; i++){
	cSt[i] =  i*stepSz;
	cEn[i] = cSt[i] + sz - 1;
	//mexPrintf("(cSt,cEn): (%d,%d) \n",cSt[i],cEn[i]);
  } 

  //mexPrintf("Location 3 \n");	
  plhs[0] = mxCreateNumericMatrix(outDim,numPatches,mxSINGLE_CLASS,mxREAL);
  plhs[1] = mxCreateNumericMatrix(2,numPatches,mxUINT32_CLASS,mxREAL);
  patches = (float *) mxGetPr(plhs[0]); // Store the patches
  loc = (uint32 *) mxGetPr(plhs[1]);

  //mexPrintf("Location 4 \n");
  int count = 0;
  int patchCount = 0;
  int col;
  #pragma omp parallel for num_threads(nThreads)
  for (int c=0; c<cNum; c++){
	for (int r=0; r<rNum; r++){
		count = 0;
		col = cSt[c];	
		loc[patchCount*2] = rSt[r] + b + 1; //+1 for matlab indexing
		loc[patchCount*2+1] = cSt[c] + b +1;
		for (int i=0; i<sz; i++){
			for (int j=0; j<sz; j++){
				patches[count + outDim*patchCount] = im[col*nr + rSt[r] + j];
				count = count + 1;
			}
			col = col + 1;
		}
		//mexPrintf("\n");
		patchCount = patchCount + 1;
	}
  }
 
}
