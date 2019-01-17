local Define = require "app.games.common.Define"
local Mj     = require "app.games.common.mahjong.Mj"
-- local LaPaoZuo = require "app.games.chaozhoumj.common.LaPaoZuoIconPanel"
require("app.DebugHelper")
require("app.games.common.ui.gameover.FriendOverView")

local kLaiziPang = "package_res/games/jieyangmj/game/laizi.png"

function FriendOverView:ctor(data)
    self.super.ctor(self, "games/common/game/mj_over.csb", data);
    self:setkLaiziPang(kLaiziPang);
end

local function addButtomPanelInfo(rootWidget, roomId, userId)
    local roomText = ccui.Helper:seekWidgetByName(rootWidget, "root_text")
    roomText:setString(string.format("房号：%d", roomId))
    roomText:enableOutline(cc.c4b(63,34,4,255), 2)
    roomText:setFontSize(21)
    -- roomText:getLayoutParameter():setMargin({ left = 0, right = 10 , top = 0, bottom = 0})

    local userText = ccui.Helper:seekWidgetByName(rootWidget, "playerid_text")
    userText:setString(string.format("玩家ID：%d", userId))
    userText:setVisible(false) --在上面已经显示id了，不需要这个了
    
    local time = os.time()
    local timeStr = os.date("%y.%m.%d %H:%M", time)
    local timeText = ccui.Helper:seekWidgetByName(rootWidget, "time_text")
    timeText:setString(string.format("日期：%s", timeStr))

    local versionText = ccui.Helper:seekWidgetByName(rootWidget, "version_text")
    versionText:setString(string.format("版本号：%s", VERSION))
end

function FriendOverView:onInit()
    if Define.ViewSizeType == 1 then
        local scalePan = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_scale")
        scalePan:setScale(cc.Director:getInstance():getVisibleSize().height/720)
    end
    self.gameSystem     = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.m_scoreitems   = self.gameSystem:getGameOverDatas().score
    self.gameOverDatas  = self.gameSystem:getGameOverDatas()
    self.isOver  = self.gameSystem:getGameOverDatas().isOver or false
    self.myUserid       = self.gameSystem:getMyUserId()

    self.playerPanels = {}

    --  玩家卡牌列表
    self.m_PlayerCardList = {}

    self.btn_start = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_start");
    self.btn_start:addTouchEventListener(handler(self, self.onClickButton));

    self.lab_rule = ccui.Helper:seekWidgetByName(self.m_pWidget, "game_rules");
    local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
    self:setRule(self.lab_rule, palyingInfo.wa)

    self.btn_share = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_shared")
    self.btn_share:addTouchEventListener(handler(self, self.onClickButton))

    if IS_YINGYONGBAO then
        self.btn_share:setVisible(false)
        local originMargin_start = self.btn_start:getLayoutParameter():getMargin()
        Log.i("originMargin", originMargin_start)
        originMargin_start.left = display.cx - self.btn_start:getContentSize().width / 2
        self.btn_start:getLayoutParameter():setMargin(originMargin_start)
    end
    
    local laiziList = self.gameSystem:getGameStartDatas().laizi
    local laiziPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "laizi_pannel")
    self.laiziName = ccui.Helper:seekWidgetByName(laiziPanel, "laizi_tip")
    self.laiziName:setString("鬼牌:")
    self:showLaiziList(laiziPanel, laiziList, laiziName)


    local gameName = ccui.Helper:seekWidgetByName(self.m_pWidget, "game_name")
    gameName:enableOutline(cc.c4b(63,34,4,255), 2)
    gameName:setFontSize(21)
    self:setGameName(gameName) -- 设置游戏名称

    local startImage = ccui.Helper:seekWidgetByName(self.m_pWidget, "start_image")
    if kFriendRoomInfo:isGameEnd() or self:isLastGameCount() or self.isOver then --兼容旧版本逻辑所以三个全写上
        startImage:loadTexture("games/common/game/friendRoom/mjOver/text_total_score.png")
    end

    -- 战绩回放中替换为返回按钮
    if VideotapeManager.getInstance():isPlayingVideo() then
        startImage:loadTexture("hall/huanpi2/jiesuan/btn_back.png")
    end
    
    -- 赢了
    local titleBg = ccui.Helper:seekWidgetByName(self.m_pWidget, "title_bg")
    local img_title = ccui.Helper:seekWidgetByName(self.m_pWidget, "title");

    self:updateTitle(titleBg, img_title)

    local playerInfo = kFriendRoomInfo:getRoomInfo();

    addButtomPanelInfo(self.m_pWidget, playerInfo.pa, self.myUserid)

    -- 玩家信息
    self:addPlayers()

