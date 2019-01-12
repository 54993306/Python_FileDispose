local FriendOverView = require("app.games.common.ui.gameover.FriendOverView")

local Mj    		= require "app.games.common.mahjong.Mj"

local BranchFriendOverView = class("BranchFriendOverView",FriendOverView)

function BranchFriendOverView:ctor(data)
	BranchFriendOverView.super.ctor(self.super,data)
end

function BranchFriendOverView:onClose()
    BranchFriendOverView.super.onClose()
end
------------------------
-- 设置规则
-- @param lab_rule  待设置的规则label
-- @param wanfa     玩法字符串: palyingInfo.wa
function BranchFriendOverView:setRule(lab_rule, wanfa)
    local itemList= Util.analyzeString_2(wanfa)
    Log.i("itemList.....",itemList)
    local ruleStr = ""
    if (#itemList > 0 ) then
        for i, v in pairs(itemList) do
            local content = kFriendRoomInfo:getPlayingInfoByTitle(v)
            if ruleStr == "" then
                ruleStr = content.ch
            else
                ruleStr = string.format("%s %s", ruleStr, content.ch)
            end
        end
    end
    lab_rule:setString(ruleStr)
end

------------------------
-- 设置玩家详情
-- @param lab_fan       待设置的玩家详情label
-- @param scoreitems    玩家详情Table
function BranchFriendOverView:setPlayerDetail(lab_fan, scoreitems)
    lab_fan:setString("")
    -- 只显示赢的玩家
    if scoreitems.result == enResult.WIN then
        lab_fan:setVisible(true)
    else
        lab_fan:setVisible(false)
    end
    -- 显示胡牌提示
    local detail = ""
    local pon = scoreitems.policyName or {}
    local pos = scoreitems.policyScore or {}
    if #pon > 0  
        and #pos > 0 then
        local textUnit = "番 "
        local policyName = ""
        for i=1, #pon do
            if pos[i] > 0 then
                policyName = pon[i]..pos[i]..textUnit
            else
                policyName = pon[i].." "
            end
            detail = detail..policyName
        end
        Log.i("FriendOverView:addPlayers....gameId", MjProxy:getInstance():getGameId())
    end
    -- 显示花牌数量
    if not self.gameOverDatas.isQuanMa and #scoreitems.flowerCards > 0 then
        local flower = #scoreitems.flowerCards
        if self.gameOverDatas.isDouble then
            flower = #scoreitems.flowerCards*2
        end
        local huaStr = string.format("%d马", flower)
        detail = detail .. " " .. huaStr
    elseif self.gameOverDatas.isQuanMa then
        local huaStr = "全马"
        detail = detail .. " " .. huaStr
    end
    lab_fan:setString(detail)

--    self:fanMaShow()
end
function BranchFriendOverView:initHuImage(item,scoreitems)
    local img_hu = ccui.Helper:seekWidgetByName(item, "img_hu");
    if self.gameOverDatas.winType  == enGameOverType.QIANG_GANG_HU then 
        if scoreitems.result == enResult.WIN then --胡牌玩家
            img_hu:loadTexture("package_res/games/shaoguantdhmj/game/qiangganghuicon.png", ccui.TextureResType.localType)
            img_hu:setVisible(true)
        elseif scoreitems.result == enResult.FANGPAO or scoreitems.result == enResult.FAILED then
            img_hu:setVisible(true)
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/icon_qianggang.png", ccui.TextureResType.localType)
        else
            img_hu:setVisible(false)
        end
    else
        if scoreitems.result == enResult.WIN then --胡牌玩家
            if self.gameOverDatas.winType == 1 then
                img_hu:loadTexture("games/common/game/friendRoom/mjOver/zimo.png", ccui.TextureResType.localType)
            else
                img_hu:loadTexture("games/common/game/friendRoom/mjOver/hupai.png", ccui.TextureResType.localType)
            end
            img_hu:setVisible(true)
        elseif (scoreitems.result == enResult.FANGPAO or scoreitems.result == enResult.FAILED)
            and self.gameOverDatas.winType == enGameOverType.FANG_PAO then
            img_hu:setVisible(true)
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/fangpao.png", ccui.TextureResType.localType)
        elseif (scoreitems.result == enResult.FANGPAO or scoreitems.result == enResult.FAILED) -- 加入抢杠胡
            and self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
            img_hu:setVisible(true)
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/icon_qianggang.png", ccui.TextureResType.localType)
        else
            img_hu:setVisible(false)
        end
    end

    self:showQuanMa(item,scoreitems)
end
function BranchFriendOverView:showQuanMa(item,scoreitems)
    local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")
    local flowerCards = scoreitems.fanma
    if self.gameOverDatas.isQuanMa and #flowerCards > 0 and hua_mj then
        hua_mj:setPositionX(hua_mj:getPositionX()+25)
        local zhongma = display.newSprite("games/guangdongjihumj/game/quanma_icon.png")
        zhongma:addTo(hua_mj)
        zhongma:setPosition(cc.p(-18,hua_mj:getContentSize().height/2))
    else
        if flowerCards and #flowerCards > 0 and hua_mj then
            hua_mj:setPositionX(hua_mj:getPositionX()+25)
            local zhongma = display.newSprite("games/guangdongjihumj/game/zhongma.png")
            zhongma:addTo(hua_mj)
            zhongma:setPosition(cc.p(-18,hua_mj:getContentSize().height/2))

        end
    end
end
function BranchFriendOverView:addPlayerMjs(i,pan_mj)
    self.super.addPlayerMjs(self,i,pan_mj)
    local hua_mj = ccui.Helper:seekWidgetByName(pan_mj:getParent(), "right_card_panel")
    local scoreitem = self.m_scoreitems[i]
    local lFlowerCards = self:showFlowerCard(scoreitem.fanma,scoreitem.zhongma, hua_mj)
    self.m_PlayerCardList[i].FlowerCards = lFlowerCards
end
------------------------
-- 结算界面花牌的显示
-- flowerCards 花牌的牌值
-- parent 花牌的父节点
function BranchFriendOverView:showFlowerCard(flowerCards,zhongma, parent)
    
    local lCardList = {}
    if flowerCards and #flowerCards > 0 and parent then
        for i,k in pairs(flowerCards) do
            local flowSp = Mj.new(enMjType.MYSELF_PENG, k)
            local mjSize = flowSp:getContentSize()
            flowSp:setScaleX(20 / mjSize.width)
            flowSp:setScaleY(28 / mjSize.height)

            mjSize.width = mjSize.width * flowSp:getScaleX()
            mjSize.height = mjSize.height * flowSp:getScaleY()

            local index_x = (i - 1)%12
            flowSp:setPosition(cc.p((mjSize.width + 1) * index_x + mjSize.width * 0.5, (mjSize.height + 6) * (1 + math.floor((i-1)/12)) + mjSize.height / 2 - 4))
            flowSp:addTo(parent)
            local isZhong = false
            for j,v in pairs(zhongma) do
                if k == v then
                    isZhong = true
                end
            end
            if not isZhong then
                flowSp:setColor(cc.c3b(128, 128, 128))
            end
            table.insert(lCardList, flowSp)
        end
    end

    return lCardList
end
return BranchFriendOverView