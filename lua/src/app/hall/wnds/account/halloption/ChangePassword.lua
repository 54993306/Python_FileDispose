-----------------------------------------------------------
--  @file   ChangePassword.lua
--  @brief  修改密码界面
--  @author At.Lin
--  @DateTime:2018-07-06 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local ChangePassword = class("ChangePassword")
local ComFun = require("app.hall.wnds.account.AccountComFun")
local AccountStatus = require "app.hall.wnds.account.AccountStatus"
local crypto = require "app.framework.crypto"

local _Widget = {
    change_pw           = "change_pw",          -- 更改密码界面
    input_oldpw         = "input_oldpw",        -- 更改密码界面，旧密码输入框
    img_old_tips        = "img_old_tips",       -- 更改密码界面，旧密码提示框
    input_new1          = "input_new1",         -- 更改密码界面，新密码输入框
    img_new1_tips       = "img_new1_tips",      -- 更改密码界面，新密码提示框
    input_new2          = "input_new2",         -- 更改密码界面，确认密码输入框
    img_new2_tips       = "img_new2_tips",      -- 更改密码界面，确认密码提示框
    btn_set_sure        = "btn_set_sure",       -- 更改密码界面，确认修改按钮
}

-- 构造函数
function ChangePassword:ctor(parent)
    self.Parent = parent -- 持有父节点的对象

    self.m_pWidget = parent.m_pWidget -- 父节点

    self.img_old_tips = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_old_tips)
    self.img_old_tips:setVisible(false)

    self.img_new1_tips = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_new1_tips)
    self.img_new1_tips:setVisible(false)

    self.img_new2_tips = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.img_new2_tips)
    self.img_new2_tips:setVisible(false)

    self.btn_set_sure = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_set_sure)
    self.btn_set_sure:addTouchEventListener(handler(self, self.onClickButton))

    self:initInput()

    if AccountStatus.TEST then
        self:test()
    end
end

function ChangePassword:test()
    
end

-- 初始化输入框
function ChangePassword:initInput()
    self.oldPassword = 0   -- 旧密码
    self.input_oldpw = self.Parent:getWidget(self.m_pWidget, _Widget.input_oldpw);
    self.input_oldpw:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    self.input_oldpw:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.input_oldpw:registerScriptEditBoxHandler( function(eventname,sender) 
        if eventname == "ended" then
            self.oldPassword = 0
            self.img_old_tips:setVisible(false)
            if self.input_oldpw:getText() == "" then return end
            if ComFun.isPassword(self.input_oldpw:getText()) then
                self.oldPassword = self.input_oldpw:getText()
            else
                ComFun.ShowNodeBigAction(self.img_old_tips)
            end
        end
    end)

    self.Password1 = 0   -- 新密码
    self.input_new1 = self.Parent:getWidget(self.m_pWidget, _Widget.input_new1);
    self.input_new1:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    self.input_new1:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.input_new1:registerScriptEditBoxHandler( function(eventname,sender) 
        if eventname == "ended" then
            self.Password1 = 0
            self.img_new1_tips:setVisible(false)
            if self.input_new1:getText() == "" then return end
            if ComFun.isPassword(self.input_new1:getText()) then
                self.Password1 = self.input_new1:getText()
                if self.input_new2:getText() == self.input_new1:getText() then
                    self.img_new2_tips:setVisible(false)
                    self.Password2 = self.Password1
                end
            else
                ComFun.ShowNodeBigAction(self.img_new1_tips)
            end
        end
    end)

    self.Password2 = 0   -- 确认密码
    self.input_new2 = self.Parent:getWidget(self.m_pWidget, _Widget.input_new2);
    self.input_new2:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    self.input_new2:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.input_new2:registerScriptEditBoxHandler( function(eventname,sender) 
        if eventname == "ended" then
            local ps = self.input_new2:getText()
            self.Password2 = 0
            self.img_new2_tips:setVisible(false)
            if ps == "" or self.input_new1:getText() == "" then return end
            if ComFun.isPassword(ps) and self.Password1 == ps then
                self.Password2 = ps -- 验证两次输入的密码一致后才设置密码
            else
                ComFun.ShowNodeBigAction(self.img_new2_tips)
            end
        end
    end)
end

-- 按钮点击回调
function ChangePassword:onClickButton(pWidget, EventType)
    if EventType ~= ccui.TouchEventType.ended then return end
    if pWidget:getName() == _Widget.btn_set_sure then  -- 确认修改
        if self.oldPassword == 0 then
            Toast.getInstance():show("请输入旧密码")
            return
        elseif self.Password1 == 0 then
            Toast.getInstance():show("请输入符合规则的密码")
            return
        elseif self.Password2 == 0 then
            if self.input_new2:getText() ~= "" then
                Toast.getInstance():show("新密码与确认密码不一致")
            else
                Toast.getInstance():show("请输入确认密码")
            end
            return
        elseif self.oldPassword == self.Password1 then
            Toast.getInstance():show("新密码与旧密码相同")
            return
        elseif self.Password1 ~= self.Password2 then
            Toast.getInstance():show("新密码与确认密码不一致")
            return
        end
        local data = {}
        data.olP = crypto.md5(self.oldPassword)
        data.neP = crypto.md5(self.Password1)
        data.neP0 = crypto.md5(self.Password2)
        Log.i("------Accmd5 : " .. data.olP  .. " oldnor : " ..  self.oldPassword)
        Log.i("------Accmd5 : " .. data.neP  .. " nor : " ..  self.Password1)
        SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEN_CHANGE_PASSWORD, data)
    else
        Log.e()
    end
end

return ChangePassword