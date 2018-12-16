-----------------------------------------------------------
--  @file   TopTip.lua
--  @brief  顶部提示弹框
--  @author zhousiyu
--  @DateTime:2018-03-30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2018
-- ============================================================

--[[ 测试用代码
    local TopTip = require("app.hall.wnds.tipDialog.TopTip")
    local data = {countdown = 30}
    TopTip:getInstance():show(data)
    do return end
--]]

local TopTip = class("TopTip")

local _instance = nil
local _widget = nil
local _manualClose = false -- 是否可以手动关闭
local _closing = false -- 是否正在关闭中

TopTip.BgCfg = {
    png = "hall/Common/tipDialog/bg_top_tip.png",
    startX = 20,
    startY = 20,
    size = cc.size(690, 168),
}

TopTip.timeCfg = {
    show = 0.5,
    stay = 10,
    hide = 0.5,
}

function TopTip:getInstance()
    if not _instance then
        _instance = TopTip.new()
    end
    return _instance
end

function TopTip:releaseInstance()
    _instance = nil
end

function TopTip:show(data)
    Log.i("data", data)
    self.m_data = data
    self.m_data.countdown = self.m_data.countdown or 1
    self.m_data.title = self.m_data.title or "温馨提示"
    self.m_data.content = self.m_data.content or "服务器将于%s分钟后进行维护！请及时下线避免不必要的损失！"
    _closing = false
    self:createTip()
    local action = cc.Sequence:create(
        self:createShowAction(),
        self:createStayAction(),
        self:createHideAction()
    )
    _widget:runAction(action)
end

function TopTip:createTip()
    self:removeTip()
    _widget = display.newScale9Sprite(TopTip.BgCfg.png, TopTip.BgCfg.startX, TopTip.BgCfg.startY, TopTip.BgCfg.size)
    _widget:setAnchorPoint(cc.p(0.5, 0))
    _widget:setPosition(cc.p(display.cx, display.height))
    _widget:addTo(cc.Director:getInstance():getRunningScene(), UIManager.ZOrderOnScene.TopTip)
    self:regTouchEvent()

    local cautionImg = display.newSprite("hall/Common/tipDialog/img_caution.png")
    cautionImg:addTo(_widget)
    cautionImg:setPosition(cc.p(39, 129))

    local cautionTitle = cc.Label:createWithTTF(self.m_data.title, "hall/font/fangzhengcuyuan.TTF", 27)
    cautionTitle:setColor(cc.c3b(0x06, 0x00, 0x00))
    cautionTitle:addTo(_widget)
    cautionTitle:setPosition(cc.p(123, 129))


    local cautionStr = string.format(self.m_data.content, self.m_data.countdown)
    local cautionContent = cc.Label:createWithTTF(cautionStr, "hall/font/fangzhengcuyuan.TTF", 30)
    cautionContent:setWidth(634)
    cautionContent:setColor(cc.c3b(0x06, 0x00, 0x00))
    cautionContent:addTo(_widget)
    cautionContent:setPosition(cc.p(TopTip.BgCfg.size.width * 0.5, 60))
end

function TopTip:getTip()
    return _widget
end

function TopTip:removeTip()
    if _widget then
        _widget:removeFromParent()
        _widget = nil
    end
end

function TopTip:regTouchEvent()
    -- handing touch events
    local touchBeginPoint = nil
    local firstTouched = false
    local function onTouchBegan(touch, event)
        if not _manualClose then return false end -- 只有等待的展示状态才可触摸
        local location = touch:getLocation()
        touchBeginPoint = location
        return self:customHitTest(location)
    end

    local function onTouchMoved(touch, event)
        if not _manualClose then return end
        local location = touch:getLocation()
        if self:moveTest(location, touchBeginPoint) then
            _widget:stopAllActions()
            _widget:runAction(self:createHideAction())
        end
    end

    local function onTouchEnded(touch, event)
        if not _manualClose then return end
        local location = touch:getLocation()
        if self:customHitTest(location) then
            if not firstTouched then
                firstTouched = true
            else
                _widget:stopAllActions()
                _widget:runAction(self:createHideAction())
            end
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher =  cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, _widget)
end

function TopTip:createShowAction()
    local action = cc.Sequence:create(
        cc.MoveBy:create(TopTip.timeCfg.show, cc.p(0, - TopTip.BgCfg.size.height))
    )
    return action
end

function TopTip:createStayAction()
    local action = cc.Sequence:create(
        cc.CallFunc:create(function ()
            _manualClose = true
        end),
        cc.DelayTime:create(TopTip.timeCfg.stay),
        cc.CallFunc:create(function ()
            _manualClose = false
        end)
    )
    return action
end

function TopTip:createHideAction()
    -- local hideTime = TopTip.timeCfg.hide * (display.height - _widget:getPositionY()) / TopTip.BgCfg.size.height -- 现在只有停留状态可以缩回, 所以不需要计算时间了
    local action = cc.Sequence:create(
        cc.CallFunc:create(function ()
            _manualClose = false
            _closing = true
        end),
        cc.MoveTo:create(TopTip.timeCfg.hide, cc.p(display.cx, display.height)),
        cc.CallFunc:create(function ()
            self:removeTip()
        end)
    )
    return action
end

-- 检测点击是否包含在控件内
function TopTip:customHitTest(point)
    local rect = _widget:getBoundingBox()
    return cc.rectContainsPoint(rect, point)
end

-- 检测是否符合滑动关闭的逻辑
function TopTip:moveTest(nowLocation, preLocation)
    local absOffX = math.abs(nowLocation.x - preLocation.x)
    local offY = nowLocation.y - preLocation.y
    local absOffY = math.abs(offY)
    -- Log.i(absOffX, offY, absOffY)
    return (offY > 20 and absOffY > absOffX)
end

-- 重新设置对话框位置
function TopTip:resetPositionAndParent(nextScene)
    if _closing then
        self:removeTip()
    else
        _widget:removeFromParent(false)
        _widget:addTo(nextScene, UIManager.ZOrderOnScene.TopTip)
        _widget:stopAllActions()
        _widget:setPosition(cc.p(display.cx, display.height- TopTip.BgCfg.size.height))
        local action = cc.Sequence:create(
            self:createStayAction(),
            self:createHideAction()
        )
        _widget:runAction(action)
    end
end

return TopTip