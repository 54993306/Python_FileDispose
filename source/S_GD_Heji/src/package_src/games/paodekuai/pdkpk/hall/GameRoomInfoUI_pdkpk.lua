require("app.DebugHelper")
local CommonCheckBoxPanel = require("package_src.games.paodekuai.pdkpk.hall.CommonCheckBoxPanel")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local GameRoomInfoUI_pdkpk = class("GameRoomInfoUI_pdkpk", GameRoomInfoUIBase)

function GameRoomInfoUI_pdkpk:ctor(...)
    self.super.ctor(self,...)
    
end
local wanfaSetting = {}
if IsPortrait then
	wanfaSetting = {
	    -- [1] = {name = "budaifeng",      multi = false,isSelect = true},
	    -- [2] = {name = "daixiaoji",      multi = false},
	    -- [3] = {name = "zjsbd",          multi = false},
	    -- [4] = {name = "xiapao",         multi = true,       newline = true},
	    -- -- [4] = {name = "xiapao",         multi = true},
	    -- [5] = {name = "xiaofan",        itemSelect = true},
	    -- [6] = {name = "dafan",          itemSelect = true},


	    [1]={name="16zhang", multi = false,isSelect = true},

	    [2]={name="heitao3", multi = false,isSelect = true},
	    [3]={name="yjxj", multi = false,isLink      = true},

	    [4]={name="4dai2",multi = true,isSelect = true },
	    [5]={name="AAAzhadan", multi = true},
	    [6]={name="zhandanjiafen",multi = true ,isSelect = true,newline     = true, },
	    [7]={name="xianshipai", multi = true,isSelect = true},


	    [8]={name="daguan", multi = true,isSelect = true },
	    [9]={name="daguan2",itemSelect = true,isSelect = true},
	    [10]={name="daguan3", itemSelect = true},
	    [11]={name="xiaoguan2", newline     = true, multi = true },
    


	    [12]={name="3zsdjw|fjsdjw", multi = true},
	    -- [13]={name="fjsdjw", multi = true,  newline     = true},

	    [14]={name="3dai2",multi = false, isSelect = true },
	    [15]={name="3dai1",multi = false}
	}
else
	wanfaSetting = {
	    -- [1] = {name = "budaifeng",      multi = false,isSelect = true},
	    -- [2] = {name = "daixiaoji",      multi = false},
	    -- [3] = {name = "zjsbd",          multi = false},
	    -- [4] = {name = "xiapao",         multi = true,       newline = true},
	    -- -- [4] = {name = "xiapao",         multi = true},
	    -- [5] = {name = "xiaofan",        itemSelect = true},
	    -- [6] = {name = "dafan",          itemSelect = true},


	    [1]={name="16zhang", multi = false,isSelect = true,drawLine    = true,},

	    [2]={name="heitao3", multi = false,isSelect = true},
	    [3]={name="yjxj", multi = false,isLink      = true,drawLine    = true,},

	    [4]={name="4dai2",multi = true,isSelect = true },
	    [5]={name="AAAzhadan", multi = true},
	    -- [6]={name="zhandanjiafen",multi = true ,isSelect = true,newline     = true, },
	    [6]={name="zhandanjiafen",multi = true ,isSelect = true},
	    [7]={name="xianshipai", multi = true,isSelect = true,newline     = true,drawLine    = true,},
	    [8]={name="daguan", multi = true,isSelect = true },
	    [9]={name="daguan2",itemSelect = true,isSelect = true},
	    [10]={name="daguan3", itemSelect = true},
	    [11]={name="xiaoguan2", newline     = true, multi = true ,drawLine    = true,},
    


	    [12]={name="3zsdjw|fjsdjw", multi = true},
	    -- [13]={name="fjsdjw", multi = true,  newline     = true},

	    [13]={name="3dai2",multi = false, isSelect = true},
	    [14]={name="3dai1",multi = false, drawLine    = true,}
	}
end		

