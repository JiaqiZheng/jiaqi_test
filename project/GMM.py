import numpy as np
import sys

import rgb2hsv
import readVideo


import GMM_skin
import GMM_nonskin

from PIL import Image

def GMM_scaledown(scores):
    max_score=np.amax(scores)
    #print("max: "+max_score)
    min_score=np.amin(scores)
    #print("min: "+min_score)

    #range_score=max_score-min_score
    r = len(scores)
    c = len(scores[0])
    #scaledown_scores=np.array([])
    #if range_score != 0:
    #    for i in range(r):
    #        for j in range(c):
    #            scaledwon_score=scores[i][j]/range_score
    #            scaledown_scores=np.append(scaledown_scores,scaledwon_score)
            
    #else:
    #    scaledown_scores=np.ones((r,c))
    #
    #scaledown_scores=np.resize(scaledown_scores,(r,c))
    print(min_score)
    print(max_score)
    #print("scores...")
    #print(scores)
    abs_scores=np.subtract(scores,min_score)
    #print("sub min...")
    #print(abs_scores)
    scaledown_scores=np.divide(abs_scores,max_score-min_score)
    #print("scaledown")
    #print(scaledown_scores)
    return scaledown_scores


def GMM_divide(scores_skin, scores_nonskin):
    return np.divide(scores_skin,scores_nonskin)
def GMM_subtract(scores_skin, scores_nonskin):
    return np.subtract(scores_skin,scores_nonskin)
def GMM_exp(scores):
    return np.exp(scores)
def GMM_predict_mean(scores):
    return np.mean(scores)

def GMM_decision(scores, threshold):
    decision=np.array([])
    r=len(scores)#number of rows of the scores
    c=len(scores[0])#number of colunms of the scores
    for i in range(r):
        for j in range(c):
            if scores[i][j] > threshold:
                decision=np.append(decision,1)
            else:
                decision=np.append(decision,0)

    decisions=np.resize(decision,(r,c))

    return decisions

if __name__=="__main__":
    #a=np.array([[[1,1,1],[2,2,2],[3,3,3]],[[4,4,4],[5,5,5],[6,6,6]]])
    #b=np.array([[[1,2,3],[1,2,3],[1,2,3]],[[1,2,3],[1,2,3],[1,2,3]]])

    #test=np.array([[[32,42.0,100.0],[32,42.0,100.0],[32,42.0,100.0]],[[32,42.0,100.0],[32,42.0,100.0],[32,42.0,100.0]]])

    #prediction=GMM_divide(a,b)
    #print(prediction) 
    #scores=GMM_scaledown(prediction)
    #print(scores)   


    # reading video
    print("reading video to frames in rgb...")
    Path=sys.argv[1]
    frames=readVideo.readVideo2Frames(Path)

    # coverting from rgb to hsv in matlab format
    print("coverting hsv in value range 0-1...")
    show=1
    hsv=rgb2hsv.rgb2hsv(frames)
    frameshsv=rgb2hsv.convert2one(hsv)

    print("getting GMM data")
    GMM_skin_scores=GMM_skin.GMM_skin(frameshsv)
    GMM_nonskin_scores=GMM_nonskin.GMM_nonskin(frameshsv)
    
    print("exp...")
    GMM_skin_exponential=GMM_exp(GMM_skin_scores)
    GMM_nonskin_exponential=GMM_exp(GMM_nonskin_scores)

    #print(prediction)
    print("subtracting...")
    GMM_comb=GMM_divide(GMM_skin_exponential,GMM_nonskin_exponential)
    print("scaling down...")
    GMM_comb_scaledown=GMM_scaledown(GMM_comb)

    
    print("GMM skin exp max")
    print(np.amax(GMM_skin_exponential))
    print("GMM skin exp min")
    print(np.amin(GMM_skin_exponential))
    print("GMM nonskin exp max")
    print(np.amax(GMM_nonskin_exponential))
    print("GMM nonskin exp min")
    print(np.amin(GMM_nonskin_exponential))
    print(GMM_skin_exponential)
    if show!=None:
        im= Image.fromarray(GMM_comb_scaledown[0]*255)

        im.show()


    
    