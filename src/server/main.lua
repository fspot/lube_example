package.path = "../both/?.lua;" .. package.path
require("class")
require("lube")
require("TSerial")
require("client")
table2 = require("table2")

-- "low level" events :

function connCallback(clientid)
	local client = common.instance(Client, conn, clientid)
    onConnect(client)
end

function rcvCallback(data, clientid)
	clients[clientid]:gotData(data, onConnect)
end

function disconnCallback(clientid)
	onDisconnect(clients[clientid])
end

-- "high level" events :

function onConnect(client)
	client:speak("bonjour bonjour !")
	clients[client.id] = client -- ajout a la liste des clients
end

function onMessage(msg, client)
	if msg.english then
		print("received english message with "..tostring(#msg.tags).." tags.")
		client:send({msg= "Hello, Sir.", understood= true})
	else
		print("received some characters..")
		client:send({msg= "wtf?", understood= false, details= "Shut up, stranger."})
	end
end

function onDisconnect(client)
	client:speak("bye bye !")
	clients[client.id] = nil -- destroy
end

-- love stuff :

function love.load()
	clients = {} -- map { idClient => client }
    --anything
    print("loading...")
    conn = lube.tcpServer()
	conn.handshake = "hello"
	conn:listen(3410)
	-- setup callbacks ("low level" events) :
	conn.callbacks.recv = rcvCallback
	conn.callbacks.connect = connCallback
	conn.callbacks.disconnect = disconnCallback
end

function love.update(dt)
    conn:update(dt)
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("quit")
	end
end