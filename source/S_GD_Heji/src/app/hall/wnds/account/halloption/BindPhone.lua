-----------------------------------------------------------
--  @file   BindPhone.lua
--  @brief  主界面的绑定手机号界面
--  @author At.Lin
--  @DateTime:2018-07-03 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local BindPhone = class("BindPhone", UIWndBase)
local AccountStatus = require "app.hall.wnds.account.AccountStatus"
local ComFun = require("app.hall.wnds.account.AccountComFun")

-- 控件名称声明
local _Widget = {
    closeBtn            = "closeBtn",           -- 关闭按钮
    btn_kefu            = "btn_kefu",           -- 创建界面失败时显示的联系客服按钮，默认隐藏
    img_bg              = "img_bg",             -- 背景界面

    setpassword         = "setpassword",        -- 设置密码界面

    bindpho             = "bindpho",            -- 绑定面板
    bind_pho_num        = "bind_pho_num",       -- 绑定面板，手机号输入框
    img_pw_phone_tips   = "img_pw_phone_tips",  -- 绑定面板，手机号码提示框
    input_verify_pho    = "input_verify_pho",   -- 绑定面板，验证码输入框
    img_pw_verify_tips  = "img_pw_verify_tips", -- 绑定面板，验证码提示框
    btn_getverify       = "btn_getverify",      -- 绑定面板，获取验证码按钮
    btn_sure            = "btn_sure",           -- 绑定面板，确定按钮
    lab_diamond         = "lab_diamond",        -- 绑定面板，钻石数
    lab_verify          = "lab_verify",         -- 绑定面板，验证码倒计时
    img_diamond         = "img_diamond",        -- 绑定面板，钻石图
    img_yuanbao         = "img_yuanbao",        -- 绑定面板，元宝图

    sure_bind           = "sure_bind",          -- 确认绑定面板
    lab_phonenum        = "lab_phonenum",       -- 确认绑定面板，手机号
    btn_sure2           = "btn_sure2",          -- 确认绑定面板，确定按钮
    btn_cancle          = "btn_cancle",         -- 确认绑定面板，取消按钮

    bindsucceed         = "bindsucceed",        -- 绑定成功面板
    lab_diamond2        = "lab_diamond2",       -- 绑定成功面板，钻石数
    img_diamond2        = "img_diamond2",      -- 绑定成功界面，钻石图
    img_yuanbao2        = "img_yuanbao2",        -- 绑定成功面板，元宝图
}

local SetPassword       = require "app.hall.wnds.account.SetPassword"
local BindPanel         = require "app.hall.wnds.account.halloption.BindPanel"
local NotarizePanel     = require "app.hall.wnds.account.halloption.NotarizePanel"
local PhoneLoginSocketProcesser = require("app.hall.wnds.account.PhoneLoginSocketProcesser");
local LocalEvent = require "app.hall.common.LocalEvent"

function BindPhone:ctor(...)
    self.super.ctor(self,"hall/bindPhone.csb",...)
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    self.m_socketProcesser = PhoneLoginSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
end

function BindPhone:onClose()
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
    self:removeListen()
end

-- 添加事件监听
function BindPhone:initEventListen()
    self.Events = {}
    local refreshToken = cc.EventListenerCustom:create(LocalEvent.RefreshToken,function(event)
        if AccountStatus.TEST or _isChooseServerForTest then
            Toast.getInstance():show("微信token 刷新成功 ");
        end
        self.SetPassword:bindPhone()  -- 刷新token成功后发送绑定微信消息
    end)

    table.insert(self.Events, refreshToken);
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(refreshToken , 1);
    if IsPortrait then -- TODO
        local listenBindState = cc.EventListenerCustom:create(LocalEvent.BindWechatSucceed,function(event)
            self.SetPassword:bindPhone()  -- 刷新token成功后发送绑定微信消息
        end)
        table.insert(self.Events, listenBindState);
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listenBindState , 1);
    end
end

-- 移除事件监听
function BindPhone:removeListen()
    table.walk(self.Events , function(event)
        cc.Director:getInstance():getEventDispatcher():removeEventListener(event)
    end)
    self.Events = {}
end

function BindPhone:onInit()
    self.img_bg = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_bg)
    self.closeBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.closeBtn)
    self.closeBtn:addTouchEventListener(handler(self, self.onClickButton))

    -- 绑定成功
    self.bindsucceed = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.bindsucceed)
    self.bindsucceed:setVisible(false)
    self.bindsucceed:addTouchEventListener(handler(self, self.onClickButton))

    -- 奖励的钻石数
    -- 
    self.lab_diamond = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.lab_diamond)
    self.lab_diamond2 = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.lab_diamond2)
    self.img_diamond = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_diamond)
    self.img_diamond2 = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_diamond2)
    self.img_yuanbao = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_yuanbao)
    self.img_yuanbao2 = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_yuanbao2)
    self:initAward()
    -- 设置密码
    self.setpassword = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.setpassword)
    self.SetPassword = SetPassword.new(self);
    self.SetPassword:setBind(true)
    self.setpassword:setVisible(false)
    -- 绑定界面
    self.bindpho = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.bindpho)
    self.bindpho:setVisible(true) -- 默认显示绑定界面
    self.bindPanel = BindPanel.new(self);

    -- 确定界面
    self.sure_bind = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.sure_bind)
    self.NotarizePanel = NotarizePanel.new(self);

    if self.m_data == AccountStatus.TaskFinish then
        self:bindSucceed()
    end
    
    -- 初始化消息监听
    self:initEventListen()
