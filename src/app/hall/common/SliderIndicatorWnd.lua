--[[--
滑动指示灯控件
]]

SliderIndicatorWnd = class("SliderIndicatorWnd", function()
	local node = ccui.Layout:create()
	--node:setContentSize(display.width, display.height)
	local lp3 = ccui.LinearLayoutParameter:create()
    node:setLayoutParameter(lp3)
    lp3:setGravity(ccui.LinearGravity.centerHorizontal)
    lp3:setMargin({ left = 0, top = 10, right = 0, bottom  = 10 } )
	return node
end)

--------------------------------
-- SliderIndicatorWnd
-- @function [parent=#SliderIndicatorWnd] new
-- @param table params 参数表
function SliderIndicatorWnd:ctor(params)
    Log.i("......................SliderIndicatorWnd param",params)
	self.m_radius =50 ;  
	self.m_num =0;
	Log.i("SliderIndicatorWnd init finish")
end

function SliderIndicatorWnd:dtor()
   Log.i("SliderIndicatorWnd:dtor()")
end

function SliderIndicatorWnd:addIndicator(num) 

    self.m_num = self.m_num +num;
	
   	local nodeSize =18;
	local dis=10;
	local xw = self.m_num*nodeSize+(self.m_num-1)*dis;
	self:setContentSize(cc.size(xw,50));
	
    --test color layer.
	--self.content = cc.LayerColor:create(
    --       cc.c4b(125,0,125,250))
    --self.content:setContentSize(self:getContentSize())
    --self.content:addTo(self)
	
	
    local param ={}
	param.uiType=1;

    for i=1,num do
        local indicator = SliderIndicatorSprite.new(param);  
        --indicator:setContentSize(cc.size(self.m_radius, self.m_radius));  
        --indicator:setCircleColor(Color4B(255, 40, 255, 255));  
        indicator:setTag(i);
        indicator:setAnchorPoint(cc.p(0.5,0.5));		
        self:addChild(indicator);
		
		indicator:setPosition(cc.p((i-1)*nodeSize+(i-1)*dis,0));
    end
	
    self:changeIndicator(1);  
end  
  
function SliderIndicatorWnd:changeIndicator(index)  

    for i=1,self.m_num do 
        local indicator = self:getChildByTag(i); 
        indicator:sliderIndicatorOff();  
        if i == index then 
           indicator:sliderIndicatorOn();  
        end   
    end  
end 