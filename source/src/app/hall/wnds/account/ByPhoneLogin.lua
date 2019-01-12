-----------------------------------------------------------
--  @file   ByPhoneLogin.lua
--  @brief  手机号登陆界面
--  @author At.Lin
--  @DateTime:2018-07-05 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local ByPhoneLogin = class("ByPhoneLogin")
local ComFun = require("app.hall.wnds.account.AccountComFun")
local AccountStatus = require "app.hall.wnds.account.AccountStatus"
local crypto = require "app.framework.crypto"

local _Widget = {
    input_phonenum      = "input_phonenum",     -- 手机登陆界面，手机号码输入框
    input_password      = "input_password",     -- 手机登陆界面，密码输入框
    btn_getpassword     = "btn_getpassword",    -- 手机登陆界面，找回密码按钮
    btn_phone_login     = "btn_phone_login",    -- 手机登陆界面，登陆按钮
    img_phone_tips2     = "img_phone_tips2",    -- 手机登陆界面，手机号提示框
    img_password_tips   = "img_password_tips",  -- 手机登陆界面，密码提示框
    btn_phone_regist2   = "btn_phone_regist2",  -- 手机登陆界面，注册按钮
    remain              = "remain",             -- 手机登陆界面，记住密码
}

-- 构造函数
function ByPhoneLogin:ctor(parent)
    self.Parent = parent -- 持有父节点的对象

    self.m_pWidget = parent.m_pWidget -- 父节点

    self.img_phone_tips2 = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_phone_tips2)
    self.img_phone_tips2:setVisible(false)

    self.img_password_tips = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_password_tips)
    self.img_password_tips:setVisible(false)

    self.btn_getpassword = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_getpassword)
    self.btn_getpassword:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_phone_login = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_phone_login)
    self.btn_phone_login:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_phone_regist2 = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_phone_regist2)
    self.btn_phone_regist2:addTouchEventListener(handler(self, self.onClickButton))

    self.isRemain = cc.UserDefault:getInstance():getStringForKey("remainPassword","0") ~= "0"

    self.remain = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.remain)
    self.remain:addTouchEventListener(handler(self, self.onClickButton))
    self.remain:setSelected(self.isRemain)

    self:initInput()

    self:initDefaultAccount()
    if AccountStatus.TEST then
        self:test()
    end
end

function ByPhoneLogin:test()
    self.input_phonenum:setText("17776918882") -- 设置输入框内的值
    self.PhoneNum = 17776918882;  -- 验证码是短信发送需要玩家输入的

    self.input_password:setText("a11111") -- 设置输入框内的值
    self.Password = "a11111";  -- 验证码是短信发送需要玩家输入的
end

-- 初始化账号和密码信息
function ByPhoneLogin:initDefaultAccount()
    local phone = ComFun.getPhone()
    if phone ~= "0"then
        self.input_phonenum:setText(phone) -- 设置输入框内的值
        self.PhoneNum = phone;  -- 验证码是短信发送需要玩家输入的
    else
        return
    end

    if not self.isRemain then return end
    self:initDefaultPassword()
end

-- 设置为默认密码
function ByPhoneLogin:initDefaultPassword()
    local Password = ComFun.getPassword()
    if Password ~= "0" then
        self.input_password:setText(Password) -- 设置输入框内的值
        self.Password = Password;  -- 验证码是短信发送需要玩家输入的
    else
        return
    end
end

-- 初始化输入框
function ByPhoneLogin:initInput()
    self.PhoneNum = 0   -- 手机号
    self.input_phonenum = self.Parent:getWidget(self.m_pWidget, _Widget.input_phonenum);
    self.input_phonenum:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self.input_phonenum:registerScriptEditBoxHandler( function(eventname,sender) 
        if eventname == "ended" then
            self.PhoneNum = 0
            self.img_phone_tips2:setVisible(false)
            if self.input_phonenum:getText() == "" then return end
            if ComFun.isPhoneNumber(self.input_phonenum:getText()) then
                self.PhoneNum =  self.input_phonenum:getText()
            else
                ComFun.ShowNodeBigAction(self.img_phone_tips2)
            end
        end
    end)

    self.Password = 0  -- 密码
    self.input_password = self.Parent:getWidget(self.m_pWidget, _Widget.input_password);
    self.input_password:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    self.input_password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.input_password:registerScriptEditBoxHandler( function(eventname,sender) 
        if eventname == "ended" then
            self.Password = 0
            self.img_password_tips:setVisible(false)
            if self.input_password:getText() == "" then return end
            if ComFun.isPassword(self.input_password:getText()) then
                self.Password =  self.input_password:getText()
                self.img_password_tips:setVisible(false)
            else
                ComFun.ShowNodeBigAction(self.img_password_tips)
            end
        elseif eventname == "began" then
            -- if self.Password ~= 0 then
            --     self.input_password:setText(string.rep("*",string.len(tostring(self.Password)))) -- 设置输入框内的值
            -- end
            self.input_password:setText("")
            self.Password = 0;  -- 验证码是短信发送需要玩家输入的
        end
    end)
end

-- 按钮点击回调
function ByPhoneLogin:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget:getName() == _Widget.btn_getpassword then  -- 找回密码
            self.Parent.loginPanel:setVisible(false)  -- 设置自身隐藏
            self.Parent.getpassword:setVisible(true)   -- 设置显示密码界面
        elseif pWidget:getName() == _Widget.btn_phone_regist2 then  -- 
            self.Parent:showRegist()
        elseif pWidget:getName() == _Widget.remain then  -- 
            if not pWidget:isSelected() then
                cc.UserDefault:getInstance():setStringForKey("remainPassword","1")
            else
                cc.UserDefault:getInstance():setStringForKey("remainPassword","0")
            end
            self.isRemain = not pWidget:isSelected()
        elseif pWidget:getName() == _Widget.btn_phone_login then  -- 
            if self.PhoneNum == 0 then
                Toast.getInstance():show("请输入正确的手机号")
            elseif self.Password == 0 then
                Toast.getInstance():show("请输入符合规则的密码")
            else
                -- Toast.getInstance():show("发送请求登陆消息")
                -- self:loginAccount()
                Log.d("发送请求登陆消息")
                local HallLogin = UIManager.getInstance():getWnd(HallLogin)
                if HallLogin then
                    HallLogin:onLoginGetWhiteLists(handler(self, self.loginAccount))
                end
            end
        end
    end
end

-- 登陆账号
function ByPhoneLogin:loginAccount()
    local data = LoginInfo.initLoginData()
    data.phN = self.PhoneNum
    data.pa = crypto.md5(self.Password)
    Log.i("------Accmd5 : " .. data.pa  .. " nor : " ..  self.Password)
    data.LoT = AccountStatus.PhoneLogin
    kLoginInfo:clearUserData()
    if self.isRemain then 
        ComFun.setPassword(self.Password)
    else
        ComFun.setPassword(self.Password, true)
    end
    Log.i("----------------------loginAccount :",data)
    return SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEND_LOGIN, data);
end

return ByPhoneLogin