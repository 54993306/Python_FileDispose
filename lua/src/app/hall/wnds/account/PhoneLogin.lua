-----------------------------------------------------------
--  @file   PhoneLogin.lua
--  @brief  主界面手机相关父节点类
--  @author At.Lin
--  @DateTime:2018-07-03 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local PhoneLogin = class("PhoneLogin", UIWndBase)
local PhoneLoginSocketProcesser = require("app.hall.wnds.account.PhoneLoginSocketProcesser");
-- 控件名称声明
local _Widget = {
    closeBtn            = "closeBtn",           -- 关闭按钮
    btn_kefu            = "btn_kefu",           -- 创建界面失败时显示的联系客服按钮，默认隐藏

    regist              = "regist",             -- 注册界面
    input_phone         = "input_phone",        -- 注册界面，手机号输入框
    img_phone_tips      = "img_phone_tips",     -- 注册界面，手机号提示框
    input_verift        = "input_verift",       -- 注册界面，验证码输入框
    img_verify_tips     = "img_verify_tips",    -- 注册界面，验证码提示框
    btn_verity          = "btn_verity",         -- 注册界面，获取验证码按钮
    btn_binding         = "btn_binding",        -- 注册界面，绑定微信按钮
    btn_regist          = "btn_regist",         -- 注册界面，注册按钮
    lab_regist_verify   = "lab_regist_verify",  -- 注册界面，验证码倒计时

    phoneloginpanel     = "phoneloginpanel",    -- 手机登陆界面
    input_phonenum      = "input_phonenum",     -- 手机登陆界面，手机号码输入框
    input_password      = "input_password",     -- 手机登陆界面，密码输入框
    btn_getpassword     = "btn_getpassword",    -- 手机登陆界面，找回密码按钮
    btn_phone_login     = "btn_phone_login",    -- 手机登陆界面，登陆按钮
    img_phone_tips2     = "img_phone_tips2",    -- 手机登陆界面，手机号提示框
    img_password_tips   = "img_password_tips",  -- 手机登陆界面，密码提示框
    remain              = "remain",             -- 手机登陆界面，记住密码
    btn_phone_regist2   = "btn_phone_regist2",  -- 手机登陆界面，注册按钮

    getpassword         = "getpassword",        -- 找回密码界面
    input_pw_phonenum   = "input_pw_phonenum",  -- 找回密码界面，手机号码输入框
    img_get_phone_tips  = "img_get_phone_tips", -- 找回密码界面，手机号提示框
    input_pw_verify     = "input_pw_verify",    -- 找回密码界面，验证码输入框
    img_get_verify_tips = "img_get_verify_tips",-- 找回密码界面，验证码提示框
    btn_getverify       = "btn_getverify",      -- 找回密码界面，获取验证码按钮
    btn_pw_sure         = "btn_pw_sure",        -- 找回密码界面，确定按钮
    lab_getpw_verify    = "lab_getpw_verify",   -- 找回密码界面，验证码倒计时

    setpassword         = "setpassword",        -- 设置密码界面
    input_newpw         = "input_newpw",        -- 设置密码界面，新密码输入框
    img_setpw_tips      = "img_setpw_tips",     -- 设置密码界面，新密码提示框
    input_newpw2        = "input_newpw2",       -- 设置密码界面，确认密码输入框
    img_setpw2_tips     = "img_setpw2_tips",    -- 设置密码界面，确认密码输入框
    btn_setpw_sure      = "btn_setpw_sure",     -- 设置密码界面，确定按钮
}

local RegistPanel  = require "app.hall.wnds.account.phoneRegistPanel"
local SetPassword  = require "app.hall.wnds.account.SetPassword"
local GetPassword  = require "app.hall.wnds.account.GetPassword"
local ByPhoneLogin = require "app.hall.wnds.account.ByPhoneLogin"
local AccountStatus = require "app.hall.wnds.account.AccountStatus"
local ComFun = require("app.hall.wnds.account.AccountComFun")

function PhoneLogin:ctor(...)
    self.super.ctor(self,"hall/accountPanel.csb",...)
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    self.m_socketProcesser = PhoneLoginSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
end

function PhoneLogin:onClose()
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end

    self.RegistPanel:dtor()
end

-- 初始化显示内容信息
function PhoneLogin:onInit()
    -- 注册面板
    self.registPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.regist)
    self.RegistPanel = RegistPanel.new(self);
    -- 手机登陆
    self.loginPanel  = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.phoneloginpanel)
    self.ByPhoneLogin = ByPhoneLogin.new(self);
    -- 找回密码
    self.getpassword = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.getpassword)
    self.GetPassword = GetPassword.new(self);
    -- 设置密码
    self.setpassword = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.setpassword)
    self.SetPassWordObject = SetPassword.new(self);

    self.closeBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "closeBtn")
    self.closeBtn:addTouchEventListener(handler(self, self.onClickButton))

    cc.UserDefault:getInstance():setStringForKey("logintype", "phone");
end

-- 判断玩家是否存在手机号
function PhoneLogin:onShow()
    self.phoneNum = ComFun.getPhone()

    if self.phoneNum  == "0" then
        -- self.registPanel:setVisible(true);    -- 没有手机号的情况进入注册界面
    else            
        -- self.loginPanel:setVisible(true);     -- 有手机号的情况进入输入手机号的登陆界面
    end
    self.loginPanel:setVisible(true);     -- 有手机号的情况进入输入手机号的登陆界面
    if AccountStatus.TEST then
        -- self.registPanel:setVisible(true);    -- 没有手机号的情况进入注册界面
        -- self.setpassword:setVisible(true);
    end

    local connectNetwork = cc.CallFunc:create(function() 
        if SocketManager.getInstance():getNetWorkStatus() ~= NETWORK_NORMAL then
            LoadingView.getInstance():show("正在连接服务器，请稍后...", 1000)
        end
        kLoginInfo:getPhoneInfoAndLink();   -- 获取手机信息并连接socket
    end)
    self.m_pWidget:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),connectNetwork))
