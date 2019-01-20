-------------------------------------------------------------
--  @file   OperateBtnLayer.lua
--  @brief  操作动作的版块
--  @author Zhu Can Qin
--  @DateTime:2016-08-24 16:39:47
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local currentModuleName = ...
local Mj 				= require "app.games.common.mahjong.Mj"
local Define 			= require "app.games.common.Define"
local LocalEvent 		= require "app.hall.common.LocalEvent"
local SelectOperateManager   	= import(".SelectOperateManager", currentModuleName)
local OperateBtnLayer = class("OperateBtnLayer", function ()
	local ret = ccui.Widget:create()
    ret:ignoreContentAdaptWithSize(false)
    ret:setAnchorPoint(cc.p(-1, 0.5))
    return ret
end)
-- 按钮图片
local kBtnPngs = {
	[enOperate.OPERATE_CHI] 		= "real_res/1004328.png",
	[enOperate.OPERATE_PENG] 		= "real_res/1004336.png",
	[enOperate.OPERATE_MING_GANG] 	= "real_res/1004331.png",
	[enOperate.OPERATE_JIA_GANG] 	= "real_res/1004326.png",
	[enOperate.OPERATE_AN_GANG] 	= "real_res/1004331.png",
	[enOperate.OPERATE_TING] 		= "real_res/1004341.png",
	[enOperate.OPERATE_DIAN_PAO_HU] = "real_res/1004332.png",
	[enOperate.OPERATE_ZI_MO_HU] 	= "real_res/1004344.png",
	[enOperate.OPERATE_QIANG_GANG_HU] 	= "real_res/1004333.png",
	[enOperate.OPERATE_DI_HU] 		= "real_res/1004330.png",
	[enOperate.OPERATE_YANGMA] 		= "real_res/1004342.png",
	[enOperate.OPERATE_DIAN_DI_HU] 		= "real_res/1004330.png",
	[enOperate.OPERATE_DI_XIA_HU] = "real_res/1004332.png",
	[enOperate.OPERATE_GANG_KAI] = "games/common/mj/games/game_btn_gangkai.png",
	[enOperate.OPERATE_GUO] 		= "real_res/1004338.png",
	[enOperate.OPERATE_JIA_BEI] 	= "games/common/mj/games/btn_jiabei.png",
	[enOperate.OPERATE_BU_TING] 	= "real_res/1004327.png",
	[enOperate.OPERATE_TIAN_TING] 	= "real_res/1004340.png",
	[enOperate.OPERATE_TIAN_HU] 	= "real_res/1004339.png",
	[enOperate.OPERATE_DIAN_TIAN_HU] 	= "real_res/1004339.png",
    [enOperate.OPERATE_ZHUA_PAI]    = "real_res/1004343.png",
    ["DEFAULT"] = "real_res/1004329.png", -- 默认图片
}
if IsPortrait then -- TODO
    kBtnPngs[enOperate.OPERATE_GANG_KAI] = "real_res/1004332.png"
    kBtnPngs[enOperate.OPERATE_ASK_BU_HUA]    = "real_res/1004325.png"
end

--[[
-- @brief  构造函数
-- @param  operateList：显示操作的数列
-- @return void
--]]
function OperateBtnLayer:ctor()
	-- 加入吃或者碰时选择管理器
	self.selectManager = SelectOperateManager.new()
	self.playSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
	self.operateSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM)
	self.handlers = {}

    -- 动作超时
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_ACTION_TIME_OUT_NTF,
        handler(self, self.onActionTimeOut)))
    -- 操作完成通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_ACTION_FINISH_NTF,
        handler(self, self.onActionFinish)))

    -- 打牌开始通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjPlayEvent.GAME_PLAY_CARD_NTF,
        handler(self, self.onRunPlayCardNtf)))

    self.showedTingArrow = false -- 记录是否发送过显示听牌按钮的消息, 以减少发送次数
    self.needActions = {}
end

--[[
-- @brief  析构函数
-- @param  void
-- @return void
--]]
function OperateBtnLayer:dtor()

end

function OperateBtnLayer:hidePassCardImg()
	local event = cc.EventCustom:new(LocalEvent.PassCard)
	event.isVisible = false
	cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

