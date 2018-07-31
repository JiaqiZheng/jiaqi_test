#pragma once

#include "type.hh"
#include "random.hh"

#include <iostream>
#include <string>
#include <vector>
#include <algorithm>


enum CovType {
	COVTYPE_SPHERICAL,
	COVTYPE_DIAGONAL,
	COVTYPE_FULL
};

class Gaussian {
	public:
		Gaussian(int dim, int covariance_type = COVTYPE_DIAGONAL);
        int N;
		int dim, covariance_type;
		std::vector<real_t> mean;
		std::vector<real_t> sigma;
		real_t covariance[3][3]; // not used

		real_t log_probability_of(std::vector<real_t> &x);
		real_t probability_of(std::vector<real_t> &x);
		real_t probability_of_fast_exp(std::vector<real_t> &x, double *buffer = NULL);

		// sample a point to @x
		void sample(std::vector<real_t> &x);
		std::vector<real_t> sample();

		void dump(std::ostream &out);
		void load(std::istream &in);

		Random random;
		int fast_gaussian_dim;
};

class GMM;

class GMM {
	public:
		GMM(int nr_mixtures, int covariance_type = COVTYPE_DIAGONAL);
		~GMM();

		

		int nr_mixtures;
		int covariance_type;

		int dim;
		

		std::vector<real_t> weights;
		std::vector<Gaussian *> gaussians;

		real_t log_probability_of(std::vector<real_t> &x);
		real_t log_probability_of(std::vector<std::vector<real_t>> &X);

		real_t log_probability_of_fast_exp(std::vector<real_t> &x, double *buffer = NULL);
		real_t log_probability_of_fast_exp(std::vector<std::vector<real_t>> &X, double *buffer = NULL);
		real_t log_probability_of_fast_exp_threaded(std::vector<std::vector<real_t>> &X, int concurrency);
		void log_probability_of_fast_exp_threaded(
				std::vector<std::vector<real_t>> &X, std::vector<real_t> &prob_out, int concurrency);


		real_t probability_of(std::vector<real_t> &x);

		void normalize_weights();

};
