--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2019-01-11 14:17:19
]]

local RichLabel = require("app.hall.common.RichLabel")
local HallBindPhone = require "app.hall.wnds.account.halloption.HallBindPhone"
local BindPhone = require "app.hall.wnds.account.halloption.BindPhone"
local AccountStatus = require "app.hall.wnds.account.AccountStatus"
local BindSuccessful = require("app.hall.wnds.mall.BindSuccessful")
local ComFun = require("app.hall.wnds.account.AccountComFun")

local ConversionDialog = class("ConversionDialog",UIWndBase)

function ConversionDialog:ctor(data)
    self.super.ctor(self, "hall/conversion_dialog.csb",data)
end

function ConversionDialog:onInit()
    self.txt_content = ccui.Helper:seekWidgetByName(self.m_pWidget,"txt_content")
    self:setContentString()

    self.btn_yes = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_yes")
    self.btn_yes:addTouchEventListener(handler(self, self.onBtnCallBack));

    self.btn_cancal = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_cancal")
    self.btn_cancal:addTouchEventListener(handler(self,self.onBtnCallBack))

    self.btn_return = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_return")
    self.btn_return:addTouchEventListener(handler(self,self.onBtnCallBack))
end

function ConversionDialog:setContentString()
   
    local number = string.format( "%s个元宝兑换",self.m_data.coN) 
    local showData = json.decode(self.m_data.na0) or {}
    local contF = showData.title
    local contL = showData.content
    local contentData = ""
    if contL ~= nil then
        contentData = string.format( "随机%s",contL )
    else
        contentData = self.m_data.na0
    end
    local content = string.format( "是否确认消耗%s%s",number,contentData)
    self.txt_content:setString(content)
   
end

function ConversionDialog:onBtnCallBack(pWidget, EventType)
    -- body
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_yes then
            self:bindPhone()
        elseif pWidget == self.btn_cancal or pWidget == self.btn_return then
            UIManager.getInstance():popWnd(ConversionDialog)
        end
    end

end

function ConversionDialog:bindPhone()
    -- body
    local data = kGiftData_logicInfo:getTaskByID(AccountStatus.PhoneTaskID)
    UIManager.getInstance():popWnd(ConversionDialog)
    if not data or next(data) == nil or (data.status == AccountStatus.TaskUnDeal and ComFun.getPhone() == "0") then
        Log.d("task is nil")
        data = self.m_data
        data.type = AccountStatus.HongBao
        UIManager:getInstance():pushWnd(BindPhone,data)
        return
    end
    data = self.m_data
    data.type = 2
    UIManager:getInstance():pushWnd(BindSuccessful,data)
end

return ConversionDialog