if tostring(PRODUCT_ID) == tostring(3422) then
	if IsPortrait then
	    wanfaSetting = {
	        [1]={name="16zhang", multi = false,isSelect = true},
    
	        [2]={name="heitao3", multi = false},
	        [3]={name="yjxj", multi = false,isLink      = true,isSelect = true},
    
	        [4]={name="4dai2",multi = true,isSelect = true },
	        [5]={name="AAAzhadan", multi = true},
	        [6]={name="zhandanjiafen",multi = true ,isSelect = true,newline     = true, },
	        [7]={name="xianshipai", multi = true,isSelect = true},
    
    
	        [8]={name="daguan", multi = true,isSelect = true },
	        [9]={name="daguan2",itemSelect = true,isSelect = true},
	        [10]={name="daguan3", itemSelect = true},
	        [11]={name="xiaoguan2", newline     = true, multi = true },
        
    
    
	        [12]={name="3zsdjw|fjsdjw", multi = true},

	        [14]={name="3dai1",multi = false, isSelect = true },
	        [15]={name="3dai2",multi = false},
        
	    }
	else
		wanfaSetting = {
	        [1]={name="16zhang", multi = false,isSelect = true,drawLine    = true,},

	        [2]={name="heitao3", multi = false},
	        [3]={name="yjxj", multi = false,isLink      = true,drawLine    = true,isSelect = true},

	        [4]={name="4dai2",multi = true,isSelect = true },
	        [5]={name="AAAzhadan", multi = true},
	        -- [6]={name="zhandanjiafen",multi = true ,isSelect = true,newline     = true, },
	        [6]={name="zhandanjiafen",multi = true ,isSelect = true},
	        [7]={name="xianshipai", multi = true,isSelect = true,newline     = true,drawLine    = true,},
	        [8]={name="daguan", multi = true,isSelect = true },
	        [9]={name="daguan2",itemSelect = true,isSelect = true},
	        [10]={name="daguan3", itemSelect = true},
	        [11]={name="xiaoguan2", newline     = true, multi = true ,drawLine    = true,},
        


	        [12]={name="3zsdjw|fjsdjw", multi = true},

	        [14]={name="3dai1",multi = false, isSelect = true },
	        [15]={name="3dai2",multi = false},
	    } 
	end   
end


function GameRoomInfoUI_pdkpk:onInit()
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
    self.m_setData={}

    self.wanfas= {}

    self:changPlayerNumber({3})

end
--玩法
function GameRoomInfoUI_pdkpk:initWanFa()
    local wanfa1 = {"16zhang"}
    local data1 = {}
    data1.title = "张数:"
    data1.content = {}
    data1.isDrawLine = false
    for i,v in pairs(wanfa1) do
        local m_data1 = {}
        m_data1.name = MjGameConfigManager[self.m_gameID].kGetPlayingInfoByTitle(v).ch
        m_data1.chick = v 
        for j,k in pairs(wanfaSetting) do
            if v == k.name then
                for item,content in pairs(k) do
                    if item ~= "name" then
                        m_data1[item] = content
                    end
                end
            end
        end
        table.insert(data1.content,m_data1)
    end
    -- 新增对选项的恢复
    local customSelectedInfo1 = self._friendRoomDataManager:getData("customSelectedInfo_1", customSelectedInfo1)
    if type(customSelectedInfo1) == "table" then
        for i, v in ipairs(customSelectedInfo1) do
            data1.content[i].isSelect = v
        end
    end

    self.m_wanfaPanel1 = CommonCheckBoxPanel.new(data1)
    table.insert(self.m_itemChildren,self.m_wanfaPanel1)
    self.m_wanfaPanel1:addTo(self.m_viewWanfaBaseHrl)

