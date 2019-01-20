-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
-- endregion
local Mj            = require "app.games.common.mahjong.Mj"
local Define        = require "app.games.common.Define"
-- local PlayerNode    = require "app.games.common.ui.bglayer.PlayerNode"
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local Clock         = require ("app.games.common.ui.bglayer.Clock")
-- local PlayerHead        = require "app.games.common.ui.bglayer.PlayerHead"
local Tricks        = require("app.games.common.custom.MJTricks")
local GameLayerBase     = import("..GameLayerBase")
local BgLayer       = class("BgLayer", GameLayerBase)

local KEY_GSM_ANIM = "KEY_GSM_ANIM"
local KEY_WIFI_ANIM = "KEY_WIFI_ANIM"

local kRuleWidth = 500 -- 规则文字宽度
if IsPortrait then -- TODO
    kRuleWidth = 400
end
local kRuleFontSize = 25 -- 规则字体大小
--------------------------
-- 创建规则提示
function BgLayer:createRuleTip()
    Log.i("BgLayer:createRuleTip")
    local ruleStrRet = kFriendRoomInfo:getRuleStrRet(kRuleWidth, kRuleFontSize)
    -- 非回放且大于一行时, 将规则说明放到GameUIView中
    if not VideotapeManager.getInstance():isPlayingVideo() and ruleStrRet.rows > 1 then
        self:addRuleBtn()
    elseif ruleStrRet.rows > 0 then
        self:createCustomRuleTip(ruleStrRet.ruleStr)
    end
end

---------------------
-- 添加规则按钮
function BgLayer:addRuleBtn()
    local kRuleBtnSize = cc.size(100, 70)
    -- 规则触摸容器
    self.ruleBtnLayout = ccui.Layout:create()
    self.ruleBtnLayout:setContentSize(kRuleBtnSize)
    self:addChild(self.ruleBtnLayout)
    self.ruleBtnLayout:setAnchorPoint(cc.p(0.5, 0.5))
    self.ruleBtnLayout:setPosition(cc.p(display.cx, display.cy - 45))

    -- 文字
    self.ruleBtnLabel = cc.Label:createWithTTF("规则", "res_TTF/1016001.TTF", 25)
    self.ruleBtnLabel:setColor(cc.c3b(238,253,72))
    self.ruleBtnLabel:setPosition(cc.p(kRuleBtnSize.width *0.5, kRuleBtnSize.height *0.5))
    self.ruleBtnLayout:addChild(self.ruleBtnLabel)

    -- self.ruleBtnLayout:setBackGroundColorType(1)
    -- self.ruleBtnLayout:setBackGroundColor(cc.c3b(255, 0, 0))
    -- 下划线
    local labelSize = self.ruleBtnLabel:getContentSize()
    local startX = self.ruleBtnLabel:getPositionX() - labelSize.width * self.ruleBtnLabel:getAnchorPoint().x
    local startY = self.ruleBtnLabel:getPositionY() - labelSize.height * self.ruleBtnLabel:getAnchorPoint().y
    local points = {}
    points[1] = {startX, startY}
    points[2] = {startX + labelSize.width, startY}
    local ruleBtnLineParams = {}
    ruleBtnLineParams.borderColor = cc.c4f(255 / 255, 254 / 255, 173 / 255, 1)
    ruleBtnLineParams.borderWidth = 1.5
    self.ruleBtnLine = display.newLine(points, ruleBtnLineParams)
    self.ruleBtnLine:addTo(self.ruleBtnLabel:getParent())

    -- 触摸事件
    self.ruleBtnLayout:setTouchEnabled(true)
    self.ruleBtnLayout:setTouchSwallowEnabled(true)
    self.ruleBtnLayout:addTouchEventListener(function (pWidget,EventType)
            if EventType == ccui.TouchEventType.ended then
                -- local widget = tolua.cast(pWidget, ccui.Widget)
                Log.i("ended", pWidget:getTouchEndPosition().x)
                MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_setRuleVisible, true)
                if IsPortrait then -- TODO
                    local UmengClickEvent = require("app.common.UmengClickEvent")
                    NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameRuleButton)
                end
                -- UIManager.getInstance():pushWnd(DebugWnd)
            elseif EventType == ccui.TouchEventType.began then
                Log.i("began", pWidget:getTouchBeganPosition().x)
            end
        end)
end

--------------------------
-- 创建普通规则
-- @param size 规则文字的大小尺寸, 在此只用到了width
-- @string str 规则文字
function BgLayer:createCustomRuleTip(str)

    if str == nil then
        str = ""
    end
    -- str = "随便测试一下长规ad则看看 是什么形式 随便测试一 下长规则看看是什么形式 下长规则看看是什么形式"
    -- 初始化规则背景
    --self.ruleTextBg = ccui.Scale9Sprite:create(cc.rect(10, 10, 2, 2), "real_res/1004405.png")
    local kRuleBtnSize = cc.size(70, 40)
    self.ruleTextBg = ccui.Layout:create()
    self.ruleTextBg:setContentSize(kRuleBtnSize)
    self.ruleTextBg:setAnchorPoint(cc.p(0.5, 1))
    if IsPortrait then -- TODO
        self.ruleTextBg:setPosition(cc.p(display.cx, display.cy - 30*Define.mj_common_scale))
    else
        self.ruleTextBg:setPosition(cc.p(display.cx - 7, display.cy - 30*Define.mj_common_scale))
    end

    self.ruleTextBg:addTo(self)

    self.ruleText = cc.Label:createWithTTF(str, "res_TTF/1016001.TTF", 25)
    self.ruleText:setWidth(kRuleWidth) -- 通过此方法可以设置最大宽度, 同时其contentSize也为自动适应的大小
    -- self.ruleText:setAnchorPoint(cc.p(0.5, 0.5))
    self.ruleText:setColor(cc.c3b(238,253,72))
    -- ruleText:setDimensions(size.width,size.height) -- 通过此方法可以设置大小和高度, 一旦设置后, setMaxLineWidth就无效了, 其contentSize为设置的Dimensions的大小
    self.ruleText:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self.ruleText:setAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    self.ruleText:addTo(self.ruleTextBg)

    local size = self.ruleText:getContentSize()
    size.width = size.width + 10
    size.height = size.height + 2
    self.ruleTextBg:setContentSize(size)
    if IsPortrait then -- TODO
        self.ruleText:setPosition(cc.p(size.width * 0.5-5, size.height * 0.5))
    else
        self.ruleText:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
    end
