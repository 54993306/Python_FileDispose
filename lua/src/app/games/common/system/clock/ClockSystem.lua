-------------------------------------------------------------
--  @file   ClockSystem.lua
--  @brief  时钟系统
--  @author Zhu Can Qin
--  @DateTime:2016-08-31 15:51:48
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local currentModuleName = ...
local SystemBase 	= import("..SystemBase", currentModuleName)
local ClockSystem 	= class("ClockSystem", SystemBase)

function ClockSystem:ctor(manager)
		ClockSystem.super.ctor(self, manager)
		self:initialize()
end

--[
-- @brief  释放函数
-- @param  void
-- @return void
--]
function ClockSystem:release()
		self:stoptUpdate()
		self:initialize()
end
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ClockSystem:initialize()
	-- 时钟句柄
	self.clockHandle    = nil
	-- 开始时间
	self.startTime      = 0
	-- 间隔时间
	self.intervalTime   = 0
	-- 时钟类型
	self.clockType      = enClockType.PLAY_CARD
	self.siteDirec   	= enSiteDirection.SITE_MYSELF
	-- 默认超时时间
	self.timeOut = {
		[enClockType.PLAY_CARD] = 15,
		[enClockType.ACTION] 	= 10,
	}

	self.pause = {}
end

--[
-- @brief  激活部件
-- @param  void
-- @return void
--]
function ClockSystem:activate(context)
	self:initialize()
end

--[
-- @brief  反激活部件
-- @param  void
-- @return void
--]
function ClockSystem:deactivate()
	self:stoptUpdate()
	self:initialize()
end

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ClockSystem:setClockSystemDatas(cmd, context)
	-- self.timeOut = {
	-- 	[enClockType.PLAY_CARD] = context.plTO,
	-- 	[enClockType.ACTION] 	= context.acTO,
	-- }
	self.timeOut = {
		[enClockType.PLAY_CARD] = 15,
		[enClockType.ACTION] 	= 15,
	}
end

--[
-- @brief  时间更新
-- @param  void
-- @return void
--]
function ClockSystem:onClockUpdate(dt)
	if self.pause[self.clockType] then
		self.startTime = os.clock() - self.intervalTime
		return
	end
	self.intervalTime = os.clock() - self.startTime
	if self.intervalTime >= self.timeOut[self.clockType] then
		self.startTime = os.clock()
		self.intervalTime = 0
		-- 停止定时器
		self:stoptUpdate()
		if self.clockType == enClockType.PLAY_CARD then
			if self.siteDirec == enSiteDirection.SITE_MYSELF then
				MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, enMjMsgSendId.MSG_SEND_SUBSTITUTE, 1)		
			else
				Log.i("对家时间到")
			end
		elseif self.clockType == enClockType.ACTION then
			-- 发送操作超时通知
			MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACTION_TIME_OUT_NTF)
			-- WFacade:dispatchCustomEvent(MJ_EVENT.MSG_SEND, enMjMsgSendId.MSG_SEND_MJ_ACTION, self._m_actions[1], 0, card)
		end			
	end  
end

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function ClockSystem:getTimeOutValueByType(clockType)
	if self.timeOut[clockType] then
		return self.timeOut[clockType]
	else
		printError("ClockSystem:getTimeOutValue 无效的超时数据类型%d", clockType)
		return nil
	end
end

--[
-- @brief  启动定时器
-- @param  void
-- @return void
--]
function ClockSystem:startUpdate(clockType, siteDirec)
	self.clockType = clockType
	self.siteDirec = siteDirec
		-- 必须要判断定时器是否启动，没启动才启动
	if nil == self.clockHandle then
		self.startTime = os.clock()
		self.intervalTime = 0
		self.clockHandle = scheduler.scheduleGlobal(
			handler(self, ClockSystem.onClockUpdate), 0.2)
	end  
end

--[
-- @brief  停止定时器
-- @param  void
-- @return void
--]
function ClockSystem:stoptUpdate()
	if self.clockHandle then
		scheduler.unscheduleGlobal(self.clockHandle)
	end
	self.clockHandle = nil
end

--[
-- @brief  获取经过的时间
-- @param  void
-- @return void
--]
function ClockSystem:getIntervalTime()
	return math.max(self.intervalTime, 0) 
end

--[
-- @brief  获取剩余时间
-- @param  void
-- @return void
--]
function ClockSystem:getRemainTimeByClockType(clockType)
	if nil == self.timeOut[clockType] then
		printError("ClockSystem:getRemainTimeByClockType 无效的时钟类型%d", clockType)
		return nil
	end
	local remainTime = self.timeOut[clockType] - self.intervalTime
	return math.floor(remainTime)
end

function ClockSystem:pauseTimeByClockType(clockType)
	if nil == self.timeOut[clockType] then
		printError("ClockSystem:getRemainTimeByClockType 无效的时钟类型%d", clockType)
		return
	end

	self.pause[clockType] = true
end

function ClockSystem:resumeTimeByClockType(clockType)
	if nil == self.timeOut[clockType] then
		printError("ClockSystem:getRemainTimeByClockType 无效的时钟类型%d", clockType)
		return
	end

	self.pause[clockType] = nil
end
--[
-- @override
--]
function ClockSystem:getSystemId()
		return enSystemDef.CLOCK_SYSTEM
end

return ClockSystem