--[[
-- @brief  打牌动作
-- @param  void
-- @return void
--]]
function OperateBtnLayer:onPlayCard()
	Log.d("------OperateBtnLayer:onPlayCard")
	self:onShowActions()
	--查胡数据
	local players = self.playSystem:gameStartGetPlayers()
    local tingState = players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.TING)
    if tingState == enTingStatus.TING_TRUE then
    	local tingCards = self.playSystem:gameStartLogic_getHuMjs()
    	local playData = self.playSystem:getPlayCardDatas()
		local huTable = self.operateSystem:getHuCardByTingCard(playData.playCard);
		if huTable and #huTable > 0 and tingCards ~= huTable then
			self.playSystem:gameStartLogic_setHuMjs(huTable)
		end
		tingCards = self.playSystem:gameStartLogic_getHuMjs()
    end
end

--[[
-- @brief  恢复对局动作
-- @param  void
-- @return void
--]]
function OperateBtnLayer:onShowActions(foceHideArrow)
	if foceHideArrow == nil then foceHideArrow = false end
	local needActions = self.operateSystem:getActions()
	Log.d("------onShowActions", needActions);

	local players   = self.playSystem:gameStartGetPlayers()
    local tingState = players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.TING)

    local hasTing, hasTianTing = false, false
    for i = #needActions, 1, -1 do
        if needActions[i] == enOperate.OPERATE_TING_RECONNECT then -- 仅提示箭头
            hasTing = true
            table.remove(needActions, i)
        elseif needActions[i] == enOperate.OPERATE_TING then
            hasTing = true
            if not self.playSystem:getIsHasTing() then -- 不显示听按钮
                table.remove(needActions, i)
            elseif tingState == enTingStatus.TING_TRUE then -- 听牌状态下不再显示听
                table.remove(needActions, i)
            end
        elseif needActions[i] == enOperate.OPERATE_TIAN_TING then -- 天听按钮始终显示
            hasTing = true
            hasTianTing = true
        end
    end
    if not foceHideArrow and hasTing and not VideotapeManager.getInstance():isPlayingVideo() then -- 非回放状态下判断是否需要显示听牌箭头
        local showTingArrow = hasTianTing or tingState ~= enTingStatus.TING_TRUE -- 天听时或者不处于听牌状态下时, 可以显示箭头
        self:performWithDelay(function()
                MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_TING_ARROW_NTF, showTingArrow)
            end, 0.01)
    end

	self.needActions = needActions

    if #needActions > 0 then
        Log.d("--wangzhi--显示操作按钮--",needActions)
	    self:onShowLab(needActions)
    end

	---------------------------回放相关--------------------------------------
	if VideotapeManager.getInstance():isPlayingVideo() then
		self:finishStateAndHide()
	end
	-------------------------------------------------------------------------
end


--[[
-- @brief  显示函数
-- @param  operateList：{1, 2}显示操作的数列
-- @return void
--]]
function OperateBtnLayer:onShowLab(operateList)
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
	local posX = Define.g_action_start_x
    Log.d("--wangzhi--需要显示的按钮个数--",operateList)
	for i=1, #operateList do
        if nil == operateList[i] then
            reportLog("nil == operateList[" .. i .. "]")
            break
        end

        local pngImg    = kBtnPngs[operateList[i]]
		if not pngImg then
            reportLog("operateList[" .. i .. "] 找不到图片资源", "pngImg", operateList[i])

            printError("OperateBtnLayer:onShow 找不到图片资源", kBtnPngs[operateList[i]])

            pngImg = kBtnPngs.DEFAULT
		else
    		-- operateList[i] = enOperate.OPERATE_PENG   -- 测试代码勿删
            local filePath = cc.FileUtils:getInstance():fullPathForFilename(pngImg)
            local re, err = io.exists(filePath)
            if not re then
                reportLog("[" .. i .. "] pngImg " .. pngImg .. " 文件不存在 err: " .. err, "pngImg", operateList[i])
                pngImg = kBtnPngs.DEFAULT
            end
        end

		--抢杠胡的位置左移
		if operateList[i] == enOperate.OPERATE_QIANG_GANG_HU then
			posX = posX - 40
		end

		local btn_operator = display.newSprite(pngImg)
	        :pos(posX, Define.g_action_start_y + 80)
	        :addTo(self)
	    if operateList[i] ~= enOperate.OPERATE_GUO  then 
	    	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/friendRoom/spin.csb")
		    local armature = ccs.Armature:create("spin")
		    armature:getAnimation():play("Animation1")
            if not IsPortrait then -- TODO
                btn_operator:addChild(armature);
            end
    		self:setEfPosition(operateList[i],armature)
	    end

	    posX = posX - btn_operator:getContentSize().width
	    cc(btn_operator):addComponent(enComponentName.BUTTON_ACTION):exportMethods()
	    btn_operator:onClicked(handler(self, self.onBtnClick))
	    -- 设置标志
	    btn_operator:setButtonTag(operateList[i])
	    -- 保存按钮
	    self.actionBtn[operateList[i]] = btn_operator
	end
