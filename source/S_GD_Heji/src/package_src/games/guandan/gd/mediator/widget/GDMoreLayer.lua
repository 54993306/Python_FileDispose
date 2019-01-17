--
-- Author: Machine
-- Date: 2017-11-30
-- 桌面點擊更多時的 退出和設置界面
--
-- 速配开始倒计时
local GDRoomView = require("package_src.games.guandan.gd.mediator.widget.GDRoomView")
local GDMoreLayer = class("GDMoreLayer", GDRoomView);
local GDGameEvent = require("package_src.games.guandan.gd.data.GDGameEvent")
local PokerRoomSettingView = require("package_src.games.guandan.gdcommon.widget.PokerRoomSettingView")
local PokerEventDef = require("package_src.games.guandan.gdcommon.data.PokerEventDef")
local PokerRoomRuleView = require("package_src.games.guandan.gdcommon.widget.PokerRoomRuleView")
local UmengClickEvent = require("app.common.UmengClickEvent")

function GDMoreLayer:initView()
    self.btn_setting = ccui.Helper:seekWidgetByName(self.m_pWidget, "Button_setting");
    self.btn_setting:addTouchEventListener(handler(self, self.onClicked));

    self.btn_exit = ccui.Helper:seekWidgetByName(self.m_pWidget, "Button_exit");
    self.btn_exit:addTouchEventListener(handler(self, self.onClicked));

    self.btn_rule = ccui.Helper:seekWidgetByName(self.m_pWidget, "Button_rule");
    self.btn_rule:addTouchEventListener(handler(self, self.onClicked));

    self.m_pWidget:addTouchEventListener(handler(self, self.onClicked));
    self.m_pWidget:setEnabled(true)
end

----------------------------------------------
-- @desc 按钮点击处理 
-- @pram pWidget :点击的ui
--       EventType:点击的类型
----------------------------------------------
function GDMoreLayer:onClicked(pWidget, EventType)
	if EventType == ccui.TouchEventType.ended then
    	kPokerSoundPlayer:playEffect("btn");
    	if pWidget == self.btn_setting then
            PokerUIManager:getInstance():pushWnd(PokerRoomSettingView)
            NativeCallUmengEvent(UmengClickEvent.GDGameSetting)
    	elseif pWidget == self.btn_exit then
            if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
                HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_JIESAN)
            else
                HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT)
            end 
        elseif pWidget == self.btn_rule then
            local info = {}
            info.gamepath = "guandan.gd"
            PokerUIManager.getInstance():pushWnd(PokerRoomRuleView, info);
            NativeCallUmengEvent(UmengClickEvent.GDGameRuleButton)
    	end

    	self:onBack()
	end
end

------------------------------------------------
-- @desc 显示此界面
------------------------------------------------
function GDMoreLayer:showshow()
	self.m_pWidget:setVisible(true)
end

------------------------------------------------
-- @desc 隐藏此界面
------------------------------------------------
function GDMoreLayer:hidehide()
	self.m_pWidget:setVisible(false)
end

------------------------------------------------
-- @desc 去掉此界面
------------------------------------------------
function GDMoreLayer:onBack()
	HallAPI.EventAPI:dispatchEvent(GDGameEvent.HIDEMORELAYER)
end

return GDMoreLayer