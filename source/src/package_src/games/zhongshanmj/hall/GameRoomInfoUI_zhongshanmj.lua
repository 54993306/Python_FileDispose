-------------------------------------------------------------
--  @file   GameRoomInfoUI_zhongshanmj.lua
--  @brief  创建房间规则界面
--  @author ZCQ
--  @DateTime:2016-11-07 12:08:58
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

require("app.DebugHelper")

local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
local SelectRadioPanel = import(".SelectRadioPanel")--require("app.hall.common.SelectRadioPanel")
local DropItem = require("app.games.common.custom.DropItem")
local GroupPanel = import(".GroupPanel")
local CheckBoxPanel= require("app.games.common.custom.CheckBoxPanel")
local GameRoomInfoUI_zhongshanmj = class("GameRoomInfoUI_zhongshanmj", GameRoomInfoUIBase )


local games={
    {
        radios={"白板鬼","红中鬼"},
        datas={47,45},
    },
    {
        radios={"鬼按位置看马","鬼算所有人的马"},
        datas={false,true},
    },
    {
        radios={"无鬼胡正常翻马","无鬼胡马牌数+2","无鬼胡马牌数+4"},
        datas={0,2,4},
    },
    {
        radios={"玩1马时字牌为5马","玩1马时字牌为10马"},
        datas={5,10},
    },
    {
        radios={"1,5,9鬼为马","按位置看马"},
        datas={{1,5,9},nil},
    },
}

local gameParams={
    "gui",
    "laizishima",
    "wuguihumapaishu",
    "zipaimashu",
    "mapailiebiao",
}

local gameWanfas={
    ["136gui"]={1,2,3},
    ["136wugui"]={},
    ["136guima1"]={1,4},
    ["136wuguima1"]={},

    ["120gui"]={1,2,3},
    ["120wugui"]={},
    ["120guima1"]={1,4},
    ["120wuguima1"]={},

    ["112gui"]={1,5},
    -- ["112wugui"]={4},
    ["112guima1"]={1,4},
    -- ["112wuguima1"]={4},

    ["108gui"]={2,3},
    ["108wugui"]={},
    ["108guima1"]={},
    ["108wuguima1"]={},
}


local function getWanfas(wanfa)
    local wanfas={}
    local wanfaParam={}
    if gameWanfas[wanfa] then
        for k,v in pairs(gameWanfas[wanfa]) do
            table.insert(wanfas,games[v])
            table.insert(wanfaParam,gameParams[v])
        end
    end
    return wanfas,wanfaParam
end

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function GameRoomInfoUI_zhongshanmj:ctor(...)
    self.super.ctor(self, ...)
end

