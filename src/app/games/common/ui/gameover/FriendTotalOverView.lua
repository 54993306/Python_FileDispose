FriendTotalOverView = class("FriendTotalOverView", UIWndBase)
local Define = require "app.games.common.Define"
local ObtainDialog = require("app.hall.common.ObtainDialog");

function FriendTotalOverView:ctor(...)
    -- print(debug.traceback())
    self.super.ctor(self.super, "games/common/game/mj_total_over.csb",...);
    self.gameSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.players = self.gameSystem:gameStartGetPlayers()
    self.m_clubCost = self.m_data.toRF and self.m_data.toRF or 0
    ------ add:总结算增加亲友圈ID  2018-7-10 ------
    self.m_clubId = kFriendRoomInfo:getRoomInfo().clI
    --------------------- end ---------------------
    self.m_playerInfo = {}
    self:sortPlayerInfo()

    --可在initProperty重写的属性
    self.gameName = "麻将" --当服务器没传过来的麻将名字以及GAME_NAME没值的时候使用这个显示麻将名字
    self.customItemNameOffset = 0 --结算详情项目的标题控件的偏移量
    self.customItemNumOffset = 0 --结算详情项目的分数控件的偏移量

    self:initProperty()
end

------------------------会被地方重写的方法
function FriendTotalOverView:initProperty()
end

------------------------会被地方重写的方法
function FriendTotalOverView:addResultItems(listView, data)
    self:addCustomItem(listView, nil, data.hu, self:getPathByKey(data,"scoreItem"))
end


local function getMainSite(self)
    for i=1,#self.players do
        if(kFriendRoomInfo:isRoomMain(self.m_data.plL[i].usI)) then
            return i
        end
    end
    return 1
end

