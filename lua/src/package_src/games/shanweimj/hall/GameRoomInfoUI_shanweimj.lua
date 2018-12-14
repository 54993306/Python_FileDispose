--
-- Author: ShengJie Wu
-- Date: 2017-11-21
--

require("app.DebugHelper")

local RadioButtonGroup = require("app.games.common.custom.RadioButtonGroup")
local CheckBoxPanel = require("app.games.common.custom.CheckBoxPanel")
local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
local DropItem = require("app.games.common.custom.DropItem")
-- local GroupPanel=import(".GroupPanel")

local GameRoomInfoUI_shanweimj = class("GameRoomInfoUI_shanweimj", GameRoomInfoUIBase )

function GameRoomInfoUI_shanweimj:ctor(...)
    self.super.ctor(self, ...)
end

--地方组重写 初始化自己特有的数据
function GameRoomInfoUI_shanweimj:onInit()
    self.DIList = {}
end

-- 初始化玩法列表
function GameRoomInfoUI_shanweimj:initWanFa()
    self.gamePalyingName = MjGameConfigManager[self.m_gameID]._gamePalyingName

    
    local dataDI1 =
    {
        --  标题，不传该参数则默认为不创建该文本
        title = "玩法：",
        radios = {},
        callback = function(_index) -- 选择的callback  
            self.m_wanfa[1] =  self.gamePalyingName[_index+8].title
        end,
        clickback = function (_dropItem)
            for k,v in pairs(self.DIList) do
                if v ~= _dropItem then
                    v:hideList()
                end
            end
        end
    }
    for i=1,10 do
        dataDI1.radios[i] = self.gamePalyingName[i+8].ch
    end
    local DI1 = DropItem.new(dataDI1)
    table.insert(self.DIList,DI1)
    self:addScrollItem(DI1)

    local dataDI2 =
    {
        --  标题，不传该参数则默认为不创建该文本
        title = "　花：",
        radios = {},
        callback = function(_index) -- 选择的callback  
            self.m_wanfa[2] =  self.gamePalyingName[_index+18].title
        end,
        clickback = function (_dropItem)
            for k,v in pairs(self.DIList) do
                if v ~= _dropItem then
                    v:hideList()
                end
            end
        end
    }
    for i=1,3 do
        dataDI2.radios[i] = self.gamePalyingName[i+18].ch
    end
    local DI2 = DropItem.new(dataDI2)
    table.insert(self.DIList,DI2)
    self:addScrollItem(DI2)

    local dataDI3 =
    {
        --  标题，不传该参数则默认为不创建该文本
        title = "　字：",
        radios = {},
        callback = function(_index) -- 选择的callback  
            self.m_wanfa[3] =  self.gamePalyingName[_index+21].title
        end,
        clickback = function (_dropItem)
            for k,v in pairs(self.DIList) do
                if v ~= _dropItem then
                    v:hideList()
                end
            end
        end
    }
    for i=1,3 do
        dataDI3.radios[i] = self.gamePalyingName[i+21].ch
    end
    local DI3 = DropItem.new(dataDI3)
    table.insert(self.DIList,DI3)
    self:addScrollItem(DI3)
    -- local groupPanel1 = GroupPanel.new({panels = {DI1,DI2,DI3}, pad = 40,zorder = 200,offX = {0,-20,0}})--
    -- self:addScrollItem(groupPanel1)


    local dataDI4 =
    {
        --  标题，不传该参数则默认为不创建该文本
        title = "买马：",
        radios = {},
        callback = function(_index) -- 选择的callback  
            self.m_wanfa[4] =  self.gamePalyingName[_index+24].title
        end,
        clickback = function (_dropItem)
            for k,v in pairs(self.DIList) do
                if v ~= _dropItem then
                    v:hideList()
                end
            end
        end
    }
    for i=1,3 do
        dataDI4.radios[i] = self.gamePalyingName[i+24].ch
    end
    local DI4 = DropItem.new(dataDI4)
    table.insert(self.DIList,DI4)
    self:addScrollItem(DI4)

    local dataCB1 = {
        title = "跟杠：",
        options = {
            {text = self.gamePalyingName[37].ch}
        },
        --  可配置属性，详见 CheckBoxPanel:initConfigList()
        Config ={
            LineVisible = true,--是否显示分割线
            Exclusive = false,--子项间是否互斥
            ResponseEvent = false,--点击是否响应事件
        }

    }
    local CB1 = CheckBoxPanel.new(dataCB1,function (_index,_isSelected)
        if _isSelected then
            self.m_wanfa[6] = self.gamePalyingName[37].title --，玩法2,3,4,5,6,7,8,9
        else
            self.m_wanfa[6] = nil
        end    
    end)
    

    local dataDI5 =
    {
        --  标题，不传该参数则默认为不创建该文本
        title = "奖马：",
        radios = {},
        callback = function(_index) -- 选择的callback
            self.m_wanfa[5] =  self.gamePalyingName[_index+27].title
            if _index == 1 then
                CB1:setSelectedIndex(false,1)
                CB1:setEnabled(false)
                self.m_wanfa[6] = nil
            else
                CB1:setEnabled(true)
            end
        end,
        clickback = function (_dropItem)
            for k,v in pairs(self.DIList) do
                if v ~= _dropItem then
                    v:hideList()
                end
            end
        end
    }
    for i=1,6 do
        dataDI5.radios[i] = self.gamePalyingName[i+27].ch
    end
    local DI5 = DropItem.new(dataDI5)
    table.insert(self.DIList,DI5)
    self:addScrollItem(DI5)
    self:addScrollItem(CB1)

    -- local groupPanel2 = GroupPanel.new({panels = {DI4,DI5,CB1}, pad = 12,zorder = 200})--,offX = {0,-20,0}
    -- self:addScrollItem(groupPanel2)


    local dataDI6 =
    {
        --  标题，不传该参数则默认为不创建该文本
        title = "七花：",
        radios = {},
        callback = function(_index) -- 选择的callback  
            self.m_wanfa[7] =  self.gamePalyingName[_index+33].title
        end,
        clickback = function (_dropItem)
            for k,v in pairs(self.DIList) do
                if v ~= _dropItem then
                    v:hideList()
                end
            end
        end,
        width = 360
    }
    for i=1,3 do
        dataDI6.radios[i] = self.gamePalyingName[i+33].ch
    end
    local DI6 = DropItem.new(dataDI6)
    table.insert(self.DIList,DI6)
    self:addScrollItem(DI6)

