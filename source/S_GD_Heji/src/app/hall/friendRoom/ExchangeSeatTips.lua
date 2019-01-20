
ExchangeSeatTips = class("ExchangeSeatTips", UIWndBase)
local CircleClippingNode = require("app.games.common.custom.CircleClippingNode")

local TIPS_TYPE = {
    APPLY = 1,--发起申请
    REFUSE = 2,--玩家拒绝
    SUCCESS = 3,--交换成功
    OTHER_APPLY = 4,--别的玩家请求与你交换
    OTHER_EXCHANGE = 5,--其他玩家要交换
}

function ExchangeSeatTips:ctor(data, zorder)
--##  asUI       发起问询的用户ID 发起人
--##  beAUI     收到请求的玩家Id
--##  re          结果(-1:没有问询   0:还没有回应   1:同意  2:不同意)
--##  CoD       倒计时
--##  ty            0默认  1发起交换请求  2回答交换请求
--##  chST  接受交换true 不接受交换false
    if IsPortrait then
        self.super.ctor(self, "package_res/games/guandan/hall/exchangeSeatTips.csb", data, WND_ZORDER_COMMONDDIALOG)
    else
        self.super.ctor(self, "package_res/games/guandan/hall/exchangeSeatTips_horizontal.csb", data, WND_ZORDER_COMMONDDIALOG)
    end
end

function ExchangeSeatTips:onInit()
    self.m_headImage = {}
    self.m_headIndex = {}
    self.netImgsTable = {}

    self.baseShowType = UIWndBase.BaseShowType.RTOL

    local btnClose = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close")
    self:addWidgetClickFunc(btnClose, handler(self, self.CommonClose))

    --知道啦
    self.btnKnow = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_know")
    self:addWidgetClickFunc(self.btnKnow, handler(self, self.CommonClose))
    --不换
    self.btnRefuse = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_refuse")
    self.btnRefuse:addTouchEventListener(handler(self, self.onClickButton))
    --换
    self.btnExchange = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_exchange")
    self.btnExchange:addTouchEventListener(handler(self, self.onClickButton))
    self.txtTime = ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_time")

    self.countDownTime = self.m_data.CoD
    if self.m_data.asUI ~= kUserInfo:getUserId() and self.m_data.beAUI ~= kUserInfo:getUserId() then
        --别的玩家交换申请，提示用
        self.tipsType = TIPS_TYPE.OTHER_EXCHANGE
        if self.m_data.reconnect then
            self.m_data.ty = 1
        end
    elseif self.m_data.asUI == kUserInfo:getUserId() and self.m_data.ty == 1 then--我发起的申请
        self.tipsType = TIPS_TYPE.APPLY
    elseif self.m_data.beAUI == kUserInfo:getUserId() and self.m_data.ty == 1 then--别的玩家请求与我交换
        self.tipsType = TIPS_TYPE.OTHER_APPLY
    elseif self.m_data.ty == 2 then--申请结果
        if self.m_data.chST then
            self.tipsType = TIPS_TYPE.SUCCESS
        else
            self.tipsType = TIPS_TYPE.REFUSE
        end
    elseif self.m_data.reconnect then
        if self.m_data.asUI == kUserInfo:getUserId() then
            self.tipsType = TIPS_TYPE.APPLY
        elseif self.m_data.beAUI == kUserInfo:getUserId() then
            self.tipsType = TIPS_TYPE.OTHER_APPLY
        else
            self.tipsType = TIPS_TYPE.OTHER_EXCHANGE
            self.m_data.ty = 1
        end
    end
    local panelHeadLeft = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_head_left")
    local panelHeadRight = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_head_right")
    local askInfo = kFriendRoomInfo:getRoomPlayerListInfo(self.m_data.asUI)
    local nameL = panelHeadLeft:getChildByName("playerName")
    nameL:setString(askInfo.niN)
    self:downHead(askInfo, panelHeadLeft:getChildByName("headImg"), 1)

    local beInfo = kFriendRoomInfo:getRoomPlayerListInfo(self.m_data.beAUI)
    local nameR = panelHeadRight:getChildByName("playerName")
    nameR:setString(beInfo.niN)
    self:downHead(beInfo, panelHeadRight:getChildByName("headImg"), 2)

    self:tipsWords()
