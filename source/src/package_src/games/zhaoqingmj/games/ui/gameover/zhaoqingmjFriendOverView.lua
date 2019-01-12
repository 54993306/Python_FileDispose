local Define = require "app.games.common.Define"
local Mj     = require "app.games.common.mahjong.Mj"
local LayerTurnCard = require("app.games.common.custom.TurnCard.LayerTurnCard")

require("app.DebugHelper")
require "app.games.common.ui.gameover.FriendOverView"

function FriendOverView:ctor(data)
    self.super.ctor(self, "games/common/game/mj_over.csb", data);
    self:setkLaiziPang("package_res/games/zhaoqingmj/games/gui_tag.png")
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
    local laiziName = ccui.Helper:seekWidgetByName(laiziPanel, "laizi_tip")
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

    --------------------show fanma-------------------------------
    self:showAniTurnCard()
    -------------------------------------------------------------
end


-------------------------------
-- 显示赖子
-- @laiziPanel 赖子层
-- @laiziList 赖子列表
-- @laiziName 赖子名称
function FriendOverView:showLaiziList(laiziPanel, laiziList, laiziName)
    laiziName:setString("鬼牌")
    if #laiziList > 0 then
        for i = 1, #laiziList do
            if laiziList[i] > 20 then
                local laiziMj = Mj.new(enMjType.MYSELF_PENG, laiziList[i])
                laiziMj:setScaleX(32 / laiziMj:getContentSize().width)
                laiziMj:setScaleY(40 / laiziMj:getContentSize().height)
                local mjSize = cc.size(laiziMj:getContentSize().width * laiziMj:getScaleX(), laiziMj:getContentSize().height * laiziMj:getScaleY())
                laiziMj:setPosition(cc.p(mjSize.width * i + 46, mjSize.height + 4))
                laiziMj:setAnchorPoint(cc.p(0, 0))
                laiziPanel:addChild(laiziMj)
                self:addLaiziIcon(laiziMj)
            else
                laiziPanel:setVisible(false)
            end
        end
    else
        laiziPanel:setVisible(false)
    end
end

