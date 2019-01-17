local Define = require "app.games.common.Define"
local Mj     = require "app.games.common.mahjong.Mj"
require("app.DebugHelper")
-- 加入回放层
local VideoControlLayer = require "app.games.common.ui.video.VideoControlLayer"
FriendOverView = class("FriendOverView", UIWndBase)
local kLaiziPang = "games/common/game/friendRoom/mjOver/laizi.png"
function FriendOverView:ctor(data)
    self.super.ctor(self, "games/common/game/mj_over.csb", data);
end
function FriendOverView:setkLaiziPang(png)
    kLaiziPang = png
end
local function addButtomPanelInfo(rootWidget, roomId, userId)
    local roomText = ccui.Helper:seekWidgetByName(rootWidget, "root_text")
    if IsPortrait then -- TODO
        roomText:setString(string.format("房号：%d", roomId))
        roomText:enableOutline(cc.c4b(63,34,4,255), 2)
        roomText:setFontSize(21)
    else
        roomText:setString(string.format("房间号：%d", roomId))
    end

    local userText = ccui.Helper:seekWidgetByName(rootWidget, "playerid_text")
    userText:setString(string.format("玩家ID：%d", userId))
    userText:setVisible(false)

    local time = os.time()
    local timeStr = os.date("%y-%m-%d-%H:%M", time)
    if IsPortrait then -- TODO
        timeStr = os.date("%y.%m.%d %H:%M", time)
    end
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
    if IsPortrait then -- TODO
        gameName:enableOutline(cc.c4b(63,34,4,255), 2)
        gameName:setFontSize(21)
    end
    self:setGameName(gameName) -- 设置游戏名称

    local startImage = ccui.Helper:seekWidgetByName(self.m_pWidget, "start_image")
    if kFriendRoomInfo:isGameEnd() or self:isLastGameCount() or self.isOver then --兼容旧版本逻辑所以三个全写上
        startImage:loadTexture("games/common/game/friendRoom/mjOver/text_total_score.png")
    end
	
	if VideotapeManager.getInstance():isPlayingVideo() then
        if IsPortrait then -- TODO
            startImage:loadTexture("hall/huanpi2/jiesuan/btn_back.png")
        else
            startImage:loadTexture("games/common/game/friendRoom/mjOver/text_back.png")
        end
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
            local laiziMj = Mj.new(enMjType.MYSELF_PENG, laiziList[i])
            laiziMj:setScaleX(32 / laiziMj:getContentSize().width)
            laiziMj:setScaleY(40 / laiziMj:getContentSize().height)
            local mjSize = cc.size(laiziMj:getContentSize().width * laiziMj:getScaleX(), laiziMj:getContentSize().height * laiziMj:getScaleY())
            laiziMj:setPosition(cc.p(mjSize.width * i + 46, mjSize.height + 4))
            laiziMj:setAnchorPoint(cc.p(0, 0))
            laiziPanel:addChild(laiziMj)
            self:addLaiziIcon(laiziMj)
        end
    else
        laiziPanel:setVisible(false)
    end
end

-------------------------------
-- 更新标题
-- @titleBg 标题背景图片
-- @img_title 标题图片
function FriendOverView:updateTitle(titleBg, img_title)
    for i=1,#self.m_scoreitems do
        if self.m_scoreitems[i].userid then
            local result = self.m_scoreitems[i]
            if result.totalGold > 0 then --我赢了
                if IsPortrait then -- TODO
                    img_title:loadTexture("games/common/game/friendRoom/mjOver/title_win.png")
                else
                    titleBg:loadTexture("games/common/game/friendRoom/mjOver/title_bg.png")
                    img_title:loadTexture("games/common/game/friendRoom/mjOver/title1.png")
                end
                break
            elseif result.totalGold < 0 then
                if IsPortrait then -- TODO
                    img_title:loadTexture("games/common/game/friendRoom/mjOver/title_fail.png")
                else
                    titleBg:loadTexture("games/common/game/friendRoom/mjOver/title_bg2.png")
                    img_title:loadTexture("games/common/game/friendRoom/mjOver/title3.png")
                end
                break
            else
                if IsPortrait then -- TODO
                    img_title:loadTexture("games/common/game/friendRoom/mjOver/title_ping.png")
                else
                    titleBg:loadTexture("games/common/game/friendRoom/mjOver/title_bg.png")
                    img_title:loadTexture("games/common/game/friendRoom/mjOver/title2.png")
                end
                break
            end
        end
    end 
