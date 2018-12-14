local FriendOverView = require("app.games.common.ui.gameover.FriendOverView")

local Mj    		= require "app.games.common.mahjong.Mj"
local MJFanMa= require("package_src.games.guangdongjihumj.MJFanMa")
local BranchFriendOverView = class("BranchFriendOverView",FriendOverView)

function BranchFriendOverView:ctor(data)
	BranchFriendOverView.super.ctor(self.super,data)

    self:setkLaiziPang("package_res/games/guangdongjihumj/game/laizi.png")
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
    local str = {}
    local index = 1
    local rule = ""
    if (#itemList > 0 ) then
        for i, v in pairs(itemList) do
            if str[index]== nil then
                str[index] = ""
            end
            local ruleWidth = Util.getFontWidth(str[index],19)
            if ruleWidth > 600 then
                ruleStr = ruleStr.."\n"
                index = index + 1
                rule = ""
            end
            local content = kFriendRoomInfo:getPlayingInfoByTitle(v)
            if ruleStr == "" then
                ruleStr = content.ch
            else
                ruleStr = string.format("%s %s", ruleStr, content.ch)
            end
            rule = rule..content.ch
            str[index] = rule
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
--    if scoreitems.result == enResult.WIN then
--        lab_fan:setVisible(true)
--    else
--        lab_fan:setVisible(false)
--    end
    -- 显示胡牌提示
    local detail = ""
    local pon = scoreitems.policyName or {}
    local pos = scoreitems.policyScore or {}
    if #pon > 0 then
        local textUnit = "番 "
        local policyName = ""
        for i=1, #pon do
            if #pos > 0 and pos[i] > 0 then
                policyName = pon[i]..pos[i]..textUnit
            else
                policyName = pon[i].." "
            end
            detail = detail..policyName
        end
        Log.i("FriendOverView:addPlayers....gameId", MjProxy:getInstance():getGameId())
    end
    -- 显示花牌数量
    local zhongma = 0 
    for i,v in pairs(self.gameOverDatas.maList) do
        if v.userid == scoreitems.userid then
            zhongma = v.zhongmaCount
        end
    end
    if zhongma > 0 then
        detail = detail.." "..zhongma.."马"
    end
    lab_fan:setString(detail)

end
function BranchFriendOverView:initHuImage(item,scoreitems)
    local img_hu = ccui.Helper:seekWidgetByName(item, "img_hu");
    if scoreitems.result == enResult.WIN then --胡牌玩家
        if self.gameOverDatas.winType == 1 then
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/zimo.png", ccui.TextureResType.localType)
        elseif self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
            img_hu:loadTexture("package_res/games/guangdongjihumj/game/qiangganghuicon.png", ccui.TextureResType.localType)
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
    self:showQuanMa(item,scoreitems)
end

function BranchFriendOverView:showQuanMa(item,scoreitems)
    local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")
    local flowerCards = scoreitems.fanma
    if self.gameOverDatas.isQuanMa and #flowerCards > 0 and hua_mj then
        hua_mj:setPositionX(hua_mj:getPositionX()+25)
        local zhongma = display.newSprite("package_res/games/guangdongjihumj/game/quanma_icon.png")
        zhongma:addTo(hua_mj)
        zhongma:setPosition(cc.p(-18,hua_mj:getContentSize().height/2))
    else
        if flowerCards and #flowerCards > 0 and hua_mj then
            hua_mj:setPositionX(hua_mj:getPositionX()+25)
            local zhongma = display.newSprite("package_res/games/guangdongjihumj/game/zhongma.png")
            zhongma:addTo(hua_mj)
            zhongma:setPosition(cc.p(-18,hua_mj:getContentSize().height/2))

        end
    end
end
function BranchFriendOverView:addPlayerMjs(i,pan_mj)
    self.super.addPlayerMjs(self,i,pan_mj)
    local hua_mj = ccui.Helper:seekWidgetByName(pan_mj:getParent(), "right_card_panel")
    local scoreitem = self.m_scoreitems[i]
    local lFlowerCards = self:showFlowerCard(scoreitem.fanma,scoreitem.zhongma, hua_mj,scoreitem)
    self.m_PlayerCardList[i].FlowerCards = lFlowerCards
end
------------------------
-- 结算界面花牌的显示
-- flowerCards 花牌的牌值
-- parent 花牌的父节点
function BranchFriendOverView:showFlowerCard(flowerCards,zhongma, parent,scoreitem)
    
    local lCardList = {}
    local buma = scoreitem.buma
    if (flowerCards and #flowerCards > 0) or (buma and #buma>0) then
        if parent then
            if #flowerCards + #buma <= 24 then
                for i,k in pairs(flowerCards) do
                    local flowSp = self:drawFanMa(i,k,parent,zhongma)
                    table.insert(lCardList, flowSp)
                end
                for i,k in pairs(buma) do
                    local bumazhongma = scoreitem.bumaZhongMa
                    local zhongma = {}
                    if bumazhongma then
                        zhongma = {k}
                    end
                    local flowSp = self:drawFanMa(#flowerCards+i,k,parent,zhongma,true)
                    table.insert(lCardList, flowSp)
                end
            else
                local img="package_res/games/guangdongjihumj/game/btn_fanma.png"
                local famaBtn = ccui.Button:create() 
                famaBtn:loadTextureNormal(img)
                famaBtn:addTo(parent)
        --        famaBtn:getLayoutParameter():setMargin({ left = 770, right = 0, top = 10, bottom = 0})
                famaBtn:setPosition(cc.p(30,40))
                famaBtn:addTouchEventListener(function(pWidget,EventType)
                    if EventType == ccui.TouchEventType.ended then
                        local data = self.gameSystem:getGameOverDatas()
                        for k,v in pairs( data.score) do
                            local isFanma = {}
                            for m,n in pairs(v.fanma) do
                                local mas = {}
                                mas.faI6 = n
                                mas.isM = 0
                                for i,j in pairs(v.zhongma) do
                                    if j == n then
                                        mas.isM = 1
                                    end
                                end
                                table.insert(isFanma,mas)
                            end
                            for m,n in pairs(v.buma) do
                                local mas = {}
                                mas.faI6 = n
                                mas.isM = 0
                                if v.bumaZhongMa then
                                    mas.isM = 1
                                end
                                table.insert(isFanma,mas)
                            end
                            data.score[k].faI9 = isFanma
                        end
                        local famaLayer=MJFanMa.new(data,true)
                        self.m_pWidget:addChild(famaLayer,10)
                    end
                end)
                local num=0
                for k,v in pairs(zhongma) do
        --            if v.isM==1 then
                        num=num+1
        --            end
                end
                if scoreitem.bumaZhongMa then
                    num = num + #scoreitem.buma
                end
                local ruleText = cc.Label:createWithTTF("中马"..num.."个", "hall/font/fangzhengcuyuan.TTF", 24)
                ruleText:addTo(parent)
                ruleText:setPosition(80, 40)
                ruleText:setAnchorPoint(cc.p(0, 0.5))
                ruleText:setColor(cc.c3b(0xb1, 0xcc, 0xa3))
            end
        end
    
    end
    return lCardList
end
------------
--绘制翻马
--i为第几个马
--k为翻马的牌
function BranchFriendOverView:drawFanMa(i,k,parent,zhongma,isBuMa)
    local bumaPosX = 0
    if isBuMa then
        bumaPosX = 5
    end
    local flowSp = Mj.new(enMjType.MYSELF_PENG, k)
    local mjSize = flowSp:getContentSize()
    flowSp:setScaleX(20 / mjSize.width)
    flowSp:setScaleY(28 / mjSize.height)

    mjSize.width = mjSize.width * flowSp:getScaleX()
    mjSize.height = mjSize.height * flowSp:getScaleY()

    local index_x = (i - 1)%12
--    if (index - 1)/12 > 2 then
--        bumaPosX = 0
--    end
    flowSp:setPosition(cc.p((mjSize.width + 1) * index_x + mjSize.width * 0.5+bumaPosX, (mjSize.height + 6) * (1 + math.floor((i-1)/12)) + mjSize.height / 2 - 4))
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
    return flowSp
end
-------------------------------
-- 显示赖子
-- @laiziPanel 赖子层
-- @laiziList 赖子列表
-- @laiziName 赖子名称
function BranchFriendOverView:showLaiziList(laiziPanel, laiziList, laiziName)
    self.super.showLaiziList(self,laiziPanel, laiziList, laiziName)
    laiziName:setString("鬼牌:")
end

return BranchFriendOverView