end

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function BgLayer:ctor()
	Log.i("BgLayer:ctor isResume=".. (isResume and "true" or "false"))
	self._clock    = nil
    self.headNode  = nil
	-- 速配界面
	self.matchLoadingLayer = nil
	-- 续局准备界面
	self.continueReadyLayer = nil
	-- 准备
	self.m_continueReadySprites = {}
	-- 玩家头像
	self.arrHeadNode = {}
    self.brocastContent = {}
    -- 游戏系统
    self.gamePlaySystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
	-- 背景
	local bgSprite = display.newSprite("real_res/1004471.png")
    bgSprite:setScaleX(Define.visibleWidth / (bgSprite:getContentSize().width))
    bgSprite:setScaleY(Define.visibleHeight / (bgSprite:getContentSize().height))
    bgSprite:setPosition(cc.p(Define.visibleWidth /2, Define.visibleHeight /2))
	bgSprite:addTo(self)

    -- local subSprite = display.newSprite("real_res/1004324.png")
    -- subSprite:setPosition(cc.p(Define.visibleWidth * 0.5, Define.visibleHeight * 0.5))
    -- subSprite:setScale(Define.mj_common_scale)
    -- self:addChild(subSprite)

    self:addGameName()

    self:createRuleTip()

    -- 显示背景界面
    self:initView()

    local syText = ""
    local currCount     = SystemFacade:getInstance():getCurrentGameCount() or 0
    local totalCount    = SystemFacade:getInstance():getTotalGameCount() or 0
    ---------------- 回放相关----------------------------------------
    if VideotapeManager.getInstance():isPlayingVideo() then
        local jushu  = kPlaybackInfo:getCurrentGamesNum()
        syText = string.format("第 %d 局",jushu)
    else
        syText = string.format("第 %d/%d 局", (currCount<=totalCount) and currCount or totalCount, totalCount)
    end
    ------------------------------------------------------------------


    self._shengyu = ccui.Text:create()
    self._shengyu:setString(syText)
    self._shengyu:setFontSize(25)
    self._shengyu:setColor(cc.c3b(238,253,72))
    self._shengyu:setFontName("res_TTF/1016001.TTF")
    self._shengyu:setAnchorPoint(cc.p(0.5,0.5))
    if IsPortrait then -- TODO
        self._shengyu:setPosition(cc.p(Define.visibleWidth/2,Define.visibleHeight/2 + 104*Define.mj_common_scale))
    else
        self._shengyu:setPosition(cc.p(Define.visibleWidth/2 - 7,Define.visibleHeight/2 + 120*Define.mj_common_scale))
    end
    self._shengyu:addTo(self)

    --播放背景音乐
    self._shengyu:performWithDelay(function ()
        _playGameMusic();
    end, 0.5)
end

-- latters: 指定麻将后缀, 如{"红中"}
function BgLayer:addGameName(latters)
    local offX = 80 -- 左右偏移的距离
    local offY = 40  --距离中间的距离
    local gameName = kFriendRoomInfo:getRoomBaseInfo().gameName -- 游戏名称(必须含有麻将)
    Log.i("BgLayer:addGameName() gameName", gameName)
    if gameName then
        local extName = latters or {"麻将","推倒胡","杠杠胡","红中宝","换换"}
        if IsPortrait then -- TODO
            offY = 30  --距离中间的距离
            extName = latters or {"麻将","推倒胡","杠杠胡","红中宝","做牌","鸡胡"}
        end
        local majInx = nil
        for i,v in pairs(extName) do
            if not majInx then
                majInx = string.find(gameName, v)
            end
        end
        if not majInx then
            if IsPortrait then -- TODO
                majInx = #gameName - #extName[1] + 1
            else
                majInx = #gameName - #extName + 1
            end
        end
        local newName = string.sub(gameName, 1, majInx - 1)
        extName = string.sub(gameName, majInx, #gameName)
        Log.i("newName", newName, extName, #gameName)
        local gameLabel = cc.Label:createWithTTF(newName, "res_TTF/1016001.TTF", 50)
        gameLabel:setColor(display.COLOR_BLACK)
        gameLabel:setOpacity(0.2 * 255)
        gameLabel:setAnchorPoint(cc.p(1, 0.5))
        gameLabel:setPosition(cc.p(Define.visibleWidth * 0.5 - offX, Define.visibleHeight * 0.5 + offY))
        self:addChild(gameLabel)

        local majLabel = cc.Label:createWithTTF(extName, "res_TTF/1016001.TTF", 50)
        majLabel:setColor(display.COLOR_BLACK)
        majLabel:setOpacity(0.2 * 255)
        majLabel:setAnchorPoint(cc.p(0, 0.5))
        majLabel:setPosition(cc.p(Define.visibleWidth * 0.5 + offX, Define.visibleHeight * 0.5 + offY))
        self:addChild(majLabel)
    end
end

--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function BgLayer:initView()
    -- self:showMatchLoading()
    -- 初始化头像
    -- self:initHeadView()
    -- 添加闹钟
    if not self._clock then
        self._clock = Clock.new()
        self._clock:addTo(self)
    end
    self.handlers = {}
    -- 动作结束刷新剩余牌数
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF,
        handler(self, self.refreshRemainCount)))

       -- 监听动作通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_ACT_ANIMATE_START_NTF,
        handler(self, self.onAction)))

end

