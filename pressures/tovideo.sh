#! /bin/bash
if [ -f out.mov ]; then rm out.mov; fi
avconv -threads 8 -framerate 25 -f image2 -i %08d.png -c:v h264 -crf 1 out.mov