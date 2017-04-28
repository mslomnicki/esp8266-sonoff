function isempty(s)
    return s == nil or s == ''
end

function prepareResponse(response)
    local responseNiceName = "unknown"

    if response.status == nil then
        response.status = 200
        responseNiceName = "OK"
    end

    local body = "HTTP/1.0 " .. response.status .. " " .. responseNiceName .. "\n"

    if response.headers == nil then
        response.headers = {}
    end

    foundContentType = false;
    for k, v in pairs(response.headers) do
        body = body .. k .. ":" .. v .. "\n"
        if k == "Content-Type" then
            foundContentType = true
        end
    end
    if not foundContentType then
        body = body .. "Content-Type:application/json\n\n"
        if response.content ~= nil then
            body = body .. json.encode(response.content)
        end
    else
        body = body .. response.content
        body = body .. json.encode(response.content)
    end
    return body
end

function elSplit(value, inSplitPattern, outResults)
    if not outResults then
        outResults = {}
    end
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find(value, inSplitPattern, theStart)
    while theSplitStart do
        table.insert(outResults, string.sub(value, theStart, theSplitStart - 1))
        theStart = theSplitEnd + 1
        theSplitStart, theSplitEnd = string.find(value, inSplitPattern, theStart)
    end
    table.insert(outResults, string.sub(value, theStart))
    return outResults
end

function createRequest(payload)
    local request = {}
    local splitPayload = elSplit(payload, "\r\n\r\n")
    local httpRequest = elSplit((splitPayload[1]), "\r\n")
    if not isempty((splitPayload[2])) then
        request.content = json.decode((splitPayload[2]))
    end
    local splitUp = elSplit((httpRequest[1]), "%s+")

    request.method = splitUp[1]
    request.path = splitUp[2]
    request.protocol = splitUp[3]
    local pathParts = elSplit(request.path, "/")

    if(#pathParts == 2) then -- 1 parametr
        request.path = pathParts[2]
    elseif(#pathParts == 3) then-- 2 parametry, czyli komenda i wartosc
        request.path = pathParts[2]
        request.value = pathParts[3]
    end
    return request
end

local srv = net.createServer(net.TCP, 30)
srv:listen(80, function(conn)
    conn:on("receive", function(conn, payload)
        print("Got something...")
        local request = createRequest(payload)
        local response;
        print("Method: " .. request.method .. " Location: " .. request.path)

        if HttpRequests[request.path] ~= nil then
            if HttpRequests[request.path][request.method] ~= nil then
                print("Executing code")
                local retVal = HttpRequests[request.path][request.method](request)
                response = prepareResponse(retVal)
            else
                response = prepareResponse({
                    status = 405,
                    content = { error = "Method not supported for URL", path = request.path }
                })
            end
        else
            if file.open(request.path) ~= nil then
                response = "HTTP/1.1 200 OK\nContent-Type: text/html\n\n"
                local line = file.readline()
                while line ~= nil do
                    response = response .. line
                    line = file.readline()
                end
                file.close()
            else
                response = prepareResponse({
                    status = 404,
                    content = { error = "File not found", url = request.path }
                })
            end
        end
        print(response)
        conn:send(response)
        response = nil
    end)
    conn:on("sent", function(conn) conn:close() end)
end)
