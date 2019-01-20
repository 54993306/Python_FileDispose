--[[--
指示灯精灵样式
]]

SliderIndicatorSprite = class("SliderIndicatorSprite", function()
	local node = display.newNode()
	return node
end)

--------------------------------
-- SliderIndicatorSprite
-- @function [parent=#SliderIndicatorSprite] new
-- @param table params 参数表
--params.type == 1 圆形指示灯
function SliderIndicatorSprite:ctor(params)
    
	--test color layer.
	--self.content = cc.LayerColor:create(
    --        cc.c4b(0,0,0,255))
    --self.content:setContentSize(cc.size(40,40))
    --self.content:addTo(self)
	
	self.m_type = params.uiType;
	if(self.m_type == 1)then --
	    local bg = ccui.ImageView:create("real_res/1004383.png");
		self.m_selectImg = ccui.ImageView:create("real_res/1004384.png");
		
		self:addChild(bg);
		self:addChild(self.m_selectImg);
		
		bg:setAnchorPoint(cc.p(0,0));
		self.m_selectImg:setAnchorPoint(cc.p(0,0));
		--Log.i("......................m_noselectImg param",params)
	else
	
	end
end

function SliderIndicatorSprite:dtor()
  -- Log.i("SliderIndicatorSprite:dtor()")
end

--指示灯开。
function SliderIndicatorSprite:sliderIndicatorOn()
    --Log.i("指示灯开");
   	if(self.m_type == 1)then --
	   self.m_selectImg:setVisible(true)
	else
	
	end
end

--指示灯关。
function SliderIndicatorSprite:sliderIndicatorOff()
    --Log.i("指示灯关")
   	if(self.m_type == 1)then --
	   self.m_selectImg:setVisible(false)
	else
	
	end
end