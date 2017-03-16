#!/bin/bash
DELAY=0.025
../luatool/luatool.py --ip localhost:9999  --delay $DELAY -f init.lua 
../luatool/luatool.py --ip localhost:9999  --delay $DELAY -f config.lua 
../luatool/luatool.py --ip localhost:9999  --delay $DELAY -f service_mode.lua -c 

