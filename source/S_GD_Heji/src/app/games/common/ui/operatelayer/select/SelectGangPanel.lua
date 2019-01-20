-------------------------------------------------------------
--  @file   SelectGangPanel.lua
--  @brief  杠版块
--  @author Zhu Can Qin
--  @DateTime:2016-09-07 11:54:38
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Define 			= require "app.games.common.Define"
local Mj 				= require "app.games.common.mahjong.Mj"
local currentModuleName = ...
local SelectBasePanel 	= import(".SelectBasePanel", currentModuleName)
local SelectGangPanel 	= class("SelectGangPanel", SelectBasePanel)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function SelectGangPanel:ctor()
	SelectGangPanel.super.ctor(self)
	-- 设置自身在屏幕中的位置
	self:setPosition(cc.p(Define.visibleWidth / 2 + 80, Define.g_action_start_y))
	self.operateSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM)
	self.operateType = -1
end

function SelectGangPanel:setOperateType(opType)
	self.operateType = opType
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function SelectGangPanel:onShow(content, callBack)
	SelectGangPanel.super.onShow(self, content)
	local posX 			= 0
	local panelWidth 	= 0
	local paneLHeight 	= 0
	local scaleX = 69
	local scaleY = 91
	for i = 1, #content do
		local gangBg = "real_res/1004302.png"
		local gangSp = cc.ui.UIImage.new(gangBg)
		self:addChild(gangSp)
		-- 绑定按钮
		cc(gangSp):addComponent(enComponentName.BUTTON_ACTION):exportMethods()
		gangSp:onClicked(handler(self, function()
			local ty = self.operateType
			self:removeFromParent()
			callBack(ty, content[i])
		end))
		local mj 	= Mj.new(enMjType.MYSELF_NORMAL, content[i])
		local size 	= mj:getContentSize()
		local gangSpSize = gangSp:getContentSize()
		mj:setPosition(cc.p(gangSpSize.width / 2, gangSpSize.height - 20))
		-- 缩小
		mj:setScale(scaleX / size.width, scaleY / size.height)
		gangSp:addChild(mj)
		panelWidth 	= panelWidth + gangSpSize.width
		if gangSpSize.height > paneLHeight then
			paneLHeight = gangSpSize.height
		end
		if i > 1 then
			posX = posX - gangSpSize.width 
		end
		gangSp:setPosition(cc.p(posX, gangSpSize.height / 2))
	end

	local pngImg 	= "real_res/1004338.png"
	local guoBtn = display.newSprite(pngImg)
	        -- :pos(posX, 0)
	        :addTo(self)
	cc(guoBtn):addComponent(enComponentName.BUTTON_ACTION):exportMethods()
	guoBtn:onClicked(handler(self, function()
		self:removeFromParent()
		callBack(enOperate.OPERATE_GUO)
	end))
	guoBtn:setPosition(cc.p(panelWidth / 2 + guoBtn:getContentSize().width / 2, guoBtn:getContentSize().height / 2))
	if IsPortrait then -- TODO
		guoBtn:setScale(0.9)
	end
	panelWidth = panelWidth + guoBtn:getContentSize().width
	self:setContentSize(cc.size(panelWidth, paneLHeight))
end

--[[
-- @brief  隐藏函数
-- @param  void
-- @return void
--]]
function SelectGangPanel:onHide()
	SelectGangPanel.super.onHide(self)
end

--[[
-- @brief  过按钮返回
-- @param  void
-- @return void
--]]
function SelectGangPanel:onBtnClick()
	
end

--[[
-- @brief  点击选择按钮函数
-- @param  void
-- @return void
--]]
function SelectGangPanel:onSelectBtnClick()
	-- print("SelectGangPanel:onSelectBtnClick")
end

return SelectGangPanel