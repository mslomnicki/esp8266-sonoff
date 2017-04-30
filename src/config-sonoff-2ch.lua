ledPin = 7

function devSetup()
    gpio.mode(ledPin, gpio.OUTPUT)
    gpio.write(ledPin, gpio.HIGH)
    uartSetup()
    sendState(state)
end

function uartSetup()
    uart.setup(0, 19200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)
    --    uart.on("data", 4, function(data)
    --        if data:byte(1) == 160 and data:byte(4) == 161 then
    --            local stateChange = bit.bxor(state, data:byte(3))
    --            print("CURRSTATE:", state, stateChange)
    --            state = data:byte(3)
    --            if stateChange == 1 then
    --                updateState("relay1", bit.band(state, 0))
    --            elseif stateChange == 2 then
    --                updateState("relay2", bit.band(state, 0))
    --            elseif stateChange == 4 then
    --                if (bit.isset(state, 0)) then
    --                    setRelay("relay1", "OFF")
    --                else
    --                    setRelay("relay1", "ON")
    --                end
    --            end
    --        else
    --        end
    --    end, 0)
end

function getMqttEndpoints()
    return { "relay1", "relay2" }
end

function setRelay(relay, value)
    local bitNo
    if relay == "relay1" then
        bitNo = 0
    elseif relay == "relay2" then
        bitNo = 1
    else
        return
    end
    state = bit.clear(state, bitNo)
    if value == "ON" then
        state = bit.set(state, bitNo)
    end
    sendState()
    mqttPublish(relay, value)
end

function updateState(relay, state)
    if state then
        mqttPublish(relay, "ON")
    else
        mqttPublish(relay, "OFF")
    end
end

function sendState()
    uart.write(0, string.char(160, 4, state, 161))
end

function sendCurrentState()
    updateState("relay1", bit.isset(state, 0))
    updateState("relay2", bit.isset(state, 1))
end
