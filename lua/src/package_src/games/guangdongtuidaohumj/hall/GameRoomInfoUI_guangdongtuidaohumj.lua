
require("app.DebugHelper")

local RadioButtonGroup = require("package_src.games.guangdongtuidaohumj.hall.RadioButtonGroup")
local SelectRadioBtn = require("app.hall.common.SelectRadioBtn")
local CheckBoxPanel = require("app.games.common.custom.CheckBoxPanel")
local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")

local  kselectImg = "hall/huanpi2/Common/checkbox_sle.png"-------复选框选中
local  kbackgroundImg = "hall/huanpi2/Common/checkbox_bg.png"---------复选框未选中背景
local  shuangguicheck = cc.p(570, 10)-----双鬼选项复选坐标
local  jiafenfanbei = cc.p(420, 10)-----加分翻倍选项坐标
local  magendifen = cc.p(0, 0)-----马跟底分选项坐标

local GameRoomInfoUI_guangdongtuidaohumj = class("GameRoomInfoUI_guangdongtuidaohumj", GameRoomInfoUIBase)

function GameRoomInfoUI_guangdongtuidaohumj:ctor(...)
    self.super.ctor(self, ...)
end

--地方组重写 初始化自己特有的数据
function GameRoomInfoUI_guangdongtuidaohumj:onInit()
end

-----当人数不为4人是 不显示"跟庄"
function GameRoomInfoUI_guangdongtuidaohumj:playerNumChange(playerNum)
    Log.i("playerNum",playerNum)
    if self.wanfaPanel1 then  
        if playerNum ==  4 then
            self.wanfaPanel1:setBtnEnabled(9, true)
            self.m_wanfa[9] = MjGameConfigManager[self.m_gameID]._gamePalyingName[9].title
        elseif playerNum == 3 or playerNum == 2 then
            self.wanfaPanel1:setBtnEnabled(9, false)
            self.wanfaPanel1:setSelectedIndex(false,9)
            self.m_wanfa[9] = nil
        end        
    end
end

