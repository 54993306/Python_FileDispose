-------------------------------------------------------------
--  @file   MjGroups.lua
--  @brief  麻将组
--  @author Zhu Can Qin
--  @DateTime:2016-08-08 19:54:15
--  Version: 1.0.0
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Mj                = require "app.games.common.mahjong.Mj"
local MjGroupFactory    = import ".MjGroupFactory"
local Deque             = require "app.games.common.utils.Deque"

local MjGroups = require("app.games.common.ui.playlayer.exhibition.MjGroups")
local zhongshanMjGroups        = class("zhongshanMjGroups",MjGroups)
--[[
-- @brief  添加函数
-- @param  content{
--	mjs 	=  {},  麻将的列表
--  actionType		动作类型 吃 碰 明杠 暗杠 加杠，参考 Define.lua 里面的 enOperate
--  operator		操作者的座次	
--  beOperator      被操作的座位，暗杠和加杠不需要传进来	
-- }
-- @return void
--]]
function zhongshanMjGroups:addMjGroup(content)
    -- if content.operator == content.beOperator then
    --     printError("MjGroups:addMjGroup 操作者和被操作者不能是同一个人")
    --     return
    -- end
    local mjGroup = MjGroupFactory:createMjGroup(content)
    mjGroup:onShow()
    -- 将设置的组加入队列里面
    if nil == self.mjsGroupsQueue[content.operator] then
        self.mjsGroupsQueue[content.operator] = {}
        table.insert(self.mjsGroupsQueue[content.operator], mjGroup)
    else
        table.insert(self.mjsGroupsQueue[content.operator], mjGroup)
    end
    -- 统计打出去的麻将
    local outObjs = mjGroup:getPutOutObjs()
    for i=1,#outObjs do
        table.insert(self.putOutObjs, outObjs[i])
    end
    return mjGroup
end

return zhongshanMjGroups