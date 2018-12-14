local Mj 				= require "app.games.common.mahjong.Mj"
local Define 			= require "app.games.common.Define"
local operateBtnLayer = import("app.games.common.ui.operatelayer.OperateBtnLayer")

local shantoumjOperateBtnLayer = class("shantoumjOperateBtnLayer", operateBtnLayer)

function shantoumjOperateBtnLayer:ctor(...)
	self.super.ctor(self, ...)
	self:addBtnPngs(enOperate.OPERATE_HAI_DI_LAO, "games/common/mj/games/game_btn_zimo.png")
	self:addBtnPngs(enOperate.OPERATE_DIAN_HAI_DI_LAO, "games/common/mj/games/game_btn_hu.png")
	self:addBtnPngs(enOperate.OPERATE_GANG_KAI, "games/common/mj/games/game_btn_zimo.png")
	self:addBtnPngs(enOperate.OPERATE_GANG_HOU_PAO, "games/common/mj/games/game_btn_hu.png")
end

--[[
-- @brief  按钮点击函数
-- @param  void
-- @return void
--]]
function shantoumjOperateBtnLayer:onBtnClick(event, tag)
	Log.d("shantoumjOperateBtnLayer:onBtnClick",tag)
	--点击过是否要二次确认框只要有胡，选择过都要先出现二次确认框
	if(tag ~= enOperate.OPERATE_ZI_MO_HU
	and tag ~= enOperate.OPERATE_DIAN_PAO_HU
	and tag ~= enOperate.OPERATE_TIAN_HU ) then
		local isGuo = self:checkIsHasGuoQueRen(tag)
		if(isGuo)then
			Log.i("检测到过要二次确认");
			return;
		end
	end
	
	local tipBg = display.getRunningScene():getChildByName("repPrompt")
	if tipBg then
		tipBg:removeFromParent()
	end

	local removeFlag = true
	if tag == enOperate.OPERATE_CHI then
		local chiCardsGroup = self.operateSystem:getActionDatas().chiCards
		if #chiCardsGroup > 1 then
			self.selectChiPanel = self.selectManager:getOperateType(enOperate.OPERATE_CHI)
			local panelSize = self.selectChiPanel:getContentSize()
			self:addChild(self.selectChiPanel)
			self:hideBtn()
			self.selectChiPanel:onShow(chiCardsGroup, function(actID, chiGroup)
				if actID == enOperate.OPERATE_GUO then
					self:finishStateAndHide()
					self.operateSystem:sendGuoOperate();
				elseif actID == enOperate.OPERATE_CHI then
					-- 发送吃操作到服务器
					self.operateSystem:sendChiOperate(chiGroup)
					self:finishStateAndHide()
				end
			end)
			local visibleWidth = cc.Director:getInstance():getVisibleSize().width
    		local visibleHeight = cc.Director:getInstance():getVisibleSize().height
			self.selectChiPanel:setPosition(cc.p(visibleWidth / 2 + panelSize.width / 2,  visibleHeight / 2 - 180))
			removeFlag = false
		else
			-- 发送吃操作到服务器
			self.operateSystem:sendChiOperate(chiCardsGroup[1])
		end
	elseif tag == enOperate.OPERATE_AN_GANG then
    	local lChosedGang = self.operateSystem:getActionDatas().ChosedGang
        if #lChosedGang > 0 then
            local lGangList = {}
            for i, v in pairs(lChosedGang) do
                if v.gangType == tag then
                    table.insert(lGangList, v)
                end
            end
            
            self:dealGangEvent(tag, lGangList)
			removeFlag = false
        else
		    local anGangGroups = self.operateSystem:getAnGangGroupCards()
		    if #anGangGroups > 1 then
		    	self.selectAnGangPanel = self.selectManager:getOperateType(enOperate.OPERATE_AN_GANG)
		    	self.selectAnGangPanel:setOperateType(enOperate.OPERATE_AN_GANG)
		    	self:addChild(self.selectAnGangPanel)
		    	local anGList = {}
		    	for i=1,#anGangGroups do
		    		table.insert(anGList, anGangGroups[i][1])
		    	end
		    	-- 隐藏按钮
		    	self:hideBtn()
		    	self.selectAnGangPanel:onShow(anGList, function(actID, card)
		    		if actID == enOperate.OPERATE_GUO then
		    			-- 显示按钮
		    			-- self:showBtn()
		    			self:finishStateAndHide()
		    			self.operateSystem:sendGuoOperate();
		    		elseif actID == enOperate.OPERATE_AN_GANG then
		    			-- 发送暗杠操作给服务器
		    			self.operateSystem:sendAnGangOperate(card)
		    			self:finishStateAndHide()
		    		end
		    	end)
		    	local visibleWidth  = cc.Director:getInstance():getVisibleSize().width
    	    	local visibleHeight = cc.Director:getInstance():getVisibleSize().height
    	    	local panelSize 	= self.selectAnGangPanel:getContentSize()
    	    	self.selectAnGangPanel:setPosition(cc.p(visibleWidth / 2 + panelSize.width / 2,  visibleHeight / 2 - 180))
			    removeFlag = false
		    else
		    	-- 发送暗杠操作给服务器
		    	self.operateSystem:sendAnGangOperate(anGangGroups[1][1])
		    end
        end
	elseif tag == enOperate.OPERATE_PENG then
		-- 发送暗杠操作给服务器
		self.operateSystem:sendPengOperate()
	elseif tag == enOperate.OPERATE_MING_GANG then
    	local lChosedGang = self.operateSystem:getActionDatas().ChosedGang
        if #lChosedGang > 0 then
            local lGangList = {}
            for i, v in pairs(lChosedGang) do
                if v.gangType == tag then
                    table.insert(lGangList, v)
                end
            end
            
            self:dealGangEvent(tag, lGangList)
			removeFlag = false
        else
		    self.operateSystem:sendMingGangOperate()
        end
	elseif tag == enOperate.OPERATE_JIA_GANG then
    	local lChosedGang = self.operateSystem:getActionDatas().ChosedGang
        if #lChosedGang > 0 then
            local lGangList = {}
            for i, v in pairs(lChosedGang) do
                if v.gangType == tag then
                    table.insert(lGangList, v)
                end
            end
            
            self:dealGangEvent(tag, lGangList)
			removeFlag = false
        else
		    local addGangCards = self.operateSystem:getActionDatas().addGangCards
		    if #addGangCards > 1 then
		    	self.selectAnGangPanel = self.selectManager:getOperateType(enOperate.OPERATE_AN_GANG)
		    	self.selectAnGangPanel:setOperateType(enOperate.OPERATE_JIA_GANG)
		    	self:addChild(self.selectAnGangPanel)
		    	self:hideBtn()
		    	self.selectAnGangPanel:onShow(addGangCards, function(actID, card)
		    		if actID == enOperate.OPERATE_GUO then
		    			-- self:showBtn()
		    			self:finishStateAndHide()
		    			self.operateSystem:sendGuoOperate();
		    		elseif actID == enOperate.OPERATE_JIA_GANG then
		    			self.operateSystem:sendJiaGangOperate(card)
		    			self:finishStateAndHide()
		    		end
		    	end)
		    	local visibleWidth = cc.Director:getInstance():getVisibleSize().width
		    	local visibleHeight = cc.Director:getInstance():getVisibleSize().height
		    	local panelSize = self.selectAnGangPanel:getContentSize()
		    	self.selectAnGangPanel:setPosition(cc.p(visibleWidth * 0.5 + panelSize.width * 0.5, visibleHeight * 0.5 - 180))
		    	removeFlag = false
		    else
		    	self.operateSystem:sendJiaGangOperate(addGangCards[1])
		    end
        end
	elseif tag == enOperate.OPERATE_ZI_MO_HU then
		self.operateSystem:sendZiMoHuOperate()
	elseif tag == enOperate.OPERATE_DI_HU then
		self.operateSystem:sendDiHuOperate()
	elseif tag == enOperate.OPERATE_YANGMA then
		local yangmaGroups = self.operateSystem:getActionDatas().yangmaCards
		if #yangmaGroups > 1 then
			self.selectAnGangPanel = self.selectManager:getOperateType(enOperate.OPERATE_AN_GANG)
			self.selectAnGangPanel:setOperateType(enOperate.OPERATE_YANGMA)
			self:addChild(self.selectAnGangPanel)
			self:hideBtn()
			self.selectAnGangPanel:onShow(yangmaGroups, function(actID, card)
				if actID == enOperate.OPERATE_GUO then
					self:finishStateAndHide()
					self.operateSystem:sendGuoOperate();
				elseif actID == enOperate.OPERATE_YANGMA then
					self.operateSystem:sendYangmaOperate(card)
					self:finishStateAndHide()
				end
			end)
			local visibleWidth = cc.Director:getInstance():getVisibleSize().width
			local visibleHeight = cc.Director:getInstance():getVisibleSize().height
			local panelSize = self.selectAnGangPanel:getContentSize()
			self.selectAnGangPanel:setPosition(cc.p(visibleWidth * 0.5 + panelSize.width * 0.5, visibleHeight * 0.5 - 180))
			removeFlag = false
		else
			self.operateSystem:sendYangmaOperate(yangmaGroups[1])
		end
	elseif tag == enOperate.OPERATE_DIAN_DI_HU then
		self.operateSystem:sendDianDiHuOperate()	
	elseif tag == enOperate.OPERATE_DI_XIA_HU then
		self.operateSystem:sendDiXiaHuOperate()	
	elseif tag == enOperate.OPERATE_GANG_KAI then
        local lActionCard = self.operateSystem:getDoorCard()
		self.operateSystem:sendActionMsg(tag, lActionCard)
	elseif tag == enOperate.OPERATE_HAI_DI_LAO then
		self.operateSystem:sendHaiDiLaoOperate()
	elseif tag == enOperate.OPERATE_DIAN_HAI_DI_LAO then
		self.operateSystem:sendDianHaiDiLaoOperate()
	elseif tag == enOperate.OPERATE_DIAN_PAO_HU then
		self.operateSystem:sendDianPaoHuOperate()
	elseif tag == enOperate.OPERATE_GANG_HOU_PAO then
		self.operateSystem:sendGangHouPaoOperate()
	elseif tag == enOperate.OPERATE_GUO then
		local needActions = self.needActions
       
		-- 听特殊处理
		for i = 1, #needActions do
			if (needActions[i] == enOperate.OPERATE_TING)
				or (needActions[i] == enOperate.OPERATE_TIAN_TING) then
				local players = self.playSystem:gameStartGetPlayers()
				players[enSiteDirection.SITE_MYSELF]:setState(enCreatureEntityState.TING, enTingStatus.TING_FALSE)
				MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_TING_NTF, false)
				if self.playSystem:getIsHuHintNeedTing() then
					MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_TING_ARROW_NTF, false)
				end
			end
		end

		if #needActions > 0 and needActions[1] == enOperate.OPERATE_GUO then
            table.remove(needActions, 1)
        end

        self.operateSystem:sendGuoOperate(needActions);
        self.sendPassLocalEvent()
	elseif tag == enOperate.OPERATE_TING then
		-- 听牌处理
		local players = self.playSystem:gameStartGetPlayers()
		local huHintNeedTing = self.playSystem:getIsHuHintNeedTing()
		-- 不在听的状态
		if self.tingState == false  then
			-- 设置自己的状态为听
			print("OperateBtnLayer:onBtnClick 听")
			players[enSiteDirection.SITE_MYSELF]:setState(enCreatureEntityState.TING, enTingStatus.TING_BTN_ON)
			local pngImg = self:getBtnPngs()[enOperate.OPERATE_BU_TING]
			self.actionBtn[tag]:setTexture(pngImg)
			self.tingState = true
			for k, v in pairs(self.actionBtn) do
				if k == enOperate.OPERATE_MING_GANG or k == enOperate.OPERATE_JIA_GANG or k == enOperate.OPERATE_PENG or k == enOperate.OPERATE_AN_GANG or k == enOperate.OPERATE_CHI then
					v:setVisible(false)
				end
			end
			MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_TING_NTF, true)
			if huHintNeedTing then
				MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_TING_ARROW_NTF, true)
			end

		else
			print("OperateBtnLayer:onBtnClick 不听")
			-- 改变按钮为不听
			local pngImg = self:getBtnPngs()[enOperate.OPERATE_TING]
			self.actionBtn[tag]:setTexture(pngImg)
			-- 恢复不听的状态
			players[enSiteDirection.SITE_MYSELF]:setState(enCreatureEntityState.TING, enTingStatus.TING_BTN_OFF)
			self.tingState = false
			MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_TING_NTF, false)
			if huHintNeedTing then
				MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_TING_ARROW_NTF, false)
			end
			for k, v in pairs(self.actionBtn) do
				v:setVisible(true)
			end
		end
		removeFlag = false
	elseif tag == enOperate.OPERATE_TIAN_TING then
		-- 听牌处理
		local players = self.playSystem:gameStartGetPlayers()
		-- 不在听的状态
		if self.tingState == false  then
			-- 设置自己的状态为听
			print("OperateBtnLayer:onBtnClick 天听")
			players[enSiteDirection.SITE_MYSELF]:setState(enCreatureEntityState.TING, enTingStatus.TIAN_TING_BTN_ON)
			local pngImg 	= self:getBtnPngs()[enOperate.OPERATE_BU_TING]
			self.actionBtn[tag]:setTexture(pngImg)
			self.tingState = true
			for k, v in pairs(self.actionBtn) do
				if k == enOperate.OPERATE_MING_GANG or k == enOperate.OPERATE_JIA_GANG or k == enOperate.OPERATE_PENG or k == enOperate.OPERATE_AN_GANG or k == enOperate.OPERATE_CHI then
					v:setVisible(false)
				end
			end
			MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_TIAN_TING_NTF, true)
		else
			print("OperateBtnLayer:onBtnClick 不天听")
			-- 改变按钮为不听
			local pngImg 	= self:getBtnPngs()[enOperate.OPERATE_TIAN_TING]
			self.actionBtn[tag]:setTexture(pngImg)
			-- 恢复不听的状态
			players[enSiteDirection.SITE_MYSELF]:setState(enCreatureEntityState.TING, enTingStatus.TIAN_TING_BTN_OFF)
			self.tingState = false
			for k, v in pairs(self.actionBtn) do
				v:setVisible(true)
			end
			MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_TIAN_TING_NTF, false)
		end
		removeFlag = false
	elseif tag == enOperate.OPERATE_TIAN_HU then
		self.operateSystem:sendTianHuOperate()
	elseif tag == enOperate.OPERATE_DIAN_TIAN_HU then
		self.operateSystem:sendDianTianHuOperate()
	elseif tag == enOperate.OPERATE_QIANG_GANG_HU then
		self.operateSystem:sendQiangGangHuOperate()
	end
	-- 过/ 听/ 天听按钮不改变胡牌提示
	if tag ~= enOperate.OPERATE_TIAN_TING and tag ~= enOperate.OPERATE_TING and tag ~= enOperate.OPERATE_GUO then
		-- 隐藏指示箭头
		MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_TING_ARROW_NTF, false)
	end
	-- 隐藏操作栏
	if removeFlag then
		self:finishStateAndHide()
	end

end

return shantoumjOperateBtnLayer