--[[
-- @brief  动作监听函数
-- @param  void
-- @return void
--]]
function BgLayer:onAction()
    local operateSysData = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM):getOperateSystemDatas()
    local site  = self.gamePlaySystem:getPlayerSiteById(operateSysData.userid)
    --定缺和取消听牌不走时钟和光标
    if operateSysData.actionID ~= enOperate.OPERATE_DINGQUE and operateSysData.actionID ~= enOperate.OPERATE_CANCEL_TING then
        self._clock:setThePoint(site, enClockType.PLAY_CARD)
    end
end

--[[
-- @brief  创建头像函数
-- @param  void
-- @return void
--]]
function BgLayer:createHead()
    Log.i("BgLayer:showHead....")
    self:removeHead()
    self.headNode = UIFactory.createPlayerHead(_gameType);--PlayerHead:new()
    self.headNode.m_pWidget:addTo(self, 10)
    self.headNode:setDelegate(self);
    self.headNode:onInit()
    -- self.headNode:setGameLayer()
end

function BgLayer:removeHead()
    if self.headNode ~= nil and self.headNode.m_pWidget ~= nil then
        self.headNode.m_pWidget:removeFromParent()
        self.headNode = nil
    end
end

function BgLayer:onClose()
    -- 移除监听
    table.walk(self.handlers, function(h)
        MjMediator.getInstance():getEventServer():removeEventListener(h)
    end)
    self.handlers = {}
end
--[[
-- @brief  进入函数
-- @param  void
-- @return void
--]]
function BgLayer:onEnter()
end
--[[
-- @brief  退出函数
-- @param  void
-- @return void
--]]
function BgLayer:onExit()
end

function BgLayer:getRoomTypePic(mutil)
	if mutil == 1 then
		return "game_pic_room_cainiao.png"
	elseif mutil == 2 then
		return "game_pic_room_gaoshou.png"
	elseif mutil == 4 then
		return "game_pic_room_dashi.png"
	elseif mutil == 10 then
		return "game_pic_room_queshen.png"
	end
end

function BgLayer:showCardCount()
	local count = 0

	if self.isResume == true then
		count = MjProxy:getInstance()._gameStartData.rRemainCount
	else
		count = MjProxy:getInstance()._gameStartData.rRemainCount
	end
    self._remainCount = count
	if count == nil then
		count = 0
	end
    local gameid = MjProxy:getInstance():getGameId()
    if gameid == Define.gameId_xuzhou then
	    count = math.ceil(count/2)
    elseif gameid == Define.gameId_changzhou then
        count = count
    end
	local remainPaiCountBg = display.newSprite("#other_gang_poker.png")
    local remainPaiCountBg_1 = display.newSprite("#other_gang_poker.png")
    if gameid == Define.gameId_xuzhou then
        remainPaiCountBg_1:setPosition(cc.p(50,Define.visibleHeight - 56)):addTo(self)
        remainPaiCountBg:setPosition(cc.p(50, Define.visibleHeight - 46)):addTo(self)
    elseif gameid == Define.gameId_changzhou then
        remainPaiCountBg:setPosition(cc.p(50, Define.visibleHeight - 55)):addTo(self)
    end

	self.m_remainPaiCount = cc.Label:create()
	self.m_remainPaiCount:setSystemFontSize(25)
	self.m_remainPaiCount:setPosition(cc.p(remainPaiCountBg:getContentSize().width/2, remainPaiCountBg:getContentSize().height / 2+8))
	self.m_remainPaiCount:addTo(remainPaiCountBg)
	self.m_remainPaiCount:setString(count.."")
    self.m_remainPaiCount:setSystemFontName ("hall/font/bold.ttf")
    self.m_remainPaiCount:setTextColor(cc.c3b(91,255,0))
end
--[[
-- @brief  初始化电量函数
-- @param  void
-- @return void
--]]
function BgLayer:initBattery()
	local batteryBg = display.newSprite("#1004201.png")
	batteryBg:setPosition(cc.p(248, Define.visibleHeight - 51)):addTo(self)
	local battery = display.newSprite("#1004257.png")
	battery:setAnchorPoint(cc.p(0, 0.5))
	battery:setPosition(cc.p(12, batteryBg:getContentSize().height / 2))
	battery:addTo(batteryBg)

	self.pro_bat = cc.ProgressTimer:create(cc.Sprite:create("#1004258.png"))
	self.pro_bat:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	self.pro_bat:setMidpoint(cc.p(0, 1))
	self.pro_bat:setAnchorPoint(cc.p(0, 0.5))
	self.pro_bat:setBarChangeRate(cc.p(1, 0))
	self.pro_bat:setPosition(cc.p(7, battery:getContentSize().height / 2))
	self.pro_bat:addTo(battery)
	self.pro_bat:setPercentage(80)

    self.percentLabel = cc.Label:create()
    self.percentLabel:setString("80%")
    self.percentLabel:setAnchorPoint(0,0.5)
    self.percentLabel:setSystemFontSize(25)
    self.percentLabel:setPosition(cc.p(battery:getContentSize().width + battery:getPositionX() + 10, batteryBg:getContentSize().height/2))
    self.percentLabel:setColor(display.COLOR_WHITE)
    self.percentLabel:addTo(batteryBg)
    self.percentLabel:setSystemFontName ("hall/font/bold.ttf")

    self:updateBattery()
end

--[[
-- @brief  更新电量函数
-- @param  void
-- @return void
--]]
function BgLayer:updateBattery()
    local data = {};
    data.cmd = NativeCall.CMD_GETBATTERY;
    NativeCall.getInstance():callNative(data, self.onUpdateBattery, self);
end

--[[
-- @brief  更新电量回调函数
-- @param  void
-- @return void
--]]
function BgLayer:onUpdateBattery(info)
    self:performWithDelay(function()
        self.percentLabel:setString(info.baPro .. "%");
        self.pro_bat:setPercentage(info.baPro);
    end, 1);
    self:performWithDelay(function()
        self:updateBattery();
    end, 60);
end