end

-- 初始化奖励信息
function BindPhone:initAward()
    local data = kHallGiftInfo:getGiftBaseInfo(AccountStatus.PhoneTaskID);
    if IsPortrait then -- TODO
        if not data.awL then return end
    end
    local list = string.split(data.awL,":")
    -- list[1] = 10009
    if list[1] == "10009" then
        self.img_diamond:setVisible(false)
        self.img_diamond2:setVisible(false)
        self.img_yuanbao:setVisible(true)
        self.img_yuanbao2:setVisible(true)
    end
    self.lab_diamond:setString("x"..list[2])
    self.lab_diamond2:setString("x"..list[2])
    Log.i("---------------------",list)
end

-- 显示确认界面
function BindPhone:showNotarizePanel(data)
    self.setpassword:setVisible(false)
    self.NotarizePanel:initNotarizeData(data)
    self.sure_bind:setVisible(true);
end

function BindPhone:onClickButton(pWidget, EventType)
    if EventType ~= ccui.TouchEventType.ended then
        return
    end
    if pWidget:getName()  == _Widget.closeBtn then
        UIManager.getInstance():popWnd(self);
    elseif pWidget:getName() == _Widget.bindsucceed then
        -- 发送请求获取钻石请求
        SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_GETWARD, {["quI"] = AccountStatus.PhoneTaskID})
        UIManager.getInstance():popWnd(self);
    end
end

-- 初始化设置面板数据
function BindPhone:initAccountData()
    if self.bindpho:isVisible() then
        self.bindpho:setVisible(false)  -- 设置自身隐藏
        self.SetPassword:setAccountData(self.bindPanel:getPhoneAndVerify(),true)
    end
    self.setpassword:setVisible(true)   -- 设置显示密码界面
end

-- 手机号码绑定成功处理
function BindPhone:bindSucceed()
    LoadingView.getInstance():hide()
    self.bindsucceed:setVisible(true)
    self.img_bg:setVisible(false)
    self.bindpho:setVisible(false)
    self.setpassword:setVisible(false)
    self.sure_bind:setVisible(false)
    Log.i(type(self.m_data))
    if type(self.m_data) == "table" and self.m_data.type == AccountStatus.HongBao then
        UIManager:getInstance():popWnd(BindPhone)
        local data = {}
        data = self.m_data
        data.type = 1
        local BindSuccessful = require("app.hall.wnds.mall.BindSuccessful")
        UIManager:getInstance():pushWnd(BindSuccessful,data)
    end
end

-- 获取验证码结果
function BindPhone:RecVerifyCode(data)
    if data.st == AccountStatus.VerifyBackSucceed then
        Toast.getInstance():show("验证码发送中请稍候...");
        self.bindPanel:updateVerifyTime()
    elseif data.st == AccountStatus.VerifyBackDefeat then
        Toast.getInstance():show("获取验证码失败");
    elseif data.st == AccountStatus.VerifyWait then
        Toast.getInstance():show("获取验证码太频繁");
    else
        Log.e()
    end
end

-- 验证码校验结果
function BindPhone:verifyCheckBack(packetInfo)
    if packetInfo.st == AccountStatus.CodeVerifySucceed then  -- 验证码校验成功，跳转设置密码界面
        Toast.getInstance():show("短信校验成功");
        LoadingView.getInstance():hide()
        self:initAccountData()
    elseif packetInfo.st == AccountStatus.CodeVerifyDefeat then
        Toast.getInstance():show("短信校验失败");
    elseif packetInfo.st == AccountStatus.CodeVerifyErr then
        Toast.getInstance():show("验证码错误");
    elseif packetInfo.st == AccountStatus.PhoneRepeat then
        Toast.getInstance():show("手机号已被注册");
    elseif packetInfo.st == AccountStatus.UnHavePhone then
        Toast.getInstance():show("该手机未注册");
    else
        Log.e()
    end
end

-- 绑定手机返回
function BindPhone:bindPhoneBack(data)
    if data.st == AccountStatus.BindSucceed then
        Toast.getInstance():show("绑定成功");
        ComFun.setPhone(data.phN)
        self:bindSucceed()
    elseif data.st == AccountStatus.BindDefeat then
        Toast.getInstance():show("绑定手机失败");
    elseif data.st == AccountStatus.BindVerifyDefeat then
        Toast.getInstance():show("验证码失效");
    elseif data.st == AccountStatus.BindVerifyErr then
        Toast.getInstance():show("验证码错误");
    elseif data.st == AccountStatus.BindPhoneRepeat then
        Toast.getInstance():show("该手机号已被使用");
    elseif data.st == AccountStatus.BindPhoneErr then
        Toast.getInstance():show("手机号错误");
    else
        Log.e()
    end
end

BindPhone.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_VERIFY]         = BindPhone.RecVerifyCode;        -- 获取验证码状态返回
    [HallSocketCmd.CODE_REC_CODEVERIFY]     = BindPhone.verifyCheckBack;      -- 验证码校验返回
    [HallSocketCmd.CODE_REC_BINDPHONE]      = BindPhone.bindPhoneBack;        -- 绑定手机返回
};

return BindPhone