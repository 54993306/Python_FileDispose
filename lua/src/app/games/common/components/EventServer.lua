--[[
	全局的控制与协调类
	由于是全局的实例，所以在代码中直接使用EventServer获取到的就是此类的实例

	1、框架的事件监听注册与移除，事件派发功能
	(此功能块的EventDispatcher与cocos引擎的EventDispatcher实例相互独立互不影响)
		<code>
			a.事件监听
				EventServer:addEventListener(eventListener)
			 	EventServer:addCustomEventListener(eventName, eventCallback)
			 	
			 b.事件移除
			 	EventServer:removeEventListener(eventListener)
			 	EventServer:removeCustomEventListener(eventName)

			 c.事件派发
			 	EventServer:dispatchEvent(event)
			 	EventServer:dispatchCustomEvent(eventName, param_list)

		</code>
	
	2、引擎范围内的事件监听注册与移除，事件派发功能
	(此模块使用cocos引擎的EventDispatcher实例进行操作)
		<code>
			a.事件监听
				EventServer:addGlobalEventListener(eventListener)
			 	EventServer:addGlobalCustomEventListener(eventName, eventCallback)
			 	
			 b.事件移除
			 	EventServer:removeGlobalEventListener(eventListener)
			 	EventServer:removeGlobalCustomEventListener(eventName)

			 c.事件派发
			 	EventServer:dispatchGlobalEvent(event)
			 	EventServer:dispatchGlobalCustomEvent(eventName, param_list)

		</code>

	TODO:是否有场景管理方面的需求统一放在此处进行管理的情况
--]]
local Component = cc.Component
local EventServer = class("EventServer", Component)

function EventServer:ctor()
	EventServer.super.ctor(self, "EventServer")
	self._eventDispatcher = cc.EventDispatcher:new()
	assert(self._eventDispatcher)
	self._eventDispatcher:retain()
	self:setEventDispatcherEnabled(true)
end
--[[
-- @brief  激活函数
-- @param  void
-- @return void
--]]
function EventServer:activate()

end

-- framework EventDispatcher
-- 获取framework事件派发器实例
function EventServer:getEventDispatcher()
	assert(self._eventDispatcher)
	return self._eventDispatcher
end

-- 设置frameframework事件派发器是否可用
-- enabled[boolean] - true:可用；false:不可用
function EventServer:setEventDispatcherEnabled(enabled)
	-- body
	assert(type(enabled) == "boolean")
	self:getEventDispatcher():setEnabled(enabled)
end

-- 添加事件监听器
function EventServer:addEventListener(eventListener)
	-- body
	-- if not iskindof(eventListener, "cc.EventListener") then
	-- 	print("<EventServer | addEventListener - argument(eventListener) is not kind of cc.EventListener")
	-- 	return
	-- end

	self:getEventDispatcher():addEventListenerWithFixedPriority(eventListener, 1)
end

-- 添加自定义的事件监听器
-- eventName - 事件名
-- eventCallback - 事件回调
function EventServer:addCustomEventListener(eventName, eventCallback)
	-- body
	assert(type(eventName) == "string" and type(eventCallback) == "function")
	if string.len(eventName) == 0 then
		print("<EventServer | registerEvent -- eventName is empty.")
		return
	end

	local listener = cc.EventListenerCustom:create(eventName, eventCallback)
	self:addEventListener(listener, 1)
	return listener
end

-- 移除事件监听器
function EventServer:removeEventListener(eventListener)
	-- body
	-- if not iskindof(eventListener, "cc.EventListener") then
	-- 	print("<EventServer | addEventListener - argument(eventListener) is not kind of cc.EventListener")
	-- 	return
	-- end

	self:getEventDispatcher():removeEventListener(eventListener)
end

-- 派发事件
function EventServer:dispatchEvent(event)
	-- body
	-- assert(iskindof(event, "cc.Event"))
	self:getEventDispatcher():dispatchEvent(event)
end

-- 派发自定义事件
function EventServer:dispatchCustomEvent(eventName, ...)
	-- body
	assert(type(eventName) == "string")
	local event = cc.EventCustom:new(eventName)
	event._userdata = {...}
--    Log.i("event._userdata==",event._userdata)
   	self:dispatchEvent(event)
end

-- cocos EventDispatcher 
-- 获取cocos事件派发器实例
function EventServer:getGlobalEventDispatcher()
	-- body
	return cc.Director:getInstance():getEventDispatcher()
end

-- 设置cocos事件派发器是否可用
-- enabled[boolean] - true:可用；false:不可用
function EventServer:setGlobalEventDispatcherEnabled(enabled)
	-- body
	assert(type(enabled) == "boolean")
	self:getGlobalEventDispatcher():setEnabled(enabled)
end

-- 添加事件监听器
function EventServer:addGlobalEventListener(eventListener)
	-- body
	if not iskindof(eventListener, "cc.EventListener") then
		print("<EventServer | addEventListener - argument(eventListener) is not kind of cc.EventListener")
		return
	end

	self:getGlobalEventDispatcher():addEventListenerWithFixedPriority(eventListener, 1)
end

-- 添加自定义的事件监听器
-- eventName - 事件名
-- eventCallback - 事件回调
function EventServer:addGlobalCustomEventListener(eventName, eventCallback)
	-- body
	assert(type(eventName) == "string" and type(eventCallback) == "function")
	if string.len(eventName) == 0 then
		print("<EventServer | registerEvent -- eventName is empty.")
		return
	end

	local listener = cc.EventListenerCustom:create(eventName, eventCallback)
	self:addGlobalEventListener(listener, 1)
	return listener
end

-- 移除事件监听器
function EventServer:removeGlobalEventListener(eventListener)
	-- body
	if not iskindof(eventListener, "cc.EventListener") then
		print("<EventServer | addEventListener - argument(eventListener) is not kind of cc.EventListener")
		return
	end

	self:getGlobalEventDispatcher():removeEventListener(eventListener)
end

-- 派发事件
function EventServer:dispatchGlobalEvent(event)
	-- body
	assert(iskindof(event, "cc.Event"))
	self:getGlobalEventDispatcher():dispatchEvent(event)
end

-- 派发自定义事件
function EventServer:dispatchGlobalCustomEvent(eventName, ...)
	-- body
	assert(type(eventName) == "string")
	local event = cc.EventCustom:new(eventName)
	event._userdata = {...}

   	self:dispatchGlobalEvent(event)
end

--[[
-- @brief  反激活函数
-- @param  void
-- @return void
--]]
function EventServer:deactivate()
	self._eventDispatcher:release()
end

--[[
-- @brief  导出方法
-- @param  void
-- @return target
--]]
function EventServer:exportMethods()
    self:exportMethods_({
        "activate",
        "deactivate",
        "addEventListener",
        "addCustomEventListener",
        "removeEventListener",
        "dispatchEvent",
        "dispatchCustomEvent",
        "addGlobalEventListener",
        "addGlobalCustomEventListener",
        "removeGlobalEventListener",
        "dispatchGlobalEvent",
        "dispatchGlobalCustomEvent",
    })
    return self.target_
end

function EventServer:onBind_()
end

function EventServer:onUnbind_()
end

return EventServer