end

-------------------------------
-- 显示赖子
-- @laiziPanel 赖子层
-- @laiziList 赖子列表
-- @laiziName 赖子名称
function FriendOverView:showLaiziList(laiziPanel, laiziList, laiziName)
    if #laiziList > 0 then
        for i = 1, #laiziList do
            if laiziList[i] == 0 then
                Log.i("laizi value == 0, 赖子的值是0")
                self.laiziName:setString("")
            else
                local laiziMj = Mj.new(enMjType.MYSELF_PENG, laiziList[i])
                laiziMj:setScaleX(32 / laiziMj:getContentSize().width)
                laiziMj:setScaleY(40 / laiziMj:getContentSize().height)
                local mjSize = cc.size(laiziMj:getContentSize().width * laiziMj:getScaleX(), laiziMj:getContentSize().height * laiziMj:getScaleY())
                laiziMj:setPosition(cc.p(mjSize.width * i + 46, mjSize.height + 4))
                laiziMj:setAnchorPoint(cc.p(0, 0))
                laiziPanel:addChild(laiziMj)
                self:addLaiziIcon(laiziMj)
            end
        end
    else
        laiziPanel:setVisible(false)
    end
end


function FriendOverView:addPlayers()

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
        -- if #players > 2 then
        --     self:initSide(item,players[i])
        -- end

        local pan_mj = ccui.Helper:seekWidgetByName(item, "left_card_panel");  
        pan_mj.player = players[i]  
        self:addPlayerMjs(i,pan_mj)

        local line = ccui.Helper:seekWidgetByName(item, "line")
        --line:setVisible(false)

        local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")


        if self.m_scoreitems[i].maCards and #self.m_scoreitems[i].maCards > 0 then
            self.m_scoreitems[i].hasZhuaMa = true     -- 是否有买马
        else
            self.m_scoreitems[i].hasZhuaMa = false
        end


        self:showMaPai(self.m_scoreitems[i].maCards,hua_mj)
        self:showTotleMaPai(self.gameOverDatas.fanma,hua_mj,self.m_scoreitems[i].hasZhuaMa)
        --self:showFlower(scoreitem.flowerCards, hua_mj)

    end
end

