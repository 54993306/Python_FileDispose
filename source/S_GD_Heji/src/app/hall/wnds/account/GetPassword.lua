-----------------------------------------------------------
--  @file   GetPassword.lua
--  @brief  设置账号密码界面
--  @author At.Lin
--  @DateTime:2018-07-05 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local GetPassword = class("GetPassword")
local ComFun = require("app.hall.wnds.account.AccountComFun")
local _Widget = {
    input_pw_phonenum   = "input_pw_phonenum",  -- 找回密码界面，手机号码输入框
    img_get_phone_tips  = "img_get_phone_tips", -- 找回密码界面，手机号提示框
    input_pw_verify     = "input_pw_verify",    -- 找回密码界面，验证码输入框
    img_get_verify_tips = "img_get_verify_tips",-- 找回密码界面，验证码提示框
    btn_getverify       = "btn_getverify",      -- 找回密码界面，获取验证码按钮
    btn_pw_sure         = "btn_pw_sure",        -- 找回密码界面，确定按钮
    lab_getpw_verify    = "lab_getpw_verify",   -- 找回密码界面，验证码倒计时
}
local AccountStatus = require "app.hall.wnds.account.AccountStatus"

-- 构造函数
function GetPassword:ctor(parent)
    self.Parent = parent  -- 持有父节点的对象

    self.m_pWidget = parent.m_pWidget  -- 父节点

    self.verifystatus = false ;  -- 是否在请求验证码倒计时阶段

    self.verifyDelay = ComFun.getVerifyDelayTime()

    self.img_get_phone_tips = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_get_phone_tips)
    self.img_get_phone_tips:setVisible(false)

    self.img_get_verify_tips = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_get_verify_tips)
    self.img_get_verify_tips:setVisible(false)

    self.btn_getverify = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_getverify)
    self.btn_getverify:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_pw_sure = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_pw_sure)
    self.btn_pw_sure:addTouchEventListener(handler(self, self.onClickButton))

    self.lab_getpw_verify = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.lab_getpw_verify)
    self:initInput()

    if AccountStatus.TEST then
        self:test()
    end
end

-- 
function GetPassword:test()
    self.PhoneNum = "17776918882"
    self.input_pw_phonenum:setText("17776918882")

    self.input_pw_verify:setText("123456") -- 设置输入框内的值
    self.verifyNum = 123456;  -- 验证码是短信发送需要玩家输入的
end

-- 初始化输入框
function GetPassword:initInput()
    self.PhoneNum = 0   -- 手机号
    self.input_pw_phonenum = self.Parent:getWidget(self.m_pWidget, _Widget.input_pw_phonenum);
    self.input_pw_phonenum:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self.input_pw_phonenum:registerScriptEditBoxHandler( function(eventname,sender) 
        if eventname == "ended" then
            self.PhoneNum = 0   -- 手机号
            self.img_get_phone_tips:setVisible(false)
            if self.input_pw_phonenum:getText() == "" then return end
            if ComFun.isPhoneNumber(self.input_pw_phonenum:getText()) then
                self.PhoneNum =  self.input_pw_phonenum:getText()
            else
                ComFun.ShowNodeBigAction(self.img_get_phone_tips)
            end
        end
    end)

    self.verifyNum = 0  -- 验证码
    self.input_pw_verify = self.Parent:getWidget(self.m_pWidget, _Widget.input_pw_verify);
    self.input_pw_verify:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    self.input_pw_verify:registerScriptEditBoxHandler( function(eventname,sender) 
        if eventname == "ended" then
            self.verifyNum = 0
            self.img_get_verify_tips:setVisible(false)
            if self.input_pw_verify:getText() == "" then return end
            if ComFun.isVerifyCode(self.input_pw_verify:getText() , 6) then
                self.verifyNum =  self.input_pw_verify:getText()
            else
                ComFun.ShowNodeBigAction(self.img_get_verify_tips)
            end
        end
    end)
end

-- 按钮点击回调 17776918882
function GetPassword:onClickButton(pWidget, EventType)
    if EventType ~= ccui.TouchEventType.ended then
        return
    end

    if pWidget:getName() == _Widget.btn_getverify then  -- 获取验证码
        if self.PhoneNum == 0 then 
            Toast.getInstance():show("请输入正确的手机号");
            return
        elseif self.verifystatus then 
            Toast.getInstance():show(self.verifyDelay.."秒后再次获取验证码");
            return
        end
        local data = {}
        data.phN = self.PhoneNum
        data.seC = AccountStatus.VerifyResetPassword
        SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEN_VERIFY, data)
    elseif pWidget:getName() == _Widget.btn_pw_sure then
        self:sendGetMessage(pWidget)
    else
        Log.e()
    end
end

-- 点击注册按钮处理
function GetPassword:sendGetMessage(pWidget)
    if self.PhoneNum == 0 then
        Toast.getInstance():show("请输入正确的手机号");
    elseif self.verifyNum == 0 then
        Toast.getInstance():show("请输入验证码");
    else
        LoadingView.getInstance():show("正在发送请求,请稍候...");
        self:sendCheckVerify()
    end
end

-- 校验验证码
function GetPassword:sendCheckVerify()
    local data = {}
    data.phN = self.PhoneNum
    data.phC = self.verifyNum
    data.seC = AccountStatus.VerifyCheckResetPassword
    SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEN_CODEVERIFY, data)
end

-- 获取手机号和验证码
function GetPassword:getPhoneAndVerify()
    local data = {}
    data.phone = self.PhoneNum
    data.verify = self.verifyNum
    return data
end

-- 刷新验证码倒计时
function GetPassword:updateVerifyTime()
    self.verifystatus = true
    local updatedelay = cc.CallFunc:create(function()
        self.verifyDelay = self.verifyDelay - 1;
        if self.verifyDelay == 0 then
            self.lab_getpw_verify:stopAllActions()
            self.verifyDelay = ComFun.getVerifyDelayTime();
            self.lab_getpw_verify:setString("获取验证码")
            if not IsPortrait then -- TODO
                self.lab_getpw_verify:setFontSize(33)
            end
            self.verifystatus = false
            if device.platform ~= "ios" and device.platform ~= "android" then
                -- self:verifyBack()  -- 测试
            end
        else
            if IsPortrait then -- TODO
                self.lab_getpw_verify:setString(self.verifyDelay)
            else
                self.lab_getpw_verify:setString(self.verifyDelay.."秒后再次获取")
                self.lab_getpw_verify:setFontSize(21)
            end
        end
    end)
    self.lab_getpw_verify:runAction(cc.RepeatForever:create(cc.Sequence:create(updatedelay,cc.DelayTime:create(1))))
end

return GetPassword