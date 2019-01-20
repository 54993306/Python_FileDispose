-------------------------------------------------------------
--  @file   Robot.lua
--  @brief  托管按钮
--  @author Zhu Can Qin
--  @DateTime:2016-09-02 17:21:34
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

-- endregion
local Define = require "app.games.common.Define"
local Robot = class("Robot", function ()
	return display.newNode()
end)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function Robot:ctor()
	local bgSprite = display.newSprite("real_res/1004365.png")
    local item_canelshadow = cc.MenuItemSprite:create(bgSprite, nil, nil)
	item_canelshadow:registerScriptTapHandler(handler(self, self.btnCb))
	item_canelshadow:setPosition(cc.p(Define.visibleWidth / 2, 0))
	-- self:addChild(bgSprite)

	-- 取消托管
	local  btnSprite= display.newSprite("real_res/1004264.png")
	local  cancelTextSprite= display.newSprite("real_res/1004366.png")
	cancelTextSprite:setPosition(cc.p(btnSprite:getContentSize().width / 2, btnSprite:getContentSize().height / 2))
	cancelTextSprite:addTo(btnSprite)

	local cancelItem = cc.MenuItemSprite:create(btnSprite, btnSprite)
	cancelItem:registerScriptTapHandler(handler(self, self.btnCb))
	cancelItem:setPosition(cc.p(Define.visibleWidth / 2, cancelItem:getContentSize().height / 2 + 30 ))
	local menu = cc.Menu:create(item_canelshadow, cancelItem)
	menu:setPosition(cc.p(0, 0))
	self:addChild(menu)
end
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function Robot:btnCb()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, enMjMsgSendId.MSG_SEND_SUBSTITUTE, enSubstitusStatus.CANCEL)
	-- 分发取消托管通知
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_CANCEL_SUB_NTF)
    SoundManager.playEffect("btn", false);
end

return Robot
