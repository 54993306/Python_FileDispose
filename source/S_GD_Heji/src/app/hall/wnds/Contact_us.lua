-----------------------------------------------------------
--  @file   Contact_us.lua
--  @brief  联系我们类
--  @author linxiancheng
--  @DateTime:2017-04-6 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

Contact_us = class("Contact_us", UIWndBase)

local LocalEvent = require("app.hall.common.LocalEvent")
local UmengClickEvent = require("app.common.UmengClickEvent")

function Contact_us:ctor(...)
    self.super.ctor(self, "hall/contact_us.csb", ...)
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    self.Events = {}
    self.m_data = self.m_data or {}
end

function Contact_us:onInit()
    if IsPortrait then -- TODO
        local UITool = require("app.common.UITool")
        UITool.setTitleStyle(ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_title"))
    else
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_openWx = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_weixin")
    self.btn_openWx:addTouchEventListener(handler(self, self.onClickButton));

    self.lis_txt = ccui.Helper:seekWidgetByName(self.m_pWidget, "ItemList");
    self.lis_txt:setVisible(true)

    self.img_kfTip = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_kfRedPoint");
    self.img_kfTip:setVisible(false)

    self.lab_title = ccui.Helper:seekWidgetByName(self.m_pWidget, "title")
    if self.m_data.title and self.m_data.title ~= "" then
        self.lab_title:setString(self.m_data.title)
    end

    local listener = cc.EventListenerCustom:create(LocalEvent.HallCustomerService, handler(self, self.getKeFuHongDian))
    table.insert(self.Events,listener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

    if self.m_data.type == 1 then
        self.lis_txt:removeAllItems()
    else
        local btn = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_kefu")
        if Util.debug_shield_value("kefu") then
            btn:setVisible(false)
         end
        btn:addTouchEventListener(handler(self, self.onOpenKf));
    end

    
    self.item = {}
    self:updateList()
end


function Contact_us:updateList(data)

    if #self.item > 0 then
        for k,v in pairs(self.item) do
            self.lis_txt:removeChild(v,true)
        end 
        self.item = {}
    end 

    local mItem = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/contact_item.csb");

    local content_str = kUserData_userExtInfo:getDiamoundWechatID()
    local contentTab = data or (content_str and content_str.content)
  
    if contentTab then
        for k, v in pairs(contentTab) do
            if v ~= "" then
                local item = mItem:clone();
                self.item[#self.item + 1] = item
                self.lis_txt:insertCustomItem(item, k-1);
                --创建两段label，超出某个长度则在它的下方添加，否则在尾部添加
                local btn_copy = ccui.Helper:seekWidgetByName(item, "Button_copy");
                if Util.debug_shield_value("kefu") then
                    btn_copy:setVisible(false)
                end
                btn_copy:addTouchEventListener(handler(self, self.copyBtnBack));
                btn_copy:setTag(k)
                local itemTab = string.split(v,"##");
                local str
                if #itemTab <= 1 then
                    str = v
                    btn_copy.data = v
                else
                    str = itemTab[1]..itemTab[2];
                    btn_copy.data = string.trim(itemTab[2])--动态语言随时存，存了就能取
                end
                local haveGongZhongHao = string.find(str, "公众号")
                if haveGongZhongHao ~= nil then
                    btn_copy.haveGongZhongHao = true
                else
                    btn_copy.haveGongZhongHao = false
                end
                local haveDaiLi = string.find(str, "代理")
                if haveDaiLi ~= nil then
                    btn_copy.haveDaiLi = true
                else
                    btn_copy.haveDaiLi = false
                end

                local title = ccui.Helper:seekWidgetByName(item, "title");
                self:DynamicLabel(title,str)
            end
        end
    end
end

function Contact_us:onClose()
    table.walk(self.Events,function(event)
        cc.Director:getInstance():getEventDispatcher():removeEventListener(event)
    end)
    self.Events = {}
end

function Contact_us:setKfRed(visible)
    if not tolua.isnull(self.img_kfTip) then
        self.img_kfTip:setVisible(visible or false)
    end
end

function Contact_us:getKeFuHongDian(event)
    local hongdianNum = math.floor(tonumber(event._userdata.count))
    if not tolua.isnull(self.img_kfTip) then
        if hongdianNum > 0 then
            self.img_kfTip:setVisible(true)
            --hongdian2:setVisible(true)
        else
            self.img_kfTip:setVisible(false)
            --hongdian2:setVisible(false)
        end
    end
end

function Contact_us:DynamicLabel(node,str)
    -- str = "了肯德基爱丽丝肯德基阿斯达搜啊交换机狂欢节啊交换机狂欢节啊交换交换机狂欢节啊交换机狂欢节了肯德基爱丽丝肯德基阿斯达搜"
    node:setString(str)
    --[[
    node:setVisible(false)
    local textSize = 22
    local params = {}
    params.text = str or "暂无信息"
    params.font = "res_TTF/1016001.TTF"
    params.size = textSize
    params.align =  cc.TEXT_ALIGNMENT_CENTER
    params.valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    params.color = cc.c3b(43,76,1)              --cc.c3b
    local lenth = ToolKit.widthSingle(params.text)
    local tDynamicLabel = display.newTTFLabel(params)
    local tMaxLength = 22
    if lenth < tMaxLength then
        tDynamicLabel:setDimensions(lenth*textSize,textSize+20)
    else
        local texLen = math.ceil(lenth/tMaxLength)
        tDynamicLabel:setDimensions(tMaxLength*textSize,(textSize+10)*texLen)
    end
    local contentSize = tDynamicLabel:getContentSize()
    tDynamicLabel:setPosition(node:getPosition())
    node:getParent():addChild(tDynamicLabel)]]
end

function Contact_us:copyBtnBack(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        local data = {}
        data.cmd = NativeCall.CMD_CLIPBOARD_COPY;
        data.content = string.format("%s",pWidget.data)--
        Log.i("-----copy code----->" .. pWidget.data)
        NativeCall.getInstance():callNative(data);
        Toast.getInstance():show("复制信息成功");
        local tag = pWidget:getTag()
        if tag== 1 then
            Log.i("--wangzhi--MoreKeFuGongZhongHaoCopy")
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.MoreKeFuGongZhongHaoCopy)
        elseif tag== 2 then
            Log.i("--wangzhi--MoreKeFuDaiLiCopy")
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.MoreKeFuDaiLiCopy)
        end
    end
end

function Contact_us:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_close then
            self:keyBack()
        elseif pWidget == self.btn_openWx then            
            TouchCaptureView.getInstance():showWithTime()
            if IsPortrait and device.platform == "ios" then -- TODO
                device.openURL("weixin://")
            else
                local data = {}
                data.cmd = NativeCall.CMD_OPEN_WEIXIN
                NativeCall.getInstance():callNative(data, function(info)
                    if info.errCode and info.errCode == -1 then
                        Toast.getInstance():show("您未安装微信或版本过低,请安装微信或升级后重试～");
                    end
                end);
            end
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.MoreOpenWeChatButton)
        end
    end
end

function Contact_us:onOpenKf(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        local event = cc.EventCustom:new(LocalEvent.HallCustomerService)
        event._userdata = {count = 0}
        cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

        local data = {};
        data.cmd = NativeCall.CMD_KE_FU;
        data.uid, data.uname = self.getKfUserInfo()
        NativeCall.getInstance():callNative(data, self.openKeFuCallBack, self);
        NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.MoreKeFuOnline)
    end
end

function Contact_us:getKfUserInfo()
    local uid = kUserInfo:getUserId();
    local uname = kUserInfo:getUserName();
    if uid == 0 then
        local lastAccount = kLoginInfo:getLastAccount();
        if lastAccount and lastAccount.usi then
            uid = lastAccount.usi
        end
    end

    if uname == "" or uname == nil then        
        if uid == nil or uid == 0 then
            uname = "游客"
        else
            uname = "游客"..uid
        end
    end

    --此时uid需要传入字符串类型.否则ios那边解析会出问题.
    return ""..uid, uname
end

function Contact_us:openKeFuCallBack(info)
    Log.i("openKeFuCallBack info", info);
    if info.errCode == 1 then
        -- Toast.getInstance():show("连接在线客服成功");
    else
        Toast.getInstance():show("无法连接在线客服");
    end
end


function Contact_us:keyBack()
    UIManager:getInstance():popWnd(Contact_us)
end