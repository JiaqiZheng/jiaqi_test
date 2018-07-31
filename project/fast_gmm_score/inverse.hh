#include "type.hh"
#include <vector>

using namespace std;
#define N 3

void getCofactor(real_t A[N][N], real_t temp[N][N], int p, int q, int n);
real_t determinant(real_t A[N][N], real_t n);
void adjoint(real_t A[N][N],real_t adj[N][N]);
vector<vector<real_t>> inverse(real_t A[N][N])


