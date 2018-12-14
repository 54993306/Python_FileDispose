--
-- Author: RuiHao Lin
-- Date: 2017-05-15 09:59:09
--


--  字体路径
local lFontFilePath = "hall/font/fangzhengcuyuan.TTF"
--  单选模板
local lCSBFilePath = "games/common/game/radiobutton_panel.csb"
--  分割线路径
local lLineFilePath = "hall/Common/line2.png"

-- @brief   RadioButtonGroup   创建“房间界面”定制版【单选版块】
local RadioButtonGroup = class("RadioButtonGroup", function()
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
                text = {"七对加番"},
                --  默认复选框是否选中
                isSelected = true
            },
            --  选项2
            {
                --  文本
                text = {"七对加番"},
                --  默认复选框是否选中
                isSelected = false
            }
        },

        --  可配置属性，详见 RadioButtonGroup:initConfigList()
        Config =
        {
            --  @brief  分割线的可见性；不传该参数则作false处理；
            --  @Exclusive  true：显示分割线；  false：隐藏分割线；
            LineVisible = true,        

            --  @brief  初始化时默认选项是否产生响应事件；不传该参数则作true处理；
            --  @ResponseEvent  true：产生响应事件；  false：不产生响应事件；
            ResponseEvent = false,

            --  @brief  单排选项面板尺寸
            OptionPanelSize = cc.size(1020, 60),

            --  @brief  初始化时options中text的idx；
            --  @OptionsGroupIdx  text[idx]；
            OptionsGroupIdx = 1,
        }
    }
]]
function RadioButtonGroup:ctor(data, callback)
    self.m_data = self:formatData(data)
    self.m_callback = callback
    self:init()
end

--为了兼容旧版
--为了支持多选，将v.text变换成table格式
function RadioButtonGroup:formatData(data)
    for i, v in pairs(data.options) do
        if type(v.text) == "table" then
        else
            v.text = {v.text}
        end
    end
    return data
end

--  初始化
function RadioButtonGroup:init()
    self:initData()
    self:initUI()
end

--  初始化数据
function RadioButtonGroup:initData()
    --  初始化可配置属性
    self:initConfigList()

    --  单个控件位置偏移量
    self.m_posOffset = cc.p(0, self.m_OptionPanelSize.height * 0.5)

    --  当前面板尺寸的高
    self.m_CurrHeight = self.m_OptionPanelSize.height
    
    --  选项面板列表
    self.m_OptionPanelList = { }
    
    --  按钮列表
    self.m_ButtonList = { }
    
    --  按钮描述文本列表
    self.m_LabelList = { }

    --  当前选中的按钮
    self.m_CurrButton = nil

    -- 当前option的组别
    self.m_CurrGroupIdx = self.m_ConfigList.OptionsGroupIdx
end

--  初始化可配置属性
function RadioButtonGroup:initConfigList()
    --  可配置属性列表
    self.m_ConfigList = self.m_data.Config or {}

    --  分割线可见性
    self.m_ConfigList.LineVisible = self.m_ConfigList.LineVisible or false

    --  子项间是否互斥
    self.m_ConfigList.Exclusive = self.m_ConfigList.Exclusive or false

    --  初始化时默认选项是否产生响应事件
    self.m_ConfigList.ResponseEvent = self.m_ConfigList.ResponseEvent == nil or self.m_ConfigList.ResponseEvent

    --  默认最大列数
    self.m_ConfigList.MaxCol = self.m_ConfigList.MaxCol or G_ROOM_INFO_FORMAT.groupColMax

    --  文本正常颜色
    self.m_ConfigList.LabNormalColor = self.m_ConfigList.LabNormalColor or G_ROOM_INFO_FORMAT.normalColor

    --  文本选中颜色
    self.m_ConfigList.LabSelectedColor = self.m_ConfigList.LabSelectedColor or G_ROOM_INFO_FORMAT.selectColor

    --  文本字体尺寸
    self.m_ConfigList.LabFontSize = self.m_ConfigList.LabFontSize or G_ROOM_INFO_FORMAT.fontSize

    --  单排选项面板尺寸
    self.m_OptionPanelSize = self.m_ConfigList.OptionPanelSize or cc.size(G_ROOM_INFO_FORMAT.lineWidth, G_ROOM_INFO_FORMAT.lineHeight)

    -- option中text的idx
    self.m_ConfigList.OptionsGroupIdx = self.m_ConfigList.OptionsGroupIdx or 1

    -- option中text的idx
    self.m_ConfigList.NeedMove = self.m_ConfigList.NeedMove or false --是否需要偏移后面选项

    -- option中text的idx
    self.m_ConfigList.MoveLast = self.m_ConfigList.MoveLast or false --是否需要移动最后面选项