function FriendOverView:showTotleMaPai(maCards,parent,isZhuama)
    if self.gameOverDatas.winType == 3 then
        parent:setVisible(false)
    else

        if isZhuama then
           local label = cc.ui.UILabel.new({
            UILabelType = 2,
            text =  "翻马:",
            size = 14})
            label:align(display.CENTER)
            label:setPosition(20, 25)
            parent:addChild(label)

            if #maCards == 0 then
                label:setVisible(false)
            end

            for i,v in ipairs(maCards) do
                local maSp = Mj.new(enMjType.MYSELF_PENG,v.faI6)
                local mjSize = maSp:getContentSize()
                if v.isM == 0 then
                    maSp:setColor(cc.c3b(128,128,128))--暗显示
                elseif v.isM == 2 then
                maSp:setColor(cc.c3b(255,255,0))                   --高亮显示
                end

                maSp:setScaleX(0.4)
                maSp:setScaleY(0.4)

                mjSize.width = mjSize.width * maSp:getScaleX()
                mjSize.height = mjSize.height * maSp:getScaleY()
                maSp:setPosition(cc.p((i-1)*mjSize.width+50,40))
                maSp:addTo(parent)
            end
        else
            local label = cc.ui.UILabel.new({
            UILabelType = 2,
            text =  "翻马:",
            size = 14})
            label:align(display.CENTER)
            label:setPosition(20, 40)
            parent:addChild(label)

            if #maCards == 0 then
                label:setVisible(false)
            end

            for i,v in ipairs(maCards) do
                local maSp = Mj.new(enMjType.MYSELF_PENG,v.faI6)
                local mjSize = maSp:getContentSize()
                if v.isM == 0 then
                    maSp:setColor(cc.c3b(128,128,128))--暗显示
                elseif v.isM == 2 then
                maSp:setColor(cc.c3b(255,255,0))                   --高亮显示
                end

                maSp:setScaleX(0.4)
                maSp:setScaleY(0.4)

                mjSize.width = mjSize.width * maSp:getScaleX()
                mjSize.height = mjSize.height * maSp:getScaleY()
                maSp:setPosition(cc.p((i-1)*mjSize.width+50,55))
                maSp:addTo(parent)
            end

        end
    end
end

function FriendOverView:showMaPai(maCards,parent)
    if maCards and #maCards > 0 and self.gameOverDatas.fanma and #self.gameOverDatas.fanma == 0 then --只有买马, 没有翻马

        local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text =  "抓马:",
        size = 14})
        label:align(display.CENTER)
        label:setPosition(20, 40)
        parent:addChild(label)

        local posX =1
        local num = 6
        local change = false
        for i,v in ipairs(maCards) do
            local maSp = Mj.new(enMjType.MYSELF_PENG,v.faI6)
            local mjSize = maSp:getContentSize()
             if v.isM == 0 then
                maSp:setColor(cc.c3b(128,128,128))--暗显示
            elseif v.isM == 2 then
                maSp:setColor(cc.c3b(255,255,0))                   --高亮显示
            end
            maSp:setScaleX(0.8)
            maSp:setScaleY(0.8)

            mjSize.width = mjSize.width * maSp:getScaleX()
            mjSize.height = mjSize.height * maSp:getScaleY()
            if not change and i > num then
                posX = 1
            end
            local poY = i > num and 44 or 75
            local index_x = (posX-1)%12
            posX = posX + 1
            maSp:setPosition(cc.p((mjSize.width+1)*index_x+mjSize.width*0.5+50,poY))
            maSp:addTo(parent)
        end

    elseif maCards and #maCards > 0 and #self.gameOverDatas.fanma > 0  then -- 有翻马 有抓马
        local label = cc.ui.UILabel.new({
        UILabelType = 2,
        text =  "抓马:",
        size = 14})
        label:align(display.CENTER)
        label:setPosition(20, 55)
        parent:addChild(label)

        local posX =1
        local num = 6
        local change = false
        for i,v in ipairs(maCards) do
            local maSp = Mj.new(enMjType.MYSELF_PENG,v.faI6)
            local mjSize = maSp:getContentSize()
            if v.isM == 0 then
                maSp:setColor(cc.c3b(128,128,128))--暗显示
            elseif v.isM == 2 then
                maSp:setColor(cc.c3b(255,255,0))--高亮显示
            end

            maSp:setScaleX(0.4)
            maSp:setScaleY(0.4)

            mjSize.width = mjSize.width * maSp:getScaleX()
            mjSize.height = mjSize.height * maSp:getScaleY()
            if not change and i > num then
                posX = 1
            end
            local poY = i > num and 44 or 75
            local index_x = (posX-1)%12
            posX = posX + 1
            maSp:setPosition(cc.p((mjSize.width+1)*index_x+mjSize.width*0.5+40,poY))
            maSp:addTo(parent)
        end
    end
