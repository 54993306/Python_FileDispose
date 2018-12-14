--
-- Author: RuiHao Lin
-- @brief   CheckBoxPanel   创建“房间界面”定制版【复选选项块】
-- Date: 2017-05-15 09:59:09
--


local CheckBoxPanel = class("CheckBoxPanel", function()
    local ret = display.newNode()
    return ret
end )

--  文本颜色
local kLabelColors =
{
    --  默认
    normalColor = cc.c3b(0x2b,0x4c,0x01),
    --  选中
    selectedColor = cc.c3b(0xff,0x00,0x00)
}

--  字体尺寸
local kLabelSize = 28

--  单排选项面板尺寸
local kOptionPanelSize = cc.size(800, 60)

--  位置偏移量
local kPosOffset = cc.p(0, kOptionPanelSize.height * 0.5)

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
        --  是否需要创建分割线；true：创建分割线；  false：不创建分割线
        --  不传该参数则作true处理
        isNeedLine = false
    }
]]
--function CheckBoxPanel:ctor(data, callback)
--    self.m_data = data
--    self.m_callback = callback
--    self:initData()
--    self:initUI()
--    self:setContentSize(kOptionPanelSize.width, self.m_currHeight)
--    self.m_layoutNode:setPosition(cc.p(0, self:getContentSize().height - kOptionPanelSize.height))
--end

----  初始化数据
--function CheckBoxPanel:initData()
--    self.m_currHeight = kOptionPanelSize.height
--end

----  初始化UI界面
--function CheckBoxPanel:initUI()
--    self.m_layoutNode = display.newNode()
--    self:addChild(self.m_layoutNode)
--    self:initLine()
--    self:initTitle()
--    self:initOptions()
--end

----  初始化标题
--function CheckBoxPanel:initTitle()
--    local hasTitle = self.m_data.title or false
--    if not hasTitle then
--        return
--    end
--    --  字体路径
--    local kFontFilePath = "package_res/games/jiangmengangganghumj/CheckBoxPanel/fangzhengcuyuan.TTF"
--    --  标题
--    title = display.newTTFLabel( {
--        text = self.m_data.title,
--        font = kFontFilePath,
--        size = kLabelSize,
--        color = kLabelColors.normalColor,
--        align = cc.TEXT_ALIGNMENT_LEFT,
--        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
--    } )
--    self.m_layoutNode:addChild(title)
--    title:setAnchorPoint(cc.p(0, 0.5))
--    title:setPosition(cc.p(5, 0 + kPosOffset.y))
--end

----  初始化选项
--function CheckBoxPanel:initOptions()
--    --  选项位置
--    local itemPos =
--    {
--        cc.p(kOptionPanelSize.width * 0.1,- kOptionPanelSize.height * 0.5 + kPosOffset.y),
--        cc.p(kOptionPanelSize.width * 0.4,- kOptionPanelSize.height * 0.5 + kPosOffset.y)
--    }

--    local kCSBFilePath = "package_res/games/jiangmengangganghumj/CheckBoxPanel/CheckBoxPanel.csb"
--    local CheckBoxPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile(kCSBFilePath)

--    local j, k = 0, 0
--    --  选项
--    for i, v in pairs(self.m_data.options) do
--        j = j + 1
--        if j > 2 then
--            j = 1
--            k = k + 1
--            self.m_currHeight = self.m_currHeight + kOptionPanelSize.height
--        end

--        panel = CheckBoxPanel:clone()
--        self.m_layoutNode:addChild(panel)
--        panel:setPosition(itemPos[j].x, itemPos[j].y - k * kOptionPanelSize.height)

--        --  复选框
--        local checkbox = ccui.Helper:seekWidgetByName(panel, "CheckBox")
--        checkbox:setTag(i)
--        checkbox:addEventListener(handler(self, self.onCheckBoxEvent))

--        --  文本
--        local label = ccui.Helper:seekWidgetByName(panel, "Label")
--        label:setTag(checkbox:getTag())
--        label:setString(v.text)
--        label:setFontSize(kLabelSize)

--        --  初始化状态表现
--        if v.isSelected then
--            checkbox:setSelected(true)
--            self:onCheckBoxEvent(checkbox, ccui.CheckBoxEventType.selected)
--        else
--            checkbox:setSelected(false)
--            self:onCheckBoxEvent(checkbox, ccui.CheckBoxEventType.unselected)
--        end
--    end
--end

----  初始化分割线
--function CheckBoxPanel:initLine()
--    -- 是否创建分割线
--    local isNeedLine = self.m_data.isNeedLine or false
--    if isNeedLine then
--        --  分割线位置
--        local kLinePosX = kOptionPanelSize.width / 2
--        local kLinePosY = 1

--        --  分割线尺寸
--        local kLineSize = cc.size(kOptionPanelSize.width, 2)

--        --  分割线
--        local kLine = display.newScale9Sprite("hall/Common/line2.png", kLinePosX, kLinePosY, kLineSize)
--        self:addChild(kLine)
--    end
--end

----  复选框回调事件
--function CheckBoxPanel:onCheckBoxEvent(obj, event)
--    if event == ccui.CheckBoxEventType.selected then
--        label = obj:getChildByTag(obj:getTag())
--        label:setColor(kLabelColors.selectedColor)
--        if self.m_callback then
--            self.m_callback(obj:getTag(), true)
--        end
--    elseif event == ccui.CheckBoxEventType.unselected then
--        label = obj:getChildByTag(obj:getTag())
--        label:setColor(kLabelColors.normalColor)
--        if self.m_callback then
--            self.m_callback(obj:getTag(), false)
--        end
--    end
--end

return CheckBoxPanel