end
--根据不同的图片动态调整特效位置
function OperateBtnLayer:setEfPosition(operatorType,widget)
    Log.d("--wangzhi--进入设置按钮特效--")
    if IsPortrait then -- TODO
        if operatorType == enOperate.OPERATE_CHI then
            widget:pos(4,6)
        elseif operatorType == enOperate.OPERATE_PENG then
            widget:pos(0,2)
        elseif operatorType == enOperate.OPERATE_MING_GANG
            or operatorType == enOperate.OPERATE_AN_GANG then
            widget:pos(0,5)
        elseif operatorType == enOperate.OPERATE_JIA_GANG
            or operatorType == enOperate.OPERATE_YANGMA then
            widget:pos(0,9)
        elseif operatorType == enOperate.OPERATE_JIA_GANG then
            widget:pos(0,9)
        elseif operatorType == enOperate.OPERATE_TING then
            widget:pos(2,1)
        elseif operatorType == enOperate.OPERATE_DIAN_PAO_HU 
            or operatorType == enOperate.OPERATE_ZI_MO_HU 
            or operatorType == enOperate.OPERATE_TIAN_HU
            or operatorType == enOperate.OPERATE_DIAN_TIAN_HU
            or operatorType == enOperate.OPERATE_DI_HU
            or operatorType == enOperate.OPERATE_DIAN_DI_HU
            or operatorType == enOperate.OPERATE_DI_XIA_HU
            or operatorType == enOperate.OPERATE_GANG_KAI 
            or operatorType == enOperate.OPERATE_ZHUA_PAI 
            or operatorType == enOperate.OPERATE_ASK_BU_HUA 
            or operatorType == enOperate.OPERATE_QIANG_GANG_HU then
                widget:setScale(1.12, 1.12)
                widget:pos(15,7)
        elseif operatorType == enOperate.OPERATE_BU_TING then
            widget:pos(2,9)
        elseif operatorType == enOperate.OPERATE_TIAN_TING then
            widget:pos(2,0)
        end
    else
    	widget:setScale(1.12, 1.12)
    	widget:pos(12,5)
    end
end

--[[
-- @brief  隐藏函数
-- @param  void
-- @return void
--]]
function OperateBtnLayer:onHide()
	self:removeAllChildren()
	self:setVisible(false)
end

--[[
-- @brief  隐藏按钮
-- @param  void
-- @return void
--]]
function OperateBtnLayer:hideBtn()
	for k, v in pairs(self.actionBtn)  do
		v:setVisible(false)
	end
end

--[[
-- @brief  显示按钮
-- @param  void
-- @return void
--]]
function OperateBtnLayer:showBtn()
	for k, v in pairs(self.actionBtn)  do
		v:setVisible(true)
	end
end

--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function OperateBtnLayer:onClose()
	-- 移除监听
    table.walk(self.handlers, function(h)
        MjMediator.getInstance():getEventServer():removeEventListener(h)
    end)
    self.handlers = {}
end

--[[
-- @brief  动作超时操作函数
-- @param  void
-- @return void
--]]
function OperateBtnLayer:onActionTimeOut()
	self:onHide()
end

--[[
-- @brief  操作完成通知函数
-- @param  void
-- @return void
--]]
function OperateBtnLayer:onActionFinish()

end

--[[
-- @brief  打牌开始动画通知函数
-- @param  void
-- @return void
--]]
function OperateBtnLayer:onRunPlayCardNtf(event)    
    self:hidePassCardImg()
    
	local value = unpack(event._userdata)
	--  隐藏
	self:finishStateAndHide()
end

function OperateBtnLayer:sendPassLocalEvent()
	local event = cc.EventCustom:new(LocalEvent.PassCard)
	event.isVisible = true
	cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

