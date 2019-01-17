
-- local PokerUtils = require("package_src.games.guandan.gdcommon.commontool.PokerUtils")
-- local PokerConst = require("package_src.games.guandan.gdcommon.data.PokerConst")
-- local BasePlayerDefine = require("package_src.games.guandan.gdcommon.data.BasePlayerDefine")
local GDPKGameoverView = class("GDPKGameoverView", PokerUIWndBase)
local PokerEventDef = require("package_src.games.guandan.gdcommon.data.PokerEventDef")
local GDDefine = require("package_src.games.guandan.gd.data.GDDefine")
local GDConst = require("package_src.games.guandan.gd.data.GDConst")

local SETTLEMENT_TYPE = {
    SINGLE = 1,--单局结算
    TOTAL = 2,--总结算
}
local RESULT_TYPE = {
    BOTH_UP = 1,--双上
    BOTH_DOWN = 2,--双下
}

local WHITE_COLOR = cc.c3b(255, 255, 255)
local YELLOW_COLOR = cc.c3b(255, 222, 66)

---------------------------------------
-- 函数功能：   构造函数 初始化数据
-- 返回值：     无
---------------------------------------
function GDPKGameoverView:ctor(data)
    self.super.ctor(self, "package_res/games/guandan/gameover.csb", data)
    --背景开始缩放比例
    self.bg_scale = 0.95
    --背景动画第一次放大时间
    self.bg_first_bscaleTime = 0.2
    --背景动画第一次放大比例
    self.bg_first_bscale = 1.1
    --背景动画第一次缩小比例
    self.bg_first_sscale = 0.9
    --背景动画第一次缩小时间
    self.bg_first_sscaleTime = 0.2
    --背景动画第二次放大小比例
    self.bg_second_bscale = 1.02
    --背景动画第二放大时间
    self.bg_second_bscaleTime = 0.1
    --背景动画第二次缩小时间
    self.bg_second_sscaleTime = 0.08
end

