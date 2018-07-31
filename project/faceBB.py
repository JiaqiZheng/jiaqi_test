#!/usr/bin/python

import cv2
import sys
import copy
import numpy as np

import readVideo



def faceBB(frames,show):

    #cap = cv2.VideoCapture(Path)
    #frames = []
    cascPath = "/Users/Jiaqi/Desktop/face detect/project/haarcascades/haarcascade_frontalface_default.xml"
    faceCascade = cv2.CascadeClassifier(cascPath)
    result = np.array([])
    for i in range(len(frames)):
        gray = cv2.cvtColor(frames[i], cv2.COLOR_BGR2GRAY)

        faces = faceCascade.detectMultiScale(
                gray,
                scaleFactor=1.1,
                minNeighbors=5,
                minSize=(30, 30),
                flags = cv2.CASCADE_SCALE_IMAGE
        )
        WH=0
        if i==0:
            for (x, y, w, h) in faces:
                if w*h>WH:
                    WH=w*h
                    box=faces
            result=np.array(box)
        else:
            for (x, y, w, h) in faces:
                if w*h>WH:
                    WH=w*h
                    box=faces
            result=np.vstack((result,box))




    return result
    
if __name__=="__main__":
    FilePath = sys.argv[1]
    show=None
    frames = readVideo.readVideo2Frames(FilePath)
    print(len(frames))
    boxs=faceBB(frames,show)
    print(boxs)
    