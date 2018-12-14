-----------------------------------------------------------
--  @file   myclub.lua
--  @brief  亲友圈
--  @author linxiancheng
--  @DateTime:2017-07-26 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local ShareToWX = require "app.hall.common.ShareToWX"
local MyClub = class("MyClub", UIWndBase)

local ClubHeadList = require("app.hall.wnds.club.ClubHeadList")
local clubSocketProcesser = require("app.hall.wnds.club.clubSocketProcesser")
local LocalEvent = require "app.hall.common.LocalEvent"
local BackEndStatistics = require("app.common.BackEndStatistics")
local UmengClickEvent = require("app.common.UmengClickEvent")
local choiceShare = require("app.hall.common.share.choiceShare")

function MyClub:ctor(clubInfo)
    self.super.ctor(self,"hall/myclub.csb", clubInfo)
    self.m_SocketProcesser = clubSocketProcesser.new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_SocketProcesser)
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    LoadingView.getInstance():hide();
    self:registerLocalEventListener()
end

function MyClub:registerLocalEventListener()
    self.LocalEvent = {}
    local RemoveHeadList = cc.EventListenerCustom:create(LocalEvent.RemoveHeadList, function()
            self.headList = nil
        end)
    table.insert(self.LocalEvent, RemoveHeadList)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(RemoveHeadList, 1)
end

function MyClub:onClose()
    if self.m_SocketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_SocketProcesser)
        self.m_SocketProcesser = nil
    end

    table.walk(self.LocalEvent, function(pListener)
        cc.Director:getInstance():getEventDispatcher():removeEventListener(pListener)
    end)
    self.LocalEvent = {}
end

local Tab_ShareType = {}
Tab_ShareType.ShareToWechatCircle = 1
Tab_ShareType.ShareToWechatFriend = 2
Tab_ShareType.ShareToWechatQRCode = 3

local function shareClub(self, shareType)
    local data = {}
    --[[local serverClubShareInfo = kServerInfo:getClubShareInfo()
    data.title = serverClubShareInfo.shareTitle or self.data.shT or "亲友圈分享"
    data.desc = serverClubShareInfo.shareDesc or self.data.shD or "您的好友邀请您加入他的亲友圈"
    data.url = serverClubShareInfo.shareLink or self.data.clURL or "weixin://"]] --亲友圈分享暂时依然按旧方式
    data.title = self.data.shT or "亲友圈分享"
    data.desc = self.data.shD or "您的好友邀请您加入他的亲友圈"
    data.url = self.data.clURL or "weixin://"

    falg = nil
    local falg = string.find(data.url,"?")
    if falg then
        data.url = data.url..""
    else
        data.url = data.url.."?"
    end
    data.url = data.url..ShareToWX.ClubShareFriendQun
    data.headUrl = self.data.shI or kFriendRoomInfo:getRoomBaseInfo().dwShareTitle; --kUserInfo:getHeadImgSmall()
    data.type = shareType
    data.cmd = NativeCall.CMD_WECHAT_SHARE
    local shareCallBack = function(shareInfo)
        if shareInfo.errCode == 0 then
            Toast.getInstance():show("分享成功")
        elseif shareInfo.errCode == -8 then
            Toast.getInstance():show("您的手机未安装微信")
        else
            Toast.getInstance():show("分享失败请联系客服")
        end
    end

    if shareType==Tab_ShareType.ShareToWechatFriend then
        local shareToWechat = function()
                LoadingView.getInstance():show("正在分享,请稍后...", 2)
                Log.i("================ShareToWechatFriend " , data)
                WeChatShared.getWechatShareInfo(WeChatShared.ShareType.FRIENDS, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.CLUB_FRIEND, shareCallBack, ShareToWX.ClubShareFriendQun, data)
                end
        local data = {}
        data.shareToWechat = shareToWechat
        data.type = "club"
        UIManager.getInstance():pushWnd(choiceShare, data)
    elseif shareType==Tab_ShareType.ShareToWechatCircle then
        LoadingView.getInstance():show("正在分享,请稍后...", 2)
        WeChatShared.getWechatShareInfo(WeChatShared.ShareType.TIMELINE, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.CLUB, shareCallBack, ShareToWX.ClubShareFriendQuan, data)
    end
end

