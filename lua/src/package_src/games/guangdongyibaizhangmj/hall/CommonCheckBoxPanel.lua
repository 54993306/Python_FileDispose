--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local CommonCheckBoxPanel = class("CommonCheckBoxPanel",function()
    local widget = ccui.Widget:create()
    widget:ignoreContentAdaptWithSize(false)
    widget:setAnchorPoint(cc.p(0.5, 0))
    return widget
end)


--local data = {
--    title = "测试：",
--   content{[1] = {  name        = "拉庄",           -- 每个选项的label名称
--            chick       = "lazhuang",       -- 选项名称(最后会设置为table选项名)
--            multi       = false,            -- 是多选还是单选（单选为互斥，false为单，true为多）
--            itemSelect  = false,            -- 是否是子选项（true为子项）
--            newline     = false,            -- 是否换行  
--            isSelect    = false,            -- 是否默认选择
--            title       = false,            -- 是否是标题（是标题的话则不显示选择的按钮）    
--            isLink      = true,             -- 是否与上一行实现互斥关系
--        },
--    isDrawLine = true,                      --是否绘制横分割(true为绘制)
--    }
--}

local roundPanel = "games/common/game/roundSelectCheckBox.csb"              --单选框路径
local selectPanel = "games/common/game/selectCheckBox.csb"                  --多选框路径
local labelGreyColor = cc.c3b(105,105,105)                                  --label灰色
local normalCheckColor = cc.c3b(255,255,255)                                --checkbox的正常颜色

function CommonCheckBoxPanel:ctor(data)
--    data = wanFadatas
    self:createData(data)
    self:dataManage(data)
    self:createCheckPanel()
    self:drawCheckBox()
end
function CommonCheckBoxPanel:createData(data)
    self.m_itemMinimum  = 2                 --单行最小项数
    self.m_itemBiggest = 3                  --单行最大项数
    self.m_titleText = data.title           -- 单项名称
    self.m_isDrawLine = data.isDrawLine     --是否绘制横向分割线
    self.lineSize = cc.size(G_ROOM_INFO_FORMAT.lineWidth,2) --分割线的大小
    self.m_CommonCheckBoxPanel = {}               -- 保存所有的选择按钮层（分组）
    self.m_checkBoxData = {}                -- 重新保存所有的选择按钮数据（结构修改为按钮层一致可配合按钮数据使用）
    self.m_startCBPanelX = 110              -- checkBox的起始x位置
    self.m_panelHeight = G_ROOM_INFO_FORMAT.lineHeight or 60                 -- 层高度
    self.m_titleStartX = 20                 --title的起始偏移位置
    self.m_panelWidth = G_ROOM_INFO_FORMAT.lineWidth - self.m_startCBPanelX or 720                 -- 层宽度

    self.m_itemTitle = -55                  --子项title的偏移量
    self.m_itemScale = 0.8                  --子项的缩放比例
    self.m_itemOffectY = 10                 --子项的Y偏移量

    self.m_panelOffsetY = 10                 --Y的偏移量

    self.m_titleStartX = G_ROOM_INFO_FORMAT.titlePosX or 20                 --title的起始偏移位置

    self.m_TitleFontColor = G_ROOM_INFO_FORMAT.titleFontColor or cc.c3b(255, 255, 255)  --标题默认颜色
    self.m_TitleFontSize = G_ROOM_INFO_FORMAT.titleFontSize or 28   --标题默认大小

    self.m_itemPanelWidth = 290              -- 子项层宽
    self.m_itemChildWidth = 240             -- 子项离母项的宽度

    self.m_FontName = "hall/font/fangzhengcuyuan.TTF"       -- 文字字体
    self.m_FontColorMoren = G_ROOM_INFO_FORMAT.normalColor or  cc.c3b(255, 255, 255) -- 文字默认颜色
    self.m_selectFontColor = G_ROOM_INFO_FORMAT.selectColor or cc.c3b(38, 204, 38)  -- 选中后的文字颜色
    self.m_textSize = G_ROOM_INFO_FORMAT.fontSize or 28                    --文字大小

     self.m_itemMinimum  = 2                 --单行最小项数
    self.m_itemBiggest = 3                  --单行最大项数
    self.m_titleText = data.title           -- 单项名称
    self.m_isDrawLine = data.isDrawLine     --是否绘制横向分割线
    self.lineSize = cc.size(G_ROOM_INFO_FORMAT.lineWidth,2) --分割线的大小
    self.m_CommonCheckBoxPanel = {}               -- 保存所有的选择按钮层（分组）
    self.m_checkBoxData = {}                -- 重新保存所有的选择按钮数据（结构修改为按钮层一致可配合按钮数据使用）
    self.m_startCBPanelX = 110              -- checkBox的起始x位置
    self.m_panelHeight = G_ROOM_INFO_FORMAT.lineHeight or 60                 -- 层高度
    self.m_titleStartX = 20                 --title的起始偏移位置
    self.m_panelWidth = G_ROOM_INFO_FORMAT.lineWidth - self.m_startCBPanelX or 720                 -- 层宽度

    self.m_itemTitle = -55                  --子项title的偏移量
    self.m_itemScale = 0.8                  --子项的缩放比例
    self.m_itemOffectY = 10                 --子项的Y偏移量

    self.m_panelOffsetY = 10                 --Y的偏移量

    self.m_titleStartX = G_ROOM_INFO_FORMAT.titlePosX or 20                 --title的起始偏移位置

    self.m_TitleFontColor = G_ROOM_INFO_FORMAT.titleFontColor or cc.c3b(255, 255, 255)  --标题默认颜色
    self.m_TitleFontSize = G_ROOM_INFO_FORMAT.titleFontSize or 28   --标题默认大小

    self.m_itemPanelWidth = 190             -- 子项层宽
