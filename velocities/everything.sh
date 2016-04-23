#! /bin/bash
./get_vector_field.awk < ../output > velocities
./split_on_frame.awk velocities
./generate_plots.sh
./tovideo.sh
