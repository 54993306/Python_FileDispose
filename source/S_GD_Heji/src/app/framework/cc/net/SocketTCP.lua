--[[
For quick-cocos2d-x
SocketTCP lua
@author zrong (zengrong.net)
Creation: 2013-11-12
Last Modification: 2013-12-05
@see http://cn.quick-x.com/?topic=quickkydsocketfzl
]]
local SOCKET_TICK_TIME = 0.05 			-- check socket data interval
local SOCKET_RECONNECT_TIME = 5			-- socket reconnect try interval
local SOCKET_CONNECT_FAIL_TIMEOUT = 5	-- socket failure timeout

local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"

local scheduler = require("app.framework.scheduler")
local socket = require "socket"

local SocketTCP = class("SocketTCP")

SocketTCP.EVENT_DATA = "SOCKET_TCP_DATA"
SocketTCP.EVENT_CLOSE = "SOCKET_TCP_CLOSE"
SocketTCP.EVENT_CLOSED = "SOCKET_TCP_CLOSED"
SocketTCP.EVENT_CONNECTED = "SOCKET_TCP_CONNECTED"
SocketTCP.EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE"

SocketTCP._VERSION = socket._VERSION
SocketTCP._DEBUG = socket._DEBUG

function SocketTCP.getTime()
	return socket.gettime()
end

function SocketTCP:ctor(__host, __port, __retryConnectWhenFailure)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    self.host = __host
    self.port = __port
	self.tickScheduler = nil			-- timer for data
	self.reconnectScheduler = nil		-- timer for reconnect
	self.connectTimeTickScheduler = nil	-- timer for connect timeout
	self.name = 'SocketTCP'
	self.tcp = nil
	self.isRetryConnect = __retryConnectWhenFailure
	self.isConnected = false
end

function SocketTCP:setName( __name )
	self.name = __name
	return self
end

function SocketTCP:setTickTime(__time)
	SOCKET_TICK_TIME = __time
	return self
end

function SocketTCP:setReconnTime(__time)
	SOCKET_RECONNECT_TIME = __time
	return self
end

function SocketTCP:setConnFailTime(__time)
	SOCKET_CONNECT_FAIL_TIMEOUT = __time
	return self
end

-- 函数功能: 检测是否为ipv6地址
-- 返回值: bool
local function isIpv6(addrinfo)
	Log.i("------isIpv6");
    Log.i("------isIpv6 result", addrinfo);
    local ipv6 = false
    if addrinfo then
        for k,v in pairs(addrinfo) do
            if v.family == "inet6" then
                ipv6 = true
                break
            end
        end
    end
    return ipv6
end

-- 函数功能: 检测是否能获取到host
-- 返回值: bool
local function canGetHost(addrinfo)
    local hasAddr = false
    if addrinfo then
        for k,v in pairs(addrinfo) do
            if v.addr then
                hasAddr = true
				Log.i("------hasAddr");
                break
            end
        end
    end
    return hasAddr
end

function SocketTCP:connect(__host, __port, __retryConnectWhenFailure)
	if __host then self.host = __host end
	if __port then self.port = __port end
	if __retryConnectWhenFailure ~= nil then self.isRetryConnect = __retryConnectWhenFailure end
	assert(self.host or self.port, "Host and port are necessary!")
	-- printInfo("%s.connect(%s, %d)", self.name, self.host, self.port)

	--self.tcp = socket.tcp()
	Log.i("SocketTCP:connect", "getaddrinfo: " .. self.host)
    local addrinfo = socket.dns.getaddrinfo(self.host)
	if isIpv6(addrinfo) then
		self.tcp = socket.tcp6()
	else
		self.tcp = socket.tcp()
	end
	self.tcp:settimeout(0)

	local function connectFailure()
		self.waitConnect = nil
		self:close()
		self:_connectFailure()
	end

	local result = canGetHost(addrinfo) -- 检测是否能获取到host
	if not result then
		scheduler.performWithDelayGlobal(connectFailure, 0)
		return
	end

	local function __checkConnect()
		local __succ = self:_connect()
		if __succ then
			self:_onConnected()
		end
		return __succ
	end

	if not __checkConnect() then
		-- check whether connection is success
		-- the connection is failure if socket isn't connected after SOCKET_CONNECT_FAIL_TIMEOUT seconds
		local __connectTimeTick = function ()
			--printInfo("%s.connectTimeTick", self.name)
			if self.isConnected then return end
			self.waitConnect = self.waitConnect or 0
			self.waitConnect = self.waitConnect + SOCKET_TICK_TIME
			if self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT then
				connectFailure()
			end
			__checkConnect()
		end
		self.connectTimeTickScheduler = scheduler.scheduleUpdateGlobal(__connectTimeTick)
	end
end

