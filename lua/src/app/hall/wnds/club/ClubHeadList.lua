-----------------------------------------------------------
--  @file   ClubHeadList.lua
--  @brief  亲友圈亲友头像
--  @author linxiancheng
--  @DateTime:2017-07-29 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local PlayerListDialog = require "app.hall.wnds.PlayerListDialog"
local ClubHeadList = class("ClubHeadList",PlayerListDialog)
local LocalEvent = require "app.hall.common.LocalEvent"

local CacheItem = 4                              -- 缓存大小 上下都预留4个
local ItemDataSize = 4                           -- 每个item上的数据量
local CacheDatasize = CacheItem * ItemDataSize
local MaxItems = CacheItem * 3                   -- 缓存的最大item数
local pullServerSize = CacheDatasize * 2         -- 每一个请求服务器的数据量.每页的数据量


function ClubHeadList:ctor(data)
    ClubHeadList.super.ctor(self,data)
    self.directionDown = true
end

function ClubHeadList:onExit()
    local event = cc.EventCustom:new(LocalEvent.RemoveHeadList)
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function ClubHeadList:onInit()
    ClubHeadList.super.onInit(self)
    local lab_tips = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_tips")
    lab_tips:setString("快来呼唤你的小伙伴吧~")
    if #self.headList:getItems() == 0 then     
        lab_tips:setVisible(true) 
    else
        lab_tips:setVisible(false)
    end
    self:registerListBottomEvent()
end

function ClubHeadList:addPageNum()
    self:setPageNum(self:getPageNum() + 1)
end

function ClubHeadList:setPageNum(num)
    self.pageNum = num or 0
end

function ClubHeadList:getPageNum()
    return self.pageNum or 0
end

function ClubHeadList:setSendState(isSend)
    self.isSend = isSend
end

function ClubHeadList:isSendState()
    return self.isSend or false
end