---------------------------------------
-- 函数功能：   初始化UI
-- 返回值：     无
---------------------------------------
function GDPKGameoverView:onInit()
    self.btnContinue = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_continue")
    self.btnContinue:addTouchEventListener(handler(self, self.onClickButton))
    --总结算
    if HallAPI.DataAPI:isGameEnd() then
        self.btnContinue:getChildByName("img_txt"):loadTexture("btn/btn_certain.png", ccui.TextureResType.plistType)
    end
    --返回按钮
    self.btnBack = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_back")
    self.btnBack:addTouchEventListener(handler(self, self.onClickButton))
    --确定按钮
    self.btnSure = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_sure")
    self.btnSure:addTouchEventListener(handler(self, self.onClickButton))
    --分享按钮
    self.btnShare = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_share")
    self.btnShare:addTouchEventListener(handler(self, self.onClickButton))
    
    self.panelTitleSingle = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_title_single")
    self.panelItemSingle = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_item_single")
    self.panelItemSingle:setVisible(false)

    self.panelTitleTotal = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_title_total")
    self.panelItemTotal = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_item_total")
    self.panelItemTotal:setVisible(false)
    self.panelCenterVS = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_center_vs")
    
    self.panelContent = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_content")
    local topPlayerID = DataMgr:getInstance():getIdBySeat(GDConst.SEAT_TOP)
    local rightPlayerID = DataMgr:getInstance():getIdBySeat(GDConst.SEAT_RIGHT)
    local leftPlayerID = DataMgr:getInstance():getIdBySeat(GDConst.SEAT_LEFT)
    local wanfaData = DataMgr:getInstance():getWanfaData()
    local isShengJi = false
    local duiYouZuDui = false
    for k,v in pairs(wanfaData) do
        if v == "shengji" then
            isShengJi = true
        end
        if v == "duiyouzudui" then
            duiYouZuDui = true
        end
    end

    if self.m_data.overType == SETTLEMENT_TYPE.SINGLE then
        self.btnContinue:setVisible(true)
        self.panelTitleSingle:setVisible(true)

        self.panelTitleTotal:setVisible(false)
        self.panelCenterVS:setVisible(false)
        self.btnSure:setVisible(false)
        self.btnShare:setVisible(false)

        local txtTitle1 = self.panelTitleSingle:getChildByName("txt_title_1")
        txtTitle1:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        local txtTitle2 = self.panelTitleSingle:getChildByName("txt_title_2")
        txtTitle2:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        if isShengJi then
            txtTitle2:setString("升级")
        else
            txtTitle2:setString("分数")
        end

        local rankId = {}
        for k,v in pairs(self.m_data.rankingMap) do
            rankId[v] = k
        end
        local topTwoSeat = {}
        for i=1, 4 do
            local item = self.panelItemSingle:clone()
            item:setPosition(cc.p(67, 331 - (i-1)*69))
            item:setVisible(true)
            local userId = tonumber(rankId[i])
            local color = YELLOW_COLOR
            if userId == leftPlayerID or userId == rightPlayerID then
                color = WHITE_COLOR
            end

            local txtName = item:getChildByName("txt_name")
            local txtResult = item:getChildByName("txt_result")
            local imgRank = item:getChildByName("img_rank")
            local imgRankSpecial = item:getChildByName("img_rank_special")

            local playerModel = DataMgr:getInstance():getPlayerInfo(userId)
            txtName:setColor(color)
            txtName:setString(playerModel:getProp(GDDefine.NAME))
            local score = self.m_data.playFenMap[tostring(userId)]
            if score > 0 then
                score = "+" .. score
            end
            txtResult:setColor(color)
            txtResult:setString(score)
            imgRankSpecial:setVisible(false)
            if i == 1 then
                topTwoSeat[i] = playerModel:getProp(GDDefine.SITE)
                imgRank:loadTexture("settlement_rank_first.png", ccui.TextureResType.plistType)
                imgRankSpecial:loadTexture("settlement_rank_first_icon.png", ccui.TextureResType.plistType)
                imgRankSpecial:setVisible(true)
            elseif i == 2 then
                topTwoSeat[i] = playerModel:getProp(GDDefine.SITE)
                imgRank:loadTexture("settlement_rank_second.png", ccui.TextureResType.plistType)
            elseif i == 3 then
                imgRank:loadTexture("settlement_rank_three.png", ccui.TextureResType.plistType)
            else
                imgRank:loadTexture("settlement_rank_end.png", ccui.TextureResType.plistType)
                imgRankSpecial:loadTexture("settlement_rank_end_icon.png", ccui.TextureResType.plistType)
                imgRankSpecial:setPosition(cc.p(32, 32))
                imgRankSpecial:setVisible(true)
            end
            self.panelContent:addChild(item)
        end
        --显示双上/双下
        local myRank = self.m_data.rankingMap[tostring(kUserInfo:getUserId())]
        local seat1 = topTwoSeat[1]
        local seat2 = topTwoSeat[2]
        if math.abs(seat1 - seat2) == 2 then
            if myRank <= 2 then
                self:addBothWinLose(RESULT_TYPE.BOTH_UP, myRank)
            else
                self:addBothWinLose(RESULT_TYPE.BOTH_DOWN, myRank)
            end
        end
    else
        self.panelTitleSingle:setVisible(false)
        self.btnContinue:setVisible(false)

        self.panelTitleTotal:setVisible(true)
        self.btnSure:setVisible(true)
        self.btnShare:setVisible(true)

        local txtTitle1 = self.panelTitleTotal:getChildByName("txt_title_1")
        txtTitle1:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        local txtTitle2 = self.panelTitleTotal:getChildByName("txt_title_2")
        txtTitle2:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        local txtTitle3 = self.panelTitleTotal:getChildByName("txt_title_3")
        txtTitle3:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        local shengjiRule = ""
        local midwayDisbanded = false
        if isShengJi then
            txtTitle3:setString("规则")
            shengjiRule = self:getUpdateRule(wanfaData)
            if self.m_data.halfWayDis then 
                midwayDisbanded = true
            end
        else
            txtTitle3:setString("总分")
        end
        --不升级场分数排名
        local fenRank = {}
        local fenRankID = {}
        for k,v in pairs(checktable(self.m_data.playFenMap)) do
            if next(fenRank) then
                local hasInsert = false
                for i=#fenRank, 1, -1 do
                    if v <= fenRank[i] then
                        hasInsert = true
                        table.insert(fenRank, i+1, v)
                        table.insert(fenRankID, i+1, k)
                        break
                    end
                end
                if not hasInsert then
                    table.insert(fenRank, 1, v)
                    table.insert(fenRankID, 1, k)
                end
            else
                table.insert(fenRank, v)
                table.insert(fenRankID, k)
            end
        end

        local startY = 0
        local disY = 0
        if duiYouZuDui then
            startY = 347
            disY = 51
            self.panelCenterVS:setVisible(true)
        else
            startY = 339
            disY = 69
            self.panelCenterVS:setVisible(false)
        end
        local winId = {}--赢家ID
        local firstScore = 1
        for k,v in pairs(self.m_data.playFenMap) do
            if v > firstScore then
                winId = {}
                table.insert(winId, k)
                firstScore = v
            elseif v == firstScore then
                table.insert(winId, k)
            end 
        end
        for i=1, 4 do
            local item = self.panelItemTotal:clone()
            item:setVisible(true)
            local index = i
            local color = YELLOW_COLOR
            if duiYouZuDui and i > 2 then
                startY = 174
                index = i - 2
                color = WHITE_COLOR
            elseif not duiYouZuDui then
                color = WHITE_COLOR
            end
            local txtName = item:getChildByName("txt_name")
            local txtResult = item:getChildByName("txt_result")
            local txtTotal = item:getChildByName("txt_total")
            local img_house_owner = item:getChildByName("img_house_owner")
            local img_big_winner = item:getChildByName("img_big_winner")
            img_big_winner:setVisible(false)
            txtName:setColor(color)
            txtResult:setColor(color)
            txtTotal:setColor(color)
            item:setPosition(cc.p(17, startY - (index-1)*disY))
            self.panelContent:addChild(item)

            local userId 
            --大赢家展示
            if duiYouZuDui then
                if i == 1 then
                    userId = kUserInfo:getUserId()
                elseif i == 2 then
                    userId = topPlayerID
                elseif i == 3 then
                    userId = leftPlayerID
                else
                    userId = rightPlayerID
                end
                if (not midwayDisbanded) and next(winId) and tonumber(winId[1]) == userId then
                    local posY = 0
                    if i <= 2 then
                        posY = 342
                    else
                        posY = 177
                    end
                    local img = ccui.ImageView:create("settlement_winner_both.png", ccui.TextureResType.plistType)
                    img:setPosition(cc.p(719, posY))
                    self.panelContent:addChild(img)
                end
            else
                userId = tonumber(fenRankID[i])
                for k,v in pairs(winId) do
                    if tonumber(v) == userId then
                        img_big_winner:setVisible(true)
                        break
                    end
                end
            end

            local playerModel = DataMgr:getInstance():getPlayerInfo(userId)
            txtName:setString(playerModel:getProp(GDDefine.NAME))
            local totalScore = self.m_data.playFenMap[tostring(userId)]
            if isShengJi then--升级场 一定是组队场
                if (not next(winId)) or
                    (totalScore == firstScore) then
                    txtTotal:setString(midwayDisbanded and "失败" or shengjiRule)
                else
                    txtTotal:setString("失败")
                end
            else
                txtTotal:setString(totalScore .. "分")
            end
            --几胜几负
            local info
            for k,v in pairs(self.m_data.plL) do
                if v.usI == userId then
                    info = v
                    break
                end
            end
            txtResult:setString(string.format("%d胜%d负", info.winCount, info.losCount))
            img_house_owner:setVisible(HallAPI.DataAPI:isRoomMain(info.usI))
        end
    end

    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        self.btnBack:setVisible(false)
    end
    -- 回放不用显示继续游戏按钮
    if VideotapeManager.getInstance():isPlayingVideo() then
        self.btnContinue:setVisible(false)
    end
