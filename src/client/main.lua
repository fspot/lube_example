package.path = "../both/?.lua;" .. package.path
require("class")
require("lube")
require("TSerial")
require("client")
cron = require("cron")
table2 = require("table2")

-- "low level" events :

function rcvCallback(data)
    serveur:gotData(data, onConnect)
end

-- "high level" events :

function onMessage(msg)
	local details
	if msg.details then
		details = ", details : " .. msg.details
	else
		details = ", no details."
	end
	print("Received : " .. msg.msg .. details)
end

-- love stuff :

function love.load()
    --do anything else you need to do here
    print("loading...")
    conn = lube.tcpClient()
	conn.handshake = "hello"
	serveur = common.instance(Client, conn) -- oui, le serveur est un "client" :)
	assert(conn:connect("localhost", 3410, true))
	conn.callbacks.recv = rcvCallback

	local function popMsg()
		local toSend = {
			msg= "hello world",
			author= "fred",
			tags= {"test", "hello", "beNice"},
			words= 2,
			english= true
		}
		serveur:send(toSend)
		cron.after(math.random(1, 3), popMsg)
	end
	cron.after(math.random(1, 3), popMsg)
end

function love.update(dt)
    conn:update(dt)
    cron.update(dt)
    --anything else
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("quit")
	end
end

function love.quit()
	conn:disconnect()
end