--[[
-- @brief  显示测试文本函数
-- @param  void
-- @return void
--]]
function BgLayer:showTestView()
    --测试用 添加对局id
    local match_label = cc.Label:create()
    local playid = self.gamePlaySystem:getGameStartDatas().gamePlayID
    match_label:setString("对局Id："..playid)
    match_label:setSystemFontSize(30)
    match_label:setPosition(cc.p(Define.visibleWidth /2, Define.visibleHeight /2 + 90))
    match_label:setColor(display.COLOR_RED)
    match_label:setSystemFontName ("hall/font/bold.ttf")
    match_label:addTo(self)
end

function BgLayer:onCheckGameStart()
    local function showTricks()
        -- 显示骰子
        self:addMJOfTricks()
        local startData = self.gamePlaySystem:getGameStartDatas()
        assert(startData ~= nil)
        self._MJTricks:diceAnimation(startData.dice[1],startData.dice[2])
    end
    if IsPortrait and device.platform == "android" then -- TODO
        scheduler.performWithDelayGlobal(showTricks, 0.1)
    else
        showTricks()
    end
end

--[[
-- @brief  开始游戏函数
-- @param  void
-- @return void
--]]
function BgLayer:onGameStart()

    -- 显示视图
    self:showViews()

end
--[[
-- @brief  恢复游戏函数
-- @param  void
-- @return void
--]]
function BgLayer:onGameResume()
    -- 显示视图
    self:showViews()
end

--[[
-- @brief  显示视图函数
-- @param  void
-- @return void
--]]
function BgLayer:showViews()
    Log.i("------BgLayer:showViews")
    -- 移除速配界面
    self:removeMatchLoading()
    -- 设置门风位置
    self._clock:setDoorDirect()
    -- 设置打牌玩家
    local startData = self.gamePlaySystem:getGameStartDatas()
    local site = self.gamePlaySystem:getPlayerSiteById(startData.firstplay)
    self._clock:setThePoint(site, enClockType.PLAY_CARD)

    self:refreshRemainCount()
    self:showShengyuStr()
end

-- --[[
-- -- @brief  构造函数
-- -- @param  void
-- -- @return void
-- --]]
-- function BgLayer:changeHeadContent()
--     -- 重新改变头像
--     for i=1,4 do
--         self.arrHeadNode[i]:changeHead(i)
--         self.arrHeadNode[i]:setVisible(true)
--     end
-- end

-- --[[
-- -- @brief  构造函数
-- -- @param  void
-- -- @return void
-- --]]
-- function BgLayer:initHeadView()
--     -- 添加头像
--     local headPos = {
--         cc.p(60, 205),
--         cc.p(Define.visibleWidth - 70, Define.visibleHeight/2+100),
--         cc.p(Define.visibleWidth - 273, Define.visibleHeight - 80),
--         cc.p(60, Define.visibleHeight/2+100)
--     }
--     -- 创建头像
--     for i=1,4 do
--         if not self.arrHeadNode[i] then --有下跑的话，头像已经创建了
--             self.arrHeadNode[i] = PlayerNode.new()
--             self:addChild(self.arrHeadNode[i])
--         end
--         self.arrHeadNode[i]:setVisible(false)
--         self.arrHeadNode[i]:setLocalZOrder(2)
--         self.arrHeadNode[i]:setPosition(headPos[i])
--     end

-- end

-- --[[
-- -- @brief  -- 初始化准备字样
-- -- @param  void
-- -- @return void
-- --]]
-- function BgLayer:initReadyText()
--     local headWidth     = self.arrHeadNode[1]:getContentSize().width
--     local headHeight    = self.arrHeadNode[1]:getContentSize().height

--     local readyPos = {cc.p(self.arrHeadNode[1]:getPositionX(), self.arrHeadNode[1]:getPositionY() + 50 + headHeight / 2),
--         cc.p(self.arrHeadNode[2]:getPositionX() - headWidth/2 - 80, self.arrHeadNode[2]:getPositionY() ),
--         cc.p(self.arrHeadNode[3]:getPositionX(), self.arrHeadNode[3]:getPositionY() - 50 - headHeight / 2),
--         cc.p(self.arrHeadNode[4]:getPositionX() + headWidth/2 + 80, self.arrHeadNode[4]:getPositionY() )}
--     for i=1,4 do
--         self.m_continueReadySprites[i] = display.newSprite("real_res/1004063.png")
--         self:addChild(self.m_continueReadySprites[i])
--         self.m_continueReadySprites[i]:setPosition(readyPos[i])
--         self.m_continueReadySprites[i]:setVisible(false)
--     end
-- end

-- --[[
-- -- @brief  注册玩家监听函数
-- -- @param  void
-- -- @return void
-- --]]
-- function BgLayer:registerListenerEvents()
--     self.playerHandles      = {}
--     -- 状态句柄
--     self.stateHandle   = {}
--     local players   = self.gamePlaySystem:gameStartGetPlayers()
--     for i=1, #players do
--         table.insert(self.playerHandles, players[i]:addCustomEventListener(
--         enEntityEvent.ENTITY_PROP_CHANGED_NTF, function (event)
--             -- 监听到相应玩家发过来改变积分数的消息后重新设置积分的显示
--             local propid, value, oldvalue = unpack(event._userdata)
--             if propid == enCreatureEntityProp.FORTUNE then
--                self.arrHeadNode[i]:setMoney(value)
--             end
--         end))
--         -- 状态监听
--         table.insert(self.stateHandle, players[i]:addCustomEventListener(
--         enEntityEvent.ENTITY_STATE_CHANGED_NTF, function (event)
--             -- 监听到相应玩家发过来改变积分数的消息后重新设置积分的显示
--             local stateid, value, oldvalue = unpack(event._userdata)
--             if stateid == enCreatureEntityState.SUBSTITUTE then
--                 if value == enSubstitusStatus.SUBSTITUTE then
--                     if i ~= enSiteDirection.SITE_MYSELF then
--                         self.arrHeadNode[i]:showHeadSubstitute(true)
--                     end
--                 elseif value == enSubstitusStatus.CANCEL then
--                     if i ~= enSiteDirection.SITE_MYSELF then
--                         self.arrHeadNode[i]:showHeadSubstitute(false)
--                     end
--                 end
--             end
--         end))
--     end
-- end

