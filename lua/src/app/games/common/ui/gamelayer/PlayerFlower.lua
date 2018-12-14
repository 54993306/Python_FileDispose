--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Define = require "app.games.common.Define"
-- local MjSide = require "app.games.common.mediator.game.model.MjSide"
local Mj     = require "app.games.common.mahjong.Mj"
local Define            = require("app.games.common.Define")
PlayerFlower = class("PlayerFlower")

function PlayerFlower:ctor(data)
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/playerFlow.csb");
    self.m_data = data
    self.m_headImage = {}
    self.scrollViews = {}
    self.m_flowMj = {}     --存储补花的牌
end
function PlayerFlower:setDelegate(delegate)
    self.m_delegate = delegate;
end
--获取子控件时赋予特殊属性(支持Label,TextField)
function PlayerFlower:getWidget(parent, name, ...)
    return ccui.Helper:seekWidgetByName(parent or self.m_pWidget, name);
end

function PlayerFlower:onInit()
    self.m_scale = 0.8
    self:showBuhuaPos()
    for i = 1, 4 do
        local scrollView = self:getWidget(self.m_pWidget,"flower_ScrollView_" .. i)
        if scrollView then scrollView:setSwallowTouches(false) end
    end
end
function PlayerFlower:showBuhuaPos()

    self.flower_ScrollView_1 = self:getWidget(self.m_pWidget,"flower_ScrollView_1")
    self.flower_ScrollView_1:setPosition(cc.p(290*Define.mj_buhua_pos_scale, 118*Define.mj_buhua_pos_scale))

    self.flower_ScrollView_2 = self:getWidget(self.m_pWidget,"flower_ScrollView_2")
    self.flower_ScrollView_2:setPosition(cc.p(display.size.width - 290, 136*Define.mj_buhua_pos_scale))

    self.flower_ScrollView_3 = self:getWidget(self.m_pWidget,"flower_ScrollView_3")
    self.flower_ScrollView_3:setPosition(cc.p(930, display.size.height - 100*Define.mj_buhua_pos_scale))

    self.flower_ScrollView_4 = self:getWidget(self.m_pWidget,"flower_ScrollView_4")
    self.flower_ScrollView_4:setPosition(cc.p(290, display.size.height - 100*Define.mj_buhua_pos_scale))

    --获取房间人数
    local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.playerCount = sys:getGameStartDatas().playerNum

    if self.playerCount == 2 then
        self.flower_ScrollView_3:setContentSize(cc.size(320, 150))
        self.flower_ScrollView_3:setPosition(cc.p(display.size.width - 200, display.size.height - 270))
        self.flower_ScrollView_1:setContentSize(cc.size(320, 150))
        self.flower_ScrollView_1:setPosition(cc.p(200, display.cy - 100))
    elseif self.playerCount == 3 then
        self.flower_ScrollView_1:setPosition(cc.p(600, 140*Define.mj_buhua_pos_scale))
        self.flower_ScrollView_2:setPositionY(180)

    elseif self.playerCount == 4 then
        self.flower_ScrollView_1:setPosition(cc.p(200, 140*Define.mj_buhua_pos_scale))
        self.flower_ScrollView_3:setPositionY(display.size.height - 80)
        self.flower_ScrollView_2:setPositionY(180)
    end

    table.insert(self.scrollViews, self.flower_ScrollView_1)
    if self.playerCount == 2 then
        table.insert(self.scrollViews, self.flower_ScrollView_3)
    elseif self.playerCount == 3 then
        table.insert(self.scrollViews, self.flower_ScrollView_2)
        table.insert(self.scrollViews, self.flower_ScrollView_4)
    elseif self.playerCount == 4 then
        table.insert(self.scrollViews, self.flower_ScrollView_2)
        table.insert(self.scrollViews, self.flower_ScrollView_3)
        table.insert(self.scrollViews, self.flower_ScrollView_4)
    end
