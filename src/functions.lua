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

_buttondebounced = 0
_debouncerTimer = tmr.create()
_debouncerTimer:register(buttonDebounce, tmr.ALARM_SEMI, function()
    _buttondebounced = 0
end)
function gpioSetup()
    devSetup()
    if buttonPin ~= nil then
        gpio.trig(buttonPin, "down", function(level)
            if (_buttondebounced == 0) then
                _buttondebounced = 1
                _debouncerTimer:start()
                toggleRelay(getMqttEndpoints()[1])
            end
        end)
    end
end

mqttclient = mqtt.Client(hostname, 180, mqttuser, mqttpassword)
mqttclient:lwt("/lwt", hostname, 0, 0)
mqttTimer = tmr.create()
mqttTimer:alarm(1000, tmr.ALARM_AUTO, function()
    if wifi.sta.status() == wifi.STA_GOTIP and wifi.sta.getip() ~= nil then
        mqttTimer:stop()
        mqttclient:connect(mqttbroker, 1883, 0, function()
            print("mqttClient connected")
            for index, endpoint in ipairs(getMqttEndpoints()) do
                mqttclient:subscribe("/" .. hostname .. "/" .. endpoint, 0)
            end
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
    end
end)

function toggleRelay(relay)
    mqttclient:publish("/" .. hostname .. "/" .. relay .. "/state", devToggleRelay(relay), 0, 0)
    ledBlink()
end

function setRelay(relay, value)
    devSetRelay(relay, value)
    mqttclient:publish("/" .. hostname .. "/" .. relay .. "/state", value, 0, 0)
    ledBlink()
end
