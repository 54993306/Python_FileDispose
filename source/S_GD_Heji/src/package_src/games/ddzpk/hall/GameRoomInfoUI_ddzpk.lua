
require("app.DebugHelper")

local CheckBoxPanel = require("app.games.common.custom.CheckBoxPanel")
local SelectRadioPanel = require "app.hall.common.SelectRadioPanel"

local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
local GameRoomInfoUI_ddzpk = class("GameRoomInfoUI_ddzpk", GameRoomInfoUIBase)

local serverWanFaTxt = {
    ["wanfa"] = 1,
}

function GameRoomInfoUI_ddzpk:ctor(...)
    self.super.ctor(self, ...)
end

function GameRoomInfoUI_ddzpk:onInit()
    --[[
        ##  gaI  int  游戏ID
        ##  roS  String  局数
        ##  RoFS  String  房费数量
        ##  di  String  底分
        ##  fe  String  封顶
        ##  wa  String  玩法
        ##  plS int     人数
        ##  RoJST int   付费类型 1 =房主付费，2 =大赢家付费，3 =AA付费
        ##  re  int  结果（-1 =创建失败不够资源，-2 =创建失败无可用房间， 非0 = 房间密码）
]]

    self.m_wanfa = { }

    self:changPlayerNumber({3})
end

-- function GameRoomInfoUI_ddzpk:playerNumChange(playerNum)
--     if self.payTypeRadioGoup then
--         if self.payTypeRadioGoup:getSelectedIndex() == 3 then
--             self.payTypeRadioGoup:setSelectedIndex(1)
--         end
--         local btn = self.payTypeRadioGoup:getBtnByIndex(3)
--         btn:setEnabled(playerNum == 3)
--     end
-- end


-- 初始化玩法列表
function GameRoomInfoUI_ddzpk:initWanFa()

    self:initCallLord()

    self:initTopBeiShu()

    self:initWfa()
end

function GameRoomInfoUI_ddzpk:initTopBeiShu(  )
    local tag = 1
    if self.m_wanfa[1] and self.m_wanfa[1] == "2b" then
        tag = 8
    end

    local dataSelectRadio1 =
    {
        title = "封顶:",
        radios = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[tag].ch, 
            MjGameConfigManager[self.m_gameID]._gamePalyingName[tag+1].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[tag+2].ch,
        },
        hiddenLine = true,
        count = 3
    }
    
    if IsPortrait then
    	dataSelectRadio1.width = (G_ROOM_INFO_FORMAT.lineWidth - 170) / 3
    end

    if self.groupSelectRadio1 then

        self.groupSelectRadio1:refreshRadios(dataSelectRadio1.radios, self.groupSelectRadio1:getSelectedIndex(),function (index)
            self.m_wanfa[2] = MjGameConfigManager[self.m_gameID]._gamePalyingName[index].title
        end)
        self:viewLayout()
    else

        self.groupSelectRadio1 = SelectRadioPanel.new(dataSelectRadio1, function(index)
            self.m_wanfa[2] = MjGameConfigManager[self.m_gameID]._gamePalyingName[index].title
        end)  
        self.groupSelectRadio1:setSelectedIndex(1)
        self:addScrollItem(self.groupSelectRadio1)   
    end
  
end


function GameRoomInfoUI_ddzpk:initWfa(  )

    local dataWanFa2 =
    {
        title = "玩法:",
        options =
        {
            {text = MjGameConfigManager[self.m_gameID]._gamePalyingName[6].ch,isSelected = true},
            {text = MjGameConfigManager[self.m_gameID]._gamePalyingName[7].ch,isSelected = true},
        },
        --  可配置属性，详见 CheckBoxPanel:initConfigList()
        Config =
        {
            LineVisible = true,Exclusive = false,ResponseEvent = true,
        }
    }
    local callback2 = function(tag ,flag) -- 选择的callback  
        local tagType = tolua.type(tag)
        if tagType ~= "number" then
            for i, v in pairs(tag) do
                if v._select then
                    self.m_wanfa[i+2] =  MjGameConfigManager[self.m_gameID]._gamePalyingName[i + 5].title
                else
                    self.m_wanfa[i+2] = nil
                end
            end
            return
        end
        if flag then
            self.m_wanfa[tag+2] =  MjGameConfigManager[self.m_gameID]._gamePalyingName[tag + 5].title
        else
            self.m_wanfa[tag+2] = nil
        end       
    end
    local groupWanFa2 = CheckBoxPanel.new(dataWanFa2,callback2)    
    self:addScrollItem(groupWanFa2)

