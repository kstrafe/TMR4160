#! /bin/bash

# Samler alle frames til en video fil

if [ -f out.mov ]; then rm out.mov; fi
avconv -threads 4 -framerate 25 -f image2 -i %08d.png -c:v h264 -crf 1 out.mov
