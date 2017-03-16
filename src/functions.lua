local _ledTimer = tmr.create()
_ledTimer:register(5, tmr.ALARM_SEMI, function()
    gpio.write(ledPin, gpio.HIGH)
end)

local _buttondebounced = 0
local _debouncerTimer = tmr.create()
_debouncerTimer:register(buttonDebounce, tmr.ALARM_SEMI, function()
    _buttondebounced = 0
end)

function gpioSetup()
    gpio.mode(ledPin, gpio.OUTPUT)
    gpio.write(ledPin, gpio.LOW)

    gpio.mode(relayPin, gpio.OUTPUT)
    gpio.write(relayPin, relayInitState)

    gpio.mode(buttonPin, gpio.INT)
    buttonSetup()
end

function wifiSetup()
    wifi.setmode(wifi.STATION)
    wifi.setphymode(wifi.PHYMODE_N)
    wifi.sta.sethostname(hostname)
    wifi.sta.connect()
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function()
        gpio.write(ledPin, gpio.HIGH)
    end)
end

function setupTelnetServer(port)
    telnetServerInUse = false
    function listenTelnetServer(sock)
        if telnetServerInUse then
            sock:send("Telnet server in use.\n")
            sock:close()
            return
        end
        telnetServerInUse = true

        function s_output(str)
            if (sock ~= nil) then
                sock:send(str)
            end
        end

        node.output(s_output, 0)

        sock:on("receive", function(sock, input)
            node.input(input)
        end)

        sock:on("disconnection", function(sock)
            node.output(nil)
            telnetServerInUse = false
        end)

        sock:send("Welcome to NodeMCU world.\n> ")
    end

    telnetServer = net.createServer(net.TCP, 180)
    telnetServer:listen(port, listenTelnetServer)
end

function ledBlink()
    gpio.write(ledPin, gpio.LOW)
    _ledTimer:start()
end

function buttonSetup()
    -- Pin to toggle the status
    gpio.trig(buttonPin, "down", function(level)
        if (_buttondebounced == 0) then
            _buttondebounced = 1
            _debouncerTimer:start()

            --Change the state
            if (gpio.read(relayPin) == gpio.HIGH) then
                gpio.write(relayPin, gpio.LOW)
                print("Was on, turning off")
            else
                gpio.write(relayPin, gpio.HIGH)
                print("Was off, turning on")
            end

            --            mqttAct()
            --            mqtt_update()
        end
    end)
end