print("Konfiguracja WiFi")

wifi.setmode(wifi.STATIONAP)
apcfg = {}
wifi.sta.sethostname(hostname)
apcfg.ssid = hostname
apcfg.pwd = "12345678"
apcfg.auth = AUTH_WPA_PSK
wifi.ap.config(apcfg)
cfg =
{
    ip = "169.254.0.1",
    netmask = "255.255.0.0",
    gateway = "169.254.0.1"
}
wifi.ap.setip(cfg)
enduser_setup.manual(true)

enduser_setup.start(function()
    print("Connected to wifi as:" .. wifi.sta.getip())
    gpio.write(ledPin, 0); -- wlaczamy diode
end, function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
end)