local function getClubQRCodeImagePath(self)
    local CodeImageName = string.format("club_%s.png",tostring(self.m_data.clubID))
    local fullPath = cc.FileUtils:getInstance():fullPathForFilename(CodeImageName)
    if io.exists(fullPath) then
        return fullPath
    else
        return cc.FileUtils:getInstance():fullPathForFilename("defaultClub.png")
    end
end

local function compoundShareQRCodeImage(self, savePath)
    local bgpath = _ClubShareBg
    if not cc.FileUtils:getInstance():isFileExist(bgpath) then
        bgpath = "package_res/config/image/club_bg.png"
    end
    local QRbgImage = display.newSprite(bgpath)
    QRbgImage:setAnchorPoint(cc.p(0,0))
    local QRCodeImage = display.newSprite(getClubQRCodeImagePath(self))
    QRCodeImage:pos(979,89)
    QRCodeImage:setAnchorPoint(cc.p(0,0))
    QRbgImage:addChild(QRCodeImage)

    local render_texture = cc.RenderTexture:create(
        QRbgImage:getContentSize().width, QRbgImage:getContentSize().height)
    render_texture:begin()
    QRbgImage:visit()
    render_texture:endToLua()

    render_texture:retain()
    scheduler.performWithDelayGlobal(function()
        render_texture:newImage(true):saveToFile(savePath, true)
        render_texture:release()
    end,0.01)
end

local function shareClubQRImage(self, savePath)
    local data = {}
    data.path = savePath
    data.imgPath = data.path
    data.type = 1
    data.friendOrCircle = 1
    data.linkOrPhoto = 1
    data.url = ""
    data.title = "亲友圈邀请"
    data.desc = "长按图片识别二维码"
    data.cmd = NativeCall.CMD_WECHAT_SHARE
    local finishRet = function(retInfo)
        if retInfo.errCode == 0 then --成功
            Toast.getInstance():show("分享成功");
        elseif (retInfo.errCode == -8) then
            Toast.getInstance():show("您手机未安装微信");
        else
            Toast.getInstance():show("分享失败");
        end
        retInfo.resType = WeChatShared.UseShareType.DYNAMICAPPIDPIC
        retInfo.sharedResCB = function() end -- 不需要额外的回调
        retInfo.sharePath = ShareToWX.ClubQRShareFriend
        WeChatShared.nativeSharedFinishRet(retInfo)
    end
    NativeCall.getInstance():callNative(data, finishRet)
end

local function createQRImage(drawNode, clubID)
    local render_texture = cc.RenderTexture:create(drawNode:getContentSize().width,drawNode:getContentSize().height)
    render_texture:begin()
    drawNode:visit()
    render_texture:endToLua() --CACHEDIR ==  D:\git_Project\cache/

    local savePath = CACHEDIR.."club_"..tostring(clubID)..".png"
    if drawNode.data == "" then
        savePath = CACHEDIR.."defaultClub.png"
    end
    render_texture:retain()
    scheduler.performWithDelayGlobal(function()
        render_texture:newImage(true):saveToFile(savePath, false)
        render_texture:release()
    end, 0.01)
end