end

--  初始化UI界面
function RadioButtonGroup:initUI()
    --  布局节点，所有控件的父节点，用于调整整体位置
    self.m_layoutNode = ccui.Layout:create()
    self:addChild(self.m_layoutNode)
    self:initLine()
    self:initTitle()
    self:initOptions()
    self:composition()
    self:dealResponseEvent(self.m_ConfigList.ResponseEvent)
end

--  初始化标题
function RadioButtonGroup:initTitle()
    local hasTitle = self.m_data.title or false
    if not hasTitle then
        --  空则不创建标题
        return
    end
    --  标题
    local title = display.newTTFLabel( {
        text = self.m_data.title,
        font = lFontFilePath,
        size = G_ROOM_INFO_FORMAT.titleFontSize,
        color = G_ROOM_INFO_FORMAT.titleFontColor,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    } )
    self.m_layoutNode:addChild(title)
    title:setAnchorPoint(cc.p(0, 0.5))
    title:setPosition(cc.p(G_ROOM_INFO_FORMAT.titlePosX, 0 + 30--[[self.m_posOffset.y]]))
end

--  初始化选项
function RadioButtonGroup:initOptions()
    local lRadioButtonPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile(lCSBFilePath)

    --  选项
    for i, v in pairs(self.m_data.options) do
        --  选项面板
        self.m_OptionPanelList[i] = lRadioButtonPanel:clone()
        self.m_OptionPanelList[i]:setSwallowTouches(false)
        
        self.m_layoutNode:addChild(self.m_OptionPanelList[i])

        --  按钮
        self.m_ButtonList[i] = ccui.Helper:seekWidgetByName(self.m_OptionPanelList[i], "Button")
        self.m_ButtonList[i]:setSwallowTouches(false)
        self.m_ButtonList[i]:setTag(i)
        self.m_ButtonList[i]:addTouchEventListener(handler(self, self.onBtnTouchEvent))

        --  文本
        self.m_LabelList[i] = ccui.Helper:seekWidgetByName(self.m_OptionPanelList[i], "Label")
        self.m_LabelList[i]:setTag(i)
        self.m_LabelList[i]:setString( (v.text[self.m_CurrGroupIdx] ~= nil) and v.text[self.m_CurrGroupIdx] or v.text[1] )
        self.m_LabelList[i]:setFontSize(self.m_ConfigList.LabFontSize)
        self.m_LabelList[i]:setFontName(lFontFilePath)
        self.m_LabelList[i]:setPosition(cc.p(56,14))

        if v.isSelected then
            self.m_CurrButton = self.m_ButtonList[i]
        end
    end
    self:updateBtnState(self.m_CurrButton)
end

--  初始化分割线
function RadioButtonGroup:initLine()
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
    @brief  处理默认选项响应事件
    @isResponse 是否响应事件，不传参则作true处理
--]]
function RadioButtonGroup:dealResponseEvent(isResponse)
    isResponse = isResponse == nil or isResponse
    if not isResponse then
        return
    end
    if self.m_CurrButton then
        self:onBtnTouchEvent(self.m_CurrButton, ccui.TouchEventType.ended)
    end
end