-- --[[
-- -- @brief  移除玩家监听函数
-- -- @param  void
-- -- @return void
-- --]]
-- function BgLayer:removeListenerEvents()
--     -- 移除玩家监听
--     table.walk(self.playerHandles, function(h)
--         MjMediator.getInstance():getEventServer():removeEventListener(h)
--     end)
--     self.playerHandles = {}

--     -- 移除状态监听
--     table.walk(self.stateHandle, function(h)
--         MjMediator.getInstance():getEventServer():removeEventListener(h)
--     end)
--     self.stateHandle = {}
-- end

--[[
-- @brief  初始化牌墩数
-- @param  void
-- @return void
--]]
function BgLayer:addMJOfTricks()
    Log.i("BgLayer:addMJOfTricks")
    self._MJTricks = Tricks.new()
    self._MJTricks:initTriacks()
    self._MJTricks:addTo(self)
end

--[[
-- @brief  发牌结束函数
-- @param  void
-- @return void
--]]
function BgLayer:onMjDistrubuteEnd()
    Log.i("------BgLayer:onMjDistrubuteEnd")
    local data      = self.gamePlaySystem:getGameStartDatas()
    local players   = self.gamePlaySystem:gameStartGetPlayers()
    assert(data ~= nil)
    for i=1,#players do
        if players[i]:getProp(enCreatureEntityProp.BANKER) then
            if #data.actions > 0 then
                self._clock:setThePoint(i, enClockType.ACTION)
            else
                self._clock:setThePoint(i, enClockType.PLAY_CARD)
            end
        end
    end
end

--[[
-- @brief  拿牌操作函数
-- @param  void
-- @return void
--]]
function BgLayer:onDispenseCard()
    local dispenseData  = self.gamePlaySystem:getDispenseCardDatas()
    local players       = self.gamePlaySystem:gameStartGetPlayers()
    for i=1, #players do
        if players[i]:getProp(enCreatureEntityProp.USERID) == dispenseData.userId then
            -- 启动时钟
            self._clock:setThePoint(i, enClockType.PLAY_CARD)
            break
        end
    end
    self:refreshRemainCount()
end

--[[
-- @brief  出牌消息处理函数
-- @param  void
-- @return void
--]]
function BgLayer:onPlayCard()
    Log.i("------BgLayer:onPlayCard")
    -- 打出去的牌消息
    local playCardData = self.gamePlaySystem:getPlayCardDatas()
    -- 通过id获取玩家座位索引
    if playCardData.nextplayerID ~= 0 then
         local index = self.gamePlaySystem:getPlayerSiteById(playCardData.nextplayerID)
        self._clock:setThePoint(index, enClockType.PLAY_CARD)
    end
end

--[[
-- @brief  取消托管消息处理函数
-- @param  void
-- @return void
--]]
function BgLayer:onCancelSub()

end
--[[
-- @brief  刷新界面托管显示
-- @param  void
-- @return void
--]]
function BgLayer:onHandleSubstitute()
    local players = self.gamePlaySystem:gameStartGetPlayers()
    -- 不更新自己的头像所以从2开始遍历
    for i=2, #players - 1 do
        -- 根据玩家的托管状态，更新玩家的头像状态显示
        if players[i]:getState(enCreatureEntityState.SUBSTITUTE) == enSubstitusStatus.SUBSTITUTE
            and self.gamePlaySystem:getGameSubstituteDatas().maPI == players[i]:getProp(enCreatureEntityProp.USERID) then
            -- self.arrHeadNode[i]:showHeadSubstitute(true)
        else
            -- self.arrHeadNode[i]:showHeadSubstitute(false)
        end
    end
end

--[[
-- @brief  显示吃碰杠消息
-- @param  void
-- @return void
--]]
function BgLayer:onShowOperateLab(event)
    local site = self.gamePlaySystem:getCurrentPlayer()
    self._clock:setThePoint(site, enClockType.ACTION)
end

--[[
-- @brief  结算消息
-- @param  void
-- @return void
--]]
function BgLayer:onGameOver()
    -- 收到结算停止定时器
    self._clock:stoptUpdate()
end

function BgLayer:showMFAnim(ty, dSeat, dpx, dpy, sSeat, spx, spy)
    Log.i("------showMFAnim type", ty);
    if ty == 1 then
        SoundManager.playEffect("magic_face_1");
        self:showHezuo(dSeat, dpx, dpy, sSeat, spx, spy);
    elseif ty == 3 then
        SoundManager.playEffect("magic_face_3");
        self:showJinggubang(dSeat, dpx, dpy, sSeat, spx, spy);
    elseif ty == 2 then
        SoundManager.playEffect("magic_face_2");
        self:showSongtao(dSeat, dpx, dpy, sSeat, spx, spy);
    elseif ty == 4 then
        local sex =  MjProxy:getInstance()._players[sSeat]:getSex()
            SoundManager.playEffect("magic_face_4"..sex);
        self:showJinguzou(dSeat, dpx, dpy, sSeat, spx, spy);
    elseif ty == 5 then
        SoundManager.playEffect("magic_face_5");
        self:showWuzhishan(dSeat, dpx, dpy, sSeat, spx, spy);
    end
end

function BgLayer:showHezuo(dSeat, dpx, dpy, sSeat, spx, spy)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/gameCommon/anim/magicface/hezuo/hezuo.csb");
    local armature = ccs.Armature:create("hezuo");
    self:getParent():addChild(armature,4);
    armature:setPosition(cc.p(spx, spy));
    --armature:setScale(0.68);
    local moveTime = 0.8;
    if sSeat == 1 then
        armature:getAnimation():play("Animation1");
        if dSeat == 4  then
            moveTime = 0.4;
        end
    elseif sSeat == 2 then
        armature:getAnimation():play("Animation2");
        if dSeat == 3 then
            moveTime = 0.4;
        end
    elseif sSeat == 3 then
        if dSeat == 2 then
            armature:getAnimation():play("Animation1");
            moveTime = 0.4;
        else
            armature:getAnimation():play("Animation2");
        end
    elseif sSeat == 4 then

        if dSeat == 1 then
            armature:getAnimation():play("Animation2");
            moveTime = 0.4;
        else
            armature:getAnimation():play("Animation1");
        end
    end

    transition.fadeIn(armature, {time = 0.167});
    transition.execute(armature, cc.MoveBy:create(moveTime, cc.p(dpx - spx, dpy - spy)), {onComplete = function()
        armature:getAnimation():play("Animation3");
        armature:performWithDelay(function()
            armature:removeFromParent();
        end, 1);
    end});
