-------------------------
-- Author:  周思宇
-- Date:    2017-05-22

local kColors = {
    normalColor = G_ROOM_INFO_FORMAT.normalColor,
    selectColor = G_ROOM_INFO_FORMAT.selectColor,
}

-- 按钮的默认图片
local kImg = {
    selectImg       = "hall/huanpi2/Common/btn_b_on2.png", -- 选中的图片
    backgroundImg   = "hall/huanpi2/Common/radio_yellow_box2.png", -- 背景图片
}

-- 按钮的透明度
local kOpacity = {
    disabled = 0.5 * 255,   -- 被禁用
    normal = 255,           -- 正常状态
    hidden = 0,             -- 隐藏状态
}

-- 按钮的缩放
local kScale = {
    normal = 1,     -- 通常状态
    pressed = 0.9,  -- 按住状态
}

local SelectRadioBtn = class("SelectRadioBtn", function() 
    local ret = display.newNode()
    return ret
end)

function SelectRadioBtn:ctor(data)
    --[[
    data = {
        textNormal      = "",  -- 未选中情况下的文字
        index           = 0, -- 序号
        selectImg       = "", -- 选中的图片
        backgroundImg   = "", -- 背景图片
        selectColor     = cc.c3b(255, 0, 0), -- 选中的颜色
        normalColor     = cc.c3b(0, 0, 0), -- 未选中的颜色
        callback        = nil, -- 选中时的回调
        hasGroup        = false, -- 是否有组
    }
    ]]
    -- dump(data)
    self.m_data = data or {}
    -- 载入UI
    self.m_pWidget = CSBManager.getInstance():getCSBFile("hall/radio_item.csb")--ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/radio_item.csb");
    self.m_pWidget:addTo(self)
    -- 底部panel
    self.m_root = ccui.Helper:seekWidgetByName(self.m_pWidget, "root")

    self:bindBtn() -- 绑定UI上的按钮
    
    self.m_text = ccui.Helper:seekWidgetByName(self.m_pWidget, "text")
    self.m_text:setString(self.m_data.textNormal)
    if IsPortrait then -- TODO
        self.m_text:setFontSize(self.m_data.textSize or G_ROOM_INFO_FORMAT.fontSize)
    else
        self.m_text:setAnchorPoint(0, 0)
        self.m_text:setPosition(cc.p(G_ROOM_INFO_FORMAT.itemTextOffsetX,G_ROOM_INFO_FORMAT.itemTextOffsetY))
    end
    self.m_virtualRendererSize = cc.size(self.m_text:getPositionX() + self.m_text:getContentSize().width, self.m_text:getContentSize().height)

    self:setIndex(self.m_data.index)
    self:setSelected(false)
    self.m_enabled = true
end

function SelectRadioBtn:setTextNormal(str)
    self.m_data.textNormal = str
    self.m_text:setString(self.m_data.textNormal)
end

function SelectRadioBtn:bindBtn()
    self.m_btn = ccui.Helper:seekWidgetByName(self.m_pWidget, "radio_btn")
    self.m_btn:loadTexture(self.m_data.selectImg or kImg.selectImg, ccui.TextureResType.localType)
    self.m_btn:setSwallowTouches(false)
    self.m_btn:addTouchEventListener(handler(self, self.onChangedRadioButtonSelect))

    self.m_btnBg = display.newSprite(self.m_data.backgroundImg or kImg.backgroundImg)
    self.m_btnBg:setAnchorPoint(self.m_btn:getAnchorPoint())
    self.m_btnBg:setPosition(self.m_btn:getPosition())
    self.m_btnBg:addTo(self.m_btn:getParent(), -1)
end

function SelectRadioBtn:setContentSize(size)
    self.m_root:setContentSize(size)
end

function SelectRadioBtn:getContentSize()
    return self.m_root:getContentSize()
end

function SelectRadioBtn:setIndex(index)
    self.index = index
end

function SelectRadioBtn:getIndex()
    return self.index
end

--------------------
-- 设置选中状态
function SelectRadioBtn:setSelected(selected)
    self.m_isSelected = selected
    if self.m_isSelected then
        self.m_btn:setOpacity(kOpacity.normal)
        self.m_text:setColor(self.m_data.selectColor or kColors.selectColor)
    else
        self.m_btn:setOpacity(kOpacity.hidden)
        self.m_text:setColor(self.m_data.normalColor or kColors.normalColor)
    end
    -- 当按钮独立时, 状态改变就触发事件
    if not self.m_data.hasGroup and self.m_data.callback then
        self.m_data.callback(self:getIndex(), selected)
    end
end

function SelectRadioBtn:getSelected()
    return self.m_isSelected
end

function SelectRadioBtn:setEnabled(enable)
    self.m_enabled = enable
    local opacity = enable and kOpacity.normal or kOpacity.disabled
    self.m_text:setOpacity(opacity)
    self.m_btnBg:setOpacity(opacity)
    -- 按钮在未选中状态被启用或禁用时, 透明度仍然为kOpacity.hidden
    self.m_btn:setTouchEnabled(enable)
    self.m_btn:setOpacity(not self:getSelected() and kOpacity.hidden or opacity)
end

function SelectRadioBtn:getEnabled()
    return self.m_enabled
end
function SelectRadioBtn:onChangedRadioButtonSelect(radio, EventType)
    if IsPortrait then -- TODO
        if EventType == ccui.TouchEventType.began then
            local pos_x,pos_y = radio:getPosition()
            self.world_pos = radio:getParent():convertToWorldSpace(cc.p(pos_x,pos_y))
            self.moving = false
            self.m_btn:setScale(0.9)
        elseif EventType == ccui.TouchEventType.ended then

            self.m_btn:setScale(1)
            if not self.moving then
                self:setSelected(self.m_data.hasGroup or not self.m_isSelected)
                -- 当按钮属于某一组时, 只有触摸到这个按钮时才触发事件
                if self.m_data.hasGroup and self.m_data.callback then
                    self.m_data.callback(self:getIndex())
                end
            end
            self.moving = false
        elseif EventType == ccui.TouchEventType.canceled then
            self.m_btn:setScale(1)
            self.moving = false
        elseif EventType == ccui.TouchEventType.moved then
            local pos_x,pos_y = radio:getPosition()
            local world_pos = radio:getParent():convertToWorldSpace(cc.p(pos_x,pos_y))
            if  math.abs(self.world_pos.x - world_pos.x) > 10 or math.abs(self.world_pos.y - world_pos.y) > 10 then
                self.moving = true
            end
        end
    else
        if EventType == ccui.TouchEventType.began then
            self:setSelected(self.m_data.hasGroup or not self.m_isSelected)
            self.m_btn:setScale(0.9)
            -- 当按钮属于某一组时, 只有触摸到这个按钮时才触发事件
            if self.m_data.hasGroup and self.m_data.callback then
                self.m_data.callback(self:getIndex())
            end
        elseif EventType == ccui.TouchEventType.ended then
            self.m_btn:setScale(1)
        elseif EventType == ccui.TouchEventType.canceled then
            self.m_btn:setScale(1)
        end
    end
end

-- 获取可见部分的长度
function SelectRadioBtn:getVirtualRendererSize()
    return self.m_virtualRendererSize
end

return SelectRadioBtn