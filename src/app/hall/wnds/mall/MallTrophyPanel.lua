-----------------------------------------------------------
--  @file   MallTrophyPanel.lua
--  @brief  兑换商城商品界面
--  @author linxiancheng
--  @DateTime:2017-07-14 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================


local MallTrophyPanel = class("MallTrophyPanel")
local RedPacketPanel = require "app.hall.wnds.mall.redPacketPanel"
local MallPlayerInfo = require "app.hall.wnds.mall.mallPlayerInfo"
local UmengClickEvent = require("app.common.UmengClickEvent")

local fun = {}

local EntityType = {}
EntityType.entity = 0   -- 实物
EntityType.redBag = 1   -- 红包码

local limitType = {}
limitType.zero  = 0
limitType.day   = 1
limitType.week  = 2
limitType.month = 3
limitType.ever  = 4
limitType.time  = 5

function MallTrophyPanel:ctor(mall)
    self.mall = mall
    self.m_data = self.mall.m_data
    self.m_pWidget = self.mall.m_pWidget
    self.Trophys = {}
    self.urls = {}
    self:init()
end

function MallTrophyPanel:getTrophys()
    return self.Trophys
end

function MallTrophyPanel:init()
    self:horizontal()     -- 横版
end
-- 横版item
function MallTrophyPanel:horizontal()
    local trophyItem = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/mall_item.csb");
    local list = ccui.Helper:seekWidgetByName(self.m_pWidget,"itemList")
    list:removeAllItems()
    self.Trophys = {}
    -- 横版item
    for i,data in pairs(self.m_data.paGL) do
        local item = trophyItem:clone()
        data.scrip = self.mall.scrip
        item.data = data
        fun.initTrophyItem(self,item,i)
        table.insert(self.Trophys,item)
        list:pushBackCustomItem(item)
    end
end

-- 竖版item显示
--[[
    function MallTrophyPanel:vertical()
        local trophyItem = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/mall_item.csb");
        local list = ccui.Helper:seekWidgetByName(self.m_pWidget,"itemList")
        list:removeAllItems()
        self.Trophys = {}
        local lineModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/null_layer.csb");
        local itemInterval = 45
        local width = trophyItem:getContentSize().width*3 + itemInterval * 2
        local height = trophyItem:getContentSize().height+10
        lineModel:setContentSize(cc.size(width, height));
        
        --竖版item
        for i,data in pairs(self.m_data.paGL) do
            local lay = list:getItem((i-1)/3)   --调用的是c++的接口，在c++中是向下求整的，c++下标是从0开始的
            if not lay then
               lay = lineModel:clone()
               list:pushBackCustomItem(lay)
            end
            local col =  i%3>0 and i%3 or 3     --c++   i%3 > 0 ? i%3 : 3
            local item = trophyItem:clone()
            item:setPosition((col-1)*(trophyItem:getContentSize().width + itemInterval),0)
            data.scrip = self.scrip
            item.data = data
            initTrophyItem(self,item)
            table.insert(self.Trophys,item)
            -- self.Trophys[data.goI] = item
            lay:addChild(item) 
        end
    end
]]

