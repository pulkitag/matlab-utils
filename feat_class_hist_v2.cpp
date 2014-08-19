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
		const float* dWts, const uint32* clId, int sz, int numIm, int sqSz, float* imTemp){
  //Is im2 to the 1st quadrant of im1 or not. 
  int offset = numIm;
   //uint32 imTemp[sqSz];
  //uint32* imTemp;
  //imTemp = (uint32*) malloc(sqSz*sizeof(uint32));
  for (int n=0; n<numIm; n++){
	int stIdx = n;
	//Find the furthest points in im2.
	int rlim = sz;
	int clim = 0;
	int count = 0;
	int lastCount = 0;
	int numSig = 0;
	memset(imTemp,0,sqSz*sizeof(float));
	//for (int j=0;j<sqSz;j++)
	//	imTemp[j] = 0;

	for (int r=0; r<sz; r++){
		lastCount = count;
		for (int c=0; c<sz; c++){
			if (r >= rlim && c <clim){
				imTemp[count] = 1;
				numSig = numSig + 1;
			}
			else{
				//Something Present in im2
			   //std::cout<< "L1"  <<std::endl;
				if (im2[stIdx + count*offset] >0){
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

   /*   
   std::cout<< "imTemp Formed"  <<std::endl;
   uint32 blah = sTokens[n];
   std::cout<< "Here 0"  <<std::endl;
   float blah1 = im1[stIdx + (sqSz-1)*offset];
   std::cout<<"Here 1" <<std::endl;
   bool aa = blah1 > 0;
   std::cout<<"Here 2" <<std::endl; 
   sTokens[n] = 0;
   std::cout<< "Blah is fine " << blah << std::endl;
	*/
   //Now parse the first im
   //imTemp creates a map, st. if it is >0 at a certain location and this coincides with im1 being high then im2 has atleast one element in quarter 1 wrt im1. 
   if (numSig > 0){
	   for (int i=0;i<sqSz;i++){
			if (imTemp[i] > 0 && im1[stIdx + i*offset] >0){
				sTokens[n] = 1; break;
			}
		}
	}else{
		sTokens[n] = 0;
	}

   //std::cout<< "Forming Histograms"  <<std::endl;
	int h = clId[n]-1; //-1 to account for the fact that class labels are from 1 to n
	if (sTokens[n] >0){
		histRight[h] += dWts[n];
	}else{
		histLeft[h]  += dWts[n]; 
	}
  }

  //free(imTemp);
}


void find_q2(const float* im1, const float* im2, uint32* sTokens, float* histLeft, float* histRight,
		const float* dWts, const uint32* clId, int sz, int numIm, int sqSz, float* imTemp){
//COde for quadrants 2: Is im2 to the 2nd quadrant of im1 or not ?
 // (POints which are exacly vertical will be considered 2-4 quadrant relationship). 
	 //std::cout<<"Type 2 or 4"<<std::endl;
	 int offset = numIm; 
	 //uint32* imTemp;
	 //imTemp = (uint32*) malloc(sqSz*sizeof(uint32));
	 //uint32 imTemp[sqSz];
	 for (int n=0; n<numIm; n++){
		int stIdx = n;
		//Fine the furthest points in im2.
		int rlim = sz;
		int clim = sz;
		int count = 0;
		int numSig = 0;
		memset(imTemp,0,sqSz*sizeof(float));
		//for (int j=0;j<sqSz;j++)
		//	imTemp[j] = 0;
	
		for (int r=0; r<sz; r++){
			for (int c=0; c<sz; c++){
				if (r > rlim && c >= clim){
					//Notice no equality in r,rlim is for a purpose
					imTemp[count] = 1;
					numSig = numSig + 1;
				}
				else{
					//Something Present in im2
					if (im2[stIdx + count*offset] >0){
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
					if (imTemp[i] > 0 && im1[stIdx + i*offset] >0){
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
	//free(imTemp);
}

void find_q5(const float* im1, const float* im2, uint32* sTokens, float* histLeft, float* histRight,
		const float* dWts, const uint32* clId, int sz, int numIm, int sqSz){
	//Finds if im1 and im2 are same anywhere. 
	int offset = numIm;
	for (int n=0; n<numIm; n++){
		int count = 0;
		int stIdx = n;
		sTokens[n] = 0;
		for (int r=0; r<sz; r++){
			for (int c=0; c<sz; c++){
				if (im1[stIdx + count*offset]>0 && im2[stIdx + count*offset]>0){
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

void find_q6(const float* im1, uint32* sTokens, float* histLeft, float* histRight, const float* dWts, const uint32* clId, int sz, int numIm, int sqSz){
	//Finds if im1 has a certain filter active or not
	int offset = numIm;
	for (int n=0; n<numIm; n++){
		int count = 0;
		int stIdx = n;
		sTokens[n] = 0;
		for (int r=0; r<sz; r++){
			for (int c=0; c<sz; c++){
				if (im1[stIdx + count*offset]>0){
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
  float *data, *dWts, *histLeft, *histRight, *im1, *im2, *imTemp;
  int numIm,sqSz,sz;
  int nQ,nThreads,numCl,nf;
  int *dims;
  uint32* qns, *debTokens, *clId, *sTokens; 
  
 

  //std::cout<<"Entering Here"<<std::endl;

  if (nrhs < 7){
	 mexErrMsgTxt("Atleast 7 input arguments required:	[histLeft,histRight,isFeat] = feat_class_hist(data,nf,sz,qns,dWts,clId,numCl,nThread)");
  }

  // data: N*featDims
  // qType: type of question
  // dWts: Weights of data points
  //  clId: classIds of dataPOints
  // numCl: number of classes

  
  //std::cout<<"Entering"<<std::endl;
  if (mxGetClassID(prhs[0])!=mxSINGLE_CLASS)
	 mexErrMsgTxt("data must be of type single");
  if (mxGetClassID(prhs[4])!=mxSINGLE_CLASS)
	 mexErrMsgTxt("dWts must be of type single");
  if (mxGetClassID(prhs[5])!=mxUINT32_CLASS)
	 mexErrMsgTxt("clId must be of type uint32");
  if (mxGetNumberOfDimensions(prhs[0])!=2)
	 mexErrMsgTxt("2 dimensional im1 is expected");
 
  data  = (float *) mxGetData(prhs[0]);
  nf    = (int)     mxGetScalar(prhs[1]);
  sz    = (int)     mxGetScalar(prhs[2]);
  qns   = (uint32 *)mxGetData(prhs[3]); //qns to ask
  dWts  = (float *) mxGetData(prhs[4]);
  clId  = (uint32 *)mxGetData(prhs[5]);
  numCl = (int) mxGetScalar(prhs[6]);
  nThreads = (nrhs<8) ? 100000 : (int) mxGetScalar(prhs[7]);
  nThreads = min(nThreads,omp_get_max_threads());


  //std::cout<<"Location 1"<<std::endl;
  
  
  //mexPrintf("Location 1 \n"); 
  sqSz  = sz*sz;
  dims  = (int *) mxGetDimensions(prhs[0]);
  numIm = (int) dims[0];
  if (nf*sqSz != dims[1])
	mexErrMsgTxt("data size mismatch");

  if (mxGetM(prhs[4])!=numIm)
	mexErrMsgTxt("dWts dimensions mismatch");
  if (mxGetM(prhs[5])!=numIm)
	mexErrMsgTxt("clId dimensions mismatch");

  //std::cout<<"Location 2"<<std::endl;
 
 //number of questions to ask
  nQ = mxGetM(prhs[3]);
  if (mxGetN(prhs[3])!=3)
	mexErrMsgTxt("Unrecognized qns");
	
  //std::cout<<"nf: "<<nf<<" sqSz: "<<sqSz<<" nQ: "<<nQ<<" numIm: "<<numIm<<std::endl;

  
  plhs[0] = mxCreateNumericMatrix(numCl,nQ,mxSINGLE_CLASS,mxREAL);
  plhs[1] = mxCreateNumericMatrix(numCl,nQ,mxSINGLE_CLASS,mxREAL);
  plhs[2] = mxCreateNumericMatrix(numIm,nQ,mxUINT32_CLASS,mxREAL);
  imTemp  =(float *) mxGetPr(mxCreateNumericMatrix(sqSz,numIm,mxUINT32_CLASS,mxREAL));
 
  histLeft   = (float *)  mxGetPr(plhs[0]);
  histRight  = (float *)  mxGetPr(plhs[1]);
  sTokens   = (uint32 *) mxGetPr(plhs[2]);
  //debTokens = (uint32 *) mxGetPr(plhs[3]);
  
  int f1,f2,qType;
  #pragma omp parallel for num_threads(nThreads)
  for (int n=0; n<nQ; n++){
	  //std::cout <<" Entering Loop" <<std::endl;
	  f1        = qns[n]-1;
	  f2        = qns[nQ + n]-1;
	  qType     = qns[2*nQ + n];
	  if (qType <0 || qType > 6)
		mexErrMsgTxt("Unrecognized qType");

	  im1 = &(data[f1*sqSz*numIm]);
	  im2 = &(data[f2*sqSz*numIm]);

	  //std::cout<<"n: " <<n<<" f1: "<<f1<<" f2: "<<f2<<" qType: "<<qType<<std::endl;
    
	  if (qType==1)
		find_q1(im1, im2, sTokens,histLeft,histRight,dWts,clId,sz,numIm,sqSz,imTemp);
	  if (qType==3)
		find_q1(im2, im1, sTokens,histLeft,histRight,dWts,clId,sz,numIm,sqSz,imTemp);
	 
	 if (qType ==2)
		find_q2(im1, im2, sTokens,histLeft,histRight,dWts,clId,sz,numIm,sqSz,imTemp);
	 if (qType ==4)
		find_q2(im2, im1, sTokens,histLeft,histRight,dWts,clId,sz,numIm,sqSz,imTemp);
	 
     if (qType ==5)
		find_q5(im1, im2, sTokens,histLeft,histRight,dWts,clId,sz,numIm,sqSz);
	
     if (qType ==6)
		find_q6(im1, sTokens,histLeft,histRight,dWts,clId,sz,numIm,sqSz);

	 histLeft  += numCl;
	 histRight += numCl;
	 sTokens   += numIm;
  }
 
}
