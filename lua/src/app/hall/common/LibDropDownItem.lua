--[[
    �����۵��˵���
--]]
LibDropDownItem = class("LibDropDownItem", function ()
	return cc.Layer:create()--cc.LayerColor:create(cc.c4b(255, 0, 0,255));
end)
-- ����
function LibDropDownItem:ctor(...)
    self:init()
end

-- ��ʼ��
function LibDropDownItem:init( )
  
end

-- ����
function LibDropDownItem:dtor( )

end

function LibDropDownItem:showUI(tmpData)
   
end

function LibDropDownItem:onTouchBegan(touch, event)
    local location = touch:getLocation()
	self.m_beginPos = location 
	return true
end

function LibDropDownItem:onTouchMoved(touch, event)
--[[
    local location = touch:getLocation()
	local tmpBox = self:getBoundingBox()
	--local rect = cc.rect(rc.x, rc.y, rc.width, rc.height)
	local nsp = self:convertToNodeSpace(location)
	local isHit =cc.rectContainsPoint(tmpBox, nsp)

	if(isHit) then
	   Log.i("hit")
	   
	   self.m_data.movecallBackFun(self.m_data)
	  
	   return false
	else
	   Log.i("not hit")
	end]]
end

function LibDropDownItem:onTouchEnded(touch, event)
  	local location = touch:getLocation()
	--�Ƿ����ƶ��¼�
    local dis = cc.pGetDistance(location,self.m_beginPos)
    if(dis>=6) then
      return
    end

	local tmpBox = self:getBoundingBox()
	--local rect = cc.rect(rc.x, rc.y, rc.width, rc.height)
	local nsp = self:convertToNodeSpace(location)
	local isHit =cc.rectContainsPoint(tmpBox, nsp)

	if(isHit) then
	   Log.i("hit")
	   
	   self.m_data.callBackFun(self.m_data)
	  
	   return false
	else
	   Log.i("not hit")
	end
end

--ע�ᴥ���¼�
function LibDropDownItem:regTouchEvent(size,data)

    self.m_data= data
	
	self:setContentSize(size)
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(true)
	
	local touchBeginPoint = nil
   
	local function onTouchBegan(touch, event)
		local location = touch:getLocation()
	   --Log.i("onTouchBegan: %0.2f, %0.2f", location.x, location.y)
		return self:onTouchBegan(touch, event)
	end

	local function onTouchMoved(touch, event)
		local location = touch:getLocation()
		--Log.i("onTouchMoved: %0.2f, %0.2f", location.x, location.y)
		self:onTouchMoved(touch, event)
	end

	local function onTouchEnded(touch, event)
		local location = touch:getLocation()
		--Log.i("onTouchEnded: %0.2f, %0.2f", location.x, location.y)
		self:onTouchEnded(touch, event)
	end

	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	self.listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
	self.listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
	local eventDispatcher =  cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(self.listener,self)
	
end
