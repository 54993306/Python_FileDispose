--
-- Author: RuiHao Lin
-- Date: 2017-05-10 11:03:32
--
require("app.DebugHelper")
local FriendOverView = require("app.games.common.ui.gameover.FriendOverView")
local Mj    		= require "app.games.common.mahjong.Mj"
local flowerdeviation = 150 --- flower            防止杠四次麻将牌会和花牌界面重合的偏移量

local linedeviation = 141---------line
local gaozhoumjFriendOverView = class("gaozhoumjFriendOverView", FriendOverView)

function gaozhoumjFriendOverView:ctor(data)
    self.super.ctor(self.super, data)
end


function gaozhoumjFriendOverView:addPlayers()

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

        line:setPositionX(display.cx+linedeviation)--xiong
        line:getParent():requestDoLayout()

        local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")


        local lFlowerCards = self:showFlower(scoreitem.flowerCards, hua_mj,scoreitem.zhongMaList)----------------加多一个参数

        hua_mj:setPositionX(display.cx+flowerdeviation)--xiong
        hua_mj:getParent():requestDoLayout()

        self.m_PlayerCardList[i].FlowerCards = lFlowerCards
    end
end




----------------
-- 设置玩家详情
-- @param lab_fan       待设置的玩家详情label
-- @param scoreitems    玩家详情Table
function gaozhoumjFriendOverView:setPlayerDetail(lab_fan, scoreitems)
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
   
    
     --local hu = "胡".."(".."1".."底"..")" 
   -- buf = buf .. " " .. hu

--    if name[1] == "庄家(1番)" or name[2] == "庄家(1番)"or name[3] == "庄家(1番)" then

--     local zhuang = "庄"
--     buf = buf.." "..zhuang
--    end


    lab_fan:setString(buf)
    --self:fanMaShow()
end
--function gaozhoumjFriendOverView:initHuImage(item,scoreitems)
--    local img_hu = ccui.Helper:seekWidgetByName(item, "img_hu");

--    if scoreitems.result == enResult.WIN then --胡牌玩家
--        if self.gameOverDatas.winType == 1 then
--            img_hu:loadTexture("games/common/game/friendRoom/mjOver/zimo.png", ccui.TextureResType.localType)
--        elseif self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
--            img_hu:loadTexture("package_res/games/gaozhoumj/image/qiangganghu.png", ccui.TextureResType.localType)
--        else
--            img_hu:loadTexture("games/common/game/friendRoom/mjOver/hupai.png", ccui.TextureResType.localType)
--        end
--        img_hu:setVisible(true)
--    elseif (scoreitems.result == enResult.FANGPAO or scoreitems.result == enResult.FAILED)
--        and self.gameOverDatas.winType == enGameOverType.FANG_PAO then
--        img_hu:setVisible(true)
--        img_hu:loadTexture("games/common/game/friendRoom/mjOver/fangpao.png", ccui.TextureResType.localType)
--    elseif (scoreitems.result == enResult.FANGPAO or scoreitems.result == enResult.FAILED) -- 加入抢杠胡
--        and self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
--        img_hu:setVisible(true)
--        img_hu:loadTexture("games/common/game/friendRoom/mjOver/icon_qianggang.png", ccui.TextureResType.localType)
--    else
--        img_hu:setVisible(false)
--    end
--end


function gaozhoumjFriendOverView:fanMaShow()


if #(self.gameOverDatas.maList)>0 and #(self.gameOverDatas.maList[1].fanMa)>0 then 
    local fanmalist = self.gameOverDatas.maList[1].fanMa
    local groupX = -display.cx
    local fanma_label = display.newTTFLabel({
                        text = "翻马：",
                        font = "hall/font/fangzhengcuyuan.TTF",
                        size = 25,
                        color = cc.c3b(139, 137, 113),
                        align = cc.TEXT_ALIGNMENT_LEFT,
                        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                    })

    fanma_label:setPosition(cc.p(groupX, fanma_label:getContentSize().height/2 - 5))
    fanma_label:addTo(self.lab_rule)
    groupX = groupX+fanma_label:getContentSize().width/2+10

    for i=1,#fanmalist do
        local majiang   = Mj.new(enMjType.MYSELF_PENG, fanmalist[i])
        local mjSize    = majiang:getContentSize()
        majiang:setScaleX(24 / mjSize.width)
        majiang:setScaleY(30 / mjSize.height)

        mjSize.width = mjSize.width * majiang:getScaleX()
        mjSize.height = mjSize.height * majiang:getScaleY()
        
        self.lab_rule :addChild(majiang)
        majiang:setPosition(cc.p(groupX, mjSize.height + mjSize.height / 2 - 10)) 
        groupX = groupX + mjSize.width

    end
    end
end
function gaozhoumjFriendOverView:showFlower(flowerCards, parent,zhongma)


--local zhongma = self.gameOverDatas.ma.zhongMa
--    self.super.showFlower(self,flowerCards,parent)
 local lCardList = {}
    if flowerCards and #flowerCards > 0 and parent then
        for i,k in pairs(flowerCards) do
            local flowSp = Mj.new(enMjType.MYSELF_PENG, k)
            local mjSize = flowSp:getContentSize()
            flowSp:setScaleX(20 / mjSize.width)
            flowSp:setScaleY(28 / mjSize.height)

            flowSp:setOpacity(125)
            --if #zhongma > 0 then
                for z,c in pairs(zhongma) do 
                    if flowerCards[i] ==c then
                        zhongma[z] = nil
                            flowSp:setOpacity(255)
                        break
                    end 
                end
           -- end

            mjSize.width = mjSize.width * flowSp:getScaleX()
            mjSize.height = mjSize.height * flowSp:getScaleY()

            local index_x = (i - 1)%12
            flowSp:setPosition(cc.p((mjSize.width + 1) * index_x + mjSize.width * 0.5, (mjSize.height + 6) * (1 + math.floor((i-1)/12)) + mjSize.height / 2 - 4))
            flowSp:addTo(parent)




            table.insert(lCardList, flowSp)
        end
    end


     if flowerCards and #flowerCards > 0 and parent then
        local zhongma = display.newSprite("package_res/games/gaozhoumj/game/zhongma.png")
        zhongma:addTo(parent)
        zhongma:setPosition(cc.p(-25,parent:getContentSize().height/2))


    end
    return lCardList
   

end
-- function gaozhoumjFriendOverView:setRule(lab_rule, wanfa)
--    self.super:setRule(lab_rule, wanfa)
--    local strWidth = lab_rule:getContentSize().width
--    local currMargin = lab_rule:getLayoutParameter():getMargin()
--    currMargin.left = display.width - strWidth - 30
--    lab_rule:getLayoutParameter():setMargin(currMargin)
--end
return gaozhoumjFriendOverView
