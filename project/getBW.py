#!/usr/bin/python
#!/usr/bin/python
import numpy as np
from PIL import Image

def genBW(scores,threshold):
    binary=np.array([])
    
    if len(scores.shape)==3:
        numf=scores.shape[0]
        for f_scores in scores:
            r=len(f_scores)# number of rows
            c=len(f_scores[0])#number of columns
            f_scores[f_scores>threshold]=1
            f_scores[f_scores<=threshold]=0
            
            binary=np.append(binary,f_scores)  
        binary=binary.reshape(numf,r,c)
  


    if len(scores.shape)==2:
        r=len(scores)# number of rows
        c=len(scores[0])#number of columns
        scores=scores.reshape(r*c)
        scores[scores>threshold]=1
        scores[scores<=threshold]=0

        scores=np.asarray(scores)
        
        binary=scores.reshape(1,r,c)

    return binary 
if __name__ =="__main__":
    A=np.array([[[1,2,3],[4,5,6]],[[7,8,9],[10,11,12]]])
    threshold=np.mean(A)
    BW=genBW(A,threshold)
    print(BW)