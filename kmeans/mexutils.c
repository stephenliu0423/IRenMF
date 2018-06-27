/* file:        mexutils.c 
** author:      Andrea Vedaldi
** description: Utility functions to write MEX files.
**/

/* AUTORIGHTS
Copyright (C) 2006 Regents of the University of California
All rights reserved

Written by Andrea Vedaldi (UCLA VisionLab).

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the University of California, Berkeley nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include"mex.h"

#undef M_PI
#define M_PI 3.14159265358979


/** @biref Is real?
 **
 ** @return @c true if the array @a A is real (and double).
 **/
int
uIsReal(const mxArray* A)
{
  return 
    mxIsDouble(A) && 
    !mxIsComplex(A) ;
}

/** @biref Is real scalar?
 **
 ** @return @c true if the array @a A is a real (and double) scalar.
 **/
int
uIsRealScalar(const mxArray* A)
{
  return 
    mxIsDouble(A) && 
    !mxIsComplex(A) &&
    mxGetNumberOfDimensions(A) == 2 &&
    mxGetM(A) == 1 &&
    mxGetN(A) == 1 ;
}

/** @brief Is real matrix?
 **
 ** The function checks wether the argument @a A is a real (and double)
 ** matrix.  In addition, if @a M >= 0, it checks wether the number of
 ** rows is equal to @a M and, if @a N >= 0, if the number of columns
 ** is equal to @a N.
 **
 ** @param M number of rows.
 ** @param N number of columns.
 ** @return @c true if the array is a real matrix with the specified format.
 **/
int
uIsRealMatrix(const mxArray* A, int M, int N)
{
  return  
    mxIsDouble(A) &&
    !mxIsComplex(A) &&
    mxGetNumberOfDimensions(A) == 2 &&
    ((M>=0)?(mxGetM(A) == M):1) &&
    ((N>=0)?(mxGetN(A) == N):1) ;   
}


/** @brief Is real array?
 **
 ** The function checks wether the argument @a A is a real (and double)
 ** array.  If @a D >= 0, it also checks wether the arrays a @a D
 ** dimensions. If @a D >=0 and a non null pointer @a dims is
 ** provided, it also check that all dimensions of the array are equal
 ** tao the corresponding non-negative entries of the C-array @a dims.
 **
 ** @param A array to check.
 ** @param D number of dimensions.
 ** @param dims dimensions.
 ** @return @c true if the array is real and has the specified sizes.
 **/
int
uIsRealArray(const mxArray* A, int D, const int* dims)
{
  if(!mxIsDouble(A) || mxIsComplex(A))
    return false ;

  if(D >= 0) {
    int d ;
    const int* actual_dims = mxGetDimensions(A) ;

    if(mxGetNumberOfDimensions(A) != D)
      return false ;

    return true  ;
    
    if(dims != NULL) {
      for(d = 0 ; d < D ; ++d) {
        if(dims[d] >= 0 && dims[d] != actual_dims[d])
          return false ;
      }
    }
  }
  return true ;
}

/** @brief Is real vector?
 **
 ** The function checks wether the argument @a V is a real (and
 ** double) vector. By definiton, a matrix is a vector if one of its
 ** dimension is one.  In addition, if @a D >= 0, it checks wether the
 ** dimension of the vecotr is equal to @a D.
 **
 ** @param D lenght of the vector.
 ** @return @c true if the array is a real vector of the specified dimension.
 **/
int
uIsRealVector(const mxArray* V, int D) 
{
  int M = mxGetM(V) ;
  int N = mxGetN(V) ;
  int is_vector = (N == 1) || (M == 1) ;
  
  return   
    mxIsDouble(V) &&
    !mxIsComplex(V) &&
    mxGetNumberOfDimensions(V) == 2 &&
    is_vector &&
    ( D < 0 || N == D || M == D) ;
}


/** @brief Is a string?
 **
 ** The function checks wether the array @a S is a string. If
 ** @a L is non-negative, it also check wether the strign has
 ** length @a L.
 **
 ** @return @a c true if S is a string of the specified length.
 **/
int
uIsString(const mxArray* S, int L)
{
  int M = mxGetM(S) ;
  int N = mxGetN(S) ;

  return 
    mxIsChar(S) &&
    M == 1 &&
    (L < 0 || N == L) ;
}
