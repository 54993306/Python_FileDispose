
require("app.DebugHelper")

local CheckBoxPanel = require("app.games.common.custom.CheckBoxPanel")
local SelectRadioPanel = require "app.hall.common.SelectRadioPanel"

local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
local GameRoomInfoUI_gdpk = class("GameRoomInfoUI_gdpk", GameRoomInfoUIBase)

local serverWanFaTxt = {
    ["wanfa"] = 1,
}

function GameRoomInfoUI_gdpk:ctor(...)

    -- 扩展局数字段
    local newPayStringAA = {
        [1] = "过6(每人%d钻)",
        [2] = "过10(每人%d钻)",
        [3] = "过A(每人%d钻)",
    }

    local newPayStringCommon = {
        [1] = "过6(%d钻)",
        [2] = "过10(%d钻)",
        [3] = "过A(%d钻)",
    }

    local newPriceData = {
        [1] = 4,
        [2] = 8,
        [3] = 12,
    }

    local isChangeLine = true
    Log.i("--GameRoomInfoUI_gdpk--payString1,payString2,priveData",payString1,payString2,priveData)
    self:setChangePayData(newPayStringAA,newPayStringCommon,newPriceData,isChangeLine)

    self.super.ctor(self, ...)

end

function GameRoomInfoUI_gdpk:onInit()
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


end

-- 初始化玩法列表
function GameRoomInfoUI_gdpk:initWanFa()

    self:changPlayerNumber({4})

    self:initWfa()

    self:initShengji()

    self:initLevelUp()
end

function GameRoomInfoUI_gdpk:initLevelUp()
    local tag = 1
    Log.i("--wangzhi--self.m_wanfa[2]--",self.m_wanfa[2])
    Log.i("--wangzhi--self.m_wanfa[1]--",self.m_wanfa[1])
    if self.m_wanfa[2] and self.m_wanfa[2] == "shengji" and self.m_wanfa[1] and self.m_wanfa[1] == "duiyouzudui" then
        Log.i("--wangzhi--升级")
        self:changRoundNumber(true)
    else
        Log.i("--wangzhi--不升级")
        self:changRoundNumber(false)
    end
  
end


function GameRoomInfoUI_gdpk:initWfa(  )

local dataSelectRadio1 =
    {
        title = "模式:",
        radios = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[1].ch, 
            MjGameConfigManager[self.m_gameID]._gamePalyingName[2].ch,
        },
        hiddenLine = true,
        count = 2,
        width = (G_ROOM_INFO_FORMAT.lineWidth - 110) / 2,
        select = 2
    }

    self.groupSelectRadio1 = SelectRadioPanel.new(dataSelectRadio1, function(index)
        self.m_wanfa[1] = MjGameConfigManager[self.m_gameID]._gamePalyingName[index].title

        if self.groupSelectRadio2 then
            local dataSelectRadio1 =
                {
                    title = "玩法:", 
                    radios = {
                        MjGameConfigManager[self.m_gameID]._gamePalyingName[3].ch, 
                        MjGameConfigManager[self.m_gameID]._gamePalyingName[4].ch,
                    }, 
                    hiddenLine = true,
                    count = 2,
                    width = (G_ROOM_INFO_FORMAT.lineWidth - 110) / 2,
                }
                Log.i("--wangzhi--组队模式--更新玩法--")
            if self.groupSelectRadio1 and index == 1 then
                dataSelectRadio1.radios = {
                    MjGameConfigManager[self.m_gameID]._gamePalyingName[4].ch, 
                }
            end
            for k,v in pairs(self.m_headItemChildren) do
                if v == self.groupSelectRadio2 then
                    self.m_viewHeadItemBaseHrl:removeChild(self.m_headItemChildren[k])
                    table.remove(self.m_headItemChildren,k)
                    break
                end
            end
            local flagIndex = 1
            if self.m_wanfa[2] == "shengji" then
                flagIndex = 1
            else
                flagIndex = 2
            end
            self.groupSelectRadio2 = SelectRadioPanel.new(dataSelectRadio1, function(index2)
                    if self.groupSelectRadio1 and index == 1 then
                        self.m_wanfa[2] = MjGameConfigManager[self.m_gameID]._gamePalyingName[index2 + 3].title 
                    else
                        self.m_wanfa[2] = MjGameConfigManager[self.m_gameID]._gamePalyingName[index2 + 2].title 
                    end
                    Log.i("--wangzhi--self:initLevelUp()--001")
                    -- if self.m_wanfa[2] == "shengji" then
                    --     self.groupSelectRadio2:setSelectedIndex(1)
                    -- else
                    --     self.groupSelectRadio2:setSelectedIndex(2)
                    -- end
                    self:initLevelUp()                
                end)
            self.groupSelectRadio2:setSelectedIndex(flagIndex)
            if self.groupSelectRadio1 and index == 1 then
                self.groupSelectRadio2:setSelectedIndex(1)
            end 
            table.insert(self.m_headItemChildren,self.groupSelectRadio2)
            self.groupSelectRadio2:addTo(self.m_viewHeadItemBaseHrl)
        end
        Log.i("--wangzhi--self:initLevelUp()--002")
        self:initLevelUp()
    end)  
        
    table.insert(self.m_headItemChildren,self.groupSelectRadio1)
    self.groupSelectRadio1:addTo(self.m_viewHeadItemBaseHrl)

end

function GameRoomInfoUI_gdpk:initShengji(  )

    local dataSelectRadio1 =
    {
        title = "玩法:", 
        radios = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[3].ch, 
            MjGameConfigManager[self.m_gameID]._gamePalyingName[4].ch,
        }, 
        hiddenLine = true,
        count = 2,
        width = (G_ROOM_INFO_FORMAT.lineWidth - 110) / 2,
    }
    if self.groupSelectRadio1 and self.m_wanfa[1] =="suijizudui" then
        dataSelectRadio1.radios = {
                MjGameConfigManager[self.m_gameID]._gamePalyingName[4].ch, 
        }
    end
    self.groupSelectRadio2 = SelectRadioPanel.new(dataSelectRadio1, function(index)

        self.m_wanfa[2] = MjGameConfigManager[self.m_gameID]._gamePalyingName[index + 2].title
        self:initLevelUp()
    end)

    table.insert(self.m_headItemChildren,self.groupSelectRadio2)
    self.groupSelectRadio2:addTo(self.m_viewHeadItemBaseHrl)

end

function GameRoomInfoUI_gdpk:wanFaFactory()
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
    local bushengji = string.find(str,"bushengji") or false
    if not bushengji then
        if self.m_setData and self.m_setData.roS then
            if tostring(self.m_setData.roS) == "4" then
                str = str.."|".."guo6"
            elseif tostring(self.m_setData.roS) == "8"  then
                str = str.."|".."guo10"
            elseif tostring(self.m_setData.roS) == "12"  then
                str = str.."|".."guoA"
            end
        end
    end
    self.m_setData.wa = str
end


function GameRoomInfoUI_gdpk:initRoomInfo()
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
    
    local itemChildren = self.m_headItemChildren
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

function GameRoomInfoUI_gdpk:saveRoomInfo()
    local wanfa = self.m_headItemChildren
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


return GameRoomInfoUI_gdpk