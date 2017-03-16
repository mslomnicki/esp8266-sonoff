-- Jezeli ten plik sie uruchamia to oznacza, ze jest wcisniety przycisk 
-- serwisowy

function setupTelnetServer()--{{{
    inUse = false
    function listenFun(sock)
        if inUse then
            sock:send("Already in use.\n")
            sock:close()
            return
        end
        inUse = true

        function s_output(str)
            if(sock ~=nil) then
                sock:send(str)
            end
        end

        node.output(s_output, 0)

        sock:on("receive",function(sock, input)
                node.input(input)
            end)

        sock:on("disconnection",function(sock)
                node.output(nil)
                inUse = false
            end)

        sock:send("Welcome to NodeMCU world.\n> ")
    end

    telnetServer = net.createServer(net.TCP, 180)
    telnetServer:listen(23, listenFun)
end--}}}
gpio.mode(service_led,gpio.OUTPUT)
gpio.write(service_led,0); -- wlaczamy diode

gpio.mode(service_button,gpio.INT, gpio.PULLUP)

gpio.trig(service_button,"up", function()
  gpio.mode(service_button,gpio.INPUT)
	tmr.unregister(0) -- wylaczamy alarm
  gpio.write(service_led,1); -- gasimy diode diode
	wifi.setmode(wifi.STATION)
  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function()
	  gpio.write(service_led,0) -- wlaczamy diode
  	setupTelnetServer()
    print("Telnet started")
  end)
  if (hostname ~= nil) then wifi.sta.sethostname(hostname) end					  
  wifi.sta.connect()

end)

if not tmr.alarm(0, 4000, tmr.ALARM_SINGLE, function()
  gpio.write(service_led,1); -- gasimy diode diode
	gpio.trig(service_button,"up", function()
  gpio.mode(service_button,gpio.INPUT)
    tmr.unregister(0)
		print("Konfiguracja WiFi")
		
		wifi.setmode(wifi.STATIONAP)
		apcfg={}
    if (hostname ~= nil) then 
		  wifi.sta.sethostname(hostname) 
		  apcfg.ssid=hostname
		
		end					  
		apcfg.pwd=password
		apcfg.auth=AUTH_WPA_PSK
		wifi.ap.config(apcfg)
		cfg =
		{
		  ip="169.254.0.1",
		  netmask="255.255.0.0",
		  gateway="169.254.0.1"
		}
		wifi.ap.setip(cfg)
		enduser_setup.manual(true)
		
		enduser_setup.start(
		  function()
		    print("Connected to wifi as:" .. wifi.sta.getip())
        gpio.write(service_led,0); -- wlaczamy diode
--				enduser_setup.stop()
		  end,
		  function(err, str)
		    print("enduser_setup: Err #" .. err .. ": " .. str)
--				enduser_setup.stop()
		  end
		)
  end) 
end) then print ("whoopsie") end

-- vim: fdm=marker:commentstring=--%s
