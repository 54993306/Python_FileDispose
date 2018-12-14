-----------------------------------------------------------
--  @file   Mall.lua
--  @brief  兑换商城
--  @author linxiancheng
--  @DateTime:2017-07-14 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local Mall = class("Mall", UIWndBase)
local MallTest = require "app.hall.wnds.mall.mallTest"
local MallSocketProcesser = require "app.hall.wnds.mall.mallSocketProcesser"
local RedPacketPanel = require "app.hall.wnds.mall.redPacketPanel"
local MallPlayerInfo = require "app.hall.wnds.mall.mallPlayerInfo"
local MallTrophyPanel = require "app.hall.wnds.mall.MallTrophyPanel"
local MallRecordPanel = require "app.hall.wnds.mall.MallRecordPanel"
local UmengClickEvent = require("app.common.UmengClickEvent")


local EntityType = {}
EntityType.entity = 0   -- 实物
EntityType.redBag = 1   -- 红包码

local  mallTest = MallTest.new()

function Mall:ctor(...)
    self.super.ctor(self, "hall/mall.csb",...)
    -- mallTest:initData(self,self.m_data)
    self.m_SocketProcesser = MallSocketProcesser.new(self)
    SocketManager:getInstance():addSocketProcesser(self.m_SocketProcesser)
end

function Mall:onClose()
    if self.m_SocketProcesser then
        SocketManager:getInstance():removeSocketProcesser(self.m_SocketProcesser)
        self.m_SocketProcesser = nil
    end
end

local function initNilLabel(self)
    local lab_nil = ccui.Helper:seekWidgetByName(self.lay_trophy, "lab_nil")
    if #self.m_data.paGL > 0 then
        lab_nil:setVisible(false)
    else
        lab_nil:setVisible(true)
    end
    local lab_nil2 = ccui.Helper:seekWidgetByName(self.lay_record, "lab_nil")
    if #self.m_data.reL > 0 then
        lab_nil2:setVisible(false)
    else
        lab_nil2:setVisible(true)
    end
end

local function setChoice(self,isTrophy)
    self.lay_trophy:setVisible(isTrophy)
    initNilLabel(self)
    if IsPortrait then -- TODO
        local img_back = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_back")
        local img_back_flip = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_back_flip")

        --local img_line = ccui.Helper:seekWidgetByName(self.btn_trophy, "img_line")
        --img_line:setVisible(isTrophy)
        local lab = ccui.Helper:seekWidgetByName(self.btn_trophy, "lab") 
        local im1 = ccui.Helper:seekWidgetByName(self.btn_trophy, "im1") 
        local im1sub = ccui.Helper:seekWidgetByName(self.btn_trophy, "im1sub") 
        if isTrophy then
            lab:setOpacity(255)
            im1:setOpacity(255)
            im1sub:setOpacity(255)
            img_back:setOpacity(255)
            img_back_flip:setOpacity(0)
            self.btn_trophy:setLocalZOrder(1)
        else
            lab:setOpacity(150)
            im1:setOpacity(50)
            im1sub:setOpacity(50)
            img_back:setOpacity(0)
            img_back_flip:setOpacity(255)
            self.btn_trophy:setLocalZOrder(0)
        end

        self.lay_record:setVisible(not isTrophy)
        --local img_line2 = ccui.Helper:seekWidgetByName(self.btn_record, "img_line")
        --img_line2:setVisible(not isTrophy)
        local lab2 = ccui.Helper:seekWidgetByName(self.btn_record, "lab")
        local im2 = ccui.Helper:seekWidgetByName(self.btn_record, "im1") 
        local im2sub = ccui.Helper:seekWidgetByName(self.btn_record, "im1sub")
        if isTrophy then
            lab2:setOpacity(150)
            im2:setOpacity(50)
            im2sub:setOpacity(50)
            self.btn_record:setLocalZOrder(0)
        else
            lab2:setOpacity(255)
            im2:setOpacity(255)
            im2sub:setOpacity(255)
            self.btn_record:setLocalZOrder(1)
        end
    else
        local img_line = ccui.Helper:seekWidgetByName(self.btn_trophy, "img_line")
        img_line:setVisible(isTrophy)
        local lab = ccui.Helper:seekWidgetByName(self.btn_trophy, "lab") 
        if isTrophy then
            lab:setOpacity(255)
        else
            lab:setOpacity(127)
        end

        self.lay_record:setVisible(not isTrophy)
        local img_line2 = ccui.Helper:seekWidgetByName(self.btn_record, "img_line")
        img_line2:setVisible(not isTrophy)
        local lab2 = ccui.Helper:seekWidgetByName(self.btn_record, "lab")
        if isTrophy then
            lab2:setOpacity(128)
        else
            lab2:setOpacity(255)
        end
    end
end

function Mall:onInit()

    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onBtnCallBack));

    self.scrip = kUserInfo:getScrip()
    -- self.scrip = 100000
    self.lab_scrip = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_scrip")
    if IsPortrait then -- TODO
        self.lab_scrip:setString(tostring(self.scrip))
    else
        self.lab_scrip:setString("x"..tostring(self.scrip))
    end
    
    self.lay_trophy = ccui.Helper:seekWidgetByName(self.m_pWidget,"trophyPanel")
    self.lay_record = ccui.Helper:seekWidgetByName(self.m_pWidget,"recordPanel")

    --默认选中第一个按钮，显示第一个面板
    self.btn_trophy = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_trophy")
    self.btn_trophy:addTouchEventListener(handler(self,self.onBtnCallBack))

    self.btn_record = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_record")
    self.btn_record:addTouchEventListener(handler(self,self.onBtnCallBack))

    local lab_wechat = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_wechat")
    lab_wechat:setString(_MALLWECHAT)
    lab_wechat:setVisible(false)

    self.TrophyPanel = MallTrophyPanel.new(self)
    self.RecordPanel = MallRecordPanel.new(self) 
    -- self.Trophys = {}
    -- self.Records = {}
    self.urls = {}
    -- self:initTrophyList()
    -- self:initRecordList()
    setChoice(self, true)    
