-------------------------------------------------------------
--  @file   SystemFacade.lua
--  @brief  系统数据单例
--  @author Zhu Can Qin
--  @DateTime:2016-09-01 10:11:24
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

SystemFacade = class("SystemFacade")

SystemFacade.getInstance = function()
    if not SystemFacade.s_instance then
        SystemFacade.s_instance = SystemFacade.new()
    end

    return SystemFacade.s_instance
end

SystemFacade.releaseInstance = function()
    if SystemFacade.s_instance then
        SystemFacade.s_instance:dtor()
    end
    SystemFacade.s_instance = nil
end
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
SystemFacade.ctor = function(self)
	self:init()
end

--[[
-- @brief  析构函数
-- @param  void
-- @return void
--]]
SystemFacade.dtor = function(self)
    self:init()
end

--[[
-- @brief  初始化函数
-- @param  void
-- @return void
--]]
function SystemFacade:init()
	self.gameId 	= 0
	self.roomId 	= 0
	self.roomInfo 	= {}
    self.remainCards = 0    -- 剩余牌数

	self.totalGameCount = FriendRoomInfo.getInstance():getTotalCount()-- 总局数
    self.remainGameCount = FriendRoomInfo.getInstance():getShengYuCount()-- 剩余局数
end
--[[
-- @brief  设置游戏id函数
-- @param  void
-- @return void
--]]
function SystemFacade:setGameId(gameId)
    self.gameId = gameId
end
--[[
-- @brief  获取游戏id函数
-- @param  void
-- @return void
--]]
function SystemFacade:getGameId()
    return self.gameId or 0
end
--[[
-- @brief  设置房间信息函数
-- @param  void
-- @return void
--]]
function SystemFacade:setRoomInfo(roomInfo)
    self.roomInfo = roomInfo
end
--[[
-- @brief  获取房间信息函数
-- @param  void
-- @return void
--]]
function SystemFacade:getRoomInfo()
    return self.roomInfo
end
--[[
-- @brief  设置房间id函数
-- @param  void
-- @return void
--]]
function SystemFacade:setRoomId(roomId)
    self.roomId = roomId
end

--[[
-- @brief  获取房间id函数
-- @param  void
-- @return void
--]]
function SystemFacade:getRoomId()
    return self.roomId or 0
end

--[[
-- @brief  设置剩余牌数
-- @param  void
-- @return void
--]]
function SystemFacade:setRemainPaiCount(count)
    self.remainCards = count
end

--[[
-- @brief  获取剩余牌数
-- @param  self.remainCards 返回剩余牌数
-- @return void
--]]
function SystemFacade:getRemainPaiCount()
    return self.remainCards
end

--[[
-- @brief  设置总局数
-- @param  count 局数
-- @return void
--]]
function SystemFacade:setTotalGameCount(count)
    self.totalGameCount = count
end

--[[
-- @brief  获取总局数
-- @param  self.remainCards 返回剩余牌数
-- @return void
--]]
function SystemFacade:getTotalGameCount()
    return self.totalGameCount
end

--[[
-- @brief  设置已经玩过的游戏局数
-- @param  count 局数
-- @return void
--]]
function SystemFacade:setRemainGameCount(count)
    self.remainGameCount = count
end

--[[
-- @brief  获取已经玩过的游戏局数
-- @return void
--]]
function SystemFacade:getRemainGameCount()
    return self.remainGameCount
end

--[[
-- @brief  获取当前局数
-- @return void
--]]
function SystemFacade:getCurrentGameCount()
    -- local currentCount = self:getTotalGameCount() - self:getRemainGameCount()
    -- return currentCount
    return FriendRoomInfo.getInstance():getNowCount()
end

SystemFacade = SystemFacade or SystemFacade.new()
return SystemFacade