--  设置分割线的可见性
function RadioButtonGroup:setLineVisible(isVisible)
    self.m_line:setVisible(isVisible)
    self.m_ConfigList.LineVisible = isVisible
end

--[[
    @biref  排版
--]]
function RadioButtonGroup:composition()
    --  行
    local row = 0
    --  列
    local col = 0
    --  最大列数
    local lMaxCol = self.m_ConfigList.MaxCol
    --  首位置比例
    local firstPosRatio = G_ROOM_INFO_FORMAT.firstPosX / self.m_OptionPanelSize.width
    --  排版比例
    local ratio = G_ROOM_INFO_FORMAT.radioItemOffset / self.m_OptionPanelSize.width --(1 - firstPosRatio) / lMaxCol
    if lMaxCol > G_ROOM_INFO_FORMAT.groupColMax then
        ratio = ratio * (G_ROOM_INFO_FORMAT.groupColMax / lMaxCol)
    end
    --  选项位置
    local pos = cc.p(self.m_OptionPanelSize.width, - self.m_OptionPanelSize.height * 0.5 + self.m_posOffset.y)
    --  重置当前高度
    self.m_CurrHeight = self.m_OptionPanelSize.height
    local offsetX = 0
    local offsetY = 1
    for i, v in pairs(self.m_OptionPanelList) do
        col = col + 1
        if self.m_ConfigList.NeedMove then
            if i>1 then
                offsetX = -40
            else
                offsetX = 0
            end
        end        
        --  排版公式
        local formula = firstPosRatio + ratio * (col - 1)
        if self.m_ConfigList.MoveLast then -- 特殊处理
            if i == #self.m_OptionPanelList then
                formula = firstPosRatio + ratio * (2) -- 跟第三个对齐
            end
        end
        v:setPosition(pos.x * formula + offsetX, pos.y - row * self.m_OptionPanelSize.height + offsetY)
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

--  更新按钮表现状态
function RadioButtonGroup:updateBtnState(obj)
    for i, v in pairs(self.m_ButtonList) do
        local tag = v:getTag()
        if v == obj then
            --  处理被选中按钮相关逻辑
            self.m_CurrButton = v
            self.m_LabelList[tag]:setColor(self.m_ConfigList.LabSelectedColor)
            v:setEnabled(false)
            v:setBright(false)
        else
            --  处理其他按钮相关逻辑
            self.m_LabelList[tag]:setColor(self.m_ConfigList.LabNormalColor)
            v:setEnabled(true)
            v:setBright(true)
        end
    end
end

--  按钮触摸事件
function RadioButtonGroup:onBtnTouchEvent(obj, event)
    if event == ccui.TouchEventType.ended then
        self:updateBtnState(obj)
        if self.m_callback then
            local tag = obj:getTag()
            self.m_callback(tag, self.m_CurrGroupIdx)
        end
    end
end

-- 设置option的group
function RadioButtonGroup:setGroupIdx(idx)
    --  选项
    for i, v in pairs(self.m_data.options) do
        -- options 中的某项的text表的idx的值不存在的话 不改变
        if v.text[idx] ~= nil then
            self.m_LabelList[i]:setString( v.text[idx] )
        else
            self.m_LabelList[i]:setString( v.text[#v.text] )
        end
    end

    self.m_CurrGroupIdx = idx
    if self.m_callback and self.m_CurrButton then
        local tag = self.m_CurrButton:getTag()
        self.m_callback(tag, self.m_CurrGroupIdx)
    end
end

-- 设置某一按钮的可选性
-- @int index 按钮序号
-- @boolean enable 是否可选
function RadioButtonGroup:setBtnEnabled(enable, index)
    local v = self.m_ButtonList[index]
    if not v then
        return 
    end
    v:setEnabled(enable)
    -- v:setBright(not enable)
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
function RadioButtonGroup:setSelectedIndex(enable, index)
    for i, v in pairs(self.m_ButtonList) do
        if index == i then
            v:setBright(not enable)
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




return RadioButtonGroup
