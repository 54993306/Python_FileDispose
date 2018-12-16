-------------------------------------------------------------
--  @file   SelectChiPanel.lua
--  @brief  显示吃
--  @author Zhu Can Qin
--  @DateTime:2016-09-06 18:05:50
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Define 			= require "app.games.common.Define"
local Mj 				= require "app.games.common.mahjong.Mj"
local currentModuleName = ...
local SelectBasePanel 	= import(".SelectBasePanel", currentModuleName)
local SelectChiPanel 	= class("SelectChiPanel", SelectBasePanel)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function SelectChiPanel:ctor()
	SelectChiPanel.super.ctor(self)
	-- 设置自身在屏幕中的位置
	self:setPosition(cc.p(Define.visibleWidth / 2 + 80, Define.g_action_start_y))
	self.operateSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM)
end
--[[
-- @brief  显示函数
-- @param  content 选择列表
-- @return void
--]]
function SelectChiPanel:onShow(content, callBack)
	SelectChiPanel.super.ctor(self, content)
	local posX 			= 0
	local panelWidth 	= 0
	local paneLHeight 	= 0
	local size
	for i = 1, #content do
		local chi 	= self:chiComponent(content[i], callBack)
		size 		= chi:getContentSize()
		panelWidth 	= panelWidth + size.width
		if size.height > paneLHeight then
			paneLHeight = size.height
		end
		if i > 1 then
			posX = posX + size.width
		end
		chi:setPosition(cc.p(posX, 0))
		self:addChild(chi)
	end

	local pngImg 	= "games/common/mj/games/game_btn_qi.png"
	local guoBtn = display.newSprite(pngImg)
	        :addTo(self)
	cc(guoBtn):addComponent(enComponentName.BUTTON_ACTION):exportMethods()
	guoBtn:onClicked(handler(self, function()
		self:removeFromParent()
		callBack(enOperate.OPERATE_GUO, content[i])
	end))
	guoBtn:setPosition(cc.p(panelWidth + guoBtn:getContentSize().width, paneLHeight / 2))
	panelWidth = panelWidth + guoBtn:getContentSize().width
	self:setContentSize(cc.size(panelWidth, paneLHeight))
end

--[[
-- @brief  隐藏函数
-- @param  void
-- @return void
--]]
function SelectChiPanel:onHide()
	SelectChiPanel.super.onHide(self)
end

--[[
-- @brief  单个吃函数
-- @param  content 牌列表
-- @return void
--]]
function SelectChiPanel:chiComponent(content, callBack)
	local chiPath = "games/common/mj/games/bg_action_chi.png"
	local chiBg = cc.ui.UIImage.new(chiPath)
	local actionCard = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM):getActionCard()
	actionCard = actionCard and actionCard or MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):getActionCard()

	-- 绑定按钮
	cc(chiBg):addComponent(enComponentName.BUTTON_ACTION):exportMethods()
	chiBg:onClicked(handler(self, function()
		self:removeFromParent()
		callBack(enOperate.OPERATE_CHI,content)
	end))
	local chiBgSize = chiBg:getContentSize()
	local posX 	= 58
	for i = 1, #content do
		local mj 	= Mj.new(enMjType.MYSELF_NORMAL, content[i])
		local size 	= mj:getContentSize()
		if i > 1 then
			posX = posX + size.width * (52 / size.width)
		end
		mj:setPosition(cc.p(posX, chiBgSize.height - 8))
		-- 缩小
		mj:setScale(52 / size.width, 70 / size.height)
		chiBg:addChild(mj)

		-- 添加动作牌的变暗效果
		if content[i] == actionCard then
			Util.addCardEffect(mj, cc.size(0, 16))
		end
	end
	return chiBg
end

return SelectChiPanel