-- 处理滑动条事件
function ClubHeadList:registerListBottomEvent()
    self.headList:addScrollViewEventListener(
    function(pListWidget, pEventType)
        if pEventType == ccui.ScrollviewEventType.scrollToBottom then
            self:scrollToBottom()
        elseif pEventType == ccui.ScrollviewEventType.bounceBottom then
            self:bounceBottom()
        elseif pEventType == ccui.ScrollviewEventType.scrollToTop then
            self:scrollToTop()
        elseif pEventType == ccui.ScrollviewEventType.bounceTop then
            self:bounceTop()
        end
    end)
    -- 可直接监听item上的触摸消息
    self.headList:addEventListener(function(pListWidget, pEventType) 
        if pEventType == ccui.ListViewEventType.ONSELECTEDITEM_END then  -- 不脱手的时候不需要改变ListView的Item情况1`q

        end
    end)
end 

local function pullListData(self)
    if self:isSendState() then
        return
    end
    self:setSendState(true)
    self:addPageNum()
    local data = {}
    data.pa = self:getPageNum()           -- 页码
    data.roN = pullServerSize             -- 每页显示人数
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_QUERYCLUBHEAD,data)
    LoadingView.getInstance():show("请求下一页亲友数据中...")
end

local function getLastItemData(self)
    local items = self.headList:getItems()
    if items[#items] then
        return items[#items].lastData
    else
        return nil
    end
end

local function isLastData(self)
    local data = getLastItemData(self) 
    if self.m_data[#self.m_data] == data then
        return true
    else
        return false
    end
end

local function getBackItemsData(self)
    local beginIndex = table.indexof(self.m_data, getLastItemData(self)) or #self.m_data
    local endIndex = beginIndex 
    if beginIndex + CacheDatasize > #self.m_data then
        endIndex = #self.m_data
    else
        endIndex = beginIndex + CacheDatasize
    end
    beginIndex = beginIndex + 1
    local data = {}
    for index = beginIndex, endIndex do
        data[index - beginIndex + 1] = self.m_data[index]
    end
    return data
end
-- 在回弹的时候去触发添加体验不好
function ClubHeadList:bounceBottom()
    self.directionDown = true           -- 向下滑动不是每次都从服务器拉数据
    if #self.headList:getItems() == 0 then
        return
    end
    if isLastData(self) then
        pullListData(self)
    else
        self:pushBackItem()
    end
end

function ClubHeadList:scrollToBottom()
    self.directionDown = true
    -- print("-------scrollToBottom")
    -- 体验好的非常多,需要优化,次数太多
    -- if #self.headList:getItems() == 0 then
    --     return
    -- end
    -- if isLastData(self) then
    --     pullListData(self)
    -- else
    --     self:pushBackItem()
    -- end
end

function ClubHeadList:scrollToTop()
    -- print("-------scrollToTop")
    self.directionDown = false
end

local function getFirstItemData(self)
    local item = self.headList:getItem(0)
    if item then
        return item.frontData
    else
        return nil
    end
end

local function isFrontItem(self)  
    if getFirstItemData(self) == self.m_data[1] then
        return true
    else
        return false
    end
end

local function getFrontItemsData(self)
    local endIndex = table.indexof(self.m_data, getFirstItemData(self)) or 0
    local beginIndex = endIndex
    if endIndex - CacheDatasize > 0 then        
        beginIndex = endIndex - CacheDatasize
    else
        beginIndex = 1
    end
    endIndex = endIndex - 1
    local data = {}
    for index = endIndex,beginIndex,-1 do
        data[endIndex - index + 1] = self.m_data[index] 
    end
    return data
end
-- 回弹的时候才进行触发
function ClubHeadList:bounceTop()
    self.directionDown = false
    if isFrontItem(self) then
        Toast:getInstance():show("已经是第一页亲友")
    else
        self:insertFrontItem()
    end
end

local function checkItemCellState(item)
    for index = 0, 3 do
        local state = ccui.Helper:seekWidgetByName(item, "panel_"..index):isVisible()
        if not state then
            return false
        end
    end
    return true
end 

function ClubHeadList:insertFrontItem() 
    for index,data in pairs( getFrontItemsData(self) ) do  
        local lay = self.headList:getItem(0)
        if checkItemCellState(lay) then
            self.headList:insertDefaultItem(0)
            lay = self.headList:getItem(0)
            lay.lastData = data
            for d = 0,3 do
                ccui.Helper:seekWidgetByName(lay, "panel_"..d):setVisible(false)
            end
        end
        lay.frontData = data     
        local item = ccui.Helper:seekWidgetByName(lay, "panel_"..3 - (index-1)%4)
        item:setVisible(true)
        item.data = data
        self:initItem(item)
    end
    self:itemCacheDispose(false)
end
-- 刷新显示头像列表
function ClubHeadList:pushBackItem()
    local hasItemNum = #self.headList:getItems()
    for index,data in pairs( getBackItemsData(self) ) do   
        local lay = self.headList:getItem((index-1)/4 + hasItemNum)
        if not lay then
            self.headList:pushBackDefaultItem()
            lay = self.headList:getItem( #self.headList:getItems() - 1)
            lay.frontData = data
            for d = 0, 3 do
                ccui.Helper:seekWidgetByName(lay, "panel_"..d):setVisible(false)
            end
        end
        lay.lastData = data
        local item = ccui.Helper:seekWidgetByName(lay, "panel_"..(index-1)%4)
        item:setVisible(true)
        item.data = data
        self:initItem(item)
    end
    self:itemCacheDispose(true)
end

function ClubHeadList:serverDataDispose(pData)
    if #pData > 0 then
        for _,v in pairs(pData) do
            table.insert(self.m_data,v)
        end
        self:pushBackItem()
    else
        Toast.getInstance():show("已是最后一个亲友圈亲友")
    end
    LoadingView.getInstance():hide()
    self:setSendState(false)
end

-- 数据不需要清理，显示的item需要清理,保持item的数量在 MaxItems 内
function ClubHeadList:itemCacheDispose(isPushBack)
    for _ = 1,#self.headList:getItems() - MaxItems do
        if isPushBack then
            self.headList:removeItem(0)
            print("----------Front")
        else
            self.headList:removeLastItem()
            print("-----------Back")
        end     
    end
end

return ClubHeadList