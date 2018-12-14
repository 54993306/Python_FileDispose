
require("app.DebugHelper")

-- local DropDownBoxPanel = require("app.games.common.custom.DropDownBox.DropDownBoxPanel")

-- local SelectRadioPanel = require("app.hall.common.SelectRadioPanel")
local RadioButtonGroup = require("app.games.common.custom.RadioButtonGroup")
local CheckBoxPanel = require("app.games.common.custom.CheckBoxPanel")
local DropItem = require("app.games.common.custom.DropItem")

local MjGameConfigManager = require("app.games.common.MjGameConfigManager")

local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")

local GameRoomInfoUI_shantoumj = class("GameRoomInfoUI_shantoumj", GameRoomInfoUIBase )

function GameRoomInfoUI_shantoumj:onInit()
    self.dropData = {}
end

function GameRoomInfoUI_shantoumj:playerNumChange(playerNum)
    if playerNum < 4 and self.wanfaPanel3 then
        self.wanfaPanel3:setSelectIndex(1)
        self.wanfaPanel3:setEnabled(false)
        self.m_wanfa[3] = nil
    elseif playerNum == 4 and self.wanfaPanel3  then
        self.wanfaPanel3:setEnabled(true)
    end
end

-- 初始化玩法列表
function GameRoomInfoUI_shantoumj:initWanFa()
    self.gamePalyingName= {}---------------------新建玩法列表

    self.gamePalyingName = MjGameConfigManager[self.m_gameID]._gamePalyingName------获取玩法

    local data1 = {
        title="分数:",
        radios = {
            self.gamePalyingName[1].ch,
            self.gamePalyingName[2].ch,
            self.gamePalyingName[3].ch,
            self.gamePalyingName[4].ch,
        },  -- 未选中情况下的文字
        index           = 1, -- 序号
        callback        = function(index)
            self.m_wanfa[1] = self.gamePalyingName[index].title
        end, -- 选中选项时的回调
        clickback= function()
            if self.wanfaPanel2 then
                self.wanfaPanel2:hideList()
            end
            if self.wanfaPanel3 then
                self.wanfaPanel3:hideList()
            end
        end, --点击按钮回调
        zorder=2,
        width=200, --调整条目的宽
        line = false,
        initX = 30,
    }
    self.wanfaPanel1 = DropItem.new(data1)
    self:addScrollItem(self.wanfaPanel1)

    local data2 = {
        title="奖马:",
        radios = {
            "0马",
            "2马",
            "4马",
            "5马",
            "6马",
            "7马",
            "8马",
            "9马",
            "10马",
        },  -- 未选中情况下的文字
        index           = 4, -- 序号
        callback        = function(index)
            if index == 1 then
                if self.wanfaPanel5 and self.wanfaPanel6 then
                    if self.m_wanfa[5] == self.gamePalyingName[23].title then
                        self.wanfaPanel5:onBtnTouchEvent(self.wanfaPanel5.m_ButtonList[1], ccui.TouchEventType.ended)
                    end
                    self:setBtnEnable(self.wanfaPanel5, 3, false)

                    if self.m_wanfa[6] == self.gamePalyingName[26].title then
                        self.wanfaPanel6:onBtnTouchEvent(self.wanfaPanel6.m_ButtonList[1], ccui.TouchEventType.ended)
                    end
                    self:setBtnEnable(self.wanfaPanel6, 4, false)
                end
                if self.wanfaPanel7 then
                    self.wanfaPanel7:setSelectedIndex(false, 1)
                    self.wanfaPanel7:setBtnEnabled(1, false)
                    self.m_wanfa[7] = nil
                end

                self.m_wanfa[2] = nil
            else
                if self.wanfaPanel5 and self.wanfaPanel6 then
                    self:setBtnEnable(self.wanfaPanel5, 3, true)
                    self:setBtnEnable(self.wanfaPanel6, 4, true)
                end

                if self.wanfaPanel7 then
                    self.wanfaPanel7:setBtnEnabled(1, true)
                end
                self.m_wanfa[2] = self.gamePalyingName[index + 4].title
            end
        end, -- 选中选项时的回调
        clickback= function()
            if self.wanfaPanel1 then
                self.wanfaPanel1:hideList()
            end
            if self.wanfaPanel3 then
                self.wanfaPanel3:hideList()
            end
        end, --点击按钮回调
        zorder=2,
        width=200, --调整条目的宽
        line = false,
        initX = 30,
    }
    self.m_wanfa[2] =  self.gamePalyingName[4 + 4].title
    self.wanfaPanel2 = DropItem.new(data2)
    self:addScrollItem(self.wanfaPanel2)

    local data3 = {
        title="买马:",
        radios = {
            "0马",
            "1马",
            "2马",
            "3马",
            "4马",
            "5马",
        },  -- 未选中情况下的文字
        index           = 3, -- 序号
        callback        = function(index)
            if index == 1 then
                self.m_wanfa[3] = nil
            else
                self.m_wanfa[3] = self.gamePalyingName[index + 13].title
            end
        end, -- 选中选项时的回调
        clickback= function()
            if self.wanfaPanel2 then
                self.wanfaPanel2:hideList()
            end
            if self.wanfaPanel1 then
                self.wanfaPanel1:hideList()
            end
        end, --点击按钮回调
        zorder=2,
        width=200, --调整条目的宽
        line = false,
    }
    self.m_wanfa[3] =  self.gamePalyingName[3 + 13].title
    self.wanfaPanel3 = DropItem.new(data3)
    self.wanfaPanel2:addChild(self.wanfaPanel3)
    self.wanfaPanel3:setPositionX(337)

    -- 玩法选项
    local data4 =
    {
        title = "玩法:",
        options =
        {
            {text = self.gamePalyingName[20].ch,isSelected = true},
            {text = self.gamePalyingName[21].ch,isSelected = false},
        },
        Config =
        {
            LineVisible = false,ResponseEvent = true,MaxCol = 1,
        }
    }
    self.wanfaPanel4 = RadioButtonGroup.new(data4, function(index, groupIdx)
        -- if index == 1 then 

        -- elseif index == 2 then 

        -- end
        self.m_wanfa[4] =  self.gamePalyingName[index + 19].title ----玩法4
    end )

    self:addScrollItem(self.wanfaPanel4)

    -- 黄庄选项
    local data5 =
    {
        title = "",
        options =
        {
            {text = "黄庄无说法",isSelected = true},
            {text = self.gamePalyingName[22].ch,isSelected = false},
            {text = self.gamePalyingName[23].ch,isSelected = false},
        },
        Config =
        {
            LineVisible = false,ResponseEvent = true,
        }
    }
    self.wanfaPanel5 = RadioButtonGroup.new(data5, function(index, groupIdx)
        if index == 1 then
            self.m_wanfa[5] = nil
            if self.wanfaPanel6~= nil then
                self:setBtnEnable(self.wanfaPanel6, 2, true)
                self:setBtnEnable(self.wanfaPanel6, 3, true)
                if self.m_wanfa[2] ~= self.gamePalyingName[5].title then
                    self:setBtnEnable(self.wanfaPanel6, 4, true)
                end
            end
        else
            if index == 2 and self.wanfaPanel6~= nil then
                if self.m_wanfa[6] == self.gamePalyingName[26].title then
                    self.wanfaPanel6:onBtnTouchEvent(self.wanfaPanel6.m_ButtonList[1], ccui.TouchEventType.ended)
                end
                self:setBtnEnable(self.wanfaPanel6, 2, true)
                self:setBtnEnable(self.wanfaPanel6, 3, true)
                self:setBtnEnable(self.wanfaPanel6, 4, false)

            elseif index == 3 and self.wanfaPanel6 ~= nil then
                if self.m_wanfa[6] == self.gamePalyingName[24].title or self.m_wanfa[6] == self.gamePalyingName[25].title  then
                    self.wanfaPanel6:onBtnTouchEvent(self.wanfaPanel6.m_ButtonList[1], ccui.TouchEventType.ended)
                end
                self:setBtnEnable(self.wanfaPanel6, 2, false)
                self:setBtnEnable(self.wanfaPanel6, 3, false)
                self:setBtnEnable(self.wanfaPanel6, 4, true)
            end
            self.m_wanfa[5] =  self.gamePalyingName[index + 20].title ----玩法5
        end
    end )

    self:addScrollItem(self.wanfaPanel5)

    -- 连庄选项
    local data6 =
    {
        title = "",
        options =
        {
            {text = "连庄无说法",isSelected = true},
            {text = self.gamePalyingName[24].ch,isSelected = false},
            {text = self.gamePalyingName[25].ch,isSelected = false},
            {text = self.gamePalyingName[26].ch,isSelected = false},
        },
        Config =
        {
            LineVisible = false,ResponseEvent = true,MaxCol = 2,
        }
    }
    self.wanfaPanel6 = RadioButtonGroup.new(data6, function(index, groupIdx)
        
        if index == 1 then
            self.m_wanfa[6] = nil
        else
            if index == 3 then

            end
            self.m_wanfa[6] = self.gamePalyingName[index + 22].title ----玩法4
        end
    end )

    self:addScrollItem(self.wanfaPanel6)

    -- 玩法复选框
    local data7 =
    {
        title = "",
        options =
        {
            {text = self.gamePalyingName[27].ch,isSelected = false},
            {text = self.gamePalyingName[28].ch,isSelected = false},
            {text = self.gamePalyingName[29].ch,isSelected = false},
        },
        --  可配置属性，详见 CheckBoxPanel:initConfigList()
        Config =
        {
            LineVisible = false,Exclusive = false,ResponseEvent = true,
        }
    }
    self.wanfaPanel7 = CheckBoxPanel.new(data7,function(tag ,flag) -- 选择的callback  
      if flag then
          self.m_wanfa[tag + 6] =  self.gamePalyingName[tag + 26].title
      else
          self.m_wanfa[tag + 6] = nil
      end       
    end)  

    self:addScrollItem(self.wanfaPanel7)
