require("app.DebugHelper")

local SelectRadioPanel = require("app.hall.common.SelectRadioPanel")
local DropDownBoxPanel = require("app.games.common.custom.DropDownBox.DropDownBoxPanel")
local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")

local SelectRadioBtn = require("app.hall.common.SelectRadioBtn")
require("app.DebugHelper")

local kRule = {
    testWanfa = "zhuangjia2di|wuhongzhongjiayidi|qianggangbaosanjia|wumasuanquanma|quanmajia1ma|kechi|qixiaoduikehu|kedianpao|suportmutihu|4_ma|3_ma|2_ma|6_ma|99_ma|91_ma",
    wanfaTitle = "玩法:",
    selectRule = {zhuangjia2di = 1, wuhongzhongjiayidi = 1, qianggangbaosanjia = 1, wumasuanquanma = 1, quanmajia1ma = 1, qixiaoduikehu = 1,}, -- 默认选中的玩法
    fanmaTitle = "翻马:",
    fanmaWanFa = "_ma",
    selectFanma = "4_ma",
    fanmaSpecial = {["99_ma"] = "1马(乘点数)", ["91_ma"] = "1马(加点数)", },
    fanmaDisableRule = {wumasuanquanma = 1, quanmajia1ma = 1,}, -- 特殊翻马时禁用的选项
    selectImg = "games/common/game/play_select.png",
    backgroundImg = "games/common/game/play_select_bg.png",
    maxWidth = G_ROOM_INFO_FORMAT.radioItemOffset * G_ROOM_INFO_FORMAT.groupColMax, -- 一行的最大宽度
    minHeight = G_ROOM_INFO_FORMAT.lineHeight, -- 一行的最小高度
}


local GameRoomInfoUI_hongzhongmj = class("GameRoomInfoUI_hongzhongmj", GameRoomInfoUIBase )


--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function GameRoomInfoUI_hongzhongmj:ctor(...)
    self.super.ctor(self, ...)
end

--地方组重写 初始化自己特有的数据
function GameRoomInfoUI_hongzhongmj:onInit()
end

--------------------------
-- 刷新一炮多响的按钮状态
function GameRoomInfoUI_hongzhongmj:refreshYPDXState()
    if self.m_ypdx then
        Log.i("setEnabled", self.m_keqianggang, self.m_kedianpao)
        self.m_ypdx:setEnabled(self.m_keqianggang or self.m_kedianpao)
        if not (self.m_keqianggang or self.m_kedianpao) then
            self.m_ypdx:setSelected(false)
        end
    end
end

--------------------------
-- 初始化玩法
function GameRoomInfoUI_hongzhongmj:initWanFa()
    --玩法:
    local tmpData = kFriendRoomInfo:getRoomBaseInfo()
    tmpData.wanfa = kRule.testWanfa
    self.m_wanfa_itemList = {}
    local list = Util.analyzeString_2(tmpData.wanfa)
    -- 将玩法分类
    for i, v in ipairs(list) do
        local info = MjGameConfigManager[self.m_gameID].kGetPlayingInfoByTitle(v, self.m_gameID)
        if info and info.model then
            if not self.m_wanfa_itemList[info.model] then
                self.m_wanfa_itemList[info.model] = {}
            end
            table.insert(self.m_wanfa_itemList[info.model], info)
        else
            Log.i("not found", v)
        end
    end
    Log.i("self.m_wanfa_itemList", self.m_wanfa_itemList)

    self:initWanFaPanel()
    self:initFanMa()
end

function GameRoomInfoUI_hongzhongmj:initWanFaPanel()
    self.m_ruleBtns = {}
    if(not self.m_wanfa_itemList.common) then
        return;
    end
    self.rulePanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/select_charge.csb")
    local title = ccui.Helper:seekWidgetByName(self.rulePanel, "title")
    title:setString(kRule.wanfaTitle)
    title:setPositionX(G_ROOM_INFO_FORMAT.titlePosX)
    title:setColor(G_ROOM_INFO_FORMAT.titleFontColor)
    title:setFontSize(G_ROOM_INFO_FORMAT.titleFontSize)

    local panel = ccui.Helper:seekWidgetByName(self.rulePanel, "radio_panel")
    panel:setPositionX(G_ROOM_INFO_FORMAT.firstPosX)

    local checkBoxData = {}
    checkBoxData.selectImg = kRule.selectImg
    checkBoxData.backgroundImg = kRule.backgroundImg

    local preX, preY = 0, 0 -- 记录开始时的位置
    local panelHeight = kRule.minHeight -- 玩法的总高度

    self.m_keqianggang = false
    self.m_kedianpao = false
    for i, v in ipairs(self.m_wanfa_itemList.common) do
        local data = clone(checkBoxData)
        data.textNormal = v.ch
        -- Log.i("data.textNormal", data.textNormal)
        data.index = v.title -- 直接设置为玩法
        -- 如果没有选中抢杠包三家或可点炮, 则一炮多响不能被选中
        if v.title == "qianggangbaosanjia" or v.title == "kedianpao" then
            data.callback = function(index, selected)
                if index == "qianggangbaosanjia" then
                    self.m_keqianggang = selected
                elseif index == "kedianpao" then
                    self.m_kedianpao = selected
                end
                self:refreshYPDXState()
            end
        end
        local btn = SelectRadioBtn.new(data)
        if v.title == "suportmutihu" then -- 记录一炮多响
            self.m_ypdx = btn
            self:refreshYPDXState()
        end
        -- 设置各个规则的位置
        local size = btn:getVirtualRendererSize()
        local itemWidth = kRule.maxWidth / G_ROOM_INFO_FORMAT.groupColMax -- 每行最多放G_ROOM_INFO_FORMAT.groupColMax个
        if size.width > kRule.maxWidth / 2 then
            itemWidth = kRule.maxWidth   -- 单独占一行
        elseif size.width > itemWidth then
            itemWidth = kRule.maxWidth / 2 -- 一行2个
        end

        if preX + itemWidth > kRule.maxWidth then -- 放不下则另起一行
            preX = 0
            preY = preY - kRule.minHeight
            panelHeight = panelHeight + kRule.minHeight
        end
        btn:setPosition(preX, preY)
        preX = preX + itemWidth

        table.insert(self.m_ruleBtns, btn)
        panel:addChild(btn)
    end

    -- 重设panel的大小
    title:setPositionY(panelHeight - kRule.minHeight / 2)
    panel:setContentSize(cc.size(panel:getContentSize().width, panelHeight))
    self.rulePanel:setContentSize(cc.size(self.rulePanel:getContentSize().width, panelHeight))

    -- 重设各个按钮的位置
    for k, v in ipairs(self.m_ruleBtns) do
        if kRule.selectRule[v:getIndex()] == 1 then
            v:setSelected(true)
        end
        v:setPositionY(v:getPositionY() + panelHeight - kRule.minHeight)
    end
    self:addScrollItem(self.rulePanel)