end

function Mall:onBtnCallBack(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_close then
            self:keyBack()
        elseif pWidget == self.btn_trophy then
            setChoice(self,true)     
        elseif pWidget == self.btn_record then
            setChoice(self,false)
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.ExchengeButton)
        end
    end
end

local function getItemByFileName(fileName, itemList)
    local itemID = string.sub(fileName,string.len("mall_") + 1 , string.find(fileName,".jpg")-1)
    for id,item in ipairs( itemList ) do           -- getItemList 只会调用一次
        if tonumber(id) == tonumber(itemID) then   -- 转化为相同的类型才能使用比较运算符
            return item
        end
    end
    return nil
end

function Mall:initItemImg(item, fileName)
    local fullpath = cc.FileUtils:getInstance():fullPathForFilename(fileName)
    if io.exists(fullpath) then
        local itemImg = ccui.Helper:seekWidgetByName(item,"img_item")
        itemImg:loadTexture(fullpath)
        return true
    end
    return false
end

-- 重写父类的方法,http请求返回
function Mall:onResponseNetImg(fileName)
    local function getItemList()
        if self.lay_record:isVisible() then
            return self.RecordPanel:getRecords()
        else
            return self.TrophyPanel:getTrophys()
        end
    end
    local item = getItemByFileName(fileName, getItemList())
    if item and self.initItemImg(item,fileName) then
        return 
    else
        print("Mall:onResponseNetImg------UNUSUAL by [ Mall::onResponseNetImg ]",fileName)
    end
end

-- 走已经实现好的获取图片的方法获取图片
function Mall:getItemImageByNet(item)
    if true then
        return
    end
    local fileName = string.format("mall_%d.jpg",item.data.goI or item.data.id)
    if self.initItemImg(item,fileName) then
        return
    end

    for _,url in pairs(self.urls) do   
        if url == (item.data.im or item.data.im3) then                     -- 比较运算符 == 的优先级高于 or 逻辑运算符
            return
        end
    end
    table.insert(self.urls,item.data.im or item.data.im3)               -- 存储已经请求下载的url防止在下载的过程中被多次下载
    HttpManager.getNetworkImage(
    string.format("%s%s",kServerInfo:getImgUrl(),item.data.im or item.data.im3),fileName) -- 回调默认调用窗口基类的onResponseNetImg方法
end
-- ##  goI  int  商品id
-- ##  goC  String  红包码
-- ##  we  String  关注的微信号
-- ##  re  int  结果(0:操作成功，获得XX  1:货币不够兑换  2:id无效 3:无库存 4:已经达到购买上限)
local recResult = {}
recResult.succeed       = 0      -- 操作成功
recResult.defIcon       = 1      -- 货币不足
recResult.unKnowID      = 2      -- id无效
recResult.unRepertory   = 3      -- 无库存
recResult.upper         = 4      -- 已到达购买上限
recResult.max           = 5      -- 未领取兑换码达20条
function Mall:MallExchangeRec(infoPacket)
    LoadingView.getInstance():hide()
    if infoPacket.re == recResult.succeed then
        -- exchangeSucceed(self,infoPacket)
        -- updateRecord(self,infoPacket)
        self.TrophyPanel:exchangeSucceed(infoPacket)
        self.RecordPanel:updateRecord(infoPacket)
        Toast.getInstance():show("兑换成功");
    elseif infoPacket.re == recResult.defIcon then
        Toast.getInstance():show("元宝不足，无法兑换");
    elseif infoPacket.re == recResult.unKnowID then
        Toast.getInstance():show("商品ID无效，请联系客服");
    elseif infoPacket.re == recResult.unRepertory then
        Toast.getInstance():show("商品库存不足");
    elseif infoPacket.re == recResult.upper then 
        Toast.getInstance():show("已达到兑换上限");
    elseif infoPacket.re == recResult.max then 
        Toast.getInstance():show("兑换记录已满，请先使用红包");
    end
end

-- 刷新兑换商城兑换券数量
function Mall:updateScrip(packet)
    self.scrip = kUserInfo:getScrip()
    self.lab_scrip:setString(tostring(self.scrip))
end

function Mall:RecMallPlayerInfo(infoPacket)
    LoadingView.getInstance():hide()
    if infoPacket.re == 0 then
        Toast.getInstance():show("兑换信息发送成功");
    else
        Toast.getInstance():show("兑换信息发送失败，请联系客服");
    end
end

Mall.s_socketCmdFuncMap = 
{
    [HallSocketCmd.CODE_REC_EXCHANGE]    = Mall.MallExchangeRec;    --使用局部的方法会出现栈溢出的情况
    [HallSocketCmd.CODE_REC_MALLADD]     = Mall.RecMallPlayerInfo;
    [HallSocketCmd.CODE_USERDATA_POINT]  = Mall.updateScrip;
}

return Mall