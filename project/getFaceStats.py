#!/usr/bin/python

import cv2
import sys
import numpy as np
from scipy.stats import multivariate_normal


import faceBB
import rgb2hsv
import readVideo

import GMM_skin
import GMM_nonskin
import GMM


def getSmallFrames(facebb, frames):
    ### crop a small frames of face bounding box from all video frames
    ### input face bounding box parameters X, Y, W, H from faceBB
    ### return a 4-d np array with first dimension is frame-index
    i=0
    #resize=0.8
    smallframes=[]
    for frame in frames:
        X1=int(facebb[i][0]+0.1*facebb[i][2])
        X2=int(facebb[i][0]+0.9*facebb[i][2])
        Y1=int(facebb[i][1]+0.1*facebb[i][3])
        Y2=int(facebb[i][1]+0.9*facebb[i][3])

        smallframe=frame[Y1:Y2,X1:X2]
        smallframes.append(smallframe)
        i=i+1
    return np.asarray(smallframes)


def getFaceStats(data):
    ### get mu array and cov matrix from the face Bounding box
    ### input all the face bounding box data from function getSmallFrames
    ### return mu array and cov matrix
    mus=[]
    covs=[]
    for d in data:
        mean=np.array(np.mean(d,axis=1))
        mean=np.array(np.mean(mean,axis=0))
        mus.append(mean)
        vector=np.reshape(d,(-1,3)).T
        covar=np.cov(vector)
        covs.append(covar)

    return mus, covs



def get_face_scores(frameshsv,mu,cov):
    if len(frameshsv.shape)==4:
        num_f=len(frameshsv)
        num_r=len(frameshsv[0])
        num_c=len(frameshsv[0][0])
        results=np.array([])
        for i in range(len(frameshsv)):
            vec_f=frameshsv[i].reshape(num_c*num_r,3)

            prob = multivariate_normal.pdf(vec_f,mean=mu[i], cov=cov[i])
            prob=np.array([prob])  
            results=np.append(results,prob)
        results=results.reshape(num_f,num_r,num_c)
    else:
        
        num_c=len(frameshsv)
        num_r=len(frameshsv[0])
        results=np.array([])
        for i in range(len(frameshsv)):
            vec_f=frameshsv[i].reshape(num_c*num_r,3)

            prob = multivariate_normal.pdf(vec_f,mean=mu[i], cov=cov[i])
            prob=np.array([prob])  
            results=np.append(results,prob)
        results=results.reshape(1,num_r,num_c)
    
    return results

def face_scaledown(scores):
    max_score=np.amax(scores)
    min_score=np.amin(scores)
    abs_scores=np.subtract(scores,min_score)
    scaledown_scores=np.divide(abs_scores,max_score-min_score)
    return scaledown_scores




   



if __name__=="__main__":
    # reading video
    a=[[[0.1,0.2,0.3],[0.2,3,0.4],[0.3,0.4,0.5]],[[0.1,0.2,0.3],[0.2,3,0.4],[0.3,0.4,0.5]]]
    A=np.asarray(a)
    


    Path=sys.argv[1]
    frames=readVideo.readVideo2Frames(Path)
    # coverting from rgb to hsv in matlab format
    show=None
    hsv=rgb2hsv.rgb2hsv(frames)
    frameshsv=rgb2hsv.convert2one(hsv)

    faceBox=faceBB.faceBB(frames,show)
    data=getSmallFrames(faceBox,frameshsv)
    mus, covs= getFaceStats(data)
    #print(mus,covs)
    print("testing face scores...")
    print(frameshsv.shape)
    test=get_face_scores(frameshsv,mus, covs)
    #scale_test=face_scaledown(test)
    print(test.shape)