--初始化玩法列表
function GameRoomInfoUI_guangdongtuidaohumj:initWanFa()
    self.m_wanfa = {}

    local data =
    {
        title = "玩法:",
        options =
        {
            {   text = MjGameConfigManager[self.m_gameID]._gamePalyingName[1].ch, isSelected = true  },
            {   text = MjGameConfigManager[self.m_gameID]._gamePalyingName[2].ch, isSelected = false  },
            {   text = MjGameConfigManager[self.m_gameID]._gamePalyingName[3].ch, isSelected = false  },
            {   text = MjGameConfigManager[self.m_gameID]._gamePalyingName[4].ch, isSelected = false  },
            {   text = MjGameConfigManager[self.m_gameID]._gamePalyingName[5].ch, isSelected = true  },
            {   text = MjGameConfigManager[self.m_gameID]._gamePalyingName[6].ch, isSelected = true  },
            {   text = MjGameConfigManager[self.m_gameID]._gamePalyingName[7].ch, isSelected = true  },
            {   text = MjGameConfigManager[self.m_gameID]._gamePalyingName[8].ch, isSelected = false  },
            {   text = MjGameConfigManager[self.m_gameID]._gamePalyingName[9].ch, isSelected = false  },
            {   text = MjGameConfigManager[self.m_gameID]._gamePalyingName[10].ch, isSelected = false  },

       },
       Config =
        {
            LineVisible = false, Exclusive = false,ResponseEvent = true,MaxCol = 2,
        }
    }
    local callback = function (tag, isSelected)
        if isSelected then
            self.m_wanfa[tag] = MjGameConfigManager[self.m_gameID]._gamePalyingName[tag].title
        else
            self.m_wanfa[tag] = nil
        end

        if self.wanfaPanel1 then
            if tag == 1 then
                if isSelected == true then
                    self.wanfaPanel1:setBtnEnabled(2,true)
                    self.wanfaPanel1:setBtnEnabled(3,true)
                    self.wanfaPanel1:setSelectedIndex(false,2)
                    self.wanfaPanel1:setSelectedIndex(true,3)
                    self.m_wanfa[2] = nil
                    self.m_wanfa[3] = MjGameConfigManager[self.m_gameID]._gamePalyingName[3].title
                else
                    self.wanfaPanel1:setBtnEnabled(2,false)
                    self.wanfaPanel1:setBtnEnabled(3,false)
                    self.wanfaPanel1:setSelectedIndex(false,2)
                    self.wanfaPanel1:setSelectedIndex(false,3)
                    self.m_wanfa[2] = nil
                    self.m_wanfa[3] = nil
                end
            elseif tag == 3 then
                if isSelected == true then
                else
                    if self.m_wanfa[13] == "baozhama" then
                        self.wanfaPanel1:setBtnEnabled(2,false)
                        self.wanfaPanel1:setBtnEnabled(3,false)
                        self.wanfaPanel1:setSelectedIndex(false,1)
                        self.wanfaPanel1:setSelectedIndex(false,2)
                        self.m_wanfa[1] = nil
                        self.m_wanfa[2] = nil
                    end
                end
            elseif tag == 5 then
                if isSelected == true then
                    self.wanfaPanel1:setBtnEnabled(6,true)
                    self.wanfaPanel1:setSelectedIndex(false,6)
                    self.m_wanfa[6] = nil
                else
                    self.wanfaPanel1:setBtnEnabled(6,false)
                    self.wanfaPanel1:setSelectedIndex(false,6)
                    self.m_wanfa[6] = nil
                end
            end
        end
    end
    self.wanfaPanel1 = CheckBoxPanel.new(data, callback)
    self:addScrollItem(self.wanfaPanel1)

    local data2 =
    {
        title = "鬼牌:",
        options =
        {
            {text = MjGameConfigManager[self.m_gameID]._gamePalyingName[11].ch,isSelected = false}, --
            {text = MjGameConfigManager[self.m_gameID]._gamePalyingName[12].ch,isSelected = true}, --
            {text = MjGameConfigManager[self.m_gameID]._gamePalyingName[13].ch,isSelected = false}, --
        },
        --  可配置属性，详见 CheckBoxPanel:initConfigList()
        Config =
        {
            LineVisible = false, Exclusive = false,ResponseEvent = false,MaxCol = 3, NeedMove = true,
        }
    }
    local callback2 = function(tag ,groupid) -- 选择的callback  
        self.m_wanfa[11] =  MjGameConfigManager[self.m_gameID]._gamePalyingName[tag+10].title --，玩法3
        if self.wanfaBtnShuangui then
            if tag == 3  then
                self.wanfaBtnShuangui:setEnabled(true)
            else
                self.wanfaBtnShuangui:setEnabled(false)
            end
            self.wanfaBtnShuangui:setSelected(false)
            self.m_wanfa[12] = nil
        end

        if self.wanfaPanel1 then
            if tag == 3 then
                self.wanfaPanel1:setBtnEnabled(7,true)
                self.wanfaPanel1:setSelectedIndex(false,7)
                self.wanfaPanel1:setBtnEnabled(8,true)
                self.wanfaPanel1:setSelectedIndex(true,8)
                self.m_wanfa[7] = nil
                self.m_wanfa[8] = MjGameConfigManager[self.m_gameID]._gamePalyingName[8].title
            elseif tag == 2 then
                self.wanfaPanel1:setBtnEnabled(7,true)
                self.wanfaPanel1:setSelectedIndex(false,7)
                self.wanfaPanel1:setBtnEnabled(8,false)
                self.wanfaPanel1:setSelectedIndex(false,8)
                self.m_wanfa[7] = nil
                self.m_wanfa[8] = nil
            else
                self.wanfaPanel1:setBtnEnabled(7,false)
                self.wanfaPanel1:setSelectedIndex(false,7)
                self.wanfaPanel1:setBtnEnabled(8,true)
                self.wanfaPanel1:setSelectedIndex(true,8)
                self.m_wanfa[7] = nil
                self.m_wanfa[8] = MjGameConfigManager[self.m_gameID]._gamePalyingName[8].title
            end
        end
    end
    self.wanfaPanel2 = RadioButtonGroup.new(data2,callback2) 
    self.wanfaPanel1:setBtnEnabled(7,true) -- 默认不响应事件，设置默认值
    self.wanfaPanel1:setSelectedIndex(true,7)
    self.wanfaPanel1:setBtnEnabled(8,false)
    self.wanfaPanel1:setSelectedIndex(false,8)
    self.m_wanfa[7] = MjGameConfigManager[self.m_gameID]._gamePalyingName[7].title
    self.m_wanfa[11] =  MjGameConfigManager[self.m_gameID]._gamePalyingName[12].title --，玩法

    local datafu = {
        textNormal      = " "..MjGameConfigManager[self.m_gameID]._gamePalyingName[14].ch,  -- 未选中情况下的文字
        index           = 1, -- 序号
        selectImg = kselectImg,---"hall/huanpi2/Common/checkbox_sle.png",
        backgroundImg = kbackgroundImg,--"hall/huanpi2/Common/checkbox_bg.png",
        selectColor     = G_ROOM_INFO_FORMAT.selectColor, -- 选中的颜色
        normalColor     = G_ROOM_INFO_FORMAT.normalColor, -- 未选中的颜色
        --callback        = nil, -- 选中时的回调
        hasGroup        = false, -- 是否有组
    }

    datafu.callback = function (tag, isSelected)
        if isSelected then
            self.m_wanfa[11+tag] = MjGameConfigManager[self.m_gameID]._gamePalyingName[tag + 13].title
        else
            self.m_wanfa[11+tag] = nil
        end
    end
    self.wanfaBtnShuangui = SelectRadioBtn.new(datafu)
    self.wanfaBtnShuangui:setSelected(false) --5--双鬼
    self.wanfaBtnShuangui:setEnabled(false)
    self.wanfaBtnShuangui:setPosition(shuangguicheck)
    self.wanfaBtnShuangui:setScale(0.7)
    self.wanfaPanel2:addChild(self.wanfaBtnShuangui)
    self.wanfaBtnShuangui:setOpacity(0)

    self:addScrollItem(self.wanfaPanel2)


    local data4 =
    {
        title = "马牌:",
        options =
        {
            {text = MjGameConfigManager[self.m_gameID]._gamePalyingName[15].ch,isSelected = true}, --
            {text = MjGameConfigManager[self.m_gameID]._gamePalyingName[16].ch,isSelected = false}, --
            {text = MjGameConfigManager[self.m_gameID]._gamePalyingName[17].ch,isSelected = false}, --
            {text = MjGameConfigManager[self.m_gameID]._gamePalyingName[18].ch,isSelected = false}, --
            {text = MjGameConfigManager[self.m_gameID]._gamePalyingName[19].ch,isSelected = false}, --
            {text = MjGameConfigManager[self.m_gameID]._gamePalyingName[20].ch,isSelected = false}, --
        },
        --  可配置属性，详见 CheckBoxPanel:initConfigList()
        Config =
        {
            LineVisible = false, Exclusive = false,ResponseEvent = true,MaxCol = 5,MoveLast = true,
        }
    }
    local callback4 = function(tag ,groupid) -- 选择的callback  
        self.m_wanfa[13] =  MjGameConfigManager[self.m_gameID]._gamePalyingName[tag+14].title --，玩法3
        if self.wanfaPanel6 and self.wanfaPanel5 then
            self.wanfaPanel6:setSelectedIndex(false,1)
            self.m_wanfa[14] = nil
            if tag == 1 then
                self.wanfaPanel1:setBtnEnabled(4,true)
                self.wanfaPanel6:setBtnEnabled(1,false)
                self.wanfaPanel5:setSelectedIndex(false,1)
                self.wanfaPanel5:setSelectedIndex(false,2)
                self.wanfaPanel5:setBtnEnabled(false,1)
                self.wanfaPanel5:setBtnEnabled(false,2)
            elseif tag == 6 then
                self.wanfaPanel6:setBtnEnabled(1,false)
                self.wanfaPanel5:setSelectedIndex(true,1)
                self.wanfaPanel5:setBtnEnabled(true,1)
                self.wanfaPanel5:setBtnEnabled(true,2)
                self.m_wanfa[14] =  MjGameConfigManager[self.m_gameID]._gamePalyingName[22].title --，默认选中
            else
                self.wanfaPanel1:setBtnEnabled(4,true)
                self.wanfaPanel6:setBtnEnabled(1,true)
                self.wanfaPanel5:setSelectedIndex(false,1)
                self.wanfaPanel5:setSelectedIndex(false,2)
                self.wanfaPanel5:setBtnEnabled(false,1)
                self.wanfaPanel5:setBtnEnabled(false,2)
            end
            
        end
    end
    self.wanfaPanel4 = RadioButtonGroup.new(data4,callback4)     
   
    local data5 =
    {
        options =
        {
            {text = MjGameConfigManager[self.m_gameID]._gamePalyingName[22].ch,isSelected = false}, --
            {text = MjGameConfigManager[self.m_gameID]._gamePalyingName[23].ch,isSelected = false}, --
        },
        --  可配置属性，详见 CheckBoxPanel:initConfigList()
        Config =
        {
            LineVisible = false, Exclusive = false,ResponseEvent = true,MaxCol = 5
        }
    }
    local callback5 = function(tag ,flag) -- 选择的callback  
        self.m_wanfa[14] =  MjGameConfigManager[self.m_gameID]._gamePalyingName[tag+21].title --，玩法3
        if self.wanfaPanel1 then -- 删除 -- 选择爆炸马与杠爆全包无关
            if tag == 2 then
                self.wanfaPanel1:setBtnEnabled(4,false)
                self.wanfaPanel1:setSelectedIndex(true,4)
                self.m_wanfa[4] = MjGameConfigManager[self.m_gameID]._gamePalyingName[4].title
            else
                if self.m_wanfa[4] then
                    self.wanfaPanel1:setBtnEnabled(4,true)
                    self.wanfaPanel1:setSelectedIndex(true,4)
                    self.m_wanfa[4] = MjGameConfigManager[self.m_gameID]._gamePalyingName[4].title
                else
                    self.wanfaPanel1:setBtnEnabled(4,true)
                    self.wanfaPanel1:setSelectedIndex(false,4)
                    self.m_wanfa[4] = nil
                end
            end
        end
    end
    self.wanfaPanel5 = RadioButtonGroup.new(data5,callback5) 
    self.wanfaPanel5:setPosition(jiafenfanbei)
    self.wanfaPanel5:setScale(0.7)
    self.wanfaPanel5:setBtnEnabled(false,1)
    self.wanfaPanel5:setBtnEnabled(false,2)
    self.wanfaPanel4:addChild(self.wanfaPanel5)    


    local data6 =
    {
        options =
        {
            {   text = MjGameConfigManager[self.m_gameID]._gamePalyingName[21].ch, isSelected = false  }, -- 马跟底分

       },
       Config =
        {
            LineVisible = false, Exclusive = false,ResponseEvent = true,MaxCol = 2,
        }
    }
    local callback6 = function (tag, isSelected)
        if isSelected then
            self.m_wanfa[15] = MjGameConfigManager[self.m_gameID]._gamePalyingName[tag + 20].title
        else
            self.m_wanfa[15] = nil
        end
    end
    self.wanfaPanel6 = CheckBoxPanel.new(data6, callback6)
    self.wanfaPanel6:setPosition(magendifen)
    self.wanfaPanel6:setBtnEnabled(1,false) -- 设置默认值
    self.wanfaPanel4:addChild(self.wanfaPanel6)

    self:addScrollItem(self.wanfaPanel4)