end

-- 初始化房费支付列表
function GameRoomInfoUI_shantoumj:initPayType()
    local dataPayType =
    {
        title = "房费:",
        options =
        {
            { text = "房主付费" ,isSelected = true},
            { text = "大赢家付费" },
            { text = "AA付费" }
        },
        Config =
        {
            LineVisible = true,
            OptionPanelSize = cc.size(1020, 60)
        }
    }
    local groupPayType = RadioButtonGroup.new(dataPayType, function(index)
        self.m_setData.RoJST = index
    end )
    self:addScrollItem(groupPayType)
end


function GameRoomInfoUI_shantoumj:setBtnEnable(panel, index, enable)
    for k,v in pairs(panel.m_ButtonList) do
        if k == index then
            if enable then
                panel.m_LabelList[index]:setOpacity(255)
                v:setOpacity(255)
                v:setTouchEnabled(true)
            else
                panel.m_LabelList[index]:setColor(G_ROOM_INFO_FORMAT.normalColor)
                panel.m_LabelList[index]:setOpacity(255*0.5)
                v:setBright(true)
                v:setOpacity(255*0.5)
                v:setTouchEnabled(false)
            end
        end
    end
end

-- function GameRoomInfoUI_shantoumj:setWanfaBtnEnable()
--     if self.m_wanfa[2] == self.gamePalyingName[5].title then
--         if self.m_wanfa[5] == self.gamePalyingName[23].title then
--             wanfaPanel5:onBtnTouchEvent(wanfaPanel5.m_ButtonList[1], ccui.TouchEventType.ended)
--         end
--         self:setBtnEnable(self.wanfaPanel5, 3, false)

--         if self.m_wanfa[6] == self.gamePalyingName[26].title then
--             wanfaPanel5:onBtnTouchEvent(wanfaPanel6.m_ButtonList[1], ccui.TouchEventType.ended)
--         end
--         self:setBtnEnable(self.wanfaPanel6, 4, false)
--     else

--     end
-- end


return GameRoomInfoUI_shantoumj
