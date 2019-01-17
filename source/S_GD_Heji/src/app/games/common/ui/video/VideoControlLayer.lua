-------------------------------------------------------------
--  @file   VideoControlLayer.lua
--  @brief  录像回放控制层
--  @author ZCQ
--  @DateTime:2016-10-27 15:08:03
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Define = require "app.games.common.Define"
local VideoControlLayer = class("VideoControlLayer", function ()
	local ret = display.newLayer()
	-- ret:setTouchSwallowEnabled(false)
	-- local ret = display.newColorLayer(cc.c3b(255, 255, 255))
	-- ret:setTouchEnabled(false)
	return ret
end)
local kPngPath = "games/common/mj/games/" -- 操作根目录
-- 动作图片
local kPngName = {
	[enOperate.OPERATE_CHI] 	= "game_btn_chi.png",
	[enOperate.OPERATE_PENG] 	= "game_btn_peng.png",
	[enOperate.OPERATE_MING_GANG] 	= "game_btn_gang.png",
	[enOperate.OPERATE_AN_GANG] 	= "game_btn_gang.png",
	[enOperate.OPERATE_JIA_GANG] 	= "game_btn_bugang.png",
	[enOperate.OPERATE_TING] 	= "game_btn_ting.png",
	[enOperate.OPERATE_BU_TING] 	= "game_btn_buting.png",
	[enOperate.OPERATE_DIAN_PAO_HU] 	= "game_btn_hu.png",
	[enOperate.OPERATE_GUO] 	= "game_btn_qi.png",
	[enOperate.OPERATE_JIA_BEI] 	= "btn_jiabei.png",
	[enOperate.OPERATE_ZI_MO_HU] 	= "game_btn_zimo.png",
	[enOperate.OPERATE_TIAN_HU] 	= "game_btn_tianhu.png",
	[enOperate.OPERATE_DIAN_TIAN_HU] = "game_btn_tianhu.png",
	[enOperate.OPERATE_TIAN_TING] 	= "game_btn_tianting.png",
}

-- 摆放起始位置
local kStartPos = {

}
-- 旋转
local kRotateAngles = {
	[Define.site_self] 	= 0,
	[Define.site_right] = -90,
	[Define.site_other] = 360,
	[Define.site_left] 	= 90,
}
-- 透明度数值
local kOpacity 	= 120
-- 按钮开关
local kBtnType = {
    ON  = 0, -- 开
    OFF = 1, -- 关
}

local kEffect = {
	[enOperate.OPERATE_CHI] 		= "AnimationCHI",
	[enOperate.OPERATE_PENG] 		= "AnimationPENG",
	[enOperate.OPERATE_MING_GANG] 	= "AnimationGANG",
	[enOperate.OPERATE_AN_GANG] 	= "AnimationGANG",
	[enOperate.OPERATE_JIA_GANG] 	= "AnimationGANG",
	[enOperate.OPERATE_TING] 		= "AnimationTING",
	[enOperate.OPERATE_DIAN_PAO_HU] = "AnimationHU",
	[enOperate.OPERATE_ZI_MO_HU] 	= "AnimationHU",
	[enOperate.OPERATE_BU_HUA] 		= "AnimationBUHUA",

}