end
function ExchangeSeatTips:downHead(playerInfo, headImg, i)
    local headFile = "#1004291.png";
    if playerInfo.heI and string.len(playerInfo.heI) > 4 then
        local imgName = playerInfo.usI .. ".jpg"
        headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName)
        self.m_headImage[i] = headFile
        if io.exists(headFile) then
            local width = headImg:getContentSize().width
            local headIamge = CircleClippingNode.new(headFile, true , width)
            headIamge:setPosition(width/2, headImg:getContentSize().height/2)
            headImg:loadTexture(headFile)
            self.m_headIndex[imgName] = i
        else
            self.netImgsTable[imgName] = headImg
            self.m_headIndex[imgName] = i
            HttpManager.getNetworkImage(playerInfo.heI, imgName)
        end
    else
        self.m_headImage[i] = headFile
        headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile)
        if io.exists(headFile) then
            local width=headImg:getContentSize().width
            local headIamge = CircleClippingNode.new(headFile, true , width)
            headIamge:setPosition(width/2, headImg:getContentSize().height/2)
            headImg:loadTexture(headFile)
        end
    end
end
function ExchangeSeatTips:onResponseNetImg(imgName)
    local falg = false
    for k,v in pairs(self.m_headIndex) do
        if k == imgName then
            falg = true
        end
    end
    if falg  then
        local isFalg = false
        for k,v in pairs(self.netImgsTable) do
            if k == imgName then
                isFalg = true
            end
        end
        if isFalg then
            local  headImg = self.netImgsTable[imgName]
            local imageName = cc.FileUtils:getInstance():fullPathForFilename(imgName)
            self.m_headImage[self.m_headIndex[imgName]] = imageName
            if io.exists(imageName) then
                local width=headImg:getContentSize().width
                local headIamge = CircleClippingNode.new(imageName, true , width)
                headIamge:setPosition(width/2, headImg:getContentSize().height/2)
                headImg:loadTexture(imageName)
            end
        end
    else
        return 
    end
end

function ExchangeSeatTips:CommonClose()
    SoundManager.playEffect("btn")

    self:stopCountDown()
    if self.neeCancel and CountDownData and CountDownData.packetInfo then
        if CountDownData.clockHandle then
            scheduler.unscheduleGlobal(CountDownData.clockHandle)
            CountDownData.clockHandle = nil
        end
        if CountDownData.packetInfo.asUI == kUserInfo:getUserId() then
            local data = {
                asUI = CountDownData.packetInfo.asUI,
                beAUI = CountDownData.packetInfo.beAUI,
                ty = 1,
                chST = false,
            }
            FriendRoomSocketProcesser.sendPrivateRoomSeats(data)
        else
            --拒绝
            local data = {
                asUI = CountDownData.packetInfo.asUI,
                beAUI = CountDownData.packetInfo.beAUI,
                ty = 2,
                chST = false,
            }
            FriendRoomSocketProcesser.sendPrivateRoomSeats(data)
        end
    end

    UIManager.getInstance():popWnd(self)
end

function ExchangeSeatTips:startCountDown()
    self.clockHandle = scheduler.scheduleGlobal(
        function()
            if not tolua.isnull(self.txtTime) then
                self.countDownTime = self.countDownTime - 1
                if CountDownData and CountDownData.time then
                    self.txtTime:setString(string.format("(%d秒)", CountDownData.time))
                end
                if self.countDownTime <= 0 then
                    -- self:stopCountDown()
                    self:CommonClose()
                end
            end
    end, 1)
end

function ExchangeSeatTips:stopCountDown()
    if self.clockHandle then
        scheduler.unscheduleGlobal(self.clockHandle)
        self.clockHandle = nil
    end
end

