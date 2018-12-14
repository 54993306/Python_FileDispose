
require("app.DebugHelper")

local DropDownBoxPanel = require("app.games.common.custom.DropDownBox.DropDownBoxPanel")

local SelectRadioPanel = require("app.hall.common.SelectRadioPanel")

local CheckBoxPanel = require("app.games.common.custom.CheckBoxPanel")

local MjGameConfigManager = require("app.games.common.MjGameConfigManager")

local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")

local GameRoomInfoUI_guangdongzptdhmj = class("GameRoomInfoUI_guangdongzptdhmj", GameRoomInfoUIBase )


--初始化玩法列表
function GameRoomInfoUI_guangdongzptdhmj:initWanFa()
     
     --local SelectRadioPanel = require("package_src.games.guangdongzptdhmj.hall.SelectRadioPanel")

    local _gamePalyingName= {}---------------------新建玩法列表

    _gamePalyingName = MjGameConfigManager[self.m_gameID]._gamePalyingName------获取玩法


    self.m_wanfa[1] = {}
    local data1 =
    {
        title = "玩法:", 
        
        options =
        {
            {text = _gamePalyingName[1].ch, isSelected = false},
            {text = _gamePalyingName[2].ch, isSelected = true},
            {text = _gamePalyingName[3].ch, isSelected = true},
            {text = _gamePalyingName[4].ch, isSelected = false},
            {text = _gamePalyingName[5].ch, isSelected = true},
            {text = _gamePalyingName[6].ch, isSelected = false},
            {text = _gamePalyingName[7].ch, isSelected = false},
            {text = "2倍", isSelected = false},
            {text = _gamePalyingName[9].ch, isSelected = true},
            {text = _gamePalyingName[10].ch, isSelected = true},
            {text = _gamePalyingName[11].ch, isSelected = true},
            {text = _gamePalyingName[12].ch, isSelected = true},
            {text = _gamePalyingName[13].ch, isSelected = true},
            {text = _gamePalyingName[14].ch, isSelected = true},
        },
        Config =
        {
            LineVisible = false,
            ResponseEvent = true,
            MaxCol = 2,
        }
    }
    self.wanfaPanel1 = CheckBoxPanel.new(data1, function(tag, flag)
        if flag then
            self.m_wanfa[1][tag] =  _gamePalyingName[tag].title
        else
            self.m_wanfa[1][tag] = nil
        end 

        if self.wanfaPanel1 == nil or self.wanfaPanel2 == nil then
            return
        end
        -- “不带风”与“全风8倍和十三幺8倍”为互斥关系。勾选了“不带风”时，“全风8倍和十三幺8倍”不可勾选
        if tag == 1 then
            self.wanfaPanel1:setSelectedIndex(false, 12)
            self.wanfaPanel1:setSelectedIndex(false, 13)
            self.wanfaPanel1:setBtnEnabled(12, not flag)
            self.wanfaPanel1:setBtnEnabled(13, not flag)
            self.m_wanfa[1][12] = nil
            self.m_wanfa[1][13] = nil
        end
        if tag == 12 or tag == 13 then
            local daiFengEnable = nil
            if self.wanfaPanel1:getSelectedByIndex(12) == true or self.wanfaPanel1:getSelectedByIndex(13) == true then
                daiFengEnable = false
            else
                daiFengEnable = true
            end
            self.wanfaPanel1:setSelectedIndex(false, 1)
            self.wanfaPanel1:setBtnEnabled(1, daiFengEnable)
            self.m_wanfa[1][1] = nil
        end

        -- 只有勾选了可抢杠胡时才能勾选可抢明杠和抢杠全包
        if tag == 3 then
            self.wanfaPanel1:setSelectedIndex(false, 4)
            self.wanfaPanel1:setBtnEnabled(4, flag)
            self.m_wanfa[1][4] = nil
            
            -- 没有选择明杠可抢时，马跟杠可选
            self.wanfaPanel6:setBtnEnabled(2, true)

            self.wanfaPanel1:setSelectedIndex(false, 5)
            self.wanfaPanel1:setBtnEnabled(5, flag)
            self.m_wanfa[1][5] = nil
        end
        -- 勾选了明杠可抢就不能勾选马跟杠
        if tag == 4 then
            self.wanfaPanel6:setSelectedIndex(false, 2)
            self.wanfaPanel6:setBtnEnabled(2, not flag)
            self.m_wanfa[6][2] = nil
        end


        -- 只有勾选了四鬼胡牌时才能勾选四鬼胡牌2倍，
        if tag == 7 then
            self.wanfaPanel1:setSelectedIndex(false, 8)
            self.wanfaPanel1:setBtnEnabled(8, flag)
            self.m_wanfa[1][8] = nil

            -- 勾选了四鬼胡牌不能勾选无鬼
            self.wanfaPanel2.m_radioBtns[1]:setEnabled(not flag)

            if self.wanfaPanel2:getSelectedIndex() == 3 then
                self.wanfaPanel3:setSelectedIndex(false, 1)
                self.wanfaPanel3:setBtnEnabled(1, not flag)
                self.m_wanfa[3] = nil
            end
        end
        if tag == 8 then
            if flag then
                self.m_wanfa[1][7] = nil
            else
                self.m_wanfa[1][7] = _gamePalyingName[7].title
            end
        end
    end)
    self.wanfaPanel1:setBtnEnabled(1, false)
    self.wanfaPanel1:setBtnEnabled(8, false)
    self:addScrollItem(self.wanfaPanel1)

    
    local data2 =
    {
        title = "鬼牌:", radios = 
        {
            _gamePalyingName[15].ch, 
            _gamePalyingName[16].ch,
            _gamePalyingName[17].ch,
        }, 
        count = 2,
        hiddenLine = true
    }
    self.wanfaPanel2 = SelectRadioPanel.new(data2, function(tag)
        local index = tag + 14
        self.m_wanfa[2] = _gamePalyingName[index].title

        if self.wanfaPanel1 == nil or self.wanfaPanel3 == nil or self.wanfaPanel4 == nil then
            return
        end

        -- 翻鬼时才能勾选双鬼  需要先处理这个因为后面有对wanfaPanel3的判断
        if tag == 3 then
            if self.wanfaPanel1:getSelectedByIndex(7) == false then
                self.wanfaPanel3:setBtnEnabled(1, true)
            end
        else
            self.wanfaPanel3:setSelectedIndex(false, 1)
            self.wanfaPanel3:setBtnEnabled(1, false)
            self.m_wanfa[3] = nil
        end

        -- 无鬼时不能勾选四鬼胡牌(2倍)和无鬼加倍
        if tag == 1 then
            self.wanfaPanel1:setSelectedIndex(false, 7)
            self.wanfaPanel1:setBtnEnabled(7, false)
            self.m_wanfa[1][7] = nil
            self.wanfaPanel1:setSelectedIndex(false, 8)
            self.wanfaPanel1:setBtnEnabled(8, false)
            self.m_wanfa[1][8] = nil

            self.wanfaPanel4:setSelectedIndex(false, 1)
            self.wanfaPanel4:setBtnEnabled(1, false)
            self.m_wanfa[4] = nil
        else
            self.wanfaPanel4:setBtnEnabled(1, true)
            if self.wanfaPanel3:getSelectedByIndex(1) == false then
                self.wanfaPanel1:setBtnEnabled(7, true)
            end
        end
    end)
    self.wanfaPanel2:setSelectedIndex(3)
    self:addScrollItem(self.wanfaPanel2)

    local data3 =
    {
        title = "", 
        options = 
        {
            {text = _gamePalyingName[18].ch,isSelected = true},
        }, 
        Config =
        {
            LineVisible = false,
        }
    }
    self.wanfaPanel3 = CheckBoxPanel.new(data3, function(tag, flag)
        if flag then
            self.m_wanfa[3] =  _gamePalyingName[18].title

            -- 选了双鬼不能选择四鬼胡牌
            self.wanfaPanel1:setSelectedIndex(false, 7)
            self.wanfaPanel1:setBtnEnabled(7, false)
            self.m_wanfa[1][7] = nil
            self.wanfaPanel1:setSelectedIndex(false, 8)
            self.wanfaPanel1:setBtnEnabled(8, false)
            self.m_wanfa[1][8] = nil
        else
            self.m_wanfa[3] = nil

            self.wanfaPanel1:setBtnEnabled(7, true)
        end    
    end)
    self.wanfaPanel3:setPositionX(G_ROOM_INFO_FORMAT.radioItemOffset)
    self.wanfaPanel2:addChild(self.wanfaPanel3)

    local data4 =
    {
        title = "", 
        options = 
        {
            {text = _gamePalyingName[19].ch,isSelected = true},
        }, 
        Config =
        {
            LineVisible = false,
        }
    }
    self.wanfaPanel4 = CheckBoxPanel.new(data4, function(tag, flag)
        if flag then
            self.m_wanfa[4] =  _gamePalyingName[19].title
        else
            self.m_wanfa[4] = nil
        end    
    end)
    self:addScrollItem(self.wanfaPanel4)
    
    local data5 =
    {
        title = "马牌:", radios = 
        {
            _gamePalyingName[25].ch, 
            _gamePalyingName[20].ch, 
            _gamePalyingName[21].ch,
            _gamePalyingName[22].ch,
        }, 
        count = 2,
        hiddenLine = true
    }
    self.wanfaPanel5 = SelectRadioPanel.new(data5, function(tag)
        if tag == 1 then
            self.m_wanfa[5] =  _gamePalyingName[25].title
            if self.wanfaPanel6 then
                self.wanfaPanel6:setSelectedIndex(false, 1)
                self.wanfaPanel6:setSelectedIndex(false, 2)
                self.wanfaPanel6:setBtnEnabled(1, false)
                self.wanfaPanel6:setBtnEnabled(2, false)
                self.m_wanfa[6] = {}
            end
        else
            local index = tag + 18
            self.m_wanfa[5] = _gamePalyingName[index].title
            if self.wanfaPanel6 then
                self.wanfaPanel6:setBtnEnabled(1, true)
                self.wanfaPanel6:setBtnEnabled(2, true)
            end
        end
    end)
    self.wanfaPanel5:setSelectedIndex(4)
    self:addScrollItem(self.wanfaPanel5)

    self.m_wanfa[6] = {}
    local data6 =
    {
        title = "", 
        options = 
        {
            {text = _gamePalyingName[23].ch,isSelected = false},
            {text = _gamePalyingName[24].ch,isSelected = false},
        }, 
        Config =
        {
            LineVisible = false,
        }
    }
    self.wanfaPanel6 = CheckBoxPanel.new(data6, function(tag, flag)
        local index = tag + 22
        if flag then
            self.m_wanfa[6][tag] =  _gamePalyingName[index].title
        else
            self.m_wanfa[6][tag] = nil
        end

        if self.wanfaPanel1 == nil or self.wanfaPanel5 == nil or self.wanfaPanel6 == nil then
            return
        end

        -- 勾选了马跟杠，明杠可抢不能勾选
        if tag == 2 then
            self.wanfaPanel1:setSelectedIndex(false, 4)
            self.wanfaPanel1:setBtnEnabled(4, not flag)
            self.m_wanfa[1][4] = nil
        end
        self:checkWanfaPanel6()
    end)
    self:addScrollItem(self.wanfaPanel6)
