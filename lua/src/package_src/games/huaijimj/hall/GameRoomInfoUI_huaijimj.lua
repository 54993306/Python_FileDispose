
require("app.DebugHelper")

local DropDownBoxPanel = require("app.games.common.custom.DropDownBox.DropDownBoxPanel")

local SelectRadioPanel = require("app.hall.common.SelectRadioPanel")

local MjGameConfigManager = require("app.games.common.MjGameConfigManager")

local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")

local GameRoomInfoUI_huaijimj = class("GameRoomInfoUI_huaijimj", GameRoomInfoUIBase )


--初始化玩法列表
function GameRoomInfoUI_huaijimj:initWanFa()
     
     --local SelectRadioPanel = require("package_src.games.huaijimj.hall.SelectRadioPanel")

    self.gamePalyingName= {}---------------------新建玩法列表

    self.gamePalyingName = MjGameConfigManager[self.m_gameID]._gamePalyingName------获取玩法

     local dataSelectRadio1 =
    {
        title = "玩法:", radios = {self.gamePalyingName[1].ch, self.gamePalyingName[2].ch}, hiddenLine = true
    }
    local groupSelectRadio1 = SelectRadioPanel.new(dataSelectRadio1, function(index)
        self.m_wanfa[1] = self.gamePalyingName[index].title
    end)
    self:addScrollItem(groupSelectRadio1)

    
    local dataSelectRadio2 =
    {
        title = "买马:", radios = {self.gamePalyingName[3].ch, 
            self.gamePalyingName[4].ch, 
            self.gamePalyingName[5].ch,
            self.gamePalyingName[6].ch,
            self.gamePalyingName[7].ch,
            }, 
            hiddenLine = true
    }
    local groupSelectRadio2 = SelectRadioPanel.new(dataSelectRadio2, function(index)
        self.m_wanfa[2] = self.gamePalyingName[index + 2].title
    end)
    self:addScrollItem(groupSelectRadio2)

    local dataSelectRadio3 =
    {
        title = "", 
        radios = {self.gamePalyingName[8].ch, 
            self.gamePalyingName[9].ch, 
            }, 
        hiddenLine = true
    }
    local groupSelectRadio3 = SelectRadioPanel.new(dataSelectRadio3, function(index)
        self.m_wanfa[3] = self.gamePalyingName[index + 7].title
    end)
    groupSelectRadio3:setSelectedIndex(1)
    self:addScrollItem(groupSelectRadio3)
end


return GameRoomInfoUI_huaijimj