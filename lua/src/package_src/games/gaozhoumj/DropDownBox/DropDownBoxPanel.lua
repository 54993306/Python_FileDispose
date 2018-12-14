--
-- Author: RuiHao Lin
-- @brief   DropDownBoxPanel   创建“房间界面”定制版【下拉框面板块】
-- Date: 2017-05-15 09:59:09
--


local DropDownBoxPanel = class("DropDownBoxPanel", function()
    local ret = cc.Node:create()
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
                text = "1马",
                --  是否为选中项，不写则作false处理
                isSelected = true
            },
            --  选项2
            {
                --  文本
                text = "2马",
            }
        },
        --  分割线的可见性；true：显示分割线；  false：隐藏分割线
        --  不传该参数则作false处理
        lineVisible = true
    }
    @callback   下拉框内按钮的额外事件回调
]]
function DropDownBoxPanel:ctor(data, callback)
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
function DropDownBoxPanel:initData()
    --  文本颜色
    self.m_labelColors =
    {
        --  默认
        normalColor = cc.c3b(0x2b,0x4c,0x01),
        --  选中
        selectedColor = cc.c3b(0xff,0x00,0x00)
    }

    --  板块列表
    self.m_panelList = {}

    --  字体尺寸
    self.m_labelSize = 28

    --  单排选项面板尺寸
    self.m_optionPanelSize = cc.size(800, 60)

    --  单个控件位置偏移量
    self.m_posOffset = cc.p(0, self.m_optionPanelSize.height * 0.5)

    --  当前面板尺寸的高
    self.m_currHeight = self.m_optionPanelSize.height
end

--  初始化UI界面
function DropDownBoxPanel:initUI()
    --  布局节点，所有控件的父节点，用于调整整体位置
    self.m_layoutNode = display.newNode()
    self:addChild(self.m_layoutNode)
    self:initLine()
    self:initTitle()
    self:initOptions()
end

function DropDownBoxPanel:setMaxRow(maxRow)
    self.m_panelList[1]:setMaxRow(maxRow)
end

--  初始化标题
function DropDownBoxPanel:initTitle()
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
        font =kFontFilePath,
        size = self.m_labelSize,
        color = self.m_labelColors.normalColor,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    } )
    self.m_layoutNode:addChild(title)
    title:setAnchorPoint(cc.p(0, 0.5))
    title:setPosition(cc.p(5, self.m_posOffset.y - 1))
end

--  初始化选项
function DropDownBoxPanel:initOptions()
    local DropDownBox = require("package_src.games.gaozhoumj.DropDownBox.DropDownBox")
    self.m_panelList[1] = DropDownBox.new(self.m_data.options, self.m_callback)
    self:addChild(self.m_panelList[1])

	--	默认最大列数
	local lColCount = 2
	self:compositionOfCol(lColCount)
end

--  初始化分割线
function DropDownBoxPanel:initLine()
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
function DropDownBoxPanel:setLineVisible(isVisible)
    self.m_line:setVisible(isVisible)
    self.m_data.lineVisible = isVisible
end

--[[
    @biref  根据最大列数排版
    @colCount   最大列数
--]]
function DropDownBoxPanel:compositionOfCol(colCount)
    --  行
    local row = 0
    --  列
    local col = 0
    --  最大列数
    local colMax = colCount
	--	首位置比例
    local firstPosRatio = 0.1
	--	排版比例
    local ratio = (1 - firstPosRatio) / colMax
    --  选项位置
    local pos = cc.p(self.m_optionPanelSize.width, - self.m_optionPanelSize.height * 0.5 + self.m_posOffset.y)
    --  X轴对齐偏移量
    local offsetX = 14
    --  重置当前高度
    self.m_currHeight = self.m_optionPanelSize.height
	for i, v in pairs(self.m_panelList) do
        col = col + 1
		--	排版公式
        local formula = firstPosRatio + ratio * (col - 1)
        v:setPosition(pos.x * formula + offsetX, pos.y - row * self.m_optionPanelSize.height)
        if (col >= colMax) and (i ~= #self.m_panelList) then
            col = 0
            row = row + 1
            self.m_currHeight = self.m_currHeight + self.m_optionPanelSize.height
        end
	end

    --  所有控件创建完成后，确定最终面板尺寸
    self:setContentSize(self.m_optionPanelSize.width, self.m_currHeight)
    --  最终位置整体往上偏移
    self.m_layoutNode:setPosition(cc.p(0, self:getContentSize().height - self.m_optionPanelSize.height))
end

return DropDownBoxPanel