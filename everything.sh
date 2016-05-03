#! /bin/bash

# Kjør standard rendering, men åpne filene i vlc til slutt

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# Kjører vlc for å vise videoene
source everything_no_vlc.sh

# Kjør vlc (eller erstatt med en annen video-viewer) på alle video filer
vlc $(find -name '*.mov')
