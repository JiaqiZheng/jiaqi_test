import cv2
import copy
import numpy as np
import sys
import readVideo

def rgb2hsv(frames):
    frameshsv=[]
    for frame in frames:
        framehsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
        factors = [0.5,2.55,2.55]
        framehsv=framehsv/factors
        #framehsv[0]=framehsv[0]*2
        #framehsv[1]=framehsv[1]/2.55
        #framehsv[2]=framehsv[2]/2.55
        frameshsv.append(framehsv)  


    return np.asarray(frameshsv)
def convert2one(frameshsv):
    frameshsv_one=[]
    for frame in frameshsv:
        scale2one_fractor = [360,100,100]
        framehsv_one = frame/scale2one_fractor
        frameshsv_one.append(framehsv_one)
    return np.asarray(frameshsv_one)


if __name__=="__main__":
    Path = sys.argv[1]
    frames=readVideo.readVideo2Frames(Path)

    frameshsv=rgb2hsv(frames)
    print("hsv frame...")
    print(frameshsv[0])

    frameshsv_one=convert2one(frameshsv)
    
    print("convert to one scale...")
    print(frameshsv_one[0])

    

