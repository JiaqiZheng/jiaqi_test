#!/usr/bin/python

import cv2
import sys
import copy
import numpy as np




def faceBB(Path,show):

    cap = cv2.VideoCapture(Path)
    i = 0
    frames = []
    cascPath = "/Users/Jiaqi/Desktop/face detect/project/haarcascades/haarcascade_frontalface_default.xml"
    faceCascade = cv2.CascadeClassifier(cascPath)

    if (cap.isOpened()== False): 
        print("Error opening video stream or file")

    while(cap.isOpened()):
        # Capture frame-by-frame
        ret, frame = cap.read()
        

        image = copy.deepcopy(frame)
        frames.append(image)


        if ret == True:
            #cv2.imshow('Frame',frames[i])
            
            # Read the image
            gray = cv2.cvtColor(frames[i], cv2.COLOR_BGR2GRAY)

            # Detect faces in the image
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
           

        # Break the loop
        else: 
            break
        i=i+1



    # When everything done, release the video capture object
    cap.release()
    
    
    # Closes all the frames
    #cv2.destroyAllWindows()
    return result
    
if __name__=="__main__":
    FilePath = sys.argv[1]
    show=None
    boxs=faceBB(FilePath,show)
    print(boxs)
    