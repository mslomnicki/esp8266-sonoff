wifi.setmode(wifi.NULLMODE)
print('MAC: ',wifi.sta.getmac())
print('chip: ',node.chipid())
print('heap: ',node.heap())

if file.exists("config.lua") then
  dofile("config.lua")
	else print("No config.lua")
end

if file.exists("hostname") then
  file.open("hostname", "r")
  hostname=file.read('\n')
	hostname=string.gsub(hostname,"[^a-zA-Z0-9_\-]",'')
  if (hostname == '') then hostname = nil end
  file.close()
else print("No hostname")
end

if not tmr.alarm(0, 500, tmr.ALARM_SINGLE, function() 
   -- dajemy 500 ms na:
	 -- * wcisniecie przycisku 
	 -- * wykasowanie init.lua w razie bledu w service_mode
    if (gpio.read(service_button) == 0 ) then
			if file.exists("service_mode.lc") then
		  	print("Starting service mode")
				dofile("service_mode.lc")
	    else print("No service_mode.lc")
      end
		else
		  if file.exists("main.lc") then
			  print("Starting script main.lc.");
			  dofile("main.lc") 
			else
			  if file.exists("main.lua") then
				  print("Starting script main.lua.");
					dofile("main.lua")
				else
				  print("No script found.");
				end
			end
		end
  end) then 
  print("Timer 0 already in use!") 
end
