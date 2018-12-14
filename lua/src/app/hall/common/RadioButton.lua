-------------------------------------------------------------
--  @file   RadioButton.lua
--  @brief  单选按钮定义
--  @author ZCQ
--  @DateTime:2016-11-08 09:57:06
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

local Component = cc.Component
local RadioButton = class("RadioButton", Component)

local kFrameNormal = "frameNormal"
local kFrameSelect = "frameSelect"
local kTextName = "text_"
--[
-- @brief  构造函数
-- @param  void
-- @return void
--]
function RadioButton:ctor()
    RadioButton.super.ctor(self, "RadioButton")
    self.mode = enRadioButtonMode.CHANGE
    self.text = "Hello"
end

--[
-- @override
--]
function RadioButton:onBind_()
    cc(self.target_):addComponent("app.hall.common.ButtonAction"):exportMethods()
    self.target_:onClicked(handler(self, RadioButton._onClicked))
    -- self.target_:setUnifySizeEnabled(true)
end

--[
-- @override
--]
function RadioButton:onUnbind_()
    -- cc.unbind(self.target_, "ButtonAction")
    cc(self.target_):removeComponent("app.hall.common.ButtonAction")
    self:removeFromGroup()
end

--[
-- @brief  初始化，图片
-- @param  void
-- @return void
--]
function RadioButton:loadTextures(normalbg, normalfg, selectedbg, selectedfg)
    self.normalbg = normalbg
    self.normalfg = normalfg
    self.selectedbg = selectedbg
    self.selectedfg = selectedfg
end

--[
-- @brief  设置页签显示的文字
-- @param  text
-- @return void
--]
function RadioButton:setText(text)
    self.text = text
end

--[[
-- @brief  设置按钮模式
-- @param  void
-- @return void
--]]
function RadioButton:setButtonMode(mode)
    self.mode = mode
end

--[
-- @brief  设置选中
-- @param  void
-- @return void
--]
function RadioButton:setSelected(selected)
    if self.selected == selected then
        return
    end

    self.selected = selected
    if self.selected then
        if self.mode == enRadioButtonMode.TEXTURE then
          
        elseif self.mode == enRadioButtonMode.FRAME then
           
        elseif self.mode == enRadioButtonMode.TEXT then
          
        elseif self.mode == enRadioButtonMode.CHANGE then
            self.target_:loadTexture(self.selectedbg, ccui.TextureResType.localType)
        end
    else
        if self.mode == enRadioButtonMode.TEXTURE then
          
        elseif self.mode == enRadioButtonMode.FRAME then
            
        elseif self.mode == enRadioButtonMode.TEXT then
           
        elseif self.mode == enRadioButtonMode.CHANGE then
            self.target_:loadTexture(self.normalbg, ccui.TextureResType.localType)
        end
    end
end

--[
-- @brief  设置单选组
-- @param  void
-- @return void
--]
function RadioButton:setGroup(group)
    if self.group then
        printError("一个单选按钮只能属于一个组")
        return
    end
    self.group = group
end

--[
-- @brief  从单选组移除
-- @param  void
-- @return void
--]
function RadioButton:removeFromGroup()
    if not self.group then
        return
    end
    self.group = nil
    self.selected = nil
end

--[
-- @private
--]
function RadioButton:_onClicked()
    if not self.selected then
        self:setSelected(true)
        if self.group then
            self.group:onChangedRadioButtonSelect(self.target_)
        end
    -- else
    --     self:setSelected(false)
    --     if self.group then
    --         self.group:onChangedRadioButtonSelect(self.target_)
    --     end
    end
end

--[
-- @override
--]
function RadioButton:exportMethods()
    self:exportMethods_({
        "loadTextures",
        "setText",
        "setSelected",
        "setGroup",
        "setButtonMode",
        "removeFromGroup",
    })
    return self.target_
end

return RadioButton
