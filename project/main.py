#!/usr/bin/python
import timeit

start = timeit.default_timer()

import numpy as np
from PIL import Image
import sys

import rgb2hsv
import readVideo

import SIFT
import faceBB
import getFaceStats

#!/usr/bin/python

import GMM_skin
import GMM_nonskin
import GMM

import getBW
import post_process

from PIL import Image



#Your statements here


#parameters


def getFace(Path, show, frameshsv,frames):
    #getting a faceBB
    print("getting a face bounding box...")
    faceBox=faceBB.faceBB(frames,show)

    #getting face scores (hsv in range 0-1)
    print("getting scores based on face...")
    small_frame=getFaceStats.getSmallFrames(faceBox,frameshsv)
    mus, covs= getFaceStats.getFaceStats(small_frame)
    face_scores=getFaceStats.get_face_scores(frameshsv,mus,covs)
    return face_scores



def getGMM(frameshsv,show):
    print("getting GMM data")
    GMM_skin_log=GMM_skin.GMM_skin(frameshsv)
    GMM_nonskin_log=GMM_nonskin.GMM_nonskin(frameshsv)
    GMM_skin_scores=GMM.GMM_exp(GMM_skin_log)
    GMM_nonskin_scores=GMM.GMM_exp(GMM_nonskin_log)
   
    return GMM_skin_scores,GMM_nonskin_scores

def getFaceES(face_scores,scores_skin):
    scaleDiff=np.mean(face_scores)/np.mean(scores_skin)
    faceES=face_scores/scaleDiff
    return faceES

if __name__=="__main__":
    types=["grey","binary","filled","eroded","dilated"]
    weight = 0.08
    threshold=8

    show_type=None

    show_test=None
    iterNum=3

    # reading video
    print("reading video to frames in rgb...")
    Path=sys.argv[1]
    frames=readVideo.readVideo2Frames(Path)
    
    read_time= timeit.default_timer()##

    # coverting from rgb to hsv in matlab format
    print("coverting hsv in value range 0-1...")
    
    hsv=rgb2hsv.rgb2hsv(frames)
    frameshsv=rgb2hsv.convert2one(hsv)
    f_num=frames.shape

    hsv_time = timeit.default_timer()##

    #calculating socres combining face and GMM

    print("getting a face bounding box...")
    
    faceBox=faceBB.faceBB(frames,show_test)
    
    faceBB_time = timeit.default_timer()##
    #getting face scores (hsv in range 0-1)
    print("getting scores based on face...")
    small_frame=getFaceStats.getSmallFrames(faceBox,frameshsv)
    small_frame_time = timeit.default_timer()##
    
    mus, covs= getFaceStats.getFaceStats(small_frame)
    mu_cov_time = timeit.default_timer()##
    
    face_scores=getFaceStats.get_face_scores(frameshsv,mus,covs)



    face_score_time = timeit.default_timer()##
    #getting GMM

    #GMM_skin,GMM_nonskin=getGMM(frameshsv,show_test)


    GMM_skin_log=GMM_skin.GMM_skin(frameshsv)
    getgmmskin_time = timeit.default_timer()##
    
    GMM_nonskin_log=GMM_nonskin.GMM_nonskin(frameshsv)
    getgmmnonskin_time = timeit.default_timer()##

    GMM_skin=GMM.GMM_exp(GMM_skin_log)
    gmmskinexp_time = timeit.default_timer()##

    GMM_nonskin=GMM.GMM_exp(GMM_nonskin_log)
    gmmnonskinexp_time = timeit.default_timer()##



    GMM_time = timeit.default_timer()##

    #combining
    faceES=getFaceES(face_scores,GMM_skin)

    up=weight*faceES+(1-weight)*GMM_skin

    total=up/GMM_nonskin

    total_score_time=timeit.default_timer()##

    #calculating binary images
    print("thresholding to binary...")
    B_im=getBW.genBW(total,threshold)

    threshold_time = timeit.default_timer()## 

    #post processing
    print("post processing...")
    B_im_filled=post_process.get_holes_filled(B_im)
    fillhole_time = timeit.default_timer()##

    print("eroding...")
    for i in range(iterNum):
        B_im_eroded=post_process.get_erosion(B_im_filled)

    erode_time = timeit.default_timer()##
    
    print("dilating...")
    for j in range(iterNum):
        B_im_dilated=post_process.get_dilation(B_im_eroded)

    dilate_time = timeit.default_timer()##
    


    if show_type=="grey":
        im= Image.fromarray(total[2])

        im.show()
    elif show_type=="binary":
        im= Image.fromarray(B_im[2]*255)

        im.show()
        #print(B_im[2])
    elif show_type=="filled":
        im=Image.fromarray(B_im_filled[2]*255)

        im.show()
    elif show_type=="eroded":
        im=Image.fromarray(B_im_eroded[2]*255)

        im.show()
    elif show_type=="dilated":
        im=Image.fromarray(B_im_dilated[2]*255)

        im.show()

    stop = timeit.default_timer()
    print("num of frames")
    print(f_num[0])
    print("reading...")
    print(read_time - start)
    print("converting to hsv...")
    print(hsv_time - read_time)
    #print("getting face stats...")
    #print(face_score_time - hsv_time)


    print ("faceBB")
    print(faceBB_time - hsv_time)
    print("small frame")
    print(small_frame_time - faceBB_time)
    print("mu_cov_time")
    print(mu_cov_time - small_frame_time)
    print("face score")
    print(face_score_time - mu_cov_time)


    print("getting GMM stats...")
    print(GMM_time - face_score_time)

    #print("get gmm skin")
    #print(getgmmskin_time - face_score_time)
    #print("get gmm nonskin")
    #print(getgmmnonskin_time - getgmmskin_time)
    #print("gmm skin exp")
    #print(gmmskinexp_time - getgmmnonskin_time)
    #print("gmm nonskin exp")
    #print(gmmnonskinexp_time - gmmskinexp_time)



    print("getting total scores...")
    print(total_score_time - GMM_time)
    print("thresholding...")
    print(threshold_time - total_score_time)
    print("fillhole...")
    print(fillhole_time - threshold_time)
    print("eroding...")
    print(erode_time - fillhole_time)
    print("dilating")
    print(dilate_time - erode_time)
    print("total")
    print(dilate_time - start) 



    
