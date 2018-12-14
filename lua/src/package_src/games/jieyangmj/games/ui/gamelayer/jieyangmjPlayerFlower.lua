--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Define = require "app.games.common.Define"
-- local MjSide = require "app.games.common.mediator.game.model.MjSide"
local Mj     = require "app.games.common.mahjong.Mj"
local PlayerFlower      = require "app.games.common.ui.gamelayer.PlayerFlower"
local jieyangmjPlayerFlower = class("jieyangmjPlayerFlower",PlayerFlower)

function jieyangmjPlayerFlower:ctor(data)
    jieyangmjPlayerFlower.super:ctor(data)
    self.m_pWidget:setEnabled(false)
    self.baoTings = {}
end

function jieyangmjPlayerFlower:showBuhuaPos()

    --花牌旋转角度
    local flowerRotate = {
     left = 270,
     opposite = 180,
     right = 90,
    };

    --对家的花牌位置
    local flower3SiteX = 920;
    --上家的花牌位置
    local flower4Site ={
        x = 290,
        y = 600,
    };



    local flowerSize = {};  --补花的矩形
    flowerSize.width = 360;  
    flowerSize.height = 200;
    
    self.flower_ScrollView_1 = self:getWidget(self.m_pWidget,"flower_ScrollView_1")
    local svS_1 = self.flower_ScrollView_1:getContentSize()
    self.flower_ScrollView_1:setPosition(cc.p(290, 118))
    self.baomaBg1 = display.newSprite("package_res/games/jieyangmj/common/maima_tag.png")
    self.m_pWidget:addChild(self.baomaBg1)
    self.baomaBg1:setVisible(false)


    self.flower_ScrollView_2 = self:getWidget(self.m_pWidget,"flower_ScrollView_2")
    local svS_2 = self.flower_ScrollView_2:getContentSize()
    self.flower_ScrollView_2:setPosition(cc.p(display.size.width - 290, 181))
    self.baomaBg2 = display.newSprite("package_res/games/jieyangmj/common/maima_tag.png")
    self.baomaBg2:setRotation(flowerRotate.left)
    self.m_pWidget:addChild(self.baomaBg2)
    local pos2 = cc.p( self.flower_ScrollView_2:getPositionX() + self.baomaBg2:getContentSize().width + 5, self.flower_ScrollView_2:getPositionY() + self.baomaBg2:getContentSize().height * 0.0 - 15)
    local pos2X = self.flower_ScrollView_2:getPositionX() + self.baomaBg2:getContentSize().width + 5
    local pos2Y = self.flower_ScrollView_2:getPositionY() + self.baomaBg2:getContentSize().height * 0.0 - 15
    self.baomaBg2:setPosition(pos2X + 3,pos2Y + 3)
    self.baomaBg2:setVisible(false)

    

    self.flower_ScrollView_3 = self:getWidget(self.m_pWidget,"flower_ScrollView_3")
    local svS_3 = self.flower_ScrollView_3:getContentSize()
    self.flower_ScrollView_3:setPosition(cc.p(flower3SiteX, display.size.height - 100))
    self.baomaBg3 = display.newSprite("package_res/games/jieyangmj/common/maima_tag.png")
    self.m_pWidget:addChild(self.baomaBg3)
    self.baomaBg3:setRotation(flowerRotate.opposite)
    self.baomaBg3:setVisible(false)

    

    self.flower_ScrollView_4 = self:getWidget(self.m_pWidget,"flower_ScrollView_4")
    local svS_4 = self.flower_ScrollView_4:getContentSize()
    self.flower_ScrollView_4:setPosition(cc.p(flower4Site.x, flower4Site.y))
    self.baomaBg4 = display.newSprite("package_res/games/jieyangmj/common/maima_tag.png")
    self.baomaBg4:setRotation(flowerRotate.right);
    self.m_pWidget:addChild(self.baomaBg4)

    local pos4 = cc.p( self.flower_ScrollView_4:getPositionX() - self.baomaBg4:getContentSize().width *1 - 2, self.flower_ScrollView_4:getPositionY() - self.baomaBg4:getContentSize().height * 1 + 15)
    local pos4X =  self.flower_ScrollView_4:getPositionX() - self.baomaBg4:getContentSize().width *1 - 2
    local pos4Y =  self.flower_ScrollView_4:getPositionY() - self.baomaBg4:getContentSize().height * 1 - 2
    self.baomaBg4:setPosition(cc.p(pos4X,pos4Y))
    self.baomaBg4:setVisible(false)


    --获取房间人数
    local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.playerCount = sys:getGameStartDatas().playerNum

    if self.playerCount == 2 then
        self.flower_ScrollView_3:setContentSize(cc.size(flowerSize.width, flowerSize.height))
        self.flower_ScrollView_3:setPosition(cc.p(display.size.width - 200, display.size.height - 10))
        self.flower_ScrollView_1:setContentSize(cc.size(flowerSize.width, flowerSize.height))
        self.flower_ScrollView_1:setPosition(cc.p(170, display.cy - 280))
        local pos1 = cc.p( self.flower_ScrollView_1:getPositionX() - self.baomaBg1:getContentSize().width * 0.5, self.flower_ScrollView_1:getPositionY() + self.baomaBg1:getContentSize().height * 2)
        local pos1X = self.flower_ScrollView_1:getPositionX() - self.baomaBg1:getContentSize().width * 0.5 
        local pos1Y = self.flower_ScrollView_1:getPositionY() + self.baomaBg1:getContentSize().height * 2
        self.baomaBg1:setPosition(cc.p(pos1X,pos1Y + 10))
        self.baomaBg1:setVisible(false)

        local pos3 = cc.p(self.flower_ScrollView_3:getPositionX()  + self.baomaBg1:getContentSize().width * 0.5, self.flower_ScrollView_3:getPositionY() - self.baomaBg3:getContentSize().height * 2)
        local pos3X = self.flower_ScrollView_3:getPositionX()  + self.baomaBg1:getContentSize().width * 0.5
        local pos3Y =  self.flower_ScrollView_3:getPositionY() - self.baomaBg3:getContentSize().height * 2
        self.baomaBg3:setPosition(cc.p(pos3X,pos3Y - 35))
        self.baomaBg3:setVisible(false)

    elseif self.playerCount == 4 then 

        self.flower_ScrollView_1:setPosition(cc.p(200, display.cy - 220))
        local pos1 = cc.p( self.flower_ScrollView_1:getPositionX() - self.baomaBg1:getContentSize().width * 0.5, self.flower_ScrollView_1:getPositionY() + self.baomaBg1:getContentSize().height * 0.5)
        self.baomaBg1:setPosition(pos1.x,pos1.y)
        self.baomaBg1:setVisible(false)

        self.flower_ScrollView_3:setPosition(cc.p(flower3SiteX, display.size.height - 80))
        local pos3 = cc.p( self.flower_ScrollView_3:getPositionX()  - self.baomaBg1:getContentSize().width * 1  - 6, self.flower_ScrollView_3:getPositionY() - self.baomaBg3:getContentSize().height * 0.5 )
        local pos3X = self.flower_ScrollView_3:getPositionX()  - self.baomaBg1:getContentSize().width * 1  - 6
        local pos3Y =  self.flower_ScrollView_3:getPositionY() - self.baomaBg3:getContentSize().height * 0.5 
        self.baomaBg3:setPosition(cc.p(pos3X - 4,pos3Y + 3))
        self.baomaBg3:setVisible(false)
        self.flower_ScrollView_3:setContentSize(cc.size(flowerSize.width, flowerSize.height))

        local pos4 = cc.p( self.flower_ScrollView_4:getPositionX() - self.baomaBg4:getContentSize().width *1 - 2, self.flower_ScrollView_4:getPositionY() - self.baomaBg4:getContentSize().height * 1 + 15)
        local pos4X =  self.flower_ScrollView_4:getPositionX() - self.baomaBg4:getContentSize().width *1 - 2
        local pos4Y =  self.flower_ScrollView_4:getPositionY() - self.baomaBg4:getContentSize().height * 1 - 2
        self.baomaBg4:setPosition(cc.p(pos4X - 3,pos4Y + 14))
    elseif self.playerCount == 3 then

        self.flower_ScrollView_1:setContentSize(cc.size(flowerSize.width, flowerSize.height))
        local pos1 = cc.p( self.flower_ScrollView_1:getPositionX() - self.baomaBg1:getContentSize().width * 0.5, self.flower_ScrollView_1:getPositionY() + self.baomaBg1:getContentSize().height * 2)
        local pos1X = self.flower_ScrollView_1:getPositionX() - self.baomaBg1:getContentSize().width * 0.5 
        local pos1Y = self.flower_ScrollView_1:getPositionY() + self.baomaBg1:getContentSize().height * 2
        self.baomaBg1:setPosition(pos1X,pos1Y - 95)


        self.flower_ScrollView_4:setPosition(cc.p(290, 600))
        self.flower_ScrollView_4:setContentSize(cc.size(flowerSize.width, flowerSize.height))
        local pos4 = cc.p( self.flower_ScrollView_4:getPositionX() - self.baomaBg4:getContentSize().width *1 - 2, self.flower_ScrollView_4:getPositionY() - self.baomaBg4:getContentSize().height * 1 + 15)
        local pos4X =  self.flower_ScrollView_4:getPositionX() - self.baomaBg4:getContentSize().width *1 - 2
        local pos4Y =  self.flower_ScrollView_4:getPositionY() - self.baomaBg4:getContentSize().height * 1 - 2
        self.baomaBg4:setPosition(cc.p(pos4X - 5 ,pos4Y + 74))

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
function jieyangmjPlayerFlower:setBuhuaNumber(site,index)
    if self.m_flowMj[site] == nil then
        self.m_flowMj[site] = {}
    end

    if site and self.baoTings and self.baoTings[site] then
      self.baoTings[site]:setVisible(true)
    end
    
    local mjBg = self:getFlowerMjBgPng(site,index)
    -- mjBg:setScale(self.m_scale)
    local arrList = {}
    arrList.mjBg = mjBg
    arrList.site = site
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
       --mjBg:setPosition(mjBg:getPositionX() + 3, mjBg:getPositionY()-8)
       icPosX = #self.m_flowMj[site]*38
       icPosY = svSize.height
       if icPosX < svSize.width then
            icPosX = svSize.width
            scrollView:setBounceEnabled(false)
       end
   elseif site == Define.site_right then
       --mjBg:setPosition(mjBg:getPositionX() + 3, mjBg:getPositionY() -8)
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