--  Mallitem  Mallrecord
-- ##     goI  int  商品id
-- ##     na0  String  商品名称
-- ##     goT  int  类型（实物0，红包码1）
-- ##     goN  int  数量
-- ##     coN  int  需要多少兑换券
-- ##     im  String  图片url
-- ##     isH  int  是否热卖（0 不是 1 是）
fun.initTrophyItem = function(self, item,index)
    local btn = ccui.Helper:seekWidgetByName(item,"btn_get")
    btn:setTag(index)
    btn:addTouchEventListener(function(widget, touchType)
        if touchType == ccui.TouchEventType.ended then
            fun.exchangetDispose(widget,item.data)
        end
    end)

    local img_item = ccui.Helper:seekWidgetByName(item,"img_item")
    img_item:addTouchEventListener(function(widget, touchType)
        if touchType == ccui.TouchEventType.ended then
            fun.exchangetDispose(widget,item.data)
        end
    end)

    local name = ccui.Helper:seekWidgetByName(item,"lab_name")
    local name_data = item.data.na0
    if IsPortrait then -- TODO
        local trophyName = ccui.Helper:seekWidgetByName(item,"trophyName")
        
        --name_data = string.gsub(name_data, "随机兑换", "随机兑换\n\n")
        local contF,contL = string.find(name_data,"随机兑换",1)
        if contF ~= nil and contL ~= nil then
            local lens = string.len(name_data)
            local contH = string.sub(name_data,1,contL)
            local newData = string.gsub(name_data, "随机兑换", "")
            local contC = string.sub(newData,1,lens-contL)
            print("name_data=",name_data)
            print("contF,contL,lens",contF,contL,lens)
            print("contC="..contC)
            print("contH="..contH)
            name:setString(contH)
            trophyName:setString(contC)
        else
            name:setString(item.data.na0)
            trophyName:setString("")
        end
    else
        name_data = string.gsub(name_data, "随机兑换", "随机兑换\n")
        name:setString(name_data)
    end
    -- item.data.na0 = "随机2-50元红包"
    -- name:setString(ToolKit.subUtfStrByCn(item.data.na0, 0, 8, ".."))

    local scrip = ccui.Helper:seekWidgetByName(item,"lab_num")
    scrip:setString("x"..item.data.coN)

    fun.limitInit(item,item.data)
    
    self.mall:getItemImageByNet(item)
end

-- 做兑换券和是否超时判断
fun.exchangetDispose  = function(widget, data)

    if data.scrip < data.coN then   -- 判断兑换券是否足够
        Toast.getInstance():show("元宝不足，无法兑换");
    elseif widget.timeout then      -- 判断是否超时
        Toast.getInstance():show("无法兑换，兑换时间已截止");
    else
         fun.secondAffirm(data)
    end
    local tag = widget:getTag()
    if tag == 1 then
        NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.YBButton001)
    elseif tag == 2 then
        NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.YBButton002)
    elseif tag == 3 then
        NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.YBButton003)
    end
end

-- 二次确认框
fun.secondAffirm = function(pData)
    local data = {}
    data.type = 2
    data.content = "是否确认消耗"..pData.coN.."个元宝兑换"..pData.na0
    data.yesStr = "确认兑换" 
    data.yesCallback = handler(pData.goI,fun.sendExchangeID)
    UIManager.getInstance():pushWnd(CommonDialog, data)
end

fun.sendExchangeID = function(id)
    LoadingView.getInstance():show("奖品兑换中...")
    local data = {}
    data.goI = id   -- 给服务器发送的数据都要以json格式进行传输
    SocketManager:getInstance():send(CODE_TYPE_MALL,HallSocketCmd.CODE_SEND_EXCHANGE,data)
end

-- ##     liT  int  限制类型（空/0 不限制 1天 2周 3月 4永久 5时间限制liN为结束时刻）
-- ##     liN  int  限制数量
-- ##     goN1  int  如果是天、周、月为对应周期内本人已兑换的数量；如果是总量限制，为全服已兑换的数量
-- ##     to  int  总量  如果无限制类型+无限库存，传-1
fun.limitInit  = function(item, data)
    local limit_Type = data.liT
    local limitNum  = data.liN
    local exchangeNum = data.goN1
    local totalNum = data.to
    local lab_tips = ccui.Helper:seekWidgetByName(item,"lab_tips")
    local img_hot = ccui.Helper:seekWidgetByName(item,"img_hot")
    img_hot:setVisible(true)
    if limit_Type == limitType.zero then
        if totalNum == -1 then                               -- 不限制数量不限时间
            img_hot:setVisible(false)
            lab_tips:setVisible(false)
            lab_tips:setString("无兑换限制")
        else                                                 --全服总量限制,显示全服还有多少可以兑换 
            lab_tips:setString(string.format("库存:%d / %d",totalNum-exchangeNum,totalNum).."")
        end
    elseif limit_Type == limitType.day then
        lab_tips:setString(string.format("每天限购:%d/%d",totalNum-exchangeNum,totalNum))
    elseif limit_Type == limitType.week then
        lab_tips:setString(string.format("每周限购:%d/%d",totalNum-exchangeNum,totalNum))
    elseif limit_Type == limitType.month then
        lab_tips:setString(string.format("每月限购:%d/%d",totalNum-exchangeNum,totalNum))
    elseif limit_Type == limitType.ever then
        lab_tips:setString(string.format("每人限购:%d/%d",totalNum-exchangeNum,totalNum))
    elseif limit_Type == limitType.time then   -- 限时抢购
        fun.updateTime(item,limitNum)   --5时间限制liN为结束时刻
    end
    fun.upItemBtn(item)
