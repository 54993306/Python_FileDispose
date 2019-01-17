-----------------------------------------------------------
--  @file   phoneRegistPanel.lua
--  @brief  注册账号界面
--  @author At.Lin
--  @DateTime:2018-07-03 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local phoneRegistPanel = class("phoneRegistPanel")
local ComFun = require("app.hall.wnds.account.AccountComFun")
local BindWechat = require("app.hall.wnds.account.AccountBindWechat")
local LocalEvent = require "app.hall.common.LocalEvent"
local AccountStatus = require "app.hall.wnds.account.AccountStatus"
-- 控件名称声明
local _Widget = {
    regist              = "regist",             -- 注册界面
    input_phone         = "input_phone",        -- 注册界面，手机号输入框
    img_phone_tips      = "img_phone_tips",     -- 注册界面，手机号提示框
    input_verift        = "input_verift",       -- 注册界面，验证码输入框
    img_verify_tips     = "img_verify_tips",    -- 注册界面，验证码提示框
    btn_verity          = "btn_verity",         -- 注册界面，获取验证码按钮
    btn_binding         = "btn_binding",        -- 注册界面，绑定微信按钮
    btn_regist          = "btn_regist",         -- 注册界面，注册按钮
    lab_regist_verify   = "lab_regist_verify",  -- 注册界面，验证码倒计时
    Image_bind1         = "Image_bind1",        -- 注册界面，绑定微信图
    Image_bind2         = "Image_bind2",        -- 注册界面，绑定成功图
}
if IsPortrait then -- TODO
    _Widget.red_dot             = "red_dot"            -- 微信绑定上的星号
    _Widget.img_phone_tips      = "img_phone_tip"     -- 注册界面，手机号提示框
end

function phoneRegistPanel:dtor()
    self:removeListen()
end

-- 添加事件监听
function phoneRegistPanel:initEventListen()
    self.Events = {}
    local listenBindState = cc.EventListenerCustom:create(LocalEvent.BindWechatSucceed,function(event)
        local data = {}
        data.apI = WX_APP_ID
        data.opI = WX_OPENID
        SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEN_BINDWECHAT, data)
        if AccountStatus.TEST then
            Toast.getInstance():show("返回成功微信名 : " .. event._userdata.nickname);
        end
    end)
    table.insert(self.Events, listenBindState);
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listenBindState , 1);
end

-- 移除事件监听
function phoneRegistPanel:removeListen()
    table.walk(self.Events , function(event)
        cc.Director:getInstance():getEventDispatcher():removeEventListener(event)
    end)
    self.Events = {}
end

-- 构造函数
function phoneRegistPanel:ctor(parent)
    self.Parent = parent -- 持有父节点的对象

    self.m_pWidget = parent.m_pWidget -- 父节点

    self.bindState = false -- 是否绑定微信

    self.verifystatus = false -- 是否为获取验证码状态

    self.delaytiem = ComFun.getVerifyDelayTime()    -- 验证码等待时间

    self:initWidget()

    self:initInput()

    self:initEventListen()

    if AccountStatus.TEST then
        self:test()
    end
end

-- 测试手机号
function phoneRegistPanel:test()
    self.input_phone:setText("17776918882") -- 设置输入框内的值
    self.PhoneNum = 17776918882;  -- 验证码是短信发送需要玩家输入的

    self.input_verift:setText("123456") -- 设置输入框内的值
    self.verifyNum = 123456;  -- 验证码是短信发送需要玩家输入的
end

-- 获取控件对象
function phoneRegistPanel:initWidget()
    self.Image_bind1 = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.Image_bind1)
    self.Image_bind2 = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.Image_bind2)

    self.img_phone_tips = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_phone_tips)
    self.img_phone_tips:setVisible(false)

    self.img_verify_tips = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_verify_tips)
    self.img_verify_tips:setVisible(false)

    self.btn_verify = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_verity)
    self.btn_verify:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_binding = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_binding)
    self.btn_binding:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_regist = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_regist)
    self.btn_regist:addTouchEventListener(handler(self, self.onClickButton))

    self.lab_regist_verify = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.lab_regist_verify)
    if IsPortrait then -- TODO
        self.red_dot = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.red_dot)
    end
end