end
function BgLayer:showJinggubang(dSeat, dpx, dpy, sSeat, spx, spy)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/gameCommon/anim/magicface/jingubang/jingubang.csb");
    local armature = ccs.Armature:create("jingubang");
    self:getParent():addChild(armature,4);
    armature:getAnimation():play("Animation1");
    armature:setPosition(cc.p(spx, spy+30));
    --armature:setScale(0.68);
    local moveTime = 1.1;

    if (dSeat == 1 and sSeat == 4)
        or (dSeat == 2 and sSeat == 3)
        or (dSeat == 3 and sSeat == 2)
        or (dSeat == 4 and sSeat == 1)  then
--            transition.scaleTo(armature, {scaleX = 0.95, scaleY = 0.95, time = 0.8});
            moveTime = 0.4;
    else
        moveTime = 0.8
--        transition.scaleTo(armature, {scaleX = 0.95, scaleY = 0.95, time = 1.8});
    end
    transition.fadeIn(armature, {time = 0.167});
    transition.execute(armature, cc.MoveBy:create(moveTime, cc.p(dpx - spx, dpy - spy)), {onComplete = function()
        armature:getAnimation():play("Animation2");
        armature:performWithDelay(function()
            armature:removeFromParent();
        end, 1.9);
    end});
end
function BgLayer:showSongtao(dSeat, dpx, dpy, sSeat, spx, spy)

    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/gameCommon/anim/magicface/songtao/songtao.csb");
    local armature = ccs.Armature:create("songtao")
    self:getParent():addChild(armature,4);
    armature:getAnimation():play("Animation1");
    armature:setPosition(cc.p(spx, spy));
    armature:setScale(0.78);
--    local moveTime = 2;
    moveTime = 1.1;
     if sSeat == 1 then
        if dSeat == 4  then
            moveTime = 0.4;
        else
            armature:setScaleX(-0.78);
--            transition.scaleTo(armature, {scaleX = -0.95, scaleY = 0.95, time = 1.8});
        end
    elseif sSeat == 2 then
--        transition.scaleTo(armature, {scaleX = 0.95, scaleY = 0.95, time = 0.8});
        if dSeat == 3 then
            moveTime = 0.4;
        end
    elseif sSeat == 3 then
        if dSeat == 2 then
--            transition.scaleTo(armature, {scaleX = 0.95, scaleY = 0.95, time = 0.8});
            moveTime = 0.4;
        else
            armature:setScaleX(-0.78);
--            transition.scaleTo(armature, {scaleX = -0.95, scaleY = 0.95, time = 1.8});
        end
    elseif sSeat == 4 then

        if dSeat == 1 then
--            transition.scaleTo(armature, {scaleX = 0.95, scaleY = 0.95, time = 0.8});
            moveTime = 0.4;
        else
            armature:setScaleX(-0.78);
--            transition.scaleTo(armature, {scaleX = -0.95, scaleY = 0.95, time = 1.8});
        end
    end

    transition.fadeIn(armature, {time = 0.167});
    transition.execute(armature, cc.MoveBy:create(moveTime, cc.p(dpx - spx, dpy - spy)), {onComplete = function()
        armature:getAnimation():play("Animation2");
        armature:performWithDelay(function()
            armature:removeFromParent();
        end, 2.25);
    end});

end

function BgLayer:showJinguzou(dSeat, dpx, dpy, sSeat, spx, spy)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/gameCommon/anim/magicface/jinguzhou/jinguzhou.csb");
    local armature = ccs.Armature:create("jinguzhou")
    self:getParent():addChild(armature,4);
    armature:getAnimation():play("Animation1");
    armature:setPosition(cc.p(spx, spy+50));
    --armature:setScale(0.68);
    local moveTime = 0.8
    if (dSeat == 1 and sSeat == 4)
        or (dSeat == 2 and sSeat == 3)
        or (dSeat == 3 and sSeat == 2)
        or (dSeat == 4 and sSeat == 1)  then
    --    transition.scaleTo(armature, {scaleX = 0.85, scaleY = 0.85, time = 0.8});
        moveTime = 0.4;
    else
    ---    transition.scaleTo(armature, {scaleX = 0.85, scaleY = 0.85, time = 1.8});
    end
    transition.fadeIn(armature, {time = 0.167});
    transition.execute(armature, cc.MoveBy:create(moveTime, cc.p(dpx - spx, dpy - spy)), {onComplete = function()
        armature:getAnimation():play("Animation2");
        armature:performWithDelay(function()
            armature:removeFromParent();
        end, 2.67);
    end});
end
function BgLayer:showWuzhishan(dSeat, dpx, dpy, sSeat, spx, spy)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/gameCommon/anim/magicface/wuzhishan/wuzhishan.csb");
    local armature = ccs.Armature:create("wuzhishan")
    self:getParent():addChild(armature,4);
    armature:getAnimation():play("Animation1");
    armature:setPosition(cc.p(spx, spy+20));
    local moveTime = 0.8
    if (dSeat == 1 and sSeat == 4)
        or (dSeat == 2 and sSeat == 3)
        or (dSeat == 3 and sSeat == 2)
        or (dSeat == 4 and sSeat == 1)  then
        moveTime = 0.4;
    else
    end

    transition.fadeIn(armature, {time = 0.167});
    transition.execute(armature, cc.MoveBy:create(moveTime, cc.p(dpx - spx, dpy - spy)), {onComplete = function()
        armature:getAnimation():play("Animation2");
        armature:performWithDelay(function()
            armature:removeFromParent();
        end, 2.67);
    end});
