json = require "cjson"
wifi.setmode(wifi.NULLMODE)
print('MAC: ',wifi.sta.getmac())
print('chip: ',node.chipid())
print('heap: ',node.heap())

if file.exists("config.lua") then
  dofile("config.lua")
	else print("No config.lua")
end
dofile("functions.lc")

gpioSetup()
wifiSetup()
telnet()

ledTimer = tmr.create()
ledTimer:alarm(5000, tmr.ALARM_AUTO, function()
    ledBlink()
end)

if(file.exists("httpserver.lc") and file.exists("httprequests.lua")) then
    HttpRequests = {}
    dofile("httpserver.lc")
    dofile("httprequests.lua")
end