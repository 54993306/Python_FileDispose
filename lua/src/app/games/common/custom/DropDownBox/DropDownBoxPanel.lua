--
-- Author: RuiHao Lin
-- Date: 2017-05-15 09:59:09
--


--  下来框
local lDropDownBox = require("app.games.common.custom.DropDownBox.DropDownBox")
--  字体路径
local lFontFilePath = "hall/font/fangzhengcuyuan.TTF"
--  分割线路径
local lLineFilePath = "hall/Common/line2.png"

-- @brief   DropDownBoxPanel   创建“房间界面”定制版【下拉框面板块】
local DropDownBoxPanel = class("DropDownBoxPanel", function()
    local ret = ccui.Layout:create()
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
        --  可配置属性，详见 DropDownBox:initConfigList()
        Config =
        {
            --  @brief  初始化时默认选项是否产生响应事件；不传该参数则作true处理；
            --  @ResponseEvent  true：产生响应事件；  false：不产生响应事件；
            ResponseEvent = false,

            --  @brief  单排选项面板尺寸
            OptionPanelSize = cc.size(1020, 60),
        }
        boxBtnCallBack 点击下拉按钮事件
    }
    @callback   下拉框内按钮的额外事件回调
]]
function DropDownBoxPanel:ctor(data, callback)
    self.m_data = data
    self.m_callback = callback
    self:init()
end

--  初始化
function DropDownBoxPanel:init()
    self:initData()
    self:initUI()
    self:dealResponseEvent(self.m_ConfigList.ResponseEvent)
end

--  初始化数据
function DropDownBoxPanel:initData()
    --  初始化可配置属性
    self:initConfigList()

    --  选项面板列表
    self.m_OptionPanelList = {}

    --  单个控件位置偏移量
    self.m_PosOffset = cc.p(0, self.m_OptionPanelSize.height * 0.5)

    --  当前面板尺寸的高
    self.m_CurrHeight = self.m_OptionPanelSize.height
end

--  初始化可配置属性
function DropDownBoxPanel:initConfigList()
    --  可配置属性列表
    self.m_ConfigList = self.m_data.Config or {}

    --  下拉框配置
    self.m_ConfigList.DropDownBoxConfig = self.m_ConfigList.DropDownBoxConfig or {}

    --  分割线可见性
    self.m_ConfigList.LineVisible = self.m_ConfigList.LineVisible or false

    --  初始化时默认选项是否产生响应事件
    self.m_ConfigList.ResponseEvent = self.m_ConfigList.ResponseEvent == nil or self.m_ConfigList.ResponseEvent

    --	默认最大列数
    self.m_ConfigList.MaxCol = self.m_ConfigList.MaxCol or 3

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
function DropDownBoxPanel:initUI()
    --  布局节点，所有控件的父节点，用于调整整体位置
    self.m_layoutNode = display.newNode()
    self:addChild(self.m_layoutNode)

    self:initLine()
    self:initTitle()
    self:initOptions()
    self:composition()
end

--  初始化标题
function DropDownBoxPanel:initTitle()
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
    title:setPosition(cc.p(G_ROOM_INFO_FORMAT.titlePosX, 0 + 30--[[self.m_PosOffset.y]]))
end

--  初始化选项
function DropDownBoxPanel:initOptions()
    local lData = {options = self.m_data.options, Config = self.m_ConfigList.DropDownBoxConfig}
    if IsPortrait then -- TODO
        lData.boxBtnCallBack = self.m_ConfigList.boxBtnCallBack
    end
    self.m_OptionPanelList[1] = lDropDownBox.new(lData, self.m_callback)
    self:addChild(self.m_OptionPanelList[1])
end

--  初始化分割线
function DropDownBoxPanel:initLine()
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

--[[
    @biref  排版
--]]
function DropDownBoxPanel:composition()
    --  行
    local row = 0
    --  列
    local col = 0
    --  最大列数
    local lMaxCol = self.m_ConfigList.MaxCol
	--	首位置比例
    local firstPosRatio = G_ROOM_INFO_FORMAT.firstPosX / self.m_OptionPanelSize.width
	--	排版比例
    local ratio = (1 - firstPosRatio) / lMaxCol
    --  选项位置
    local pos = cc.p(self.m_OptionPanelSize.width, - self.m_OptionPanelSize.height * 0.5 + self.m_PosOffset.y)
    --  X轴对齐偏移量
    local offsetX = 12
    --  重置当前高度
    self.m_CurrHeight = self.m_OptionPanelSize.height
	for i, v in pairs(self.m_OptionPanelList) do
        col = col + 1
		--	排版公式
        local formula = firstPosRatio + ratio * (col - 1)
        v:setPosition(pos.x * formula + offsetX, pos.y - row * self.m_OptionPanelSize.height)
        if (col >= lMaxCol) and (i ~= #self.m_OptionPanelList) then
            col = 0
            row = row + 1
            self.m_CurrHeight = self.m_CurrHeight + self.m_OptionPanelSize.height
        end
	end

    --  所有控件创建完成后，确定最终面板尺寸
    self:setContentSize(self.m_OptionPanelSize.width, self.m_CurrHeight)
    --  最终位置整体往上偏移
    self.m_layoutNode:setPosition(cc.p(0, self:getContentSize().height - self.m_OptionPanelSize.height))
end

--[[
    @brief  处理默认选项响应事件
    @isResponse 是否响应事件，不传参则作true处理
--]]
function DropDownBoxPanel:dealResponseEvent(isResponse)
    isResponse = isResponse == nil or isResponse
    if not isResponse then
        return
    end
    self.m_OptionPanelList[1]:onListViewBtnEvent(self.m_OptionPanelList[1].m_CurrItem, ccui.TouchEventType.ended)
end

--  设置分割线的可见性
function DropDownBoxPanel:setLineVisible(isVisible)
    self.m_line:setVisible(isVisible)
    self.m_ConfigList.LineVisible = isVisible
end

--[[
    @brief  设置下拉框最大行数
    @maxRow 小于或等于1的时设置为1
--]]
function DropDownBoxPanel:setDropDownBoxMaxRow(maxRow)
    self.m_OptionPanelList[1]:setMaxRow(maxRow)
end

--[[
    @brief  改变数据，重新绘制控件
    @data   数据
--]]
function DropDownBoxPanel:changeData(data)
    self.m_OptionPanelList[1]:changeData(data)
end

return DropDownBoxPanel