end


function GameRoomInfoUI_guangdongtuidaohumj:initRoomInfo()
    
 --    local baseItemChildren = self.m_baseItemChildren
 --    local itemChildren = {}
 --    for i,v in pairs(baseItemChildren) do
 --        itemChildren[tostring(i)] = v
 --    end
 --    baseItemChildren = itemChildren
 --    for i,v in pairs(baseItemChildren) do
 --        if v.m_data and v.m_data.title and v.m_data.title == "局数:" then
 --            table.remove( baseItemChildren,tostring(i))
 --            baseItemChildren[tostring(i)] = v
 --            break;
 --        end
 --    end
 --    for i,v in pairs(baseItemChildren) do
 --        if v and type(v) == "userdata" and v.m_radioBtns then
 --            self._friendRoomDataManager:updateRoomPanel(v,tostring(i))
 --        end
 --    end
	
	-- local itemChildren = self.m_itemChildren
 --    for i, v in pairs(itemChildren) do
 --        if v and type(v) == "userdata" then
 --            if v.m_radioBtns then
 --                self._friendRoomDataManager:updateRoomPanel(v,string.format( "wanfa%d",i) )
 --            else
 --                self._friendRoomDataManager:updateRoomCheckPanel(v,string.format( "wanfa%d",i))
 --            end
 --        end
 --    end
end

function GameRoomInfoUI_guangdongtuidaohumj:saveRoomInfo()
    -- local wanfa = self.m_itemChildren
    -- for i, v in pairs(wanfa) do
    --     if v and type(v) == "userdata" then
    --         if v.m_radioBtns then
    --             self._friendRoomDataManager:savePanelAllData(v.m_radioBtns,string.format( "wanfa%d",i))
    --         else
    --             self._friendRoomDataManager:setCheckPanelAllData(v,string.format( "wanfa%d",i))
    --         end
    --     end
    -- end
    -- local baseItemChildren = self.m_baseItemChildren
    -- for i,v in pairs(baseItemChildren) do
    --     if v and type(v) == "userdata" and v.m_radioBtns then
    --         self._friendRoomDataManager:savePanelAllData(v.m_radioBtns,tostring(i))
    --     end
    -- end
end

return GameRoomInfoUI_guangdongtuidaohumj