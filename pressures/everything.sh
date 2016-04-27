#! /bin/bash
if [ $(ls *.image 2>/dev/null | wc -l) -gt 0 ]; then rm *.image; fi
./get_pressure_field.awk < ../output > pressures
./split_on_frame.awk pressures
./generate_plots.sh
./tovideo.sh