end
function BgLayer:refreshRemainPaiCount()
    Log.i("BgLayer:refreshRemainPaiCount")
	local data = MjProxy:getInstance()._playCardData
	if self.m_remainPaiCount and data then
--	    local count = data.remainCount
        Log.i("refreshRemainPaiCount........")
        self._remainCount = self._remainCount - 1
        local count = self._remainCount
		if count < 0 then
			count = 0
		end
        count = math.ceil(count/2)
		self.m_remainPaiCount:setString(string.format("%s", tostring(count)))
	end
end
function BgLayer:refreshRemainChangzhouPaiCount()
    local data = MjProxy:getInstance()._playCardData
	if self.m_remainPaiCount and data then
--	    local count = data.remainCount
        self._remainCount = self._remainCount - 1
        local count = self._remainCount
		if count < 0 then
			count = 0
		end
		self.m_remainPaiCount:setString(string.format("%s", tostring(count)))
	end
end


-- 显示听牌标志
function BgLayer:showTingMark(index)
	local ting = display.newSprite("real_res/1004348.png")
	local space = 70
	local  tingPos = {
        cc.p(display.cx, display.cy - ting:getContentSize().height / 2 - space ),
        cc.p(display.cx + ting:getContentSize().width / 2 + space, display.cy),
        cc.p(display.cx, display.cy + ting:getContentSize().height / 2 + space),
        cc.p(display.cx - ting:getContentSize().width / 2 - space, display.cy)
    }
	ting:setPosition(tingPos[index])
	self:addChild(ting)
end

function BgLayer:on_msgMission()
	Log.i("BgLayer:on_msgMission")
	local data = MjProxy:getInstance()._missionData
	if data == nil then
		return
	end

	if data.typee == 99 then
		local finish = nil
		for i = 1, #MjProxy:getInstance()._userIds do
        	if data.userId == MjProxy:getInstance()._userIds[i] then
        		finish = display.newSprite("#desk_task_1.png")
				MjProxy:getInstance()._players[i]:setTaskFinished(true)
        	end
    	end

		finish:setScale(5)
		finish:setOpacity(0)
		finish:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])
		finish:setPosition(cc.p(1140, 572))
		self:addChild(finish, 1)
		finish:runAction(cc.Spawn:create(cc.ScaleTo:create(0.2, 1.0), cc.FadeIn:create(0.2)))
	end

	self.taskBg = self.taskBg or nil
	if self.taskBg then
		return
	end

	self.taskBg = cc.Sprite:create("mj/game/game_task_base.png")
	self.taskBg:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_TOP])
	self.taskBg:setPosition(cc.p(1138, 70 + cc.Director:getInstance():getVisibleSize().height))
	self:addChild(self.taskBg, 2)

	local actionPng = ""
	if data.typee == 0 then
		actionPng = "action_chi.png"
	elseif data.typee == 1 then
		actionPng = "action_peng.png"
	elseif data.typee == 2 then
		actionPng = "action_gang.png"
	elseif data.typee == 3 then
		actionPng = "action_ting.png"
	elseif data.typee == 4 then
		actionPng = "action_hu.png"
	elseif data.typee == 5 then
		actionPng = "action_jiabei.png"
	end

	if actionPng == "" then
		return
	end

	local actionDo = display.newSprite("#" .. actionPng)
	actionDo:setAnchorPoint(cc.p(0, 0.5))
	actionDo:setPosition(cc.p(22, 49))
	actionDo:setScale(0.6)
	self.taskBg:addChild(actionDo)

	if data.card ~= 0 then
		local mj = data.card

		local pai = getCardPngByValue(mj)
		assert(pai ~= "" and pai ~= nil)

		local taskCardBg = display.newSprite("#game_mj_paimian.png")
		taskCardBg:setPosition(cc.p(actionDo:getContentSize().width + 16, 48))
		taskCardBg:setScale(0.8)
		self.taskBg:addChild(taskCardBg)

		local taskCard = display.newSprite("#" .. pai)
		if mj >= 11 and mj <= 19 then
			taskCard:setScale(0.8)
			taskCard:setPosition(taskCardBg:getContentSize().width / 2, taskCardBg:getContentSize().height - 18)
			taskCardBg:addChild(taskCard)

			local spwan = display.newSprite("#w_w.png")
			spwan:setScale(0.8)
			spwan:setPosition(cc.p(taskCardBg:getContentSize().width / 2, taskCard:getPositionY() - taskCard:getContentSize().height + 3))
			taskCardBg:addChild(spwan)
		else
			taskCard:setPosition(cc.p(taskCardBg:getContentSize().width / 2, taskCardBg:getContentSize().height / 2))
			taskCard:setScale(0.9)
			taskCardBg:addChild(taskCard)
		end
	end

	if data.typee ~= 5 then
		if data.card == 0 then
			local anyCard = display.newSprite("#game_task_rehepai.png")
			anyCard:setScale(0.9)
			anyCard:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
			anyCard:setPosition(cc.p(actionDo:getContentSize().width - 18, 48))
			self.taskBg:addChild(anyCard)
		end
	else
		local beiNum = cc.LabelAtlas:_create(string.format("%s", tostring(data.number)), "mj/game/desk_task_nuber.png", 30, 37, string.byte("0"))
		beiNum:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
		beiNum:setPosition(cc.p(actionDo:getContentSize().width - 45, 48))
		self.taskBg:addChild(beiNum)

		local ci = display.newSprite("#desk_task_ci.png")
		ci:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
		ci:setPosition(cc.p(beiNum:getPositionX() + beiNum:getContentSize().width + 2, beiNum:getPositionY()))
		self.taskBg:addChild(ci)
	end

	local taskNum = cc.LabelAtlas:_create(string.format("x:%s", tostring(data.multiple)), "mj/game/game_task_num.png", 27, 38, string.byte("2"))
	taskNum:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	if data.card == 0 then
		taskNum:setPosition(cc.p(145, 48))
	else
		taskNum:setPosition(cc.p(125, 48))
	end
	self.taskBg:addChild(taskNum)
	self.taskBg:runAction(cc.EaseBounceOut:create(cc.MoveTo:create(0.4, cc.p(1138, 698))))

	MjProxy:getInstance()._players[enSiteDirection.SITE_MYSELF]:setTaskMultiple(data.multiple)

