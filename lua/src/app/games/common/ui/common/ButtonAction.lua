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
local kActModeTouch = 0
local kActModeNormal = 1

-- 示例：
--     local action = self:createTouchableSprite({
--             image = "games/common/mj/games/game_btn_gang.png",
--             size = cc.size(100, 100),
--             label = "TOUCH ME !",
--             labelColor = cc.c3b(255, 0, 0)})
--         :pos(200, 200)
--         :addTo(layer)
--     cc(action):addComponent(Define.enComponentName.BUTTON_ACTION):exportMethods()
--     action:onClicked(handler(self, MjMediator.onBtnGang))

--     local action = cc.ui.UIImage.new("games/common/mj/games/game_btn_gang.png")
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
    Log.i("self.originScale........",self.originScale)
    self.touchBeginBox = nil
    self.scaleActMode = kActModeNormal
    -- self:setClickMute(false)
    self.target_:setTouchEnabled(true)
    self.target_:setTouchSwallowEnabled(true) 
    self.target_:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)-- 当不吞噬事件时，触摸事件会从上层对象往下层对象传递，称为“穿透”
    self.target_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouchEvent))
    
end

--[
-- @brief  触摸事件处理
-- @param  void
-- @return void
--]

function ButtonAction:customHitTest(point, isCascade, customRect)
    -- local nsp = self.target_:convertToNodeSpace(point)
    local rect = customRect
    if rect == nil then
        if isCascade then
            rect = self.target_:getCascadeBoundingBox()
        else
            rect = self.target_:getBoundingBox()
        end
    end
    -- rect.x = 0
    -- rect.y = 0
    if cc.rectContainsPoint(rect, point) then
        return true
    end
    return false
end

function ButtonAction:onTouchEvent(event)
     -- print(" action = "..event.name)
    local _, act
    if event.name == "began" then
        self.originScale = self.target_:getScaleX()
        self.touchBeginBox = self.target_:getCascadeBoundingBox() -- 使用getCascadeBoundingBox代替getBoundingBox, 可以获取更准确的x, y
        -- local size = self.target_:getContentSize()
        -- self.touchBeginBox.height = size.height -- 但getCascadeBoundingBox获取的高宽不准确
        -- self.touchBeginBox.width = size.width
        act = cca.scaleTo(kTime, kTouchScaled*self.originScale)
        self.scaleActMode = kActModeTouch
        -- print("began")
        self.target_:runAction(act)
        return true
    elseif event.name == "ended" then
        self.target_:stopAllActions()
        local hitTest = false
        if self.touchBeginBox == nil then
            hitTest = self.target_:hitTest(cc.p(event.x, event.y))
        else
            hitTest = self:customHitTest(cc.p(event.x, event.y), false, self.touchBeginBox)
        end
        self.touchBeginBox = nil
        if hitTest then
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
                            listener(event, self.tag)
                        end)
                    end)
                :done()
                -- print("ended")
        else
           act = cca.scaleTo(kTime/2, kNormalScaled*self.originScale)
           -- print("cancelled")
        end
        self.target_:runAction(act)
    elseif event.name == "moved" then
        local hitTest = false
        if self.touchBeginBox == nil then
            hitTest = self.target_:hitTest(cc.p(event.x, event.y))
        else
            hitTest = self:customHitTest(cc.p(event.x, event.y), false, self.touchBeginBox)
        end
        if hitTest then
            if self.scaleActMode ~= kActModeTouch then
                self.scaleActMode = kActModeTouch
                act = cca.scaleTo(kTime/4, kTouchScaled*self.originScale)
                self.target_:runAction(act)
                self.target_:stopActionByTag(kActionTag)
                act:setTag(kActionTag)
            end
        else
            if self.scaleActMode ~= kActModeNormal then
                self.scaleActMode = kActModeNormal
                act = cca.scaleTo(kTime/4, kNormalScaled*self.originScale)
                self.target_:runAction(act)
                self.target_:stopActionByTag(kActionTag)
                act:setTag(kActionTag)
            end
        end
        return
    elseif event.name == "cancelled" then
        self.touchBeginBox = nil
        act = cca.scaleTo(kTime/2, kNormalScaled*self.originScale)
    else
        return
    end
    self.target_:stopActionByTag(kActionTag)
    if act then act:setTag(kActionTag) end
end

--[[
-- @brief  设置标志函数
-- @param  void
-- @return void
--]]
function ButtonAction:setButtonTag(tag)
    self.tag = tag
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