end

------------------------
-- 设置规则
-- @param lab_rule  待设置的规则label
-- @param wanfa     玩法字符串: palyingInfo.wa
function FriendOverView:setRule(lab_rule, wanfa)
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
    if IsPortrait then -- TODO
        local ruleWidth = Util.getFontWidth(ruleStr,23)
        if ruleWidth > 2000 then
            lab_rule:setFontSize(19)
        end
    end
    lab_rule:setString(ruleStr)
end

--------------------------
-- 设置游戏名称
function FriendOverView:setGameName(gameName)
    local info = kFriendRoomInfo:getRoomBaseInfo()
    local gameTitle = info.gameName or GAME_NAME
    local areatable = kFriendRoomInfo:getAreaBaseInfo()
    if #areatable > 1 then -- 当多于一个地区选项时，增加前缀
        gameTitle = GC_GameName .. "-" .. gameTitle
    end
    gameName:setString(gameTitle)
end

function FriendOverView:addPlayers()

    local players  = self.gameSystem:gameStartGetPlayers()       -- 玩家信息    
    self.playerNum = #players
    local itemInterval = 0              --默认四人房
    local offsetY = 80
    if IsPortrait then -- TODO
        itemInterval = 10              --默认四人房
        offsetY = 30

        --修改 20171110 start 竖版换皮  diyal.yin
        --修改 20171110 end 竖版换皮 diyal.yin
    end
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

        local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")
        local lFlowerCards = self:showFlower(scoreitem.flowerCards, hua_mj)
        self.m_PlayerCardList[i].FlowerCards = lFlowerCards
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

function FriendOverView:initPlayerName(item,scoreitem)
    local lab_nick = ccui.Helper:seekWidgetByName(item, "player_name");
    local nickName = ""
    nickName = ToolKit.subUtfStrByCn(scoreitem.nick,0,5,"")
    lab_nick:setString(nickName)
    Util.updateNickName(lab_nick, nickName, 22)
    if IsPortrait then -- TODO
        local player_id = ccui.Helper:seekWidgetByName(item, "player_id");
        -- dump(scoreitem)
        player_id:setString("ID:"..scoreitem.userid)
    else
        if scoreitem.result == enResult.WIN then         -- 改变赢家名字颜色
            lab_nick:setColor(cc.c3b(253, 235, 42))
        else
            lab_nick:setColor(cc.c3b(55, 182, 102))
        end
    end
end

function FriendOverView:initScore(item,scoreitem)
    local score_panel = ccui.Helper:seekWidgetByName(item, "right_panel")
    local scoreSize = score_panel:getContentSize()
    local lab_socre
    if IsPortrait then -- TODO
        if scoreitem.totalGold == 0 then
            lab_socre = cc.Label:createWithTTF(scoreitem.totalGold, "hall/font/fangzhengcuyuan.TTF", 40)--cc.Label:createWithBMFont("hall/font/yellow_num.fnt", scoreitem.totalGold)
        elseif scoreitem.totalGold < 0 then
            lab_socre = cc.Label:createWithTTF(scoreitem.totalGold, "hall/font/fangzhengcuyuan.TTF", 40)--cc.Label:createWithBMFont("hall/font/green_num.fnt", scoreitem.totalGold)
        else
            lab_socre = cc.Label:createWithTTF("+"..scoreitem.totalGold, "hall/font/fangzhengcuyuan.TTF", 40)--cc.Label:createWithBMFont("hall/font/yellow_num.fnt", "+" .. scoreitem.totalGold)
            lab_socre:setColor(cc.c3b(255,253,87))
        end
        lab_socre:setPosition(cc.p(scoreSize.width - 5, scoreSize.height * 0.5 - 15))
        -- lab_socre:setScale(1.6)
        lab_socre:setAnchorPoint(cc.p(1, 0.5))
        score_panel:addChild(lab_socre, 1)
    else
        if scoreitem.totalGold == 0 then
            lab_socre = cc.Label:createWithBMFont("hall/font/yellow_num.fnt", scoreitem.totalGold)
        elseif scoreitem.totalGold < 0 then
            lab_socre = cc.Label:createWithBMFont("hall/font/green_num.fnt", scoreitem.totalGold)
        else
            lab_socre = cc.Label:createWithBMFont("hall/font/yellow_num.fnt", "+" .. scoreitem.totalGold)
        end
        lab_socre:setPosition(cc.p(scoreSize.width * 0.5, scoreSize.height * 0.5 - 8))
        lab_socre:setScale(1.6)
        lab_socre:setAnchorPoint(cc.p(0.5, 0.5))
        score_panel:addChild(lab_socre, 1)
    end
