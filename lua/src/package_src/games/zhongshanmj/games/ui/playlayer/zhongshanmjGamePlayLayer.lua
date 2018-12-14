-------------------------------------------------------------
--  @file   GamePlayLayer.lua
--  @brief  游戏层
--  @author Zhu Can Qin
--  @DateTime:2016-08-25 17:50:28
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local Define 			= require "app.games.common.Define"
local UIFactory           = require "app.games.common.ui.UIFactory"
local PlayerLeftPanel 	= require("app.games.common.ui.playlayer.PlayerLeftPanel")
local PlayerRightPanel 	= require("app.games.common.ui.playlayer.PlayerRightPanel")
local PlayerOtherPanel 	= require("app.games.common.ui.playlayer.PlayerOtherPanel")

local MjGroups 			= require("package_src.games.zhongshanmj.games.ui.playlayer.exhibition.MjGroups")

local Robot 			= require ("app.games.common.ui.playlayer.Robot")
local MJTricks 			= require("app.games.common.custom.MJTricks")
local Mj    			= require "app.games.common.mahjong.Mj"
local MyselfTinPaiOperation  	= require("app.games.common.ui.operatelayer.MyselfTinPaiOperation")
local Indicator = require("app.games.common.ui.playlayer.Indicator")

local GamePlayLayer = require("app.games.common.ui.playlayer.GamePlayLayer")
local zhongshanmjGamePlayerLayer = class("zhongshanmjGamePlayerLayer",GamePlayLayer)


function zhongshanmjGamePlayerLayer:initPlayers()
	Log.i("zhongshanmjGamePlayerLayer:initPlayers")
	self:registerPlayerListener()
	self:registerHandleListener()

	self.mjGroups = MjGroups.new()

    local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.playerCount = sys:getGameStartDatas().playerNum

    if self.playerCount == 2 then
        self.playerPannel[2] = PlayerOtherPanel.new(self.mjGroups)
            :addTo(self)
    elseif self.playerCount == 3 then
        self.playerPannel[2]   = PlayerRightPanel.new(self.mjGroups)
            :addTo(self)

        self.playerPannel[3]    = PlayerLeftPanel.new(self.mjGroups)
            :addTo(self)
    elseif self.playerCount == 4 then
        self.playerPannel[enSiteDirection.SITE_RIGHT]   = PlayerRightPanel.new(self.mjGroups)
            :addTo(self)

        self.playerPannel[enSiteDirection.SITE_OTHER]   = PlayerOtherPanel.new(self.mjGroups)
            :addTo(self)

        self.playerPannel[enSiteDirection.SITE_LEFT]    = PlayerLeftPanel.new(self.mjGroups)
            :addTo(self)
    end

	self.playerPannel[enSiteDirection.SITE_MYSELF]	= UIFactory.createHandCardsPanel(_gameType, self.mjGroups):addTo(self)
	-- 创建取消托管字，加入到游戏层
	self.substituteBtn = Robot.new()
	self.substituteBtn:setAnchorPoint(0.5,0.5)
	self.substituteBtn:addTo(self, Define.e_zorder_player_layer_substitute)
	-- 默认隐藏
	self.substituteBtn:setVisible(false)
	---------------------------- 测试---------------------------------------------
	-- self.playerPannel[enSiteDirection.SITE_MYSELF]:composeMjGroup({})
	-- self.playerPannel[enSiteDirection.SITE_RIGHT]:composeMjGroup({})
	-- self.playerPannel[enSiteDirection.SITE_LEFT]:composeMjGroup({})
	-- self.playerPannel[enSiteDirection.SITE_OTHER]:composeMjGroup({})
	------------------------------------------------------------------------------
end
return zhongshanmjGamePlayerLayer
