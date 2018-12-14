--
-- Author: RuiHao Lin
-- Date: 2017-05-08 10:17:58
--
--[[
G_ROOM_INFO_FORMAT = {
--这些项目基本上都是可以自定义配置的。
--这里设定的是默认值
--具体可根据具体排版创建的时候传参数修改
    normalColor = G_ROOM_INFO_FORMAT.normalColor, --未选文本颜色
    normalDropFontColor = cc.c3b(255, 255, 255),
    selectColor = G_ROOM_INFO_FORMAT.selectColor, --选中文本颜色
]]

require("app.DebugHelper")
local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
local CommonCheckBoxPanel = require("package_src.games.guangdongyibaizhangmj.hall.CommonCheckBoxPanel")
local lRadioButtonGroupPath = "app.games.common.custom.RadioButtonGroup"
-- local DropDownBoxPanel = require("app.games.common.custom.DropDownBox.DropDownBoxPanel")


local GameRoomInfoUI_guangdongyibaizhangmj = class("GameRoomInfoUI_guangdongyibaizhangmj", GameRoomInfoUIBase )


function GameRoomInfoUI_guangdongyibaizhangmj:ctor(...)
    self.super.ctor(self, ...)
    -- self.m_items:setLocalZOrder(999)
end


--地方组重写 初始化自己特有的数据
function GameRoomInfoUI_guangdongyibaizhangmj:onInit()
    self.m_difen = {}
    self.gamePalyingName = MjGameConfigManager[self.m_gameID]._gamePalyingName
   
end

--初始化低分下拉列表
function GameRoomInfoUI_guangdongyibaizhangmj:initDiFen()
   local RadioButtonGroup = require(lRadioButtonGroupPath)
    local dataWanFa =
    {
        title = "底分",
        options =
        {
            { text = self.gamePalyingName[1].ch,isSelected = true},
            { text = self.gamePalyingName[2].ch},
            { text = self.gamePalyingName[3].ch},
            { text = self.gamePalyingName[4].ch},
        },
    }
   local groupWanFa = RadioButtonGroup.new(dataWanFa, function(index)
        self.m_wanfa[1] = self.gamePalyingName[index].title
    end )
    self:addScrollItem(groupWanFa)
   
end

function GameRoomInfoUI_guangdongyibaizhangmj:initWanFa()
    local baseInfo = kFriendRoomInfo:getRoomBaseInfo()
    local wanfa = Util.analyzeString_2(baseInfo.wanfa)
    -- local wanfaPosY = self.m_jushuPanel:getPositionY()
    local wanfaTable = {}
    for i,v in pairs(wanfa) do
        if v == "wg" then
            table.insert(wanfaTable,"guipai")
        elseif v == "wuma" then
            table.insert(wanfaTable,"mapai")
        end
        table.insert(wanfaTable,v)
    end
    wanfa = wanfaTable
    Log.i("wanfa",wanfa)
    local data = {}
    data.title = "玩法:"
    data.content = {} 
    local index = 0
    for i,v in pairs(wanfa) do
        local manager = Util.analyzeString_2(v)
        Log.i("manager",manager)
        local line = false
        for j,k in pairs(manager) do
            local v = wanfa[i]
            Log.i("v",v)
            local m_data = {}
            m_data.name = kFriendRoomInfo:getPlayingInfoByTitle(k).ch
            m_data.chick = k 
            if v == "keqianggh" or v == "qgqb"
            or v == "gangbaoqb" or v == "sghp"
            or v == "pph"  or v == "qingyise"
            or v == "quanfeng"  or  v == "hunyise" 
            or v == "qidui"  or  v == "gz"
            or v == "mgd"  or v == "mgg" 
            or v == "yj"  or v == "wgjb"  then 
                m_data.multi = true
                -- m_data.isSelect = true
            end
            if v == "keqianggh" or v == "qgqb"
                or v == "gangbaoqb" or v == "pph"  or v == "sghp" then
                m_data.isSelect = true
            end
            if v == "guipai" or v == "mapai" then
                m_data.title = true
                m_data.newline = true
            end
            if v == "fg" or v == "liuma" then
                m_data.isSelect = true
            end
           
            if v == "hyj" or v == "sghp2b"  or v == "minggangkq" then --子选项
                m_data.itemSelect = true
                m_data.multi = true
            end
            
            if v == "qgqb" then
                m_data.newline = true
            end
            if v == "sghp" then
                m_data.newline = true
            end
            if v == "pph" then
                m_data.newline = true
            end
            if v == "yj" then
                m_data.newline = true
            end
            if v == "quanfeng" then
                m_data.newline = true
            end
            if v == "qidui" then
                m_data.newline = true
            end
             if v == "mgd" then
                m_data.newline = true
            end
             if v == "liuma" then
                m_data.isLink  = true
            end
            table.insert(data.content,m_data)
        end
        index = index + 1
    end

    self.m_wanfaPanel = CommonCheckBoxPanel.new(data)
    table.insert(self.m_itemChildren,self.m_wanfaPanel)
    self.m_wanfaPanel:addTo(self.m_viewWanfaBaseHrl)
    self.m_wanfaPanel:updateSelectBox(function(data,panel) self:updateWanFa(data,panel) end)

    self:updateWanFa(data)
 
end
function GameRoomInfoUI_guangdongyibaizhangmj:updateWanFa(data)
    --无马与马根底分和马跟杠的操作

    local wuma = self.m_wanfaPanel:getCheckBoxPanel("wuma")
    local checkBox = ccui.Helper:seekWidgetByName(wuma,"CheckBox")
    local mgd = self.m_wanfaPanel:getCheckBoxPanel("mgd")
    local mgg = self.m_wanfaPanel:getCheckBoxPanel("mgg")
    if checkBox:isSelected() then
        self.m_wanfaPanel:setPanelGrey(mgd,false)
        self.m_wanfaPanel:setPanelGrey(mgg,false)
        local minggangkq = self.m_wanfaPanel:getCheckBoxPanel("minggangkq")
        self.m_wanfaPanel:setPanelGrey(minggangkq, true)
    else
        self.m_wanfaPanel:setPanelGrey(mgd,true)
        self.m_wanfaPanel:setPanelGrey(mgg,true)
    end
    --颜色操作
    local checkBox = ccui.Helper:seekWidgetByName(mgd,"CheckBox")
    local label = ccui.Helper:seekWidgetByName(mgd,"Label_name")
    if data.chick == "mgd" then
        -- self:updateRenShu()
        if not checkBox:isSelected() then
            label:setColor(G_ROOM_INFO_FORMAT.selectColor)
        end
    else
        if checkBox:isSelected() then
            label:setColor(G_ROOM_INFO_FORMAT.selectColor)
        end
    end

    local checkBox = ccui.Helper:seekWidgetByName(mgg,"CheckBox")
    local label = ccui.Helper:seekWidgetByName(mgg,"Label_name")
    if data.chick == "mgg" then
        if not checkBox:isSelected() then
            label:setColor(G_ROOM_INFO_FORMAT.selectColor)
        end
    else
        if checkBox:isSelected() then
            label:setColor(G_ROOM_INFO_FORMAT.selectColor)
        end
    end
--    -- 马跟底和马跟杠的操作 以及马跟杠和明杠可抢的操作

    if data.chick == "mgg" then
        local mgg = self.m_wanfaPanel:getCheckBoxPanel("mgg")
        local checkBox = ccui.Helper:seekWidgetByName(mgg,"CheckBox")
        local mgd = self.m_wanfaPanel:getCheckBoxPanel("mgd")
        local checkBoxMgd = ccui.Helper:seekWidgetByName(mgd,"CheckBox")
        local minggangkq = self.m_wanfaPanel:getCheckBoxPanel("minggangkq")
        local label = ccui.Helper:seekWidgetByName(mgd,"Label_name")
        if checkBox:isSelected() then
            -- self.m_wanfaPanel:setPanelGrey(mgd,true)
              -- checkBoxMgd:setSelected(true)
            self.m_wanfaPanel:setPanelGrey(minggangkq,true)
        else
            -- self.m_wanfaPanel:setPanelGrey(mgd,false)
              -- checkBoxMgd:setSelected(false)
              -- label:setColor(G_ROOM_INFO_FORMAT.normalColor)
              --cc.c3b(43,76,1)
            self.m_wanfaPanel:setPanelGrey(minggangkq,false)
        end
    end

     if data.chick == "mgd" then
        -- local mgd = self.m_wanfaPanel:getCheckBoxPanel("mgd")
        -- local checkBox = ccui.Helper:seekWidgetByName(mgd,"CheckBox")
        -- local mgg = self.m_wanfaPanel:getCheckBoxPanel("mgg")
        -- local checkBoxMgg = ccui.Helper:seekWidgetByName(mgg,"CheckBox")
        -- local label = ccui.Helper:seekWidgetByName(mgg ,"Label_name")
        -- local minggangkq = self.m_wanfaPanel:getCheckBoxPanel("minggangkq")

        -- if checkBox:isSelected() then
        --     -- self.m_wanfaPanel:setPanelGrey(mgg,true)
        --       -- checkBoxMgg:setSelected(true)
        --     -- self.m_wanfaPanel:setPanelGrey(minggangkq,true)
        -- else
        --     -- self.m_wanfaPanel:setPanelGrey(mgg,false)
        --       -- checkBoxMgg:setSelected(false)
        --       -- label:setColor(G_ROOM_INFO_FORMAT.normalColor)
        --     local keqianggh = self.m_wanfaPanel:getCheckBoxPanel("keqianggh")
        --     local checkBoxkeqianggh = ccui.Helper:seekWidgetByName(keqianggh,"CheckBox")
        --     if checkBoxkeqianggh:isSelected() then
        --         self.m_wanfaPanel:setPanelGrey(minggangkq,true)
        --     end
        -- end
    end
--     --翻鬼或白板做鬼 与 无鬼加倍 和四鬼胡牌的操作的操作
if data.chick == "fg" or data.chick == "bbzg" then
    local fg = self.m_wanfaPanel:getCheckBoxPanel("fg")
    local checkBoxfg = ccui.Helper:seekWidgetByName(fg,"CheckBox")
    local bbzg = self.m_wanfaPanel:getCheckBoxPanel("bbzg")
    local checkBoxbbzg = ccui.Helper:seekWidgetByName(bbzg,"CheckBox")
    local wgjb = self.m_wanfaPanel:getCheckBoxPanel("wgjb")
    local sghp = self.m_wanfaPanel:getCheckBoxPanel("sghp")
    local sghp2b = self.m_wanfaPanel:getCheckBoxPanel("sghp2b")
    local checkBoxsghp2b = ccui.Helper:seekWidgetByName(sghp2b,"CheckBox")
    local labelsghp = ccui.Helper:seekWidgetByName(sghp,"Label_name")
    if checkBoxfg:isSelected() or checkBoxbbzg:isSelected() then
        self.m_wanfaPanel:setPanelGrey(wgjb,true)
        self.m_wanfaPanel:setPanelGrey(sghp,true)
        -- labelsghp:setColor(cc.c3b(38, 204, 38))
    else
        self.m_wanfaPanel:setPanelGrey(wgjb,false)
        self.m_wanfaPanel:setPanelGrey(sghp,false)
        self.m_wanfaPanel:setPanelGrey(sghp2b,false)
    end
end  
    if data.chick == "wg" then
        local wg = self.m_wanfaPanel:getCheckBoxPanel("wg")
        local checkBoxwg = ccui.Helper:seekWidgetByName(wg,"CheckBox")
        local wgjb = self.m_wanfaPanel:getCheckBoxPanel("wgjb")
        local sghp = self.m_wanfaPanel:getCheckBoxPanel("sghp")
         local sghp2b = self.m_wanfaPanel:getCheckBoxPanel("sghp2b")
        if checkBoxwg:isSelected() then
            self.m_wanfaPanel:setPanelGrey(wgjb,false)
            self.m_wanfaPanel:setPanelGrey(sghp,false)
            self.m_wanfaPanel:setPanelGrey(sghp2b,false)
        end
    end

-- local fg = self.m_wanfaPanel:getCheckBoxPanel("fg")
--     local checkBoxfg = ccui.Helper:seekWidgetByName(fg,"CheckBox")
--     local bbzg = self.m_wanfaPanel:getCheckBoxPanel("bbzg")
--     local checkBoxbbzg = ccui.Helper:seekWidgetByName(bbzg,"CheckBox")
--     local wgjb = self.m_wanfaPanel:getCheckBoxPanel("wgjb")
--     local sghp = self.m_wanfaPanel:getCheckBoxPanel("sghp")
--     local sghp2b = self.m_wanfaPanel:getCheckBoxPanel("sghp2b")
--     if checkBoxfg:isSelected() or checkBoxbbzg:isSelected() then
--         self.m_wanfaPanel:setPanelGrey(wgjb,true)
--         self.m_wanfaPanel:setPanelGrey(sghp,true)
--         -- self.m_wanfaPanel:setPanelGrey(sghp2b,true)
--     else
--         self.m_wanfaPanel:setPanelGrey(wgjb,false)
--         self.m_wanfaPanel:setPanelGrey(sghp,false)
--         self.m_wanfaPanel:setPanelGrey(sghp2b,false)
--     end   

-- --可抢杠胡和  抢杠全包，的操作

    if data.chick == "keqianggh" then
        local keqianggh = self.m_wanfaPanel:getCheckBoxPanel("keqianggh")
        local checkBoxkeqianggh = ccui.Helper:seekWidgetByName(keqianggh,"CheckBox")
        local qgqb = self.m_wanfaPanel:getCheckBoxPanel("qgqb")
        local checkBoxqgqb = ccui.Helper:seekWidgetByName(qgqb,"CheckBox")
        local labelQgqb = ccui.Helper:seekWidgetByName(qgqb,"Label_name")
        if checkBoxkeqianggh:isSelected() then
            checkBoxqgqb:setSelected(false)
            labelQgqb:setColor(cc.c3b(67,67,67))
        end
    end

    if data.chick == "qgqb" then
        local keqianggh = self.m_wanfaPanel:getCheckBoxPanel("keqianggh")
        local checkBoxkeqianggh = ccui.Helper:seekWidgetByName(keqianggh,"CheckBox")
        local minggangkq = self.m_wanfaPanel:getCheckBoxPanel("minggangkq")
         local checkBoxMinggangkq = ccui.Helper:seekWidgetByName(minggangkq,"CheckBox")
        local qgqb = self.m_wanfaPanel:getCheckBoxPanel("qgqb")
        local checkBoxqgqb = ccui.Helper:seekWidgetByName(qgqb,"CheckBox")
        local labelKeqianggh = ccui.Helper:seekWidgetByName(keqianggh,"Label_name")
        if not checkBoxqgqb:isSelected() then
            checkBoxkeqianggh:setSelected(true)
            labelKeqianggh:setColor(G_ROOM_INFO_FORMAT.selectColor)

            local mgg = self.m_wanfaPanel:getCheckBoxPanel("mgg")
            local checkBoxMgg = ccui.Helper:seekWidgetByName(mgg,"CheckBox")
            if not checkBoxMgg:isSelected() then
                self.m_wanfaPanel:setPanelGrey(minggangkq,true)
            end
        end
    end

-- 可抢杠胡和明杠可抢
   if data.chick == "keqianggh" then
    --     Log.i("可抢杠胡和2倍")
        local keqianggh = self.m_wanfaPanel:getCheckBoxPanel("keqianggh")
        local checkBoxkeqianggh = ccui.Helper:seekWidgetByName(keqianggh,"CheckBox")
        local minggangkq = self.m_wanfaPanel:getCheckBoxPanel("minggangkq")
        local labelMinggangkq = ccui.Helper:seekWidgetByName(minggangkq,"Label_name")
        local checkBoxMinggangkq = ccui.Helper:seekWidgetByName(minggangkq,"CheckBox")
        local labelKeqianggh = ccui.Helper:seekWidgetByName(keqianggh,"Label_name")
         local mgg = self.m_wanfaPanel:getCheckBoxPanel("mgg")
        local checkBoxMgg = ccui.Helper:seekWidgetByName(mgg,"CheckBox")
        if checkBoxkeqianggh:isSelected()  then
              self.m_wanfaPanel:setPanelGrey(minggangkq,false)

            -- self.m_wanfaPanel:setPanelGrey(sghp,true)
              if  checkBoxMgg:isSelected() then
             
                checkBoxMinggangkq:setSelected(false)
                labelMinggangkq:setColor(cc.c3b(67,67,67))
              end
        else
            -- if  not checkBoxMgg:isSelected() then
                Log.i("jinlaile")

            self.m_wanfaPanel:setPanelGrey(minggangkq,true)
             checkBoxMinggangkq:setSelected(true)
               if  checkBoxMgg:isSelected() then
                    checkBoxMinggangkq:setSelected(false)
                     self.m_wanfaPanel:setPanelGrey(minggangkq,false)

                end
            -- self.m_wanfaPanel:setPanelGrey(sghp,false)
        -- end
        end   
    end



--颜色调整
        local keqianggh = self.m_wanfaPanel:getCheckBoxPanel("keqianggh")
        local checkBoxkeqianggh = ccui.Helper:seekWidgetByName(keqianggh,"CheckBox")
        local minggangkq = self.m_wanfaPanel:getCheckBoxPanel("minggangkq")
        local labelMinggangkq = ccui.Helper:seekWidgetByName(minggangkq,"Label_name")
        local checkBoxMinggangkq = ccui.Helper:seekWidgetByName(minggangkq,"CheckBox")
        local labelKeqianggh = ccui.Helper:seekWidgetByName(keqianggh,"Label_name")
        if checkBoxMinggangkq:isSelected()  then 
                labelMinggangkq:setColor(G_ROOM_INFO_FORMAT.selectColor)
        else
           
        end   
-- 四鬼胡牌与2倍的操作

    if data.chick == "sghp" then
      local sghp = self.m_wanfaPanel:getCheckBoxPanel("sghp")
        local checkBoxsghp = ccui.Helper:seekWidgetByName(sghp,"CheckBox")
        local sghp2b = self.m_wanfaPanel:getCheckBoxPanel("sghp2b")
        local checkBoxsghp2b = ccui.Helper:seekWidgetByName(sghp2b,"CheckBox")
        -- local labelKeqianggh = ccui.Helper:seekWidgetByName(keqianggh,"Label_name")
         local labelsghp = ccui.Helper:seekWidgetByName(sghp,"Label_name")
        -- local labelsghp = ccui.Helper:seekWidgetByName(sghp,"Label_name")
         labelsghp:setColor(G_ROOM_INFO_FORMAT.selectColor)
        if checkBoxsghp:isSelected()  then
            self.m_wanfaPanel:setPanelGrey(sghp2b,false)
               checkBoxsghp2b:setSelected(false)
                labelsghp:setColor(G_ROOM_INFO_FORMAT.normalColor)
          -- labelsghp:setColor(cc.c3b(255,0,0))
            -- self.m_wanfaPanel:setPanelGrey(sghp,true)
        else
              labelsghp:setColor(G_ROOM_INFO_FORMAT.selectColor)
            self.m_wanfaPanel:setPanelGrey(sghp2b,true)
               checkBoxsghp2b:setSelected(true)
            -- self.m_wanfaPanel:setPanelGrey(sghp,false)
        end   
       
    end



        local sghp = self.m_wanfaPanel:getCheckBoxPanel("sghp")
        local checkBoxsghp = ccui.Helper:seekWidgetByName(sghp,"CheckBox")
        local sghp2b = self.m_wanfaPanel:getCheckBoxPanel("sghp2b")
        local checkBoxsghp2b = ccui.Helper:seekWidgetByName(sghp2b,"CheckBox")
        -- local labelKeqianggh = ccui.Helper:seekWidgetByName(keqianggh,"Label_name")
        local labelsghp = ccui.Helper:seekWidgetByName(sghp,"Label_name")
        local labelsghp2b = ccui.Helper:seekWidgetByName(sghp2b,"Label_name")
        -- if checkBoxsghp:isSelected()  then 
        --     labelsghp:setColor(cc.c3b(255,0,0))
        -- else 
        --     labelsghp:setColor(cc.c3b(43,76,1))     
        -- end   
        if checkBoxsghp2b:isSelected()  then 
            labelsghp2b:setColor(G_ROOM_INFO_FORMAT.selectColor)      
        end   
  

-- 幺九六倍和含幺九即可
 -- if data.chick == "keqianggh" and data.chick == "gangbaoqb"
 --    and data.chick ~= "yj" then 
 --        self.m_wanfaPanel:setPanelGrey(hyj,false)
 --    end
    if data.chick == "yj" then
        local yj = self.m_wanfaPanel:getCheckBoxPanel("yj")
        local checkBox = ccui.Helper:seekWidgetByName(yj,"CheckBox")
        local hyj = self.m_wanfaPanel:getCheckBoxPanel("hyj")
        local checkBoxHyj = ccui.Helper:seekWidgetByName(hyj,"CheckBox")
        if  checkBox:isSelected() then
            checkBoxHyj:setSelected(true)
            self.m_wanfaPanel:setPanelGrey(hyj,false)
        else
            self.m_wanfaPanel:setPanelGrey(hyj,true)
              checkBoxHyj:setSelected(true)
        end
    end 
    local keqianggh = self.m_wanfaPanel:getCheckBoxPanel("keqianggh")
    local checkBoxkeqianggh = ccui.Helper:seekWidgetByName(keqianggh,"CheckBox")
    local yj = self.m_wanfaPanel:getCheckBoxPanel("yj")
    local checkBoxYj = ccui.Helper:seekWidgetByName(yj,"CheckBox")
    local hyj = self.m_wanfaPanel:getCheckBoxPanel("hyj")
    local checkBoxHyj = ccui.Helper:seekWidgetByName(hyj,"CheckBox")
    local labelyj = ccui.Helper:seekWidgetByName(yj,"Label_name")
    local labelhyj = ccui.Helper:seekWidgetByName(hyj,"Label_name")
    if data.chick ~= "yj" and not checkBoxHyj:isSelected() and not checkBoxYj:isSelected() then
        Log.i("wawawaw")
        self.m_wanfaPanel:setPanelGrey(hyj,false)   
    end

    if checkBoxHyj:isSelected()  then 
        labelhyj:setColor(G_ROOM_INFO_FORMAT.selectColor)
    else
           
    end   
    
    --选着人房或者是三人房的时候，防止点击点击同一层控件的时候触发着灰变可选
    --  local renshu = self.m_renshuPanel:getPanelData()
    -- local genzhuang = self.m_wanfaPanel:getCheckBoxPanel("gz") 
    -- if renshu == 3 or renshu == 2 then
    --     -- self.m_wanfaPanel:setPanelGrey(genzhuang,false)

    --     local mgd = self.m_wanfaPanel:getCheckBoxPanel("mgd")
    --     local checkBoxmgd = ccui.Helper:seekWidgetByName(mgd,"CheckBox")
    --     local mgg = self.m_wanfaPanel:getCheckBoxPanel("mgg")
    --     local checkBoxMgg = ccui.Helper:seekWidgetByName(mgg,"CheckBox")
    --     local qidui = self.m_wanfaPanel:getCheckBoxPanel("qidui")
    --     local checkBoxQidui = ccui.Helper:seekWidgetByName(qidui,"CheckBox")
    --     if  not checkBoxmgd:isSelected() or  not checkBoxMgg:isSelected() 
    --       or not checkBoxQidui:isSelected()  then
    --         Log.i("gangzhuanggengzjhuagn")
    --         self.m_wanfaPanel:setPanelGrey(genzhuang,false)
    --     elseif  checkBoxmgd:isSelected() or  checkBoxMgg:isSelected() 
    --       or  checkBoxQidui:isSelected()  then
    --         self.m_wanfaPanel:setPanelGrey(genzhuang,false) 
    --     end
    -- else
    --     self.m_wanfaPanel:setPanelGrey(genzhuang,true)
    -- end

    --- 无鬼加倍颜色调整
    if data.chick == "wgjb" then
        local wgjb = self.m_wanfaPanel:getCheckBoxPanel("wgjb")
        local checkBoxwgjb = ccui.Helper:seekWidgetByName(wgjb,"CheckBox")
        local labelwgjb = ccui.Helper:seekWidgetByName(wgjb,"Label_name")
        if checkBoxwgjb:isSelected()  then 
            -- labelwgjb:setColor(cc.c3b(255,0,0))
            labelwgjb:setColor(G_ROOM_INFO_FORMAT.normalColor)
        else
            
             labelwgjb:setColor(G_ROOM_INFO_FORMAT.selectColor)
        end 
    end  
end
function GameRoomInfoUI_guangdongyibaizhangmj:playerNumChange(playerNum)
    if self.m_wanfaPanel then
        self:updateRenShu(playerNum)
    end
end

function GameRoomInfoUI_guangdongyibaizhangmj:updateRenShu(playerNum)
    local renshu = playerNum
  
    local genzhuang = self.m_wanfaPanel:getCheckBoxPanel("gz") 
    
    if renshu == 3 or renshu == 2 then
        genzhuang:setVisible(false)
        checkBox = ccui.Helper:seekWidgetByName(genzhuang,"CheckBox")
        checkBox:setSelected(false)
        local label_name = ccui.Helper:seekWidgetByName(genzhuang,"Label_name")
        label_name:setColor(G_ROOM_INFO_FORMAT.normalColor)
    else
        genzhuang:setVisible(true)
    end

    

end

function GameRoomInfoUI_guangdongyibaizhangmj:getData()
    self.m_setData.gaI = self.m_gameID;
    -- 玩法工厂
    
    -- self:fanmaFactory()
    self:wanfaFactory()
    -- self:jiadiFactory()
    self:saveRoomInfo()
    return self.m_setData;
end

--[[
-- @brief  玩法组装工厂函数
-- @param  void
-- @return void
--]]
function GameRoomInfoUI_guangdongyibaizhangmj:wanfaFactory()
    -- 拼装字符串

    local wanfa = self.m_wanfaPanel:getPanelData()
    local wf = ""
    for i,v in pairs(Util.analyzeString_2(wanfa)) do
        for j,k in pairs(Util.analyzeString_2(v)) do
            wf = wf == "" and k or wf.."|"..k
        end
    end
    self.m_setData.wa = wf
    self.m_setData.gaI = kFriendRoomInfo:getGameID();

    
end


function GameRoomInfoUI_guangdongyibaizhangmj:initRoomInfo()

    local baseItemChildren = self.m_baseItemChildren
    for i,v in pairs(baseItemChildren) do
        if v and type(v) == "userdata" and v.m_radioBtns then
            self._friendRoomDataManager:updateRoomPanel(v,tostring(i))
        end
    end

    local wanfa = self.m_itemChildren
    for i,v in pairs(wanfa) do
        if v and type(v) == "userdata" then
            local panelData =self._friendRoomDataManager:getData(string.format( "wanfa%s",tostring(i)))
            v:updateRoomPanel(panelData)
        end
    end
end

function GameRoomInfoUI_guangdongyibaizhangmj:saveRoomInfo()

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


return GameRoomInfoUI_guangdongyibaizhangmj