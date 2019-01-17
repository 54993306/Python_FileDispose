-----------------------------------------------------------
--  @file   SetPassword.lua
--  @brief  设置账号密码界面
--  @author At.Lin
--  @DateTime:2018-07-06 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local SetPassword = class("SetPassword")
local ComFun = require("app.hall.wnds.account.AccountComFun")
local AccountStatus = require "app.hall.wnds.account.AccountStatus"
local BindWechat = require("app.hall.wnds.account.AccountBindWechat")
local crypto = require "app.framework.crypto"

local _Widget = {
    setpassword         = "setpassword",        -- 设置密码界面
    input_newpw         = "input_newpw",        -- 设置密码界面，新密码输入框
    img_setpw_tips      = "img_setpw_tips",     -- 设置密码界面，新密码提示框
    input_newpw2        = "input_newpw2",       -- 设置密码界面，确认密码输入框
    img_setpw2_tips     = "img_setpw2_tips",    -- 设置密码界面，确认密码输入框
    btn_setpw_sure      = "btn_setpw_sure",     -- 设置密码界面，确定按钮
}

-- 构造函数
function SetPassword:ctor(parent)
    self.Parent = parent -- 持有父节点的对象

    self.m_pWidget = parent.m_pWidget -- 父节点

    self.isRegist = false -- 是否为注册状态

    self.isBind = false     -- 是否为绑定状态

    self.accountData = nil   -- 注册设置密码时所需数据

    self.img_setpw_tips = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_setpw_tips)
    self.img_setpw_tips:setVisible(false)

    self.img_setpw2_tips = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_setpw2_tips)
    self.img_setpw2_tips:setVisible(false)

    self.btn_setpw_sure = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_setpw_sure)
    self.btn_setpw_sure:addTouchEventListener(handler(self, self.onClickButton))

    self:initInput()

    if AccountStatus.TEST then
        self:test()
    end
end

-- 设置是否为绑定手机状态
function SetPassword:setBind(bind)
    self.isBind = bind
end

function SetPassword:test()
    self.input_newpw:setText("a123456")  -- 设置输入框内的值
    self.Password1 = "a123456";          -- 验证码是短信发送需要玩家输入的

    self.input_newpw2:setText("a123456") -- 设置输入框内的值
    self.Password2 = "a123456";          -- 验证码是短信发送需要玩家输入的
end

-- 设置是否为注册状态
function SetPassword:setAccountData(data,isRegist)
    self.isRegist = isRegist
    self.accountData = data
end

-- 初始化输入框
function SetPassword:initInput()
    self.Password1 = 0   -- 密码
    self.input_newpw = self.Parent:getWidget(self.m_pWidget, _Widget.input_newpw);
    self.input_newpw:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    self.input_newpw:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.input_newpw:setPlaceHolder("请输入6-14位数字或字母")
    self.input_newpw:registerScriptEditBoxHandler( function(eventname,sender)
        if eventname == "ended" then
            self.Password1 = 0
            self.img_setpw_tips:setVisible(false)
            if self.input_newpw:getText() == "" then return end
            if ComFun.isPassword(self.input_newpw:getText()) then
                self.Password1 = self.input_newpw:getText()
                if self.input_newpw:getText() == self.input_newpw2:getText() then
                    self.img_setpw2_tips:setVisible(false)
                    self.Password2 = self.Password1
                end
            else
                ComFun.ShowNodeBigAction(self.img_setpw_tips)
            end
        end
    end)

    self.Password2 = 0   -- 密码
    self.input_newpw2 = self.Parent:getWidget(self.m_pWidget, _Widget.input_newpw2);
    self.input_newpw2:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    self.input_newpw2:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.input_newpw2:registerScriptEditBoxHandler( function(eventname,sender)
        if eventname == "ended" then
            local ps = self.input_newpw2:getText()
            self.Password2 = 0
            self.img_setpw2_tips:setVisible(false)
            if ps == "" or self.input_newpw:getText() == "" then return end
            if ComFun.isPassword(ps) and self.Password1 == ps then
                self.Password2 = ps -- 验证两次输入的密码一致后才设置密码
            else
                ComFun.ShowNodeBigAction(self.img_setpw2_tips)
            end
        end
    end)
end

-- 注册账号设置密码后，发送登陆消息
function SetPassword:registLogin()
    local data = LoginInfo.initLoginData()
    if AccountStatus.TEST then
        data.ac = "weixinopenid"..math.random(1,100)  -- 微信的openid需要
    else
        data.ac = WX_OPENID  -- 微信的openid需要
    end
    data.phN = self.accountData.phone -- 手机号注册
    data.phC = self.accountData.verify
    data.pa  = crypto.md5(self.Password1)
    data.pa1 = crypto.md5(self.Password2)
    data.wx  = cc.UserDefault:getInstance():getStringForKey("access_token", "");
    if self.isRegist then
        data.LoT = AccountStatus.RegistAccount
    else
        data.LoT = AccountStatus.PhoneLogin
    end

    kLoginInfo:clearUserData()
    return SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEND_LOGIN, data);
end

-- 绑定手机
function SetPassword:bindPhone()
    local data = {}
    data.phN = self.accountData.phone
    data.phC = self.accountData.verify
    data.pa = crypto.md5(self.Password1)
    data.pa0 = crypto.md5(self.Password2)
    Log.i("------Accmd5 : " .. data.pa  .. " nor : " ..  self.Password1)
    data.wx  = cc.UserDefault:getInstance():getStringForKey("access_token", "");
    Log.i("bindPhone : ",data)
    self.Parent:showNotarizePanel(data)
end

-- 设置新的密码
function SetPassword:setNewPassword()
    LoadingView.getInstance():show("密码设置中,请稍候...");
    local data = {}
    data.phN = self.accountData.phone
    data.phC = self.accountData.verify
    data.pa = crypto.md5(self.Password1)
    data.pa0 = crypto.md5(self.Password2)
    Log.i("------Accmd5 : " .. data.pa  .. " nor : " ..  self.Password1)
    SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEN_GETPASSWORD, data);
end

-- 是否达到设置密码条件
function SetPassword:isCondition()
    if self.Password1 == 0 then
        Toast.getInstance():show("请输入符合规则的密码")
        return false
    elseif self.Password2 == 0 then
        if self.input_newpw2:getText() ~= "" then
            Toast.getInstance():show("两次密码不一致")
        else
            Toast.getInstance():show("请输入确认密码")
        end
        return false
    elseif self.Password2 ~= self.Password1 then
        Toast.getInstance():show("两次密码不一致")
        return false
    end
    return true
end

-- 按钮点击回调
function SetPassword:onClickButton(pWidget, EventType)
    if EventType ~= ccui.TouchEventType.ended then return end
    if pWidget:getName() == _Widget.btn_setpw_sure then  -- 获取验证码
        if not self:isCondition() then return end
        if self.isBind then
            LoadingView.getInstance():show("正在绑定手机，请稍候...");
            BindWechat.refreshToken()
        elseif self.isRegist then
            LoadingView.getInstance():show("手机绑定中,请稍候...");
            self:registLogin()
        else
            self:setNewPassword()
        end
    else
        Log.e()
    end
end

return SetPassword
