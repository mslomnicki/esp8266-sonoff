nextId = 0

HttpRequests.relay = {
    GET = function(request)
        return {
            status = 200,
            content = {
                relay = gpio.read(relayPin)
            }
        }
    end,
    POST = function(request)
        if (request.value == nil) then
            return {
                status = 404
            }
        end
        if (request.value == 'ON') then
            switchRelay(gpio.HIGH)
        elseif (request.value == 'OFF') then
            switchRelay(gpio.LOW)
        elseif (request.value == 'TOGGLE') then
            toggleRelay()
        end
        return {
            status = 200,
            content = {
                relay = gpio.read(relayPin)
            }
        }
    end
}

HttpRequests.uptime = {
    GET = function()
        return {
            status = 200,
            content = {
                uptime = tmr.time()
            }
        }
    end
}

HttpRequests.reboot = {
    POST = function()
        node.restart()
    end
}