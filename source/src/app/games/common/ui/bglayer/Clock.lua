--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion
local Define = require "app.games.common.Define"
local kLightPaths = {
	"games/common/mj/games/clock_light_dong.png",
	"games/common/mj/games/clock_light_nan.png",
	"games/common/mj/games/clock_light_xi.png",
	"games/common/mj/games/clock_light_bei.png"
	}
local kTextPaths = {
	"games/common/mj/games/clock_text_dong.png",
	"games/common/mj/games/clock_text_nan.png",
	"games/common/mj/games/clock_text_xi.png",
	"games/common/mj/games/clock_text_bei.png"
}

local kRotateAngles = {0, -90, -180, -270}
local Clock = class("Clock", function ()
	return display.newNode()
end)
local kOpacityNone = 0
local kOpacityLow = 70
local kOpacityHigh = 255

function Clock:ctor()
	Log.i("Clock:ctor")
	self.clockHandle 	= nil
	self.lightSprites   = {}
	self.textSpites     = {}
	-- self:onNodeEve("exit", handler(self, self.onExit))
	self:addNodeEventListener(cc.NODE_EVENT, function (event)
		if event.name == "exit" then
			self:onExit()
		end
	end)
	local visibleWidth 	= cc.Director:getInstance():getVisibleSize().width
	local visibleHeight = cc.Director:getInstance():getVisibleSize().height
	-- self:setContentSize(cc.size(212, 116))
	self:setCascadeColorEnabled(true)

    if IsPortrait then -- TODO
        -- 闹钟背景
        self.clockSprite = display.newSprite("games/common/mj/games/clock_bg1.png")
        self.clockSprite:setPosition(cc.p(visibleWidth / 2, visibleHeight /2 + 30))
    else
    	self.clockButtomSprite = display.newSprite("games/common/mj/games/clock_buttom_bg.png")
    	self.clockButtomSprite:setPosition(cc.p(visibleWidth / 2, visibleHeight /2 + 40))
        self.clockButtomSprite:setScale(Define.mj_common_scale)
    	self.clockButtomSprite:addTo(self)

    	-- 闹钟背景
    	self.clockSprite = display.newSprite("games/common/mj/games/clock_bg.png")
    	self.clockSprite:setPosition(cc.p(visibleWidth / 2, visibleHeight /2 + 40))
    end

    self.clockSprite:setScale(Define.mj_common_scale)
	self.clockSprite:addTo(self)

	-- 获取游戏系统
	self.gamePlaySystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
	self.clockSystem 	= MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.CLOCK_SYSTEM)
	self.mTimeType = enClockType.PLAY_CARD
	-- 初始化门风
	self:initDoor()
	self:setVisible(false)
end

--[[
-- @brief  初始化显示状态
-- @param  void
-- @return void
--]]
function Clock:initDoor()
	self.lightSprites = {}

	local kRotateAngles = {0, -90, -180, -270}
	local space, textSpace, buttomSize
    if IsPortrait then -- TODO
        space = 27
        textSpace = 26
        buttomSize = self.clockSprite:getContentSize()
    else
        space = 10
        textSpace = 22
        buttomSize = self.clockButtomSprite:getContentSize()
    end
	local lightPostions = {
		cc.p(buttomSize.width / 2, space),
		cc.p(buttomSize.width - space, buttomSize.height / 2),
		cc.p(buttomSize.width / 2, buttomSize.height - space),
		cc.p(space, buttomSize.height / 2)
	}

	local textPostions = {
		cc.p(self.clockSprite:getContentSize().width / 2, textSpace),
		cc.p(self.clockSprite:getContentSize().width - textSpace, self.clockSprite:getContentSize().height / 2),
		cc.p(self.clockSprite:getContentSize().width / 2, self.clockSprite:getContentSize().height - textSpace),
		cc.p(textSpace, self.clockSprite:getContentSize().height / 2)
	}

	for i=1,4 do
		self.textSpites[i] = display.newSprite(kTextPaths[i]):addTo(self.clockSprite)
        if IsPortrait then -- TODO
            self.lightSprites[i] = display.newSprite(kLightPaths[i]):addTo(self.clockSprite)
        else
            self.lightSprites[i] = display.newSprite(kLightPaths[i]):addTo(self.clockButtomSprite)
        end

		self.textSpites[i]:setRotation(kRotateAngles[i])
		self.lightSprites[i]:setRotation(kRotateAngles[i])
		self.lightSprites[i]:setPosition(lightPostions[i])
        self.lightSprites[i]:setOpacity(kOpacityNone)
		self.textSpites[i]:setPosition(textPostions[i])
	end
	-- 倒计时
	self.timeLabel = cc.LabelAtlas:_create("00", "games/common/mj/games/game_num_clock.png", 15, 22, string.byte("0"))
	self.timeLabel:setAnchorPoint(cc.p(0.5, 0.5)):setPosition(cc.p(self.clockSprite:getContentSize().width / 2,
		self.clockSprite:getContentSize().height / 2 ))
	self.timeLabel:addTo(self.clockSprite)
end


