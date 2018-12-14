--
-- Author: RuiHao Lin
-- Date: 2017-05-10 11:03:32
--

require("app.DebugHelper")

local LayerTurnCard = require("app.games.common.custom.TurnCard.LayerTurnCard")
local LayerTurnCardMultiplayer = require("app.games.common.custom.TurnCard.LayerTurnCardMultiplayer")
local lFriendOverView = require("app.games.common.ui.gameover.FriendOverView")

local DerivedFriendOverView = class("DerivedFriendOverView", lFriendOverView)

--  override
function DerivedFriendOverView:ctor(data)
    self.super.ctor(self.super, data)
end

--  override
function DerivedFriendOverView:onInit()
    self.super.onInit(self)
    self:showTurnCardType()
    self:showAniTurnCard()
    self:dealTurnCard()
end

--  处理翻牌显示（花牌处）
function DerivedFriendOverView:dealTurnCard()
    local lMaList = self.gameSystem:getGameOverDatas().MaList
    for i, v in pairs(lMaList) do
        local fanma = v.fanma
        local zhongma = v.zhongma
        local lPlayerIndex = self.gameSystem:getPlayerSiteById(v.userid)
        local lFlowerCards = self.m_PlayerCardList[lPlayerIndex].FlowerCards
        if #zhongma > 0 then
            --  有中马情况
            for j, k in pairs(lFlowerCards) do
                local lIsLottery = false
                for n, m in pairs(zhongma) do
                    if k:getValue() == m then
                        lIsLottery = true
                        zhongma[n] = nil
                        break
                    end
                end
                if not lIsLottery then
                    k:setMjState(enMjState.MJ_STATE_CANT_TOUCH)
                end
            end
        else
            --  无中马情况
            for j, k in pairs(lFlowerCards) do
                k:setMjState(enMjState.MJ_STATE_CANT_TOUCH)
            end
        end
    end
end 

--  显示翻牌类型
function DerivedFriendOverView:showTurnCardType()
    local lGameOverData = self.gameSystem:getGameOverDatas()

    for i, v in pairs(self.playerPanels) do
        local lLine = ccui.Helper:seekWidgetByName(v, "line")
        lLine:setVisible(false)

        local lRightCardPanel = ccui.Helper:seekWidgetByName(v, "right_card_panel")
        lRightCardPanel:setPositionX(lRightCardPanel:getPositionX() + 20)

        --  只显示参与结算的马
        local lLottery = lGameOverData.score[i].flowerCards
        if #lLottery > 0 then
            local lTurnCardTitle = cc.Sprite:create("games/common/game/icon_zhongma.png")
            lRightCardPanel:addChild(lTurnCardTitle)
            lTurnCardTitle:setAnchorPoint(cc.p(1, 0.5))
            lTurnCardTitle:setPosition(cc.p(lTurnCardTitle:getContentSize().width / 2 - 20, lRightCardPanel:getContentSize().height / 2))
        end
    end
end

--  展现翻牌动画
function DerivedFriendOverView:showAniTurnCard()
    self:setOverViewVisible(false)
    local lGameOverData = self.gameSystem:getGameOverDatas()
    local lTurnCardList = { }
    for i, v in pairs(lGameOverData.MaList) do
        local fanma = v.fanma
        local zhongma = v.zhongma
        local lCardList = { }
        lCardList.UserID = v.userid
        lCardList.CardList = { }
        for j, n in pairs(fanma) do
            local item = { }
            item.Lottery = 0
            for k, m in pairs(zhongma) do
                if n == m then
                    item.Lottery = 1
                    break
                end
            end
            item.CardID = n

            table.insert(lCardList.CardList, item)

        end
        table.insert(lTurnCardList, lCardList)
    end

    --  没有翻牌数据则直接跳过翻牌动画
    if #lTurnCardList <= 0 then
        self:setOverViewVisible(true)
        return
    end

    --  添加翻牌动画

    local scene = cc.Director:getInstance():getRunningScene()
    local lLayerTurnCard = { }
    if #lTurnCardList == 1 then
        lLayerTurnCard = LayerTurnCard.new(lTurnCardList[1].CardList)
    else
        lLayerTurnCard = LayerTurnCardMultiplayer.new(lTurnCardList)
    end
    scene:addChild(lLayerTurnCard, 999)
    lLayerTurnCard:doAniTurnCardOneByOne()
    local lDelayTime = lLayerTurnCard.m_AniTime + 3
    scene:performWithDelay( function()
        lLayerTurnCard:closed()
        self:setOverViewVisible(true)
    end , lDelayTime)
end

--  设置结算界面的可见性
function DerivedFriendOverView:setOverViewVisible(isVisible)
    local lBGPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg_panel")
    lBGPanel:setVisible(isVisible)
end

--  override
-- 设置玩家详情
-- @param lab_fan       待设置的玩家详情label
-- @param scoreitems    玩家详情Table
function DerivedFriendOverView:setPlayerDetail(lab_fan, scoreitems)
    lab_fan:setVisible(true)
    local buf = ""
    local name = scoreitems.policyName or { }
    if #name > 0 then
        for i = 1, #name do
            local format = name[i] .. "   "
            buf = buf .. format
        end
    end

    local lLotteryCount = 0
    local lUserID = scoreitems.userid
    local lMaList = self.gameSystem:getGameOverDatas().MaList
    for i, v in pairs(lMaList) do
        if v.userid == lUserID then
            lLotteryCount = #v.zhongma
            break
        end 
    end
    
    if lLotteryCount > 0 then
        local bufLottery = "中" .. lLotteryCount .. "马"
        buf = buf .. bufLottery
    end
    lab_fan:setString(buf)
end

return DerivedFriendOverView
