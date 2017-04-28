function boot()
    if file.exists("config.lua") then
        dofile("config.lua")
    else
        print("No config.lua")
    end

    if type ~= nil and file.exists("config-" .. type .. ".lua") then
        dofile("config-" .. type .. ".lua")
    else
        print("No device specific config found")
    end

    if file.exists("functions.lua") then
        dofile("functions.lua")
        gpioSetup()
        wifiSetup()
    elseif file.exists("wificonfig.lua") then
        print("No functions file - trying wificonfig")
        dofile("wificonfig.lua")
    else
        print("No functions and wificonfig - noop")
        wifiSetup()
    end

    telnet()
end

function telnet()
    local telnetServerInUse = false
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

    local telnetServer = net.createServer(net.TCP, 180)
    telnetServer:listen(23, listenTelnetServer)
end

function wifiSetup()
    wifi.setmode(wifi.STATION)
    wifi.setphymode(wifi.PHYMODE_N)
    wifi.sta.sethostname(hostname)
    wifi.sta.autoconnect(1)
    wifi.sta.connect()
end

boot()