end

-- 服务器端和客户端时间同步,每次断线重连都需要刷新一次服务器端和客户端的时间差
-- 服务器端和客户端时间差,将客户端时间转化为服务器端时间,才能跟服务器传过来的时间进行比对处理
fun.updateTime = function(item, servertime)
    local btn = ccui.Helper:seekWidgetByName(item,"btn_get")
    local lab = ccui.Helper:seekWidgetByName(item,"lab_tips")
    local icon = ccui.Helper:seekWidgetByName(item, "img_icon")
    local num = ccui.Helper:seekWidgetByName(item,"lab_num")
    local timeoffset = kSystemConfig:getTimeOffset()   -- 服务器端时间 - 客户端时间 = 时间差
    local clientTime = servertime - timeoffset
    clientTime = os.time() + 10
    local function refreshTimeFun ()
        if clientTime <= os.time() then
            lab:stopAllActions()
            lab:setString("00:00:00")
            btn.timeout = true
            btn:setBright(false)
            btn:setTouchEnabled(false)
            btn:setTitleText("已超时")
            num:setVisible(false)
            icon:setVisible(false)
           return
        end
        -- os.difftime  这个垃圾的方法把时区的参数都给搞掉了    
        -- 时间戳里面是带着时区参数的，不能直接使用100S这样的值  
        lab:setString(Util.timeFormatNew(os.difftime(clientTime - os.time())))  -- 本地时间每秒的自增1
        lab:performWithDelay(refreshTimeFun,1)
    end
    refreshTimeFun()
end

fun.upItemBtn = function(item)
    if item.data.to > item.data.goN1 or item.data.liT == limitType.zero then
        return
    else
        local btn = ccui.Helper:seekWidgetByName(item, "btn_get")
        local icon = ccui.Helper:seekWidgetByName(item, "img_icon")
        local num = ccui.Helper:seekWidgetByName(item,"lab_num")
        num:setVisible(false)
        icon:setVisible(false)
        btn:setTouchEnabled(false)
        btn:setBright(false)
        btn:setTitleText("已兑换") 
    end
end

function MallTrophyPanel:exchangeSucceed(infoPacket)
    fun.entityJudge(infoPacket,self)
    fun.updateItem(self,infoPacket.goI)
end
-- ##     goI  int  商品id
-- ##     goT  int  类型（实物0，红包码1）
fun.entityJudge = function(infoPacket,self)
    for _,data in pairs(self.m_data.paGL) do
        if data.goI == infoPacket.goI then
            if data.goT == EntityType.entity then
                UIManager.getInstance():pushWnd(MallPlayerInfo);
            elseif data.goT == EntityType.redBag then
                UIManager.getInstance():pushWnd(RedPacketPanel,infoPacket.goC,self.mall);    -- 显示提示面板
            else
                print("[ ERROR ] Mall:entityJudge ------- EntityType is Error",data.goT)
            end
        end
    end
    -- UIManager.getInstance():pushWnd(MallPlayerInfo);
end
-- 刷新商品库存信息
fun.updateItem = function(self,goI)
    for _,item in pairs(self.Trophys) do
        if item.data.goI == goI then
            item.data.goN1 = item.data.goN1 + 1
            fun.limitInit(item,item.data)
        end
    end
end

return MallTrophyPanel