-----------------------------------------------------------

    local wanfa2 = {"heitao3","yjxj"}
    local data2 = {}
    data2.title = "先手:"
    data2.content = {}
    data2.isDrawLine = false
    for i,v in pairs(wanfa2) do
        local m_data2 = {}
        m_data2.name = MjGameConfigManager[self.m_gameID].kGetPlayingInfoByTitle(v).ch
        m_data2.chick = v 
        for j,k in pairs(wanfaSetting) do
            if v == k.name then
                for item,content in pairs(k) do
                    if item ~= "name" then
                        m_data2[item] = content
                    end
                end
            end
        end
        table.insert(data2.content,m_data2)
    end
    -- 新增对选项的恢复
    local customSelectedInfo2 = self._friendRoomDataManager:getData("customSelectedInfo_2", customSelectedInfo2)
    if type(customSelectedInfo2) == "table" then
        for i, v in ipairs(customSelectedInfo2) do
            data2.content[i].isSelect = v
        end
    end
    self.m_wanfaPanel2 = CommonCheckBoxPanel.new(data2)

    if self.m_wanfaPanel2 and not tolua.isnull(self.m_wanfaPanel2.m_title) then
        self.m_wanfaPanel2.m_itemMinimum = 3
    end

    table.insert(self.m_itemChildren,self.m_wanfaPanel2)
    self.m_wanfaPanel2:addTo(self.m_viewWanfaBaseHrl)

-----------------------------------------------------------

    local wanfa3 = {"4dai2","AAAzhadan","zhandanjiafen","xianshipai"}
    local data3 = {}
    data3.title = "玩法:"
    data3.content = {}
    data3.isDrawLine = false
    for i,v in pairs(wanfa3) do
        local m_data3 = {}
        m_data3.name = MjGameConfigManager[self.m_gameID].kGetPlayingInfoByTitle(v).ch
        m_data3.chick = v 
        for j,k in pairs(wanfaSetting) do
            if v == k.name then
                for item,content in pairs(k) do
                    if item ~= "name" then
                        m_data3[item] = content
                    end
                end
            end
        end
        table.insert(data3.content,m_data3)
    end
    -- 新增对选项的恢复
    local customSelectedInfo3 = self._friendRoomDataManager:getData("customSelectedInfo_3", customSelectedInfo3)
    if type(customSelectedInfo3) == "table" then
        for i, v in ipairs(customSelectedInfo3) do
            data3.content[i].isSelect = v
        end
    end

    self.m_wanfaPanel3 = CommonCheckBoxPanel.new(data3)
    table.insert(self.m_itemChildren,self.m_wanfaPanel3)
    self.m_wanfaPanel3:addTo(self.m_viewWanfaBaseHrl)

-----------------------------------------------------------

    local wanfa4 = {"daguan","daguan2","daguan3","xiaoguan2"}
    local data4 = {}
    data4.title = "算分:"
    data4.content = {}
    data4.isDrawLine = false
    for i,v in pairs(wanfa4) do
        local m_data4 = {}
        m_data4.name = MjGameConfigManager[self.m_gameID].kGetPlayingInfoByTitle(v).ch
        m_data4.chick = v 
        for j,k in pairs(wanfaSetting) do
            if v == k.name then
                for item,content in pairs(k) do
                    if item ~= "name" then
                        m_data4[item] = content
                    end
                end
            end
        end
        table.insert(data4.content,m_data4)
    end
    -- 新增对选项的恢复
    local customSelectedInfo4 = self._friendRoomDataManager:getData("customSelectedInfo_4", customSelectedInfo4)
    if type(customSelectedInfo4) == "table" then
        for i, v in ipairs(customSelectedInfo4) do
            if #data4.content >= i then
                data4.content[i].isSelect = v
            end
        end
    end

    self.m_wanfaPanel4 = CommonCheckBoxPanel.new(data4)
    table.insert(self.m_itemChildren,self.m_wanfaPanel4)
    self.m_wanfaPanel4:addTo(self.m_viewWanfaBaseHrl)

    self.m_wanfaPanel4:updateSelectBox(function(data,panel) self:updateWanFa4(data,panel) end)
    local data= {}
    data.chick = "daguan"
    self:updateWanFa4(data)