end

function FriendOverView:initHuImage(item,scoreitems)
    local img_hu = ccui.Helper:seekWidgetByName(item, "img_hu");
    if scoreitems.result == enResult.WIN then
        -- 胡牌玩家
        img_hu:setVisible(true)
        if self.gameOverDatas.winType == enGameOverType.ZI_MO then
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/zimo.png", ccui.TextureResType.localType)
        -- elseif self.gameOverDatas.winType == enGameOverType.FANG_PAO then
        --     img_hu:loadTexture("games/common/game/friendRoom/mjOver/hupai.png", ccui.TextureResType.localType)
        -- elseif self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
        --     img_hu:loadTexture("games/common/game/friendRoom/mjOver/icon_qiangganghu.png", ccui.TextureResType.localType)
        -- elseif self.gameOverDatas.winType == enGameOverType.GANG_KAI then
        --     img_hu:loadTexture("games/common/game/friendRoom/mjOver/icon_gangkai.png", ccui.TextureResType.localType)
        -- elseif self.gameOverDatas.winType == enGameOverType.DI_XIA_HU then
        --     img_hu:loadTexture("games/common/game/friendRoom/mjOver/hupai.png", ccui.TextureResType.localType)
        else
            -- img_hu:setVisible(false)  --  没匹配到就隐藏掉吧
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/hupai.png", ccui.TextureResType.localType)
        end
        if IsPortrait then -- TODO
            img_hu:setVisible(true)
        end
    elseif (scoreitems.result == enResult.FANGPAO or scoreitems.result == enResult.FAILED)
        and self.gameOverDatas.winType == enGameOverType.FANG_PAO then
        img_hu:setVisible(true)
        img_hu:loadTexture("games/common/game/friendRoom/mjOver/fangpao.png", ccui.TextureResType.localType)
    elseif (scoreitems.result == enResult.FANGPAO or scoreitems.result == enResult.FAILED)-- 加入抢杠胡
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
            policyName = pon[i]..pos[i]..textUnit
            detail = detail..policyName
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

------------------------
-- 结算界面花牌的显示
-- flowerCards 花牌的牌值
-- parent 花牌的父节点
function FriendOverView:showFlower(flowerCards, parent)
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

            table.insert(lCardList, flowSp)
        end
    end

    return lCardList
end

function FriendOverView:addPlayerMjs(index, pan_mj) 
    local scoreitem = self.m_scoreitems[index]
    if not IsPortrait then -- TODO
        scoreitem.index = index
    end
    local groupX = 36

    -- 显示吃碰杠牌
    groupX = self:initOperatorMj(scoreitem,pan_mj,groupX)
    -- 显示手牌
    if IsPortrait then -- TODO
        groupX, self.m_PlayerCardList[index].HandCard = self:initHandCard(scoreitem,pan_mj,groupX)  
    else
        groupX = self:initHandCard(scoreitem,pan_mj,groupX)  
    end
    -- 显示胡的牌
    self:initHuCard(scoreitem.lastCard,pan_mj,groupX)