end
-- 创建补花麻将
function PlayerFlower:setBuhuaNumber(site,index)
    Log.i("PlayerFlower:setBuhuaNumber.....",site,index)
    if self.m_flowMj[site] == nil then
        self.m_flowMj[site] = {}
    end
    local mjBg = self:getFlowerMjBgPng(site,index)
    mjBg:setScale(self.m_scale)
    mjBg:setName("mjBg"..site)
    local arrList = {}
    arrList.mjBg = mjBg
    arrList.site = site
    Log.i("setBuhuaNumber...",arrList)
    table.insert(self.m_flowMj[site],arrList)
    local scrollView = self.scrollViews[site]
    scrollView:addChild(mjBg)
    self:scrollFunc(arrList, mjBg, #self.m_flowMj[site], scrollView)
    local function scrollviewEvent(sender,eventType)
       if eventType==ccui.ScrollviewEventType.scrollToBottom then

       elseif eventType==ccui.ScrollviewEventType.scrollToTop then

       end
   end
   scrollView:addTouchEventListener(scrollviewEvent)
   scrollView:setBounceEnabled(true)
   local icPosX = 0
   local icPosY = 0
   local svSize = scrollView:getContentSize()
   if site == Define.site_self then
       icPosX = #self.m_flowMj[site]*38
       icPosY = svSize.height
       if icPosX < svSize.width then
            icPosX = svSize.width
            scrollView:setBounceEnabled(false)
       end
   elseif site == Define.site_right then
        if self.playerCount == 2 then
            icPosX = #self.m_flowMj[site]*38
            icPosY = svSize.height
            if icPosX < svSize.width then
                icPosX = svSize.width
                scrollView:setBounceEnabled(false)
            end
        elseif self.playerCount == 3 or self.playerCount == 4 then
            icPosX = svSize.width
            icPosY = #self.m_flowMj[site]*48*0.67
            if icPosY < svSize.height then
                icPosY = svSize.height
                scrollView:setBounceEnabled(false)
            end
        end
   elseif site == Define.site_other then
        if self.playerCount == 3 then
            icPosX = svSize.width
            icPosY = #self.m_flowMj[site]*48*0.67
            if icPosY < svSize.height then
                icPosY = svSize.height
                scrollView:setBounceEnabled(false)
            end
        elseif self.playerCount == 4 then
            icPosX = #self.m_flowMj[site]*38
            icPosY = svSize.height
            if icPosX < svSize.width then
                icPosX = svSize.width
                scrollView:setBounceEnabled(false)
            end
        end
   elseif site == Define.site_left then
        icPosX = svSize.width
        icPosY = #self.m_flowMj[site]*48*0.67
        if icPosY < svSize.height then
            icPosY = svSize.height
            scrollView:setBounceEnabled(false)
        end
   end
   scrollView:setInnerContainerSize(cc.size(icPosX,icPosY))
end
function PlayerFlower:scrollFunc(data, mWight, nIndex, scrollView)
    local wightPosx = mWight:getPositionX()
    local wightPosy = mWight:getPositionY()
    local wightSize = mWight:getContentSize()
    local paiNode   = mWight:getChildren()
    local paiBg = paiNode[1]
    local paiBgSize = paiBg:getContentSize()
    local gmPng = ""
    local greenmask
    local bul = {gl.DST_COLOR,gl.ONE}
    if data.site == Define.site_self then
        local scrollSize = self.flower_ScrollView_1:getContentSize()
        gmPng = "games/common/game/verticalGreenmask.png"
        greenmask = display.newSprite(gmPng)
        gmSize = greenmask:getContentSize()
        greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)
        if self.playerCount == 2 then
            scrollView:setTouchEnabled(false)
            local x = (wightPosx+wightSize.width/2 + math.floor((nIndex - 1) % 8) * wightSize.width)*self.m_scale
            local y = scrollSize.height / 2 + 12 + wightPosy+wightSize.height - (wightSize.height - 12) * math.floor((nIndex - 1) / 8) * self.m_scale
            mWight:setPosition(cc.p(x, y))
        else
            mWight:setPosition(cc.p((wightPosx+wightSize.width/2+(nIndex-1)*wightSize.width)*self.m_scale, wightPosy+wightSize.height - 8))
        end

    elseif data.site == Define.site_right then
        if self.playerCount == 2 then
            scrollView:setTouchEnabled(false)
            local scrollSize = self.flower_ScrollView_3:getContentSize()
            gmPng = "games/common/game/verticalGreenmask.png"
            greenmask = display.newSprite(gmPng)
            gmSize = greenmask:getContentSize()
            greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)

            local x = (wightPosx+wightSize.width/2+math.floor((nIndex-1) % 8)*wightSize.width)*self.m_scale
            local y = scrollSize.height / 2 + 24  - (wightSize.height - 12) * math.floor((nIndex - 1) / 8) * self.m_scale
            mWight:setPosition(cc.p(x, y))
            mWight:setLocalZOrder(50 - nIndex)
        elseif self.playerCount == 3 or self.playerCount == 4 then
            gmPng = "games/common/game/horizonGreenmask.png"
            greenmask = display.newSprite(gmPng)
            gmSize = greenmask:getContentSize()
            greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)
            local gap = 0
            if nIndex > 1 then
                gap = (nIndex-1) * 10
            end
            mWight:setPosition(cc.p(wightSize.width/2+2, (wightSize.height/2+(nIndex-1)*wightSize.height)*self.m_scale - gap + 20))
            mWight:setLocalZOrder(50 - nIndex)
        end
    elseif data.site == Define.site_other then
        if self.playerCount == 3 then
            gmPng = "games/common/game/horizonGreenmask.png"
            greenmask = display.newSprite(gmPng)
            gmSize = greenmask:getContentSize()
            -- greenmask:setPosition(cc.p(paiBgSize.width, paiBgSize.height))
            greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)
            mWight:setLocalZOrder(nIndex)
            local gap = 0
            if nIndex > 1 then
                gap = (nIndex-1) * 10
            end
            mWight:setPosition(cc.p(wightSize.width/2+5, (wightSize.height+(nIndex-1)*wightSize.height)*self.m_scale - gap + 20))
        elseif self.playerCount == 4 then
            gmPng = "games/common/game/verticalGreenmask.png"
            greenmask = display.newSprite(gmPng)
            gmSize = greenmask:getContentSize()
            greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)
            mWight:setPosition(cc.p((wightPosx+wightSize.width/2+(nIndex-1)*wightSize.width)*self.m_scale + 50, 0))
        end
    elseif data.site == Define.site_left then
        gmPng = "games/common/game/horizonGreenmask.png"
        greenmask = display.newSprite(gmPng)
        gmSize = greenmask:getContentSize()
        -- greenmask:setPosition(cc.p(paiBgSize.width, paiBgSize.height))
        greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)
        mWight:setLocalZOrder(nIndex)
        local gap = 0
        if nIndex > 1 then
            gap = (nIndex-1) * 10
        end
        mWight:setPosition(cc.p(wightSize.width/2+5, (wightSize.height+(nIndex-1)*wightSize.height)*self.m_scale - gap + 20))
    end
    paiBg:addChild(greenmask)
