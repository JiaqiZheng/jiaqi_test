#!/usr/bin/python
import numpy as np
from scipy import ndimage

def get_holes_filled(b_frames):
    im_filled=np.array([])
    if len(b_frames.shape)==3:
        for i,f in enumerate(b_frames):   
            f_filled=ndimage.binary_fill_holes(f).astype(int)
            
            if i==0:
                f_filled=np.array([f_filled])

                im_filled=f_filled
                
            else:
                f_filled=np.array([f_filled])

                im_filled=np.append(im_filled,f_filled,axis=0)
                
    elif len(b_frames.shape)==2:
        im_filled=ndimage.binary_fill_holes(b_frames).astype(b_frames.dtype)

    ## Image.fromarray() the input array has to be float
    return np.asfarray(im_filled)

def get_erosion(b_frames):
    ## creat a structure to erode
    Structure=np.ones((3,2))
    
    Structure[0][0]=0
    Structure[0][Structure.shape[1]-1]=0
    Structure[Structure.shape[0]-1][0]=0
    Structure[Structure.shape[0]-1][Structure.shape[1]-1]=0
    
    im_eroded=np.array([])
    if len(b_frames.shape)==3:
        for i,f in enumerate(b_frames):
            
            f_eroded=ndimage.binary_erosion(f,structure=Structure)
            if i==0:
                f_eroded=np.array([f_eroded])
                im_eroded=f_eroded
            else:
                f_eroded=np.array([f_eroded])
                im_eroded=np.append(im_eroded,f_eroded,axis=0)
    elif len(b_frames.shape)==2:
        im_eroded=ndimage.binary_erosion(b_frames).astype(b_frames.dtype)
    return np.asfarray(im_eroded)

def get_dilation(b_frames):
    struct1 = ndimage.generate_binary_structure(2, 1)
    im_dilated=np.array([])
    if len(b_frames.shape)==3:
        for i,f in enumerate(b_frames):
            
            f_dilated=ndimage.binary_dilation(f,structure=struct1)
            if i==0:
                f_dilated=np.array([f_dilated])
                im_dilated=f_dilated
            else:
                f_dilated=np.array([f_dilated])
                im_dilated=np.append(im_dilated,f_dilated,axis=0)
    elif len(b_frames.shape)==2:
        im_dilated=ndimage.binary_dilation(b_frames,struct1)

    return np.asfarray(im_dilated)

if __name__=="__main__":
    #a = np.zeros((5, 5), dtype=int)
    #a[1:4, 1:4] = 1
    #a[2,2] = 0
    #a_filled=get_holes_filled(a)
    b=np.array([[[0,0,0,0,0],[0,1,1,1,0],[0,1,0,1,0],[0,1,1,1,0],[0,0,0,0,0]],
    [[0,0,0,0,0],[0,1,1,1,0],[0,1,0,1,0],[0,1,1,1,0],[0,0,0,0,0]]])
    b_filled=get_holes_filled(b)
    b_eroded=get_erosion(b_filled)
    b_dilated=get_dilation(b_eroded)
    print(b_eroded)
    print(b_dilated)