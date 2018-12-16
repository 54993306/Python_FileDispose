-----------------------------------------------------------
--  @file   cliblist.lua
--  @brief  亲友圈
--  @author linxiancheng
--  @DateTime:2017-07-29 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================


local PlayerListDialog = class("PlayerListDialog",UIWndBase)
local CircleClippingNode = require("app.games.common.custom.CircleClippingNode")

function PlayerListDialog:ctor(data)
    PlayerListDialog.super.ctor(self,"hall/poplist.csb",data)
end

local function initCloseBtn(self)
    local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close")
    local btn_sure = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_sure")
    btn_close:addTouchEventListener(function(widget, touchType)
            if touchType == ccui.TouchEventType.ended then
                self:keyBack()
            end
    end)
    btn_sure:addTouchEventListener(function(widget, touchType)
            if touchType == ccui.TouchEventType.ended then
                self:keyBack()
            end
    end)
end



local function initHeadImage(self,item)
    local headImage = ccui.Helper:seekWidgetByName(item,"img_head")
    if item.data.he and string.len(item.data.he) > 4 then
        local imgName = string.format("%d.jpg",item.data.usI)
        local headPath = cc.FileUtils:getInstance():fullPathForFilename(imgName)
        if io.exists(headPath) then
            if IsPortrait then -- TODO
                headImage:loadTexture(headPath)
            else
                headImage:removeAllChildren()
                local cirHead = CircleClippingNode.new(headPath, true, 80)
                cirHead:setPosition(headImage:getContentSize().width/2, headImage:getContentSize().height/2)
                headImage:addChild(cirHead)
            end
        else
            self.netImagesTable[imgName] = headImage
            HttpManager.getNetworkImage(item.data.he, imgName)
        end
        self.headImages[imgName] = headImage
    end
end

function PlayerListDialog:onResponseNetImg(imgName)
    local headImage = self.netImagesTable[imgName]
    if not tolua.isnull(headImage) then
        local headPath = cc.FileUtils:getInstance():fullPathForFilename(imgName)
        if io.exists(headPath) then
            if IsPortrait then -- TODO
                headImage:loadTexture(headPath)
            else
                headImage:removeAllChildren()
                local cirHead = CircleClippingNode.new(headPath, true, 80)
                cirHead:setPosition(headImage:getContentSize().width/2, headImage:getContentSize().height/2)
                headImage:addChild(cirHead)
            end
        end
    end
end

function PlayerListDialog:initItem(item)
    local itemName = ccui.Helper:seekWidgetByName(item,"lab_name") --item.data.na or ""
    local name = ToolKit.subUtfStrByCn(string.format("%s",item.data.na or ""), 0, 6, "...")
    Util.updateNickName(itemName, name, 20)
    local itemID   = ccui.Helper:seekWidgetByName(item,"lab_id") 
    itemID:setString(string.format("ID:%d",item.data.usI or 0))
    initHeadImage(self,item)
end

local function initList(self)
    for i,data in pairs(self.m_data) do
        local lay = self.headList:getItem((i-1)/4)
        if not lay then
            self.headList:pushBackDefaultItem()
            lay = self.headList:getItem(#self.headList:getItems() - 1)
            lay.frontData = data
            for d=0,3 do
                ccui.Helper:seekWidgetByName(lay, "panel_"..d):setVisible(false)
            end
        end
        lay.lastData = data
        local item = ccui.Helper:seekWidgetByName(lay, "panel_"..(i-1)%4)
        item:setVisible(true)
        item.data = data
        self:initItem(item)
        table.insert(self.itemList,item)
    end
end

-- SimpleUserItem      
-- ##    usI  int  玩家id（0表示未注册）
-- ##    na  String  玩家名称
-- ##    he  String  头像
-- ##    st  int     是否为正式亲友 0 非正式   1 正式亲友
function PlayerListDialog:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    self.itemList = {}
    self.netImagesTable = {}
    self.headImages = {}
    self.headList = ccui.Helper:seekWidgetByName(self.m_pWidget, "list_item") 
    local itemModel = ccui.Helper:seekWidgetByName(self.m_pWidget, "item_model")
    itemModel:setTouchEnabled(true)
    self.headList:setItemModel( itemModel:clone() )
    itemModel:removeFromParent()

    local title = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_title")
    title:setString("亲友圈玩家")
    initCloseBtn(self)
    initList(self)

    self.m_pWidget:addNodeEventListener(cc.NODE_EVENT,function(event) 
        if event.name == "exit" then
            self:onExit()
        end
    end)
end

function PlayerListDialog:onExit()
end

function PlayerListDialog:setTitle(strTitle)
    if type(strTitle) == "string" then
        local title = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_title")
        title:setString(strTitle)
    end
end

return PlayerListDialog