end
function PlayerFlower:getFlowerMjBgPng(site, mj)
    if site == Define.site_self then
        return Mj.new(enMjType.MYSELF_OUT, mj)
    elseif site == Define.site_right then
        if self.playerCount == 2 then
            local newMj = Mj.new(enMjType.OTHER_OUT, mj)
            newMj:setRotation(-180)
            return newMj
        elseif self.playerCount == 3 or self.playerCount == 4 then
            return Mj.new(enMjType.RIGHT_OUT, mj, true)
        end
    elseif site == Define.site_other then
        if self.playerCount == 3 then
            local newMj = Mj.new(enMjType.LEFT_OUT, mj, true)
            newMj:setRotation(-180)
            return newMj
        elseif self.playerCount == 4 then
            local newMj = Mj.new(enMjType.OTHER_OUT, mj)
            newMj:setRotation(-180)
            return newMj
        end
    elseif site == Define.site_left then
        local newMj = Mj.new(enMjType.LEFT_OUT, mj, true)
        newMj:setRotation(-180)
        return newMj
    end
end
--[[
-- @brief  移除补花的麻将
-- @param  void
-- @return void
--]]
function PlayerFlower:onGameOver()
    self.flower_ScrollView_1:removeAllChildren()
    self.flower_ScrollView_2:removeAllChildren()
    self.flower_ScrollView_3:removeAllChildren()
    self.flower_ScrollView_4:removeAllChildren()
end

--------------------
-- 获取补花的牌
function PlayerFlower:getFlowerCards()
    return self.m_flowMj
end

return PlayerFlower
--endregion
