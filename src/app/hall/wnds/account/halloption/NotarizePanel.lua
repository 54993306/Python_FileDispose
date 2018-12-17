-----------------------------------------------------------
--  @file   NotarizePanel.lua
--  @brief  确认信息界面
--  @author At.Lin
--  @DateTime:2018-07-06 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local NotarizePanel = class("NotarizePanel")
local ComFun = require("app.hall.wnds.account.AccountComFun")
local _Widget = {
    sure_bind           = "sure_bind",          -- 确认绑定面板
    lab_phonenum        = "lab_phonenum",       -- 确认绑定面板，手机号
    btn_sure2           = "btn_sure2",          -- 确认绑定面板，确定按钮
    btn_cancle_pho      = "btn_cancle_pho",     -- 确认绑定面板，取消按钮
}

-- 构造函数
function NotarizePanel:ctor(parent)
    self.Parent = parent -- 持有父节点的对象

    self.m_pWidget = parent.m_pWidget -- 父节点

    self.lab_phonenum = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.lab_phonenum) -- 手机号

    self.btn_sure2 = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_sure2)
    self.btn_sure2:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_cancle_pho = ccui.Helper:seekWidgetByName(self.m_pWidget, _Widget.btn_cancle_pho)
    self.btn_cancle_pho:addTouchEventListener(handler(self, self.onClickButton))

    self.data = nil
end

-- 按钮点击回调
function NotarizePanel:onClickButton(pWidget, EventType)
    if EventType ~= ccui.TouchEventType.ended then return end
    if pWidget:getName() == _Widget.btn_cancle_pho then  -- 获取验证码
        UIManager.getInstance():popWnd(self.Parent);
    elseif pWidget:getName() == _Widget.btn_sure2 then
        LoadingView.getInstance():show("手机号绑定中...")
        SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEN_BINDPHONE, self.data);
    else
        Log.e()
    end
end

-- 初始化绑定手机信息
function NotarizePanel:initNotarizeData(data)
    self.lab_phonenum:setString(ComFun.formatPhoneNumber(data.phN))
    self.data = data
end

return NotarizePanel