end

function GameRoomInfoUI_guangdongzptdhmj:playerNumChange(playerNum)
    if playerNum < 4 then
        if not tolua.isnull(self.wanfaPanel1) then
            self.wanfaPanel1:setSelectedIndex(false, 6)
            self.wanfaPanel1:setBtnEnabled(6, false)
            self.m_wanfa[1][6] = nil
        end

        if not tolua.isnull(self.wanfaPanel6) then
            self.wanfaPanel6:setSelectedIndex(false, 2)
            self.wanfaPanel6:setBtnEnabled(2, false)
            self.m_wanfa[6][2] = nil
            self:checkWanfaPanel6()
        end
        
    else
        if not tolua.isnull(self.wanfaPanel1) then
            self.wanfaPanel1:setBtnEnabled(6, true)
        end
        if not tolua.isnull(self.wanfaPanel6) then
            self.wanfaPanel6:setBtnEnabled(2, true)
        end
    end
end

function GameRoomInfoUI_guangdongzptdhmj:checkWanfaPanel6()
    -- 2个任意勾选一个就不能选择无马
    if self.wanfaPanel6:getSelectedByIndex(1) or self.wanfaPanel6:getSelectedByIndex(2) then
        -- if self.wanfaPanel5:getSelectedIndex() == 1 then
        --     self.wanfaPanel5:setSelectedIndex(4)
        --     self.m_wanfa[5] = _gamePalyingName[22].title
        -- end
        self.wanfaPanel5.m_radioBtns[1]:setEnabled(false)
    else
        self.wanfaPanel5.m_radioBtns[1]:setEnabled(true)
    end
end

return GameRoomInfoUI_guangdongzptdhmj