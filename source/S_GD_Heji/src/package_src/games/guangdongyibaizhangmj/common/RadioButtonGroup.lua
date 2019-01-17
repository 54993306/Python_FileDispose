--
-- Author: RuiHao Lin
-- @brief   RadioButtonGroup   创建“房间界面”定制版【复选选项块】
-- Date: 2017-05-15 09:59:09
--


local RadioButtonGroup = class("RadioButtonGroup", function()
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
        --  是否隐藏分割线；true：隐藏分割线；  false：不隐藏分割线
        --  不传该参数则作false处理
        hiddenLine = true
    }
]]
function RadioButtonGroup:ctor(data, callback)
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
function RadioButtonGroup:initData()
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

    --  按钮容器
    self.m_btnList = { }

    --  当前选中的按钮
    self.m_currBotton = nil
end

--  初始化UI界面
function RadioButtonGroup:initUI()
    --  布局节点，所有控件的父节点，用于调整整体位置
    self.m_layoutNode = display.newNode()
    self:addChild(self.m_layoutNode)
    self:initLine()
    self:initTitle()
    self:initOptions()
end

--  初始化标题
function RadioButtonGroup:initTitle()
    local hasTitle = self.m_data.title or false
    if not hasTitle then
        --  空则不创建标题
        return
    end
    --  字体路径
    local kFontFilePath = "package_res/games/guangdongyibaizhangmj/friendRoom/fangzhengcuyuan.TTF"
    --  标题
    title = display.newTTFLabel( {
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
function RadioButtonGroup:initOptions()
    --  选项位置
    local itemPos =
    {
        cc.p(self.m_optionPanelSize.width * 0.1,- self.m_optionPanelSize.height * 0.5 + self.m_posOffset.y),
        cc.p(self.m_optionPanelSize.width * 0.4,- self.m_optionPanelSize.height * 0.5 + self.m_posOffset.y),
        cc.p(self.m_optionPanelSize.width * 0.7,- self.m_optionPanelSize.height * 0.5 + self.m_posOffset.y)
    }

    local kCSBFilePath = "package_res/games/guangdongyibaizhangmj/friendRoom/RadioButtonPanel.csb"
    local RadioButtonPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile(kCSBFilePath)

    --  行
    local row = 0
    --  列
    local col = 0
    --  最大列数
    -- local colMax = 3

    --  选项
    for i, v in pairs(self.m_data.options) do
        local colMax
     if #self.m_data.options == 4 then
        colMax = 2
        col = col + 1
        if col > colMax then
            col = 1
            row = row + 1
            self.m_currHeight = self.m_currHeight + self.m_optionPanelSize.height
        end
     else 
        colMax = 3
        col = col + 1
        if col > colMax then
            col = 1
            row = row + 1
            self.m_currHeight = self.m_currHeight + self.m_optionPanelSize.height
        end
     end
        panel = RadioButtonPanel:clone()
        self.m_layoutNode:addChild(panel)
        panel:setPosition(itemPos[col].x, itemPos[col].y - row * self.m_optionPanelSize.height)

        --  按钮
        local button = ccui.Helper:seekWidgetByName(panel, "Button")
        table.insert(self.m_btnList, button)
        button:setTag(i)
        button:addTouchEventListener(handler(self, self.onBtnTouchEvent))
        --  文本
        local label = ccui.Helper:seekWidgetByName(panel, "Label")
        label:setTag(button:getTag())
        label:setString(v.text)
        label:setFontSize(self.m_labelSize)
        if v.isSelected then
            self.m_currBotton = button
        end
    end
    self:onBtnTouchEvent(self.m_currBotton, ccui.TouchEventType.ended)
end

--  初始化分割线
function RadioButtonGroup:initLine()
    -- 是否隐藏分割线
    local hiddenLine = self.m_data.hiddenLine and true
    if hiddenLine then
        --  隐藏则不创建分割线
        return
    end
    --  分割线位置
    local kLinePosX = self.m_optionPanelSize.width / 2
    local kLinePosY = 1

    --  分割线尺寸
    local kLineSize = cc.size(self.m_optionPanelSize.width, 2)

    --  分割线
    local kLine = display.newScale9Sprite("hall/Common/line2.png", kLinePosX, kLinePosY, kLineSize)
    self:addChild(kLine)
end

--  按钮触摸事件
function RadioButtonGroup:onBtnTouchEvent(obj, event)
    if event == ccui.TouchEventType.ended then
        for i, v in pairs(self.m_btnList) do
            if v == obj then
            --  处理被选中按钮相关逻辑    
                self.m_currBotton = v
                label = v:getChildByTag(v:getTag())
                label:setColor(self.m_labelColors.selectedColor)
                v:setEnabled(false)
                v:setBright(false)
                if self.m_callback then
                    self.m_callback(i)
                end
            else
            --  处理其他按钮相关逻辑    
                label = v:getChildByTag(v:getTag())
                label:setColor(self.m_labelColors.normalColor)
                v:setEnabled(true)
                v:setBright(true)
            end
        end
    end
end

return RadioButtonGroup