-----------------------------------------------------------

    local wanfa5 = {"3zsdjw|fjsdjw"}
    local data5 = {}
    data5.title = "最后:"
    data5.content = {}
    data5.isDrawLine = false
    for i,v in pairs(wanfa5) do
        local m_data5 = {}
        m_data5.name = MjGameConfigManager[self.m_gameID].kGetPlayingInfoByTitle(v).ch
        m_data5.chick = v 
        for j,k in pairs(wanfaSetting) do
            if v == k.name then
                for item,content in pairs(k) do
                    if item ~= "name" then
                        m_data5[item] = content
                    end
                end
            end
        end
        table.insert(data5.content,m_data5)
    end
    -- 新增对选项的恢复
    local customSelectedInfo5 = self._friendRoomDataManager:getData("customSelectedInfo_5", customSelectedInfo5)
    if type(customSelectedInfo5) == "table" then
        for i, v in ipairs(customSelectedInfo5) do
            if data5.content[i] then
                data5.content[i].isSelect = v
            end
        end
    end

    self.m_wanfaPanel5 = CommonCheckBoxPanel.new(data5)
    table.insert(self.m_itemChildren,self.m_wanfaPanel5)
    self.m_wanfaPanel5:addTo(self.m_viewWanfaBaseHrl)
    -- self.m_wanfaPanel5:updateSelectBox(function(data,panel) self:updateSanDai(data,panel) end)
-----------------------------------------------------------

    local wanfa6 = {"3dai2","3dai1"}
    if IsPortrait then
	if tostring(PRODUCT_ID) == tostring(3422) then
		wanfa6 = {"3dai1","3dai2"}
	end
    end    
    local data6 = {}
    data6.title = "带牌:"
    data6.content = {}
    data6.isDrawLine = false
    for i,v in pairs(wanfa6) do
        local m_data6 = {}
        m_data6.name = MjGameConfigManager[self.m_gameID].kGetPlayingInfoByTitle(v).ch
        m_data6.chick = v 
        for j,k in pairs(wanfaSetting) do
            if v == k.name then
                for item,content in pairs(k) do
                    if item ~= "name" then
                        m_data6[item] = content
                    end
                end
            end
        end
        table.insert(data6.content,m_data6)
    end
    -- 新增对选项的恢复
    local customSelectedInfo6 = self._friendRoomDataManager:getData("customSelectedInfo_6", customSelectedInfo6)
    if type(customSelectedInfo6) == "table" then
        for i, v in ipairs(customSelectedInfo6) do
            data6.content[i].isSelect = v
        end
    end

    self.m_wanfaPanel6 = CommonCheckBoxPanel.new(data6)
    table.insert(self.m_itemChildren,self.m_wanfaPanel6)
    self.m_wanfaPanel6:addTo(self.m_viewWanfaBaseHrl)

end


--函数功能：    玩法选择项
function GameRoomInfoUI_pdkpk:updateWanFa4(data,panel)
    if data.chick == "daguan" then
        local daguan = self.m_wanfaPanel4:getCheckBoxPanel("daguan")
        local daguancheckBox = ccui.Helper:seekWidgetByName(daguan,"CheckBox")
        local xiaoguan = self.m_wanfaPanel4:getCheckBoxPanel("xiaoguan2")
        
        if panel then
            if not daguancheckBox:isSelected() then
                self.m_wanfaPanel4:setPanelGrey(xiaoguan,true)
            else
                self.m_wanfaPanel4:setPanelGrey(xiaoguan,false)
            end
        else
            local xiaoguancheckBox = ccui.Helper:seekWidgetByName(xiaoguan,"CheckBox")
            if daguancheckBox:isSelected() then
                if not xiaoguancheckBox:isSelected() then
                    self.m_wanfaPanel4:setPanelGrey(xiaoguan,true)
                end
            else
                self.m_wanfaPanel4:setPanelGrey(xiaoguan,false)
            end
        end
    end
