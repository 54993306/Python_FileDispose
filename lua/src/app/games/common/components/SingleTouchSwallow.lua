--region *.lua
--Date
--此文件由[BabeLua]插件自动生成


local Component = cc.Component
local SingleTouchSwallow = class("SingleTouchSwallow", Component)

function SingleTouchSwallow:ctor()
	SingleTouchSwallow.super.ctor(self, "SingleTouchSwallow")
end


function SingleTouchSwallow:regSwallowTouchEvent()
    if self.swallowListener == nil then
        local function onTouchBegan(touch, event)
            Log.i("SwallowTouchEvent begain: ", touch:getId())
            return touch:getId() ~= 0
        end
        self.swallowListener = cc.EventListenerTouchOneByOne:create()
        self.swallowListener:setSwallowTouches(true)
        self.swallowListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	    self.swallowListener:setEnabled(true)

        local eventDispatcher =  cc.Director:getInstance():getEventDispatcher()
        eventDispatcher:addEventListenerWithFixedPriority(self.swallowListener, -1024)
    end
end

function SingleTouchSwallow:releaseSwallowTouchEvent()
    if self.swallowListener ~= nil then
        local eventDispatcher =  cc.Director:getInstance():getEventDispatcher()
        eventDispatcher:removeEventListener(self.swallowListener)
        self.swallowListener = nil
    end
end

function SingleTouchSwallow:onUnbind_()
    self:releaseSwallowTouchEvent()
end

function SingleTouchSwallow:exportMethods()
    self:exportMethods_({
        "regSwallowTouchEvent",
        "releaseSwallowTouchEvent"
    })
    return self.target_
end

return SingleTouchSwallow
--endregion