--    self.m_itemChildWidth = 240             -- 子项离母项的宽度

    self.m_FontName = "hall/font/fangzhengcuyuan.TTF"       -- 文字字体
	self.m_FontColorMoren = G_ROOM_INFO_FORMAT.normalColor or  cc.c3b(255, 255, 255) -- 文字默认颜色
    self.m_selectFontColor = G_ROOM_INFO_FORMAT.selectColor or cc.c3b(38, 204, 38)  -- 选中后的文字颜色
    self.m_textSize = G_ROOM_INFO_FORMAT.fontSize or 28  
end
--处理数据格式
function CommonCheckBoxPanel:dataManage(data)
    for i,v in pairs(data.content) do
        if v.multi == nil then
            v.multi = false
        end
        if v.itemSelect == nil then
            v.itemSelect = false
        end
        if v.newline == nil then
            v.newline = false
        end
        if v.isSelect == nil then
            v.isSelect = false
        end
        if v.title == nil then
            v.title = false
        end
        if v.isLink == nil then
            v.isLink = false
        end
        if not v.itemSelect then
            self:insertData(v)
        else
            self:insertDataItem(v)
        end
    end
end
--插入数据(分析数据是否为子项)
function CommonCheckBoxPanel:insertDataItem(data)
    if data.itemSelect == nil or data.itemSelect == false then
        self:insertData(data)
    else
        local item = self.m_data[#self.m_data]
        if type(self.m_data[#self.m_data][#self.m_data[#self.m_data]].itemSelect) ~= "table" then
            self.m_data[#self.m_data][#self.m_data[#self.m_data]].itemSelect = {}
        end
        table.insert(self.m_data[#self.m_data][#self.m_data[#self.m_data]].itemSelect,data)
    end
end
--插入数据（当数据不为子项时按照跪着插入）
function CommonCheckBoxPanel:insertData(data)
    local dataNum = self.m_itemBiggest
    if self.m_data == nil then
        self.m_data = {}
    end
    if #self.m_data > 0 and #self.m_data[#self.m_data] > 0 then
        for i,v in pairs(self.m_data[#self.m_data]) do
            --如果table里面有标题项则多加一个
            if v.title then
                dataNum = self.m_itemBiggest + 1
            end
        end
    end

    if #self.m_data <= 0 or #self.m_data[#self.m_data] >= dataNum or data.title or data.newline then
        if self.m_data[#self.m_data+1] == nil then
            self.m_data[#self.m_data+1] = {}
        end
    end
    table.insert(self.m_data[#self.m_data],data)
end

--加载两种选择层
function CommonCheckBoxPanel:createCheckPanel()
    local gameId = kFriendRoomInfo:getGameID()
    local gameType = GC_GameTypes[gameId]
    self.roundSelectPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/roundSelectCheckBox.csb")
    self.roundSelectPanel:setVisible(false)
    local label_name = ccui.Helper:seekWidgetByName(self.roundSelectPanel,"Label_name")
    label_name:setColor(self.m_FontColorMoren)
    label_name:setFontName(self.m_FontName)
    label_name:setFontSize(self.m_textSize)
    label_name:setPosition(cc.p(label_name:getPositionX()-1,label_name:getPositionY()))

    self.selectPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/selectCheckBox.csb")
    self.selectPanel:setVisible(false)
    local label_name = ccui.Helper:seekWidgetByName(self.selectPanel,"Label_name")
    label_name:setColor(self.m_FontColorMoren)
    label_name:setFontName(self.m_FontName)
    label_name:setFontSize(self.m_textSize)
    label_name:setPosition(cc.p(label_name:getPositionX()-1,label_name:getPositionY()))

    self:setContentSize(cc.size(0,#self.m_data*self.m_panelHeight))
end
function CommonCheckBoxPanel:setPanelContentSize(width,height)
    self:setContentSize(cc.size(width,height))
end
--绘制选项
function CommonCheckBoxPanel:drawCheckBox()
    local isItem = false
    local panelItemNum = 0
    local isLinkPanel = 0
    local isHuan = false
    local isItemHuan = false
    for i,v in pairs(self.m_data) do
        local title = false
        isLink = false
        isHuan = true
        isItemHuan = true
        isItemNewline = false
        for j,k in pairs(v) do
            local num = #v
            if k.isLink or not isHuan then
                num = #self.m_data[i-1]
                if self.m_data[i-1][1].title then
                    num = num - 1
                end
            end
            if k.title then
                title = true
            end
            local itemNum = panelItemNum
            if isItemNewline then
                itemNum = panelItemNum - 1
            end
            local posX,posY = self:drawSingle(j,i+itemNum,num,title,k)
            local panel = self:drawSelectPanel(posX,posY,k)
            local itemPanel = nil
            local isLine = false
            if type(k.itemSelect) == "table" then
                isLine,itemPanel = self:drawItemPanel(posX,posY,k.itemSelect)
                if isLine and not isItemNewline then
                    panelItemNum = panelItemNum+1
                    isItemNewline = true
                end
            end
            if k.isLink or not isHuan then
                isLink = true
                isHuan = false
            end
            self:saveCommonCheckBoxPanelData(k,panel,itemPanel,isItemHuan,isLink)
            isItemHuan = false
        end
    end
    self:updatePanelPos(panelItemNum)
    self:drawTitle()
    self:drawLine()
    self:checkBoxSelect()

end
--保存已经绘制好的item数据
function CommonCheckBoxPanel:saveCommonCheckBoxPanelData(data,panel,itemPanel,isItemHuan,isLink)
    if self.m_checkBoxData == nil then
        self.m_checkBoxData = {}
    end
    if self.m_CommonCheckBoxPanel == nil then
        self.m_CommonCheckBoxPanel = {}
    end
   
    if isItemHuan and not isLink then
        if self.m_checkBoxData[#self.m_checkBoxData + 1] == nil then
            self.m_checkBoxData[#self.m_checkBoxData + 1] = {}
        end
         if self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel + 1] == nil then
            self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel + 1] = {}
        end
        if self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].panel == nil then
            self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].panel = {}
        end
        if self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].itemSelect == nil then
            self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].itemSelect = {}
        end
        if self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].data == nil then
            self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].data = {}
        end
    end

    table.insert(self.m_checkBoxData[#self.m_checkBoxData],data)
    table.insert(self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].panel,panel)
    table.insert(self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].data,data)
    if itemPanel~= nil then
        if self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].itemSelect[#self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].panel] == nil then
            self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].itemSelect[#self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].panel] = {}
        end
        self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].itemSelect[#self.m_CommonCheckBoxPanel[#self.m_CommonCheckBoxPanel].panel] = itemPanel

    end
end
--绘制选项的层级
function CommonCheckBoxPanel:drawSingle(x,y,num,title,data)
    if num < self.m_itemMinimum then
        num = self.m_itemMinimum
    end
    if title and num > self.m_itemMinimum then
        num = num - 1
    end
    local width = self.m_panelWidth/num
    local posX = self.m_startCBPanelX + (x-1)*width
    if title then
        posX = posX - self.m_panelWidth
        if x > 1 then
            posX = posX - (width - self.m_panelWidth)
        end
    end
    local posY = ((#self.m_data)*self.m_panelHeight)-(y)*self.m_panelHeight + self.m_panelOffsetY
    
    return posX,posY
end
function CommonCheckBoxPanel:drawSelectPanel(posX,posY,data,isItem)
    local panel = nil
    if data.multi then
        panel = self.selectPanel:clone()
    else
        panel = self.roundSelectPanel:clone()
    end
    panel:setVisible(true)
    panel:setSwallowTouches(false)
    local label_name = ccui.Helper:seekWidgetByName(panel,"Label_name")
    local name = data.name
    if data.title then
        name = name ..":"
    end
    label_name:setString(name)
    local checkBox = ccui.Helper:seekWidgetByName(panel,"CheckBox")
    if data.isSelect then
        checkBox:setSelected(true)
        label_name:setColor(self.m_selectFontColor)
        if data.multi then
            checkBox:setTouchEnabled(true)
        else
            checkBox:setTouchEnabled(false)
        end
    else
        checkBox:setSelected(false)
        label_name:setColor(self.m_FontColorMoren)
        checkBox:setTouchEnabled(true)
    end
    if data.title then
        checkBox:setVisible(false)
        panel:setPosition(cc.p(self.m_itemTitle + self.m_titleStartX,posY))
        label_name:setFontSize(self.m_TitleFontSize)
        label_name:setColor(self.m_TitleFontColor)
    elseif not isItem then
        panel:setPosition(cc.p(posX,posY))
    else
        panel:setScale(self.m_itemScale)
        panel:setPosition(cc.p(posX,posY))
        checkBox:setPositionY(checkBox:getPositionY() + self.m_itemOffectY)
        label_name:setPositionY(label_name:getPositionY() + self.m_itemOffectY)
    end
    panel:addTo(self)
    return panel
end
--当为子选项时绘制
function CommonCheckBoxPanel:drawItemPanel(x,y,data)
    local isLine = false
    local itemPanel = {}
    for i,v in pairs(data) do
        local posX = 0
        local posY = 0
        if v.newline then
            isLine = true
        end
        if isLine then
            local num = #data
            if #data < self.m_itemMinimum then
                num = self.m_itemMinimum
            end
            local width = self.m_panelWidth/num
            posX = self.m_startCBPanelX + (i-1)*width
            posY = y - self.m_panelHeight
        else
            posX = x + i*self.m_itemPanelWidth
            posY = y
        end
        local panel = self:drawSelectPanel(posX,posY,v,not isLine)
        table.insert(itemPanel,panel)
        if not isLine and #data >= 2 then
            self:drawItemArea(posX,posY,i,panel)
        end
    end
    return isLine,itemPanel
end
function CommonCheckBoxPanel:drawItemArea(posX,posY,index,panel)
    local title = display.newTTFLabel({
                                    text = "(",
                                    font = self.m_FontName,
                                    size = self.m_textSize,
                                    color = self.m_FontColorMoren,
                                    align = cc.TEXT_ALIGNMENT_LEFT,
                                    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                                })
    if index == 1 then
        title:setPosition(cc.p(0,self.m_textSize+self.m_itemOffectY))
    else
        title:setString(")")
        local label = ccui.Helper:seekWidgetByName(panel,"Label_name")
        labelSize = label:getContentSize()
        title:setPosition(cc.p(labelSize.width + 65,self.m_textSize+self.m_itemOffectY))
    end
    title:addTo(panel)
end
--如有换行子项时整体向上移动子项个高度
function CommonCheckBoxPanel:updatePanelPos(itemPanelNum)
    local childs = self:getChildren()
    if itemPanelNum <= 0 then
        return
    end
    for i,v in pairs(childs) do
        v:setPositionY(v:getPositionY()+itemPanelNum*self.m_panelHeight + self.m_panelOffsetY)
    end
end

function CommonCheckBoxPanel:drawTitle()
    self.title = display.newTTFLabel({
                                    text = "",
                                    font = self.m_FontName,
                                    size = self.m_TitleFontSize,
                                    color = self.m_TitleFontColor,
                                    align = cc.TEXT_ALIGNMENT_LEFT,
                                    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                                })
    if self.m_titleText == nil then
        self.m_titleText = ""
    end
    self.title:setString(self.m_titleText)
    local titleSize = self.title:getContentSize()
    local cbPSize = self.roundSelectPanel:getContentSize()
    self.title:setPosition(cc.p(titleSize.width/2+self.m_titleStartX,(#self.m_data)*self.m_panelHeight-titleSize.height + self.m_panelOffsetY/2))
    self.title:addTo(self)
end
function CommonCheckBoxPanel:checkBoxSelect()
    for i,v in pairs(self.m_CommonCheckBoxPanel) do
        for j ,k in pairs(v.panel) do
            local checkBox = ccui.Helper:seekWidgetByName(k,"CheckBox")
            checkBox:setSwallowTouches(false)

            checkBox.moving = false
            checkBox:addTouchEventListener(function(obj, event)
                local selected = ccui.CheckBoxEventType.selected
                if v.data[j].multi then
                    selected =ccui.TouchEventType.ended
                end
                if event == selected then
                    if not obj.moving then
                        self:setCheckBoxSelect(v.panel,j,i,v)
                        if self.updateBoxFunc then
                            self.updateBoxFunc(v.data[j],v.panel)
                        end 


                    end

                    obj.moving = false
                elseif event == ccui.CheckBoxEventType.unselected or event == ccui.TouchEventType.moved then
                    obj.moving = false
                elseif event == ccui.TouchEventType.canceled then
                    obj.moving = false
                end
            end)
            if v.itemSelect[j] ~= nil then
                for m ,n in pairs(v.itemSelect[j]) do
                    local checkBox = ccui.Helper:seekWidgetByName(n,"CheckBox")
                    checkBox:setSwallowTouches(false)

                    checkBox.moving = false
                    checkBox:addTouchEventListener(function(obj, event)
                        local selected = ccui.CheckBoxEventType.selected
                        if v.data[j].itemSelect[m].multi then
                            selected =ccui.TouchEventType.ended
                        end

                        if event == selected then
                            if not obj.moving then
                                self:setItemCheckBoxSelect(v.itemSelect[j],m,v.data[j])
                                if self.updateBoxFunc then
                                    self.updateBoxFunc(v.data[j].itemSelect[m],v.itemSelect[j][m])
                                end


                            end
                            --obj:setSelected(not obj:isSelected())
                            obj.moving = false
                        elseif event == ccui.TouchEventType.canceled then
                            obj.moving = false
                        elseif event == ccui.TouchEventType.moved or event == ccui.CheckBoxEventType.unselected  then
                            obj.moving = false
                        end
                    end)
                end
            end
        end
        
    end
end
function CommonCheckBoxPanel:drawLine()
    if not self.m_isDrawLine then
        return
    end
    local line = display.newScale9Sprite("hall/Common/line2.png",G_ROOM_INFO_FORMAT.lineWidth/2,0,self.lineSize)
    line:addTo(self)
end
function CommonCheckBoxPanel:updateSelectBox(func)
    self.updateBoxFunc = func
end
function CommonCheckBoxPanel:setCheckBoxSelect(group,index,pIndex,table)
    local CommonCheckBoxPanel = ccui.Helper:seekWidgetByName(group[index],"CheckBox")
    for i,v in pairs(group) do
        local item = table.data[index]
        local checkBox = ccui.Helper:seekWidgetByName(v,"CheckBox")
        checkBox:setSwallowTouches(false)
        local label_name = ccui.Helper:seekWidgetByName(v,"Label_name")
        if item.multi then
            if i ~= index then
                if checkBox:isSelected() then
                    if not table.data or not table.data[i] or not table.data[i].title then
                        label_name:setColor(self.m_selectFontColor)
                    end
                else
                    if not table.data or not table.data[i] or not table.data[i].title then
                        label_name:setColor(self.m_FontColorMoren)
                    end
                end
            else
                if not CommonCheckBoxPanel:isSelected() then
                    if not table.data or not table.data[i] or not table.data[i].title then
                        label_name:setColor(self.m_selectFontColor)
                    end
                else
                    if not table.data or not table.data[i] or not table.data[i].title then
                        label_name:setColor(self.m_FontColorMoren)
                    end
                end
            end
            checkBox:setTouchEnabled(true)
            self:setCbSelectItemPanel(table.itemSelect[index],index,i,checkBox)
        else
            if i == index then
                checkBox:setSelected(true)
                if not table.data or not table.data[i] or not table.data[i].title then
                    label_name:setColor(self.m_selectFontColor)
                end
                checkBox:setTouchEnabled(false)
            else
                checkBox:setSelected(false)
                if not table.data or not table.data[i] or not table.data[i].title then
                    label_name:setColor(self.m_FontColorMoren)
                end
                checkBox:setTouchEnabled(true)
            end
           self:setCbItemPanel(table,index,i,checkBox)
        end
    end
end
function CommonCheckBoxPanel:setCbSelectItemPanel(table,index,pIndex,cbPanel,items)
    if table == nil or index ~= pIndex then
        return
    end
    local isSelect = cbPanel:isSelected()
    if items ~= nil then
        isSelect = not isSelect
    end
    if isSelect then
        for i,v in pairs(table) do
            local checkBox = ccui.Helper:seekWidgetByName(v,"CheckBox")
            local label_name = ccui.Helper:seekWidgetByName(v,"Label_name")
            checkBox:setSelected(false)
            label_name:setColor(self.m_FontColorMoren)
            checkBox:setTouchEnabled(false)
        end
    else
        for i,v in pairs(table) do
            local checkBox = ccui.Helper:seekWidgetByName(v,"CheckBox")
            checkBox:setSwallowTouches(false)
            local label_name = ccui.Helper:seekWidgetByName(v,"Label_name")
            if i == 1 then
                checkBox:setSelected(true)
                label_name:setColor(self.m_selectFontColor)
                checkBox:setTouchEnabled(false)
            else
                checkBox:setSelected(false)
                label_name:setColor(self.m_FontColorMoren)
                checkBox:setTouchEnabled(true)
            end
        end
    end
end
function CommonCheckBoxPanel:setCbItemPanel(data,index,pIndex,cbPanel)
    if #data.itemSelect > 0 and data.itemSelect[pIndex] ~= nil then
        if pIndex == index then
            for i,v in pairs(data.itemSelect[index]) do
                v:setVisible(true)
            end
            self:setCbSelectItemPanel(data.itemSelect[pIndex],index,pIndex,cbPanel,true)
        else
            for i,v in pairs(data.itemSelect[pIndex]) do
                v:setVisible(false)
                local checkBox = ccui.Helper:seekWidgetByName(v,"CheckBox")
                local label_name = ccui.Helper:seekWidgetByName(v,"Label_name")
                checkBox:setSelected(false)
                label_name:setColor(self.m_FontColorMoren)
                checkBox:setTouchEnabled(false)
            end
        end
            
    end
end
function CommonCheckBoxPanel:setItemCheckBoxSelect(group,index,table)
    local CommonCheckBoxPanel = ccui.Helper:seekWidgetByName(group[index],"CheckBox")
    for i,v in pairs(group) do
        local checkBox = ccui.Helper:seekWidgetByName(v,"CheckBox")
        checkBox:setSwallowTouches(false)
        local label_name = ccui.Helper:seekWidgetByName(v,"Label_name")
        if #group > 1 and not table.itemSelect[1].multi then
            if i == index then
                checkBox:setSelected(true)
                if not table.data or not table.data[i] or not table.data[i].title then
                    label_name:setColor(self.m_selectFontColor)
                end
                checkBox:setTouchEnabled(false)
            else
                checkBox:setSelected(false)
                if not table.data or not table.data[i] or not table.data[i].title then
                    label_name:setColor(self.m_FontColorMoren)
                end
                checkBox:setTouchEnabled(true)
            end
        else
            if not checkBox:isSelected() then
                if not table.data or not table.data[i] or not table.data[i].title then
                    label_name:setColor(self.m_selectFontColor)
                end
                checkBox:setTouchEnabled(true)
            else
                if not table.data or not table.data[i] or not table.data[i].title then
                    label_name:setColor(self.m_FontColorMoren)
                end
                checkBox:setTouchEnabled(true)
            end
        end
    end
end
--获取规则数据
function CommonCheckBoxPanel:getPanelData()
    local wanfa = ""
    for i,v in pairs(self.m_CommonCheckBoxPanel) do
        for j,k in pairs(v.panel) do
            local checkBox = ccui.Helper:seekWidgetByName(k,"CheckBox")
            if checkBox:isSelected() then
                if wanfa == nil or wanfa == "" then
                    wanfa  = v.data[j].chick
                else
                    wanfa = wanfa.."|"..v.data[j].chick
                end
                if v.itemSelect[j] ~= nil and v.itemSelect[j][1] ~= nil then
                    --防止单选项的索引跟规则数据索引不一致问题
                    local itemSelect = v.itemSelect[j][1]
                    for m,n in pairs(v.itemSelect[j]) do
                        itemSelect = n
                        local checkBox = ccui.Helper:seekWidgetByName(itemSelect,"CheckBox")
                        if checkBox:isSelected() then
                            wanfa = wanfa.."|"..v.data[j].itemSelect[m].chick
                        end
                    end
                    break
                end
            end
        end
    end
    return wanfa
end
function CommonCheckBoxPanel:getCheckBoxPanel(name)
    local panel = nil 
    for i,v in pairs(self.m_CommonCheckBoxPanel) do
        for j,k in pairs(v.data) do
            if k.chick == name then
                panel = v.panel[j]
            end
            if type(k.itemSelect) == "table" then
                for m,n in pairs(k.itemSelect) do
                    if n.chick == name then
                        panel = v.itemSelect[j][m]
                    end
                end
            end
        end
    end
    return panel
end
function CommonCheckBoxPanel:getAllPanel()
    local panels = {}
    for i,v in pairs(self.m_CommonCheckBoxPanel) do
        -- if v.data == nil or #v.data<=0 then 
            for j,k in pairs(v.data) do
                v.panel[j].title = k.title
                v.panel[j].name = k.name
            end

            table.insert(panels,v.panel)
            for j,k in pairs(v.data) do
                if type(k.itemSelect) == "table" then
                    for m,n in pairs(k.itemSelect) do
                        local xiangtong = false
                        for a, b in pairs(panels[#panels]) do
                            if n.name == b.name then
                                xiangtong = true
                            end

                        end
                        if not xiangtong then
                            v.itemSelect[j][m].title = n.title
                            v.itemSelect[j][m].name = n.name
                            table.insert(panels[i],v.itemSelect[j][m])
                        end
                    end
                end
            -- end
        end
    end
    return panels
end

function CommonCheckBoxPanel:setPanelGrey(panel,state,isSelect)
    local checkBox = ccui.Helper:seekWidgetByName(panel,"CheckBox")
    local label_name = ccui.Helper:seekWidgetByName(panel,"Label_name")
    if state == nil then
        state = false
    end
    if isSelect == nil then
        isSelect = false
    end
    if state == false then
        checkBox:setSelected(false)
        checkBox:setTouchEnabled(false)
        Util.setGrey(checkBox:getVirtualRenderer(),1)
        label_name:setColor(labelGreyColor)
        --防止一些按变灰失效问题
        checkBox:setColor(labelGreyColor)
        panel.grey = true
    else
        checkBox:setTouchEnabled(true)
        checkBox:setSwallowTouches(false)
        Util.setGrey(checkBox:getVirtualRenderer(),2)
        label_name:setColor(self.m_FontColorMoren)
        checkBox:setColor(normalCheckColor)
        panel.grey = false
        if isSelect then
            checkBox:setSelected(true)
            label_name:setColor(self.m_selectFontColor)
        end
    end
end

--恢复记录选择
function CommonCheckBoxPanel:getSavePanelAllData()
    local panels = self:getAllPanel()
    local panelData = {}
    for i, panel in pairs(panels) do
        for j,k in pairs(panel) do
            -- if not k.title  then
                Log.i("title....",k.title)
                local data = {}
                local checkBox = ccui.Helper:seekWidgetByName(k,"CheckBox")
                data._select = checkBox:isSelected()
                data._enabled = checkBox:isTouchEnabled()
                data._visible = k:isVisible()
                data._posX = k:getPositionX()
                data._posY = k:getPositionY()
                -- if k.grey ~= nil then
                    data._grey = k.grey
                -- end
                -- data.panel = k
                data.title = k.title
                data.name = k.name
                table.insert(panelData,data)
            -- end
        end
    end
    return panelData
end

--刷新牌局选项
function CommonCheckBoxPanel:updateRoomPanel(panelData)
    if not panelData or #panelData <= 0 then
        return
    end
    local panels = {}
    for i , panel in pairs(self:getAllPanel()) do
        for j,k in pairs(panel) do
            if j <= 1 or (j > 1 and k.name ~= panel[j-1].name) then
                table.insert(panels,k)
            end
        end
    end
    for i,data in ipairs(panelData) do
        if i > #panels then
            break
        end
        if not panels[i].title then
            local checkBox = ccui.Helper:seekWidgetByName(panels[i],"CheckBox")
            local label_name = ccui.Helper:seekWidgetByName(panels[i],"Label_name")
            if data._select then
                label_name:setColor(self.m_selectFontColor)
            else
                label_name:setColor(self.m_FontColorMoren)
            end
            checkBox:setSelected(data._select)
            checkBox:setTouchEnabled(data._enabled)
            panels[i]:setVisible(data._visible)
            panels[i]:setPosition(cc.p(data._posX,data._posY))
            if data._grey ~= nil then
                self:setPanelGrey(panels[i],not data._grey,data._select)
            end
        end

        
    end
end

return CommonCheckBoxPanel


--endregion
