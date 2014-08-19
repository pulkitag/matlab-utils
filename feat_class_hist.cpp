#include <mex.h>
#include <omp.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <iostream>

typedef unsigned char uint8;
typedef unsigned int uint32;
#define min(x,y) ((x) < (y) ? (x) : (y))

/*
//im1: sqSz*numIm is a feature map of sz*sz*numIm, similar for im2
// Inspired by the Amit and Geman Paper - the question we ask is how many of im1,im2 satisfy the question of type qtype
 CUrrently, qtype is constrained to the presence of non-zero value in 4 quadrants. 
 qType: 1 - quadrant 1 and so on.
 im1, im2 are in rowMajor format. so if im1 is 36*100 it means there are 100 instances and 6*6 when accessed serially - will read rows.
*/

//find_q1(im1, im2, sTokens,histLeft,histRight,dWts,clId,sz,numIm,sqSz);
void find_q1(const float* im1, const float* im2, uint32* sTokens, float* histLeft, float* histRight,
		const float* dWts, const uint32* clId, int sz, int numIm, int sqSz){
  //Is im2 to the 1st quadrant of im1 or not. 
 #pragma omp parallel for num_threads(nThreads)
  for (int n=0; n<numIm; n++){
	int stIdx = n*sqSz;
	//Find the furthest points in im2.
	int rlim = sz;
	int clim = 0;
	int count = 0;
	int lastCount = 0;
	int numSig = 0;
	uint32 imTemp[sqSz];
	memset(imTemp,0,sqSz*sizeof(uint32));
	for (int r=0; r<sz; r++){
		lastCount = count;
		for (int c=0; c<sz; c++){
			if (r >= rlim && c <clim){
				imTemp[count] = 1;
				numSig = numSig + 1;
			}
			else{
				//Something Present in im2
				if (im2[stIdx + count] >0){
					if (c > clim) {clim = c;}
					if (r <= rlim){rlim = r;}
					for (int i=lastCount;i<count;i++){
						imTemp[i] = 1;
						numSig = numSig + 1;
						//std::cout<<"n is "<<n<<std::endl;
					}
					lastCount = count;
				}
			}
			count = count + 1;
		}
	}
   
   //Now parse the first im
   //imTemp creates a map, st. if it is >0 at a certain location and this coincides with im1 being high then im2 has atleast one element in quarter 1 wrt im1. 
   if (numSig > 0){
	   for (int i=0;i<sqSz;i++){
			if (imTemp[i] > 0 && im1[stIdx + i] >0){
				sTokens[n] = 1; break;
			}
		}
	}else{
		sTokens[n] = 0;
	}

	int h = clId[n]-1; //-1 to account for the fact that class labels are from 1 to n
	if (sTokens[n] >0){
		histRight[h] += dWts[n];
	}else{
		histLeft[h]  += dWts[n]; 
	}
  }
}


void find_q2(const float* im1, const float* im2, uint32* sTokens, float* histLeft, float* histRight,
		const float* dWts, const uint32* clId, int sz, int numIm, int sqSz){
//COde for quadrants 2: Is im2 to the 2nd quadrant of im1 or not ?
 // (POints which are exacly vertical will be considered 2-4 quadrant relationship). 
	 //std::cout<<"Type 2 or 4"<<std::endl;
	  #pragma omp parallel for num_threads(nThreads)
	  for (int n=0; n<numIm; n++){
		int stIdx = n*sqSz;
		//Fine the furthest points in im2.
		int rlim = sz;
		int clim = sz;
		int count = 0;
		int numSig = 0;
		uint32 imTemp[sqSz];
		memset(imTemp,0,sqSz*sizeof(uint32));
		for (int r=0; r<sz; r++){
			for (int c=0; c<sz; c++){
				if (r > rlim && c >= clim){
					//Notice no equality in r,rlim is for a purpose
					imTemp[count] = 1;
					numSig = numSig + 1;
				}
				else{
					//Something Present in im2
					if (im2[stIdx + count] >0){
						if (c <= clim) {
							if (r > rlim){
								for (int i=clim;i<sz;i++){
									imTemp[i + r*sz] = 1;
									numSig = numSig + 1;
								}
							}
							clim = c; rlim=r;
						}
					}
				}
				count = count + 1;
			}
		}

		   //Now parse the first im
		   //imTemp creates a map, st. if it is >0 at a certain location and this coincides with im1 being high then im2 has atleast one element in quarter 1 wrt im1. 
		   if (numSig >0 ){
			   for (int i=0;i<sqSz;i++){
					if (imTemp[i] > 0 && im1[stIdx + i] >0){
						sTokens[n] = 1; break;
					}
				}
			}else{
				sTokens[n] = 0;
			}
			//Update Histogram
			int h = clId[n]-1; //-1 to account for the fact that class labels are from 1 to n
			if (sTokens[n] >0){
				histRight[h] += dWts[n];
			}else{
				histLeft[h]  += dWts[n]; 
			}
		}
}

