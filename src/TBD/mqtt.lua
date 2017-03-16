git clo
mqttBroker = "192.168.1.30"
mqttUser = "none"
mqttPass = "none"
 
deviceID="bugzapper"
roomID="1"
 
-- Make a short flash with the led on MQTT activity

 
m = mqtt.Client("Sonoff-" .. deviceID, 180, mqttUser, mqttPass)
m:lwt("/lwt", "Sonoff " .. deviceID, 0, 0)
m:on("offline", function(con)
    ip = wifi.sta.getip()
    print ("MQTT reconnecting to " .. mqttBroker .. " from " .. ip)
    tmr.alarm(1, 10000, 0, function()
        node.restart();
    end)
end)
 
 

 
-- Update status to MQTT
function mqtt_update()
    if (gpio.read(relayPin) == 0) then
        m:publish("/home/".. roomID .."/" .. deviceID .. "/state","OFF",0,0)
    else
        m:publish("/home/".. roomID .."/" .. deviceID .. "/state","ON",0,0)
    end
end
  
-- On publish message receive event
m:on("message", function(conn, topic, data)
    mqttAct()
    print("Recieved:" .. topic .. ":" .. data)
        if (data=="ON") then
        print("Enabling Output")
        gpio.write(relayPin, gpio.HIGH)
    elseif (data=="OFF") then
        print("Disabling Output")
        gpio.write(relayPin, gpio.LOW)
    else
        print("Invalid command (" .. data .. ")")
    end
    mqtt_update()
end)
 
 
-- Subscribe to MQTT
function mqtt_sub()
    mqttAct()
    m:subscribe("/home/".. roomID .."/" .. deviceID,0, function(conn)
        print("MQTT subscribed to /home/".. roomID .."/" .. deviceID)
    end)
end
 
tmr.alarm(0, 1000, 1, function()
    if wifi.sta.status() == 5 and wifi.sta.getip() ~= nil then  
        tmr.stop(0)
        m:connect(mqttBroker, 1883, 0, function(conn)
            gpio.write(ledPin, gpio.HIGH)
            print("MQTT connected to:" .. mqttBroker)
            mqtt_sub() -- run the subscription function
        end)
    end
 end)