local function createQRCodeByURL(data, clubID)
    cc.UserDefault:getInstance():setStringForKey("clubURL", data);
    local qrencode = require("app.luaqrcode.qrencode.lua")
    local ok, QRCode = qrencode.qrcode(data)
    if not ok then
        Log.i("[ERROR]-----MyClub:createQRCodeByURL",QRCode)
        return
    end
    local drawNode = cc.DrawNode:create()
    local gridWidth = (data ~= "") and 11 or 17;
    local offsetX = 0;
    local offsetY = 0;
    for i,row in pairs(QRCode) do
        for j,v in pairs(row) do
            if(v > 0) then
                drawNode:drawSolidRect(cc.p(i * gridWidth + offsetX, j * gridWidth + offsetY),
                    cc.p(i * gridWidth + gridWidth + offsetX, j * gridWidth + gridWidth + offsetY),
                    cc.c4f(0,0,0,1))
            else
                drawNode:drawSolidRect(cc.p(i * gridWidth + offsetX, j * gridWidth + offsetY),
                    cc.p(i * gridWidth + gridWidth + offsetX, j * gridWidth + gridWidth + offsetY),
                    cc.c4f(1,1,1,1))
            end
        end
    end
    drawNode:setContentSize(cc.size((#QRCode[1] + 2)* gridWidth,(#QRCode + 2)* gridWidth))
    drawNode.data = data
    createQRImage(drawNode, clubID)
end

local function initQRImageByRUL(self)
    local QRImage = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_club")
    -- self.data.clURL = "www.baidu.com"
    if self.data.clURL == "" or not self.data.clURL then
        local fullPath = cc.FileUtils:getInstance():fullPathForFilename("defaultClub.png")
        if io.exists(fullPath) then
            QRImage:loadTexture(fullPath)
        else
            createQRCodeByURL("", self.m_data.clubID)
            self.m_pWidget:performWithDelay(function()
                fullPath = cc.FileUtils:getInstance():fullPathForFilename("defaultClub.png")
                QRImage:loadTexture(fullPath)
            end, 0.1);
        end
    else
        local CodeImagePath = string.format("club_%s.png",tostring(self.m_data.clubID))
        local fullPath = cc.FileUtils:getInstance():fullPathForFilename(CodeImagePath)
        -- 以url作为是否生成新的二维码的标记，而不以亲友圈id作为是否生成新的二维码的标记
        if io.exists(fullPath) then
            local clubURL = cc.UserDefault:getInstance():getStringForKey("clubURL","");
            if self.data.clURL == clubURL then
                QRImage:loadTexture(fullPath)
            else
                createQRCodeByURL(self.data.clURL, self.m_data.clubID)
                self.m_pWidget:performWithDelay(function()
                    fullPath = cc.FileUtils:getInstance():fullPathForFilename(CodeImagePath)
                    QRImage:loadTexture(fullPath)
                end,0.1)
            end
        else
            createQRCodeByURL(self.data.clURL, self.m_data.clubID)
            self.m_pWidget:performWithDelay(function()
                fullPath = cc.FileUtils:getInstance():fullPathForFilename(CodeImagePath)
                QRImage:loadTexture(fullPath)
            end,0.1)
        end
    end
end

local function weChatShareQRCode(self)
    local savePath1 = CACHEDIR..string.format("club_%d.png",tonumber(self.m_data.clubID))
    if not io.exists(savePath1) then
        initQRImageByRUL(self)

        local savePath = CACHEDIR..string.format("club_share_%d.jpg",tonumber(self.m_data.clubID))
        LoadingView.getInstance():show("正在生成二维码请稍后...")
        scheduler.performWithDelayGlobal( function()
            compoundShareQRCodeImage(self,savePath)
            scheduler.performWithDelayGlobal(function()  -- 首次分享预留时间生成二维码图片
                LoadingView.getInstance():hide()
                shareClubQRImage(self,savePath)
            end,0.5)
        end,0.5)
    end

    local savePath = CACHEDIR..string.format("club_share_%d.jpg",tonumber(self.m_data.clubID))
    if not io.exists(savePath) then
        LoadingView.getInstance():show("正在生成二维码请稍后...")
        compoundShareQRCodeImage(self,savePath)
        scheduler.performWithDelayGlobal(function()  -- 首次分享预留时间生成二维码图片
            LoadingView.getInstance():hide()
            shareClubQRImage(self,savePath)
        end,0.5)
    else
        shareClubQRImage(self,savePath)
    end
end

local function btnCallBack(self, widget, touchType)
    if touchType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if  widget:getName() ==  "btn_friend" then
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.QYQShareFriendsButton)
            Util.disableNodeTouchWithinTime(widget)
            shareClub(self, Tab_ShareType.ShareToWechatFriend)
            local data = {}
            data.wa = BackEndStatistics.QinyouGroup
            SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
        elseif widget:getName() ==  "btn_circle" then
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.QYQShareFriendCircleButton)
            Util.disableNodeTouchWithinTime(widget)
            shareClub(self, Tab_ShareType.ShareToWechatCircle)
            local data = {}
            data.wa = BackEndStatistics.QinyouMoments
            SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
        elseif widget:getName() ==  "btn_erwei" then
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.QYQShareQRCodeButton)
            weChatShareQRCode(self)
            local data = {}
            data.wa = BackEndStatistics.QinyouQRCode
            SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
        elseif widget:getName() == "btn_clublist" then   -- 亲友圈亲友列表
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.QYQClubList)
            local data = {}
            data.pa = 0         -- 页码
            data.roN = 32       -- 每页显示人数
            SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_QUERYCLUBHEAD,data)
        elseif widget:getName() == "btn_clubRoom" then   -- 亲友圈界面
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.QYQClubRoom)
            local data = kSystemConfig:getOwnerClubInfo();
            if kSystemConfig:IsClubOwner() and data ~= nil then
                local ClubRoomListWnd = require("app.hall.wnds.club.clubRoomListWnd")
                UIManager.getInstance():pushWnd(ClubRoomListWnd, data, true)
            else
                Toast.getInstance():show("亲友圈信息已过期，请重新打开本界面")
            end
        elseif widget:getName() == "btn_createRoom" then   -- 创建房间界面
            if kServerInfo:getCantEnterRoom() then -- 即将维护, 禁止开局
                Toast.getInstance():show("服务器即将进行维护! ")
                return
            end
            local data = {};
            data.clubInfo = kSystemConfig:getOwnerClubInfo();
            if kSystemConfig:IsClubOwner() and data.clubInfo ~= nil then
                UIManager:getInstance():pushWnd(FriendRoomCreate, data);
            else
                Toast.getInstance():show("亲友圈信息已过期，请重新打开本界面")
            end
        end
    end
