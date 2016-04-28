#! /bin/bash
if [ $(ls *.image 2>/dev/null | wc -l) -gt 0 ]; then rm *.image; fi
./get_vector_field.awk < ../output > velocities
../split_on_frame.awk velocities
./generate_plots.sh
../tovideo.sh