end
-- 显示吃碰杠牌
function FriendOverView:initOperatorMj(scoreitem,pan_mj,groupX)
    
    local firstCards   = scoreitem.operatefirstCard                   -- 第一个动作的牌
    local operateType   = scoreitem.operateType                       -- 操作类型
    local operateCard   = scoreitem.operateCard                        -- 吃碰杠的哪张牌
    local oper_id      = scoreitem.operateUserid                      -- 吃碰杠谁的牌
    local lCardGroup = scoreitem.operateCardGroup  --    吃碰杠牌组
    local gap    = 10 -- 动作组间隙
    for i=1,#firstCards do
        local cardGroup = {}
        if #lCardGroup > 0 then
            cardGroup = lCardGroup[i]
        else
            cardGroup = self:getMjGroup(operateType[i],firstCards[i])
        end
        local groupNode,mjTab = self:mjGroup(cardGroup)        
        pan_mj:addChild(groupNode)
        if IsPortrait then -- TODO
            --修改 20171116 start 竖版换皮 吃碰杠跟其它手牌Y坐标  diyal.yin
            -- groupNode:setPosition(cc.p(groupX, pan_mj:getContentSize().height-20 ))--
            local groupSize = groupNode:getContentSize()
            groupNode:setPosition(cc.p(groupX, 0 ))--
            --修改 20171116 end 竖版换皮 吃碰杠跟其它手牌Y坐标  diyal.yin
        else
            groupNode:setPosition(cc.p(groupX, pan_mj:getContentSize().height / 2))
        end
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

function FriendOverView:convertSiteByPlayerNum(site)
    if self.playerNum == 4 then
       convertSite = site
    elseif self.playerNum == 3 then
        if site == enSiteDirection.SITE_OTHER then   --三人房没有对家
            convertSite = enSiteDirection.SITE_LEFT
        else
            convertSite = site
        end
    elseif self.playerNum == 2 then
        if site == enSiteDirection.SITE_MYSELF then
            convertSite = enSiteDirection.SITE_MYSELF
        else
            convertSite = enSiteDirection.SITE_OTHER
        end
    end
    return convertSite
end

-- --  获得两个id之间的相对位置(转换panel为本家)
--     SITE_MYSELF = 1, -- 自己 
--     SITE_RIGHT  = 2, -- 右边 
--     SITE_OTHER  = 3, -- 对面 
--     SITE_LEFT   = 4, -- 左边 
function FriendOverView:getRelativeSiteByID(panelID,operateID)
    local panelSite = self.gameSystem:getPlayerSiteById(panelID)
    panelSite = self:convertSiteByPlayerNum(panelSite)
    local operateSite = self.gameSystem:getPlayerSiteById(operateID)
   
    if panelSite == enSiteDirection.SITE_MYSELF then
       return operateSite
    elseif panelSite == enSiteDirection.SITE_RIGHT then
        if operateSite == enSiteDirection.SITE_MYSELF then
           return enSiteDirection.SITE_LEFT
        elseif operateSite == enSiteDirection.SITE_RIGHT then
            return enSiteDirection.SITE_MYSELF
        elseif operateSite == enSiteDirection.SITE_OTHER then
            return enSiteDirection.SITE_RIGHT
        elseif operateSite == enSiteDirection.SITE_LEFT then
            return enSiteDirection.SITE_OTHER
        else
            -- print("[ ERROR ]-----FriendOverView:getRelativeSiteByID---1--by-- linxiancheng") 
        end
    elseif panelSite == enSiteDirection.SITE_OTHER then
        if operateSite == enSiteDirection.SITE_MYSELF then
            return enSiteDirection.SITE_OTHER
        elseif operateSite == enSiteDirection.SITE_RIGHT then
            return enSiteDirection.SITE_LEFT
        elseif operateSite == enSiteDirection.SITE_OTHER then
            return enSiteDirection.SITE_MYSELF
        elseif operateSite == enSiteDirection.SITE_LEFT then
            return enSiteDirection.SITE_RIGHT
        else
            -- print("[ ERROR ]-----FriendOverView:getRelativeSiteByID---2--by-- linxiancheng")
        end
    elseif panelSite == enSiteDirection.SITE_LEFT then
        if operateSite == enSiteDirection.SITE_MYSELF then
            return enSiteDirection.SITE_RIGHT
        elseif operateSite == enSiteDirection.SITE_RIGHT then
            return enSiteDirection.SITE_OTHER
        elseif operateSite == enSiteDirection.SITE_OTHER then
            return enSiteDirection.SITE_LEFT
        elseif operateSite == enSiteDirection.SITE_LEFT then
            return enSiteDirection.SITE_MYSELF
        else
            -- print("[ ERROR ]-----FriendOverView:getRelativeSiteByID---3--by-- linxiancheng")
        end
    else
        -- print("[ ERROR ]-----FriendOverView:getRelativeSiteByID---4--by-- linxiancheng")      
    end
