-----------------------------------------------------------
--  @file   clibtips.lua
--  @brief  亲友圈
--  @author linxiancheng
--  @DateTime:2017-07-31 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================


local ClubTips = class("ClubTips", UIWndBase)

function ClubTips:ctor(...)
    self.super.ctor(self,"hall/clubApplyConfirmWnd.csb",...)
end

local function btnCallBack(self, widget, touchType)
    if touchType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if widget:getName() == "btn_close" then
            self:keyBack()
        elseif widget:getName() == "btn_cancle" then
            self:keyBack()
        elseif widget:getName() == "btn_sure" then
            if self.m_data.type == 1 then
                SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_QUITCLUB, {clI = self.m_data.clI or self.m_data.clubID})
            else
                SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_JOINCLUB, {clI = self.m_data.clI or self.m_data.clubID})
            end
            LoadingView.getInstance():show("信息发送中...")
        end
    end
end

function ClubTips:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
        local lab_title = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_title")
        lab_title:setString("提示")
    end

    local lab_name = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_name")
    local clubName = self.m_data.clN or self.m_data.clubName
    local formatStr = "您申请加入:%s"
    if self.m_data.type == 1 then formatStr = "您申请退出:%s" end
    if IsPortrait then -- TODO
        formatStr = ToolKit.subUtfStrByCn(string.format(formatStr,clubName), 0, 15, "...")
        Util.updateNickName(lab_name, formatStr)
    else
        Util.updateNickName(lab_name, string.format(formatStr,clubName))
    end

    local lab_id = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_id")
    lab_id:setString(string.format("亲友圈ID:%d",self.m_data.clI or self.m_data.clubID or 0))

    local lab_owner = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_owner")
    local ownerName = ToolKit.subUtfStrByCn(self.m_data.clC or self.m_data.clubName or "", 0, 9, "...")
    Util.updateNickName(lab_owner, string.format("创建者:%s",ownerName))

    local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close")
    btn_close:addTouchEventListener(handler(self,btnCallBack))

    local btn_cancle = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_cancle")
    btn_cancle:addTouchEventListener(handler(self,btnCallBack))

    local btn_sure = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_sure")
    if IsPortrait then -- TODO
        local Image_applyJoin = ccui.Helper:seekWidgetByName(btn_sure, "Image_applyJoin")
        local Img_applyQuit = ccui.Helper:seekWidgetByName(btn_sure, "Img_applyQuit")
        if self.m_data.type == 1 then
            if Image_applyJoin then Image_applyJoin:setVisible(false) end
            if Img_applyQuit then
                Img_applyQuit:setVisible(true)
                btn_sure:setTitleText("")
            else
                btn_sure:setTitleText("退出亲友圈")
            end

        else
            if Image_applyJoin then
                Image_applyJoin:setVisible(true)
                btn_sure:setTitleText("")
            else
                btn_sure:setTitleText("加入亲友圈")
            end
            if Img_applyQuit then Img_applyQuit:setVisible(false) end
        end
    else
        if self.m_data.type == 1 then
            btn_sure:setTitleText("退出亲友圈")
        else
            btn_sure:setTitleText("加入亲友圈")
        end
    end
    btn_sure:addTouchEventListener(handler(self,btnCallBack))
end

return ClubTips