function jieyangmjPlayerFlower:scrollFunc(data, mWight, nIndex, scrollView)
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
            local x = (wightPosx+wightSize.width/2 + math.floor((nIndex - 1) % 8) * wightSize.width)*self.m_scale
            local y = scrollSize.height / 2 + 12 + wightPosy+wightSize.height - (wightSize.height - 12) * math.floor((nIndex - 1) / 8) * self.m_scale
            mWight:setPosition(cc.p(x, y))
        else
            mWight:setPosition(cc.p((wightPosx+wightSize.width/2+(nIndex-1)*wightSize.width), wightPosy+wightSize.height +10))
        end
        
    elseif data.site == Define.site_right then
        if self.playerCount == 2 then
            scrollView:setTouchEnabled(false)
            local scrollSize = self.flower_ScrollView_3:getContentSize()
            -- gmPng = "games/common/game/verticalGreenmask.png"
            -- greenmask = display.newSprite(gmPng)
            -- gmSize = greenmask:getContentSize()
            -- greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)

            local x = (wightPosx+wightSize.width/2+math.floor((nIndex-1) % 8)*wightSize.width)*self.m_scale
            local y = scrollSize.height / 2 + 24  - (wightSize.height - 12) * math.floor((nIndex - 1) / 8) * self.m_scale
            mWight:setPosition(cc.p(x, y))
            mWight:setLocalZOrder(50 - nIndex)
        elseif self.playerCount == 3 or self.playerCount == 4 then
            -- gmPng = "games/common/game/horizonGreenmask.png"
            -- greenmask = display.newSprite(gmPng)
            -- gmSize = greenmask:getContentSize()
            -- greenmask:setBlendFunc(gl.DST_COLOR,gl.ONE_MINUS_SRC_ALPHA)
            local gap = 0
            if nIndex > 1 then
                gap = (nIndex-1) * 10
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



function jieyangmjPlayerFlower:getFlowerMjBgPng(site, mj)
    if site == Define.site_self then
         return  Mj.new(enMjType.EMPTY_OTHER_GANG)
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
            newMj:setRotation(90)
            return newMj
        elseif self.playerCount == 4 then
            local newMj = Mj.new(enMjType.EMPTY_OTHER_GANG)
            newMj:setRotation(180)
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
function jieyangmjPlayerFlower:onGameOver()
    self.flower_ScrollView_1:removeAllChildren()
    self.flower_ScrollView_2:removeAllChildren()
    self.flower_ScrollView_3:removeAllChildren()
    self.flower_ScrollView_4:removeAllChildren()    
    self.baomaBg1:setVisible(false)
    self.baomaBg2:setVisible(false)
    self.baomaBg3:setVisible(false)
    self.baomaBg4:setVisible(false)
end


return jieyangmjPlayerFlower
