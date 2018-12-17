-------------------------------------------------------------
--  @file   SignalInfoNode.lua
--  @brief  信号信息节点
--  @author linxiancheng
--  @DateTime:2017-17-21 17:31:33
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
--============================================================
local LocalEvent = require("app.hall.common.LocalEvent")

local SignalInfoNode = class("SignalInfoNode", function() 
	local ret = display.newNode()
	return ret
end)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function SignalInfoNode:ctor()
	self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/infoNode.csb")
	self:addChild(self.m_pWidget)
    self.LocalEvent = {};
    self:listenerExit()
end

function SignalInfoNode:listenerExit()
    self.m_pWidget:addNodeEventListener(cc.NODE_EVENT, function (event)
        if event.name == "exit" then
            self:onExit()
        end
    end)
end

function SignalInfoNode:onExit()
    table.walk(self.LocalEvent,function(pListener) 
        cc.Director:getInstance():getEventDispatcher():removeEventListener(pListener)
    end)
    self.LocalEvent = {}
    -- print("--------------SignalInfoNodeonExit")
end

--[[
-- @brief  析构函数
-- @param  void
-- @return void
--]]
function SignalInfoNode:dctor()

end

--房间号
function SignalInfoNode:updateRoomId()
    self:initPayInfo()
    local room_Panel = self:getWidget(self.m_pWidget,"room_Panel")
    local room_id = cc.Label:createWithBMFont("hall/font/room_num.fnt", kFriendRoomInfo:getRoomInfo().pa)
    room_id:setPosition(cc.p(100,37))
    room_Panel:addChild(room_id)
end

-- 初始化付费信息
function SignalInfoNode:initPayInfo()
    local playerInfos = kFriendRoomInfo:getRoomInfo()
    local room_Panel = self:getWidget(self.m_pWidget,"room_Panel")
    local img_paytype = self:getWidget(room_Panel,"img_paytype")


    if playerInfos.clI ~= nil and playerInfos.clI > 0 then
        img_paytype:loadTexture("hall/Common/clubpay.png", ccui.TextureResType.localType)
    else
        if playerInfos.RoFS and playerInfos.plS then
            if playerInfos.RoJST == 1 then          --是否需要考虑写成可拓展可配置的？
                img_paytype:loadTexture("hall/Common/wonpay.png", ccui.TextureResType.localType)
            elseif playerInfos.RoJST == 2 then
                img_paytype:loadTexture("hall/Common/winpay.png", ccui.TextureResType.localType)
            elseif playerInfos.RoJST == 3 then
                local paynum = cc.Label:createWithBMFont("hall/font/room_num.fnt",math.ceil( playerInfos.RoFS / playerInfos.plS ))
                paynum:setScale(0.82)
                paynum:setPosition(cc.p(70,-5))
                room_Panel:addChild(paynum)
            end
        else
            img_paytype:setVisible(false)
        end
    end
end

--系统时间
function SignalInfoNode:initTime()
    self.label_time = self:getWidget(self.panel,"Label_time")
    self.label_time:setString(os.date("%H:%M", os.time()))
    local tPX, tPY = self.label_time:getPosition()
    self.label_time:setPosition(cc.p(tPX + 48, tPY))
    local function refreshTimeFun ()
        local time = os.date("%H:%M", os.time())
        if time == nil then
            time = " "
        end
        time = string.format(time)
        if self.label_time ~= nil then
            self.label_time:setString(time.."")
        end
        self.label_time:performWithDelay(refreshTimeFun,1)
    end
    refreshTimeFun()

    -- 底板
    local timeBg = ccui.Scale9Sprite:create(cc.rect(10, 10, 2, 2), "hall/Common/name_scale_bg.png")
    timeBg:setContentSize(cc.size(self.label_time:getContentSize().width + 6, self.image_bat_bg:getContentSize().height + 4))
    timeBg:setPosition(cc.p(self.label_time:getPositionX(), self.panel:getContentSize().height * 0.5 + 2))
    self.panel:addChild(timeBg, -1)
end

function SignalInfoNode:initSignalIcon()
    --wifi信号
    self.image_wifi = self:getWidget(self.panel,"Image_wifi")
    self.wifi_1 = self:getWidget(self.image_wifi,"wifi_1")
    self.wifi_2 = self:getWidget(self.image_wifi,"wifi_2")
    self.wifi_3 = self:getWidget(self.image_wifi,"wifi_3")
    self.wifi_4 = self:getWidget(self.image_wifi,"wifi_4") 
    local x, y = self.image_wifi:getPosition()
    self.image_wifi:setPosition(cc.p(x + 46, y + 2))
    --手机信号
    self.image_xinhao = self:getWidget(self.panel,"Image_xinhao")
    self.xinhao_1 = self:getWidget(self.image_xinhao,"xinhao_1")
    self.xinhao_2 = self:getWidget(self.image_xinhao,"xinhao_2")
    self.xinhao_3 = self:getWidget(self.image_xinhao,"xinhao_3")
    self.xinhao_4 = self:getWidget(self.image_xinhao,"xinhao_4")
    self.image_xinhao:setScale(0.7)
    x, y = self.image_xinhao:getPosition()
    self.image_xinhao:setPosition(cc.p(x + 48, y + 2))
end

