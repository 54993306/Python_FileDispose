--[[----------------------------------------
-- 作者： 林先成
-- 日期： 2018-01-18
-- 摘要： 对UIPageView做拓展和修改
]]-------------------------------------------

local UIPageView = import("app.framework.cc.ui.UIPageView")

local PageViewWnd = class("PageViewWnd", UIPageView)

function PageViewWnd:ctor(params)
	PageViewWnd.super.ctor(self, params)
	if not IsPortrait then -- TODO
		self.bCirc = true --params.bCirc or false
		self.m_isMove = false
		self:setTouchEnabled(true)
	end
end

function PageViewWnd:dtor()
    Log.i("PageViewWnd:dtor()")
end

-- 功能:       判断当前是否为移动状态
-- 返回:       无
function PageViewWnd:getIsMove()
    return self.m_isMove
end

-- 功能:       重写回调函数
-- 返回:       无
function PageViewWnd:onTouch_(event)
	if "began" == event.name
		and not self:isTouchInViewRect_(event) then
		printInfo("PageViewWnd - touch didn't in viewRect")
		return false
	end

	if "began" == event.name then
		self:stopAllTransition()
		self.bDrag_ = false
		self.m_isMove = true
		self:notifyListener_{name="touchBegan"}
	elseif "moved" == event.name then
		self.speed = event.x - event.prevX
		if(math.abs(self.speed)>5)then   -- 小于5像素不做位移处理
			self.bDrag_ = true  
			self:scroll(self.speed)
			self.m_isMove = true
			self:notifyListener_{name="touchMoved"}
		end
	elseif "ended" == event.name then
		if self.bDrag_ then
			self:scrollAuto()
		else
			self:resetPages_()
			self:onClick_(event)
		end
		self.m_isMove=false
		self:notifyListener_{name="touchEnded"}
	end

	return true
end

return PageViewWnd