function SocketTCP:connectWithIP(__host, __port, __retryConnectWhenFailure, __addrinfo)
	Log.i("SocketTCP:connectWithIP", tostring(__host), tostring(self.m_isConnecting))
	if (not __host or __host == self.host) and self.m_isConnecting then return end
	self.m_isConnecting = true
	if __host then self.host = __host end
	if __port then self.port = __port end
	if __retryConnectWhenFailure ~= nil then self.isRetryConnect = __retryConnectWhenFailure end
	assert(self.host or self.port, "Host and port are necessary!")
	-- printInfo("%s.connect(%s, %d)", self.name, self.host, self.port)

	--self.tcp = socket.tcp()
	Log.i("SocketTCP:connectWithIP", "getaddrinfo: " .. self.host)
    local addrinfo = __addrinfo or socket.dns.getaddrinfo(self.host)
	if isIpv6(addrinfo) then
		self.tcp = socket.tcp6()
	else
		self.tcp = socket.tcp()
	end
	self.tcp:settimeout(0)

	local function connectFailure()
		self.waitConnect = nil
		self:close()
		self:_connectFailure()
		self.m_isConnecting = false
	end

	local result = canGetHost(addrinfo) -- 检测是否能获取到host
	if not result then
		scheduler.performWithDelayGlobal(connectFailure, 0)
		return
	end

	local function __checkConnect()
		local __succ = self:_connect()
		if __succ then
			self:_onConnected()
		end
		return __succ
	end

	if not __checkConnect() then
		-- check whether connection is success
		-- the connection is failure if socket isn't connected after SOCKET_CONNECT_FAIL_TIMEOUT seconds
		local __connectTimeTick = function ()
			--printInfo("%s.connectTimeTick", self.name)
			if self.isConnected then
				self.m_isConnecting = false
				return
			end
			self.waitConnect = self.waitConnect or 0
			self.waitConnect = self.waitConnect + SOCKET_TICK_TIME
			if self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT then
				connectFailure()
			end
			__checkConnect()
		end
		if self.connectTimeTickScheduler then
			self.waitConnect = 0 -- 重新开始计时
		else
			self.connectTimeTickScheduler = scheduler.scheduleUpdateGlobal(__connectTimeTick)
		end
	else
		self.m_isConnecting = false
	end
end

function SocketTCP:send(__data)
	assert(self.isConnected, self.name .. " is not connected.")
	self.tcp:send(__data)
end

function SocketTCP:close( ... )
	--printInfo("%s.close", self.name)
	if self.tcp then
		self.tcp:close();
	end
	if self.connectTimeTickScheduler then scheduler.unscheduleGlobal(self.connectTimeTickScheduler) end
	if self.tickScheduler then scheduler.unscheduleGlobal(self.tickScheduler) end
	self:dispatchEvent({name=SocketTCP.EVENT_CLOSE})
end

-- disconnect on user's own initiative.
function SocketTCP:disconnect()
	self:_disconnect()
	self.isRetryConnect = false -- initiative to disconnect, no reconnect.
end

--------------------
-- private
--------------------

--- When connect a connected socket server, it will return "already connected"
-- @see: http://lua-users.org/lists/lua-l/2009-10/msg00584.html
function SocketTCP:_connect()
	local __succ, __status = self.tcp:connect(self.host, self.port)
	-- print("SocketTCP._connect:", __succ, __status)
	return __succ == 1 or __status == STATUS_ALREADY_CONNECTED
end

function SocketTCP:_disconnect()
	self.isConnected = false
	self.tcp:shutdown()
	self:dispatchEvent({name=SocketTCP.EVENT_CLOSED})
end

function SocketTCP:_onDisconnect()
	--printInfo("%s._onDisConnect", self.name);
	self.isConnected = false
	self:dispatchEvent({name=SocketTCP.EVENT_CLOSED})
	self:_reconnect();
end

-- connecte success, cancel the connection timerout timer
function SocketTCP:_onConnected()
	--printInfo("%s._onConnectd", self.name)
	self.isConnected = true
	self:dispatchEvent({name=SocketTCP.EVENT_CONNECTED})
	if self.connectTimeTickScheduler then scheduler.unscheduleGlobal(self.connectTimeTickScheduler) end

	local __tick = function()
		while true do
			-- if use "*l" pattern, some buffer will be discarded, why?
			local __body, __status, __partial = self.tcp:receive("*a")	-- read the package body
			--print("body:", __body, "__status:", __status, "__partial:", __partial)
    	    if __status == STATUS_CLOSED or __status == STATUS_NOT_CONNECTED then
		    	self:close()
		    	if self.isConnected then
		    		self:_onDisconnect()
		    	else
		    		self:_connectFailure()
		    	end
		   		return
	    	end
		    if 	(__body and string.len(__body) == 0) or
				(__partial and string.len(__partial) == 0)
			then return end
			if __body and __partial then __body = __body .. __partial end
			-- Log.d("SocketTCP:_onConnected __body len", tostring(__body and string.len(__body)))
			-- Log.d("SocketTCP:_onConnected __partial len", tostring(__partial and string.len(__partial)))
			self:dispatchEvent({name=SocketTCP.EVENT_DATA, data=(__partial or __body), partial=__partial, body=__body})
		end
	end

	-- start to read TCP data
	self.tickScheduler = scheduler.scheduleUpdateGlobal(__tick)
end

function SocketTCP:_connectFailure(status)
	--printInfo("%s._connectFailure", self.name);
	self:dispatchEvent({name=SocketTCP.EVENT_CONNECT_FAILURE})
	self:_reconnect();
end

-- if connection is initiative, do not reconnect
function SocketTCP:_reconnect(__immediately)
	if not self.isRetryConnect then return end
	printInfo("%s._reconnect", self.name)
	if __immediately then self:connect() return end
	if self.reconnectScheduler then scheduler.unscheduleGlobal(self.reconnectScheduler) end
	local __doReConnect = function ()
		self:connect()
	end
	self.reconnectScheduler = scheduler.performWithDelayGlobal(__doReConnect, SOCKET_RECONNECT_TIME)
end

return SocketTCP
