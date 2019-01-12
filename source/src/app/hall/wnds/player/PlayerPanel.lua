-----------------------------------------------------------
--  @file   PlayerPanel.lua
--  @brief  玩家信息面板
--  @author linxiancheng
--  @DateTime:2017-04-13 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local CircleClippingNode = require("app.games.common.custom.CircleClippingNode")

local PlayerPanel = class("PlayerPanel", UIWndBase)
local LocalEvent = require("app.hall.common.LocalEvent")
local PlayerSocketProcesser = require("app.hall.wnds.player.PlayerSocketProcesser")
local Duty = require "app.hall.wnds.duty.Duty"
local RealName = require "app.hall.wnds.realName.RealName"
local CommonTips = require "app.hall.common.CommonTips"
local Club = require("app.hall.wnds.club.club")
local MyClub = require("app.hall.wnds.club.myclub")
local ClubJoinedWnd = require("app.hall.wnds.club.clubJoinedWnd")
local ComFun = require("app.hall.wnds.account.AccountComFun")
local BindPhone = require "app.hall.wnds.account.halloption.BindPhone"
local UmengClickEvent = require("app.common.UmengClickEvent")
local AccountStatus = require "app.hall.wnds.account.AccountStatus"

function PlayerPanel:ctor()
    self.super.ctor(self,"hall/Playerpanel.csb",kLoginInfo:getPlayerInfo())
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    self.m_SocketProcesser = PlayerSocketProcesser.new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_SocketProcesser) 
    self.LocalEvents = {}
end

function PlayerPanel:onClose()
    if self.m_SocketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_SocketProcesser)
        self.m_SocketProcesser = nil
    end

    table.walk(self.LocalEvents,function(pListener)
        cc.Director:getInstance():getEventDispatcher():removeEventListener(pListener)
    end)
    self.LocalEvents = {}
end

function PlayerPanel:keyBack()
    UIManager:getInstance():popWnd(PlayerPanel)
end

local function updateClubInfo(self)
    -- local lab_clubtips = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_clubtips")
    -- if kSystemConfig:isClubNewer() then
    --     lab_clubtips:setString("加入亲友圈")
    -- else
    --     lab_clubtips:setString("我的亲友圈")
    -- end

    if IsPortrait then -- TODO
        local julebu_name = ccui.Helper:seekWidgetByName(self.m_pWidget,"julebu_name")
        local julebu_name_lab = ccui.Helper:seekWidgetByName(self.m_pWidget,"julebu_name_lab")
        local julebu_id = ccui.Helper:seekWidgetByName(self.m_pWidget,"julebu_id")
        local julebu_id_lab = ccui.Helper:seekWidgetByName(self.m_pWidget,"julebu_id_lab")
        if kSystemConfig:IsClubOwner() then
            julebu_name_lab:setString("您的亲友圈:")
            julebu_id_lab:setString("亲友圈ID:")
            local clubName = ToolKit.subUtfStrByCn(string.format("%s",kSystemConfig:getClubName() or ""), 0, 9, "...")
            Util.updateNickName(julebu_name, string.format("%s",clubName), 22)
            if kSystemConfig:getClubID() == 0 then
                julebu_id:setString("暂无")
            else
                julebu_id:setString(string.format("%d",kSystemConfig:getClubID()))
            end
        else
            if kSystemConfig:getClubJoinedNum() > 0 then
                julebu_name_lab:setString("当前已加入亲友圈数量:")
                julebu_id_lab:setString("最多允许加入亲友圈数量:")
                julebu_name:setString(tostring(kSystemConfig:getClubJoinedNum()))
                julebu_id:setString(tostring(kSystemConfig:getClubJoinLimitCount()))
            else
                julebu_name_lab:setString("所在亲友圈:")
                julebu_id_lab:setString("亲友圈ID:")
                julebu_name:setString("您尚未加入亲友圈")
                julebu_id:setString("暂无")
            end
        end    

        self.panel_clubInfo:forceDoLayout()
    else
        local julebu_name_lab = ccui.Helper:seekWidgetByName(self.m_pWidget,"julebu_name_lab")
        local julebu_id_lab = ccui.Helper:seekWidgetByName(self.m_pWidget,"julebu_id_lab")

        local pan_owner = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_owner")
        local pan_frinum = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_frinum")
        local pan_joinnum = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_joinnum")
        if kSystemConfig:IsClubOwner() then
            pan_owner:setVisible(true)
            local qinyou_name1 = ccui.Helper:seekWidgetByName(self.m_pWidget,"qinyou_name1")
            local qinyou_id1 = ccui.Helper:seekWidgetByName(self.m_pWidget,"qinyou_id1")
            local clubName = ToolKit.subUtfStrByCn(string.format("%s",kSystemConfig:getClubName() or ""), 0, 9, "...")
            Util.updateNickName(qinyou_name1, string.format("%s",clubName), 22)
            if kSystemConfig:getClubID() == 0 then
                qinyou_id1:setString("暂无")
            else
                qinyou_id1:setString(string.format("%d",kSystemConfig:getClubID()))
            end
        else
            if kSystemConfig:getClubJoinedNum() > 0 then
                pan_joinnum:setVisible(true)
                local julebu_name = ccui.Helper:seekWidgetByName(self.m_pWidget,"julebu_name")
                local julebu_id = ccui.Helper:seekWidgetByName(self.m_pWidget,"julebu_id")
                julebu_name:setString(tostring(kSystemConfig:getClubJoinedNum()))
                julebu_id:setString(tostring(kSystemConfig:getClubJoinLimitCount()))
            else
                pan_frinum:setVisible(true)
            end
        end    
    end