function ExchangeSeatTips:tipsWords()
    local panContent = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_content")
    local imgExchange = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_exchange")
    self.txtTime:setVisible(false)

    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(cc.size(495, 71))
    richText:setPosition(cc.p(300, 235))
    local topStr = ""
    self.neeCancel = false
    if self.tipsType == TIPS_TYPE.APPLY then --我主动发起申请
        self.btnKnow:setVisible(false)
        self.btnRefuse:setVisible(true)
        self.btnExchange:setVisible(false)

        local imgPath = ""
        if IsPortrait then
            imgPath = "real_res/1004858.png"
        else
            imgPath = "real_res/1004859.png"
        end
        self.btnRefuse:getChildByName("img_txt"):loadTexture(imgPath)
        local originMargin_start = self.btnKnow:getLayoutParameter():getMargin()
        self.btnRefuse:getLayoutParameter():setMargin(originMargin_start)

        imgExchange:loadTexture("real_res/1004851.png")
        self.txtTime:setString(string.format("(%d秒)", self.countDownTime))
        self.txtTime:setVisible(true)
        self:startCountDown()
        self.neeCancel = true

        local name = kFriendRoomInfo:getRoomPlayerListInfo(self.m_data.beAUI).niN
        topStr = string.format("正在与%s申请交换中...", name)
        local re1 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "正在与", "res_TTF/1016001.TTF", 37)
        local re2 = ccui.RichElementText:create(1, cc.c3b(130, 65,   5), 255, name, "res_TTF/1016001.TTF", 37)
        local re3 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "申请交换中...", "res_TTF/1016001.TTF", 37)
        richText:pushBackElement(re1)
        richText:pushBackElement(re2)
        richText:pushBackElement(re3)
    elseif self.tipsType == TIPS_TYPE.REFUSE then--玩家拒绝你
        self.btnKnow:setVisible(true)
        self.btnRefuse:setVisible(false)
        self.btnExchange:setVisible(false)
        imgExchange:loadTexture("real_res/1004850.png")

        if self.m_data.beAUI ~= kUserInfo:getUserId() then
            local name = kFriendRoomInfo:getRoomPlayerListInfo(self.m_data.beAUI).niN
            topStr = string.format("%s拒绝了您交换座位请求", name)
            local re1 = ccui.RichElementText:create(1, cc.c3b(130, 65,   5), 255, name, "res_TTF/1016001.TTF", 37)
            local re2 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "拒绝了您交换座位请求", "res_TTF/1016001.TTF", 37)
            richText:pushBackElement(re1)
            richText:pushBackElement(re2)
        else
            local name = kFriendRoomInfo:getRoomPlayerListInfo(self.m_data.asUI).niN
            topStr = string.format("您拒绝了与玩家%s交换座位请求", name)
            local re1 = ccui.RichElementText:create(1, cc.c3b(0, 0,   0), 255, "您拒绝了与玩家", "res_TTF/1016001.TTF", 37)
            local re2 = ccui.RichElementText:create(1, cc.c3b(130, 65,   5), 255, name, "res_TTF/1016001.TTF", 37)
            local re3 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "交换座位请求", "res_TTF/1016001.TTF", 37)
            richText:pushBackElement(re1)
            richText:pushBackElement(re2)
            richText:pushBackElement(re3)
        end
    elseif self.tipsType == TIPS_TYPE.SUCCESS then--交换成功
        self.btnKnow:setVisible(true)
        self.btnRefuse:setVisible(false)
        self.btnExchange:setVisible(false)
        imgExchange:loadTexture("real_res/1004852.png")

        local name = ""
        if self.m_data.asUI == kUserInfo:getUserId() then
            name = kFriendRoomInfo:getRoomPlayerListInfo(self.m_data.beAUI).niN
        else
            name = kFriendRoomInfo:getRoomPlayerListInfo(self.m_data.asUI).niN
        end
        topStr = string.format("您与玩家%s交换座位成功", name)
        local re1 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "您与玩家", "res_TTF/1016001.TTF", 37)
        local re2 = ccui.RichElementText:create(1, cc.c3b(130, 65,   5), 255, name, "res_TTF/1016001.TTF", 37)
        local re3 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "交换座位成功", "res_TTF/1016001.TTF", 37)
        richText:pushBackElement(re1)
        richText:pushBackElement(re2)
        richText:pushBackElement(re3)
    elseif self.tipsType == TIPS_TYPE.OTHER_APPLY then--别的玩家请求与你交换
        self.btnKnow:setVisible(false)
        self.btnRefuse:setVisible(true)
        self.btnExchange:setVisible(true)

        imgExchange:loadTexture("real_res/1004851.png")
        self.txtTime:setString(string.format("(%d秒)", self.countDownTime))
        self.txtTime:setVisible(true)
        self:startCountDown()
        self.neeCancel = true
        
        local name = kFriendRoomInfo:getRoomPlayerListInfo(self.m_data.asUI).niN
        topStr = string.format("玩家%s想要与您交换座位", name)
        local re1 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "玩家", "res_TTF/1016001.TTF", 37)
        local re2 = ccui.RichElementText:create(1, cc.c3b(130, 65,   5), 255, name, "res_TTF/1016001.TTF", 37)
        local re3 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "想要与您交换座位", "res_TTF/1016001.TTF", 37)
        richText:pushBackElement(re1)
        richText:pushBackElement(re2)
        richText:pushBackElement(re3)
    elseif self.tipsType == TIPS_TYPE.OTHER_EXCHANGE then--其他玩家交换
        self.btnKnow:setVisible(true)
        self.btnRefuse:setVisible(false)
        self.btnExchange:setVisible(false)

        self.txtTime:setVisible(false)

        local name = kFriendRoomInfo:getRoomPlayerListInfo(self.m_data.asUI).niN
        local beName = kFriendRoomInfo:getRoomPlayerListInfo(self.m_data.beAUI).niN
        if self.m_data.ty == 1 then--1发起交换请求
            topStr = string.format("玩家%s正在与玩家%s交换座位", name, beName)
            local re1 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "玩家", "res_TTF/1016001.TTF", 37)
            local re2 = ccui.RichElementText:create(1, cc.c3b(130, 65,   5), 255, name, "res_TTF/1016001.TTF", 37)
            local re3 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "正在与玩家", "res_TTF/1016001.TTF", 37)
            local re4 = ccui.RichElementText:create(1, cc.c3b(130, 65,   5), 255, beName, "res_TTF/1016001.TTF", 37)
            local re5 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "交换座位", "res_TTF/1016001.TTF", 37)
            richText:pushBackElement(re1)
            richText:pushBackElement(re2)
            richText:pushBackElement(re3)
            richText:pushBackElement(re4)
            richText:pushBackElement(re5)
        else
            if self.m_data.chST then--同意
                topStr = string.format("玩家%s与玩家%s交换座位成功", name, beName)
                imgExchange:loadTexture("real_res/1004851.png")
                local re1 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "玩家", "res_TTF/1016001.TTF", 37)
                local re2 = ccui.RichElementText:create(1, cc.c3b(130, 65,   5), 255, name, "res_TTF/1016001.TTF", 37)
                local re3 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "与玩家", "res_TTF/1016001.TTF", 37)
                local re4 = ccui.RichElementText:create(1, cc.c3b(130, 65,   5), 255, beName, "res_TTF/1016001.TTF", 37)
                local re5 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "交换座位成功", "res_TTF/1016001.TTF", 37)
                richText:pushBackElement(re1)
                richText:pushBackElement(re2)
                richText:pushBackElement(re3)
                richText:pushBackElement(re4)
                richText:pushBackElement(re5)
            else
                topStr = string.format("玩家%s拒绝与玩家%s交换座位", name, beName)
                imgExchange:loadTexture("real_res/1004850.png")
                local re1 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "玩家", "res_TTF/1016001.TTF", 37)
                local re2 = ccui.RichElementText:create(1, cc.c3b(130, 65,   5), 255, beName, "res_TTF/1016001.TTF", 37)
                local re3 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "拒绝与玩家", "res_TTF/1016001.TTF", 37)
                local re4 = ccui.RichElementText:create(1, cc.c3b(130, 65,   5), 255, name, "res_TTF/1016001.TTF", 37)
                local re5 = ccui.RichElementText:create(1, cc.c3b(0, 0, 0), 255, "交换座位", "res_TTF/1016001.TTF", 37)
                richText:pushBackElement(re1)
                richText:pushBackElement(re2)
                richText:pushBackElement(re3)
                richText:pushBackElement(re4)
                richText:pushBackElement(re5)
            end
        end
    end

    if IsPortrait then
        panContent:addChild(richText)
    else
        local label = cc.Label:createWithTTF("", "package_res/games/guandan/hall/font/fangzhengcuyuan.ttf", 28)
        label:setPosition(cc.p(297, 310))
        label:setString(topStr)
        panContent:addChild(label)
    end
