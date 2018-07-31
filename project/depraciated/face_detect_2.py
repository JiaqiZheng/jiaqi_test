#!/usr/bin/python

import cv2
import sys
import copy
import numpy as np

FilePath = sys.argv[1]

cap = cv2.VideoCapture(FilePath)
 
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
    for (x, y, w, h) in faces:
      cv2.rectangle(frames[i], (x, y), (x+w, y+h), (0, 255, 0), 2)

    cv2.imshow('Frame',frames[i])
    


    # Press Q on keyboard to exit
    if cv2.waitKey(25) & 0xFF == ord('q'):
      break
  
  # Break the loop
  else: 
    break
  i=i+1



# When everything done, release the video capture object
cap.release()
 
# Closes all the frames
cv2.destroyAllWindows()