end

function GameRoomInfoUI_ddzpk:initCallLord(  )

     local dataSelectRadio1 =
    {
        title = "叫地主:", 
        radios = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[4].ch, 
            MjGameConfigManager[self.m_gameID]._gamePalyingName[5].ch,
        }, 
        hiddenLine = true,
    }
    local groupSelectRadio2 = SelectRadioPanel.new(dataSelectRadio1, function(index)

        self.m_wanfa[1] = MjGameConfigManager[self.m_gameID]._gamePalyingName[index + 3].title
        if self.groupSelectRadio1 then
            self:updateTopBeishu()
        end
    end)

    if groupSelectRadio2 and not tolua.isnull(groupSelectRadio2.m_title) then
        groupSelectRadio2.m_title:setFontSize(30)
    end

    groupSelectRadio2:setSelectedIndex(1)

    self:addScrollItem(groupSelectRadio2)
end

function GameRoomInfoUI_ddzpk:updateTopBeishu()
    self:initTopBeiShu( )
end


function GameRoomInfoUI_ddzpk:wanFaFactory()
    -- 拼装字符串
    local str = ""
    for i, v in pairs(self.m_wanfa) do
        if type(v) == "table" then
            if table.nums(v) > 0 then
                for j, k in pairs(v) do
                    str = str == "" and k or string.format("%s|%s", str, k)
                end
            end
        else
            str = str == "" and v or string.format("%s|%s", str, v)
        end
    end
    self.m_setData.wa = str
end


function GameRoomInfoUI_ddzpk:initRoomInfo()
    local baseItemChildren = self.m_baseItemChildren
    local itemChildren = {}
    for i,v in pairs(baseItemChildren) do
        itemChildren[tostring(i)] = v
    end
    baseItemChildren = itemChildren
    for i,v in pairs(baseItemChildren) do
        if v.m_data and v.m_data.title and v.m_data.title == "局数:" then
            table.remove( baseItemChildren,tostring(i))
            baseItemChildren[tostring(i)] = v
            break;
        end
    end
    for i,v in pairs(baseItemChildren) do
        if v and type(v) == "userdata" and v.m_radioBtns then
            self._friendRoomDataManager:updateRoomPanel(v,tostring(i))
        end
    end
    
    local itemChildren = self.m_itemChildren
    for i, v in pairs(itemChildren) do
        if v and type(v) == "userdata" then
            if v.m_radioBtns then
                self._friendRoomDataManager:updateRoomPanel(v,string.format( "wanfa%d",i) ,v.m_callback)
            else
                self._friendRoomDataManager:updateRoomCheckPanel(v,string.format( "wanfa%d",i),v.m_callback)
            end
        end
    end
end

function GameRoomInfoUI_ddzpk:saveRoomInfo()
    local wanfa = self.m_itemChildren
    for i, v in pairs(wanfa) do
        if v and type(v) == "userdata" then
            if v.m_radioBtns then
                self._friendRoomDataManager:savePanelAllData(v.m_radioBtns,string.format( "wanfa%d",i))
            else
                self._friendRoomDataManager:setCheckPanelAllData(v,string.format( "wanfa%d",i))
            end
        end
    end
    local baseItemChildren = self.m_baseItemChildren
    for i,v in pairs(baseItemChildren) do
        if v and type(v) == "userdata" and v.m_radioBtns then
            self._friendRoomDataManager:savePanelAllData(v.m_radioBtns,tostring(i))
        end
    end
end


return GameRoomInfoUI_ddzpk