--[[
-- @brief  按钮点击函数
-- @param  void
-- @return void
--]]
function OperateBtnLayer:onBtnClick(event, tag)
	Log.d("OperateBtnLayer:onBtnClick", tag)
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

	local removeFlag = true

    if not IsPortrait then -- TODO
        local flag = self:dealSpecificBtnEvent(event, tag)
        removeFlag = flag == nil or flag
    end

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
                    Log.d("--sendGuo--GUO--")
                    Log.d(debug.traceback())
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
        if lChosedGang and #lChosedGang > 0 then
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
                        Log.d("--sendGuo--OPERATE_AN_GANG--")
                        Log.d(debug.traceback())
		    			self.operateSystem:sendGuoOperate();
                        if IsPortrait then -- TODO
                            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_TING_ARROW_NTF, not foceHideArrow)
                        end
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
        if lChosedGang and #lChosedGang > 0 then
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
        if lChosedGang and #lChosedGang > 0 then
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
                        Log.d("--sendGuo--OPERATE_JIA_GANG--")
                        Log.d(debug.traceback())
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
                    Log.d("--sendGuo--OPERATE_YANGMA--")
                    Log.d(debug.traceback())
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
    elseif tag == enOperate.OPERATE_ZHUA_PAI then
        self.operateSystem:sendActionMsg(tag)
    elseif IsPortrait and tag == enOperate.OPERATE_ASK_BU_HUA then -- TODO
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
        Log.d("--sendGuo--OPERATE_GUO--")
        Log.d(debug.traceback())
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
			local pngImg = kBtnPngs[enOperate.OPERATE_BU_TING]
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
			local pngImg = kBtnPngs[enOperate.OPERATE_TING]
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
			local pngImg 	= kBtnPngs[enOperate.OPERATE_BU_TING]
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
			local pngImg 	= kBtnPngs[enOperate.OPERATE_TIAN_TING]
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

--  用于重新，处理地方麻将自定义的操作按钮点击事件
function OperateBtnLayer:dealSpecificBtnEvent(event, tag)
    return true
end

--  处理杠操作事件
function OperateBtnLayer:dealGangEvent(operateType, content)
    if #content <= 0 then
        return
    end
    self:hideBtn()

    if #content == 1 then
        local lActionCard = content[1].card
        local lCardGroup = content[1].choseGruop
        table.sort(lCardGroup,function(a,b) return a>b end)
        if #lCardGroup == 1 then
            self.operateSystem:sendActionMsg(operateType, lActionCard, lCardGroup[1]);
            self:finishStateAndHide()
        else
            self.selectChiPanel = self.selectManager:getOperateType(enOperate.OPERATE_CHI)
            self:addChild(self.selectChiPanel)
            
            self.selectChiPanel:onShow(lCardGroup, function(actionID, cardGroup)
                if actionID == enOperate.OPERATE_GUO then
                    self:finishStateAndHide()
                    Log.d("--sendGuo--dealGangEvent--if--")
                    Log.d(debug.traceback())
                    self.operateSystem:sendGuoOperate();
                else
                    self.operateSystem:sendActionMsg(operateType, lActionCard, cardGroup);
                    self:finishStateAndHide()
                end
            end )
            local visibleWidth = cc.Director:getInstance():getVisibleSize().width
            local visibleHeight = cc.Director:getInstance():getVisibleSize().height
            local panelSize = self.selectChiPanel:getContentSize()
            self.selectChiPanel:setPosition(cc.p(visibleWidth * 0.3 + panelSize.width * 0.5, visibleHeight * 0.5 - 180))           
        end
    else
        self.selectAnGangPanel = self.selectManager:getOperateType(enOperate.OPERATE_AN_GANG)
        self.selectAnGangPanel:setOperateType(operateType)
        self:addChild(self.selectAnGangPanel)
        local lGangList = { }
        for i, v in pairs(content) do
            table.insert(lGangList, v.card)
        end
        table.sort(lGangList,function(a,b) return a>b end)
        self.selectAnGangPanel:onShow(lGangList, function(actionID, cardID)
            if actionID == enOperate.OPERATE_GUO then
                self:finishStateAndHide()
                Log.d("--sendGuo--dealGangEvent--else--")
                Log.d(debug.traceback())
                self.operateSystem:sendGuoOperate()
            elseif actionID == operateType then
                local lHasMore = false
                local lCardGroup = { }
                for i, v in pairs(content) do
                    local lCurrCard = v.card
                    if lCurrCard == cardID then
                        lCardGroup = v.choseGruop
                        if #lCardGroup > 1 then
                            lHasMore = true
                        end
                        break
                    end
                end
                if lHasMore then
                    self.selectChiPanel = self.selectManager:getOperateType(enOperate.OPERATE_CHI)
                    self:addChild(self.selectChiPanel)
                    self.selectChiPanel:onShow(lCardGroup, function(actionID, cardGroup)
                        if actionID == enOperate.OPERATE_GUO then
                            self:finishStateAndHide()
                            Log.d("--sendGuo--dealGangEvent--OPERATE_GUO--")
                            Log.d(debug.traceback())
                            self.operateSystem:sendGuoOperate();
                        else
                            self.operateSystem:sendActionMsg(operateType, cardID, cardGroup);
                            self:finishStateAndHide()
                        end
                    end )
                    local panelSize = self.selectChiPanel:getContentSize()
                    self.selectChiPanel:setPosition(cc.p(display.width * 0.3 + panelSize.width * 0.5, display.cy - 180))
                else
                    self.operateSystem:sendActionMsg(actionID, cardID, lCardGroup[1]);
                    self:finishStateAndHide()
                end
            end
        end )
        local panelSize = self.selectAnGangPanel:getContentSize()
        self.selectAnGangPanel:setPosition(cc.p(display.cx + panelSize.width * 0.5, display.cy - 180))
    end
