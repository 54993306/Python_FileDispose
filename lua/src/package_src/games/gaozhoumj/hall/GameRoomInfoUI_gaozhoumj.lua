require("app.DebugHelper")
local DropDownBoxPanel = require("app.games.common.custom.DropDownBox.DropDownBoxPanel")
local RadioButtonGroup = require("app.games.common.custom.RadioButtonGroup")
local SelectRadioPanel = require("app.hall.common.SelectRadioPanel")
local DropItem = require("app.games.common.custom.DropItem")

local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local GameRoomInfoUI_gaozhoumj = class("GameRoomInfoUI_gaozhoumj", GameRoomInfoUIBase )

function GameRoomInfoUI_gaozhoumj:initScore()

    local dataScore={
        title="底分:",
        radios={},
        datas={}
    };
    for i = 1, 4 do
       dataScore.radios[i] =self.gamePalyingName[i].ch;
       dataScore.datas[i] = self.gamePalyingName[i].title;
    end

    dataScore.callback = function(index)
      self.m_wanfa[1] = self.gamePalyingName[index].title;
    end

    self.m_items1=DropItem.new(dataScore)
    self:addScrollItem(self.m_items1)
    
end

function GameRoomInfoUI_gaozhoumj:change(index)
    if self.m_wanfa[4] and self.m_wanfa[5] then 
      wa4 =  self.m_wanfa[4]
      wa5 =  self.m_wanfa[5]
    end 

    if self.m_wanfa[2] =="bufanma" then 
      self.m_itemChildren[4]:setVisible(false)
      self.m_itemChildren[5]:setVisible(false)
      self.m_wanfa[4] = nil
      self.m_wanfa[5] = nil
      Log.i("self.m_wanfa====bufanma", self.m_wanfa)
    elseif 
      self.m_wanfa[2] =="fanmabywinner" and  self.m_itemChildren[5] then 
      self.m_itemChildren[4]:setVisible(true)
      self.m_itemChildren[5]:setVisible(true)
      self:viewLayout()
      self.m_wanfa[4] = wa4
      self.m_wanfa[5] = wa5
      Log.i("self.m_wanfa====fanma", self.m_wanfa) 
   end
end
 

--初始化玩法列表
function GameRoomInfoUI_gaozhoumj:initWanFa()
    self.gamePalyingName= {}---------------------新建玩法列表

    self.gamePalyingName = MjGameConfigManager[self.m_gameID]._gamePalyingName------获取玩法
    self:initScore()

    local dataSelectRadio1 =
    {
        title = "玩法:", radios = {self.gamePalyingName[5].ch, self.gamePalyingName[6].ch}, hiddenLine = true
    }

    local groupSelectRadio1 = SelectRadioPanel.new(dataSelectRadio1, function(index)
        self.m_wanfa[2] = self.gamePalyingName[index+4].title
        self:change(index)--
    
    end)

    self:addScrollItem(groupSelectRadio1)

    --  单选（第2排）
    local dataSelectRadio2 =
    {
        title = "", radios = {self.gamePalyingName[7].ch, self.gamePalyingName[8].ch}, hiddenLine = true
    }

    local dataSelectRadio2 = SelectRadioPanel.new(dataSelectRadio2, function(index)
        self.m_wanfa[3] = self.gamePalyingName[index + 6].title
    end) 

    dataSelectRadio2:setSelectedIndex(2)
    self:addScrollItem(dataSelectRadio2)

     local dataSelectRadio3 =
    {
        title = "", radios = {self.gamePalyingName[9].ch, self.gamePalyingName[10].ch}, hiddenLine = true
    }
    local dataSelectRadio3 = SelectRadioPanel.new(dataSelectRadio3, function(index)
        self.m_wanfa[4] = self.gamePalyingName[index + 8].title
    end)
    self:addScrollItem(dataSelectRadio3)

    local dataSelectRadio4 =
    {
        title = "买马:", radios = {self.gamePalyingName[11].ch, self.gamePalyingName[12].ch, self.gamePalyingName[13].ch,self.gamePalyingName[14].ch}, hiddenLine = true,line = 4
    }
    local dataSelectRadio4 = SelectRadioPanel.new(dataSelectRadio4, function(index)
        self.m_wanfa[5] = self.gamePalyingName[index +10 ].title
    end)
    dataSelectRadio4:setSelectedIndex(2)
    self:addScrollItem(dataSelectRadio4)



    if self.m_itemChildren then 
    Log.i("changdu", (#self.m_itemChildren))
    end
end




return GameRoomInfoUI_gaozhoumj