end



local function initAgencyPanel(self)
    local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close")
    btn_close:addTouchEventListener(function(widget, touchType)
        if touchType ==  ccui.TouchEventType.ended then
            SoundManager.playEffect("btn");
            self:keyBack()
         end
    end)

    local btn_friend = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_friend")
    btn_friend:addTouchEventListener(handler(self,btnCallBack))

    local btn_circle = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_circle")
    btn_circle:addTouchEventListener(handler(self,btnCallBack))

    local btn_list = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_clublist")
    btn_list:addTouchEventListener(handler(self, btnCallBack))

    local btn_list = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_clubRoom")
    btn_list:addTouchEventListener(handler(self, btnCallBack))

    local btn_list = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_createRoom")
    btn_list:addTouchEventListener(handler(self, btnCallBack))

    local btn_erwei = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_erwei")
    btn_erwei:addTouchEventListener(handler(self, btnCallBack))

    local clubTips = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_clubtips")
    clubTips:setString("数据接收中,请稍候...")  -- 服务器数据返回后刷新显示

    self:onClubInfoReceive(self.m_data)
end

function MyClub:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end

    local lab_clubName = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_clubName")
    local clubName = ToolKit.subUtfStrByCn(string.format("%s",self.m_data.clN), 0, 12, "...")
    Util.updateNickName(lab_clubName, clubName, 30)
    if lab_clubName:getString() == "" then
        lab_clubName:setString("我的亲友圈")
    end

    local clubOwner = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_founder")
    local ownerName = ToolKit.subUtfStrByCn(string.format("%s",self.m_data.clubOwnerName), 0, 9, "...")
    if IsPortrait then -- TODO
        ownerName = ToolKit.subUtfStrByCn(string.format("%s",self.m_data.clubOwnerName), 0, 6, "...")
    end
    Util.updateNickName(clubOwner, string.format("创始人:%s",ownerName))

    local clubID = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_id")
    clubID:setString(string.format("亲友圈ID:%s",self.m_data.clubID))

    local lab_num = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_num")
    lab_num:setString("亲友圈人数:0")

    local lab_diamondNum = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_diamondNum")
    lab_diamondNum:setString("亲友圈剩余钻石:0")

    initAgencyPanel(self)
end
-- 服务器端时间 - 客户端时间 = 时间差
local function countOverTime(data)
    local clientTime = data.crT + data.chT*60 - kSystemConfig:getTimeOffset()
    local remainingTime = os.difftime(clientTime,os.time()) / (60*60)
    remainingTime = remainingTime > 0 and remainingTime or 0
    -- print(os.date("currtime---------------------%Y-%m-%d-/%H:%M:%S",os.time()))
    -- print(os.date("crT--------------------------%Y-%m-%d-/%H:%M:%S",data.crT))
    -- print(os.date("chT--------------------------%Y-%m-%d-/%H:%M:%S",data.crT + data.chT*60))
    -- print(os.date("clientTime-------------------%Y-%m-%d-/%H:%M:%S",clientTime))
    return remainingTime