end



------------------------
-- 设置玩家详情
-- @param lab_fan       待设置的玩家详情label
-- @param scoreitems    玩家详情Table
function FriendOverView:setPlayerDetail(lab_fan, scoreitems)
    lab_fan:setString("")
    -- 只显示赢的玩家
    -- if scoreitems.result == enResult.WIN then
    --     lab_fan:setVisible(true)
    -- else
    --     lab_fan:setVisible(false)
    -- end
    -- 显示胡牌提示
    local detail = ""
    local pon = scoreitems.policyName or {}
    local pos = scoreitems.policyScore or {}
    if #pon > 0  
        and #pos > 0 then
        local textUnit = "X"
        local policyName = ""
        for i=1, #pon do
            print("<janlog> pon[i] ===",pon[i])
            -- 服务器 发送字段 “空格XXX空格”  
            if pon[i] == " 鸡胡 " or pon[i] == " 杠开翻倍 " or pon[i] == " 海底捞翻倍 " 
                or pon[i] == " 抢杠胡X3 "then
                policyName = pon[i]
            else
            policyName = pon[i]..textUnit..pos[i].." "
            end
         detail = detail..""..policyName
        end
        Log.i("FriendOverView:addPlayers....gameId", MjProxy:getInstance():getGameId())
    end


     -- 显示杠牌数量
    if scoreitems.gang > 0 then
        local gangStr = string.format("杠牌(%d花)", scoreitems.gang)
        detail = detail .. " " .. gangStr
    end



    -- 显示花牌数量
    if #scoreitems.flowerCards > 0 then
        local huaStr = string.format("花牌(%d花)", #scoreitems.flowerCards)
        detail = detail .. " " .. huaStr
    end
    lab_fan:setString(detail)
end

function FriendOverView:addPlayerMjs(index, pan_mj) 
    local scoreitem = self.m_scoreitems[index]
    local groupX = 36

    -- 显示吃碰杠牌
    groupX = self:initOperatorMj(scoreitem,pan_mj,groupX)
    -- 显示手牌
    groupX = self:initHandCard(scoreitem,pan_mj,groupX)  
    -- 显示胡的牌
    self:initHuCard(scoreitem.lastCard,pan_mj,groupX)
end
-- 显示吃碰杠牌
function FriendOverView:initOperatorMj(scoreitem,pan_mj,groupX)
    
    local firstCards   = scoreitem.operatefirstCard                   -- 第一个动作的牌
    local operateType   = scoreitem.operateType                       -- 操作类型
    local operateCard   = scoreitem.operateCard                        -- 吃碰杠的哪张牌
    local oper_id      = scoreitem.operateUserid                      -- 吃碰杠谁的牌
    local gap    = 10 -- 动作组间隙
    for i=1,#firstCards do
        local cardGroup = self:getMjGroup(operateType[i],firstCards[i])
        local groupNode,mjTab = self:mjGroup(cardGroup)        
        pan_mj:addChild(groupNode)
        groupNode:setPosition(cc.p(groupX, pan_mj:getContentSize().height / 2))
        local groupSize = groupNode:getContentSize()
        groupX = groupX + groupSize.width + gap
        -- 添加麻将组的标记
        self:addGroupIcon(groupNode, operateType[i], cardGroup)
        --吃牌的变暗是一个特殊的情况
        if operateType[i] == enOperate.OPERATE_CHI then
            self:MjGroupBlackByValue(mjTab,operateCard[i])
        else
            local relativeSite = self:getRelativeSiteByID(pan_mj.player:getProp(enCreatureEntityProp.USERID),oper_id[i])
            local balckIndex = self:getBlackIndex(operateType[i],relativeSite)
            self:MjGroupBlackByIndex(mjTab,balckIndex)
        end
    end
    return groupX
end


----------------------------
-- 添加麻将组的标记
function FriendOverView:addGroupIcon(groupNode, operateType, cardGroup)
    local groupSize = groupNode:getContentSize()
    if operateType == enOperate.OPERATE_AN_GANG then

        local atIcon = display.newSprite("package_res/games/jieyangmj/common/angang.png")
        atIcon:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height / 2 - 28))
        atIcon:setScale(groupSize.width / atIcon:getContentSize().width)
        groupNode:addChild(atIcon)
    elseif operateType == enOperate.OPERATE_MING_GANG then

        local atIcon = display.newSprite("package_res/games/jieyangmj/common/minggang.png")
        atIcon:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height / 2 - 28 ))
        atIcon:setScale(groupSize.width / atIcon:getContentSize().width)
        groupNode:addChild(atIcon)
    elseif operateType == enOperate.OPERATE_JIA_GANG then
        local atIcon = display.newSprite("package_res/games/jieyangmj/common/bugang.png")
        atIcon:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height / 2 - 28))
        atIcon:setScale(groupSize.width / atIcon:getContentSize().width)
        groupNode:addChild(atIcon)
    elseif self.gameOverDatas.winType ==  enGameOverType.QIANG_GANG_HU then
        -- 根据赢家的Index来获取胡的牌, 然后在与胡的牌相同的碰牌上, 显示抢杠标签
        local winnerIndex = 1
        for i=1,#self.m_scoreitems do
            if self.m_scoreitems[i].result == enResult.WIN then
                winnerIndex = i
                break
            end
        end
        local humj = self.m_scoreitems[winnerIndex].lastCard
        if humj == cardGroup[1] then
            Log.i("FriendOverView:addGroupIcon find qianggang", humj)
            local atBg = display.newSprite("games/common/game/friendRoom/mjOver/qianggang.png")
            atBg:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height / 2 - 28))
            atBg:setScale(groupSize.width / atBg:getContentSize().width)
            groupNode:addChild(atBg)
        end
    end
