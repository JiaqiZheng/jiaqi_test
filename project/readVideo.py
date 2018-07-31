#!/usr/bin/python

import cv2
import copy
import numpy as np
import sys



#read video
def readVideo2Frames(Path):
    cap = cv2.VideoCapture(Path)
    frames = []
    i=0
    if (cap.isOpened()== False): 
        print(i)
        print("Error opening video stream or file")
    while(cap.isOpened()):
        ret, frame = cap.read()
        
        image = copy.deepcopy(frame)    
        frames.append(image)
        i=i+1
       
        if i==50:
            break

    cap.release()

    return np.asarray(frames)


if __name__=="__main__":
    Path = sys.argv[1]
    frames=readVideo2Frames(Path)
    print(type(frames))
    print(frames[0])
    print(type(frames[0]))