local getZhuangText = function(zhuangSite, site, playerCount)
    local siteMap4 = {
            [1] = {
            [2] = "庄下家",
            [3] = "庄对家",
            [4] = "庄上家",
            },
            [2] = {
            [1] = "庄上家",
            [3] = "庄下家",
            [4] = "庄对家",
            },
            [3] = {
            [1] = "庄对家",
            [2] = "庄上家",
            [4] = "庄下家",
            },
            [4] = {
            [1] = "庄下家",
            [2] = "庄对家",
            [3] = "庄上家",
            }
    }

    local siteMap3 = {
        [1] = {
        [2] = "庄下家",
        [3] = "庄上家",
        },
        [2] = {
        [1] = "庄上家",
        [3] = "庄下家",
        },
        [3] = {
        [1] = "庄下家",
        [2] = "庄上家",
        },
    }

    if playerCount == 4 then
        return siteMap4[zhuangSite][site]
    elseif playerCount == 3 then
        return siteMap3[zhuangSite][site]
    else
        return ""
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
    ------------------------------add-----
    local allZhongCards = {}
    for i=1, #self.gameOverDatas.ho do
        table.insert(allZhongCards, self.gameOverDatas.ho[i].card)
    end

    -----------------------------------------
    for i = 1, #players do
        self.m_PlayerCardList[i] = self.m_PlayerCardList[i] or {}
        local item  = itemModel:clone()
        item:setPosition(cc.p(14, bg_size.height - offsetY -(item:getContentSize().height + itemInterval) * i ))
        bg:addChild(item, 1);
        table.insert(self.playerPanels, item)
        local scoreitem = self.m_scoreitems[i]

        local img_zhuang = ccui.Helper:seekWidgetByName(item, "img_zhuang");
        --玩家 site  
        local site = players[i]:getProp(enCreatureEntityProp.SITE)
        local zhuangSite = self.gameSystem:gameStartGetBankerSite()
        --print("<jinds>: site in over is ", site )


        if site  and  zhuangSite ~= site and #players > 2 then
            local imgZuiDetail = display.newSprite("package_res/games/zhaoqingmj/games/site_detail.png")
            item:addChild(imgZuiDetail, 100)
            imgZuiDetail:setPosition(cc.p(55,60))
            --print("<jinds>: zhuang site ", zhuangSite, site)
            local text =  getZhuangText(zhuangSite, site, #players)
            local labelDesc = cc.Label:createWithTTF(text, "hall/font/fangzhengcuyuan.TTF", 16)
            imgZuiDetail:addChild(labelDesc)
            labelDesc:setAnchorPoint(cc.p(1, 0.5))
            labelDesc:setPosition(imgZuiDetail:getContentSize().width, imgZuiDetail:getContentSize().height * 0.5)
        end


        local lab_fan = ccui.Helper:seekWidgetByName(item, "event_text");
        lab_fan:setPositionX(lab_fan:getPositionX() + 4)
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


        local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")
        line:setVisible(false)

        if #self.m_scoreitems[i].zhongCard > 0 or scoreitem.result == enResult.WIN then
            line:setVisible(true)
            self:showFlower(self.m_scoreitems[i].zhongCard, hua_mj, allZhongCards) --显示中的马
        end  

    end
end

function FriendOverView:initZhuangImg(item,player)
    local img_zhuang = ccui.Helper:seekWidgetByName(item, "img_zhuang");
    if player:getProp(enCreatureEntityProp.BANKER) then
        img_zhuang:setVisible(true)
    else
        img_zhuang:setVisible(false)
    end
end

function FriendOverView:initHuImage(item,scoreitems)
    local img_hu = ccui.Helper:seekWidgetByName(item, "img_hu");
    if scoreitems.result == enResult.WIN then --胡牌玩家
        if self.gameOverDatas.winType == 1 then
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/zimo.png", ccui.TextureResType.localType)
        elseif self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
            img_hu:loadTexture("package_res/games/zhaoqingmj/games/qiangganghu.png", ccui.TextureResType.localType)
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
        local textUnit = "x"
        local policyName = ""
        for i=1, #pon do
            policyName = pon[i]..textUnit..pos[i].." "
            if tonumber(pos[i]) > 0 then
                detail = detail..policyName
            end
            
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

local function tableFind(tb, ele)
    print("<jinds>: ele", ele)
    for i,v in ipairs(tb) do
        if ele == v then
            return true
        end
    end
    return false
end

------------------------
-- 结算界面花牌的显示
-- flowerCards 花牌的牌值
-- parent 花牌的父节点
function FriendOverView:showFlower(flowerCards, parent, allFanma)
    local lCardList = {}
    if allFanma and #allFanma > 0 and parent then
        local maSp = Mj.new(enMjType.MYSELF_PENG, 11)
        local mjSize = maSp:getContentSize()
        local maSign = display.newSprite("package_res/games/zhaoqingmj/games/ma_sign.png")
        maSign:addTo(parent)
        maSign:setAnchorPoint({0,0})
        maSign:setPosition(0, 5)

        for i,k in pairs(allFanma) do
            local maSp = Mj.new(enMjType.MYSELF_PENG, k)
            local mjSize = maSp:getContentSize()
            maSp:setScaleX(20 / mjSize.width)
            maSp:setScaleY(28 / mjSize.height)

            mjSize.width = mjSize.width * maSp:getScaleX()
            mjSize.height = mjSize.height * maSp:getScaleY()

            local index_x = (i - 1)%12 + 2
            maSp:setPosition(cc.p((mjSize.width + 1) * index_x + mjSize.width * 0.5, (mjSize.height + 6) * (1 + math.floor((i-1)/12)) + mjSize.height / 2 - 4))
            maSp:addTo(parent)
            
            if tableFind(flowerCards, k) then
                -- maSp:setMjState(enMjState.MJ_STATE_NORMAL)
            else
                maSp:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
                Log.i("<jinds>: false", maSp:getAnchorPoint())
            end
        end
    end

    return lCardList
end

--是否自己中马
function FriendOverView:getZhongmaInfo()
    local mineZhong = false 
    local players  = self.gameSystem:gameStartGetPlayers()       -- 玩家信息    
    for i = 1, #players do
        local scoreitem = self.m_scoreitems[i]
        for j = 1, #scoreitem.zhongCard do
            if scoreitem.userid ==  self.myUserid then
                mineZhong = true
            end
        end
    end
    return  mineZhong
end



--  展现翻牌动画
function FriendOverView:showAniTurnCard()
    self:setOverViewVisible(false)
    local lGameOverData = self.gameSystem:getGameOverDatas()
    local lTurnCardList = { }

    -- local startdata = self.gameSystem:getGameStartDatas()
    for i, v in ipairs(lGameOverData.ho) do
        local item = { CardID = v.card, Lottery = 0 }
        table.insert(lTurnCardList, item)
    end

    local mineZhong = self:getZhongmaInfo()

    local allLightMa = {}
    local players  = self.gameSystem:gameStartGetPlayers()       -- 玩家信息    
    for i = 1, #players do
        local scoreitem = self.m_scoreitems[i]
        if not mineZhong then
            for j = 1, #scoreitem.zhongCard do
                table.insert(allLightMa, scoreitem.zhongCard[j])
            end
        else
            if scoreitem.userid ==  self.myUserid then
                for j = 1, #scoreitem.zhongCard do
                        table.insert(allLightMa, scoreitem.zhongCard[j])
                end
            end
        end

    end

    -- Log.i("<jinds>: startdata.horseCards ", startdata.horseCards)
    -- Log.i("<jinds>: allLightMa ", allLightMa)
    for _,v in ipairs(allLightMa) do
        for j = 1, #lTurnCardList do
            if lTurnCardList[j].CardID and lTurnCardList[j].CardID == v  then
                lTurnCardList[j].Lottery = 1
            end
        end
    end
    
    -- dump(lTurnCardList, "<jinds> lTurnCardList：")

    --  没有翻牌数据则直接跳过翻牌动画
    if lGameOverData.winType == 3 or #lTurnCardList <= 0 then
        self:setOverViewVisible(true)
        return
    end

    --  添加翻牌动画

    local scene = cc.Director:getInstance():getRunningScene()
    local lLayerTurnCard = LayerTurnCard.new(lTurnCardList)
    scene:addChild(lLayerTurnCard, 999)
    lLayerTurnCard:doAniTurnCardOneByOne()
    local lDelayTime = lLayerTurnCard.m_AniTime + 3
    scene:performWithDelay( function()
        lLayerTurnCard:closed()
        self:setOverViewVisible(true)
    end , lDelayTime)
end

--  设置结算界面的可见性
function FriendOverView:setOverViewVisible(isVisible)
    local lBGPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg_panel")
    lBGPanel:setVisible(isVisible)
end
return FriendOverView