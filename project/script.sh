#!/bin/bash
for f in ./data/18/*
do
   echo "Processing $f file..."
   python face_detect_2.py $f
done