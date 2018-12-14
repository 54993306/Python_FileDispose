-------------------------------------------------------------
--  @file   GameRoomInfoUI_hongzhongmj.lua
--  @brief  创建房间规则界面
--  @author ZCQ
--  @DateTime:2016-11-07 12:08:58
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

require("app.DebugHelper")

local hupaiData = {"zimohu","dianpaohu"}
local xiapaoData = {"zuida3pao","zuida5pao"}

local kRule = {
    personNumbers = {3, 2},
    personDatas = {title = "人数:", radios = {"3人", "2人"}},
    chargeDatas = {title = "房费:", radios = {"房主付费", "大赢家付费", "AA付费"}, hiddenLine = true},
    jushuText = "%s局(%s房卡)",
    jushuTitle = "局数:",
    selectImg = "package_res/games/ddztwop/hall/friendRoom/play_select.png",
    backgroundImg = "package_res/games/ddztwop/hall/friendRoom/play_select_bg.png",
    maxWidth = 720, -- 一行的最大宽度
    minHeight = 60, -- 一行的最小高度
}

local SelectRadioPanel = require("app.hall.common.SelectRadioPanel")
local SelectRadioBtn = require("app.hall.common.SelectRadioBtn")

local GameRoomInfoUI_ddztwop = class("GameRoomInfoUI_ddztwop", function()
    local ret = display.newNode()
    return ret
end)


--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function GameRoomInfoUI_ddztwop:ctor(...)
    -- self.super.ctor(self, kResPath.."friendRoomCreate.csb", ...);
    -- self.super.ctor(...)
    self.m_data=...;
    self:onInit()
end


function GameRoomInfoUI_ddztwop:onInit()
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

    self.itemChildren = {}

    self.height = 0

    self:initDDZTWOP()

end

