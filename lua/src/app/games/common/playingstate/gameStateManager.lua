-------------------------------------------------------------
--  @file   gameStateManager.lua
--  @brief  游戏状态管理
--  @author ZCQ
--  @DateTime:2017-02-14 09:12:18
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
--============================================================
local gameStateManager = class("gameStateManager")
-- 游戏状态通知
local kGameStateNtfs = {
	[enMjMsgReadId.MSG_READ_GAME_START] 	= enMjNtfEvent.GAME_START_NTF,
	[enMjMsgReadId.MSG_READ_GAME_RESUME]  	= enMjNtfEvent.GAME_RESUME_START_NTF,
	[enMjMsgReadId.MSG_READ_PLAY_CARD]  	= enMjNtfEvent.GAME_PUT_OUT_START_NTF,
	[enMjMsgReadId.MSG_READ_MJ_ACTION]  	= enMjNtfEvent.GAME_ACT_ANIMATE_START_NTF,
	[enMjMsgReadId.MSG_READ_DISPENSE_CARD]  = enMjNtfEvent.GAME_DISPENSE_START_NTF,
	[enMjMsgReadId.MSG_READ_GAME_OVER]  	= enMjNtfEvent.GAME_OVER_START_NTF,
	[enMjMsgReadId.MSG_READ_CONTINUE]  	    = enMjNtfEvent.GAME_CONTINUE_START_NTF,
}
-- 游戏状态
local kPlayingState = {
	[enMjMsgReadId.MSG_READ_GAME_START] 	= enGamePlayingState.STATE_START,
	[enMjMsgReadId.MSG_READ_GAME_RESUME]  	= enGamePlayingState.STATE_RESUME,
	[enMjMsgReadId.MSG_READ_PLAY_CARD]  	= enGamePlayingState.STATE_PLAY_CARD,
	[enMjMsgReadId.MSG_READ_MJ_ACTION]  	= enGamePlayingState.STATE_ACT_ANIMATE,
	[enMjMsgReadId.MSG_READ_DISPENSE_CARD]  = enGamePlayingState.STATE_DISTR,
	[enMjMsgReadId.MSG_READ_GAME_OVER]      = enGamePlayingState.STATE_GAME_OVER,
	[enMjMsgReadId.MSG_READ_CONTINUE]       = enGamePlayingState.STATE_CONTINUE,
}
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function gameStateManager:ctor()
	self.curState = enGamePlayingState.STATE_IDLE

end
--[
-- @brief  释放函数
-- @param  void
-- @return void
--]
function gameStateManager:release()
   
end

--[[
-- @brief  激活
-- @param  void
-- @return void
--]]
function gameStateManager:activate()

	self.handlers 	= {}
	-- 开始游戏通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_START_NTF, 
        handler(self, self.gameStartNtf)))
    -- 开局结束通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_START_FINISH_NTF, 
        handler(self, self.gameStartFinishNtf)))

    -- 开始恢复游戏通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_RESUME_START_NTF, 
        handler(self, self.gameStartResumeNtf)))
    -- 结束恢复游戏通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_RESUME_FINISH_NTF, 
        handler(self, self.gameFinishResumeNtf)))

    -- 打牌开始通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_PUT_OUT_START_NTF, 
        handler(self, self.gamePutOutStartNtf)))
    -- 打牌结束通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_PUT_OUT_FINISH_NTF, 
        handler(self, self.gamePutOutFinishNtf)))
    -- 动作开始通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_ACT_ANIMATE_START_NTF, 
        handler(self, self.gameActAnimateStartNtf)))
    -- 动作结束通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF, 
        handler(self, self.gameActAnimateFinshNtf)))

    -- 开始拿牌通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_DISPENSE_START_NTF, 
        handler(self, self.gameDispenseStartNtf)))
    -- 拿牌结束通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_DISPENSE_FINISH_NTF, 
        handler(self, self.gameDispenseFinishNtf)))

    -- 单局结算结束通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_OVER_FINISH_NTF, 
        handler(self, self.gameOverNtf)))

    self.msgThread = scheduler.scheduleUpdateGlobal(function() 
        self:handlerMsg()
    end);
end

--[[
-- @brief  反激活
-- @param  void
-- @return void
--]]
function gameStateManager:deactivate()
    if self.msgThread then
        scheduler.unscheduleGlobal(self.msgThread);
        self.msgThread = nil;
    end
end

--[[
-- @brief  改变状态函数
-- @param  void
-- @return void
--]]
function gameStateManager:setCurState(toState)
	self.curState = toState
end

--[[
-- @brief  获取当前状态函数
-- @param  void
-- @return void
--]]
function gameStateManager:getCurState()
	return self.curState
end

--[[
-- @brief  检测判断是否需要改变状态函数
-- @param  void
-- @return void
--]]
function gameStateManager:checkStateChange(datas)
	MjProxy:getInstance():pushSystemData(datas)
end