end

--[[
-- @brief  因为action动作可能会跟着开局，恢复对局，打牌等协议一起过来所以这里要发结束通知
-- @param  void
-- @return void
--]]
function OperateBtnLayer:finishStateAndHide()
	-- 发送结束当前状态
	local curState = MjMediator.getInstance():getStateManager():getCurState()
	local stateNtfs = {
		[enGamePlayingState.STATE_START] 		= enMjNtfEvent.GAME_FINISH_NTF,
		[enGamePlayingState.STATE_RESUME]  		= enMjNtfEvent.GAME_RESUME_FINISH_NTF,
		[enGamePlayingState.STATE_PLAY_CARD]  	= enMjNtfEvent.GAME_PUT_OUT_FINISH_NTF,
		[enGamePlayingState.STATE_ACT_ANIMATE]	= enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF,
		[enGamePlayingState.STATE_DISTR]  		= enMjNtfEvent.GAME_DISPENSE_FINISH_NTF,
	}
	if stateNtfs[curState] then
		MjMediator.getInstance():getEventServer():dispatchCustomEvent(stateNtfs[curState])
	end
	self:onHide()
end

--[[
-- @brief  检测是否要显示过二次确认
-- @param  点击确定要调用的方法
-- @return 返回是否要显示过二次确认ui
--]]
function OperateBtnLayer:checkIsHasGuoQueRen(actionType)
   if(self.playSystem:getIsHasGuoQueRen()) then
		local actions= self.operateSystem:getActions()--self.operateSystem:getOperateSystemDatas()
		for i = 1, #actions do
			if(actions~=nil and #actions>0) then
				if ((actions[i] == enOperate.OPERATE_ZI_MO_HU
					or actions[i] == enOperate.OPERATE_DIAN_PAO_HU
					or actions[i] == enOperate.OPERATE_TIAN_HU) ) then
						if(self.playSystem:getGuoQueRenUIShowOnce() ==false) then --没显示过
							local data = {}
							data.type = 2;
							data.title = "提示";
							data.yesTitle  = "确定";
							data.cancelTitle = "取消";
							data.content = "您确定放弃胡牌吗?"
							data.yesCallback = function()
								self:onBtnClick(nil,self.m_guoActionType);
							end
							UIManager.getInstance():pushWnd(CommonDialog, data);
							self.playSystem:setGuoQueRenUIShowOnce(true);--对话框只出现一次
							Log.d("点击过要二次确认框");
							self.m_guoActionType = actionType --记录下动作类型
							return true;
						end
				end
			end
		end
	end
	return false
end

function OperateBtnLayer:addBtnPngs(index,image)
    kBtnPngs[index] = image
end

function OperateBtnLayer:getBtnPngs()
	return kBtnPngs
end

----------------------------
-- 在这里增加或删除操作选项
function OperateBtnLayer:modifyActionList(operateList)
	if #operateList > 0 then
		table.insert(operateList, 1, enOperate.OPERATE_GUO)
	end
	return operateList
end

return OperateBtnLayer
