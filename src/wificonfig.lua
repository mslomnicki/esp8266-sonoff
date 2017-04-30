print("Konfiguracja WiFi")

wifi.setmode(wifi.STATIONAP)
wifi.sta.sethostname(hostname)
apcfg = {
    ssid = hostname,
    pwd = "12345678",
    auth = AUTH_WPA_PSK
};
wifi.ap.config(apcfg)
enduser_setup.manual(true)
enduser_setup.start(function()
    print("Connected to wifi as:" .. wifi.sta.getip())
    node.restart()
end, function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
    node.restart()
end, print)

