    -----------------------------------------------------------
--  @file   quickpayment.lua
--  @brief  快捷支付
--  @author wy
--  @DateTime:2017-6-6
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local ChargeIdTool = require("app.PayConfig")
local quickpaySelectPayType = require("app.hall.wnds.quickpay.quickpaySelectPayType")
local UmengClickEvent = require("app.common.UmengClickEvent")

quickpayment = class("quickpayment", UIWndBase)

local diamound_num_to_img = {
    [1] = "diamond_L.png",
    [2] = "diamond_XL.png",
    [3] = "diamond_XXL.png",
}

function quickpayment:ctor()
    self.super.ctor(self, "hall/quickpayment.csb")
    self.baseShowType = UIWndBase.BaseShowType.RTOL
end

function quickpayment:getChargeListData()
    local chargeList = {}
    local daList = kChargeListInfo:getChargeList();

    if device.platform == "ios" then
        if G_LOCAL_IOS_CHARGE_FOR_AUDIT then
            daList = IosLocalRechargeData
        end
        for k,v in pairs(daList) do
            chargeList[#chargeList+1] = {sellNum = v.go, giveNum = v.pr, price = v.pa, Id = v.stI}
        end
    else
        for k,v in pairs(daList) do
            chargeList[#chargeList+1] = {sellNum = v.go, giveNum = v.pr, price = v.pa, Id = v.stI}
        end
    end
    return chargeList
end

function quickpayment:onInit()
    --获取商品列表
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    kChargeListInfo:setChargeEnvironment(RECHARGE_PATH_STORE, 0, 0); --暂时用商城充值（更多充值）
    local daList = self:getChargeListData();
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));
    self.panel = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel")
    self.listView = ccui.Helper:seekWidgetByName(self.m_pWidget,"listview")

    self.pan_agent = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_agent")
    if IS_YINGYONGBAO or not kLoginInfo:getIsReview() then
        if self.pan_agent then
            self.pan_agent:setVisible(false)
            self.pan_agent:setContentSize(cc.size(self.pan_agent:getContentSize().width, 0))
        end
        self.listView:removeAllItems()
    else        
        self.btn_applyAgent = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_applyAgent")
        self.btn_applyAgent:addTouchEventListener(handler(self, self.onClickButton));
        if not IsPortrait then -- TODO
            self.listView:removeAllItems()
        end
    end

    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/quickpayitem.csb");

    for k,v in pairs(daList) do
        local item = itemModel:clone();
        -- item:setPosition(cc.p(210 + 210 * (i-1),193));
        self.listView:pushBackCustomItem(item)
        -- self.panel:addChild(item, 1);
        local showStr1 = "x"..tostring(v.sellNum)
        if not IsPortrait then -- TODO
            showStr1 = "钻石x"..tostring(v.sellNum)
        end
        local btn = ccui.Helper:seekWidgetByName(item,"btn_buy");
        local cnt = ccui.Helper:seekWidgetByName(item,"cnt")
        local cnt0 = ccui.Helper:seekWidgetByName(item,"cnt_0")
        if cnt then cnt:setString(showStr1) end
        if cnt0 then cnt0:setString(showStr1) end


        local diamond_img = ccui.Helper:seekWidgetByName(item,"Image_7")
        --diamond_img:setAnchorPoint(0.5,0)
        local img_tag = k
        if img_tag > 3 then
            img_tag = 3
        end
        if diamound_num_to_img[img_tag] then
            diamond_img:loadTexture("hall/huanpi2/Common/"..diamound_num_to_img[img_tag])
            if IsPortrait then -- TODO
                diamond_img:setScale(0.6)
            end
        end
        
        local itemBg = ccui.Helper:seekWidgetByName(item, "panel_bg")
        local free = ccui.Helper:seekWidgetByName(item,"free")
        free:setString("送" .. tostring(v.giveNum) .. "钻石")
        if(v.giveNum == 0) then
            free:setVisible(false)
        end
        local price = ccui.Helper:seekWidgetByName(item,"price");
        price:setString(tostring(v.price) .. "元");
        btn:setTag(v.Id);
        self:addWidgetClickFunc(btn, function() self:requestBuy(v, k) end)
        self:addWidgetClickFunc(itemBg, function() self:requestBuy(v, k) end)
    end

end

function quickpayment:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_close then
            UIManager:getInstance():popWnd(quickpayment)
        elseif pWidget == self.btn_applyAgent then
            UIManager:getInstance():popWnd(quickpayment)
            UIManager.getInstance():pushWnd(Contact_us)
            if IsPortrait then -- TODO
                NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.ContractButton)
            end
        end
    end
end

function quickpayment:requestBuy(goodInfo, index)
    SoundManager.playEffect("btn");
    -- if device.platform == "ios" then
    --     local data = {};
    --     data.stI = goodInfo.Id;
    --     data.paP = 3;
    --     data.paW = kChargeListInfo:getChargePath();

    --     LoadingView.getInstance():show("正在生成订单,请稍后...");
    --     SocketManager.getInstance():send(CODE_TYPE_CHARGE, HallSocketCmd.CODE_SEND_GETORDER, data);
    -- else
        UIManager.getInstance():pushWnd(quickpaySelectPayType, goodInfo)
    -- end

    local UmengClickEventList = {
        UmengClickEvent.Charge12Button,
        UmengClickEvent.Charge30Button,
        UmengClickEvent.Charge98Button,
    }
    index = index > 3 and 3 or index
    NativeCall.getInstance():NativeCallUmengEvent(UmengClickEventList[index])
end

return quickpayment