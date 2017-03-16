#!/bin/bash
DELAY=0.025
../luatool/luatool.py -b 115200  --delay $DELAY -f init.lua 
../luatool/luatool.py -b 115200  --delay $DELAY -f config.lua 
../luatool/luatool.py -b 115200  --delay $DELAY -f service_mode.lua -c 

