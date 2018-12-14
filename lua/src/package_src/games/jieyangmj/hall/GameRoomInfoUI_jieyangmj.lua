--
-- Author: RuiHao Lin
-- Date: 2017-05-08 10:17:58
--

require("app.DebugHelper")

local SelectRadioPanel = require("app.hall.common.SelectRadioPanel")
local RadioButtonGroup = require("app.games.common.custom.RadioButtonGroup")
local DropItem = require("app.games.common.custom.DropItem")--import(".DropItem")
local CheckBoxPanel= require("app.games.common.custom.CheckBoxPanel") --require("app.games.common.custom.CheckBoxPanel")--
local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
-- local CheckBoxPanel= import(".CheckBoxPanel") --require("app.games.common.custom.CheckBoxPanel")--
local GroupPanel= import(".GroupPanel")

local GameRoomInfoUI_jieyangmj = class("GameRoomInfoUI_jieyangmj", GameRoomInfoUIBase)

function GameRoomInfoUI_jieyangmj:ctor(...)
    self.super.ctor(self, ...)
end

function GameRoomInfoUI_jieyangmj:onInit()
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
    self.m_setData = {}
    self.wanfas= {}
    self.wanfas2={}
    self.init = {}
    self.itemChildren = {}
    self.height = 0
    self.m_GameRule = MjGameConfigManager[self.m_gameID]._gamePalyingName
    -- self:initSelect()
end

function GameRoomInfoUI_jieyangmj:initWanFa()
    self.wanfaItems={}
    self.isInit=false
-- 
    local lists={}
  
    local item1=nil
    local item2=nil

--          --底数
    self.m_dropData={}
    for i=1,10 do
       local tmpData={}
       tmpData.title = i .. " 分";
       tmpData.data = "difen"..i;
       table.insert(self.m_dropData,tmpData);
    end

    local data1={
        title="底分:",
        radios={},
        datas={},
        clickback=function(item)
            if item then
                for k,v in pairs(lists) do
                    if item ~= v then
                        v:hideList()
                    end
                end
            else
                -- item1:setTitleColorNormal()
            end
        end,
        zorder=2,
        width=140,
    }

    for i=1,10 do
        data1.radios[i]=self.m_dropData[i].title
        data1.datas[i]=self.m_dropData[i].data
    end

    data1.callback=function(index)
         self.m_wanfa[1]=data1.datas[index]
    end

    item1=DropItem.new(data1)

    local data2={
        title="买马:",
        radios={},
        datas={},
        index = 3,
        clickback=function(item)
            if item then
                for k,v in pairs(lists) do
                    if item ~= v then
                        v:hideList()
                    end
                end
            else
                -- item1:setTitleColorNormal()
            end
        end,
        zorder=2,
        width=150,
    }

    self.groups1={}
    local checksDataMa={
            options={
             {
                --  文本
                text = "马固定底X2",
                --  复选框默认是否选中，不传则作false处理
                isSelected = false
            }

            },

            Config =
            {
                LineVisible = false, 
                OptionPanelSize = cc.size(300, G_ROOM_INFO_FORMAT.lineHeight)
            },
        }
      table.insert(self.groups1,CheckBoxPanel.new(checksDataMa,function(index)
                if self.init[3]  == nil then
                   self.init[3] =true
                  return
                end

                if self.m_wanfa[3] == nil then
                    self.m_wanfa[3] = "maall2"
                else
                    self.m_wanfa[3] = nil
                end
        end))


    self.m_dropData2={}
    local tmpData2 = {}
    tmpData2 = {{title="无 马",data="jiangma"},
                {title="2 马",data="jiangma2"},
                {title="4 马",data="jiangma4"},
                {title="6 马",data="jiangma6"},
                {title="8 马",data="jiangma8"},
                {title="10 马",data="jiangma10"},
            }
    self.m_dropData2 = tmpData2

    for i=1,6 do
        data2.radios[i]=self.m_dropData2[i].title
        data2.datas[i]=self.m_dropData2[i].data
    end

    data2.callback=function(index)
       self.m_wanfa[2]=data2.datas[index]
        if not self.groups1 then
            return;
        end
        if index > 1 then
          self.groups1[1]:setBtnEnabled(1,true)
        else
          self.groups1[1]:setBtnEnabled(1,false)
          self.groups1[1]:setSelectedIndex(false,1)
          self.m_wanfa[3] = nil
        end

    end

    item2=DropItem.new(data2)

    self.groups2={}
    local isZhuaMa={
            options={
             {
                --  文本
                text = "抓马",
                --  复选框默认是否选中，不传则作false处理
                isSelected = false
            }
            },
            Config =
            {
                LineVisible = false, 
                OptionPanelSize = cc.size(100, G_ROOM_INFO_FORMAT.lineHeight)
            },
        }
        table.insert(self.groups2,CheckBoxPanel.new(isZhuaMa,function(index)
                if self.init[4]  == nil then
                   self.init[4] =true
                  return
                end

                if self.m_wanfa[4] == nil then
                     self.m_wanfa[4] = "zhuama"
                else
                    self.m_wanfa[4] = nil
                end
        end))

    local groupPanel6=GroupPanel.new({panels=self.groups1})
    local groupPanel7=GroupPanel.new({panels=self.groups2})
    local groupPanel1=GroupPanel.new({panels={item1,item2},pad= 140})--checkBox 做了特殊处理 但是没做通用
    local groupPanel2=GroupPanel.new({panels={groupPanel6,groupPanel7},pad=300})
    self:addScrollItem(groupPanel1)
    self:addScrollItem(groupPanel2)
    groupPanel1:setLocalZOrder(1)

     self.m_dropData3={}
    local tmpData3 = {}
    tmpData3 = {{title="无鬼",data="wugui"},
                {title="白板",data="baibanzuogui"},
                {title="红中",data="zhongzuogui"},
                {title="翻鬼",data="fangui"},
            }
    self.m_dropData3 = tmpData3

    local selectDatas1={
        title="鬼牌:",
        radios={self.m_dropData3[1].title,self.m_dropData3[2].title,self.m_dropData3[3].title,self.m_dropData3[4].title},
        width=300,
        count=2,
        datas={self.m_dropData3[1].data,self.m_dropData3[2].data,self.m_dropData3[3].data,self.m_dropData3[4].data},
    }


    local selectRadio1 = SelectRadioPanel.new(selectDatas1, function(index)
        self.m_wanfa[5]=selectDatas1.datas[index]
    end)

    self:addScrollItem(selectRadio1)


    self.m_dropData4={}
    local tmpData4 = {}
    tmpData4 = {{title="不封顶",data="bushefengding"},
                {title="5倍封顶",data="wubeifengding"},
                {title="10倍封顶",data="shibeifengding"},
            }
    self.m_dropData4 = tmpData4

    local selectDatas2={
        title="胡牌:",
        radios={self.m_dropData4[1].title,self.m_dropData4[2].title,self.m_dropData4[3].title},
        width=300,
        datas={self.m_dropData4[1].data,self.m_dropData4[2].data,self.m_dropData4[3].data},
    }

    local selectRadio2 = SelectRadioPanel.new(selectDatas2, function(index)
        self.m_wanfa[6] = selectDatas2.datas[index]
    end)

    self:addScrollItem(selectRadio2)
    self.selectRadio2=selectRadio2