--[[
-- @brief  根据协议重设游戏数据函数
-- @param  void
-- @return void
--]]
function gameStateManager:setGameDatas(cmd, data)
	if cmd == enMjMsgReadId.MSG_READ_GAME_START then
		-- 设置时间系统数据
		MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.CLOCK_SYSTEM):setClockSystemDatas(cmd, data)
	elseif cmd == enMjMsgReadId.MSG_READ_GAME_RESUME then
		-- 设置时间系统数据
		MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.CLOCK_SYSTEM):setClockSystemDatas(cmd, data)
	elseif cmd == enMjMsgReadId.MSG_READ_PLAY_CARD then
		MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):setPlayCardDatas(cmd, data)
	elseif cmd == enMjMsgReadId.MSG_READ_MJ_ACTION then
		MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM):setOperateSystemDatas(cmd, data)
	elseif cmd == enMjMsgReadId.MSG_READ_DISPENSE_CARD then 
		MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):setDispenseCardDatas(cmd, data)
	elseif cmd == enMjMsgReadId.MSG_READ_GAME_OVER then 
		MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):setGameOverDatas(cmd, data)
	end
end

--[[
-- @brief  游戏开局通知函数
-- @param  void
-- @return void
--]]
function gameStateManager:gameStartNtf()
	self:setCurState(enGamePlayingState.STATE_START)
end

--[[
-- @brief  置为空闲状态
-- @param  void
-- @return void
--]]
function gameStateManager:toNextState()
	self:setCurState(enGamePlayingState.STATE_IDLE)
end

--[[
-- @brief  进入下一状态
-- @param  void
-- @return void
--]]
function gameStateManager:handlerMsg()

    local systemDatas = MjProxy:getInstance():getSystemDatas()
    
	if #systemDatas > 0 
		and self.curState == enGamePlayingState.STATE_IDLE then
		local tempMsg = nil
		tempMsg = systemDatas[1]

		local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
        
        local isTrue = false
        local hasLa = playSystem:hasLaPaoZuoDi()
        if hasLa then
        	local isStarted = playSystem:isGameStarted()
        	if isStarted then
        		isTrue = playSystem:isMjDistrubuteEnd()
        	else
        		isTrue = true
        	end
        else
        	isTrue = true
        end

		if isTrue then
			-- 改变状态
			self:setCurState(kPlayingState[tempMsg.command])
			-- 重设游戏数据
			self:setGameDatas(tempMsg.command, tempMsg.data)
			-- 将数据移出队列
			MjProxy:getInstance():popSystemData()
			MjMediator.getInstance():getEventServer():dispatchCustomEvent(kGameStateNtfs[tempMsg.command])
			if tempMsg.command == enMjMsgReadId.MSG_READ_GAME_START or tempMsg.command == enMjMsgReadId.MSG_READ_GAME_RESUME then
				playSystem:setGameStarted(true)
			end
		end
	end
end

function gameStateManager:handlerLaPaZuoMsg(cmd, data)
	self:setGameDatas(cmd, data)
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(kGameStateNtfs[cmd])
end

--[[
-- @brief  开局完成通知函数
-- @param  void
-- @return void
--]]
function gameStateManager:gameStartFinishNtf()
	Log.i(enMjNtfEvent.GAME_START_FINISH_NTF)
	self:toNextState()
end

--[[
-- @brief  游戏开始恢复通知函数
-- @param  void
-- @return void
--]]
function gameStateManager:gameStartResumeNtf()
	
end

--[[
-- @brief  游戏结束恢复通知函数
-- @param  void
-- @return void
--]]
function gameStateManager:gameFinishResumeNtf()
	Log.i(enMjNtfEvent.GAME_RESUME_FINISH_NTF)
	self:toNextState()
end

--[[
-- @brief  游戏开始打牌通知函数
-- @param  void
-- @return void
--]]
function gameStateManager:gamePutOutStartNtf()
	
end

--[[
-- @brief  游戏结束打牌通知函数
-- @param  void
-- @return void
--]]
function gameStateManager:gamePutOutFinishNtf()
	Log.i(enMjNtfEvent.GAME_PUT_OUT_FINISH_NTF)
	self:toNextState()
end

--[[
-- @brief  游戏动作动画开始通知函数
-- @param  void
-- @return void
--]]
function gameStateManager:gameActAnimateStartNtf()
	
end

--[[
-- @brief  游戏动作动画结束通知函数
-- @param  void
-- @return void
--]]
function gameStateManager:gameActAnimateFinshNtf()
	Log.i(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF)
	self:toNextState()
end

--[[
-- @brief  游戏开始拿牌通知函数
-- @param  void
-- @return void
--]]
function gameStateManager:gameDispenseStartNtf()
	
end

--[[
-- @brief  游戏结束拿牌通知函数
-- @param  void
-- @return void
--]]
function gameStateManager:gameDispenseFinishNtf()
	Log.i(enMjNtfEvent.GAME_DISPENSE_FINISH_NTF)
	self:toNextState()
end

--[[
-- @brief  游戏结算完成通知函数
-- @param  void
-- @return void
--]]
function gameStateManager:gameOverNtf()
	self:toNextState()
end

--[[
-- @brief  游戏结束拿牌通知函数
-- @param  void
-- @return void
--]]
function gameStateManager:finishMsgNtf(event)
	self:toNextState()
end

return gameStateManager
