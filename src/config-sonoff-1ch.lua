ledPin = 7
buttonPin = 3
buttonDebounce = 250
relayPin = 6
relayInitState = gpio.LOW

function devSetup()
    gpio.mode(ledPin, gpio.OUTPUT)
    gpio.write(ledPin, gpio.HIGH)
    gpio.mode(relayPin, gpio.OUTPUT)
    gpio.write(relayPin, relayInitState)
    gpio.mode(buttonPin, gpio.INT)
end

function getMqttEndpoints()
    return { "relay1" }
end

function devToggleRelay(relay)
    local state;
    if (gpio.read(_getPin(relay)) == gpio.HIGH) then
        state = "OFF"
        print("Was on, turning off")
    else
        state = "ON"
        print("Was off, turning on")
    end
    devSetRelay(relay, state)
    return state
end

function devSetRelay(relay, value)
    if value == "ON" then
        gpio.write(_getPin(relay), gpio.HIGH)
    else
        gpio.write(_getPin(relay), gpio.LOW)
    end
end

function _getPin(relay)
    return relayPin;
end