end

function GDPKGameoverView:getUpdateRule(wanfaData)
    local shengjiRule = ""

    local myModel = DataMgr:getInstance():getMyPlayerModel()
    local ourGrade = myModel:getProp(GDDefine.OUR_GRADE)
    local otherGrade = myModel:getProp(GDDefine.OTHER_GRADE)
    for k,v in pairs(wanfaData) do
        if v == "guoA" then
            shengjiRule = "优先过A"
            break
        elseif v == "guo6" then
            shengjiRule = "优先过6"
            break
        elseif v == "guo10" then
            shengjiRule = "优先过10"
            break
        elseif v == "guo3" then
            shengjiRule = "优先过3"
            break
        elseif v == "guo4" then
            shengjiRule = "优先过4"
            break
        elseif v == "guo5" then
            shengjiRule = "优先过5"
            break
        elseif v == "guo7" then
            shengjiRule = "优先过7"
            break
        elseif v == "guo8" then
            shengjiRule = "优先过8"
            break
        elseif v == "guo9" then
            shengjiRule = "优先过9"
            break
        elseif v == "guoJ" then
            shengjiRule = "优先过J"
            break
        elseif v == "guoQ" then
            shengjiRule = "优先过Q"
            break
        elseif v == "guoK" then
            shengjiRule = "优先过K"
            break
        end
    end
    return shengjiRule
