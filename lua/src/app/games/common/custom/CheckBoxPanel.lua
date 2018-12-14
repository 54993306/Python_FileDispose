--
-- Author: RuiHao Lin
-- Date: 2017-05-15 09:59:09
--


--  字体路径
local lFontFilePath = "hall/font/fangzhengcuyuan.TTF"
--  复选框模板
local lCSBFilePath = "games/common/game/checkbox_panel.csb"
--  分割线路径
local lLineFilePath = "hall/Common/line2.png"

-- @brief   CheckBoxPanel   创建“房间界面”定制版【复选选项块】
local CheckBoxPanel = class("CheckBoxPanel", function()
    local ret = ccui.Layout:create()
    ret:setSwallowTouches(false)
    return ret
end )

--[[
    --  data结构
    data =
    {
        --  标题，不传该参数则默认为不创建该文本
        title = "玩法:",

        --  选项
        options =
        {
            --  选项1
            {
                --  文本
                text = "七对加番",

                --  复选框默认是否选中，不传则作false处理
                isSelected = true,
                --  单项是否显示，不传则作true处理
                Visible = false,
            },
            --  选项2
            {
                --  文本
                text = "十三不靠加番",

                --  复选框默认是否选中，不传则作false处理
                isSelected = false
            }
        },

        --  可配置属性，详见 CheckBoxPanel:initConfigList()
        Config =
        {
            --  @brief  分割线的可见性；不传该参数则作false处理；
            --  @Exclusive  true：显示分割线；  false：隐藏分割线；
            LineVisible = true,        

            --  @brief  子项间是否互斥；不传该参数则作false处理；
            --  @Exclusive  true：子项间互斥；  false：子项间不互斥；
            Exclusive = true,

            --  @brief  初始化时默认选项是否产生响应事件；不传该参数则作true处理；
            --  @ResponseEvent  true：产生响应事件；  false：不产生响应事件；
            ResponseEvent = false,


            --  @brief  单排选项面板尺寸
            OptionPanelSize = cc.size(1020, 60),
        }
    }
]]
function CheckBoxPanel:ctor(data, callback)
    self.m_data = data
    self.m_callback = callback
    self:init()
end

--  初始化
function CheckBoxPanel:init()
    self:initData()
    self:initUI()
end

--  初始化数据
function CheckBoxPanel:initData()
    --  初始化可配置属性
    self:initConfigList()

    --  单个控件位置偏移量
    self.m_posOffset = cc.p(0, self.m_OptionPanelSize.height * 0.5)

    --  当前面板尺寸的高
    self.m_CurrHeight = self.m_OptionPanelSize.height

    --  选项面板列表
    self.m_OptionPanelList = {}

    --  复选框列表
    self.m_CheckBoxList = {}

    --  文本列表
    self.m_LabelList = {}

    --  复选框选择结果列表
    self.m_SelectedList = {}

    --  互斥时，当前选中的复选框
    self.m_CurrCheckBox = nil
end

--  初始化可配置属性
function CheckBoxPanel:initConfigList()
    --  可配置属性列表
    self.m_ConfigList = self.m_data.Config or {}

    --  分割线可见性
    self.m_ConfigList.LineVisible = self.m_ConfigList.LineVisible or false

    --  子项间是否互斥
    self.m_ConfigList.Exclusive = self.m_ConfigList.Exclusive or false

    --  子项间是否（通常+互斥）
    self.m_ConfigList.NormalAndExclusive = self.m_ConfigList.NormalAndExclusive or false

    --  初始化时默认选项是否产生响应事件
    self.m_ConfigList.ResponseEvent = self.m_ConfigList.ResponseEvent == nil or self.m_ConfigList.ResponseEvent

    --	默认最大列数
    if IsPortrait then -- TODO
        self.m_ConfigList.MaxCol = self.m_ConfigList.MaxCol or G_ROOM_INFO_FORMAT.groupColMax
    else
        self.m_ConfigList.MaxCol = self.m_ConfigList.MaxCol or 3
    end

    --  文本正常颜色
    self.m_ConfigList.LabNormalColor = self.m_ConfigList.LabNormalColor or G_ROOM_INFO_FORMAT.normalColor

    --  文本选中颜色
    self.m_ConfigList.LabSelectedColor = self.m_ConfigList.LabSelectedColor or G_ROOM_INFO_FORMAT.selectColor

    --  文本字体尺寸
    self.m_ConfigList.LabFontSize = self.m_ConfigList.LabFontSize or G_ROOM_INFO_FORMAT.fontSize
    
    --  单排选项面板尺寸
    self.m_OptionPanelSize = self.m_ConfigList.OptionPanelSize or cc.size(G_ROOM_INFO_FORMAT.lineWidth, G_ROOM_INFO_FORMAT.lineHeight)