end

local function initLocalEvent(self)
    local updateClub = cc.EventListenerCustom:create(LocalEvent.UpdateClubState, handler(self,updateClubInfo))
    table.insert(self.LocalEvents,updateClub)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(updateClub, 1)
end

function PlayerPanel:onInit()
    if IsPortrait then -- TODO
        local UITool = require("app.common.UITool")
        local title = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_title")
        UITool.setTitleStyle(title)
    else
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));

    self.nickName = ccui.Helper:seekWidgetByName(self.m_pWidget, "nickName");

    -- self.nickName:setString(ToolKit.subUtfStrByCn(kUserInfo:getUserName(), 0, 14, "..."));
    Util.updateNickName(self.nickName, ToolKit.subUtfStrByCn(kUserInfo:getUserName(), 0, 8, "..."))

    self.label_id = ccui.Helper:seekWidgetByName(self.m_pWidget, "label_id");
    self.label_id:setString("ID:".. kUserInfo:getUserId());

    self.btn_agency = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_agency");
    self.btn_agency:addTouchEventListener(handler(self,self.onClickButton));    
    if IsPortrait then -- TODO
        self.nickName:setPositionY(self.nickName:getPositionY()+20)
        self.label_id:setPositionY(self.label_id:getPositionY()+20)
        self.pan_user = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_user")
    end

    self.btn_mianze = ccui.Helper:seekWidgetByName(self.m_pWidget, "mianze")
    self.btn_mianze:addTouchEventListener(handler(self,self.onClickButton))

    self.btn_shiming = ccui.Helper:seekWidgetByName(self.m_pWidget, "shiming")
    self.btn_shiming:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_bindphone = ccui.Helper:seekWidgetByName(self.m_pWidget, "bindphone")
    self.btn_bindphone:addTouchEventListener(handler(self, self.onClickButton))

    self.img_head = ccui.Helper:seekWidgetByName(self.m_pWidget,"head_image");
    self:headInit();

    self:initPhoneBindStatus()

    self.lab_active = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_active");
    self.lab_active:setString(string.format("%d 天",self.m_data.acA) );

    self.lab_continuous = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_continuous");
    self.lab_continuous:setString(string.format("%d 天",self.m_data.coDA));

    self.lab_owner = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_owner");
    self.lab_owner:setString(string.format("%d 次", self.m_data.roA));

    self.lab_total = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_total");
    self.lab_total:setString(string.format("%d 局",self.m_data.plA));    

    self.lab_closeClubTip = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_closeClubTip");
    self.panel_clubInfo = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_clubInfo");
    self.panel_closeClubTip = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_closeClubTip");
    self.lab_closeClubTip:setString("亲友圈暂未开放")

    if Util.debug_shield_value("club") then
        self.btn_agency:setVisible(false)
        self.panel_clubInfo:setVisible(false)
        self.panel_closeClubTip:setVisible(true)
    else
        self.btn_agency:setVisible(true)
        self.panel_clubInfo:setVisible(true)
        self.panel_closeClubTip:setVisible(false)
    end
    updateClubInfo(self)

    initLocalEvent(self)

    local copyBtnLayout = ccui.Layout:create()
    copyBtnLayout:setContentSize(cc.size(120,50))
    self.label_id:addChild(copyBtnLayout)

    copyBtnLayout:setPosition(cc.p(self.label_id:getContentSize().width+10,-7))
    if IsPortrait then -- TODO
        copyBtnLayout:setPosition(cc.p(self.label_id:getContentSize().width+20,-7))
    end
    local copyUserId = cc.Label:create()

    copyUserId:setString("(复制ID)")
    copyUserId:setSystemFontSize(28)
    copyUserId:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
    copyUserId:setPosition(cc.p(copyBtnLayout:getContentSize().width/2,copyBtnLayout:getContentSize().height/2))
    copyBtnLayout:addChild(copyUserId)

    copyBtnLayout:setTouchEnabled(true)
    copyBtnLayout:setTouchSwallowEnabled(true)
    copyBtnLayout:addTouchEventListener(handler(self,self.onUserClickButton))

    local copyUserIdLine = cc.Label:create()
    copyUserIdLine:setString("  ______  ")
    copyUserIdLine:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
    copyUserIdLine:setSystemFontSize(28)
    copyUserIdLine:setPosition(cc.p(copyBtnLayout:getContentSize().width/2,copyBtnLayout:getContentSize().height/2 - 5))
    copyBtnLayout:addChild(copyUserIdLine)
