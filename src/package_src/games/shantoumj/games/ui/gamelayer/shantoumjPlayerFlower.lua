local PlayerFlower = require("app.games.common.ui.gamelayer.PlayerFlower")
local shantoumjPlayerFlower = class("shantoumjPlayerFlower", PlayerFlower)
local Define = require "app.games.common.Define"
local Mj     = require "app.games.common.mahjong.Mj"

function shantoumjPlayerFlower:ctor(data)
    -- 本家报马牌Y轴调整
    self.kMySiteOffsetY = 15
    -- 下家报马牌Y轴调整
    self.kRightSiteOffsetY = 30
    -- 对家报马牌Y轴调整
    self.kOtherSiteOffsetY = 20

    self.baoTings = {}

    shantoumjPlayerFlower.super.ctor(self, data)
end

function shantoumjPlayerFlower:showBuhuaPos()
    
    self.flower_ScrollView_1 = self:getWidget(self.m_pWidget,"flower_ScrollView_1")
    self.flower_ScrollView_1:setPosition(cc.p(290*Define.mj_buhua_pos_scale, 118*Define.mj_buhua_pos_scale + self.kMySiteOffsetY))
    self.baomaBg1 = display.newSprite("package_res/games/shantoumj/common/maima_tag.png")
    self.m_pWidget:addChild(self.baomaBg1)
    self.baomaBg1:setVisible(false)


    self.flower_ScrollView_2 = self:getWidget(self.m_pWidget,"flower_ScrollView_2")
    self.flower_ScrollView_2:setPosition(cc.p(display.size.width - 290, 136*Define.mj_buhua_pos_scale + self.kRightSiteOffsetY))
    self.baomaBg2 = display.newSprite("package_res/games/shantoumj/common/maima_tag.png")
    self.baomaBg2:setRotation(270)
    self.m_pWidget:addChild(self.baomaBg2)
    local pos2 = cc.p( self.flower_ScrollView_2:getPositionX() + self.baomaBg2:getContentSize().width + 5, self.flower_ScrollView_2:getPositionY() - 15)
    self.baomaBg2:setPosition(pos2)
    self.baomaBg2:setVisible(false)

    

    self.flower_ScrollView_3 = self:getWidget(self.m_pWidget,"flower_ScrollView_3")
    self.flower_ScrollView_3:setPosition(cc.p(930, display.size.height - 100*Define.mj_buhua_pos_scale + self.kOtherSiteOffsetY))
    self.baomaBg3 = display.newSprite("package_res/games/shantoumj/common/maima_tag.png")
    self.m_pWidget:addChild(self.baomaBg3)
    self.baomaBg3:setRotation(180)
    self.baomaBg3:setVisible(false)

    

    self.flower_ScrollView_4 = self:getWidget(self.m_pWidget,"flower_ScrollView_4")
    self.flower_ScrollView_4:setPosition(cc.p(290, display.size.height - 100*Define.mj_buhua_pos_scale))
    self.baomaBg4 = display.newSprite("package_res/games/shantoumj/common/maima_tag.png")
    self.baomaBg4:setRotation(90)
    self.m_pWidget:addChild(self.baomaBg4)
    local pos4 = cc.p( self.flower_ScrollView_4:getPositionX() - self.baomaBg4:getContentSize().width *1 - 2, self.flower_ScrollView_4:getPositionY() - self.baomaBg4:getContentSize().height * 1)
    self.baomaBg4:setPosition(pos4)
    self.baomaBg4:setVisible(false)




    --获取房间人数
    local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.playerCount = sys:getGameStartDatas().playerNum

    if self.playerCount == 2 then
        self.flower_ScrollView_3:setContentSize(cc.size(320, 150))
        self.flower_ScrollView_3:setPosition(cc.p(display.size.width - 200, display.size.height - 270))
        self.flower_ScrollView_1:setContentSize(cc.size(320, 150))
        self.flower_ScrollView_1:setPosition(cc.p(200, display.cy - 100))
        local pos1 = cc.p( self.flower_ScrollView_1:getPositionX() - self.baomaBg1:getContentSize().width * 0.5, self.flower_ScrollView_1:getPositionY() + self.baomaBg1:getContentSize().height * 2)
        self.baomaBg1:setPosition(pos1)
        self.baomaBg1:setVisible(false)

        local pos3 = cc.p( self.flower_ScrollView_3:getPositionX()  + self.baomaBg1:getContentSize().width * 0.5, self.flower_ScrollView_3:getPositionY() - self.baomaBg3:getContentSize().height * 2)
        self.baomaBg3:setPosition(pos3)
        self.baomaBg3:setVisible(false)

    else
        local pos1 = cc.p( self.flower_ScrollView_1:getPositionX() - self.baomaBg1:getContentSize().width * 0.5, self.flower_ScrollView_1:getPositionY() + self.baomaBg1:getContentSize().height * 0.5 + 5)
        self.baomaBg1:setPosition(pos1)
        self.baomaBg1:setVisible(false)

        local pos3 = cc.p( self.flower_ScrollView_3:getPositionX()  - self.baomaBg1:getContentSize().width * 1  - 6, self.flower_ScrollView_3:getPositionY() - self.baomaBg3:getContentSize().height * 0.5 )
        self.baomaBg3:setPosition(pos3)
        self.baomaBg3:setVisible(false)
    end

    table.insert(self.scrollViews, self.flower_ScrollView_1)
    table.insert(self.baoTings, self.baomaBg1)
    if self.playerCount == 2 then
        table.insert(self.scrollViews, self.flower_ScrollView_3)
        table.insert(self.baoTings, self.baomaBg3)

    elseif self.playerCount == 3 then
        table.insert(self.scrollViews, self.flower_ScrollView_2)
        table.insert(self.scrollViews, self.flower_ScrollView_4)
        table.insert(self.baoTings, self.baomaBg2)
        table.insert(self.baoTings, self.baomaBg4)

    elseif self.playerCount == 4 then
        table.insert(self.scrollViews, self.flower_ScrollView_2)
        table.insert(self.scrollViews, self.flower_ScrollView_3)
        table.insert(self.scrollViews, self.flower_ScrollView_4)
        table.insert(self.baoTings, self.baomaBg2)
        table.insert(self.baoTings, self.baomaBg3)
        table.insert(self.baoTings, self.baomaBg4)
    end
