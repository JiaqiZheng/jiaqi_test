import numpy as np

from sklearn import mixture

def GMM_nonskin(frames):
    weights_nonskin = np.array([0.184128172909285,0.426832496283425,0.243187324233532,0.145852006573759])
    mu_nonskin = np.array([[0.563402582926284,0.0762172584484273,0.610892420753570], 
                [0.0800778099567524,0.488826210946002,0.524253767864692],
                [0.100974454493935,0.143720361403057,0.569687118111921],
                [0.606189027823846,0.397930789640375,0.379953655704685]])
    sigma_nonskin = np.array([
                    [[0.0551,0.0012,-0.0012],
                        [0.0012,0.0025,-0.0047],
                        [-0.0012,-0.0047,0.0580]], 
                    [[0.0011,-0.0018,0.0022],
                        [ -0.0018,0.0492,-0.0135],
                        [ 0.0022,-0.0135,0.0496]], 
                    [[0.0040,0.0016,-0.0017],
                        [0.0016,0.0088,-0.0072],
                        [-0.0017,0.0072,0.0646]],
                    [[0.0633,0.0029,0.0027],
                        [0.0029,0.0526,-0.0094],
                        [0.0027,-0.0094,0.0577]]
                        ])

    gmix = mixture.GaussianMixture(n_components=4, covariance_type='full')
    #gmix.fit(np.random.rand(10, 3))  # Now it thinks it is trained
    gmix.precisions_cholesky_ = np.linalg.cholesky(np.linalg.inv(sigma)).transpose((0, 2, 1))

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
    num_r=len(frames[0])
    num_c=len(frames[0][0])
    vec_f=frames.reshape(num_f*num_c*num_r,3)
    scores = gmix.score_samples(vec_f)
    scores=np.resize(scores,(num_f,num_r,num_c))
    return scores

def GMM_mean_nonskin(scores):
    return np.mean(scores)

def GMM_nonskin_binary(framehsv):
    threshold=0.9
    binary=np.array([])
    GMM_skin_data=GMM_nonskin(framehsv)
    GMM_skin_mean=GMM_mean_nonskin(GMM_skin_data)
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
    scores = GMM_nonskin(a)
    print(scores)
    print(scores.shape)