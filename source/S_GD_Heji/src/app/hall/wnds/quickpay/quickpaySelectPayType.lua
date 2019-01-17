    -----------------------------------------------------------
--  @file   quickpayment.lua
--  @brief  快捷支付
--  @author wy
--  @DateTime:2017-6-6
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local quickpaySelectPayType = class("quickpaySelectPayType", UIWndBase)

local widgetSeekInfo = 
{
    labPrice = "lab_price",
    labGoodDesc = "lab_good",
    btnWx = "btn_wx",
    btnZfb = "btn_zfb",
    btnReturn = "btn_return",
    panelGoodBg = "panel_goodBg",
}

function quickpaySelectPayType:ctor(...)
    self.super.ctor(self, "hall/pay_select_type.csb", ...)
    self.baseShowType = UIWndBase.BaseShowType.RTOL
end

function quickpaySelectPayType:onInit()
    --m_data = {sellNum = v.go, giveNum = v.pr, price = v.pa, Id = v.Id}
    --获取商品列表
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end

    for k,v in pairs(widgetSeekInfo) do
        self[k] = ccui.Helper:seekWidgetByName(self.m_pWidget, v);
    end

    self.btnReturn:addTouchEventListener(handler(self, self.onClickButton));
    self.btnWx:addTouchEventListener(handler(self, self.onClickButton));
    self.btnZfb:addTouchEventListener(handler(self, self.onClickButton));

    self.labGoodDesc:setString("钻石x"..self.m_data.sellNum)
    self.labPrice:setString(string.format("%0.2f", self.m_data.price))

    if device.platform == "ios" then
        self.btnZfb:setVisible(false)
        if IsPortrait then -- TODO
            self.btnWx:getLayoutParameter():setMargin({ left = display.cx-self.btnWx:getContentSize().width/2})
        else
            self.btnWx:getLayoutParameter():setMargin({top =self.btnWx:getLayoutParameter():getMargin().top, right = display.cx-self.btnWx:getContentSize().width/2})
        end
    else
        if Util.debug_shield_value("weixin") then
            self.btnWx:setVisible(false)
            
            if IsPortrait then -- TODO
                self.btnZfb:getLayoutParameter():setMargin({ left = display.cx-40-self.btnZfb:getContentSize().width/2})
            else
                local originMargin_start = self.panelGoodBg:getLayoutParameter():getMargin()
                originMargin_start.top = originMargin_start.top + self.btnZfb:getContentSize().height/2 - 30
                self.btnZfb:getLayoutParameter():setMargin({ left = display.cx - self.btnZfb:getContentSize().width/2, right = 0, top = originMargin_start.top, bottom = 0})
            end
            -- self.btnZfb:getLayoutParameter():setMargin({ left = display.cx-40-self.btnZfb:getContentSize().width/2})
        end
    end
end

-- 做兼容模式判断
function quickpaySelectPayType:notCompatible()
    if device.platform == "ios" then
        if not COMPATIBLE_VERSION or tonumber(COMPATIBLE_VERSION) < 1 then
            self:keyBack()
            local data = {}
            data.type = 2
            data.content = "您需要安装新版本才能使用此功能！请联系客服获取最新下载地址！"
            data.yesCallback = function()
                local data1 = {};
                data1.cmd = NativeCall.CMD_KE_FU;
                data1.uid, data.uname = kUserInfo:getKfUserInfo()
                NativeCall.getInstance():callNative(data1, function()end);
                NativeCallUmengEvent(UmengClickEvent.MoreKeFuOnline)
            end

            data.cancalCallback = function()
            end

            data.closeCallback = function()
            end

            data.yesStr = "联系客服"                               --确定按钮文本
            data.cancalStr = "取消"                            --取消按钮文本
            UIManager:getInstance():pushWnd(CommonDialog, data)

            return true
        end
    end
    return false
end

function quickpaySelectPayType:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btnReturn then
            UIManager:getInstance():popWnd(quickpaySelectPayType)
        elseif pWidget == self.btnWx then
            if self:notCompatible() then
                return
            end
            local data = {};
            -- data.gaI = kChargeListInfo:getGameId();
            -- data.roI = kChargeListInfo:getRoomId();
            data.stI = self.m_data.Id;
            data.paP = 2;
            data.paW = kChargeListInfo:getChargePath();

            LoadingView.getInstance():show("正在生成订单,请稍后...");
            SocketManager.getInstance():send(CODE_TYPE_CHARGE, HallSocketCmd.CODE_SEND_GETORDER, data);
        elseif pWidget == self.btnZfb then
            local data = {};
            data.stI = self.m_data.Id;
            data.paP = 1;
            data.paW = kChargeListInfo:getChargePath();

            LoadingView.getInstance():show("正在生成订单,请稍后...");
            SocketManager.getInstance():send(CODE_TYPE_CHARGE, HallSocketCmd.CODE_SEND_GETORDER, data);
        end
    end
end

return quickpaySelectPayType