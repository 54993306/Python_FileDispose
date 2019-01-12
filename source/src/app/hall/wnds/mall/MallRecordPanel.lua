-----------------------------------------------------------
--  @file   MallRecordPanel.lua
--  @brief  兑换商城
--  @author linxiancheng
--  @DateTime:2017-07-14 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local MallRecordPanel = class("MallRecordPanel")
local RedPacketPanel = require "app.hall.wnds.mall.redPacketPanel"
local MallPlayerInfo = require "app.hall.wnds.mall.mallPlayerInfo"

local fun = {}

local EntityType = {}
EntityType.entity = 0   -- 实物
EntityType.redBag = 1   -- 红包码

function MallRecordPanel:ctor(mall)
    self.mall = mall
    self.m_data = self.mall.m_data
    self.m_pWidget = self.mall.m_pWidget
    self.Records = {}
    self.urls = {}
    self:init()
end

function MallRecordPanel:getRecords()
    return self.Records
end

function MallRecordPanel:init()
    self:initRecordList()
end

--兑换记录的内容只是做一个显示处理
function MallRecordPanel:initRecordList()
    local recordItem = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/mall_record.csb")
    local list = ccui.Helper:seekWidgetByName(self.m_pWidget,"itemList_0")
    list:removeAllItems()
    self.Records = {}
    for _,data in pairs(self.m_data.reL) do
        local item = recordItem:clone()
        item.data = data
        fun.initRecordItem(self,item)
        table.insert(self.Records,item)
        list:pushBackCustomItem(item)
    end
end

-- ##     id  long  记录编号
-- ##     goI2  int  商品id
-- ##     im3  String  图片url
-- ##     na  String  商品名称
-- ##     co  String  兑换码
-- ##     goT4  int  类型（实物0，红包码1）
-- ##     coN5  int  消耗的兑换券数量
-- ##     ti  long  兑换时间
-- ##     usT  long  使用时间
-- ##     isU  int  是否已经使用过红包码
fun.initRecordItem = function(self, item)
    local btn = ccui.Helper:seekWidgetByName(item,"gowechat")
    btn:setTouchEnabled(true)
    btn:setBright(true)
    btn:setTitleText("兑换红包")
    btn:addTouchEventListener(function(widget, touchType)
        if touchType == ccui.TouchEventType.ended then
            if item.data.goT4 == 0 then
                UIManager.getInstance():pushWnd(MallPlayerInfo);
            else
                UIManager.getInstance():pushWnd(RedPacketPanel,item.data.co,self.mall);
            end
        end
    end)
    -- 
    local lab_overtime = fun.initOvertime(self,item)

    local lab_time = ccui.Helper:seekWidgetByName(item,"lab_time")
    lab_time:setString(string.format("兑换时间:%s",os.date("%Y-%m-%d",item.data.ti)))

    if item.data.usT and (item.data.usT ~= -1) then
        lab_time:setString(string.format("使用时间:%s",os.date("%Y-%m-%d",item.data.usT)))
    end

    -- local lab_num = ccui.Helper:seekWidgetByName(item,"lab_num")
    -- lab_num:setString(data.coN5)

    local lab_name = ccui.Helper:seekWidgetByName(item,"lab_name")
    if lab_name then lab_name:setString(item.data.na)  end
    
    local lmg_tips = ccui.Helper:seekWidgetByName(item, "img_tips")
    if item.data.goT4 == EntityType.entity then
        -- lab_name:setString(data.na)
    elseif item.data.goT4 == EntityType.redBag then
        if item.data.isU == 0 then
            lab_overtime:setVisible(true)
        else
            lab_overtime:setVisible(false)
            btn:setTouchEnabled(false)
            btn:setBright(false)
            btn:setTitleText("已使用")
            lmg_tips:setVisible(false)
        end
        -- lab_name:setString(string.format("兑换码:%s",data.na))
    else
        print("[ Server Data Error ] Mall:initRecordItem -----------------")
    end
    self.mall:getItemImageByNet(item)
end

local function getDelaytime(self)
    return self.m_data.exD * 24 * 60 * 60
end

fun.initOvertime = function(self,item)
    local lab = ccui.Helper:seekWidgetByName(item, "lab_overtime")
    local lmg_tips = ccui.Helper:seekWidgetByName(item, "img_tips")
    local btn = ccui.Helper:seekWidgetByName(item,"gowechat")
    local timeoffset = kSystemConfig:getTimeOffset()   -- 服务器端时间 - 客户端时间 = 时间差
    local clientTime = item.data.ti - timeoffset + getDelaytime(self)
    -- clientTime = os.time() + 10    -- 测试代码
    local function refreshTimeFun ()
        if clientTime <= os.time() then
           lab:stopAllActions()
           lmg_tips:setVisible(false)
           btn:setBright(false)
           btn:setTouchEnabled(false)
           btn:setTitleText("已过期")
           return
        end
        local str,isDay = Util.timeFormatNew(os.difftime(clientTime - os.time()))
        if isDay then
            lab:setString(str.."后过期")  -- 本地时间每秒的自增1
        else
            lab:setString(str)  -- 本地时间每秒的自增1
        end
        lab:performWithDelay(refreshTimeFun,1)
    end
    refreshTimeFun()
    return lab
end

function MallRecordPanel:updateRecord(infoPacket)
    table.insert(self.m_data.reL,1,infoPacket.re1)
    if #self.m_data.reL > 20 then
        table.remove(self.m_data.reL)
    end
    self:initRecordList()
end


return MallRecordPanel