end


--显示补花
function shantoumjPlayerFlower:setBuhuaNumber(site,index)
    Log.i("shantoumjPlayerFlower:setBuhuaNumber.....",site,index)
    if self.m_flowMj[site] == nil then
        self.m_flowMj[site] = {}
    end

    if self.baoTings and self.baoTings[site] then
      self.baoTings[site]:setVisible(true)
    end
    
    local mjBg = self:getFlowerMjBgPng(site,index)
    -- mjBg:setScale(self.m_scale)
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
       mjBg:setPosition(mjBg:getPositionX() + 3, mjBg:getPositionY() + 20)
       icPosX = #self.m_flowMj[site]*38
       icPosY = svSize.height
       if icPosX < svSize.width then
            icPosX = svSize.width
            scrollView:setBounceEnabled(false)
       end
   elseif site == Define.site_right then
       -- mjBg:setScaleX(1.1)
       -- mjBg:setPosition(mjBg:getPositionX() + 3, mjBg:getPositionY() + 8)
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
       -- mjBg:setScaleX(1.1)
        icPosX = svSize.width
        icPosY = #self.m_flowMj[site]*48*0.67
        if icPosY < svSize.height then
            icPosY = svSize.height
            scrollView:setBounceEnabled(false)
        end
   end
   scrollView:setInnerContainerSize(cc.size(icPosX,icPosY))
end


