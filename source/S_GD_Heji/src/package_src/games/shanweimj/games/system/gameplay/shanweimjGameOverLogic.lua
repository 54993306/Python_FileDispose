--
-- Author: Your Name
-- Date: 2017-05-23 12:20:16
--
-------------------------------------------------------------
--  @file   GameOverLogic.lua
--  @brief  打牌逻辑
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 20:10:58
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

-- local Component = cc.Component
local commonGameOverLogic = require("app.games.common.system.gameplay.GameOverLogic")
local shanweimjGameOverLogic = class("shanweimjGameOverLogic", commonGameOverLogic)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function shanweimjGameOverLogic:ctor()
    shanweimjGameOverLogic.super.ctor(self, "shanweimjGameOverLogic")
end


--[[
-- @brief  设置游戏结束数据函数(保存后端发过来的结束数据31006协议)
-- @param  void
-- @return void
--]]
function shanweimjGameOverLogic:setGameOverDatas(cmd, context)
	self.super.setGameOverDatas(self, cmd, context)

    self.gameOverDatas.fanma = context.faI or {};
    self.gameOverDatas.maima = context.maimainfo2 or {};
    if #self.gameOverDatas.fanma > 0 then
    	self.gameOverDatas.isND = 1
    else
    	self.gameOverDatas.isND = 0
    end
end

--设置不同麻将玩家数据，可以给子类重写该方法
function shanweimjGameOverLogic:setPlayerDatas(site,context)
   Log.i("overwrite GameOverLogic:setPlayerDatas");
    self.gameOverDatas.score[site].policyBGGK 		= context.isBGGK  --包杠杠开
end


return shanweimjGameOverLogic