end

function PlayerPanel:onUserClickButton(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
        local userId = kUserInfo:getUserId()
        local data = {}
        data.cmd = NativeCall.CMD_CLIPBOARD_COPY
        data.content = string.format("%d",userId)
        NativeCall.getInstance():callNative(data);
        Toast.getInstance():show("复制成功"); 
        NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameCopyIdInfo)
    end
end

-- 初始化
function PlayerPanel:initPhoneBindStatus()
    local data = kGiftData_logicInfo:getTaskByID(AccountStatus.PhoneTaskID)
    if not data then Log.e() return end
    self.unbind = ccui.Helper:seekWidgetByName(self.m_pWidget,"unbind");
    self.bindimg = ccui.Helper:seekWidgetByName(self.m_pWidget,"bindimg");
    if IsPortrait then -- TODO
        self.bindimg = ccui.Helper:seekWidgetByName(self.m_pWidget,"binding");
    end
    self.bindnum = ccui.Helper:seekWidgetByName(self.m_pWidget,"bindnum");
    if data.status == AccountStatus.TaskUnDeal then
        self.unbind:setVisible(true)
        self.bindimg:setVisible(false)
    else            
        self.unbind:setVisible(false)
        self.bindimg:setVisible(true)
        self.bindnum:setString(ComFun.formatPhoneNumber(ComFun.getPhone(),true))
    end
end

function PlayerPanel:headInit()
    local imgName = kUserInfo:getUserId() .. ".jpg";
    local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
    if io.exists(headFile) then
        self.img_head:removeAllChildren()
        local cirHead = CircleClippingNode.new(headFile, true, self.img_head:getContentSize().height)
        cirHead:setPosition(self.img_head:getContentSize().width/2, self.img_head:getContentSize().height/2 )
        if IsPortrait then -- TODO
            self.img_head:loadTexture(headFile)
        else
            self.img_head:addChild(cirHead)
        end
    else
        print("[ ERROR ]  by Linxiancheng")
    end
end