function SignalInfoNode:initElectric()
    --手机电量
    self.image_bat_bg = self:getWidget(self.panel,"Image_bat_bg")
    self.progressBar_pro = self:getWidget(self.image_bat_bg,"ProgressBar_pro")
    local posX, posY = self.progressBar_pro:getPosition()
    self.progressBar_pro:setPosition(cc.p(posX + 1, posY + 1))

    self.proNum = cc.Label:createWithBMFont("hall/Common/batteryFont.fnt", "100%")
    local x = self.image_bat_bg:getPositionX() + self.image_bat_bg:getContentSize().width + 8
    self.proNum:setPosition(cc.p(x , self.panel:getContentSize().height * 0.5 - 4))
    self.proNum:setAnchorPoint(cc.p(0.5, 0.85))
    self.panel:addChild(self.proNum, 10)

    -- 底板
    local bBgSize = self.image_bat_bg:getContentSize()
    local proBg = ccui.Scale9Sprite:create(cc.rect(10, 10, 2, 2), "hall/Common/name_scale_bg.png")
    proBg:setContentSize(cc.size(bBgSize.width + self.proNum:getContentSize().width + 8, bBgSize.height + 4))
    proBg:setPosition(cc.p(self.image_bat_bg:getPositionX() - bBgSize.width * 0.5 - 4, self.panel:getContentSize().height * 0.5 + 2))
    proBg:setAnchorPoint(cc.p(0, 0.5))
    self.panel:addChild(proBg, -1)
end
--更新电量信号时间信息
function SignalInfoNode:updateTitle()
    -- print(debug.traceback())
    self.panel = self:getWidget(self.m_pWidget,"title_panel")
    local bg = self:getWidget(self.panel, "Image_bg")
    bg:setVisible(false)
    self:initElectric()
    self:initSignalIcon()
    self:initTime(self.panel)
    self.m_pWidget:performWithDelay(function()
        self:updateBattery()
        self:updateSignal()
    end, 2)
end

function SignalInfoNode:updateBattery()
    local update = cc.CallFunc:create(function()
            local data = {}
            data.cmd = NativeCall.CMD_GETBATTERY
            NativeCall.getInstance():callNative(data, self.onBatteryCallBack, self)
        end)
    self.image_bat_bg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(8),update)))

    local batteryEvent = cc.EventListenerCustom:create(LocalEvent.FriendRoomBattery,handler(self,self.onUpdateBattery))
    table.insert(self.LocalEvent,batteryEvent)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(batteryEvent, 1)
end

function SignalInfoNode:onBatteryCallBack(data)
    local event = cc.EventCustom:new(LocalEvent.FriendRoomBattery)
    event.data = data
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function SignalInfoNode:onUpdateBattery(event)
    -- Log.i("-------------------onUpdateBattery",event.data)
    self.progressBar_pro:setPercent(event.data.baPro)
    self.proNum:setString(string.format("%d%%", event.data.baPro))
end

function SignalInfoNode:updateSignal()
    local update = cc.CallFunc:create(function() 
        local data = {}
        data.cmd = NativeCall.CMD_WECHAT_SIGNAL
        NativeCall.getInstance():callNative(data, self.onSignalCallBack, self)
    end)
    self.image_wifi:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(6),update)))
    -- 回调函数注册的时候不传入self指针则在方法内无法调用到了
    local signalEvent = cc.EventListenerCustom:create(LocalEvent.FriendRoomSignal,handler(self,self.onUpdateSignal))
    table.insert(self.LocalEvent,signalEvent)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(signalEvent, 1)
end

function SignalInfoNode:onSignalCallBack(data)
    local event = cc.EventCustom:new(LocalEvent.FriendRoomSignal)
    event.data = data
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function SignalInfoNode:onUpdateSignal(event)
    -- Log.i("-------------------onUpdateSignal",event.data)
    local info = event.data
    if info.type ~= "Wi-Fi" then
        self.image_wifi:setVisible(false)
        self.image_xinhao:setVisible(true)
        return
    else
        self.image_wifi:setVisible(true)
        self.image_xinhao:setVisible(false)
    end
    if info.rssi == 4 then
        self.wifi_1:setVisible(true)
        self.wifi_2:setVisible(true)
        self.wifi_3:setVisible(true)
        self.wifi_4:setVisible(true)
    elseif info.rssi == 3 then
        self.wifi_1:setVisible(true)
        self.wifi_2:setVisible(true)
        self.wifi_3:setVisible(true)
        self.wifi_4:setVisible(false)
    elseif info.rssi == 2 then
        self.wifi_1:setVisible(true)
        self.wifi_2:setVisible(true)
        self.wifi_3:setVisible(false)
        self.wifi_4:setVisible(false)
    elseif info.rssi == 1 then
        self.wifi_1:setVisible(true)
        self.wifi_2:setVisible(false)
        self.wifi_3:setVisible(false)
        self.wifi_4:setVisible(false)
    end
end

--获取子控件时赋予特殊属性(支持Label,TextField)
function SignalInfoNode:getWidget(parent, name, ...)
    local widget = nil;
    local args = ...;
    widget = ccui.Helper:seekWidgetByName(parent or self.m_pWidget, name)
	if(widget == nil) then 
        return; 
    end
    
    return widget;
end

return SignalInfoNode 
