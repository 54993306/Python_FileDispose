--[[
    作者:徐志军
    时间:2018-03-25 11:08:20
    摘要:创建房间数据存储类
    return
]]
local DataStore = require("app.hall.common.DataStore")

local FriendRoomDataManager = class("FriendRoomDataManager")

function FriendRoomDataManager:ctor(fillName)
    self._fillName = string.format( "%s.text",fillName) 
    self:init()
end
--初始化数据存储
function FriendRoomDataManager:init()
    DataStore:getInstance():init(self._fillName)

    self.m_FontColorMoren = G_ROOM_INFO_FORMAT.normalColor or  cc.c3b(255, 255, 255) -- 文字默认颜色
    self.m_selectFontColor = G_ROOM_INFO_FORMAT.selectColor or cc.c3b(38, 204, 38)  -- 选中后的文字颜色
end
--获取并保存panel上所有属性的数据
function FriendRoomDataManager:savePanelAllData(panels,_key)
    -- local children = panel:getChildren() 
    local panelData = {}
    for i,v in pairs(panels) do
        local data = {}
        data._select = v:getSelected()
        data._enabled = v:getEnabled()
        data._visible = v:isVisible()
        data._posX = v:getPositionX()
        data._posY = v:getPositionY()
        table.insert(panelData,data)
    end
    if panelData and #panelData > 0 then
        self:insertData(_key,table)
        self:saveData(_key,panelData)
    end
end
--获取并保存checkBox数据
function FriendRoomDataManager:setCheckPanelAllData(panels,_key)
    local panelData = {}
    for i,v in pairs(panels.m_OptionPanelList) do
        local data = {}
        local checkBox = ccui.Helper:seekWidgetByName(v,"CheckBox")

        if not tolua.isnull(checkBox) then
            data._select = checkBox:isSelected()
        else
            checkBox = ccui.Helper:seekWidgetByName(panels.m_OptionPanelList[i],"Button")
            if not tolua.isnull(checkBox) then
                data._select = checkBox.select
            end
        end

        if not tolua.isnull(checkBox) then
            data._enabled = checkBox:isTouchEnabled()
            data._visible = v:isVisible()
            data._posX = v:getPositionX()
            data._posY = v:getPositionY()
            table.insert(panelData,data)    
        end

    end
    if panelData and #panelData > 0 then
        self:insertData(_key,table)
        self:saveData(_key,panelData)
    end
end
--汇总单个类型数据到表里面
function FriendRoomDataManager:insertData(_key,table)
    if self._roomData == nil then
        self._roomData = {}
    end
    if self._roomData[_key] == nil then
        self._roomData[_key] = {}
    end
    self._roomData[_key] = table
  
end

--保存数据
function FriendRoomDataManager:saveData(_key,table)
    DataStore:getInstance():setData(_key,table)
end
--需要更新的panel
function FriendRoomDataManager:updateRoomPanel(panel,_key,_func)
    local panelData = self:getData(_key)
    if not panelData or #panelData <= 0 then
        return
    end
    local group = panel.m_radioBtns
    -- local children = panel:getChildren()
    if IsPortrait then -- TODO
        if table.nums(group) ~= table.nums(panelData) then
            return
        end
    end
    for i , v in pairs(panelData) do
        if v._select then
            panel.select = i
            panel.m_selectedIndex = i
            panel.m_data.callback(i)
        end
        local child = group[i]
        if v._select ~= nil then
            child:setSelected(v._select)
        end
        if v._enabled ~= nil then
            child:setEnabled(v._enabled)
        end
        if v._visible ~= nil then
            child:setVisible(v._visible)
        end
        
        if v._posX ~= nil and v._posY ~= nil then
            child:setPosition(cc.p(v._posX,v._posY))
        end
    end

    if _func then
        _func(panelData)
    end
end
--更新checkPanel属性
function FriendRoomDataManager:updateRoomCheckPanel(panels,_key,_func)
    local panelData = self:getData(_key)
    if not panelData or #panelData <= 0 then
        return
    end
    -- local children = panel:getChildren()
    if IsPortrait then -- TODO
        if table.nums(panels.m_OptionPanelList) ~= table.nums(panelData) then
            return
        end
    end
    for i , data in ipairs(panelData) do
        local checkBox = ccui.Helper:seekWidgetByName(panels.m_OptionPanelList[i],"CheckBox")
        if data._select and panels.m_callback then
            panels.select = i
            panels.m_selectedIndex = i
            panels.m_callback(i,true)
        end
        if not tolua.isnull(checkBox) then
            checkBox:setSelected(data._select)
        else
            checkBox = ccui.Helper:seekWidgetByName(panels.m_OptionPanelList[i],"Button")
            if not tolua.isnull(checkBox) then
                checkBox:setEnabled(not data._select)
                checkBox:setBright(not data._select)
                checkBox.select = data._select
            end
        end

        if not tolua.isnull(checkBox) then
            checkBox:setTouchEnabled(data._enabled)
            panels.m_OptionPanelList[i]:setVisible(data._visible)
            -- panels.m_OptionPanelList[i]:setPosition(cc.p(data._posX,data._posY))
            local label_name = ccui.Helper:seekWidgetByName(panels.m_OptionPanelList[i], "Label")
            if data._select then
                label_name:setColor(self.m_selectFontColor)
            else
                label_name:setColor(self.m_FontColorMoren)
            end
        end
    end

    if _func then
        _func(panelData)
    end
end
--获取数据
function FriendRoomDataManager:getData(_key,_func)
    if _key == nil then
        return
    end
    if self._roomData == nil then
        self._roomData = {}
    end
    if self._roomData[_key] == nil then
        self._roomData[_key] = {}
    end
    self._roomData[_key] = DataStore:getInstance():getData(_key)

    return self._roomData[_key]
end

return FriendRoomDataManager