end

--  初始化UI界面
function CheckBoxPanel:initUI()
    --  布局节点，所有控件的父节点，用于调整整体位置
    self.m_layoutNode = display.newNode()
    self:addChild(self.m_layoutNode)

    if not IsPortrait then -- TODO
        self:initLine()
    end
    self:initTitle()
    self:initOptions()
    self:composition()
    self:dealResponseEvent(self.m_ConfigList.ResponseEvent)
end

--  初始化标题
function CheckBoxPanel:initTitle()
    local hasTitle = self.m_data.title or false
    if not hasTitle then
        --  空则不创建标题
        return
    end
    --  标题
    local title = display.newTTFLabel( {
        text = self.m_data.title,
        font = lFontFilePath,
        size = self.m_ConfigList.LabFontSize,
        color = self.m_ConfigList.LabNormalColor,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    } )
    if IsPortrait then -- TODO
        title.size = G_ROOM_INFO_FORMAT.titleFontSize
        title.color = G_ROOM_INFO_FORMAT.titleFontColor
    end
    self.m_layoutNode:addChild(title)
    title:setAnchorPoint(cc.p(0, 0.5))
    title:setPosition(cc.p(G_ROOM_INFO_FORMAT.titlePosX, 0 + 30--[[self.m_posOffset.y]]))
end

--  初始化选项
function CheckBoxPanel:initOptions()
    local lCheckBoxPanel = CSBManager.getInstance():getCSBFile(lCSBFilePath)--ccs.GUIReader:getInstance():widgetFromBinaryFile(lCSBFilePath)

    for i, v in pairs(self.m_data.options) do
        --  选项面板
        self.m_OptionPanelList[i] = lCheckBoxPanel:clone()
        self.m_OptionPanelList[i]:setSwallowTouches(false)
        self.m_layoutNode:addChild(self.m_OptionPanelList[i])

        --  复选框
        self.m_CheckBoxList[i] = ccui.Helper:seekWidgetByName(self.m_OptionPanelList[i], "CheckBox")
        self.m_CheckBoxList[i]:setTag(i)
        self.m_CheckBoxList[i]:setSwallowTouches(false)
        self.m_CheckBoxList[i]:addEventListener(handler(self, self.onCheckBoxEvent))

        --  文本
        self.m_LabelList[i] = ccui.Helper:seekWidgetByName(self.m_OptionPanelList[i], "Label")
        self.m_LabelList[i]:setTag(i)
        self.m_LabelList[i]:setString(v.text)
        self.m_LabelList[i]:setFontSize(self.m_ConfigList.LabFontSize)
        self.m_LabelList[i]:setFontName(lFontFilePath)
        if IsPortrait then -- TODO
            self.m_LabelList[i]:setPosition(cc.p(56,14))
        else
            self.m_LabelList[i]:setPosition(cc.p(G_ROOM_INFO_FORMAT.itemTextOffsetX,G_ROOM_INFO_FORMAT.itemTextOffsetY))
        end

        --  初始化状态表现
        local lIsSelected = v.isSelected or false
        local lVisible = v.Visible == nil and true or v.Visible        
        if lIsSelected and self.m_ConfigList.Exclusive then
            self.m_CurrCheckBox = self.m_CheckBoxList[i]
        end

        self.m_OptionPanelList[i]:setVisible(lVisible)
        self.m_SelectedList[i] = lIsSelected
        self.m_CheckBoxList[i]:setSelected(self.m_SelectedList[i])
        self:updateCheckBoxState(self.m_CheckBoxList[i], self.m_SelectedList[i])
    end
end