end

--[[
-- @brief  玩法组装工厂函数
-- @param  void
-- @return void
--]]
function GameRoomInfoUI_pdkpk:wanFaFactory()
    local wanfa1 = self.m_wanfaPanel1:getPanelData()
    local wanfa2 = self.m_wanfaPanel2:getPanelData()
    local wanfa3 = self.m_wanfaPanel3:getPanelData()
    local wanfa4 = self.m_wanfaPanel4:getPanelData()
    local wanfa5 = self.m_wanfaPanel5:getPanelData()
    local wanfa6 = self.m_wanfaPanel6:getPanelData()
    local wanfa = wanfa1.."|"..wanfa2.."|"..wanfa3.."|"..wanfa4.."|"..wanfa5.."|"..wanfa6
    local wf = ""
    for i,v in pairs(Util.analyzeString_2(wanfa)) do
        for j,k in pairs(Util.analyzeString_3(v)) do
            wf = wf == "" and k or wf.."|"..k
        end
    end

    Log.i("wanfa..........",wf)
    self.m_setData.wa = wf
    self.m_setData.gaI = kFriendRoomInfo:getGameID();

    -- 新增对选项的恢复
    local customSelectedInfo1 = self.m_wanfaPanel1:getSelectedInfo()
    self._friendRoomDataManager:saveData("customSelectedInfo_1", customSelectedInfo1)

    -- 新增对选项的恢复
    local customSelectedInfo2 = self.m_wanfaPanel2:getSelectedInfo()
    self._friendRoomDataManager:saveData("customSelectedInfo_2", customSelectedInfo2)

    -- 新增对选项的恢复
    local customSelectedInfo3 = self.m_wanfaPanel3:getSelectedInfo()
    self._friendRoomDataManager:saveData("customSelectedInfo_3", customSelectedInfo3)

    -- 新增对选项的恢复
    local customSelectedInfo4 = self.m_wanfaPanel4:getSelectedInfo()
    self._friendRoomDataManager:saveData("customSelectedInfo_4", customSelectedInfo4)

    -- 新增对选项的恢复
    local customSelectedInfo5 = self.m_wanfaPanel5:getSelectedInfo()
    self._friendRoomDataManager:saveData("customSelectedInfo_5", customSelectedInfo5)
    -- 新增对选项的恢复
    local customSelectedInfo6 = self.m_wanfaPanel6:getSelectedInfo()
    self._friendRoomDataManager:saveData("customSelectedInfo_6", customSelectedInfo6)
end

function GameRoomInfoUI_pdkpk:initRoomInfo()

    local baseItemChildren = self.m_baseItemChildren
    for i,v in pairs(baseItemChildren) do
        if v and type(v) == "userdata" and v.m_radioBtns then
            self._friendRoomDataManager:updateRoomPanel(v,tostring(i))
        end
    end

    local wanfa = self.m_itemChildren
    for i,v in pairs(wanfa) do
        if v and type(v) == "userdata" then
            if v.m_radioBtns then
                self._friendRoomDataManager:updateRoomPanel(v,string.format( "wanfa%d",i) )
            else
                -- self._friendRoomDataManager:updateRoomCheckPanel(v,string.format( "wanfa%d",i))
            end
        end
    end
end

function GameRoomInfoUI_pdkpk:saveRoomInfo()

    local baseItemChildren = self.m_baseItemChildren
    for i,v in pairs(baseItemChildren) do
        if v and type(v) == "userdata" and v.m_radioBtns then
            self._friendRoomDataManager:savePanelAllData(v.m_radioBtns,tostring(i))
        end
    end

    local wanfa = self.m_itemChildren
    for i, v in pairs(wanfa) do
        if v and type(v) == "userdata" then
            local panelData = v:getSavePanelAllData()
            self._friendRoomDataManager:saveData(string.format( "wanfa%s",tostring(i)),panelData)
        end
    end
end



return GameRoomInfoUI_pdkpk