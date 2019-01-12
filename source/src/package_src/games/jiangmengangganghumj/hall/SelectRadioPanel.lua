--
-- Author: Nong Jinxia
-- Date: 2017-04-10 09:52:25
--

local SelectRadioBtn = require("app.hall.common.SelectRadioBtn")

local SelectRadioPanel = class("SelectRadioPanel", function() 
    local ret = display.newNode()
    return ret
end)

---------------------------
-- 构造函数
-- callback 按钮被选中时的回调
function SelectRadioPanel:ctor(datas, callback)
    --[[
    datas = {
        title           = "title:",             -- 标题
        radios          = {{"",},},                -- 未选中情况下的文字
        hiddenLine      = true or false,        -- 是否隐藏分隔线
        index           = {0,},                 -- 按钮序号
        selectImg       = "",                   -- 按钮被选中时的图片
        backgroundImg   = "",                   -- 按钮未被选中时的背景图片
        selectColor     = cc.c3b(255, 0, 0),    -- 按钮被选中时的颜色
        normalColor     = cc.c3b(0, 0, 0),      -- 按钮未被选中时的颜色
        manualSelect    = true,                 -- 手动选中, 避免出现多个复选框初始化完成前, 相互调用的问题
        count=3, --一行几个 
        radiosGroupIdx = 1 --第几组radios
    }
    ]]
    
    self.m_data = datas or {}
    self.m_data.callback = callback
    self.m_data.radios = self.m_data.radios or {}
    self.m_data.count=datas.count or 3

    --为了支持一个项多个文字 做个旧版兼容

    for i,v in ipairs(self.m_data.radios) do        
        if type(v) == "table" then
        else
            self.m_data.radios[i] = {v}
        end
    end

    --设置默认选项的值
    self.select={}
    if not self.m_data.select or self.m_data.select>#self.m_data.radios then
        self.select=1
    else
        self.select=self.m_data.select
    end

    if not self.m_data.radiosGroupIdx or self.m_data.radiosGroupIdx > #self.m_data.radios[1] then
        self.radiosGroupIdx=1
    else
        self.radiosGroupIdx=self.m_data.radiosGroupIdx
    end


    if not datas.index then
        self.m_data.index = {}
        for i, v in ipairs(self.m_data.radios) do
            table.insert(self.m_data.index, i)
        end
    end
    -- self.m_data.index = self.m_data.index or {}
    self.m_radioBtns = {}

    self:initUI()

    if not self.m_data.manualSelect and #self.m_radioBtns > 0 then
        self:setSelectedIndex(self.select)
    end


    -- 数据中是否要求隐藏分隔线
    -- self:setLineVisible(not self.m_data.hiddenLine)
    -- self:setLineVisible(true)
end

-- 保持原有接口
function SelectRadioPanel:getButtonIndex()
    return self:getSelectedIndex()
end

-- 初始化UI
function SelectRadioPanel:initUI()
    self.m_root = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/select_charge.csb")
    self.m_root:setPosition(cc.p(0, 0))
    self.m_root:setAnchorPoint(cc.p(0, 0))
    self:addChild(self.m_root)

    self.m_title = ccui.Helper:seekWidgetByName(self.m_root, "title")
    self.m_title:setString(self.m_data.title)
    self.m_panel = ccui.Helper:seekWidgetByName(self.m_root, "radio_panel")

    local height=self.m_root:getContentSize().height

    --根据选项的数量设置高度的放大倍数
    self.tmpRow1=math.ceil (#self.m_data.radios/self.m_data.count)

    self.m_root:setContentSize(cc.size(self.m_root:getContentSize().width,height*self.tmpRow1))
  
    --设置标题名字的位置
    self.m_title:setPositionY(self.m_root:getContentSize().height-height/2)

    -- 初始化按钮
    self:initSelectRadioBtns()
end

-- 初始化按钮
function SelectRadioPanel:initSelectRadioBtns()
    local i = 1
    for k, v in ipairs(self.m_data.index) do
        if self.m_data.radios[k] then
            local data = {
                textNormal      = self.m_data.radios[k][self.radiosGroupIdx],  -- 未选中情况下的文字
                index           = v, -- 序号
                selectImg       = self.m_data.selectImg, -- 选中的图片
                backgroundImg   = self.m_data.backgroundImg, -- 背景图片
                selectColor     = self.m_data.selectColor, -- 选中的颜色
                normalColor     = self.m_data.normalColor, -- 未选中的颜色
                callback        = handler(self, self.setSelectedIndex),-- self.setSelectedIndex, -- 选中时的回调
                hasGroup        = true, -- 是否有组
            }
            local btn = SelectRadioBtn.new(data)     
            local width=self.m_data.width or btn:getContentSize().width
            -- self.tmpRow2=""
            self.tmpRow2=math.ceil ((i-0.1)/self.m_data.count)
            -- btn的高度是80
            btn:setPosition(cc.p((width+67) * ((i-1)%self.m_data.count)+8, btn:getContentSize().height  * (self.tmpRow1-self.tmpRow2)))
            i = i + 1
            self.m_panel:addChild(btn)
            table.insert(self.m_radioBtns, btn)
        end
    end
end

-- 设置大小
function SelectRadioPanel:setContentSize(size)
    self.m_root:setContentSize(size)
end

-- 获取大小
function SelectRadioPanel:getContentSize()
    return self.m_root:getContentSize()
end

-- 设置选中的Index
function SelectRadioPanel:setSelectedIndex(index)
    self.m_selectedIndex = index
    for k, v in ipairs(self.m_radioBtns) do
        v:setSelected(v:getIndex() == self.m_selectedIndex)
    end
    if self.m_data.callback then
        self.m_data.callback(self.m_selectedIndex, self.radiosGroupIdx)
    end
end

-- 设置option的group
function SelectRadioPanel:setGroupIdx(idx)
    --  选项    
    for i, v in ipairs(self.m_radioBtns) do
        -- options 中的某项的text表的idx的值不存在的话 不改变
        if self.m_data.radios[i][idx] ~= nil then
            v:setTextNormal( self.m_data.radios[i][idx] )
        else
            v:setTextNormal( self.m_data.radios[i][#self.m_data.radios[i]])
        end
    end

    self.radiosGroupIdx = idx
    if self.m_data.callback then
        self.m_data.callback(self.m_selectedIndex, self.radiosGroupIdx)
    end
end

-- 获取选中的Index
function SelectRadioPanel:getSelectedIndex()
    return self.m_selectedIndex
end

-- 获取对应序号的Btn
function SelectRadioPanel:getBtnByIndex(index)
    for k, v in ipairs(self.m_radioBtns) do
        if v:getIndex() == index then
            return v
        end
    end
    return nil
end

-- 设置分隔线可见性
function SelectRadioPanel:setLineVisible(visible)
    local line = ccui.Helper:seekWidgetByName(self.m_root, "line")
    if line then
        line:setVisible(visible)
    end
end

-- 移除分隔线(注意! 此操作不可逆)
function SelectRadioPanel:removeLine()
    local line = ccui.Helper:seekWidgetByName(self.m_root, "line")
    if line then
        local lineHeight = line:getContentSize().height
        line:removeFromParent()
        self.m_title:setPositionY(self.m_title:getPositionY() - lineHeight)
        self.m_panel:setPositionY(self.m_panel:getPositionY() - lineHeight)
        local size = self:getContentSize()
        self:setContentSize(cc.size(size.width, size.height - lineHeight))
    end
end

return SelectRadioPanel