-----------------------------------------------------------------------------------------------------------
   local dataCB2 = {
        title = "胡牌：",
        options = {},
        --  可配置属性，详见 CheckBoxPanel:initConfigList()
        Config ={
            LineVisible = true,--是否显示分割线
            Exclusive = false,--子项间是否互斥
            ResponseEvent = false,--点击是否响应事件
        }

    }
    for i=1,5 do
        if not dataCB2.options[i] then
            dataCB2.options[i] = {}
        end
        dataCB2.options[i].text = self.gamePalyingName[i].ch
    end
    local CB2 = CheckBoxPanel.new(dataCB2,function (_index,_isSelected)
        if _isSelected then
            self.m_wanfa[7+_index] = self.gamePalyingName[_index].title --，玩法2,3,4,5,6,7,8,9
        else
            self.m_wanfa[7+_index] = nil
        end    
    end)
    self:addScrollItem(CB2)
-----------------------------------------------------------------------------------------------------------
   local dataCB3 = {
        title = "玩法：",
        options = {},
        --  可配置属性，详见 CheckBoxPanel:initConfigList()
        Config ={
            LineVisible = true,--是否显示分割线
            Exclusive = false,--子项间是否互斥
            ResponseEvent = false,--点击是否响应事件
        }

    }
    for i=1,3 do
        if not dataCB3.options[i] then
            dataCB3.options[i] = {}
        end
        dataCB3.options[i].text = self.gamePalyingName[i+5].ch
    end
    local CB3 = CheckBoxPanel.new(dataCB3,function (_index,_isSelected)
        if _isSelected then
            self.m_wanfa[12+_index] = self.gamePalyingName[_index+5].title --，玩法2,3,4,5,6,7,8,9
        else
            self.m_wanfa[12+_index] = nil
        end    
    end)
    self:addScrollItem(CB3)
end

--支持地方组重写，该函数功能为填充self.m_setData.wa字段
function GameRoomInfoUI_shanweimj:wanFaFactory()
    Log.i("GameRoomInfoUI_shanweimj:wanFaFactory================",self.m_wanfa)
    -- 拼装字符串
    local str = ""
    for i, v in pairs(self.m_wanfa) do
        str = str == "" and v or string.format("%s|%s", str, v)
    end
    self.m_setData.wa = str
    print("<jinds>: wanfa str :", str)
end

return GameRoomInfoUI_shanweimj