local isSpeed 	= false
local speedTime = 0.3
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:ctor(...)
	self.data = ...
	self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/video_layer.csb")
	self:addChild(self.m_pWidget)
    -- 重设对局回放的位置
    self.djhf = ccui.Helper:seekWidgetByName(self.m_pWidget,"Image_8")
    if self.djhf then 
    	if self.data and self.data.isDDZ then
    		self.djhf:setPositionY(display.height - 350) 
            if IsPortrait then -- TODO
                self.djhf:loadTexture("package_res/games/pokercommon/paodekuai/duijuhuifang.png")
            end
    	elseif self.data and self.data.isGD then
			self.djhf:setPositionY(display.height - 150) 
			self.djhf:loadTexture("package_res/games/pokercommon/paodekuai/duijuhuifang.png")
    	else
    		self.djhf:setPositionY(display.height - 200) 
    	end

    end


	self.actionSpr 	= {} --  动作精灵
	self.actionNode = {} --  动作节点
	self.visibleWidth = cc.Director:getInstance():getVisibleSize().width
	self.visibleHeight = cc.Director:getInstance():getVisibleSize().height

	local actPos = {
		[Define.site_self] = cc.p(self.visibleWidth / 2 + 260, self.visibleHeight / 2 - 260),
		[Define.site_right] = cc.p(self.visibleWidth / 2 + 400, self.visibleHeight / 2 + 150),
		[Define.site_other] = cc.p(self.visibleWidth / 2 - 150, self.visibleHeight / 2 + 180),
		[Define.site_left] = cc.p(self.visibleWidth / 2 - 400, self.visibleHeight / 2 - 100),
	}
	for i=1, 4 do
		-- 创建节点
		local actNode = display.newNode()
		actNode:setPosition(actPos[i])
		actNode:setScale(0.8)
		self:addChild(actNode)
		table.insert(self.actionNode, actNode)
		--  创建动作字
		local pngPath = kPngPath..kPngName[i] -- 默认是吃
		local actSpr = display.newSprite(pngPath)
		local size 	= actSpr:getContentSize()
		-- actSpr:setScale(0.8)
		actSpr:setPosition(cc.p(0 - size.width / 2, size.height / 2))
		actNode:addChild(actSpr)
		table.insert(self.actionSpr, actSpr)
		-- 创建 弃字
		local qiPng = kPngPath..kPngName[enOperate.OPERATE_GUO] -- 默认是吃
		local qiSpr = display.newSprite(qiPng)
		qiSpr:setPosition(cc.p(size.width / 2, size.height / 2))
		local size 	= qiSpr:getContentSize()
		actNode:addChild(qiSpr)
		actNode:setRotation(kRotateAngles[i])
		actNode:setVisible(false)
	end
	-- 初始化控制版块
	self:initContralPanel()
	--  注册监听入口，出口函数
	self:registerScriptHandler( function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end )
end

