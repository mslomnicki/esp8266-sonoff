ledPin = 7
buttonPin = 3
buttonDebounce = 250
relayPin = 6

local _buttondebounced = 0
local _debouncerTimer = tmr.create()
_debouncerTimer:register(buttonDebounce, tmr.ALARM_SEMI, function()
    _buttondebounced = 0
end)

function devSetup()
    gpio.mode(ledPin, gpio.OUTPUT)
    gpio.write(ledPin, gpio.HIGH)
    gpio.mode(relayPin, gpio.OUTPUT)
    gpio.write(relayPin, relayInitState)
    gpio.mode(buttonPin, gpio.INT)
    gpio.trig(buttonPin, "down", function(level)
        if (_buttondebounced == 0) then
            _buttondebounced = 1
            _debouncerTimer:start()
            if (gpio.read(relayPin) == gpio.HIGH) then
                state = "OFF"
            else
                state = "ON"
            end
            setRelay(relay, state)
        end
    end)
end

function getMqttEndpoints()
    return { "relay1" }
end

function setRelay(relay, value)
    if value == "ON" then
        gpio.write(relayPin, gpio.HIGH)
    else
        gpio.write(relayPin, gpio.LOW)
    end
    mqttPublish(relay, value)
end

function sendCurrentState()
    if gpio.read(relayPin) == 0 then
        mqttPublish("relay1", "OFF")
    else
        mqttPublish("relay1", "ON")
    end
end