end

function BgLayer:showMatchLoading()
	local visibleWidth = cc.Director:getInstance():getVisibleSize().width
	local visibleHeight = cc.Director:getInstance():getVisibleSize().height
	-- 防作弊速配中
	self.matchLoadingLayer =  display.newLayer()
	self.matchLoadingLayer:addTo(self)

	local countDownBgSprite = display.newSprite("real_res/1004353.png")
	countDownBgSprite:setPosition(cc.p(visibleWidth / 2, visibleHeight / 2))
	countDownBgSprite:addTo(self.matchLoadingLayer)

    local match_label = cc.Label:create()
    local match_text = "防作弊排队中."
    match_label:setString(match_text)
    match_label:setSystemFontName ("hall/font/bold.ttf")

    local actionString = ""
    local function labelActionFunc()
        local asLen = string.len(actionString)
        if asLen>=0 and asLen < 5 then
            actionString = actionString.."."
        else
            actionString = ""
        end
        match_label:setString(match_text..actionString)
        local cf = cc.CallFunc:create(labelActionFunc)
        local dt = cc.DelayTime:create(0.3)
        match_label:runAction(cc.Sequence:create(dt,cf))
    end
    labelActionFunc()
    match_label:setAnchorPoint(0,0.5)
    match_label:setSystemFontSize(40)
    match_label:setPosition(cc.p(countDownBgSprite:getContentSize().width/2-match_label:getContentSize().width/2, countDownBgSprite:getContentSize().height/2))
    match_label:setColor(display.COLOR_WHITE)
    match_label:addTo(countDownBgSprite)
end

--更新开始时间
function BgLayer:updateMatchTime()
    self.m_matchTime = self.m_matchTime - 1;
    if self.m_matchTime < 0 then
        self.m_matchTime = 10;
    end

    self.match_timeLabel:setString(self.m_matchTime);

    self.m_match_time_update = self.match_timeLabel:performWithDelay(handler(self, self.updateMatchTime), 1);
end

function BgLayer:removeMatchLoading()
	if self.matchLoadingLayer then
	    if self.m_match_time_update then
	        transition.removeAction(self.m_match_time_update);
	        self.m_match_time_update = nil;
	    end
		self.matchLoadingLayer:removeFromParent()
		self.matchLoadingLayer = nil
	end
end

function BgLayer:on_showPaoMaDeng(content)
	Log.i("BgLayer:on_showPaoMaDeng")
    if content then
    	if not self.pan_notice then
        	self.pan_notice = display.newSprite("real_res/1004276.png")

        	self.pan_notice:addTo(self)
        	self.pan_notice:setPosition(cc.p(display.cx, display.height - self.pan_notice:getContentSize().height/2))
        	self.pan_notice:setVisible(false)
        	self.pan_notice:setScale(808/1014, 1)
		    self.lb_notice = cc.Label:create()
            self.lb_notice:setSystemFontName ("hall/font/bold.ttf")
		    self.lb_notice:setAnchorPoint(0,0.5)
		    self.lb_notice:setSystemFontSize(26)
		    self.lb_notice:setPosition(cc.p(808, self.pan_notice:getContentSize().height/2))
		    self.lb_notice:setColor(display.COLOR_WHITE)
		    self.lb_notice:addTo(self.pan_notice)
    	end

        if not self.pan_notice:isVisible() then
            self.pan_notice:setVisible(true);
            self.lb_notice:setString(content);
            local size = self.lb_notice:getContentSize();
            local moveX = -808 - size.width;
            local showTime = -moveX/130;
            transition.execute(self.lb_notice, cc.MoveBy:create(showTime, cc.p(moveX, 0)), {
                onComplete = function()
                    self.lb_notice:setPosition(cc.p(808, 21));
                    self.pan_notice:setVisible(false);
                    --
                    if #self.brocastContent > 0 then
                        local content = table.remove(self.brocastContent, 1);
                        self:on_showPaoMaDeng(content);
                    end
                end
            });
        else
            table.insert(self.brocastContent, content);
        end
    end
end

function BgLayer:on_dismissDesk(info)
    if self.continueReadyLayer then
        self.continueReadyLayer:removeFromParent()
        self.continueReadyLayer = nil
        self:showMatchLoading()
    end

end
-- @brief  刷新剩余数据
-- @param  void
-- @return void
--]]
function BgLayer:refreshRemainCount(event)
    if self._shengyu then
        local count = SystemFacade:getInstance():getRemainPaiCount()
        if count < 0 then
            count = 0
        end
        -----------------------回放-----------------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            local jushu  = kPlaybackInfo:getCurrentGamesNum()
            local syText = string.format("剩余 %s 张    第 %d 局", count, jushu)
            self._shengyu:setString(syText)
        else
            if event then
                local animation = unpack(event._userdata)
                -- 胡牌动作发生时, 不再刷新牌局数量
                if animation == "AnimationHU" or animation == "AnimationTIANHU" then
                    return
                end
            end
            local currCount     = SystemFacade:getInstance():getCurrentGameCount() or 0
            local totalCount    = SystemFacade:getInstance():getTotalGameCount() or 0
            local syText = string.format("剩余 %s 张    第 %d/%d 局",count, (currCount<=totalCount) and currCount or totalCount, totalCount)
            self._shengyu:setString(syText)
        end
        ----------------------------------------------------------------
    end
end
-- @brief  隐藏剩余数据
-- @param  void
-- @return void
--]]
function BgLayer:hideShengyuStr()
    self._shengyu:setVisible(false)
end
-- @brief  显示剩余数据
-- @param  void
-- @return void
--]]
function BgLayer:showShengyuStr()
    self._shengyu:setVisible(true)
end


return BgLayer
