--
-- Author: RuiHao Lin
-- Date: 2017-05-08 10:17:58
--

require("app.DebugHelper")
local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
local CheckBoxPanel = require("app.games.common.custom.CheckBoxPanel")
local lRadioButtonGroupPath = "app.games.common.custom.RadioButtonGroup"
-- local DropDownBoxPanel = require("app.games.common.custom.DropDownBox.DropDownBoxPanel")


local GameRoomInfoUI_xuanchengbandaohumj = class("GameRoomInfoUI_xuanchengbandaohumj", GameRoomInfoUIBase )


function GameRoomInfoUI_xuanchengbandaohumj:ctor(...)
    self.super.ctor(self, ...)

    -- self.m_items:setLocalZOrder(999)
end


local wanFaIndexOffset1  = 4  --玩法下标的偏移量
local wanFaIndexOffset2  = 5  --玩法下标的偏移量
local diFenIndexOffset  = 7   --买马玩法下标的偏移量

--地方组重写 初始化自己特有的数据
function GameRoomInfoUI_xuanchengbandaohumj:onInit()
    -- self.m_difen = {}
    self.m_maiMa = {}
    self.m_setData = { }
    self.m_wanfa = { }
    self.m_difen = {}
    self.gamePalyingName = MjGameConfigManager[self.m_gameID]._gamePalyingName
    self.wanFaItem = {
        Item_1 = 1,
        Item_2 = 2,
        Item_3 = 3,
        Item_4 = 4,
    }
   
end

function GameRoomInfoUI_xuanchengbandaohumj:initWanFa()
    local RadioButtonGroup = require(lRadioButtonGroupPath)
     local dataWanFa =
    {
        title = "底分：",
        options =
        {
            { text = self.gamePalyingName[1].ch,isSelected = true},
            { text = self.gamePalyingName[2].ch},
            { text = self.gamePalyingName[3].ch},
            { text = self.gamePalyingName[4].ch},
        },
    }
   local groupWanFa = RadioButtonGroup.new(dataWanFa, function(index)
        self.m_wanfa[self.wanFaItem.Item_1] = self.gamePalyingName[index].title
        self.m_difen[self.wanFaItem.Item_1]= MjGameConfigManager[self.m_gameID]._gamePalyingName[index].title
    end )
    self:addScrollItem(groupWanFa)


    local dataWanFa1 =
    {
        title = "玩法：",
        options =
        {
            { text = MjGameConfigManager[self.m_gameID]._gamePalyingName[5].ch},
        },
        Config =
        {
            LineVisible = true,
        }
    }
      local  wanfapanal1= CheckBoxPanel.new(dataWanFa1, function(tag, isSelected)
        local index = tag + wanFaIndexOffset1
        if isSelected then
            self.m_wanfa[self.wanFaItem.Item_2] = MjGameConfigManager[self.m_gameID]._gamePalyingName[index].title
        else
            self.m_wanfa[self.wanFaItem.Item_2] = nil
        end
    end)
    self:addScrollItem(wanfapanal1)


     local dataWanFa2 =
    {
        options =
        {
            { text = MjGameConfigManager[self.m_gameID]._gamePalyingName[6].ch, isSelected =true},
            { text = MjGameConfigManager[self.m_gameID]._gamePalyingName[7].ch},
        },
        Config =
        {
            LineVisible = true,Exclusive = true, 
        }
    }
    local wanfaPanel2= CheckBoxPanel.new(dataWanFa2, function(tag, isSelected)
        local index = tag + wanFaIndexOffset2
        if isSelected then
            self.m_wanfa[self.wanFaItem.Item_4+tag] = MjGameConfigManager[self.m_gameID]._gamePalyingName[index].title
        else
            self.m_wanfa[self.wanFaItem.Item_4+tag] = nil
        end
    end)
    self:addScrollItem(wanfaPanel2)


    local RadioButtonGroup = require(lRadioButtonGroupPath)
     local dataWanFa3 =
    {
        title = "买马：",
        options =
        {
            { text = self.gamePalyingName[8].ch,isSelected = true},
            { text = self.gamePalyingName[9].ch},
            { text = self.gamePalyingName[10].ch},
            { text = self.gamePalyingName[11].ch},
        },
    }
   local wanfaPanel3 = RadioButtonGroup.new(dataWanFa3, function(index)
        self.m_wanfa[self.wanFaItem.Item_3] = self.gamePalyingName[index + diFenIndexOffset].title
         self.m_maiMa[self.wanFaItem.Item_1] = MjGameConfigManager[self.m_gameID]._gamePalyingName[index+diFenIndexOffset].title
    end )
    self:addScrollItem(wanfaPanel3)

   --  self:initYouHunziHu()
end

function GameRoomInfoUI_xuanchengbandaohumj:getData()
    self.m_setData.gaI = self.m_gameID;
    -- 玩法工厂
    
    self:fanmaFactory()
    self:wanfaFactory()
    self:jiadiFactory()

    return self.m_setData;
end

--[[
-- @brief  玩法组装工厂函数
-- @param  void
-- @return void
--]]
function GameRoomInfoUI_xuanchengbandaohumj:wanfaFactory()
    -- 拼装字符串
    local str = ""
    for i, v in pairs(self.m_wanfa) do
        Log.i("m_wanfa",m_wanfa)
        str = str == "" and v or string.format("%s|%s", str, v)
    end
    Log.i("str//",str)
    self.m_setData.wa = str
end
function GameRoomInfoUI_xuanchengbandaohumj:fanmaFactory()
    local str = 0
    Log.i("self.m_MaiMa.........",self.m_maiMa)
    local number = kFriendRoomInfo:getPlayingInfoByTitle(self.m_maiMa[1]).number
    self.m_setData.fa = number
end
function GameRoomInfoUI_xuanchengbandaohumj:jiadiFactory()
    local str = ""
    for i,v in pairs(self.m_difen) do
        str = str == "" and v or string.format("%s|%s",str,v)
    end
    self.m_setData.ji = tonumber(str)
end

return GameRoomInfoUI_xuanchengbandaohumj