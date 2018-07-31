#include "gmm.hh"
#include "timer.hh"
#include "Threadpool/Threadpool.hpp"
#include "util.hh"
#include "mode.hh"
#include "inverse.hh"

#include <cassert>
#include <fstream>
#include <limits>


using namespace std;
using namespace ThreadLib;

static const real_t SQRT_2_PI = 2.5066282746310002;
static const real_t PI = 3.1415926535897932;

#include "fastexp.hh"

#define array_exp remez5_0_log2_sse

#define dprintf(fmt, ...) \
	printf(fmt, ##__VA_ARGS__);



static const real_t EPS = 2.2204460492503131e-16;

static real_t safe_log(real_t x) {
	if (x <= 0)
		x = 1e-15;
	return log(x);
}



real_t cov_skin[4][3][3] = {{{0.0890,0.0098,0.0227},
                        {0.0098,0.0712,-0.0270},
                        {0.0227,-0.0270,0.0869}}, 
                    {{0.0005,0.0010,0.0001},
                        {0.0010,0.0155,-0.0106},
                        {0.0001,-0.0106,0.0405}}, 
                    {{0.0008,-0.0030,0.0015},
                        {-0.0030,0.0457,-0.0210},
                        {0.0015,-0.0210,0.0520}},
                    {{0.0004,0.0007,0.0001},
                        {0.0007,0.0172,-0.0113},
                        {0.0001,-0.0113,0.0347}}};


//input vector x; x is n dim vector
real_t Gaussian::log_probability_of(std::vector<real_t> &x) {
	assert((int)x.size() == dim);

	real_t prob = 0;
	switch (covariance_type) {
		case COVTYPE_SPHERICAL:
			throw "COVTYPE_SPHERICAL not implemented";
			break;
		case COVTYPE_DIAGONAL:
			for (int i = 0; i < dim; i ++) {
				real_t &s = sigma[i];
				real_t s2 = s * s;
				real_t d = (x[i] - mean[i]);
				prob += -safe_log(SQRT_2_PI * s) - 1.0 / (2 * s2) * d * d;
			}
			break;
        //to be implemented
		case COVTYPE_FULL:

            real_t D = determinantOfMatrix(covariance , dim);
            vector<vector<real_t> > inv = inverse(covariance);
			//for i in numcom 
			real_t M = -0.5*safe_log(2*PI*D) ;
			for (int i = 0; i < dim; i ++) {
				real_t* cov = covariance[i];
				
			}
            
			break;
	}
	return prob;


}


//input vector x and a buffer
real_t Gaussian::probability_of_fast_exp(std::vector<real_t> &x, double *buffer) {
	assert((int)x.size() == dim);

	real_t prob = 1.0;
	switch (covariance_type) {
		case COVTYPE_SPHERICAL:
			throw "COVTYPE_SPHERICAL not implemented";
			break;
		case COVTYPE_DIAGONAL:
			assert(buffer != NULL);
			for (int i = 0; i < dim; i ++) {
				real_t &s = sigma[i];
				real_t d = x[i] - mean[i];
				buffer[i] = - d * d / (2 * s * s);
			}
			array_exp(buffer, fast_gaussian_dim);
			for (int i = 0; i < dim; i ++) {
				real_t p = buffer[i] / (SQRT_2_PI * sigma[i]);
				prob *= p;
			}
			break;
		case COVTYPE_FULL:
			throw "COVTYPE_FULL not implemented";
			break;
	}
	return prob;
}

//
//
//

GMM::GMM(int nr_mixtures, int covariance_type) :
	nr_mixtures(nr_mixtures),
	covariance_type(covariance_type) {

	
}

GMM::~GMM() {
	for (auto &g: gaussians)
		delete g;
}

real_t GMM::log_probability_of(std::vector<real_t> &x) {
	real_t prob = 0;
	for (int i = 0; i < nr_mixtures; i ++) {
		prob += weights[i] * gaussians[i]->probability_of(x);
	}
	return safe_log(prob);
}

real_t GMM::log_probability_of_fast_exp(std::vector<real_t> &x, double *buffer) {

	real_t prob = 0;
	for (int i = 0; i < nr_mixtures; i ++) {
		prob += weights[i] * gaussians[i]->probability_of_fast_exp(x, buffer);
	}
	return safe_log(prob);
}

real_t GMM::probability_of(std::vector<real_t> &x) {
	real_t prob = 0;
	for (int i = 0; i < nr_mixtures; i ++) {
		prob *= weights[i] * gaussians[i]->probability_of(x);
	}
	return prob;
}

// input is 2d vector 
real_t GMM::log_probability_of(std::vector<std::vector<real_t>> &X) {
	real_t prob = 0;
	for (auto &x: X)
		prob += log_probability_of(x);
	return prob;
}

real_t GMM::log_probability_of_fast_exp(std::vector<std::vector<real_t>> &X, double *buffer) {
	assert(buffer != NULL);
	real_t prob = 0;
	for (auto &x: X)
		prob += log_probability_of_fast_exp(x, buffer);
	return prob;
}

//using threadpool
static void threaded_log_probability_of(GMM *gmm, std::vector<std::vector<real_t>> &X, std::vector<real_t> &prob_buffer, int concurrency) {
	int n = (int)X.size();
	prob_buffer.resize(n);
	int batch_size = (int)ceil(n / (real_t)concurrency);

	int nr_batch = (int)ceil(n / (double)batch_size) ;
	double **buffers = new double *[nr_batch];
	for (int i = 0; i < nr_batch; i ++)
		buffers[i] = new double[gmm->gaussians[0]->fast_gaussian_dim];

	{
		Threadpool pool(concurrency);

		for (int i = 0, id = 0; i < n; i += batch_size, id ++) {
			auto task = [&](int begin, int end, double *buffer){
				for (int j = begin; j < end; j ++) {
					prob_buffer[j] = gmm->log_probability_of_fast_exp(X[j], buffer);
				}
			};
			pool.enqueue(bind(task, i, min(i + batch_size, n), buffers[id]), 1);
		}

	}

	for (int i = 0; i < nr_batch; i ++)
		delete [] buffers[i];
	delete [] buffers;
}

static real_t threaded_log_probability_of(GMM *gmm, std::vector<std::vector<real_t>> &X, int concurrency) {
	std::vector<real_t> prob_buffer;
	threaded_log_probability_of(gmm, X, prob_buffer, concurrency);
	real_t prob = 0;
	for (auto &p: prob_buffer)
		prob += p;
	return prob;
}

real_t GMM::log_probability_of_fast_exp_threaded(std::vector<std::vector<real_t>> &X, int concurrency) {
	return threaded_log_probability_of(this, X, concurrency);
}

void GMM::log_probability_of_fast_exp_threaded(
		std::vector<std::vector<real_t>> &X, std::vector<real_t> &prob_out, int concurrency) {
	threaded_log_probability_of(this, X, prob_out, concurrency);
}




