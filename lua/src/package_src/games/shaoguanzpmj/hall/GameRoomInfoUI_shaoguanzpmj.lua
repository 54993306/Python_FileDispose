require("app.DebugHelper")
local CommonCheckBoxPanel = require("package_src.games.shaoguanzpmj.hall.CommonCheckBoxPanel")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local GameRoomInfoUI_shaoguanzpmj = class("GameRoomInfoUI_shaoguanzpmj", GameRoomInfoUIBase)

--玩法的配置
local wanfaSetting = {
    [1] = {name = "yifenliangfen",                          isSelect = true},
	[2] = {name = "shifenershifen",		isLink = true,		newline = true},
    [3] = {name = "wanfa",              title = true,       newline = true},
    [4] = {name = "humasuanquanma",     multi = true,       isSelect = true},
    [5] = {name = "magengqingyise",     isSelect = true,    newline = true},
    [6] = {name = "magengquanzi",       newline = true,     isLink = true},
    [7] = {name = "magengshisanyao",    isLink = true},
    [8] = {name = "fanma",              title = true,       newline = true},
    [9] = {name = "sima",               isSelect = true},
    [10] = {name = "liuma",              newline = true,     isLink = true},
    [11] = {name = "bama",              isLink = true},
}

function GameRoomInfoUI_shaoguanzpmj:ctor(...)
	self.super.ctor(self,...)
	
end

function GameRoomInfoUI_shaoguanzpmj:initWanFa()
	
    local baseInfo = kFriendRoomInfo:getRoomBaseInfo()
    local wanfa =Util.analyzeString_2(baseInfo.wanfa)
--    local wanfaPosY = self.m_jushuPanel:getPositionY()
    
    local function updateWanFa()
        local isInsert = 0
        for i,v in pairs(wanfa) do
            if v == "wanfa" then
                isInsert = 1
            elseif v == "fanma" then
                isInsert = 2
            elseif v == "humasuanquanma" and isInsert ~= 1 then
                table.insert(wanfa,i,"wanfa")
                updateWanFa()
                break
            elseif v == "erma" and isInsert ~= 2 then
                table.insert(wanfa,i,"fanma")
                updateWanFa()
                break
            end
        end
    end
    updateWanFa()

    local data = {}
    data.title = "底分:"
    data.content = {}
    for i,v in pairs(wanfa) do
        local m_data = {}
        m_data.name = MjGameConfigManager[self.m_gameID].kGetPlayingInfoByTitle(v).ch
        m_data.chick = v 
        for j,k in pairs(wanfaSetting) do
            if v == k.name then
                for item,content in pairs(k) do
                    if item ~= "name" then
                        m_data[item] = content
                    end
                end
                break
            end
        end
        table.insert(data.content,m_data)
    end

    self.m_wanfaPanel = CommonCheckBoxPanel.new(data)
    table.insert(self.m_itemChildren,self.m_wanfaPanel)
    self.m_wanfaPanel:addTo(self.m_viewWanfaBaseHrl)
end

--[[
-- @brief  玩法组装工厂函数
-- @param  void
-- @return void
--]]
function GameRoomInfoUI_shaoguanzpmj:wanFaFactory()
	local wanfa = self.m_wanfaPanel:getPanelData()
    local wf = ""
    for i,v in pairs(Util.analyzeString_2(wanfa)) do
        for j,k in pairs(Util.analyzeString_3(v)) do
            wf = wf == "" and k or wf.."|"..k
        end
    end
    Log.i("wanfa......",wanfa)
	self.m_setData.wa = wf
	self.m_setData.gaI = kFriendRoomInfo:getGameID();
	
end

return  GameRoomInfoUI_shaoguanzpmj