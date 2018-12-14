--
-- Author: Jinds
-- Date: 2017-07-06 11:51:43
--
local currentModuleName = ...
local Mj 				= require "app.games.common.mahjong.Mj"
local LocalEvent 		= require "app.hall.common.LocalEvent"
local Define 			= require "app.games.common.Define"
-- local SelectOperateManager   	= import(".SelectOperateManager", currentModuleName)
local OperateBtnLayer = require("app.games.common.ui.operatelayer.OperateBtnLayer")
local huizhoumjOperateBtnlayer = class("huizhoumjOperateBtnlayer", OperateBtnLayer)

---------------add------------------
function huizhoumjOperateBtnlayer:addBaoDaGeTip(parent, str, fontSize)
	 local tipBg = ccui.Scale9Sprite:create(cc.rect(30, 30, 1, 1),"games/common/gameCommon/hu_di.png")
	  --"res/hall/Common/toast_bg.png")
	 tipBg:setPosition(display.cx ,340)
	 tipBg:setContentSize(800, 90)
	 tipBg:setName("tipBg")
	 self:addChild(tipBg)
	 str = "特别提示：报大哥后只能胡大哥牌，建议不要更换牌型。"
	 local tipLabel = cc.Label:createWithTTF(str, "hall/font/fangzhengcuyuan.TTF", fontSize)
	 tipBg:addChild(tipLabel)
	 tipLabel:setAnchorPoint(cc.p(0,1))
	 tipLabel:setColor(display.COLOR_BLACK)
	 tipLabel:setPosition(cc.p(30,63))

	 tipBg:runAction(cca.seq({cca.delay(5), cca.hide()}))

	 -- self:performWithDelay(function ()
	 -- 	if tipBg ~= nil then
	 -- 		tipBg:setVisible(false)
	 -- 	end
	 -- 	end, 1.5)
end

-------------------------------------

--[[
-- @brief  显示函数
-- @param  operateList：{1, 2}显示操作的数列
-- @return void
--]]
function huizhoumjOperateBtnlayer:onShowLab(operateList)
	self:hidePassCardImg()
	self:removeAllChildren()  -- 每次进来会把身上的对象清除一遍，所以在构造函数里初始没有用
	self:setVisible(true)
	self.actionBtn = {}
	local posX 		= 0
	local preSize 	= cc.size(0, 0)
	local prePos 	= cc.p(0, 0)
	-- 默认显示弃
	operateList = self:modifyActionList(operateList)

    local function reportLog(desc, tag, operate)
        Log.d("只显示弃按钮 enOperate", enOperate)
        Log.d("只显示弃按钮 kBtnPngs", kBtnPngs)
        Log.d("只显示弃按钮 operateList", operateList)
        Log.d("只显示弃按钮 actionDatas", self.operateSystem:getActionDatas())
        if desc then Log.d("只显示弃按钮 desc", desc) end
        if tag then Log.d("只显示弃按钮 tag", tag) end
        if operate then Log.d("只显示弃按钮 operate", operate) end
    end
    if #operateList <= 0 then
        reportLog("operateList table error")
    end
    if #operateList == 1 and operateList[1] == enOperate.OPERATE_GUO then
        reportLog("operateList has only guo")
    end

	-- 听显示状态
	self.tingState 	= false
	posX = Define.g_action_start_x
	for i=1, #operateList do
        if nil == operateList[i] then
            reportLog("nil == operateList[" .. i .. "]")
            break
        end
		local pngImg
		if nil == self:getBtnPngs()[operateList[i]] then
            reportLog("operateList[" .. i .. "] 找不到图片资源", "pngImg", operateList[i])
			-- printError("OperateBtnLayer:onShow 找不到图片资源", self:getBtnPngs()[operateList[i]])
			pngImg = kBtnPngs.DEFAULT
		end
----------------------------------modify---------------------------------------
		Log.d("<jinds>: kid operatebtnlayer")
		if operateList[i] == enOperate.OPERATE_BAO_DA_GE then
			pngImg = "package_res/games/huizhoumj/games/img_bao_da_ge.png"
			-- Toast.getInstance():show("特别提示：报大哥后只能胡大哥牌，建议不要更换牌型")


		else
			pngImg 	= self:getBtnPngs()[operateList[i]]
		end
	    local filePath = cc.FileUtils:getInstance():fullPathForFilename(pngImg)
        local re, err = io.exists(filePath)
        if not re then
            reportLog("[" .. i .. "] pngImg " .. pngImg .. " 文件不存在 err: " .. err, "pngImg", operateList[i])
            pngImg = kBtnPngs.DEFAULT
        end
        
		--抢杠胡的位置左移
		if operateList[i] == enOperate.OPERATE_QIANG_GANG_HU then
			posX = posX - 40
		end


----------------------------------------------------------------------------------------


		local btn_operator = display.newSprite(pngImg)
	        :pos(posX, Define.g_action_start_y + 80)
	        :addTo(self)
	    if operateList[i] ~= enOperate.OPERATE_GUO  then 
	    	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/friendRoom/spin.csb")
		    local armature = ccs.Armature:create("spin")
		    armature:getAnimation():play("Animation1")
    		-- btn_operator:addChild(armature);
    		self:setEfPosition(operateList[i],armature)
	    end

	    posX = posX - btn_operator:getContentSize().width
	    cc(btn_operator):addComponent(enComponentName.BUTTON_ACTION):exportMethods()
	    btn_operator:onClicked(handler(self, self.onBtnClick))
	    -- 设置标志
	    btn_operator:setButtonTag(operateList[i])
	    -- 保存按钮
	    self.actionBtn[operateList[i]] = btn_operator

	------------------add-----------------------------------------
		if operateList[i] == enOperate.OPERATE_BAO_DA_GE then
		    self:addBaoDaGeTip(btn_operator, "", 30)
		end

	------------------------------------------------------------------
	end