--[[
    @biref  排版
--]]
function CheckBoxPanel:composition()
    --  行
    local row = 0
    --  列
    local col = 0
    --  最大列数
    local lMaxCol = self.m_ConfigList.MaxCol
	--	首位置比例
    local firstPosRatio = G_ROOM_INFO_FORMAT.firstPosX / self.m_OptionPanelSize.width
	--	排版比例
    local ratio = G_ROOM_INFO_FORMAT.radioItemOffset / self.m_OptionPanelSize.width --(1 - firstPosRatio) / lMaxCol
    --  选项位置
    local pos = cc.p(self.m_OptionPanelSize.width, - self.m_OptionPanelSize.height * 0.5 + self.m_posOffset.y)
    --  重置当前高度
    self.m_CurrHeight = self.m_OptionPanelSize.height
    local offsetX = 0
    local offsetY = 1
	for i, v in pairs(self.m_OptionPanelList) do
        if v:isVisible() then
            if col >= lMaxCol then
                col = 0
                row = row + 1
                self.m_CurrHeight = self.m_CurrHeight + self.m_OptionPanelSize.height
            end
            col = col + 1
		    --	排版公式
            local formula = firstPosRatio + ratio * (col - 1)
            v:setPosition(pos.x * formula + offsetX, pos.y - row * self.m_OptionPanelSize.height + offsetY)        
        end
	end

    --  所有控件创建完成后，确定最终面板尺寸
    self:setContentSize(self.m_OptionPanelSize.width, self.m_CurrHeight)
    --  最终位置整体往上偏移
    self.m_layoutNode:setPosition(cc.p(0, self:getContentSize().height - self.m_OptionPanelSize.height))
end

--  初始化分割线
function CheckBoxPanel:initLine()
    --  分割线位置
    local kLinePosX = self.m_OptionPanelSize.width / 2
    local kLinePosY = 1

    --  分割线尺寸
    local kLineSize = cc.size(self.m_OptionPanelSize.width, 2)

    --  分割线
    self.m_line = display.newScale9Sprite(lLineFilePath, kLinePosX, kLinePosY, kLineSize)
    self:addChild(self.m_line)

    self:setLineVisible(self.m_ConfigList.LineVisible)
end

--  设置分割线的可见性
function CheckBoxPanel:setLineVisible(isVisible)
    self.m_line:setVisible(isVisible)
    self.m_ConfigList.LineVisible = isVisible
end

--[[
    @brief  处理默认选项响应事件
    @isResponse 是否响应事件，不传参则作true处理
--]]
function CheckBoxPanel:dealResponseEvent(isResponse)
    isResponse = isResponse == nil or isResponse
    if not isResponse then
        return
    end

    for i, v in pairs(self.m_CheckBoxList) do
        local lSelected = self.m_SelectedList[i]
        if lSelected then
            self:onCheckBoxEvent(v, ccui.CheckBoxEventType.selected)
        else
            self:onCheckBoxEvent(v, ccui.CheckBoxEventType.unselected)
        end
    end
end

--  复选框回调事件
function CheckBoxPanel:onCheckBoxEvent(obj, event)
    if self.m_ConfigList.Exclusive then
        self:onCBExclusiveEvent(obj, event)
    elseif self.m_ConfigList.NormalAndExclusive then
        self:onCBNormalAndExclusiveEvent(obj, event)
    else
        self:onCBNormalEvent(obj, event)
    end
end

--  复选框通常情况事件
function CheckBoxPanel:onCBNormalEvent(obj, event)
    local tag = obj:getTag()
    if event == ccui.CheckBoxEventType.selected then
        self:updateCheckBoxState(obj, true)
        if self.m_callback then
            self.m_callback(tag, true)
        end
    elseif event == ccui.CheckBoxEventType.unselected then
        self:updateCheckBoxState(obj, false)
        if self.m_callback then
            self.m_callback(tag, false)
        end
    end
end

--  复选框互斥情况事件
function CheckBoxPanel:onCBExclusiveEvent(obj, event)
    if event == ccui.CheckBoxEventType.selected then
        self.m_CurrCheckBox = obj
        self:dealExclusiveEvents()
    elseif event == ccui.CheckBoxEventType.unselected then
        self:dealExclusiveEvents()
    end
