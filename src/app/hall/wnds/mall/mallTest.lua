-----------------------------------------------------------
--  @file   MallTest.lua
--  @brief  兑换商城
--  @author linxiancheng
--  @DateTime:2017-07-14 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================


local MallTest = class("MallTest")

function MallTest:initData(mall,data)
    if  device.platform == "android" or 
        device.platform == "ios" or 
        not DEBUG_LXC then
        return
    end
    self.mall = mall
    data.na = "测试名称"
    data.ad = "测试住址"
    data.ph = "测试电话"
    data.em = "测试邮箱"
    data.exD = 10 -- 红包兑换码有效期
    self:initItemData(data)
    self:initRecordData(data)
    Log.i("---------------------------------------MallTest",self.m_data)
end

function MallTest:initItemData(data)
    data.paGL = {}
    for i = 1,12 do
        local item = {}
        item.goI = i
        item.na0  = "商品"..i
        item.goT = i%2
        item.goN = i
        item.coN = i*100
        item.im = ""
        item.liT = i == 5 and os.time() + 180 or i 
        -- item.liT = i == 5 and os.time() + 180 or i 
        item.liN = i
        item.goN1 = i*10
        item.to = i*5
        item.isH = false--i%2 > 0
        table.insert(data.paGL, item)
    end
end

function MallTest:initRecordData(data)
    data.reL = {}
    for i=1,10 do
        local record = {}
        record.id = i
        record.im2 = ""
        record.na = "记录数据"..i
        record.goT3 = i%2
        record.coN4 = i*100
        record.ti = os.time() + i * 120   -- 格式跟服务器的不太一样
        record.isU = i%2 > 0
        table.insert(data.reL, record)
    end
end

function MallTest:exchangeItem()
    self.mall:MallExchangeRec({re = 0})
end


return MallTest