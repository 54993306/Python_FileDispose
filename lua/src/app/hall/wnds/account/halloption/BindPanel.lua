-----------------------------------------------------------
--  @file   BindPanel.lua
--  @brief  绑定手机界面
--  @author At.Lin
--  @DateTime:2018-07-06 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local BindPanel = class("BindPanel")
local ComFun = require("app.hall.wnds.account.AccountComFun")
local AccountStatus = require "app.hall.wnds.account.AccountStatus"

local _Widget = {
    bindpanel           = "bindpanel",          -- 绑定面板
    bind_pho_num        = "bind_pho_num",       -- 绑定面板，手机号输入框
    img_pw_phone_tips   = "img_pw_phone_tips",  -- 绑定面板，手机号码提示框
    input_verify_pho    = "input_verify_pho",       -- 绑定面板，验证码输入框
    img_pw_verify_tips  = "img_pw_verify_tips", -- 绑定面板，验证码提示框
    btn_getverify       = "btn_getverify",      -- 绑定面板，获取验证码按钮
    btn_sure            = "btn_sure",           -- 绑定面板，确定按钮
    lab_diamond         = "lab_diamond",        -- 绑定面板，钻石数
    lab_verify          = "lab_verify",         -- 绑定面板，验证码倒计时
}
if IsPortrait then -- TODO
    _Widget.bind_pho_num = "input_phone"       -- 绑定面板，手机号输入框
    _Widget.lab_verify = "lab_regist_verify"         -- 绑定面板，验证码倒计时
end

-- 构造函数
function BindPanel:ctor(parent)
    self.Parent = parent -- 持有父节点的对象

    self.m_pWidget = parent.m_pWidget -- 父节点

    self.verifystatus = false -- 是否为获取验证码状态

    self.delaytiem = ComFun.getVerifyDelayTime()    -- 验证码等待时间

    self.img_pw_phone_tips = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_pw_phone_tips)
    self.img_pw_phone_tips:setVisible(false)

    self.img_pw_verify_tips = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_pw_verify_tips)
    self.img_pw_verify_tips:setVisible(false)

    self.btn_getverify = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_getverify)
    self.btn_getverify:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_sure = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_sure)
    self.btn_sure:addTouchEventListener(handler(self, self.onClickButton))

    self.lab_diamond = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.lab_diamond)

    self.lab_verify = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.lab_verify) --获取验证码倒计时

    self:initInput()

    if AccountStatus.TEST then
        self:test()
    end
end

function BindPanel:test()
    self.input_verify_pho:setText("123456") -- 设置输入框内的值
    self.phoVerify = "123456";  -- 验证码是短信发送需要玩家输入的

    self.bind_pho_num:setText("17776918882") -- 设置输入框内的值
    self.phoNum = 17776918882;  -- 验证码是短信发送需要玩家输入的
end

-- 初始化输入框
function BindPanel:initInput()
    self.phoNum = 0   -- 手机号
    self.bind_pho_num = self.Parent:getWidget(self.m_pWidget, _Widget.bind_pho_num);
    self.bind_pho_num:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self.bind_pho_num:registerScriptEditBoxHandler( function(eventname,sender) 
        if eventname == "ended" then
            self.phoNum = 0
            self.img_pw_phone_tips:setVisible(false)
            if self.bind_pho_num:getText() == "" then return end
            if ComFun.isPhoneNumber(self.bind_pho_num:getText()) then
                self.phoNum =  self.bind_pho_num:getText()
            else
                ComFun.ShowNodeBigAction(self.img_pw_phone_tips)
            end
        end
    end)

    self.phoVerify = 0  -- 验证码
    self.input_verify_pho = self.Parent:getWidget(self.m_pWidget, _Widget.input_verify_pho);
    self.input_verify_pho:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    self.input_verify_pho:registerScriptEditBoxHandler( function(eventname,sender) 
        if eventname == "ended" then
            self.img_pw_verify_tips:setVisible(false)
            self.phoVerify = 0
            if self.input_verify_pho:getText() == "" then return end
            if ComFun.isVerifyCode(self.input_verify_pho:getText() , 6) then
                self.phoVerify =  self.input_verify_pho:getText()
            else
                ComFun.ShowNodeBigAction(self.img_pw_verify_tips)
            end
        end
    end)
end

-- 刷新验证码倒计时
function BindPanel:updateVerifyTime()
    self.verifystatus = true
    local updatedelay = cc.CallFunc:create(function()
        self.delaytiem = self.delaytiem - 1;
        if self.delaytiem == 0 then
            self.lab_verify:stopAllActions()
            self.delaytiem = ComFun.getVerifyDelayTime();
            self.lab_verify:setString("获取验证码")
            if IsPortrait then -- TODO
                self.lab_verify:setFontSize(33)
            end
            self.verifystatus = false
            if device.platform ~= "ios" and device.platform ~= "android" then
                -- self:verifyBack()  -- 测试
            end
        else
            if IsPortrait then -- TODO
                self.lab_verify:setString(self.delaytiem)
            else
                self.lab_verify:setString(self.delaytiem.."秒后再次获取")
                self.lab_verify:setFontSize(21)
            end
        end
    end)
    self.lab_verify:runAction(cc.RepeatForever:create(cc.Sequence:create(updatedelay,cc.DelayTime:create(1))))
end

-- 获取注册的账号信息
function BindPanel:getPhoneAndVerify()
    local data = {}
    data.phone = self.phoNum
    data.verify = self.phoVerify
    return data
end

-- 点击确定按钮处理
function BindPanel:registCallBack()
    if self.phoNum == 0 then
        Toast.getInstance():show("请输入正确的手机号");
    elseif self.phoVerify == 0 then
        Toast.getInstance():show("请输入验证码");
    else
        self:sendCheckVerify()
    end
end

-- 校验验证码是否正确
function BindPanel:sendCheckVerify()
    local data = {}
    data.phN = self.phoNum
    data.phC = self.phoVerify
    data.seC = AccountStatus.VerifyCheckRegist
    SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEN_CODEVERIFY, data)
end

-- 按钮点击回调
function BindPanel:onClickButton(pWidget, EventType)
    if EventType ~= ccui.TouchEventType.ended then
        return
    end
    
    if pWidget:getName() == _Widget.btn_getverify then  -- 获取验证码
        if self.phoNum == 0 then 
            Toast.getInstance():show("请输入正确的手机号");
            return
        elseif self.verifystatus then 
            Toast.getInstance():show(self.delaytiem.."秒后再次获取验证码");
            return
        end       
        local data = {}
        data.phN = self.phoNum
        data.seC = AccountStatus.VerifyRegist
        SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEN_VERIFY, data)
    elseif pWidget:getName() == _Widget.btn_sure then
        self:registCallBack()
    else
        Log.e();
    end
end

return BindPanel