end

function FriendOverView:getMjGroup(operateType,firstMj)
    local cardGroup = {}
    if operateType == enOperate.OPERATE_CHI then
        cardGroup = {firstMj, firstMj + 1, firstMj + 2}
    elseif operateType == enOperate.OPERATE_PENG then
        cardGroup = {firstMj, firstMj, firstMj}
    elseif operateType == enOperate.OPERATE_MING_GANG 
        or operateType == enOperate.OPERATE_AN_GANG 
        or operateType == enOperate.OPERATE_JIA_GANG then
        cardGroup = {firstMj, firstMj, firstMj, firstMj}
    else
        cardGroup = {}
    end
    return cardGroup
end

function FriendOverView:getBlackIndex(operateType,site)
    site = self:convertSiteByPlayerNum(site)   
    if operateType == enOperate.OPERATE_PENG then
        if site == enSiteDirection.SITE_RIGHT then    -- 下家
            return 3                                  -- 4人麻将，碰,下家的牌，第3张,变暗 
        elseif site == enSiteDirection.SITE_LEFT then -- 上家
            return 1
        elseif site == enSiteDirection.SITE_OTHER then -- 对家
            return 2
        end
    elseif operateType == enOperate.OPERATE_MING_GANG
        or operateType == enOperate.OPERATE_JIA_GANG then
        if site == enSiteDirection.SITE_RIGHT then    -- 下家
            return 4                                  -- 4人麻将，杠,下家的牌，第4张,变暗 
        elseif site == enSiteDirection.SITE_LEFT then -- 上家
            return 1
        elseif site == enSiteDirection.SITE_OTHER then -- 对家
            return 2
        end
    end
    return 0
end

function FriendOverView:MjGroupBlackByValue(mjTab,value)
    for i=1,#mjTab do
        if mjTab[i]:getValue() ==  value then
            mjTab[i]:blackMj(true)
        else
            mjTab[i]:blackMj(false)
        end
    end
end

function FriendOverView:MjGroupBlackByIndex(mjTab,index)
    for i=1,#mjTab do
        if i == index then
            mjTab[i]:blackMj(true)
        else
            mjTab[i]:blackMj(false)
        end
    end
end

