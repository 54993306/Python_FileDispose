
local CheckBoxPanel = class("CheckBoxPanel", function()
    local ret = display.newNode()
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
                --  默认复选框是否选中
                isSelected = true
            },
            --  选项2
            {
                --  文本
                text = "十三不靠加番",
                --  默认复选框是否选中
                isSelected = false
            }
        },
        --  分割线的可见性；true：显示分割线；  false：隐藏分割线
        --  不传该参数则作false处理
        lineVisible = true
    }
]]
function CheckBoxPanel:ctor(data, callback)
    self.m_data = data
    self.m_callback = callback
    self:initData()
    self:initUI()
    --  所有控件创建完成后，确定最终面板尺寸
    self:setContentSize(self.m_optionPanelSize.width, self.m_currHeight)
    --  最终位置整体往上偏移
    self.m_layoutNode:setPosition(cc.p(0, self:getContentSize().height - self.m_optionPanelSize.height))
end

--  初始化数据
function CheckBoxPanel:initData()
    --  文本颜色
    self.m_labelColors =
    {
        --  默认
        normalColor = cc.c3b(0x2b,0x4c,0x01),
        --  选中
        selectedColor = cc.c3b(0xff,0x00,0x00)
    }

    --  字体尺寸
    self.m_labelSize = 28

    --  单排选项面板尺寸
    self.m_optionPanelSize = cc.size(800, 60)

    --  单个控件位置偏移量
    self.m_posOffset = cc.p(0, self.m_optionPanelSize.height * 0.5)

    --  当前面板尺寸的高
    self.m_currHeight = self.m_optionPanelSize.height

    --  复选框列表
    self.m_checkboxes = {}

    --  复选框选择结果列表
    self.m_cbSelectedList = {}
end

--  初始化UI界面
function CheckBoxPanel:initUI()
    --  布局节点，所有控件的父节点，用于调整整体位置
    self.m_layoutNode = display.newNode()
    self:addChild(self.m_layoutNode)
    self:initLine()
    self:initTitle()
    self:initOptions()
end

--  初始化标题
function CheckBoxPanel:initTitle()
    local hasTitle = self.m_data.title or false
    if not hasTitle then
        --  空则不创建标题
        return
    end
    --  字体路径
    local kFontFilePath = "hall/font/fangzhengcuyuan.TTF"
    --  标题
    local title = display.newTTFLabel( {
        text = self.m_data.title,
        font = kFontFilePath,
        size = self.m_labelSize,
        color = self.m_labelColors.normalColor,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    } )
    self.m_layoutNode:addChild(title)
    title:setAnchorPoint(cc.p(0, 0.5))
    title:setPosition(cc.p(5, 0 + self.m_posOffset.y))
end

--  初始化选项
function CheckBoxPanel:initOptions()
    --  选项位置
    local itemPos =
    {
        cc.p(self.m_optionPanelSize.width * 0.1,- self.m_optionPanelSize.height * 0.5 + self.m_posOffset.y),
        cc.p(self.m_optionPanelSize.width * 0.4,- self.m_optionPanelSize.height * 0.5 + self.m_posOffset.y)
    }

    local kCSBFilePath = "package_res/games/kaipingmj/friendRoom/CheckBoxPanel.csb"
    local CheckBoxPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile(kCSBFilePath)

    --  行
    local row = 0
    --  列
    local col = 0
    --  最大列数
    local colMax = 2

    --  选项
    for i, v in pairs(self.m_data.options) do
        col = col + 1
        if col > colMax then
            col = 1
            row = row + 1
            self.m_currHeight = self.m_currHeight + self.m_optionPanelSize.height
        end

        local panel = CheckBoxPanel:clone()
        self.m_layoutNode:addChild(panel)
        panel:setPosition(itemPos[col].x, itemPos[col].y - row * self.m_optionPanelSize.height)

        --  复选框
        self.m_checkboxes[i] = ccui.Helper:seekWidgetByName(panel, "CheckBox")
        self.m_checkboxes[i]:setTag(i)
        self.m_checkboxes[i]:addEventListener(handler(self, self.onCheckBoxEvent))

        --  文本
        local label = ccui.Helper:seekWidgetByName(panel, "Label")
        label:setTag(self.m_checkboxes[i]:getTag())
        label:setString(v.text)
        label:setFontSize(self.m_labelSize)
        label:setFontName("hall/font/fangzhengcuyuan.TTF")

        --  初始化状态表现
        self.m_cbSelectedList[i] = v.isSelected and true or false
        self.m_checkboxes[i]:setSelected(self.m_cbSelectedList[i])
        self:updateCheckBoxState(self.m_checkboxes[i], self.m_cbSelectedList[i])
    end
end

--  初始化分割线
function CheckBoxPanel:initLine()
    --  分割线位置
    local kLinePosX = self.m_optionPanelSize.width / 2
    local kLinePosY = 1

    --  分割线尺寸
    local kLineSize = cc.size(self.m_optionPanelSize.width, 2)

    --  分割线
    self.m_line = display.newScale9Sprite("hall/Common/line2.png", kLinePosX, kLinePosY, kLineSize)
    self:addChild(self.m_line)

    local lineVisible = self.m_data.lineVisible or false
    self:setLineVisible(lineVisible)
end

--  设置分割线的可见性
function CheckBoxPanel:setLineVisible(isVisible)
    self.m_line:setVisible(isVisible)
    self.m_data.lineVisible = isVisible
end

--  更新复选框的表现状态
function CheckBoxPanel:updateCheckBoxState(obj, isSelected)
    local tag = obj:getTag()
    self.m_cbSelectedList[tag] = isSelected
    label = obj:getChildByTag(tag)
    if isSelected == true then
        label:setColor(self.m_labelColors.selectedColor)
    else
        label:setColor(self.m_labelColors.normalColor)
    end
end

--  复选框回调事件
function CheckBoxPanel:onCheckBoxEvent(obj, event)
    --[[
    if event == ccui.CheckBoxEventType.selected then
        label = obj:getChildByTag(obj:getTag())
        label:setColor(self.m_labelColors.selectedColor)
        if self.m_callback then
            self.m_callback(obj:getTag(), true)
        end
    elseif event == ccui.CheckBoxEventType.unselected then
        label = obj:getChildByTag(obj:getTag())
        label:setColor(self.m_labelColors.normalColor)
        if self.m_callback then
            self.m_callback(obj:getTag(), false)
        end
    end
    --]]
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

return CheckBoxPanel