local function sortInfo(self)
    for i=1,#self.players do
        local  site = (i - getMainSite(self) + (#self.players))%(#self.players) +1
        self.m_playerInfo[site] = self.m_data.plL[i]
    end
    Log.i("排序后玩家信息:",self.m_playerInfo)
end

local function initWinner(self)
    local maxValue = -99999
    for i=1,#self.m_playerInfo do
       local data = self.m_playerInfo[i]
       if(data.to>maxValue) then
          maxValue =data.to
       end
    end
    
    for i=1,#self.m_playerInfo do
        local data = self.m_playerInfo[i]
        if data.to > 0 and data.to >= maxValue then   -- 大赢家的分数必定大于0
            self.m_playerInfo[i].winner = true;
        else
            self.m_playerInfo[i].winner = false;
        end
    end
end 

local function getItemInterval(self)
    local offsetX = 34          --二三人房
    local itemInterval = 40
    if IsPortrait then -- TODO
        offsetX = 10          --二三人房
        itemInterval = 30
    end
    if #self.players == 3 then
        offsetX = offsetX + 130
        itemInterval = itemInterval + 20
    elseif #self.players == 2 then
        offsetX = offsetX + 260
        itemInterval = itemInterval + 80
    end
    return offsetX,itemInterval
end

function FriendTotalOverView:sortPlayerInfo()
    sortInfo(self)
    initWinner(self)
end

function FriendTotalOverView:initCommon()
    self.btn_share = ccui.Helper:seekWidgetByName(self.m_pWidget, "shared_btn")
    self.btn_share:addTouchEventListener(handler(self, self.onClickButton));
    
    if IS_YINGYONGBAO then
        self.btn_share:setVisible(false)        -- 应用宝审核时没有分享
    end
    -- 返回
    self.btn_back = ccui.Helper:seekWidgetByName(self.m_pWidget, "back_btn")
    self.btn_back:addTouchEventListener(handler(self, self.onClickButton));
    --房间号
    local roomText = ccui.Helper:seekWidgetByName(self.m_pWidget, "root_text")
    if IsPortrait then -- TODO
        roomText:setString(string.format("房间号:%d", kFriendRoomInfo:getRoomInfo().pa))
        roomText:enableOutline(cc.c4b(63,34,4,255), 2)
    else
        roomText:setString(string.format("房间号：%d", kFriendRoomInfo:getRoomInfo().pa))
    end

    local userText = ccui.Helper:seekWidgetByName(self.m_pWidget, "playerid_text")
    if IsPortrait then -- TODO
        userText:setString(string.format("玩家ID:%d", self.gameSystem:getMyUserId()))
        userText:setVisible(false)
    else
        userText:setString(string.format("玩家ID：%d", self.gameSystem:getMyUserId()))
    end

    local timeText = ccui.Helper:seekWidgetByName(self.m_pWidget, "time_text")
    if IsPortrait then -- TODO
        timeText:setString(string.format("日期:%s", os.date("%y-%m-%d-%H:%M", os.time())))
    else
        timeText:setString(string.format("日期：%s", os.date("%y-%m-%d-%H:%M", os.time())))
    end

    local versionText = ccui.Helper:seekWidgetByName(self.m_pWidget, "version_text")
    if IsPortrait then -- TODO
        versionText:setString(string.format("版本号:%s", VERSION))
    else
        versionText:setString(string.format("版本号：%s", VERSION))
    end

    local gameName = ccui.Helper:seekWidgetByName(self.m_pWidget, "game_name")
    if IsPortrait then -- TODO
        local info = kFriendRoomInfo:getRoomBaseInfo()
        local gameTitle = info.gameName or GAME_NAME or self.gameName
        local areatable = kFriendRoomInfo:getAreaBaseInfo()
        if #areatable > 1 then -- 当多于一个地区选项时，增加前缀
            gameTitle = GC_GameName .. "-" .. gameTitle
        end
        gameName:setString(gameTitle)
        gameName:enableOutline(cc.c4b(63,34,4,255), 2)
    else
        self:setGameName(gameName)
    end
    
    local clubText = ccui.Helper:seekWidgetByName(self.m_pWidget, "club_txt")
    clubText:setVisible(self.m_isClubRoom)
    clubText:setString(string.format("亲友圈付费：%d钻石", self.m_clubCost))
    ------ add:总结算增加俱乐部ID  2018-7-10 ------
    if self.m_clubId and tonumber(self.m_clubId) > 0 then
        local clubIdText = ccui.Helper:seekWidgetByName(self.m_pWidget, "club_id_txt")
        clubIdText:setString("亲友圈ID:" .. tostring(self.m_clubId))
    end
    -------------------- end -----------------------
end

--------------------------
-- 设置游戏名称
function FriendTotalOverView:setGameName(gameName)
    local info = kFriendRoomInfo:getRoomBaseInfo()
    local gameTitle = info.gameName or GAME_NAME or self.gameName
    local areatable = kFriendRoomInfo:getAreaBaseInfo()
    if #areatable > 1 then -- 当多于一个地区选项时，增加前缀
        gameTitle = GC_GameName .. "-" .. gameTitle
    end
    gameName:setString(gameTitle)
    gameName:setPositionX(gameName:getPositionX() - 30)
end

function FriendTotalOverView:onInit()
    if not IsPortrait then -- TODO
        if Define.ViewSizeType == 1 then
            local scalePan = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_scale")
            scalePan:setScale(cc.Director:getInstance():getVisibleSize().height/720)
        end
    end

    local playerInfo = kFriendRoomInfo:getRoomInfo();
    self.m_isClubRoom = playerInfo.clI ~= nil and playerInfo.clI > 0

    self.pan_Player = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg2")
    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/mj_total_over_item.csb")
    -- local resultItem = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/mj_total_over_result_item.csb")
    local offsetX,itemInterval = getItemInterval(self)
    for i = 1, #self.m_playerInfo do
        local item = itemModel:clone() 
        item.data = self.m_playerInfo[i]
        if IsPortrait then -- TODO
            item:setPosition(cc.p((item:getContentSize().width + itemInterval) * (i - 1) + offsetX, (self.pan_Player:getContentSize().height-item:getContentSize().height)/2))
        else
            item:setPosition(cc.p((item:getContentSize().width + itemInterval) * (i - 1) + offsetX, 98))
        end
        self.pan_Player:addChild(item, 100-i);

        self:initBgSource(item)
        if not IsPortrait then -- TODO
            self:initNewListBg(item)
        end
        self:initWinnerInfo(item)
        self:initScore(item)
        self:initRoomMainIcon(item)
        self:initHeadImage(item)
        self:initChargeInfo(item)

        local listView = ccui.Helper:seekWidgetByName(item, "listView")
        self:addResultItems(listView, item.data)
    end

    self:initCommon()
end

function FriendTotalOverView:getPathByKey(data, key)
    if key == "bgSource" then
        if data.winner then
          return "games/common/game/friendRoom/mjOver/total_over_item_win.png"
        else
          return "games/common/game/friendRoom/mjOver/total_over_item_fail.png"
        end
    elseif key == "listPath" then
        if data.winner then
          return "games/common/game/friendRoom/mjOver/total_sub_win_scale_bg.png"
        else
          return "games/common/game/friendRoom/mjOver/total_sub_fail_scale_bg.png"
        end
    elseif key == "chargeBgSource" then
        if data.winner then
          return "games/common/game/friendRoom/mjOver/win_charge_tip_bg.png"
        else
          return "games/common/game/friendRoom/mjOver/fail_chage_tip_bg.png"
        end
    elseif key == "scoreItem" then
        if data.winner then
          return "games/common/game/friendRoom/mjOver/total_win_tip_scale_bg.png"
        else
          return "games/common/game/friendRoom/mjOver/total_fail_tip_scale_bg.png"
        end
    end
end

function FriendTotalOverView:initNewListBg(item)
    local listBg = ccui.Helper:seekWidgetByName(item, "listBg")
    local listNewBg = ccui.Scale9Sprite:create(cc.rect(16, 16, 1, 1), self:getPathByKey(item.data,"listPath"))
    listNewBg:setContentSize( listBg:getContentSize() )
    listNewBg:setPosition(cc.p(listBg:getPositionX(), listBg:getPositionY()))
    listNewBg:setAnchorPoint(listBg:getAnchorPoint())
    listBg:getParent():addChild(listNewBg, -1)
    listBg:setVisible(false)
end

function FriendTotalOverView:initBgSource(item)
    if IsPortrait then -- TODO
        local bgSource = ccui.Layout:create()
        bgSource:setContentSize(item:getContentSize())
        bgSource:setName("bgSource")
        item:addChild(bgSource, -1)
    else
        local bgSource = ccui.Scale9Sprite:create(cc.rect(16, 16, 1, 1), self:getPathByKey(item.data,"bgSource") )
        bgSource:setContentSize(cc.size(266, 452))
        bgSource:setPosition(cc.p(0, 0))
        bgSource:setAnchorPoint(cc.p(0, 0))
        bgSource:setName("bgSource")
        item:addChild(bgSource, -1)
    end
end

function FriendTotalOverView:initWinnerInfo(item)
    if IsPortrait then -- TODO
        if IS_YINGYONGBAO or not item.data.winner then
            return
        end
    else
        if not item.data.winner then
            return
        end
    end

    local bgSource = item:getChildByName("bgSource")
    if IsPortrait then -- TODO
        local dyjTip = cc.Sprite:create("games/common/game/friendRoom/mjOver/text_dyj.png")
        dyjTip:setPosition(cc.p(bgSource:getContentSize().width * 0.7, 80))
        item:addChild(dyjTip, 10)
    else
        local dyjTip = cc.Sprite:create("games/common/game/friendRoom/mjOver/text_dayingjia.png")
        dyjTip:setPosition(cc.p(bgSource:getContentSize().width * 0.5 - 25, bgSource:getContentSize().height - 6)) -- 调整位置，第4个玩家胡，会超出屏幕
        item:addChild(dyjTip, 10)
    end
    -- item.data.wiA = 10
    if item.data.wiA == nil or item.data.wiA == 0 then return end
    local scripBg = cc.Sprite:create("hall/huanpi2/Common/scrip_bg2.png")
    if IsPortrait then -- TODO
        --修改 20171114 start 竖版换皮 修改牌局结束总结算获取元宝角标 diyal.yin
        -- scripBg:pos(bgSource:getContentSize().width,bgSource:getContentSize().height-30)
        scripBg:pos(bgSource:getContentSize().width * 0.85, bgSource:getContentSize().height-30)
        --修改 20171114 end 竖版换皮 修改牌局结束总结算获取元宝角标 diyal.yin
    else
        scripBg:pos(bgSource:getContentSize().width - 25,bgSource:getContentSize().height-20)
    end
    item:addChild(scripBg)
    scripBg:setScale(0.8)

    local scripNum = cc.Label:createWithBMFont("hall/font/yellow_num_hrl.fnt",item.data.wiA)
    scripNum:setRotation(33)
    scripNum:pos(scripBg:getContentSize().width/2-20,scripBg:getContentSize().height/2 + 10)
    scripBg:addChild(scripNum)

    if item.data.usI==self.gameSystem:getMyUserId() then
        local dialog = UIManager.getInstance():pushWnd(ObtainDialog);
        dialog:setPropData(2,item.data.wiA)
    end
end

function FriendTotalOverView:initScore(item)
    local pan_score = ccui.Helper:seekWidgetByName(item, "score_bg");--总分
    local scoreSize = pan_score:getContentSize()
    local score_num = item.data.to
    if score_num > 0 then
        local score
        if IsPortrait then -- TODO
            score =  cc.Label:createWithTTF("+" .. score_num, "hall/font/fangzhengcuyuan.TTF", 42)--cc.Label:createTTF("+" .. score_num,)--cc.Label:createWithBMFont("hall/font/yellow_num.fnt", "+" .. score_num)
            score:setPosition(cc.p(scoreSize.width * 0.5 , scoreSize.height * 0.5 ))--+ 40
            -- score:setScale(1.5)
            score:setColor(cc.c3b(255,253,87))
        else
            score = cc.Label:createWithBMFont("hall/font/yellow_num.fnt", "+" .. score_num)
            score:setPosition(cc.p(scoreSize.width * 0.5 + 40, scoreSize.height * 0.5 - 8))
            score:setScale(1.5)
        end
        score:setAnchorPoint(cc.p(0.5, 0.5))
        pan_score:addChild(score, 1)

        local winTip = cc.Sprite:create("games/common/game/friendRoom/mjOver/win_tip.png")
        local bgSource = item:getChildByName("bgSource")
        winTip:setPosition(cc.p(bgSource:getContentSize().width - 4, bgSource:getContentSize().height - 4))
        winTip:setAnchorPoint(cc.p(1, 1))

        if item.data.wiA == nil or item.data.wiA == 0 then
            item:addChild(winTip, 1)
        end
    else
        local score
        if IsPortrait then -- TODO
            score = cc.Label:createWithTTF(score_num, "hall/font/fangzhengcuyuan.TTF", 42)--cc.Label:createWithBMFont("hall/font/green_num.fnt", score_num)
            score:setPosition(cc.p(scoreSize.width * 0.5 , scoreSize.height * 0.5 ))--+ 40
        else
            score = cc.Label:createWithBMFont("hall/font/green_num.fnt", score_num)
            score:setPosition(cc.p(scoreSize.width * 0.5 + 40, scoreSize.height * 0.5 - 8))
            score:setScale(1.5)
        end
        score:setAnchorPoint(cc.p(0.5, 0.5))
        pan_score:addChild(score, 1)
    end
end

function FriendTotalOverView:initRoomMainIcon(item)
    local lab_id = ccui.Helper:seekWidgetByName(item, "playerid_text");--id
    lab_id:setString("ID:"..item.data.usI)

    local lab_nick = ccui.Helper:seekWidgetByName(item, "player_name");--昵称

    if IsPortrait then -- TODO
        local idPanelWidth = 350
        local usIdWidth,usIdLen = Util.getTextWidth("ID:"..item.data.usI,26)
        if usIdLen > 9 then
            lab_id:setFontSize(idPanelWidth/usIdLen)
        end
    else
        lab_nick:setColor(cc.c3b(252, 235, 42))
    end

    Util.updateNickName(lab_nick, ToolKit.subUtfStrByCn(item.data.niN, 0, 5, ""), 22)

    if kFriendRoomInfo:isRoomMain(item.data.usI) then
        if IsPortrait then -- TODO
            local img_host = ccui.Helper:seekWidgetByName(item, "img_host");--昵称--cc.Sprite:create("games/common/game/friendRoom/mjOver/fangzhu_tip.png")
            img_host:setVisible(true)
        else
            local img_host = cc.Sprite:create("games/common/game/friendRoom/mjOver/fangzhu_tip.png")
            img_host:setPosition(4, item:getContentSize().height - 4)
            img_host:setAnchorPoint(cc.p(0, 1))
            item:addChild(img_host)
        end
    end
end
--
function FriendTotalOverView:initChargeInfo(item)
    if item.data.roFS == 0 or item.data.roFS == nil then    -- 非付费玩家不显示付费信息
        return
    end
    local texts = {[-1] = "付费信息:", [1] = "房主付费:", [2] = "大赢家付费:", [3] = "AA付费:"}
    -- setmetatable(texts, texts)
    -- texts.__index = function(table, key)
    --     return "付费信息:"
    -- end
    local idex = item.data.roJST > 0 and item.data.roJST < 4 and item.data.roJST or -1
    local scoreTips = ccui.Helper:seekWidgetByName(item,"score_tip")
    if IsPortrait then -- TODO
        local label_pay_info=ccui.Helper:seekWidgetByName(item,"label_pay_info")
        if IS_YINGYONGBAO then
            label_pay_info:setVisible(false)
        else
            label_pay_info:setString(string.format("%s %d钻石", texts[idex], item.data.roFS))
        end
    else
        local chargeBg = cc.Sprite:create(self:getPathByKey(item.data,"chargeBgSource"))
        local chargeInfo = display.newTTFLabel{size = 16,color = cc.c3b(0x07, 0x47, 0x4b), font = "hall/font/fangzhengcuyuan.TTF"}
        chargeInfo:setString(string.format("%s %d钻石", texts[idex], item.data.roFS))
        chargeInfo:pos(chargeBg:getContentSize().width/2,chargeBg:getContentSize().height/2)
        chargeBg:addChild(chargeInfo)
        chargeBg:pos(scoreTips:getPositionX()+20,scoreTips:getPositionY()+30)
        scoreTips:getParent():addChild(chargeBg)
    end
end

function FriendTotalOverView:addCustomItem(listView, titleStr, num, bgPath)
    local resultItem = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/mj_total_over_result_item.csb")

    if not IsPortrait then -- TODO
        local huBg = ccui.Helper:seekWidgetByName(resultItem, "bg")
        local huNewBg = ccui.Scale9Sprite:create(cc.rect(110, 10, 1, 1), bgPath)
        huNewBg:setContentSize(cc.size(222, 45))
        huNewBg:setPosition(huBg:getPosition())
        huNewBg:setAnchorPoint(huBg:getAnchorPoint())
        huBg:getParent():addChild(huNewBg, -1)
        huBg:setVisible(false)
    end

    if titleStr then
        local lab_name = ccui.Helper:seekWidgetByName(resultItem, "event_text")
        lab_name:setString(titleStr)
        lab_name:setPositionX(lab_name:getPositionX()+self.customItemNameOffset)
    end
    if num then
        local lab_num = ccui.Helper:seekWidgetByName(resultItem, "event_num")
        lab_num:setString("" .. num)
        lab_num:setPositionX(lab_num:getPositionX()+self.customItemNumOffset)
    end
    listView:pushBackCustomItem(resultItem)
end

function FriendTotalOverView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kFriendRoomInfo:setGameEnd(false)
        if pWidget == self.btn_share then 
            TouchCaptureView.getInstance():showWithTime()
            kGameManager:shareScreen()
        elseif pWidget == self.btn_back then
            if not IsPortrait then -- TODO
                if self.m_data.isMaintain then
                    Log.i("self.m_data.isMaintain")
                    SocketManager.getInstance():closeSocket();
                    -- if not UIManager.getInstance():getWnd(HallLogin) then
                    --     UIManager.getInstance():recoverToDesignOrient();
                    --     local info = {};
                    --     info.isExit = true;
                    --     UIManager.getInstance():replaceWnd(HallLogin, info);
                    -- end
                end
            end
            MjMediator:getInstance():exitGame()
        end
    end
end

function FriendTotalOverView:initHeadImage(item)
    local img_head = ccui.Helper:seekWidgetByName(item, "img_head");--头像
    local playerInfo = kFriendRoomInfo:getRoomPlayerListInfo(item.data.usI)
    if playerInfo and string.len(playerInfo.heI) > 3 then
        local imgName = self.gameSystem:gameStartGetPlayerByUserid(item.data.usI):getProp(enCreatureEntityProp.USERID)..".jpg";
        local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(headFile) then
            img_head:loadTexture(headFile);
            -- img_head:setScale(70 / img_head:getContentSize().width)
        else
            -- print("------------------FriendTotalOverView:initHeadImage")    -- 不存在这种情况，其他玩家的图片在牌局中一定被下载好了
        end
    else        
        local headFile = "hall/Common/default_head_2.png";
        headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
        if io.exists(headFile) then
            img_head:loadTexture(headFile)
            -- img_head:setScale(70 / img_head:getContentSize().width)
        end
    end
end
-- 收到返回键事件
function FriendTotalOverView:keyBack()
end

return FriendTotalOverView