--[[
-- @brief  创建操作界面函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:initContralPanel()
    self.panelBtn = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_btn")
    self.panelBtn:setVisible(false)

    self:performWithDelay(function ()        -- 发牌结束后显示控制面板
        self.panelBtn:setVisible(true)
    end, 7)
	if self.data and self.data.isDDZ then
		self.panelBtn:setPositionY(50)
	elseif self.data and self.data.isGD then
		self.panelBtn:setPositionY(self.panelBtn:getPositionY()+40)
	end
    
    local speedBtn = ccui.Helper:seekWidgetByName(self.m_pWidget,"speedbtn")
    speedBtn:addTouchEventListener(handler(self,self.onClickedFast))
    self.speedFlag = false -- 快进标识

    if IsPortrait then -- TODO
        local speedLab = ccui.Helper:seekWidgetByName(self.m_pWidget, "speedLab")
        -- speedLab:setString()              -- 默认速度是 1  
        
        if self.data and self.data.isDDZ then
            self.speedLab = display.newTTFLabel({
                text = string.format("当前播放速率：%d倍",1),
                font = "Arial",
                size = speedLab:getFontSize(),
                color = color,
                align = cc.TEXT_ALIGNMENT_LEFT,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
            })
            self.speedLab:setPosition(speedLab:getPosition())
            self.speedLab:addTo(speedLab:getParent())
            -- self.speedLab:setVisible(false)
            self.speedLab:setColor(cc.c3b(158, 251, 36))
            self.speedLab:enableShadow(cc.c4b(0, 0, 0,255),cc.size(2,2));
        else
            self.speedLab = speedLab
        end
    else
        self.speedLab = ccui.Helper:seekWidgetByName(self.m_pWidget, "speedLab")
        self.speedLab:setString(string.format("当前播放速率：%d倍",1))              -- 默认速度是 1  
    	if self.data and self.data.isDDZ then
    		-- self.speedLab:setVisible(false)
    		self.speedLab:setColor(cc.c3b(235, 95, 13))
    	end
    end

    local playBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "playbtn")
    playBtn.select = true    --默认是播放状态
    local playIcon = ccui.Helper:seekWidgetByName(self.m_pWidget, "imgplay")
    self.playBtn = playBtn
    self.playIcon = playIcon    
    playBtn:addTouchEventListener(handler(playIcon, function (pIcon ,pWidget, EventType)
        if EventType == ccui.TouchEventType.ended then
            if(VideotapeManager:getInstance():isPlayingEndState()==false) then --视频是否播放结束
                if pWidget.select then
                    VideotapeManager:getInstance():pause()
                    pIcon:loadTexture("hall/friendRoom/zanTing.png")
                    pWidget.select = false
                else
                    VideotapeManager:getInstance():resume()
                    pIcon:loadTexture("hall/friendRoom/boFang.png")
                    pWidget.select = true
                end
            end
        end
    end))


    self:initExitBtn()
end
--[[
-- @brief  快进按钮函数 q
-- @param  void
-- @return void
--]]
function VideoControlLayer:onClickedFast(pWidget, EventType)
	if EventType == ccui.TouchEventType.ended then
	 	if not self.speedFlag then
	 		cc.Director:getInstance():getScheduler():setTimeScale(3)
	 		self.speedFlag = true
            self.speedLab:setString(string.format("当前播放速率：%d倍",3))
	 	else
	 		cc.Director:getInstance():getScheduler():setTimeScale(1)
	 		self.speedFlag = false
            self.speedLab:setString(string.format("当前播放速率：%d倍",1))
	 	end
	end
end

--[[
-- @brief  退出房间按钮
-- @param  void
-- @return void
--]]
function VideoControlLayer:initExitBtn()
    local returnBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "returnbtn")
    returnBtn:addTouchEventListener(handler(self,function(pData,pWidget,pEventType)
        if pEventType == ccui.TouchEventType.ended then
            VideotapeManager:getInstance():pause()				
			self.playBtn.select = false
			self.playIcon:loadTexture("hall/friendRoom/zanTing.png")

            local _data = {}
            _data.type = 2;
            _data.content = "确定退出战局回放？"
            _data.yesCallback = function()
                kPlaybackInfo:setVideoReturn(true)
                VideotapeManager.releaseInstance()
                MjMediator:getInstance():exitGame()
            end
            _data.cancalCallback = function()
                -- VideotapeManager:getInstance():resume()
            end
            UIManager.getInstance():pushWnd(CommonDialog, _data);
        end
    end))
end


--[[
-- @brief  入口函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:onEnter()

end

--[[
-- @brief  退出函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:onExit()
	self.data = nil
	-- self:stopTimeSchedule()
	-- 反激活回放管理器
	VideotapeManager:getInstance():deactivate()
	cc.Director:getInstance():getScheduler():setTimeScale(1)
end

--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:onClose()
	-- self:stopTimeSchedule()
	-- 反激活回放管理器
	VideotapeManager:getInstance():deactivate()
	cc.Director:getInstance():getScheduler():setTimeScale(1)
end
--[[
-- @brief  显示函数
-- @param  actionType: 操作类型
-- @param  site: 坐位
-- @return void
--]]
function VideoControlLayer:onShowActionLab(data, site)

	self.actionNode[site]:setVisible(true)
	local actPng = kPngPath..kPngName[data.actionID] -- 默认是吃
	self.actionSpr[site]:setTexture(actPng)

	local scaleTo 	= cc.ScaleTo:create(0.2, 0.7)
	local scaleReverse 	= cc.ScaleTo:create(0.2, 1) --  还原
	local delay 	= cc.DelayTime:create(0.5)
	local delay02 	= cc.DelayTime:create(0.5)
	local callFun 	= cc.CallFunc:create(
		function ()
			self.actionNode[site]:setVisible(false)
			-- 显示操作动画
			-- MjMediator:getInstance():on_payerAction(kEffect[data.actionID], 1, site)
			MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjEventUi.ACTION_SHOW_BTN_NTF)
		end
		)
	self.actionSpr[site]:runAction(
		cc.Sequence:create(
			delay02,
			scaleTo,
			scaleReverse,
			delay,
			callFun
			)
		)
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function VideoControlLayer:onHide()

end

return VideoControlLayer