----------------------------
-- 添加麻将组的标记
function FriendOverView:addGroupIcon(groupNode, operateType, cardGroup)
    local groupSize = groupNode:getContentSize()
    local lTipsFilePath = ""
    if operateType == enOperate.OPERATE_AN_GANG then
        lTipsFilePath = "games/common/mj/common/angang.png"
    elseif operateType == enOperate.OPERATE_MING_GANG then
        lTipsFilePath = "games/common/mj/common/minggang.png"
    elseif operateType == enOperate.OPERATE_JIA_GANG then
        lTipsFilePath = "games/common/mj/common/bugang.png"
    elseif self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
        -- 根据赢家的Index来获取胡的牌, 然后在与胡的牌相同的碰牌上, 显示抢杠标签
        local winnerIndex = 1
        for i = 1, #self.m_scoreitems do
            if self.m_scoreitems[i].result == enResult.WIN then
                winnerIndex = i
                break
            end
        end
        --  如果抢杠的牌是癞子，则用HuCard来识别
        local humj = {}
        local lHuCard = self.m_scoreitems[winnerIndex].HuCard
        if lHuCard then
            humj = lHuCard
        else
            humj = self.m_scoreitems[winnerIndex].lastCard
        end
        if humj == cardGroup[1] then
            Log.i("FriendOverView:addGroupIcon find qianggang", humj)
            local atBg = display.newSprite("games/common/game/friendRoom/mjOver/qianggang.png")
            atBg:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height / 2 - 28))
            if IsPortrait then -- TODO
                --修改 20171110 start 竖版换皮  diyal.yin
                -- atBg:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height / 2 - 28))
                atBg:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height + 8))
                --修改 20171110 end 竖版换皮 diyal.yin
            else
                atBg:setScale(groupSize.width / atBg:getContentSize().width)
            end
            groupNode:addChild(atBg)
        end
        return
    else
        return
    end
    local lTipsBG = cc.Sprite:create("games/common/mj/common/angang_bg.png")
    groupNode:addChild(lTipsBG)
    if IsPortrait then -- TODO
        --修改 20171110 start 竖版换皮  diyal.yin
        -- lTipsBG:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height / 2 - 28))
        lTipsBG:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height + 8))
        --修改 20171110 end 竖版换皮 diyal.yin
    else
        lTipsBG:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height / 2 - 28))
    end
    lTipsBG:setScale(groupSize.width / lTipsBG:getContentSize().width)

    -- print("------------addGroupIcon",lTipsFilePath)
    local lTips = cc.Sprite:create(lTipsFilePath)
    lTips:setPosition(cc.p(lTipsBG:getContentSize().width / 2, lTipsBG:getContentSize().height / 2))
    lTipsBG:addChild(lTips)
end

--显示手牌
function FriendOverView:initHandCard(scoreitem,pan_mj,groupX)
    local laiziList = self.gameSystem:getGameStartDatas().laizi  
    local handCards    = scoreitem.closeCards               -- 手牌
    local handCradsMahjong = {}
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
        table.insert(handCradsMahjong,majiang)
    end
    if IsPortrait then -- TODO
        return groupX, handCradsMahjong
    else
        self.m_PlayerCardList[scoreitem.index].handCards = handCradsMahjong
        return groupX
    end
end

function FriendOverView:initHuCard(huMj,pan_mj,groupX)
    if huMj and huMj > 0 then
        local majiang   = Mj.new(enMjType.MYSELF_PENG, huMj)
        local mjSize    = majiang:getContentSize()
        majiang:setScaleX(32 / mjSize.width)
        majiang:setScaleY(40 / mjSize.height)
        mjSize.width = mjSize.width * majiang:getScaleX()
        mjSize.height = mjSize.height * majiang:getScaleY()
        pan_mj:addChild(majiang)
        majiang:setPosition(cc.p(groupX + 10, mjSize.height + mjSize.height / 2))
        self:addHuIcon(majiang)
    end
end
--------------------------
-- 添加胡牌角标
function FriendOverView:addHuIcon(majiang)
    local huIcon = display.newSprite("games/common/mj/common/icon_hu.png")
    huIcon:setAnchorPoint(cc.p(1,1))
    huIcon:setScale(0.8)
    huIcon:setPosition(cc.p(majiang:getContentSize().width /2 - 1, majiang:getContentSize().height / 2 - 10))
    majiang:addChild(huIcon, 2)
end

--------------------------
-- 添加赖子角标
function FriendOverView:addLaiziIcon(majiang)
    local laiziPng = cc.Sprite:create(kLaiziPang)
    laiziPng:setPosition(cc.p(-4, -6))
    laiziPng:setAnchorPoint(cc.p(0, 0))
    majiang:addChild(laiziPng, 1)
end

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
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
            if IsPortrait then -- TODO
                --修改 20171116 start 竖版换皮 吃碰杠跟其它手牌Y坐标  diyal.yin
                -- mahjong:setPosition(cc.p(mjWidth, mjSize.height * 0.5))
                mahjong:setPosition(cc.p(mjWidth, mjSize.height * 1.5))
                --修改 20171116 start 竖版换皮 吃碰杠跟其它手牌Y坐标  diyal.yin
            else
                mahjong:setPosition(cc.p(mjWidth, mjSize.height * 0.5))
            end
            mjWidth = mjWidth + mjSize.width
            table.insert(mjTab,mahjong)
        end
    end
    node:setContentSize(cc.size(mjWidth, 0))
    return node,mjTab