end

function GDPKGameoverView:addBothWinLose(resultType, myRank)
    local imgName, posY
    if resultType == RESULT_TYPE.BOTH_UP then
        imgName = "settlement_both_up.png"
    else
        imgName = "settlement_both_down.png"
    end
    if myRank <= 2 then
        posY = 338
    else
        posY = 198
    end
    local img = ccui.ImageView:create(imgName, ccui.TextureResType.plistType)
    img:setPosition(cc.p(695, posY))
    self.panelContent:addChild(img)
end
---------------------------------------
-- 函数功能：    展示UI
-- 返回值：      无
---------------------------------------
function GDPKGameoverView:onShow()
    HallAPI.SoundAPI:pauseMusic()
    self:initTitleAni()
end
---------------------------------------
-- 函数功能：    初始化玩家游戏数据
-- 返回值：      无
---------------------------------------
function GDPKGameoverView:initTitleAni()
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/guandan/anim/gameover/AnimationDDZ2.csb")
    local armature = ccs.Armature:create("AnimationDDZ2")
    armature:setPosition(cc.p(self.panelContent:getContentSize().width/2, self.panelContent:getContentSize().height-50))
    self.panelContent:addChild(armature)
    if self.m_data.overType == SETTLEMENT_TYPE.TOTAL then
        armature:getAnimation():play("AnimationZONGFEN")
    elseif self:checkIsWin() then
        kPokerSoundPlayer:playEffect("win")
        armature:getAnimation():play("AnimationWIN")
    else
        kPokerSoundPlayer:playEffect("lose")
        armature:getAnimation():play("AnimationLOSE")
    end
end

---------------------------------------
-- 函数功能：    检查玩家是否是赢家
-- 返回值：      无
---------------------------------------
function GDPKGameoverView:checkIsWin()
    local partnerID = DataMgr:getInstance():getIdBySeat(GDConst.SEAT_TOP)
    local myRank = self.m_data.rankingMap[tostring(kUserInfo:getUserId())]
    local partnerRank = self.m_data.rankingMap[tostring(partnerID)]
    if myRank == 1 or partnerRank == 1 then
        return true
    end
    return false
end

---------------------------------------
-- 函数功能：    点击事件处理
-- 返回值：      无
---------------------------------------
function GDPKGameoverView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn")
        if pWidget == self.btnContinue then
            if HallAPI.DataAPI:isGameEnd() then
                HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SHOWTOTALOVER)
            else
                HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
                HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_REQCONTINUE,1)
            end
        elseif pWidget == self.btnSure then
            HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_EXIT_GAME)
        elseif pWidget == self.btnShare then
            HallAPI.ViewAPI:shareScreen()
        elseif pWidget == self.btnBack then
            HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_EXIT_GAME)
        end
    end
end

---------------------------------------
-- 函数功能：    返回键事件处理
-- 返回值：      无
---------------------------------------
function GDPKGameoverView:keyBack()
end

---------------------------------------
-- 函数功能：  播放动画
-- 返回值： 无
---------------------------------------
function GDPKGameoverView:showAnimation()
    self.bg_container:setScaleY(self.bg_scale)
    transition.execute(self.bg_container,cc.ScaleTo:create(self.bg_first_bscaleTime,1,self.bg_first_bscale),{onComplete = function()
        transition.execute(self.bg_container,cc.ScaleTo:create(self.bg_first_sscaleTime,1,self.bg_first_sscale),{onComplete = function()
            transition.execute(self.bg_container,cc.ScaleTo:create(self.bg_second_bscaleTime,1,self.bg_second_bscale),{onComplete = function()
                transition.execute(self.bg_container,cc.ScaleTo:create(self.bg_second_sscaleTime,1,1),{onComplete = function()
                end})
            end})
        end})
    end})
end

return GDPKGameoverView