function PlayerPanel:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_close then
            self:keyBack()
        elseif pWidget == self.btn_agency then
            self:agency()
        elseif pWidget == self.btn_bindphone then
            UIManager:getInstance():popWnd(PlayerPanel)
            UIManager:getInstance():pushWnd(BindPhone);
        elseif pWidget == self.btn_mianze then
            UIManager.getInstance():pushWnd(Duty)
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.DisclaimerButton)
        elseif pWidget == self.btn_shiming then
            local data = {}
            data.ty = 0
            SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_PLAYERCARDINFO, data)
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.RealNameButton)
        end
    end
end

function PlayerPanel:agency()    
    if Util.debug_shield_value("club") then return end

    if kSystemConfig:IsClubOwner() then
        SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_QUERYCLUBINFO);
    else
        SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_JOINEDCLUBLIST);
    end
    LoadingView.getInstance():show();
    NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.JoinClubButton)
end

function PlayerPanel:onClubUpdate(info)
    updateClubInfo(self)
end
-- 打开实名认证面板
function PlayerPanel:recPanelCardInfo(info)
    self.cardPanel = UIManager.getInstance():pushWnd(RealName, info)
end

local function showTips(str)
    local data = {}
    data.content = str
    UIManager.getInstance():pushWnd(CommonTips, data)
end 

local function failedDispose(failedType)
    if failedType == 1 then
        showTips("认证失败，您输入的信息有误，请重新输入")
    elseif failedType == 2 then -- 身份证号码格式错误
        showTips("您输入的信息有误，请重新输入")
    elseif failedType == 3 then -- 姓名格式错误
        showTips("您输入的信息有误，请重新输入")
    else
        showTips("认证失败，您输入的信息有误，请重新输入")
    end
end
-- 发送实名认证信息返回
function PlayerPanel:recCardInfoTips(info)
    -- if info.st ~= 0 then
        -- info.st = 2
    -- end
    LoadingView.getInstance():hide()
    local realPanel = UIManager.getInstance():getWnd(RealName)
    if info.st == -1  then -- 认证失败
        if realPanel then
            failedDispose(info.faT)
        else
            UIManager.getInstance():pushWnd(RealName)
        end 
    elseif info.st == 0 then -- 未认证
        if not realPanel then
            UIManager.getInstance():pushWnd(RealName)
        end
    elseif info.st == 1 then -- 认证成功   getWnd      
        if realPanel then
            realPanel:disposeRec(info)
            showTips("认证成功")
        else
            UIManager.getInstance():pushWnd(RealName, info)
        end
    elseif info.st == 2 then -- 认证中
        if realPanel then
            UIManager:getInstance():popWnd(RealName);
        end
        showTips("认证中，请稍候...")
    else 
        Log.i("[ ERROR ] PlayerPanel:recCardInfoTips data error ", info)
    end 
end

function PlayerPanel:recClubInfo()
    if Util.debug_shield_value("club") then return end
    LoadingView.getInstance():hide();

    self:keyBack()
    local ownerClubInfo = kSystemConfig:getOwnerClubInfo()
    if ownerClubInfo.clubID == 0 or ownerClubInfo.clubID == nil then
        if #kSystemConfig:getMyClubsInfo() > 0 then
            local ClubJoinedWnd = require("app.hall.wnds.club.clubJoinedWnd")
            UIManager.getInstance():pushWnd(ClubJoinedWnd);
        else
            UIManager.getInstance():pushWnd(Club);
        end
    else
        UIManager.getInstance():pushWnd(MyClub, ownerClubInfo);
    end
end

PlayerPanel.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_CLUB_REFRESH_UI]    = PlayerPanel.onClubUpdate,
    [HallSocketCmd.CODE_REC_PLAYERCARDINFO]     = PlayerPanel.recCardInfoTips,

    [HallSocketCmd.CODE_REC_QUERYCLUBINFO]      = PlayerPanel.recClubInfo;
    [HallSocketCmd.CODE_REC_JOINEDCLUBLIST]     = PlayerPanel.recClubInfo;
}

return PlayerPanel