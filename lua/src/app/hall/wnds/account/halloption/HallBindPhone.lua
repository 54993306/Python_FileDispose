-----------------------------------------------------------
--  @file   HallBindPhone.lua
--  @brief  更改密码界面
--  @author At.Lin
--  @DateTime:2018-07-03 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local HallBindPhone = class("HallBindPhone", UIWndBase)
local ComFun = require "app.hall.wnds.account.AccountComFun"
local BindPhone = require "app.hall.wnds.account.halloption.BindPhone"
local AccountStatus = require "app.hall.wnds.account.AccountStatus"

-- 控件名称声明
local _Widget = {
    closeBtn            = "closeBtn",           -- 关闭按钮
    btn_kefu            = "btn_kefu",           -- 创建界面失败时显示的联系客服按钮，默认隐藏
    img_bg              = "img_bg",             -- 背景界面

    choicepanel         = "choicepanel",        -- 选择功能界面
    img_bind            = "img_bind",           -- 选择功能界面，绑定手机图
    img_change          = "img_change",         -- 选择功能界面，修改密码图
    btn_bindphone       = "btn_bindphone",      -- 选择功能界面，绑定手机按钮
    btn_account         = "btn_account",        -- 选择功能界面，切换账号按钮
    btn_changepw        = "btn_changepw",       -- 选择功能界面，修改密码按钮

    change_pw           = "change_pw",          -- 更改密码界面
    input_oldpw         = "input_oldpw",        -- 更改密码界面，旧密码输入框
    img_old_tips        = "img_old_tips",       -- 更改密码界面，旧密码提示框
    input_new1          = "input_new1",         -- 更改密码界面，新密码输入框
    img_new1_tips       = "img_new1_tips",      -- 更改密码界面，新密码提示框
    input_new2          = "input_new2",         -- 更改密码界面，确认密码输入框
    img_new2_tips       = "img_new2_tips",      -- 更改密码界面，确认密码提示框
    btn_set_sure        = "btn_set_sure",       -- 更改密码界面，确认修改按钮

    verifyuser          = "verifyuser",         -- 验证身份界面 (已经取消)
    lab_verify_phone    = "lab_verify_phone",   -- 验证身份界面，已绑定的手机号(中间4位需要隐藏)
    input_user_verify   = "input_user_verify",  -- 验证身份界面，验证码输入框
    img_verify_tips     = "img_verify_tips",    -- 验证身份界面，验证码错误提示
    btn_getverify       = "btn_getverify",      -- 验证身份界面，获取验证码按钮
    btn_verify_sure     = "btn_verify_sure",    -- 验证身份界面，确定按钮

    successpanel        = "successpanel",       -- 绑定成功界面(已经取消)
    lab_success         = "lab_success",        -- 绑定成功界面，手机号码
    btn_know            = "btn_know",           -- 绑定成功界面，确定按钮

    changePhone         = "changePhone",        -- 换绑手机界面(已经取消)
    input_phonenum      = "input_phonenum",     -- 换绑手机界面，需要换绑手机号
    img_cg_phone_tips   = "img_cg_phone_tips",  -- 换绑手机界面，手机提示框
    input_cg_verify     = "input_cg_verify",    -- 换绑手机界面，验证码输入框
    img_cg_verify_tips  = "img_cg_verify_tips", -- 换绑手机界面，验证码提示框
    btn_cg_getverify    = "btn_cg_getverify",   -- 换绑手机界面，获取验证码按钮
    btn_cg_sure         = "btn_cg_sure",        -- 换绑手机界面，确认更换按钮
}

local ChangePassword = require "app.hall.wnds.account.halloption.ChangePassword"
local PhoneLoginSocketProcesser = require("app.hall.wnds.account.PhoneLoginSocketProcesser");

function HallBindPhone:ctor(...)
    self.super.ctor(self,"hall/hallBind.csb",...)
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    self.m_socketProcesser = PhoneLoginSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
end

function HallBindPhone:onClose()
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
end

function HallBindPhone:onInit()
    self.closeBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.closeBtn)
    self.closeBtn:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_bindphone = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_bindphone)
    self.btn_bindphone:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_changepw = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_changepw)
    self.btn_changepw:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_account = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_account)
    self.btn_account:addTouchEventListener(handler(self, self.onClickButton))

    self.img_bind = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_bind)

    self.img_change = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_change)

    -- 选择界面
    self.choicepanel = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.choicepanel)
    self.choicepanel:setVisible(true)
    -- 修改密码界面
    self.change_pw = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.change_pw)
    self.ChangePassword = ChangePassword.new(self);
    
    -- self.verifyuser = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.verifyuser)  -- 多余的界面

    -- self.changePhone = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.changePhone)

    -- self.successpanel = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.successpanel)
end

-- 判断玩家是否存在手机号
function HallBindPhone:onShow()
    self.phoneNum = ComFun.getPhone();
    local hasPhone = self.phoneNum  ~= "0"
    self.btn_changepw:setVisible(hasPhone);    -- 没有手机号的情况进入注册界面
    self.btn_bindphone:setVisible(not hasPhone);     -- 有手机号的情况进入输入手机号的登陆界面
    self.img_bind:setVisible(not hasPhone)
    self.img_change:setVisible(hasPhone)

    if AccountStatus.TEST then
        self:test()
    end
end

function HallBindPhone:test()
    self.btn_changepw:setVisible(true);    -- 没有手机号的情况进入注册界面
    self.btn_bindphone:setVisible(false);     -- 有手机号的情况进入输入手机号的登陆界面
end

-- 按钮回调函数
function HallBindPhone:onClickButton(pWidget, EventType)
    if EventType ~= ccui.TouchEventType.ended then
        return
    end

    if pWidget:getName() == _Widget.btn_bindphone then
        UIManager:getInstance():pushWnd(BindPhone);
        UIManager.getInstance():popWnd(self);
    elseif pWidget:getName() == _Widget.btn_changepw then  --
        self.change_pw:setVisible(true)
        self.choicepanel:setVisible(false)
    elseif pWidget:getName() == _Widget.btn_account then
        self:changeAccount()
    elseif pWidget:getName() == _Widget.closeBtn then
        Log.i("linxiancheng ------- HallBindPhone:onClickButton")
        UIManager.getInstance():popWnd(self);
    else
        Log.e()
    end
end

-- 切换账号
function HallBindPhone:changeAccount()
    SocketManager.getInstance():closeSocket();
    kLoginInfo:clearAccountInfo();
    cc.UserDefault:getInstance():setStringForKey("refresh_token", "");
    cc.UserDefault:getInstance():setStringForKey("wx_name", "");
    local info = {};
    info.isExit = true;
    UIManager.getInstance():replaceWnd(HallLogin, info);
end

-- 修改密码返回
function HallBindPhone:changeBack(data)
    if data.st == AccountStatus.ChangeSucceed then
        UIManager.getInstance():popWnd(self);
        local data = {}
        data.type = 1;
        data.content = "修改密码成功";
        UIManager.getInstance():pushWnd(CommonDialog, data);
    elseif data.st == AccountStatus.ChangeDefeat  then
        Toast.getInstance():show("修改密码失败")
    elseif data.st == AccountStatus.ChangeOldPasswordErr  then
        Toast.getInstance():show("旧密码错误")
    elseif data.st == AccountStatus.ChangeUnRegist  then
        Toast.getInstance():show("该手机未注册")
    else
        Log.e()
    end
end

HallBindPhone.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_CHANGE_PASSWORD]    = HallBindPhone.changeBack;           --如果是一个局部方法，会如何
};

return HallBindPhone