end


--[[
-- @brief  按钮点击函数
-- @param  void
-- @return void
--]]
function huizhoumjOperateBtnlayer:onBtnClick(event, tag)
	Log.d("huizhoumjOperateBtnlayer:onBtnClick",tag)
	--点击过是否要二次确认框只要有胡，选择过都要先出现二次确认框
	if(tag ~= enOperate.OPERATE_ZI_MO_HU
	and tag ~= enOperate.OPERATE_DIAN_PAO_HU
	and tag ~= enOperate.OPERATE_TIAN_HU ) then
		local isGuo = self:checkIsHasGuoQueRen(tag)
		if(isGuo)then
			Log.d("检测到过要二次确认");
			return;
		end
	end

	local tipBg = self:getChildByName("tipBg")
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
            table.sort(lGangList,function(a,b) return a>b end)
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
                table.sort(anGList,function(a,b) return a>b end)
		    	-- 隐藏按钮
		    	self:hideBtn()
		    	self.selectAnGangPanel:onShow(anGList, function(actID, card)
		    		if actID == enOperate.OPERATE_GUO then
		    			-- 显示按钮
		    			-- self:showBtn()
		    			self:finishStateAndHide()
		    			self.operateSystem:sendGuoOperate();
                        MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_TING_ARROW_NTF, true)
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
            table.sort(lGangList,function(a,b) return a>b end)
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
            table.sort(lGangList,function(a,b) return a>b end)
            self:dealGangEvent(tag, lGangList)
			removeFlag = false
        else
		    local addGangCards = self.operateSystem:getActionDatas().addGangCards
            table.sort(addGangCards,function(a,b) return a>b end)
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
    elseif tag == enOperate.OPERATE_ZHUA_PAI or tag == enOperate.OPERATE_ASK_BU_HUA then
        self.operateSystem:sendActionMsg(tag)
	elseif tag == enOperate.OPERATE_DIAN_PAO_HU then
		self.operateSystem:sendDianPaoHuOperate()
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
			Log.d("OperateBtnLayer:onBtnClick 听")
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
			Log.d("OperateBtnLayer:onBtnClick 不听")
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
			Log.d("OperateBtnLayer:onBtnClick 天听")
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
			Log.d("OperateBtnLayer:onBtnClick 不天听")
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
		self.operateSystem:sendDianPaoHuOperate()
	elseif tag == enOperate.OPERATE_QIANG_GANG_HU then
		self.operateSystem:sendQiangGangHuOperate()
	-----------------------add1------------------------
	elseif tag == enOperate.OPERATE_BAO_DA_GE then
		self.operateSystem:sendBaoDaGeOperate()
	end
	---------------------------------------------------
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

--[[
-- @brief  恢复对局动作
-- @param  void
-- @return void
--]]
function huizhoumjOperateBtnlayer:onShowActions(foceHideArrow)
	if foceHideArrow == nil then foceHideArrow = false end
	local needActions = self.operateSystem:getActions()
	Log.d("------onShowActions", needActions);

	local players   = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()
    local huHintNeedTing = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):getIsHuHintNeedTing()
    local tingState = players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.TING)

    dump(needActions)
    Log.d("<jinds>: ", self.playSystem:getIsHasTing())

	-- 不需要听牌操作的麻将, 从动作中删除听
	for i = #needActions, 1, -1 do
		if not self.playSystem:getIsHasTing() then
			-- if needActions[i] == enOperate.OPERATE_TING or needActions[i] == enOperate.OPERATE_TIAN_TING then
			if needActions[i] == enOperate.OPERATE_TING or needActions[i] == enOperate.OPERATE_TIAN_TING or (needActions[i] == enOperate.OPERATE_TING_RECONNECT) then

				table.remove(needActions, i)
				if not VideotapeManager.getInstance():isPlayingVideo() then
					-- 存在听操作, 发送消息显示指示箭头
					self:performWithDelay(function()
						if tingState == enTingStatus.TING_TRUE then    -- 听牌的状态下不需要再出现箭头
							MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_TING_ARROW_NTF, false)
						else
							MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_TING_ARROW_NTF, not foceHideArrow)
						end		 
					end, 0.01)
				end
			end
		end

		if tingState == enTingStatus.TING_TRUE and needActions[i] == enOperate.OPERATE_TING then
			table.remove(needActions, i)
		end

		-- if needActions[i] == enOperate.OPERATE_TING_RECONNECT then
		-- 	table.remove(needActions, i)
		-- end
	end

	self.needActions = needActions

	if #needActions > 0 then
		for i = #needActions, 1, -1 do
			if (needActions[i] == enOperate.OPERATE_TING or needActions[i] == enOperate.OPERATE_TIAN_TING or
				(needActions[i] == enOperate.OPERATE_TING_RECONNECT and self.playSystem:getGameStartDatas().firstplay == kUserInfo:getUserId())) and
			 	not VideotapeManager.getInstance():isPlayingVideo() then
				-- 存在听操作, 发送消息显示指示箭头
				self:performWithDelay(function()
					MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_TING_ARROW_NTF, not foceHideArrow)
				end, 0.01)
			end
			if needActions[i] == enOperate.OPERATE_TING_RECONNECT then
                table.remove(needActions, i)
            end
		end
		self:onShowLab(needActions)
	end
	---------------------------回放相关--------------------------------------
	if VideotapeManager.getInstance():isPlayingVideo() then
		self:finishStateAndHide()
	end
	-------------------------------------------------------------------------
end

return huizhoumjOperateBtnlayer