--地方组重写 初始化自己特有的数据
function GameRoomInfoUI_zhongshanmj:onInit()
    -- 玩法规则
    self.kWanFa = {
        --是否带鬼
        [1] = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[1].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[2].title,
        },
        --无鬼是否可吃胡
        [2] = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[3].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[4].title,
        },
        --牌数
        [3] = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[5].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[6].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[7].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[8].title,
        },
        --白板鬼 红中鬼
        [4] = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[9].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[10].title,
        },
        --鬼按位置看马 鬼算所有人的马
        [5] = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[11].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[12].title,
        },
        --无鬼胡正常翻马+X
        [6] = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[13].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[14].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[15].title,
        },
        --玩1马时字牌为5马
        [7] = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[16].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[17].title,
        },
        --马数
        [8] = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[18].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[19].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[20].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[21].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[22].title,
        },
        --1,5,9鬼为马 按位置看马
        [9] = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[23].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[24].title,
        },
        --底分
        [10] = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[25].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[26].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[27].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[28].title,
        },
        --底分2
        [11] = {
            MjGameConfigManager[self.m_gameID]._gamePalyingName[29].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[30].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[31].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[32].title,
        },
    }

    --配置动态选项
    local gamePalyingName=MjGameConfigManager[self.m_gameID]._gamePalyingName
    self.m_configWanfans={
        --136张
        [gamePalyingName[5].title..gamePalyingName[1].title]={
            {index=4,radios={gamePalyingName[9].ch,gamePalyingName[10].ch}},
            {index=5,radios={gamePalyingName[11].ch,gamePalyingName[12].ch}},
            {index=6,radios={gamePalyingName[13].ch,gamePalyingName[14].ch,gamePalyingName[15].ch}},
        },--136带鬼
        [gamePalyingName[5].title..gamePalyingName[2].title]={},--136不带鬼
        [gamePalyingName[5].title..gamePalyingName[1].title..gamePalyingName[22].title]={
            {index=4,radios={gamePalyingName[9].ch,gamePalyingName[10].ch}},
            {index=7,radios={gamePalyingName[16].ch,gamePalyingName[17].ch}},
        },--136带鬼马1
        [gamePalyingName[5].title..gamePalyingName[2].title..gamePalyingName[22].title]={},--136不带鬼马1

        --120张
        [gamePalyingName[6].title..gamePalyingName[1].title]={ 
            {index=4,radios={gamePalyingName[9].ch,gamePalyingName[10].ch}},
            {index=5,radios={gamePalyingName[11].ch,gamePalyingName[12].ch}},
            {index=6,radios={gamePalyingName[13].ch,gamePalyingName[14].ch,gamePalyingName[15].ch}},
        },
        [gamePalyingName[6].title..gamePalyingName[2].title]={},
        [gamePalyingName[6].title..gamePalyingName[1].title..gamePalyingName[22].title]={
            {index=4,radios={gamePalyingName[9].ch,gamePalyingName[10].ch}},
            {index=7,radios={gamePalyingName[16].ch,gamePalyingName[17].ch}},
        },
        [gamePalyingName[6].title..gamePalyingName[2].title..gamePalyingName[22].title]={},

        --112张
        [gamePalyingName[7].title..gamePalyingName[1].title]={
            {index=4,radios={gamePalyingName[9].ch,gamePalyingName[10].ch}},
            {index=9,radios={gamePalyingName[23].ch,gamePalyingName[24].ch}},
        },
        [gamePalyingName[7].title..gamePalyingName[1].title..gamePalyingName[22].title]={
            {index=4,radios={gamePalyingName[9].ch,gamePalyingName[10].ch}},
            {index=7,radios={gamePalyingName[16].ch,gamePalyingName[17].ch}},
        },

        --108张
        [gamePalyingName[8].title..gamePalyingName[1].title]={
            {index=5,radios={gamePalyingName[11].ch,gamePalyingName[12].ch}},
            {index=6,radios={gamePalyingName[13].ch,gamePalyingName[14].ch,gamePalyingName[15].ch}},
        },
        [gamePalyingName[8].title..gamePalyingName[2].title]={},
        [gamePalyingName[8].title..gamePalyingName[1].title..gamePalyingName[22].title]={},
        [gamePalyingName[8].title..gamePalyingName[2].title..gamePalyingName[22].title]={},
    }

    self.wanfaItems={}
    self.wanfas2={}
    -- self.payTypes = {enFriendRoomPayType.Owner, enFriendRoomPayType.Winer}
end