end

--显示手牌
function FriendOverView:initHandCard(scoreitem,pan_mj,groupX)
    local laiziList = self.gameSystem:getGameStartDatas().laizi  
    local handCards    = scoreitem.closeCards               -- 手牌
    for i=1,#handCards do
        local majiang   = Mj.new(enMjType.MYSELF_PENG, handCards[i])
        local mjSize    = majiang:getContentSize()
        majiang:setScaleX(32 / mjSize.width)
        majiang:setScaleY(40 / mjSize.height)

        mjSize.width = mjSize.width * majiang:getScaleX()
        mjSize.height = mjSize.height * majiang:getScaleY()
        
        pan_mj:addChild(majiang)
        majiang:setPosition(cc.p(groupX, mjSize.height + mjSize.height / 2)) 
        groupX = groupX + mjSize.width

        -- 显示赖子
        for k, v in pairs(laiziList)  do
            if majiang:getValue() == v then
                self:addLaiziIcon(majiang)
            end
        end
    end
    return groupX
end

function FriendOverView:mjGroup(cardGroup)
    local node = display.newNode()
    local mjWidth = 0
    local mjTab = {}
    if #cardGroup > 0 then
        for t=1, #cardGroup do
            local mahjong = Mj.new(enMjType.MYSELF_PENG, cardGroup[t])
            local mjSize  = mahjong:getContentSize()
            mahjong:setScaleX(32 / mjSize.width)
            mahjong:setScaleY(40 / mjSize.height)

            mjSize.width = mjSize.width * mahjong:getScaleX()
            mjSize.height = mjSize.height * mahjong:getScaleY()
            
            node:addChild(mahjong)
            mahjong:setPosition(cc.p(mjWidth, mjSize.height * 0.5))
            mjWidth = mjWidth + mjSize.width
            table.insert(mjTab,mahjong)
        end
    end
    node:setContentSize(cc.size(mjWidth, 0))
    return node,mjTab
end

return FriendOverView
