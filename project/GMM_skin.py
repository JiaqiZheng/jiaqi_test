 #!/usr/bin/env python -W ignore::DeprecationWarning

import numpy as np
from numpy.linalg import inv

from sklearn import mixture

def GMM_skin(frames):
    weights_skin = np.array([0.0610708826839086,0.0477458488061264,0.215091364529589,0.676091903980376])
    mu_skin = np.array([[0.535391792606177,0.287666851340888,0.473649194170043], 
                [0.971309985597353,0.249481695472915,0.640397068785967],
                [0.0700645294019952,0.494162067985864,0.553904023280271],
                [0.0495348144268944,0.396304986215106,0.629909028483418]])
    sigma_skin = np.array([
                    [[0.0890,0.0098,0.0227],
                        [0.0098,0.0712,-0.0270],
                        [0.0227,-0.0270,0.0869]], 
                    [[0.0005,0.0010,0.0001],
                        [0.0010,0.0155,-0.0106],
                        [0.0001,-0.0106,0.0405]], 
                    [[0.0008,-0.0030,0.0015],
                        [-0.0030,0.0457,-0.0210],
                        [0.0015,-0.0210,0.0520]],
                    [[0.0004,0.0007,0.0001],
                        [0.0007,0.0172,-0.0113],
                        [0.0001,-0.0113,0.0347]]
                        ])
    #percisions=inv(sigma)
    gmix = mixture.GaussianMixture(n_components=4, covariance_type='full')
    #gmix.fit(np.random.rand(10, 3))  # Now it thinks it is trained
    #gmix.covariances_ = sigma  # mixture cov (n_components, 2, 2)
    gmix.precisions_cholesky_ = np.linalg.cholesky(np.linalg.inv(sigma)).transpose((0, 2, 1))
    #gmix.fit(np.random.rand(10, 3))  # Now it thinks it is trained
    gmix.weights_ = weights   # mixture weights
    gmix.means_ = mu          # mixture means 
    gmix.covariances_ = sigma  # mixture cov

    

    scores=np.array([])
    num_f=len(frames)
    #for i in range(r):
    #    for j in range(c):
    #        #print(i,j)
    #        score = gmix.score([frame[i][j]])
    #        scores=np.append(scores, score)
    #scores=np.resize(scores,(r,c))
    num_r=len(frames[0])
    num_c=len(frames[0][0])
    vec_f=frames.reshape(num_f*num_c*num_r,3)
    scores = gmix.score_samples(vec_f)
    scores=np.resize(scores,(num_f,num_r,num_c))
    return scores





def GMM_mean_skin(scores):
    return np.mean(scores)

def GMM_skin_binary(framehsv):
    threshold=0.9
    binary=np.array([])
    GMM_skin_data=GMM_skin(framehsv)
    GMM_skin_mean=GMM_mean_skin(GMM_skin_data)
    r=len(framehsv)# number of rows
    c=len(framehsv[0])#number of columns
    for i in range(r):
        for j in range(c):
            if GMM_skin_data[i][j]*threshold>GMM_skin_mean:
                binary=np.append(binary,1)
            else:
                binary=np.append(binary,0)
    binary=np.resize(binary,(r,c))
    return binary

            


if __name__=="__main__":
    a=np.array([[[[32,42.0,100.0],[32,42.0,100.0],[32,42.0,100.0]],[[32,42.0,100.0],[32,42.0,100.0],[32,42.0,100.0]]]])
    #binary=GMM_skin_binary([[[32,42.0,100.0],[32,42.0,100.0],[32,42.0,100.0]],[[32,42.0,100.0],[32,42.0,100.0],[32,42.0,100.0]]])
    scores = GMM_skin(a)
    print(scores)
    print(scores.shape)
    #print(GMM_mean_skin(scores))

