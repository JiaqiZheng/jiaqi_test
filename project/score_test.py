#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jun 29 17:13:49 2018

@author: Jiaqi
"""
import imp

import GMM_skin_class
imp.reload(GMM_skin_class)


a=np.array([[[0.535391792606177,0.287666851340888,0.473649194170043],[0.535391792606177,0.287666851340888,0.473649194170043],[0.535391792606177,0.287666851340888,0.473649194170043]]])
#binary=GMM_skin_binary([[[32,42.0,100.0],[32,42.0,100.0],[32,42.0,100.0]],[[32,42.0,100.0],[32,42.0,100.0],[32,42.0,100.0]]])
scores,gmix = GMM_skin_class.GMM_skin(a)
print(scores)
print(GMM_mean_skin(scores))
