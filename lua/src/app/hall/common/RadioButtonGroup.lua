-------------------------------------------------------------
--  @file   RadioButtonGroup.lua
--  @brief  单选按钮组定义
--  @author ZCQ
--  @DateTime:2016-11-08 09:57:28
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================


local RadioButtonGroup = class("RadioButtonGroup")

--[
-- @brief  构造函数
-- @param  void
-- @return void
--]
function RadioButtonGroup:ctor()
    self.radioButtons = {}
    self.selectedRadioButton = nil
    self.listener = nil
end

--[
-- @brief  添加
-- @param  radio
-- @return void
--]
function RadioButtonGroup:addRadioButton(radio)
    radio:setGroup(self)
    radio:setSelected(false)
    table.insert(self.radioButtons, radio)
end

--[
-- @brief  设置选中
-- @param  idx
-- @return void
--]
function RadioButtonGroup:setSelectedRadioButton(idx)
    local radio = self.radioButtons[idx]
    if self.selectedRadioButton == radio then
        return
    end

    self:deselect()
    self.selectedRadioButton = radio
    self.selectedRadioButton:setSelected(true)
    self:onChangedRadioButtonSelect(radio)

end

--[
-- @brief  回调
-- @param  listener
-- @return void
--]
function RadioButtonGroup:setChangeEventListener(listener)
    self.listener = listener
end

--[
-- @private
--]
function RadioButtonGroup:deselect()
    if self.selectedRadioButton == nil then
        return
    end

    self.selectedRadioButton:setSelected(false)
    self.selectedRadioButton = nil
end

--[
-- @private
--]
function RadioButtonGroup:onChangedRadioButtonSelect(radio)
    if self.selectedRadioButton ~= radio then
        self:deselect()
        self.selectedRadioButton = radio
    end

    if self.listener then
        local idx = table.keyof(self.radioButtons, radio)
        self.listener(radio, idx)
    end
end

--[
-- @brief  获取选中索引
-- @param  void
-- @return void
--]
function RadioButtonGroup:getSelectedIndex()
    if nil == self.selectedRadioButton then
        return 0
    end

    return table.indexof(self.radioButtons, self.selectedRadioButton)
end

--[
-- @brief  获取指定的单选按钮
-- @param  void
-- @return void
--]
function RadioButtonGroup:getRadioButton(idx)
    return self.radioButtons[idx]
end

--[
-- @brief  获取所有的单选按钮
-- @param  void
-- @return void
--]
function RadioButtonGroup:getAllRadioButtons()
    return self.radioButtons
end

--[
-- @brief 移除所有
--]
function RadioButtonGroup:removeAllRadioButtons()
    for _, radio in ipairs(self.radioButtons) do
        radio:removeFromGroup()
    end
    self.radioButtons = {}
    self.selectedRadioButton = nil
end

return RadioButtonGroup
