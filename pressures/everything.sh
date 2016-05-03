#! /bin/bash

# Lag video til trykk plottet

if [ $(ls *.image 2>/dev/null | wc -l) -gt 0 ]; then rm *.image; fi
./get_pressure_field.awk < ../output > pressures
../split_on_frame.awk pressures
../generate_plots.sh pressure_plot.gnuplot
../tovideo.sh