end

--  复选框通常+互斥情况事件
function CheckBoxPanel:onCBNormalAndExclusiveEvent(obj, event)
    if event == ccui.CheckBoxEventType.selected then
        self.m_CurrCheckBox = obj
        self:dealExclusiveEvents()
    elseif event == ccui.CheckBoxEventType.unselected then
        if self.m_CurrCheckBox == obj then
            self.m_CurrCheckBox = nil
            if self.m_callback then
                self.m_callback(obj:getTag(), false)
            end
        end
        self:dealExclusiveEvents()
    end
end

--  更新复选框的表现状态
function CheckBoxPanel:updateCheckBoxState(obj, isSelected)
    local tag = obj:getTag()
    self.m_SelectedList[tag] = isSelected
    label = obj:getChildByTag(tag)
    if isSelected == true then
        label:setColor(self.m_ConfigList.LabSelectedColor)
    else
        label:setColor(self.m_ConfigList.LabNormalColor)
    end
end

--  处理互斥事件
function CheckBoxPanel:dealExclusiveEvents()
    for i, v in pairs(self.m_CheckBoxList) do
        local lIsSelected = false
        if v == self.m_CurrCheckBox then
            lIsSelected = true
        end
        v:setSelected(lIsSelected)
        self:updateCheckBoxState(v, lIsSelected)
        if self.m_callback then
            local tag = v:getTag()
            self.m_callback(tag, lIsSelected)
        end
    end
end

-- 设置是否可点,默认可置灰
function CheckBoxPanel:setEnabled(enable, isShow)
    for i, v in pairs(self.m_CheckBoxList) do
        v:setEnabled(enable)
        -- v:setSelected(enable)

        -- 文本颜色
        local tag = v:getTag()
        local label = v:getChildByTag(tag)
        if isShow then
        else
            if enable then
                v:setOpacity(255)
                label:setOpacity(255)
            else
                v:setOpacity(255 * 0.5)
                label:setOpacity(255 * 0.5)
            end
        end
        
    end
end

-- 设置某一按钮的可选性
-- @int index 按钮序号
-- @boolean enable 是否可选
function CheckBoxPanel:setBtnEnabled(index, enable)
    local v = self.m_CheckBoxList[index]
    v:setEnabled(enable)
    -- 文本颜色
    local tag = v:getTag()
    local label = v:getChildByTag(tag)

    if enable then
        v:setOpacity(255)
        label:setOpacity(255)
    else
        v:setOpacity(255 * 0.5)
        label:setOpacity(255 * 0.5)
    end
end

-- 设置是否可选中
function CheckBoxPanel:setSelectedIndex(enable, index)
    for i, v in pairs(self.m_CheckBoxList) do
        if index == i then
            v:setSelected(enable)
            -- 文本颜色
            local tag = v:getTag()
            local label = v:getChildByTag(tag)
            if enable then
                label:setColor(self.m_ConfigList.LabSelectedColor)
            else
                label:setColor(self.m_ConfigList.LabNormalColor)
            end
        end
    end
end

-- 获取单个复选框项的选中状态
function CheckBoxPanel:getSelectedByIndex(index)
    for i, v in pairs(self.m_CheckBoxList) do
        if index == i then
            return v:isSelected()
        end
    end
end

--[[
    @biref 设置单个复选框项的可见性，并且会刷新排版
    @param index 索引
    @param visible 可见性
--]]
function CheckBoxPanel:setOptionItemVisible(index, visible)
    self.m_OptionPanelList[index]:setVisible(visible)
    self:composition()
end

--[[
    @biref 设置单个复选框选中状态，并且会调用回调事件
    @param index 索引
    @param selected 选中状态
--]]
function CheckBoxPanel:setOptionItemSelected(index, selected)
    self.m_SelectedList[index] = selected
    self.m_CheckBoxList[index]:setSelected(self.m_SelectedList[index])
    if selected then
        self:onCheckBoxEvent(self.m_CheckBoxList[index], ccui.CheckBoxEventType.selected)
    else
        self:onCheckBoxEvent(self.m_CheckBoxList[index], ccui.CheckBoxEventType.unselected)
    end
end

return CheckBoxPanel