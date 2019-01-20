-------------------------------------------------------------
--  @file   ButtonAction.lua
--  @brief  按钮组件
--  @author Zhu Can Qin
--  @DateTime:2016-08-23 16:59:37
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================


local kTouchScaled  = 0.8 -- 按下缩放系数
local kNormalScaled = 1.0 -- 常态缩放系数
local kTime = 0.06
local kActionTag = 0xb122
local Component = cc.Component
local ButtonAction = class("ButtonAction", Component)

-- 示例：
--     local action = self:createTouchableSprite({
--             image = "real_res/1004331.png",
--             size = cc.size(100, 100),
--             label = "TOUCH ME !",
--             labelColor = cc.c3b(255, 0, 0)})
--         :pos(200, 200)
--         :addTo(layer)
--     cc(action):addComponent(Define.enComponentName.BUTTON_ACTION):exportMethods()
--     action:onClicked(handler(self, MjMediator.onBtnGang))

--     local action = cc.ui.UIImage.new("real_res/1004331.png")
--         :pos(400, 200)
--         :addTo(layer)
--     cc(action):addComponent(Define.enComponentName.BUTTON_ACTION):exportMethods()
--     action:onClicked(handler(self, MjMediator.onBtnGang2))



-- function MjMediator:createTouchableSprite(p)
--     local sprite = display.newScale9Sprite(p.image)
--     sprite:setContentSize(p.size)

--     local cs = sprite:getContentSize()
--     local label = cc.ui.UILabel.new({
--             UILabelType = 2,
--             text = p.label,
--             color = p.labelColor})
--     label:align(display.CENTER)
--     label:setPosition(cs.width / 2, label:getContentSize().height)
--     sprite:addChild(label)
--     sprite.label = label
--     return sprite
-- end

--[
-- @brief  构造函数
-- @param  void
-- @return void
--]
function ButtonAction:ctor()
    ButtonAction.super.ctor(self, "ButtonAction")
    self.listeners = {}
    self.handle = 0
    self.tag    = 0
end

--[
-- @brief  绑定组件
-- @param  void
-- @return void
--]
function ButtonAction:onBind_()
    self.originScale = self.target_:getScaleX()
    -- self:setClickMute(false)
    -- self.target_:setTouchEnabled(true)
    -- self.target_:setTouchSwallowEnabled(true) -- 当不吞噬事件时，触摸事件会从上层对象往下层对象传递，称为“穿透”
    -- self.target_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouchEvent))


    self.target_:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE) -- 单点触摸
    self.target_:setTouchEnabled(true)
    self.target_:setTouchCaptureEnabled(true)
    self.target_:setTouchSwallowEnabled(true)

    -- 添加触摸事件处理函数
    self.target_:addTouchEventListener(handler(self, self.onTouchEvent))
end

--[
-- @brief  触摸事件处理
-- @param  void
-- @return void
--]
function ButtonAction:onTouchEvent(sender, event)
    local _, act
    -- 开始
    if event == ccui.TouchEventType.began then
        act = cca.scaleTo(kTime, kTouchScaled*self.originScale)
        self.target_:runAction(act)
        return true
    -- 结束
    elseif event == ccui.TouchEventType.ended then
        _, act =
            cca.builder "seq"
                :cb(function()
                    -- 动画期间禁用各种点击
                    self.target_:getEventDispatcher():setEnabled(false)
                end)
                :scaleTo(kTime/2, kNormalScaled*self.originScale)
                :cb(function()
                    self.target_:getEventDispatcher():setEnabled(true)

                    table.walk(clone(self.listeners), function(listener)
                        listener(event, self.tag, self.target_)
                    end)
                end)
            :done()
            -- self.target_:runAction(act)
    -- 取消
    elseif event == ccui.TouchEventType.canceled then
        act = cca.scaleTo(kTime/2, kNormalScaled*self.originScale)
        -- self.target_:runAction(act)
    else
        return
    end
    self.target_:stopActionByTag(kActionTag)
    act:setTag(kActionTag)
    self.target_:runAction(act)
end

--[[
-- @brief  设置标志函数
-- @param  void
-- @return void
--]]
function ButtonAction:setButtonTag(tag)
    self.tag = tag
end

--[[
-- @brief  获取标志函数
-- @param  void
-- @return void
--]]
function ButtonAction:getButtonTag()
   return self.tag 
end

--[
-- @brief  解绑
-- @param  void
-- @return void
--]
function ButtonAction:onUnbind_()
end

--[[
-- @brief  移除点击回调
-- @param  handle
-- @return void
--]]
function ButtonAction:removeClickEventListener(handle)
    self.listeners[handle] = nil
end

--[[
-- @brief  添加点击回调
-- @param  cb
-- @return void
--]]
function ButtonAction:onClicked(cb)
    -- local handle = self.target_.newHandle()
    self.handle = self.handle + 1
    self.listeners[self.handle] = cb
    return self.target_, self.handle
end
--[[
-- @brief  使能按钮
-- @param  cb
-- @return void
--]]
function ButtonAction:setClickEnabled(b)
    self.target_:setTouchEnabled(b)

    if b then
        self.target_:setColor(cc.c3b(255, 255, 255))
    else
        self.target_:setColor(cc.c3b(127, 127, 127))
    end
    return self.target_
end

--[[
-- @brief  设置点击静音
-- @param  value
-- @return self
--]]
function ButtonAction:setClickMute(value)
    if not value then
        self.target_:bind_("SoundableButton")
    else
        self.target_:unbind_("SoundableButton")
    end
    return self.target_
end

--[
-- @brief  导出函数
-- @param  void
-- @return void
--]
function ButtonAction:exportMethods()
    self:exportMethods_({
        "onClicked",
        "removeClickEventListener",
        "setClickEnabled",
        "setButtonTag",
        -- "setClickMute",
    })
    return self.target_
end

return ButtonAction

