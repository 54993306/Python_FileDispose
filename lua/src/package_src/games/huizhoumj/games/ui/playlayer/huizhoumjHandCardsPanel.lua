--
-- Author: Jinds
-- Date: 2017-08-01 19:49:21
--
local Define 		= require "app.games.common.Define"
local Mj    		= require "app.games.common.mahjong.Mj"
local LocalEvent 	= require "app.hall.common.LocalEvent"
local HandCardsPanel = require("app.games.common.ui.playlayer.HandCardsPanel")
local huizhoumjHandCardsPanel = class("huizhoumjHandCardsPanel", HandCardsPanel)

--[[
-- @brief  出牌逻辑操作
-- @param  void
-- @return void
--]]
function huizhoumjHandCardsPanel:putOutCard(index, posX, posY)
    Log.d("huizhoumjHandCardsPanel:putOutCard", index, posX, posY)
------------------------------------------------add------------------------------------------------
	local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local playerCount = sys:getGameStartDatas().playerNum
 --    local playData  = sys:getGameStartDatas().rRemainCount
 --    dump(playData)
    local remainCards = SystemFacade:getInstance():getRemainPaiCount()
    if remainCards < 0 then
        remainCards = 0
    end
    local maCount = tonumber(getMaCount())

    Log.d("<jinds>: maCount",maCount, remainCards)
    if remainCards < maCount or remainCards == maCount then
    	-- Toast.getInstance():show("最后一张不能打出")
        return
    end
-----------------------------------------------------------------------------------------------------------


	local mjValue = self.handCardsObjs[index]:getValue()
	local player = self.playSystem:gameStartGetPlayerBySite(enSiteDirection.SITE_MYSELF)

	MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_SET_CHAHU_BUTTON_STATUS_NTF, 2);

	-- -- --查胡数据
	local huTable = self.operateSystem:getHuCardByTingCard(mjValue);
	if #huTable > 0 then
		Log.d("------putOutCard huTable", huTable);
		self.playSystem:gameStartLogic_setHuMjs(huTable);
	end

    -- 隐藏指示箭头
    self:performWithDelay(function()
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_TING_ARROW_NTF, false)
        end, 0.05)

	-- 从队列里面移除打出去的麻将对象
	self:removeHandMjByIndex(index)
	-- 处理出牌逻辑，播放出牌动画
	self:runPlayOutAction(cc.p(posX, posY), mjValue, index, self:judgeIsHandBuHua(mjValue), delay)
	-- 手动补花的流程不同
	if self:judgeIsHandBuHua(mjValue) then
        self:sendBuHuaOperate(mjValue)
	else
		self:performWithDelay(function() -- 考虑到性能因素, 延迟0.2秒发送消息(以及其他处理)
				self:sendPlayOutOperate(mjValue)
			end, 0.2)
	end

	-- 打牌通知
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_PLAY_CARD_NTF, mjValue)
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_CANCEL_SELECTED_TING_CARD_NTF)
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_CANCEL_SELECTED_CHAHU_NTF)
    -- 取消选中的麻将对象
    MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_CANCEL_SELECTED_CHAPAI_NTF)
end

return huizhoumjHandCardsPanel