-- function GameRoomInfoUI_zhongshanmj:addScrollItem(item)
--     if item then
--         self.itemChildren[#self.itemChildren + 1] = item
--         self.height = self.height + item:getContentSize().height
--     end
-- end

function GameRoomInfoUI_zhongshanmj:removeScrollItem(item)
    for k,v in pairs(self.m_itemChildren) do
        if v==item then
            table.remove(self.m_itemChildren,k)
            -- self.height = self.height - item:getContentSize().height
            item:removeFromParent()
            break
        end
    end
end

-- 创建玩法
function GameRoomInfoUI_zhongshanmj:initWanFa()
    local tmpData = self.m_roomBaseInfo

    --玩法:
    self.m_wanfa_itemList = Util.analyzeString_2(tmpData.wanfa);
    if(not self.m_wanfa_itemList) then
        return;
    end

    local lists={}

    local item1=nil
    local item2=nil
    local isInit=true

    local gamePalyingName=MjGameConfigManager[self.m_gameID]._gamePalyingName

    local function updateWanfa()
        if not isInit then return end
        local paishu=self.m_wanfa[3] or gamePalyingName[5].title--self.wanfas.paishu or 136
        local gui=self.m_wanfa[1] or gamePalyingName[1].title
        if paishu==gamePalyingName[7].title then --112张
            gui=gamePalyingName[1].title
            -- self.wanfas.yougui=true
        end
        local ma=self.m_wanfa[8] and self.m_wanfa[8] == gamePalyingName[22].title and gamePalyingName[22].title or ""
        -- local gui=self.wanfas.yougui and self.wanfas.yougui==true and "gui" or "wugui" --self.m_group and self.m_group:getSelectedIndex()==1 and "gui" or "wugui"
        local wanfa=paishu..gui..ma
        self:upateWanFa(wanfa)
    end

    local data1={
        -- title="底分:",
        radios={
            MjGameConfigManager[self.m_gameID]._gamePalyingName[25].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[26].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[27].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[28].ch
        },
        datas={
            MjGameConfigManager[self.m_gameID]._gamePalyingName[25].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[26].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[27].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[28].title
        },
        clickback=function(item)
            if item then
                for k,v in pairs(lists) do
                    if item ~= v then
                        v:hideList()
                    end
                end
            else
                if dropRadioGroup then
                    dropRadioGroup:setSelectedIndex(2)
                end
                item2:setTitleColorNormal()
            end
        end,
        zorder=3,
        width=190,
        -- line=true,
    }

    data1.callback=function(index)
        self.m_wanfa[10]=data1.datas[index]
        self.m_wanfa[11]=nil
        -- self.wanfas.dpfen=data1.datas[index].dpfen
        -- self.wanfas.zmfen=data1.datas[index].zmfen
    end

    item1=DropItem.new(data1)
    table.insert(lists,item1)

    local data2={
        -- title="               ",
        radios={
            MjGameConfigManager[self.m_gameID]._gamePalyingName[29].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[30].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[31].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[32].ch
        },
        datas={
            MjGameConfigManager[self.m_gameID]._gamePalyingName[29].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[30].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[31].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[32].title
        },
        clickback=function(item)
            if item then
                for k,v in pairs(lists) do
                    if item ~= v then
                        v:hideList()
                    end
                end
            else
                if dropRadioGroup then
                    dropRadioGroup:setSelectedIndex(1)
                end
                item1:setTitleColorNormal()
            end
        end,
        initX=135,
        zorder=2,
        width=190,
    }
    data2.callback=function(index)
        self.m_wanfa[10]=nil
        self.m_wanfa[11]=data2.datas[index]
        -- self.wanfas.dpfen=data2.datas[index].dpfen
        -- self.wanfas.zmfen=data2.datas[index].zmfen
    end
    item2=DropItem.new(data2)
    -- item2:setTitleColorNormal()
     -- self:addScrollItem(item2)
    table.insert(lists,item2)


    local dropRadio={
        title="底分:",
        radios={"",""},
        -- width=307,
        -- datas={},
    }

    dropRadioGroup = SelectRadioPanel.new(dropRadio, function(index)
        if index==1 then
            item2:setSelectIndex()
            item1:setTitleColorNormal()
        else
            item1:setSelectIndex()
            item2:setTitleColorNormal()
        end
    end)
    item1:setTitleColorNormal()

    local groupPanel1=GroupPanel.new({panels={item2,item1},pad=100,initX=30})
    self:addScrollItem(groupPanel1)
    groupPanel1:setLocalZOrder(2)
    groupPanel1:addChild(dropRadioGroup)



    local checksData = {
        options =
        {
            --  选项1
            {
                --  文本
                text =  MjGameConfigManager[self.m_gameID]._gamePalyingName[4].ch,
                --  复选框默认是否选中，不传则作false处理
                isSelected = false
            },
        }
        -- title = "无鬼可吃胡",
        -- callback=function(enable)
        --     self.wanfas.wuguikechihu=enable
        -- end
    }
    local checkBox = CheckBoxPanel.new(checksData,function(tag,enable)
        self.m_wanfa[2]=self.kWanFa[2][enable and 2 or 1]
        -- self.wanfas.wuguikechsihu=enable
    end)

    local datas={
        radios={MjGameConfigManager[self.m_gameID]._gamePalyingName[1].ch,MjGameConfigManager[self.m_gameID]._gamePalyingName[2].ch},
        width=160,
        --datas={},
    }


    local group3 = SelectRadioPanel.new(datas, function(index)
        self.m_wanfa[1]=self.kWanFa[1][index]
        -- self.wanfas.yougui=index==1
        -- checkBox:setEnabled(index==1)
        checkBox:setVisible(index==1)
        checkBox:setSelectedIndex(index==2,1)
           
        updateWanfa()
    end)
    -- self:addScrollItem(group3)

  
    -- checkBox:setSelected(false)
    -- group3:removeLine()
    self.m_group=group3
    self.m_checkBox=checkBox


    local data3={
        title="玩法:",
        radios={
            MjGameConfigManager[self.m_gameID]._gamePalyingName[5].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[6].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[7].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[8].ch
        },
        datas={
            MjGameConfigManager[self.m_gameID]._gamePalyingName[5].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[6].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[7].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[8].title
        },
        initX=25,
        -- width=180,
        -- callback=callbackCard,
        -- index=index,
        clickback=function(item)
            for k,v in pairs(lists) do
                if item ~= v then
                    v:hideList()
                end
            end
        end,
    }

    data3.callback=function(index)
        self.m_wanfa[3]=self.kWanFa[3][index]
        -- self.wanfas.paishu=data3.datas[index]
        updateWanfa()
    end


    local item3=DropItem.new(data3)
    self:addScrollItem(item3)
    table.insert(lists,item3)

    local groupPanel2=GroupPanel.new({panels={group3,checkBox},pad=-110})
    self:addScrollItem(groupPanel2)
    groupPanel2:setLocalZOrder(1)
    checkBox:setPosition(345,8)


    local data4={
        radios={
            MjGameConfigManager[self.m_gameID]._gamePalyingName[18].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[19].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[20].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[21].ch,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[22].ch
        },
        width=115,
        count=5,
        datas={
            MjGameConfigManager[self.m_gameID]._gamePalyingName[18].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[19].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[20].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[21].title,
            MjGameConfigManager[self.m_gameID]._gamePalyingName[22].title
        },
    }


    local group4 = SelectRadioPanel.new(data4, function(index)
        self.m_wanfa[8]=self.kWanFa[8][index]
        -- self.wanfas.mashu=data4.datas[index]
        updateWanfa()
    end)

    -- group4:removeLine()
    self:addScrollItem(group4)


    -- local wanFaDatas1 = {
    --     title = "底分:", 
    --     radios = {  
    --         MjGameConfigManager[self.m_gameID]._gamePalyingName[1].ch,
    --         MjGameConfigManager[self.m_gameID]._gamePalyingName[2].ch 
    --     },
    --     -- width=307
    -- }
    -- local group1 = SelectRadioPanel.new(wanFaDatas1, function(index)
    --     self.m_wanfa[1] = self.kWanFa[1][index]
    -- end)
    -- self:addScrollItem(group1)

    isInit=true
    updateWanfa()
end

function GameRoomInfoUI_zhongshanmj:upateWanFa(wanfa)
    self.wanfas2={}
    -- dump(paraWanfa)
    local wanfas=self.m_configWanfans[wanfa] or {}--,wanfaParams = getWanfas(wanfa)
    dump(wanfas)

    if #self.wanfaItems>0 then
        for k,item in pairs(self.wanfaItems) do
            self:removeScrollItem(item)
        end
        self.wanfaItems={}
    end
    -- local wuguihumapaishu
    -- dump(games)
    -- dump(wanfaIndex)
    for k,v in pairs(wanfas) do
        local datas={
            radios=v.radios,
            -- width=307,
            hiddenLine=true,
        }

        dump(v.radios,#v.radios)
        if #v.radios==3 then
            datas.count=2
        end

        if v.index==7 then
            datas.count=1
        end

        local group = SelectRadioPanel.new(datas, function(i)
            self.wanfas2[v.index]=self.kWanFa[v.index][i]
            -- local para=wanfaParams[k]
            -- self.wanfas2[para]=v.datas[i]
        end)

        -- if #v.radios==3 then
        --     local btn=group:getBtnByIndex(3)
        --     btn:setPositionX(datas.width)
        -- end

        -- if k<#wanfas then
        --     group:removeLine()
        -- end
        self:addScrollItem(group)
        table.insert(self.wanfaItems,group)
    end

    if self.m_group then
        if string.find(wanfa,"112") then 
            self.m_group:getBtnByIndex(2):setVisible(false)
            self.m_group:setSelectedIndexShow(1)
            
            if self.m_checkBox then
                -- self.m_checkBox:setEnabled(true)
                self.m_checkBox:setVisible(true)
                -- self.m_checkBox:setSelected(false)
            end
        else
            self.m_group:getBtnByIndex(2):setVisible(true)
        end
    end

    self:viewLayout()
     -- self:updatePosition()
end


--[[
-- @brief  玩法组装工厂函数
-- @param  void
-- @return void
--]]
function GameRoomInfoUI_zhongshanmj:wanFaFactory()
    -- 拼装字符串
    local str = ""
    for k, v in pairs(self.m_wanfa) do
        str = str == "" and v or string.format("%s|%s", str, v)
    end

    for k, v in pairs(self.wanfas2) do
        str = str == "" and v or string.format("%s|%s", str, v)
    end

    -- local temp={}

    -- table.merge(temp, self.wanfas)
    -- table.merge(temp, self.wanfas2)


    -- dump(temp)

    self.m_setData.wa = str--json.encode(temp)
    -- print(self.m_setData.wa)
    -- error("wanFaFactory")
end



return GameRoomInfoUI_zhongshanmj