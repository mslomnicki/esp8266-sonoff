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
        end
        return {
            status = 200,
            content = {
                status = "OK"
            }
        }
    end
}

HttpRequest.uptime = {
    GET = function()
        return {
            status = 200,
            content = {
                uptime = tmr.time()
            }
        }
    end
}

HttpRequest.reboot = {
    POST = function()
        node.restart()
    end
}