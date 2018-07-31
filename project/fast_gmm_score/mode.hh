#include <stdio.h>
#include "type.hh"

#define N 3
void getCofactor(real_t mat[N][N], real_t temp[N][N], int p, int q, int n);

real_t determinantOfMatrix(real_t mat[N][N], int n);