function shantoumjPlayerFlower:scrollFunc(data, mWight, nIndex, scrollView)
    local wightPosx = mWight:getPositionX()
    local wightPosy = mWight:getPositionY()
    local wightSize = mWight:getContentSize()
    local paiNode   = mWight:getChildren()
    local paiBg = paiNode[1]
    local paiBgSize = paiBg:getContentSize()
    -- local gmPng = ""
    -- local greenmask
    local bul = {gl.DST_COLOR,gl.ONE}
    if data.site == Define.site_self then
        local scrollSize = self.flower_ScrollView_1:getContentSize()
        -- gmPng = "games/common/game/verticalGreenmask.png"
        -- greenmask = display.newSprite(gmPng)
        -- gmSize = greenmask:getContentSize()
        -- greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)
        if self.playerCount == 2 then
            scrollView:setTouchEnabled(false)
            local x = (wightPosx+wightSize.width/2 + math.floor((nIndex - 1) % 8) * wightSize.width)
            local y = scrollSize.height / 2 + 12 + wightPosy+wightSize.height - (wightSize.height - 12) * math.floor((nIndex - 1) / 8)
            mWight:setPosition(cc.p(x, y))
        else
            mWight:setPosition(cc.p((wightPosx+wightSize.width/2+(nIndex-1)*wightSize.width), wightPosy+wightSize.height - 8))
        end
        
    elseif data.site == Define.site_right then
        if self.playerCount == 2 then
            scrollView:setTouchEnabled(false)
            local scrollSize = self.flower_ScrollView_3:getContentSize()
            -- gmPng = "games/common/game/verticalGreenmask.png"
            -- greenmask = display.newSprite(gmPng)
            -- gmSize = greenmask:getContentSize()
            -- greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)

            local x = (wightPosx+wightSize.width/2+(nIndex-1)*wightSize.width)
            local y = scrollSize.height / 2 + 24  - (wightSize.height - 12) * (nIndex - 1)
            mWight:setPosition(cc.p(x, y))
            mWight:setLocalZOrder(50 - nIndex)
        elseif self.playerCount == 3 or self.playerCount == 4 then
            -- gmPng = "games/common/game/horizonGreenmask.png"
            -- greenmask = display.newSprite(gmPng)
            -- gmSize = greenmask:getContentSize()
            -- greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)
            local gap = 0
            if nIndex > 1 then
                gap = (nIndex-1) * 13
            end
            mWight:setPosition(cc.p(wightSize.width/2+43, (wightSize.height/2+(nIndex-1)*wightSize.height) - gap -10))
            mWight:setLocalZOrder(50 - nIndex)
        end
    elseif data.site == Define.site_other then
        if self.playerCount == 3 then
            -- gmPng = "games/common/game/horizonGreenmask.png"
            -- greenmask = display.newSprite(gmPng)
            -- gmSize = greenmask:getContentSize()
            -- greenmask:setPosition(cc.p(paiBgSize.width, paiBgSize.height))
            -- greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)
            mWight:setLocalZOrder(nIndex)
            local gap = 0
            if nIndex > 1 then
                gap = (nIndex-1) * 13
            end
            mWight:setPosition(cc.p(wightSize.width/2+43, (wightSize.height/2+(nIndex-1)*wightSize.height) - gap -10))
        elseif self.playerCount == 4 then
            -- gmPng = "games/common/game/verticalGreenmask.png"
            -- greenmask = display.newSprite(gmPng)
            -- gmSize = greenmask:getContentSize()
            -- greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)
            mWight:setPosition(cc.p(wightPosx+wightSize.width/2+(nIndex-1)*(wightSize.width + 1) + 50, -5))
        end
    elseif data.site == Define.site_left then
        -- gmPng = "games/common/game/horizonGreenmask.png"
        -- greenmask = display.newSprite(gmPng)
        -- gmSize = greenmask:getContentSize()
        -- greenmask:setPosition(cc.p(paiBgSize.width, paiBgSize.height))
        -- greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)
        mWight:setLocalZOrder(nIndex)
        local gap = 0
        if nIndex > 1 then
            gap = (nIndex-1) * 13
        end
        mWight:setPosition(cc.p(wightSize.width/2+40, (wightSize.height+(nIndex-1)*wightSize.height) - gap +32))
    end
    -- paiBg:addChild(greenmask)
end

function shantoumjPlayerFlower:getFlowerMjBgPng(site, mj)
    if site == Define.site_self then
        return Mj.new(enMjType.EMPTY_OTHER_GANG)
    elseif site == Define.site_right then
        if self.playerCount == 2 then
            local newMj = Mj.new(enMjType.EMPTY_OTHER_GANG)
            newMj:setRotation(-180)
            return newMj
        elseif self.playerCount == 3 or self.playerCount == 4 then
            local newMj = Mj.new(enMjType.EMPTY_OTHER_GANG)
            -- newMj:setContentSize(cc.p(50, 37))
            newMj:setRotation(90)
            return newMj
        end
    elseif site == Define.site_other then
        if self.playerCount == 3 then
            local newMj = Mj.new(enMjType.EMPTY_OTHER_GANG)
            newMj:setRotation(-180)
            return newMj
        elseif self.playerCount == 4 then
            local newMj = Mj.new(enMjType.EMPTY_OTHER_GANG)
            newMj:setRotation(-180)
            return newMj
        end
    elseif site == Define.site_left then
        local newMj = Mj.new(enMjType.EMPTY_OTHER_GANG)
        -- newMj:setContentSize(cc.p(50, 37))
        newMj:setRotation(90)
        return newMj
    end
end

--[[
-- @brief  移除补花的麻将 以及 报马图片
-- @param  void
-- @return void
--]]
function shantoumjPlayerFlower:onGameOver()
    self.flower_ScrollView_1:removeAllChildren()
    self.flower_ScrollView_2:removeAllChildren()
    self.flower_ScrollView_3:removeAllChildren()
    self.flower_ScrollView_4:removeAllChildren()    
    self.baomaBg1:setVisible(false)
    self.baomaBg2:setVisible(false)
    self.baomaBg3:setVisible(false)
    self.baomaBg4:setVisible(false)
end


return shantoumjPlayerFlower