function GameRoomInfoUI_ddztwop:addScrollItem(item)
    if item then
        self.itemChildren[#self.itemChildren + 1] = item
        self.height = self.height + item:getContentSize().height
    end
end

function GameRoomInfoUI_ddztwop:initDDZTWOP()
   
    local numbers = {3, 2}
    local SelectRadioPanel = require("app.hall.common.SelectRadioPanel")
    local group1 = SelectRadioPanel.new(kRule.personDatas, function(index)
        if index == 1 then
            package.loaded["package_src.games.ddztwop.GameConfig"] = nil
            require("package_src.games.ddz.GameConfig")
        else
            package.loaded["package_src.games.ddz.GameConfig"] = nil
            require("package_src.games.ddztwop.GameConfig")
        end
        self.m_setData.plS = kRule.personNumbers[index]
    end)

    self:addScrollItem(group1)

    self:setInitSelect()

    -- local group4 = SelectRadioPanel.new(kRule.hupaiDatas, function(index)
    --     self.waHu = hupaiData[index]
    -- end)

    -- self:addScrollItem(group4)

    -- local group5 = SelectRadioPanel.new(kRule.xiapaoDatas, function(index)
    --     self.waXia = xiapaoData[index]
    -- end)

    -- self:addScrollItem(group5)

    -- self:initWanFa()

    local group2 = SelectRadioPanel.new(kRule.chargeDatas, function(index)
        self.m_setData.RoJST = index
    end)

    self:addScrollItem(group2)


    self.height = self.height < self.m_data.height and self.m_data.height or self.height

    self:setContentSize(cc.size(self.m_data.width, self.height))

    local offsetY = 8
    for i , v in ipairs(self.itemChildren) do
        local h = v:getContentSize().height
        offsetY = offsetY + h
        v:setPosition(cc.p(0, self.height - offsetY))
        v:setAnchorPoint(cc.p(0, 0))
        self:addChild(v, 10)
    end
end


function GameRoomInfoUI_ddztwop:getData()
    self.m_setData.gaI = kFriendRoomInfo:getGameID();
    -- 玩法工厂
    --self:wanFaFactory()

    return self.m_setData;

end

--guizhe_ScrollView  是承载玩法的控件
function GameRoomInfoUI_ddztwop:setInitSelect()
    local tmpData = kFriendRoomInfo:getRoomBaseInfo()

    --局数:
    self.m_jushu_itemList = Util.analyzeString_2(tmpData.roundSum);
    self.m_fangfei_itemList = tmpData.roomFeeMap.common--Util.analyzeString_2();
    if(not self.m_jushu_itemList) then
        return;
    end

    local textDatas = {}
    for i, v in ipairs(self.m_jushu_itemList) do
        local text = string.format(kRule.jushuText, self.m_jushu_itemList[i], self.m_fangfei_itemList["3"]["8"])
        table.insert(textDatas, text)
    end

    local juShuDatas = {title = kRule.jushuTitle, radios = textDatas}

    SelectRadioPanel = require("app.hall.common.SelectRadioPanel")
    local group3 = SelectRadioPanel.new(juShuDatas, function(index)
        self.m_setData.roS = 8--self.m_jushu_itemList[index];
        self.m_setData.RoFS = 1--self.m_fangfei_itemList[index];
    end)
    
    self:addScrollItem(group3)
end

--------------------------
-- 初始化玩法
-- function GameRoomInfoUI_ddztwop:initWanFa()
--     --玩法:
--     local tmpData = kFriendRoomInfo:getRoomBaseInfo()
--     -- Log.i("self.tmpData", tmpData)
--     tmpData.wanfa = kRule.testWanfa -- 测试用
--     self.m_wanfa_itemList = Util.analyzeString_2(tmpData.wanfa);
--     self.m_ruleBtns = {}
--     if(not self.m_wanfa_itemList) then
--         return;
--     end
--     self.rulePanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/select_charge.csb")
--     local title = ccui.Helper:seekWidgetByName(self.rulePanel, "title")
--     title:setString(kRule.wanfaTitle)
--     title:setPositionY(title:getPositionY() + 2 * kRule.minHeight - 1)
--     local panel = ccui.Helper:seekWidgetByName(self.rulePanel, "radio_panel")

--     local checkBoxData = {}
--     checkBoxData.selectImg = kRule.selectImg
--     checkBoxData.backgroundImg = kRule.backgroundImg

--     local preX, preY = 0, 0 -- 记录开始时的位置
--     local panelHeight = kRule.minHeight -- 玩法的总高度

--      local gameId = HallAPI.DataAPI:getGameId()
--     for i, v in ipairs(self.m_wanfa_itemList) do
--         local data = clone(checkBoxData)
--         data.textNormal = HallAPI.DataAPI:getPlayingInfoByTitle(self.m_wanfa_itemList[i],gameId).ch
--         Log.i("data.textNormal", data.textNormal)
--         data.index = v -- 直接设置为玩法
--         local btn = SelectRadioBtn.new(data)
--         -- 设置各个规则的位置
--         local size = btn:getVirtualRendererSize()
--         local itemWidth = kRule.maxWidth / 3 -- 每行最多放3个
--         if size.width > kRule.maxWidth / 2 then
--             --itemWidth = kRule.maxWidth   -- 单独占一行
--             preX = preX - 50
--         elseif size.width > itemWidth then
--             itemWidth = kRule.maxWidth / 2 -- 一行2个
--         end

--         if preX + itemWidth > kRule.maxWidth then -- 放不下则另起一行
--             preX = 0
--             preY = preY - kRule.minHeight
--             panelHeight = panelHeight + kRule.minHeight
--         end
--         btn:setPosition(preX, preY)
--         preX = preX + itemWidth

--         table.insert(self.m_ruleBtns, btn)
--         panel:addChild(btn)
--     end

--     -- 重设panel的大小
--     panel:setContentSize(cc.size(panel:getContentSize().width, panelHeight))
--     self.rulePanel:setContentSize(cc.size(self.rulePanel:getContentSize().width, panelHeight))

--     -- 重设各个按钮的位置
--     for k, v in ipairs(self.m_ruleBtns) do
--         if kRule.selectRule[v:getIndex()] == 1 then
--             v:setSelected(true)
--         end
--         v:setPositionY(v:getPositionY() + panelHeight - kRule.minHeight)
--     end
--     self:addScrollItem(self.rulePanel)
-- end

--------------------------
--[[
-- @brief  复选框按钮
-- @param  void
-- @return void
--]]
function GameRoomInfoUI_ddztwop:selectedEvent(index)
    Log.i("GameRoomInfoUI_DDZTWOP:selectedEvent index", index)
    if index == kFanMaInfo.specialFanma then
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
            end
        end
    end
    self.m_setData.fa = index
end

--[[
-- @brief  玩法组装工厂函数
-- @param  void
-- @return void
--]]
-- function GameRoomInfoUI_ddztwop:wanFaFactory()
--     -- 拼装字符串
--     local str = ""
--     for i , v in ipairs(self.m_ruleBtns) do
--         if v:getSelected() then
--             str = str == "" and v:getIndex() or string.format("%s|%s", str, v:getIndex())
--         end
--     end
--     --local fanMa = self.m_setData.fa .. kFanMaInfo.fanmaWanFa
--     --str = str == "" and fanMa or string.format("%s|%s", str, fanMa)
--     -- str = "zhuangjia2di|wuhongzhongjiayidi|wumasuanquanma|quanmajia1ma|qixiaoduikehu"
--     -- self.m_setData.fa = 6
--     if str == "" then
--         str = self.waHu .."|" ..self.waXia
--     else
--         str = str .. "|" .. self.waHu .. "|" .. self.waXia
--     end
--     self.m_setData.wa = str
--     Log.i("self.m_setData", self.m_setData)
--     -- self.m_setData = nil
-- end

return GameRoomInfoUI_ddztwop