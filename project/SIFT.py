#!/usr/bin/python

import cv2
import copy
import numpy as np
from matplotlib import pyplot as plt

#read video
def read_video(Path):
    cap = cv2.VideoCapture(Path)
    frames = []
    i=0
    if (cap.isOpened()== False): 
        print("Error opening video stream or file")
    while(cap.isOpened()):
        ret, frame = cap.read()
        
        image = copy.deepcopy(frame)
        
        frames.append(image)
        
        i=i+1
        if i==10:
            break

        #print(i)
    cap.release()
    return frames


#read a image
def read_image(Path):
    image  =  cv2.imread(Path)
    return image

##detect SIFT keypoint in a image or a frame
def SIFT_detect(image):
    sift = cv2.xfeatures2d.SIFT_create()
    kp, des = sift.detectAndCompute(image,None)
    return kp, des

## show SIFT keypoints in a image
def show_SIFT(image,kp):
    image2 = cv2.drawKeypoints(image, kp, outImage=np.array([]))
    plt.imshow(image2)
    plt.show()
    return

## matching SIFT keypoints using Flann matching
def Flann_match (des1,des2):
    flann_params = dict(algorithm=1, trees=4)
    search_params = dict(checks = 50)

    flann = cv2.FlannBasedMatcher(flann_params, search_params)

    matches = flann.knnMatch(des1,des2,2)
    del flann


    return matches


def test_SIFT_detect(Path):
    print("starting ...")
    frames = read_video(Path)
    print("read success")
    kp, des = SIFT_detect(frames[0])
    show_SIFT(frames[0],kp)
    return

def test_SIFT_match(Path):
    print("starting ...")
    frames = read_video(Path)
    print("read success")
    kp1, des1=SIFT_detect(frames[0])
    print("keypoint one calculated")
    kp2, des2=SIFT_detect(frames[1])
    print("keypoint two calculated")

    matches = Flann_match(des1,des2)
    good = []
    for m,n in matches:
        if m.distance < 0.75*n.distance:
            good.append([m])
    img3 = cv2.drawMatchesKnn(frames[0],kp1,frames[1],kp2,good,outImg=np.array([]))

    plt.imshow(img3),plt.show()
    return