end
-- ##  clS  int  亲友圈状态（0 新注册的 1 正常 2 审核通过后的冻结  3 审核未通过而冻结）
-- 服务器数据返回更新界面
local function initClubTips(self)
    local clubTips = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_clubtips")
    if self.data.clS == 0 then  -- 根据是否转正来显示提示信息
        local content = "注：亲友圈距离转正考核还剩%d小时，届时若亲友圈未满%d人将被解散。"
        clubTips:setString(string.format(content,countOverTime(self.data),self.data.chMN or 0))  -- 人数改为后台数据控制
    elseif self.data.clS == 2 then
        -- clubTips:setString("您的亲友圈已被冻结")  -- 产品提出不用处理
        clubTips:setString("注：赠予钻石和充值请进入公众号亲友圈后台")
    elseif self.data.clS == 3 then
        clubTips:setString("注：数据异常请联系客服处理:异常码 3 ")
    elseif self.data.clS == 1 then
        clubTips:setString("注：赠予钻石和充值请进入公众号亲友圈后台")
    end

    local lab_num = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_num")
    lab_num:setString(string.format("亲友圈人数:%s", self.data.meN and tostring(self.data.meN) or ""))

    local lab_diamondNum = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_diamondNum")
    lab_diamondNum:setString(string.format("亲友圈剩余钻石:%s", self.data.diaNum and tostring(self.data.diaNum) or ""))
end
-- 使用更换纹理的方式显示二维码
local function initClubQRImage(self)
    local QRImage = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_club")
    if self.data.clQRURL and string.len(self.data.clQRURL) then
        local fileName = string.format("club_%d.jpg",self.m_data.clubID or "")
        local QRPath = cc.FileUtils:getInstance():fullPathForFilename(fileName)
        if io.exists(QRPath) then
            QRImage:loadTexture(QRPath)
        else
            HttpManager.getNetworkImage(self.data.clQRURL, fileName)
        end
    end
end

function MyClub:onResponseNetImg(fileName)
    if fileName == string.format("club_%d.jpg",self.m_data.clubID or "") then
        local QRPath = cc.FileUtils:getInstance():fullPathForFilename(fileName)
        if io.exists(QRPath) then
            local QRImage = ccui.Helper:seekWidgetByName(self.m_pWdiget,"img_club")
            QRImage:loadTexture(QRPath)
        else
            print(debug.traceback("[ ERROR ]----->LinXiancheng"))
        end
    end
end

-- testFunction
-- ##    usI  int  玩家id（0表示未注册）
-- ##    na  String  玩家名称
-- ##    he  String  头像
-- ##    st  int     是否为正式亲友 0 非正式   1 正式亲友
local function testFunction(data,num,begin)
    begin = begin or 0
    num = num or 20*4
    for i=1,num do
        local pData = {}
        pData.usI = 1
        pData.na = "是否为正式亲友"
        pData.st = 0
        pData.usI = i + begin
        table.insert(data,pData)
    end
end

-- 亲友圈头像信息返回
function MyClub:onReceiveHeadList(info)
    LoadingView.getInstance():hide();
    if self.headList then
        -- testFunction(info.meL)
        self.headList:serverDataDispose(info.meL)
    else
        -- testFunction(info.meL,4,100)
        self.headList = UIManager.getInstance():pushWnd(ClubHeadList, info.meL);
    end
end
-- ##  clI  long  亲友圈id
-- ##  clN  String  亲友圈名称
-- ##  clC  String  亲友圈创始人
-- ##  crT  int  亲友圈创建时间   crT + chT = 截止时间
-- ##  chT  int  亲友圈创建后预审核阶段的时间（分钟）
-- ##  clS  int  亲友圈状态（0预审核，1正式，2未通过）
-- ##  meN  int  亲友圈人数
-- ##  clURL  String  亲友圈公众号url
-- ##  clQRURL  String  亲友圈二维码url
function MyClub:onClubInfoReceive(info)
    self.data = info
    initClubTips(self)
    initQRImageByRUL(self)
end

MyClub.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_QUERYCLUBHEAD] = MyClub.onReceiveHeadList,
    [HallSocketCmd.CODE_REC_QUERYCLUBINFO] = MyClub.onClubInfoReceive,
}

return MyClub