end

function ExchangeSeatTips:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn")
        -- self.m_data.canKeyBack = true
        -- if self.m_data.canKeyBack == nil or  self.m_data.canKeyBack == true then
        --     self:stopCountDown()
        --     UIManager.getInstance():popWnd(self)
        -- end
        -- if self.m_data.keyBackCallback then
        --     self.m_data.keyBackCallback()
        -- end
        if pWidget == self.btnExchange then
             local data = {
                asUI = self.m_data.asUI,
                beAUI = self.m_data.beAUI,
                ty = 2,
                chST = true,
            }
            FriendRoomSocketProcesser.sendPrivateRoomSeats(data)
        elseif pWidget == self.btnRefuse then--拒绝、取消申请
            if self.tipsType == TIPS_TYPE.APPLY then --取消申请
                local data = {
                    asUI = self.m_data.asUI,
                    beAUI = self.m_data.beAUI,
                    ty = 1,
                    chST = false,
                }
                FriendRoomSocketProcesser.sendPrivateRoomSeats(data)
            else--拒绝
                local data = {
                    asUI = self.m_data.asUI,
                    beAUI = self.m_data.beAUI,
                    ty = 2,
                    chST = false,
                }
                FriendRoomSocketProcesser.sendPrivateRoomSeats(data)
            end
        end
    end
end

--返回
function ExchangeSeatTips:keyBack()
    self:CommonClose()
end