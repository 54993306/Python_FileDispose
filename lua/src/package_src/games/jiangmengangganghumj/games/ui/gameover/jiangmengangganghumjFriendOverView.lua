--
-- Author: RuiHao Lin
-- Date: 2017-05-10 11:03:32
--
require("app.DebugHelper")
local FriendOverView = require("app.games.common.ui.gameover.FriendOverView")
local Mj    		= require "app.games.common.mahjong.Mj"

local flowerdeviation = 150 --- flowercard            防止杠四次麻将牌会和花牌界面重合的偏移量

local linedeviation = 141---------line

local jiangmengangganghumjFriendOverView = class("jiangmengangganghumjFriendOverView", FriendOverView)

function jiangmengangganghumjFriendOverView:ctor(data)
Log.i("++++++++++++++++++++++")
    self.super.ctor(self.super, data)

end

---------------------------------------------------------------------------
function jiangmengangganghumjFriendOverView:onInit()
    self.super.onInit(self)
end
function jiangmengangganghumjFriendOverView:addPlayers()

    local players  = self.gameSystem:gameStartGetPlayers()       -- 玩家信息    
    self.playerNum = #players
    local itemInterval = 10              --默认四人房
    local offsetY = 30

    --修改 20171110 start 竖版换皮  diyal.yin
    --修改 20171110 end 竖版换皮 diyal.yin

    if self.playerNum == 3 then 
        itemInterval = itemInterval + 30
        offsetY = offsetY - 20
    elseif self.playerNum == 2 then
        itemInterval = itemInterval + 60
    end
    local bg = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg2");
    local bg_size = bg:getContentSize()
    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/mj_over_item.csb")
    math.randomseed(os.time())
    for i = 1, #players do
        self.m_PlayerCardList[i] = self.m_PlayerCardList[i] or {}
        local item  = itemModel:clone()
        item:setPosition(cc.p(14, bg_size.height - offsetY -(item:getContentSize().height + itemInterval) * i ))
        bg:addChild(item, 1);
        table.insert(self.playerPanels, item)
        local scoreitem = self.m_scoreitems[i]

        local lab_fan = ccui.Helper:seekWidgetByName(item, "event_text");
        self:setPlayerDetail(lab_fan, scoreitem)
        self:initHeadImage(item,players[i])
        self:initZhuangImg(item,players[i])
        self:initPlayerName(item,scoreitem)  
        self:initScore(item,scoreitem)                -- 区分正负，如果大于0就是正数，小于等于0就默认显示   
        self:initHuImage(item,scoreitem)

        local pan_mj = ccui.Helper:seekWidgetByName(item, "left_card_panel");  
        pan_mj.player = players[i]  
        self:addPlayerMjs(i,pan_mj)

        local line = ccui.Helper:seekWidgetByName(item, "line")
        line:setVisible(#scoreitem.flowerCards > 0)

        line:setPositionX(display.cx+140)--xiong
        line:getParent():requestDoLayout()

        local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")

        hua_mj:setPositionX(display.cx+150)--xiong
        hua_mj:getParent():requestDoLayout()

        local lFlowerCards = self:showFlower(scoreitem.flowerCards, hua_mj, scoreitem.zhongMaCards)---------加入一个中马数参数
        self.m_PlayerCardList[i].FlowerCards = lFlowerCards
    end
end
function jiangmengangganghumjFriendOverView:add1Players()

    local players  = self.gameSystem:gameStartGetPlayers()       -- 玩家信息    
    self.playerNum = #players
    local itemInterval = 0              --默认四人房
    local offsetY = 80
    if self.playerNum == 3 then 
        itemInterval = itemInterval + 30
        offsetY = offsetY - 20
    elseif self.playerNum == 2 then
        itemInterval = itemInterval + 60
    end
    local bg = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg2");
    local bg_size = bg:getContentSize()
    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/mj_over_item.csb")
    math.randomseed(os.time())
    for i = 1, #players do
        local item  = itemModel:clone()
        item:setPosition(cc.p(14, bg_size.height - offsetY -(item:getContentSize().height + itemInterval) * i ))
        bg:addChild(item, 1);
        table.insert(self.playerPanels, item)
        local scoreitem = self.m_scoreitems[i]

        local lab_fan = ccui.Helper:seekWidgetByName(item, "event_text");
        self:setPlayerDetail(lab_fan, scoreitem)
        self:initHeadImage(item,players[i])
        self:initZhuangImg(item,players[i])
        self:initPlayerName(item,scoreitem)  
        self:initScore(item,scoreitem)                -- 区分正负，如果大于0就是正数，小于等于0就默认显示   
        self:initHuImage(item,scoreitem)

        local pan_mj = ccui.Helper:seekWidgetByName(item, "left_card_panel");  
        pan_mj.player = players[i]  
        self:addPlayerMjs(i,pan_mj)

        local line = ccui.Helper:seekWidgetByName(item, "line")
        line:setVisible(#scoreitem.flowerCards > 0)

        line:setPositionX(display.cx+linedeviation)--xiong
        line:getParent():requestDoLayout()

        local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")

        hua_mj:setPositionX(display.cx+flowerdeviation)--xiong
        hua_mj:getParent():requestDoLayout()

        self:showFlower(scoreitem.flowerCards, hua_mj, scoreitem.zhongMaCards )
       
    end

end

----------------
-- 设置玩家详情
-- @param lab_fan       待设置的玩家详情label
-- @param scoreitems    玩家详情Table
function jiangmengangganghumjFriendOverView:setPlayerDetail(lab_fan, scoreitems)
     if scoreitems.result == enResult.WIN then
        lab_fan:setVisible(true)
    else
        lab_fan:setVisible(false)
    end
    local buf = ""
    local name = scoreitems.policyName or {}
    local score = scoreitems.policyScore or {}
    
    if #name > 0 and #score > 0 then
        for i = 1, #name do
       -- for i, v in pairs(name) do
            local format = name[i] .."   "         
            buf = buf .. format

        end
    end
   

    lab_fan:setString(buf)
end


function jiangmengangganghumjFriendOverView:showFlower(flowerCards, parent,zhongma)
 local lCardList = {}
    if flowerCards and #flowerCards > 0 and parent then

        Log.i("杠杠胡花牌",flowerCards)
        Log.i("杠杠胡中马",zhongma)
        local maxCol = 8
        for i,k in pairs(flowerCards) do
            local flowSp = Mj.new(enMjType.MYSELF_PENG, k)
            

            flowSp:setOpacity(125)

            

            local mjSize = flowSp:getContentSize()
            flowSp:setScaleX(20 / mjSize.width)
            flowSp:setScaleY(28 / mjSize.height)

            mjSize.width = mjSize.width * flowSp:getScaleX()
            mjSize.height = mjSize.height * flowSp:getScaleY()

            local index_x = (i - 1)%maxCol
            flowSp:setPosition(cc.p((mjSize.width + 1) * index_x + mjSize.width * 0.5, (mjSize.height + 6) * (2 - math.floor((i-1)/maxCol)) + mjSize.height / 2 - 4))
            flowSp:addTo(parent)
            local count = #zhongma
         --   if #zhongma > 0 then
                for z,c in pairs(zhongma) do 
                    if flowerCards[i] ==c then
                        zhongma[z] = nil
                        flowSp:setOpacity(255)
                        break
                    end 
                end
           -- end



            table.insert(lCardList, flowSp)
        end
    end

    if flowerCards and #flowerCards > 0 and parent then
        local zhongma = display.newSprite("package_res/games/jiangmengangganghumj/game/zhongma.png")
        zhongma:addTo(parent)
        zhongma:setPosition(cc.p(-25,parent:getContentSize().height/2))


    end
    return lCardList
end

return jiangmengangganghumjFriendOverView
