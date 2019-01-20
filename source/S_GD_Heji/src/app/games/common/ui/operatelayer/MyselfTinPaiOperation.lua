-------------------------------------------------------------
--  @brief  听牌操作显示节点ui
--============================================================
local MyselfTinPaiOperation = class("MyselfTinPaiOperation", function ()
	local ret = display.newNode()
	
	ret.m_pwidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/tingPaiOperationNode.csb")
    ret.m_pwidget:addTo(ret)
	
    return ret
end)

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function MyselfTinPaiOperation:ctor(context)
	
end

--更新麻将牌值(通过精灵缓存加载)
function MyselfTinPaiOperation:createMjValueImage(param)
  
    local midPanel = ccui.Helper:seekWidgetByName(self.m_pwidget,"midPanel")
    local pai_panel    = ccui.Helper:seekWidgetByName(self.m_pwidget,"pai_panel")
	local scrollView    = ccui.Helper:seekWidgetByName(self.m_pwidget,"scrollView")
	local img_1  = ccui.Helper:seekWidgetByName(self.m_pwidget,"img_1") --胡图片
	--计算大小
	local colMaxNum=6;
	local num =#param;
	local col = 1
    local row = 1
	if(num>=colMaxNum)then
	   col=colMaxNum
	else
	   col = num
	end
	
	row = math.ceil(num / col)
	Log.i("行" .. row .."列" .. col);
	
    local szItem =  pai_panel:getContentSize()--项大小
    local spaceX = 5
    local spaceY = 5
    szItem.width = szItem.width + spaceX
    szItem.height = szItem.height + spaceY
	--
    local szCont = cc.size(0, 0)
    szCont.height = szItem.height * row
	szCont.width = szItem.width * col

    self:setContentSize(cc.size(szCont.width+125,szCont.height+50));
	midPanel:setContentSize(cc.size(szCont.width+125,szCont.height+45)) 
	scrollView:setContentSize(cc.size(szCont.width,szCont.height-10))
	
	--设置胡的位置
	local posX = img_1:getPositionX();
	img_1:setPosition(cc.p(posX,szCont.height));
	
	local function scrollFunc(data,mWight,nIndex,from)
		local img = ccui.Helper:seekWidgetByName(mWight,"paiValue")
		local label_1 = ccui.Helper:seekWidgetByName(mWight,"label_1") --还有多少张
		local label_2 = ccui.Helper:seekWidgetByName(mWight,"label_2") --还有多少番
		label_2:setFontName("res_TTF/1016001.TTF")
		local cardPng = getCardPngByValue(data.value)
		--牌值
		img:loadTexture(cardPng, ccui.TextureResType.plistType);
        --还剩多少张牌
		label_1:setString(data.text)
		label_1:setFontName("res_TTF/1016001.TTF")
		
		if(data.fang==nil) then --没有多少番
		  label_2:setVisible(false);
		end
	end
	self.scrollViewUI = new_cScrollView(scrollView,pai_panel,param,scrollFunc,5,6)
end



--[[
设置位置
function MyselfTinPaiOperation:changPostion(x,y)
   self:setAnchorPoint(cc.p(0.5,0));
  --local halfWidth = self:getContentSize().width*0.5;
  --Log.i("窗口大小"..halfWidth)
  self:setPosition(cc.p(1280/2,y));
  -- elseif(x+halfWidth>display.width) then
      --self:setPosition(cc.p(display.width-halfWidth,y));
  -- else
      --self:setPosition(cc.p(x,y))
  -- end
end

--添加到父节点
function MyselfTinPaiOperation:addToParent(parent,x,y)
   local s  = display.getRunningScene()
   self:addTo(parent)
   local p = self:getParent():convertToWorldSpace(cc.p(x,y));
   self:changPostion(p.x,p.y)
end
]]

return MyselfTinPaiOperation
