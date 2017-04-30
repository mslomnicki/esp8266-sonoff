_ledBlinkTimer = tmr.create()
_ledBlinkTimer:register(5, tmr.ALARM_SEMI, function()
    gpio.write(ledPin, gpio.HIGH)
end)
function ledBlink()
    if ledPin ~= nil then
        gpio.write(ledPin, gpio.LOW)
        _ledBlinkTimer:start()
    end
end

function gpioSetup()
    devSetup()
end

mqttclient = mqtt.Client(hostname, 180, mqttuser, mqttpassword)
mqttclient:lwt("/lwt", hostname, 0, 0)
mqttTimer = tmr.create()
mqttTimer:alarm(1000, tmr.ALARM_AUTO, function()
    if wifi.sta.status() == wifi.STA_GOTIP and wifi.sta.getip() ~= nil then
        mqttTimer:stop()
        mqttclient:connect(mqttbroker, 1883, 0, function()
            for index, endpoint in ipairs(getMqttEndpoints()) do
                mqttclient:subscribe("/" .. hostname .. "/" .. endpoint, 0)
            end
            mqttclient:subscribe("/" .. hostname .. "/node", 0)
            sendCurrentState()
        end, function(client, reason)
            mqttTimer:start()
        end)
    end
end)
mqttclient:on("offline", function(con)
    mqttTimer:start()
end)
mqttclient:on("message", function(conn, topic, data)
    local startIndexOfEndpoint = topic:find("/", 2)
    local endpoint = topic:sub(startIndexOfEndpoint + 1)
    if data == "ON" or data == "OFF" then
        setRelay(endpoint, data)
    elseif (endpoint == "node" and data == "RESTART") then
        node.restart()
    end
end)

function mqttPublish(relay, value)
    mqttclient:publish("/" .. hostname .. "/" .. relay .. "/state", value, 0, 0)
    ledBlink()
end