end

-- 显示注册界面
function PhoneLogin:showRegist()
    self.registPanel:setVisible(true);    -- 没有手机号的情况进入注册界面
    self.loginPanel:setVisible(false);     -- 有手机号的情况进入输入手机号的登陆界面
end

-- 连接服务器返回
function PhoneLogin:onNetWorkConnected()
    -- Toast.getInstance():show("服务器连接成功");
    LoadingView.getInstance():hide()
end

-- 关闭手机绑定界面
function PhoneLogin:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        UIManager.getInstance():popWnd(self);
        SocketManager.getInstance():closeSocket()
        cc.UserDefault:getInstance():setStringForKey("logintype", "0");
    end
end

-- 登陆成功返回处理
function PhoneLogin:LoginSucceed()
    -- 跳转至主界面
    UIManager.getInstance():replaceWnd(HallLoading) -- 会把其他的界面都移除掉，只剩下大厅的场景
end

-- 找回密码成功
function PhoneLogin:turnToSetPassword() -- 服务器通知找回密码成功跳转设置密码界面，隐藏找回密码界面
    self.getpassword:setVisible(false)
    self.setpassword:setVisible(true)
end

-- 初始化设置面板数据
function PhoneLogin:initAccountData(isRegist)
    if self.registPanel:isVisible() then
        self.registPanel:setVisible(false)  -- 设置自身隐藏
        self.SetPassWordObject:setAccountData(self.RegistPanel:getPhoneAndVerify(),true)
    else
        self.getpassword:setVisible(false)  -- 设置自身隐藏
        self.SetPassWordObject:setAccountData(self.GetPassword:getPhoneAndVerify())
    end
    self.setpassword:setVisible(true)   -- 设置显示密码界面
end

-- 获取验证码结果
function PhoneLogin:RecVerifyCode(data)
    if data.st == AccountStatus.VerifyBackSucceed then
        Toast.getInstance():show("验证码发送中请稍候...");
        if self.registPanel:isVisible() then
            self.RegistPanel:updateVerifyTime()
        else
            self.GetPassword:updateVerifyTime()
        end
    elseif data.st == AccountStatus.VerifyBackDefeat then
        Toast.getInstance():show("获取验证码失败");
    elseif data.st == AccountStatus.VerifyWait then
        Toast.getInstance():show("获取验证码太频繁");
    else
        Log.e()
    end
end

-- 验证码校验结果
function PhoneLogin:verifyCheckBack(packetInfo)
    if packetInfo.st == AccountStatus.CodeVerifySucceed then  -- 验证码校验成功，跳转设置密码界面
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

-- 找回密码结果
function PhoneLogin:getPasswordRec(data)
    if data.st == AccountStatus.GetPasswordSucceed then
        UIManager.getInstance():popWnd(self);
        local data = {};
        if IsPortrait then -- TODO
            data.type = 1;
            data.title = "提示";
            data.closeStr = "进入游戏";
            data.content = "新密码设置成功点击进入游戏";
            data.closeCallback = function ()
                self.SetPassWordObject:registLogin()
            end
        else
            data.type = 2;
            data.title = "取回密码成功";
            data.yesStr = "确定";
            data.content = "新密码设置成功点击进入游戏";
            data.yesCallback = function ()
                self.SetPassWordObject:registLogin()
            end
        end
        UIManager.getInstance():pushWnd(CommonDialog, data);
    elseif data.st == AccountStatus.GetPasswordDefeat then
        Toast.getInstance():show("找回密码失败");
    elseif data.st == AccountStatus.GetPasswordVerifyDefeat then
        Toast.getInstance():show("验证码失效");
    elseif data.st == AccountStatus.GetPasswordVerifyErr then
        Toast.getInstance():show("验证码错误");
    elseif data.st == AccountStatus.GetPasswordAccountErr then
        Toast.getInstance():show("账号错误");
    elseif data.st == AccountStatus.GetPasswordUnPhone then
        Toast.getInstance():show("该手机未注册");
    elseif data.st == AccountStatus.GetPasswordRepeat then
        Toast.getInstance():show("新密码不能与旧密码相同");
    else
        Toast.getInstance():show("找回密码服务器数据错误 Code :" .. data.st);
        Log.e()
    end
end

-- 绑定微信返回
function PhoneLogin:bindWechatRec(data)
    if data.St == AccountStatus.WechatBindSucceed then
        self.RegistPanel:wechatBindSucceed()
    elseif data.St == AccountStatus.WechatBindFailed then
        Toast.getInstance():show("微信绑定失败");
    elseif data.St == AccountStatus.WechatBindRepeat then
        Toast.getInstance():show("该微信已绑定过其他手机");
    else
        Toast.getInstance():show("绑定微信服务器返回数据错误 Code :" .. data.St);
        Log.e()
    end
end

PhoneLogin.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_VERIFY]         = PhoneLogin.RecVerifyCode;        -- 获取验证码状态返回
    [HallSocketCmd.CODE_REC_CODEVERIFY]     = PhoneLogin.verifyCheckBack;      -- 验证码校验返回
    [HallSocketCmd.CODE_REC_GETPASSWORD]    = PhoneLogin.getPasswordRec;        -- 发送新密码返回
    [HallSocketCmd.CODE_REC_BINDWECHAT]     = PhoneLogin.bindWechatRec;        -- 绑定微信返回
};

return PhoneLogin