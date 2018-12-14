--
-- Author: Jinds
-- Date: 2017-06-26 12:01:50
--
local PlayerFlower = require("app.games.common.ui.gamelayer.PlayerFlower")
local zhaoqingmjPlayerFlower  = class("zhaoqingmjPlayerFlower", PlayerFlower)
local Define = require "app.games.common.Define"
local Mj     = require "app.games.common.mahjong.Mj"

function zhaoqingmjPlayerFlower:ctor(data)
    zhaoqingmjPlayerFlower.super:ctor(data)
	
    self.baoTings = {}
    self.m_pWidget:setEnabled(false)
end

function zhaoqingmjPlayerFlower:showBuhuaPos()

    local pos1_flower = cc.p(290, 135);
    local pos3_flower = cc.p(960, display.size.height - 80);

    
    self.flower_ScrollView_1 = self:getWidget(self.m_pWidget,"flower_ScrollView_1")
    local svS_1 = self.flower_ScrollView_1:getContentSize()
    self.flower_ScrollView_1:setPosition(pos1_flower)
    self.baomaBg1 = display.newSprite("package_res/games/zhaoqingmj/games/img_baoma.png")
    self.m_pWidget:addChild(self.baomaBg1)
    self.baomaBg1:setVisible(false)

    self.flower_ScrollView_2 = self:getWidget(self.m_pWidget,"flower_ScrollView_2")
    local svS_2 = self.flower_ScrollView_2:getContentSize()
    self.flower_ScrollView_2:setPosition(cc.p(display.size.width - 290, 181))
    self.baomaBg2 = display.newSprite("package_res/games/zhaoqingmj/games/img_baoma_v.png")
    self.baomaBg2:setRotation(180)
    self.m_pWidget:addChild(self.baomaBg2)
    local pos2 = cc.p( self.flower_ScrollView_2:getPositionX() + self.baomaBg2:getContentSize().width * 0.5, self.flower_ScrollView_2:getPositionY() - self.baomaBg2:getContentSize().height * 0.5)
    self.baomaBg2:setPosition(pos2)
    self.baomaBg2:setVisible(false)

    

    self.flower_ScrollView_3 = self:getWidget(self.m_pWidget,"flower_ScrollView_3")
    local svS_3 = self.flower_ScrollView_3:getContentSize()
    self.flower_ScrollView_3:setPosition(pos3_flower);
    self.baomaBg3 = display.newSprite("package_res/games/zhaoqingmj/games/img_baoma.png")
    self.m_pWidget:addChild(self.baomaBg3)
    self.baomaBg3:setRotation(180)
    self.baomaBg3:setVisible(false)

    

    self.flower_ScrollView_4 = self:getWidget(self.m_pWidget,"flower_ScrollView_4")
    local svS_4 = self.flower_ScrollView_4:getContentSize()
    self.flower_ScrollView_4:setPosition(cc.p(290, 620))
    self.baomaBg4 = display.newSprite("package_res/games/zhaoqingmj/games/img_baoma_v.png")
    self.m_pWidget:addChild(self.baomaBg4)
    local pos4 = cc.p( self.flower_ScrollView_4:getPositionX() - self.baomaBg4:getContentSize().width * 0.5, self.flower_ScrollView_4:getPositionY() - self.baomaBg4:getContentSize().height * 2 + 6)
    self.baomaBg4:setPosition(pos4)
    self.baomaBg4:setVisible(false)

    self.baomaBg1:setScale(0.85)
    self.baomaBg2:setScale(0.85)
    self.baomaBg3:setScale(0.85)
    self.baomaBg4:setScale(0.85)


    --获取房间人数
    local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.playerCount = sys:getGameStartDatas().playerNum

    if self.playerCount == 2 then
        self.flower_ScrollView_3:setContentSize(cc.size(320, 150))
        self.flower_ScrollView_3:setPosition(cc.p(display.size.width - 200, display.size.height - 270))
        self.flower_ScrollView_1:setContentSize(cc.size(320, 150))
        self.flower_ScrollView_1:setPosition(cc.p(200, display.cy - 100))

        local pos1 = cc.p( self.flower_ScrollView_1:getPositionX() - self.baomaBg1:getContentSize().width * 0.5, self.flower_ScrollView_1:getPositionY() + self.baomaBg1:getContentSize().height * 2+5)
        self.baomaBg1:setPosition(pos1)
        self.baomaBg1:setVisible(false)

        local pos3 = cc.p( self.flower_ScrollView_3:getPositionX()  + self.baomaBg1:getContentSize().width * 0.5-5, self.flower_ScrollView_3:getPositionY() - self.baomaBg3:getContentSize().height * 2 +5)
        self.baomaBg3:setPosition(pos3)
        self.baomaBg3:setVisible(false)
    else
        local pos1 = cc.p( self.flower_ScrollView_1:getPositionX() - self.baomaBg1:getContentSize().width * 0.5, self.flower_ScrollView_1:getPositionY() + self.baomaBg1:getContentSize().height * 0.5)
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


--显示报马
function zhaoqingmjPlayerFlower:setBuhuaNumber(site,index)
    Log.i("zhaoqingmjPlayerFlower:setBuhuaNumber.....",site,index)

    if self.m_flowMj[site] == nil then
        self.m_flowMj[site] = {}
    end

    if site and self.baoTings and self.baoTings[site] then
      self.baoTings[site]:setVisible(true)
    end

    local mjBg = self:getFlowerMjBgPng(site, index)
    mjBg:setScale(0.85)
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
       mjBg:setPosition(mjBg:getPositionX() + 3, mjBg:getPositionY() + 8)
       icPosX = #self.m_flowMj[site]*42
       icPosY = svSize.height
       if icPosX < svSize.width then
            icPosX = svSize.width
            scrollView:setBounceEnabled(false)
       end
   elseif site == Define.site_right then
       mjBg:setScaleX(1.1)
       mjBg:setPosition(mjBg:getPositionX() + 3, mjBg:getPositionY() + 8)
        if self.playerCount == 2 then
            mjBg:setPosition(mjBg:getPositionX() + 3, mjBg:getPositionY() -16)
            mjBg:setScale(0.85)
            icPosX = #self.m_flowMj[site]*42
            icPosY = svSize.height + 10
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
       mjBg:setScaleX(1.1)
        icPosX = svSize.width
        icPosY = #self.m_flowMj[site]*48*0.67
        if icPosY < svSize.height then
            icPosY = svSize.height
            scrollView:setBounceEnabled(false)
        end
   end
   scrollView:setInnerContainerSize(cc.size(icPosX,icPosY))
end


--[[
-- @brief  移除补花的麻将 以及 报马图片
-- @param  void
-- @return void
--]]
function zhaoqingmjPlayerFlower:onGameOver()
    self.flower_ScrollView_1:removeAllChildren()
    self.flower_ScrollView_2:removeAllChildren()
    self.flower_ScrollView_3:removeAllChildren()
    self.flower_ScrollView_4:removeAllChildren()    
    self.baomaBg1:setVisible(false)
    self.baomaBg2:setVisible(false)
    self.baomaBg3:setVisible(false)
    self.baomaBg4:setVisible(false)
end

return zhaoqingmjPlayerFlower