end

function FriendOverView:isLastGameCount()
    local totalCount = SystemFacade:getInstance():getTotalGameCount() or 0

    if totalCount > 0 then
        return not (FriendRoomInfo.getInstance():getShengYuCount() > 0 )
    else
        return false
    end
end

function FriendOverView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.btn_start then 
            if VideotapeManager.getInstance():isPlayingVideo() then
                Log.i("--wangzhi--onClickButton--")
                kPlaybackInfo:setVideoReturn(true)
                VideotapeManager.releaseInstance()
                MjMediator:getInstance():exitGame()
            else
                if(kFriendRoomInfo:isGameEnd() or self:isLastGameCount() or self.isOver) then--兼容旧版本逻辑所以三个全写上
                    if kFriendRoomInfo:isGameEnd() then
                        local tmpScene = MjMediator:getInstance():getScene();
                        tmpScene.m_friendOpenRoom:gameOverUICallBack();
                        UIManager.getInstance():popWnd(self);
                    else
                        Toast.getInstance():show("牌局结算中，请稍后...");
                    end
                else
                   UIManager.getInstance():popWnd(self);
                   -- 发送续局开始通知
                   MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_CONTINUE_START_NTF)
                   MjMediator:getInstance():continueGame(1)         
                end
                MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_OVER_FINISH_NTF)
            end
        elseif pWidget == self.btn_share then
            --分享
            TouchCaptureView.getInstance():showWithTime()
            kGameManager:shareScreen()
        end
    end
end

-- 收到返回键事件
function FriendOverView:keyBack()
end

function FriendOverView:initHeadImage(item,player)
    local img_head = ccui.Helper:seekWidgetByName(item, "head")
    img_head:loadTexture("hall/Common/default_head_2.png");
    local userId = player:getProp(enCreatureEntityProp.USERID)
    local imgURL = self.gameSystem:gameStartGetPlayerByUserid(userId):getProp(enCreatureEntityProp.ICON_ID) .. "";
    if string.len(imgURL) > 3 then
        local imgName = self.gameSystem:gameStartGetPlayerByUserid(userId):getProp(enCreatureEntityProp.USERID)..".jpg";
        local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(headFile) then
            img_head:loadTexture(headFile)
            img_head:setScale(70 / img_head:getContentSize().width)
        else
            self.netImgsTable[imgName] = img_head -- 继承自 UIWndBase
            self:getNetworkImage(imgURL, imgName)
        end
    else
        local headFile = "hall/Common/default_head_2.png"
        headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile)
        if io.exists(headFile) then
            img_head:loadTexture(headFile)
            img_head:setScale(70 / img_head:getContentSize().width)
        end
    end
    if IsPortrait then -- TODO
        if kFriendRoomInfo:isRoomMain(userId) then
            local img_host = ccui.Helper:seekWidgetByName(item, "img_host");--昵称--cc.Sprite:create("games/common/game/friendRoom/mjOver/fangzhu_tip.png")
            img_host:setVisible(true)
        end
    end
end

function FriendOverView:getNetworkImage(preUrl, fileName)
    Log.i("FriendOverViewFriendOverView.getNetworkImage", "-------url = " .. preUrl);
    Log.i("FriendOverView.getNetworkImage", "-------fileName = ".. fileName);
    if preUrl == "" or preUrl == nil then
        return
    end
    local onReponseNetworkImage = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkImage code", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        request:saveResponseData(savePath);
        self:onResponseNetImg(fileName);
    end
    local url = preUrl;
    --
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end

function FriendOverView:onResponseNetImg(imgName)
    if not imgName then return end
    local imgHead = self.netImgsTable[imgName] -- 继承自 UIWndBase
    if imgHead then
        imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(imgName) then
            imgHead:loadTexture(imgName);
            imgHead:setScale(70 / imgHead:getContentSize().width)
        end
    end
end

return FriendOverView