--[[
-- @brief  初始化门风
-- @param  void
-- @return void
--]]
function Clock:setDoorDirect()
	self:setVisible(true)
	-- 门风
	local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local playerCount = sys:getGameStartDatas().playerNum
    if #self.textSpites == 4 then
    	if playerCount == 2 then
    		self.textSpites[2]:setVisible(false)
    		self.textSpites[4]:setVisible(false)
	    	table.remove(self.textSpites, 2)
	    	table.remove(self.textSpites, #self.textSpites)
    	elseif playerCount == 3 then
    		self.textSpites[3]:setVisible(false)
    		table.remove(self.textSpites, 3)
    	end
    end

	for i=1, playerCount do
		-- 获取门风属性
		local doorWind 	= self.gamePlaySystem:gameStartGetPlayerBySite(i):getProp(enCreatureEntityProp.DOOR_WIND)
		self.textSpites[i]:setTexture(kTextPaths[doorWind])
		self.lightSprites[i]:setTexture(kLightPaths[doorWind])
	end
	-- 获取庄家位置
    self.turnPoint = self.gamePlaySystem:gameStartGetBankerSite()

    if #self.lightSprites == 4 then
    	if playerCount == 2 then
	    	table.remove(self.lightSprites, 2)
	    	table.remove(self.lightSprites, #self.lightSprites)
		elseif playerCount == 3 then
	        table.remove(self.lightSprites, 3)
	    end
    end
end

--[[
-- @brief  设置打牌的人
-- @param  void
-- @return void
--]]
function Clock:setThePoint(pointType, timeType)
	Log.i("Clock:setThePoint pointType=", pointType)
	Log.i("Clock:setThePoint timeType=", timeType)
	Log.i("Clock:setThePoint self.turnPoint=", self.turnPoint)
	-- 先关闭时钟
	self:stoptUpdate()
	self.mTimeType = timeType
	if self.turnPoint ~= 0 and self.lightSprites[self.turnPoint] ~= nil then
		self.lightSprites[self.turnPoint]:stopAllActions()
	end
	self.turnPoint = pointType
	self.lightSprites[self.turnPoint]:runAction(
		cc.RepeatForever:create(
			cc.Sequence:create(
				cc.FadeTo:create(0.5, kOpacityLow),
				cc.FadeTo:create(0.5, kOpacityHigh))))
	--  启动定时器
	self.clockSystem:startUpdate(timeType, self.turnPoint)
	self:startUpdate()
end

--[
-- @brief  启动定时器
-- @param  void
-- @return void
--]
function Clock:startUpdate()
    -- 必须要判断体力定时器是否启动，没启动才启动
    if nil == self.clockHandle then
        self.clockHandle = scheduler.scheduleGlobal(
            handler(self, Clock.onClockUpdate), 0.2)
    end
end

--[
-- @brief  停止定时器
-- @param  void
-- @return void
--]
function Clock:stoptUpdate()
	self.timeLabel:setString("00")
	local players = self.gamePlaySystem:gameStartGetPlayers()
	for i=1,#players do
		self.lightSprites[i]:stopAllActions()
        self.lightSprites[i]:setOpacity(kOpacityNone)
	end
	self.clockSystem:stoptUpdate()
    if self.clockHandle then
        scheduler.unscheduleGlobal(self.clockHandle)
    end
    self.clockHandle = nil
end

--[
-- @brief  时间更新
-- @param  void
-- @return void
--]
function Clock:onClockUpdate(dt)
	if VideotapeManager.getInstance():isPlayingVideo() then
		if VideotapeManager.getInstance().isPaused then
    		self.clockSystem:pauseTimeByClockType(self.mTimeType)
		else
    		self.clockSystem:resumeTimeByClockType(self.mTimeType)
		end
	end

    local remainTime 	= self.clockSystem:getRemainTimeByClockType(self.mTimeType)
    -- 设置时间显示
    local time
    if remainTime < 10 then
    	time = "0"..remainTime
    else
    	time = tostring(remainTime)
    end
    self.timeLabel:setString(time)
    if remainTime <= 0 then
		-- if self.turnPoint == 1 then
		-- 	MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.MSG_SEND, enMjMsgSendId.MSG_SEND_SUBSTITUTE, 1)
		-- else
		-- 	Log.i("对家时间到")
		-- end
		-- 停止定时器
		self:stoptUpdate()
        self.lightSprites[self.turnPoint]:setOpacity(kOpacityHigh)
		-- self.timeLabel:setString("00")
		return
	end
end

function Clock:onExit()
	self:stoptUpdate()
end

function Clock:showLoading(visible)
	if self.m_loadingSprite then
		self.m_loadingSprite:setVisible(visible)
	else
		self.m_loadingSprite = display.newSprite("games/common/mj/common/time_wait.png")
		self.m_loadingSprite:setPosition(cc.p(self.clockSprite:getContentSize().width / 2, self.clockSprite:getContentSize().height / 2))
		self.m_loadingSprite:addTo(self.clockSprite)
        self.m_loadingSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(0.3, 180), cc.DelayTime:create(0.3),cc.RotateBy:create(0.3, 180))))
    end
    if visible == true and self.timeLabel then
    	self.timeLabel:setVisible(false)
   	end
end

return Clock
