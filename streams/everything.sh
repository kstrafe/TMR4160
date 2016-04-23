#! /bin/bash
if [ $(ls *.image | wc -l) -gt 0 ]; then rm *.image; fi
./get_pressure_field.awk < ../output > streams
./split_on_frame.awk streams
./generate_plots.sh
./tovideo.sh