-- 初始化输入框
function phoneRegistPanel:initInput()
    self.PhoneNum = 0   -- 手机号
    self.input_phone = self.Parent:getWidget(self.m_pWidget, _Widget.input_phone);
    self.input_phone:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self.input_phone:registerScriptEditBoxHandler( function(eventname,sender)
        if eventname == "ended" then
            self.PhoneNum = 0
            self.img_phone_tips:setVisible(false)
            if self.input_phone:getText() == "" then return end
            if ComFun.isPhoneNumber(self.input_phone:getText()) then
                self.PhoneNum =  self.input_phone:getText()
            else
                ComFun.ShowNodeBigAction(self.img_phone_tips)
            end
        end
    end)

    self.verifyNum = 0  -- 验证码
    self.input_verift = self.Parent:getWidget(self.m_pWidget, _Widget.input_verift);
    self.input_verift:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    self.input_verift:registerScriptEditBoxHandler( function(eventname,sender)
        if eventname == "ended" then
            self.img_verify_tips:setVisible(false)
            self.verifyNum = 0
            if self.input_verift:getText() == "" then return end
            if ComFun.isVerifyCode(self.input_verift:getText() , 6) then
                self.verifyNum =  self.input_verift:getText()
            else
                ComFun.ShowNodeBigAction(self.img_verify_tips)
            end
        end
    end)
end

-- 微信绑定成功
function phoneRegistPanel:wechatBindSucceed()
    LoadingView.getInstance():hide();
    self.bindState = true;
    self.btn_binding:setBright(false)
    self.btn_binding:setTouchEnabled(false)
    if IsPortrait then -- TODO
        self.red_dot:setVisible(false)
    end
    self.Image_bind1:setVisible(false)
    self.Image_bind2:setVisible(true)
    Toast.getInstance():show("微信绑定成功");

    if type(self.m_data) == "table" and self.m_data.type == AccountStatus.HongBao then
        local data = {}
        data = self.m_data
        data.type = 2
        local BindSuccessful = require("app.hall.wnds.mall.BindSuccessful")
        UIManager:getInstance():pushWnd(BindSuccessful,data)
    end
end

-- 获取注册的账号信息
function phoneRegistPanel:getPhoneAndVerify()
    local data = {}
    data.phone = self.PhoneNum
    data.verify = self.verifyNum
    return data
end

-- 校验验证码是否正确
function phoneRegistPanel:sendCheckVerify()
    local data = {}
    data.phN = self.PhoneNum
    data.phC = self.verifyNum
    data.seC = AccountStatus.VerifyCheckRegist
    SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEN_CODEVERIFY, data)
end

-- 点击注册按钮处理
function phoneRegistPanel:registCallBack()
    if self.PhoneNum == 0 then
        Toast.getInstance():show("请输入正确的手机号");
    elseif self.verifyNum == 0 then
        Toast.getInstance():show("请输入验证码");
    elseif not self.bindState then
        Toast.getInstance():show("尚未绑定微信");
    else
        self:sendCheckVerify()
    end
end

-- 按钮点击回调
function phoneRegistPanel:onClickButton(pWidget, EventType)
    if EventType ~= ccui.TouchEventType.ended then
        return
    end

    if pWidget:getName() == _Widget.btn_verity then  -- 获取验证码
        if self.PhoneNum == 0 then
            Toast.getInstance():show("请输入正确的手机号");
            return
        elseif self.verifystatus then
            Toast.getInstance():show(self.delaytiem.."秒后再次获取验证码");
            return
        end
        local data = {}
        data.phN = self.PhoneNum
        data.seC = AccountStatus.VerifyRegist
        SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEN_VERIFY, data)
    elseif pWidget:getName() == _Widget.btn_binding then -- 点击绑定微信按钮
        LoadingView.getInstance():show("绑定微信中...");
        if AccountStatus.TEST then
            local data = {}
            data.apI = "wxa8df3c15b8a1c7df"
            data.opI = "2"
            SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEN_BINDWECHAT, data)
        else
            BindWechat.Bind()
        end
    elseif pWidget:getName() == _Widget.btn_regist then
        self:registCallBack()
    else
        Log.e();
    end
end

-- 刷新验证码倒计时
function phoneRegistPanel:updateVerifyTime()
    self.verifystatus = true
    local updatedelay = cc.CallFunc:create(function()
        self.delaytiem = self.delaytiem - 1;
        if self.delaytiem == 0 then
            self.lab_regist_verify:stopAllActions()
            self.delaytiem = ComFun.getVerifyDelayTime();
            self.lab_regist_verify:setString("获取验证码")
            if IsPortrait then -- TODO
                self.lab_regist_verify:setFontSize(33)
            end
            self.verifystatus = false
            if device.platform ~= "ios" and device.platform ~= "android" then
                -- self:verifyBack()  -- 测试
            end
        else
            if IsPortrait then -- TODO
                self.lab_regist_verify:setString(self.delaytiem)
            else
                self.lab_regist_verify:setString(self.delaytiem.."秒后再次获取")
                self.lab_regist_verify:setFontSize(21)
            end
        end
    end)
    self.lab_regist_verify:runAction(cc.RepeatForever:create(cc.Sequence:create(updatedelay,cc.DelayTime:create(1))))
end

return phoneRegistPanel