end

--------------------------
-- 初始化翻马
function GameRoomInfoUI_hongzhongmj:initFanMa()
    if not self.m_wanfa_itemList.fanma then
        return;
    end

    local data = {}
    data.radios = {}  -- 未选中情况下的文字
    -- data.index = {} -- 序号
    -- data.width = kRule.maxWidth / 3
    data.count = G_ROOM_INFO_FORMAT.groupColMax
    for i, v in ipairs(self.m_wanfa_itemList.fanma) do
        table.insert(data.radios, v.ch)
        -- table.insert(data.index, v.title)
    end
    data.title           = kRule.fanmaTitle -- 标题
    -- data.manualSelect    = true -- 手动选中, 避免出现多个复选框初始化完成前, 相互调用的问题
    for i, v in ipairs(self.m_wanfa_itemList.fanma) do
        -- 默认选中4马
        if v.title == kRule.selectFanma then data.select = i end
    end
    self.fanmaPanel = SelectRadioPanel.new(data, handler(self, self.selectedEvent))

    self:addScrollItem(self.fanmaPanel)
end

--[[
-- @brief  复选框按钮
-- @param  void
-- @return void
--]]
function GameRoomInfoUI_hongzhongmj:selectedEvent(index)
    Log.i("GameRoomInfoUI_hongzhongmj:selectedEvent index", index)
    local wanfa = self.m_wanfa_itemList.fanma[index].title
    if kRule.fanmaSpecial[wanfa] then
        for k, v in ipairs(self.m_ruleBtns) do
            if kRule.fanmaDisableRule[v:getIndex()] == 1 then
                v:setSelected(false)
                v:setEnabled(false)
            end
        end
    else
        for k, v in ipairs(self.m_ruleBtns) do
            if not v:getEnabled() then
                if kRule.selectRule[v:getIndex()] == 1 then
                    v:setSelected(true)
                end
                v:setEnabled(true)
                self:refreshYPDXState()
            end
        end
    end
    self.m_setData.fa = string.sub(wanfa, 1, string.find(wanfa, kRule.fanmaWanFa) - 1)
end

--[[
-- @brief  玩法组装工厂函数
-- @param  void
-- @return void
--]]
function GameRoomInfoUI_hongzhongmj:wanFaFactory()
    -- 拼装字符串
    local str = ""
    for i , v in ipairs(self.m_ruleBtns) do
        if v:getSelected() then
            str = str == "" and v:getIndex() or string.format("%s|%s", str, v:getIndex())
        end
    end
    local fanMa = self.m_setData.fa .. kRule.fanmaWanFa
    str = str == "" and fanMa or string.format("%s|%s", str, fanMa)
    -- str = "zhuangjia2di|wuhongzhongjiayidi|wumasuanquanma|quanmajia1ma|qixiaoduikehu"
    -- self.m_setData.fa = 6
    self.m_setData.wa = str
    Log.i("self.m_setData", self.m_setData)
    -- self.m_setData = nil
end


function GameRoomInfoUI_hongzhongmj:initRoomInfo()

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
                self._friendRoomDataManager:updateRoomPanel(v,string.format( "wanfa%d",i) )
            else
                self:updateRoomPanel(self.m_ruleBtns,string.format( "wanfa%d",i))
            end
        end
    end
end
--需要更新的panel
function GameRoomInfoUI_hongzhongmj:updateRoomPanel(panel,_key,_func)
    local panelData = self._friendRoomDataManager:getData(_key)
    if not panelData or #panelData <= 0 then
        return
    end
    local group = panel
    -- local children = panel:getChildren()
    for i , v in pairs(panelData) do
        -- if v._select then
        --     panel.select = i
        --     panel.m_selectedIndex = i
        --     panel.m_data.callback(i)
        -- end
        local child = group[i]
        child:setSelected(v._select)
        child:setEnabled(v._enabled)
        child:setVisible(v._visible)
        child:setPosition(cc.p(v._posX,v._posY))
    end

    if _func then
        _func(panelData)
    end
end
function GameRoomInfoUI_hongzhongmj:saveRoomInfo()
    local wanfa = self.m_itemChildren
    for i, v in pairs(wanfa) do
        if v and type(v) == "userdata" then
            if v.m_radioBtns then
                self._friendRoomDataManager:savePanelAllData(v.m_radioBtns,string.format( "wanfa%d",i))
            else
                self._friendRoomDataManager:savePanelAllData(self.m_ruleBtns,string.format( "wanfa%d",i))
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


return GameRoomInfoUI_hongzhongmj