--      --牌型
    -- self.m_dropData5={}
    -- local tmpData5 = {}
    -- tmpData5 = {{title="首圈未抓牌可胡",data="dihuwuzhuapaihu"},
    --             {title="只胡庄炮",data="dihuhuzhuangdiyipao"},
    --         }
    -- self.m_dropData5 = tmpData5

    -- local selectDatas3={
    --     title="地胡:",
    --     radios={self.m_dropData5[1].title,self.m_dropData5[2].title},
    --     width=300,
    --     datas={self.m_dropData5[1].data,self.m_dropData5[2].data},
    -- }

    -- local selectRadio3 = SelectRadioPanel.new(selectDatas3, function(index)
    --    self.m_wanfa[7]=selectDatas3.datas[index]
    -- end)


    -- self:addScrollItem(selectRadio3)
    -- self.selectRadio3 = selectRadio3


    self.m_dropData6={}
    local tmpData6 = {}
    tmpData6 = {{title="杠开X2",data="gangkaifanbei"},
                {title="海底捞X2",data="haidilaofanbei"},
                {title="黄庄黄杠",data="huangzhuanghg"},
                {title="可接炮胡",data="kejiepao"},
                {title="抢杠胡X3",data="qiangganghu_X3_b3j"},
                {title="10倍听牌可接炮",data="shibeitingbaikejiepao"},
                {title="10倍听牌可免分",data="shibeitingbaikemianfen"},
            }
    self.m_dropData6 = tmpData6

 self.groups3={}
    local checksData3={
            title="玩法:",
            options=
             {
                --  文本
                { text = self.m_dropData6[1].title,isSelected = true},
                { text = self.m_dropData6[2].title},
                { text = self.m_dropData6[3].title},
                { text = self.m_dropData6[4].title},
                { text = self.m_dropData6[5].title,isSelected = true},
                { text = self.m_dropData6[6].title},
                { text = self.m_dropData6[7].title},
            },

        }

    checksData3.callback = function(tag, isSelected)
        local index = tag + 7
        if isSelected then
            self.m_wanfa[index] = self.m_dropData6[tag].data
        else
            self.m_wanfa[index] = nil
        end
    end

    local groupPanel4=CheckBoxPanel.new(checksData3,checksData3.callback)
    self:addScrollItem(groupPanel4)
end


--[[
-- @brief  玩法组装工厂函数
-- @param  void
-- @return void
--]]
-- function GameRoomInfoUI_jieyangmj:wanFaFactory()
--    local str = ""
--     for k , v in pairs(self.m_wanfa) do
--         -- str = str == "" and v or string.format("%s|%s", str, v)
--         if v == "" then
            
--         else
--             if self.isShowEableRule == false then
--                 --if MjGameConfigManager[self.m_gameID]._gamePalyingName[7].title == v then
--                 --else
--                 --    str = str == "" and v or string.format("%s|%s", str, v)
--                 --end 
--             else
--                 str = str == "" and v or string.format("%s|%s", str, v) 
--             end
--         end
--     end

--     self.m_setData.wa = str
--     Log.i("self.m_setData", self.m_setData)

-- end



return GameRoomInfoUI_jieyangmj