void find_q5(const float* im1, const float* im2, uint32* sTokens, float* histLeft, float* histRight,
		const float* dWts, const uint32* clId, int sz, int numIm, int sqSz){
	//Finds if im1 and im2 are same anywhere. 
	#pragma omp parallel for num_threads(nThreads)
	for (int n=0; n<numIm; n++){
		int count = 0;
		int stIdx = n*sqSz;
		sTokens[n] = 0;
		for (int r=0; r<sz; r++){
			for (int c=0; c<sz; c++){
				if (im1[stIdx + count]>0 && im2[stIdx + count]>0){
					sTokens[n] = 1;
					break;
				}
				count = count + 1;
			}
		}
		int h = clId[n]-1; //-1 to account for the fact that class labels are from 1 to n
		if (sTokens[n] >0){
			histRight[h] += dWts[n];
		}else{
			histLeft[h]  += dWts[n]; 
		}
	}
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){ 
  float *im1, *im2, *dWts, *histLeft, *histRight;
  int numIm,sqSz,sz;
  int qType,nThreads,numCl;
  int *dims1, *dims2;
  uint32* sTokens, *debTokens, *clId; 
 

  if (nrhs < 3){
	 mexErrMsgTxt("Atleast 6 input arguments required:	[histLeft,histRight,isFeat] = feat_class_hist(im1,im2,qType,dWts,clId,numCl,nThread)");
  }

  //im1, im2: Feature Maps: featDim*numData
  // qType: type of question
  // dWts: Weights of data points
  //  clId: classIds of dataPOints
  // numCl: number of classes

  if (mxGetClassID(prhs[0])!=mxSINGLE_CLASS)
	 mexErrMsgTxt("im1 must be of type single");
  if (mxGetClassID(prhs[1])!=mxSINGLE_CLASS)
	 mexErrMsgTxt("im2 must be of type single");
  if (mxGetClassID(prhs[3])!=mxSINGLE_CLASS)
	 mexErrMsgTxt("dWts must be of type single");
  if (mxGetClassID(prhs[4])!=mxUINT32_CLASS)
	 mexErrMsgTxt("clId must be of type uint32");
  if (mxGetNumberOfDimensions(prhs[0])!=2)
	 mexErrMsgTxt("2 dimensional im1 is expected");
  if (mxGetNumberOfDimensions(prhs[1])!=2)
	 mexErrMsgTxt("2 dimensional im2 is expected");
  
  qType = (int) mxGetScalar(prhs[2]);
  dWts  = (float *)mxGetData(prhs[3]);
  clId  = (uint32 *)mxGetData(prhs[4]);
  numCl = (int) mxGetScalar(prhs[5]);

  if (qType==1 || qType==2 || qType==5){
	  im1   = (float *) mxGetData(prhs[0]);
	  im2   = (float *) mxGetData(prhs[1]);
  }else if(qType==3 || qType==4){
	  im2   = (float *) mxGetData(prhs[0]);
	  im1   = (float *) mxGetData(prhs[1]);
  }else{
	 mexErrMsgTxt("qType should be between 1-5");
  }

  nThreads = (nrhs<7) ? 100000 : (int) mxGetScalar(prhs[6]);
  nThreads = min(nThreads,omp_get_max_threads());
 
  //mexPrintf("Location 1 \n"); 
  dims1 = (int *) mxGetDimensions(prhs[0]);
  sqSz  = (int) dims1[0];
  numIm = (int) dims1[1];
  sz    = (int) sqrt(sqSz);
  if (sz*sz != sqSz)
	mexErrMsgTxt("Square Images are expected"); 

  dims2 = (int *) mxGetDimensions(prhs[1]);
  if (dims2[0] != sqSz || dims2[1] != numIm)
	mexErrMsgTxt("im1 and im2 have different sizes"); 

  plhs[0] = mxCreateNumericMatrix(numCl,1,mxSINGLE_CLASS,mxREAL);
  plhs[1] = mxCreateNumericMatrix(numCl,1,mxSINGLE_CLASS,mxREAL);
  plhs[2] = mxCreateNumericMatrix(1,numIm,mxUINT32_CLASS,mxREAL);
  //plhs[3] = mxCreateNumericMatrix(sqSz,numIm,mxUINT32_CLASS,mxREAL);
 
  histLeft   = (float *)  mxGetPr(plhs[0]);
  histRight  = (float *)  mxGetPr(plhs[1]);
  sTokens   = (uint32 *) mxGetPr(plhs[2]);
  //debTokens = (uint32 *) mxGetPr(plhs[3]);

  if (qType==1 || qType==3)
	find_q1(im1, im2, sTokens,histLeft,histRight,dWts,clId,sz,numIm,sqSz);
	  
  if (qType ==2 || qType==4)
	find_q2(im1, im2, sTokens,histLeft,histRight,dWts,clId,sz,numIm,sqSz);

  if (qType ==5)
	find_q5(im1, im2, sTokens,histLeft,histRight,dWts,clId,sz,numIm,sqSz);

}
