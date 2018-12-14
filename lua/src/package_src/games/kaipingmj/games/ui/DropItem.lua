--
-- Author: Van
-- Date: 2017-06-27 16:07:22
--
local DropItem = class("DropItem", function() 
    local ret = display.newNode()
    return ret
end)

local commonColor=cc.c3b(43,76,1)
local selectColor=cc.c3b(255,0,0)


function DropItem:ctor(data)
  
    data = {
        title="",
        radios      = {"",},  -- 未选中情况下的文字
        index           = 1, -- 序号
        callback        = nil, -- 选中时的回调
        clickback=nil,
        zorder=1
    }
  
    -- dump(data)


    -- dump(_gameType)
    self.m_data = data or {}
    self.m_data.index=self.m_data.index or 1

    local x=0
    if self.m_data.title then
        local title=ccui.Text:create()
        title:setString(self.m_data.title)
        title:setFontSize(30)
        title:setColor(cc.c3b(43,76,1))
        title:setFontName("hall/font/fangzhengcuyuan.ttf")
        title:addTo(self)
        x=title:getContentSize().width+20
        title:setPosition(title:getContentSize().width/2, 30)
    end

    -- 载入UI
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("package_res/games/kaipingmj/friendRoom/down_item.csb")
    self.m_pWidget:addTo(self)
    self.m_pWidget:setPositionX(x)
    dump(self.m_pWidget:getContentSize())

    self.list_select=ccui.Helper:seekWidgetByName(self.m_pWidget, "list_select")
    self.img_arrow = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_arrow")

    self.btn_defult = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_defult")
    self.btn_defult:setTitleText(data.radios[self.m_data.index])
    self.btn_defult:setTitleFontName("hall/font/fangzhengcuyuan.ttf")
    self.btn_defult:setTitleColor(selectColor)
    -- self.m_text = ccui.Helper:seekWidgetByName(self.m_pWidget, "text")
    -- self.m_text:setString(self.m_data.textNormal)

    self:setSelectIndex(self.m_data.index,true)
    -- self:setSelected(false)


    

    self.btn_defult:addTouchEventListener(function(pWidget,EventType)
        if EventType == ccui.TouchEventType.ended then
    	   self.list_select:setVisible(not  self.list_select:isVisible())
           if self.m_data.clickback then  self.m_data.clickback(self) end

            self.img_arrow:setRotation(self.list_select:isVisible() and 0 or 180)

        end
    end)

    self:initList(self.m_data.radios)

    self:setContentSize(cc.size(x+self.m_pWidget:getContentSize().width,self.m_pWidget:getContentSize().height))
    self:setLocalZOrder(self.m_data.zorder or 1)


    if data.line then
        local line=display.newSprite("hall/Common/line2.png")
        line:setScaleX(100)
        line:setAnchorPoint(cc.p(0,0))
        line:addTo(self,-1)
    end
end

function DropItem:initList(datas)
	for k,v in pairs(datas) do
		local item=ccui.Text:create()
	    -- item:loadTextureNormal("package_res/games/kaipingmj/friendRoom/button.png")
        item:setString(v)
        item:setFontSize(24)
        item:setFontName("hall/font/fangzhengcuyuan.ttf")
        item:setTextAreaSize(cc.size(200,50))
        -- if v == self.btn_defult:getTitleText() then
        --     item:setTitleColor(selectColor)
        -- else
        -- item:setColor(cc.c3b(11,14,14))
        item:setColor(commonColor)
        item:setTouchEnabled(true)

        if k~=#datas then
            local line=display.newSprite("hall/main/linellae.png")
            line:setPositionX(100)
            line:setScale(0.2,1.2)
            item:addChild(line)
        end
        -- item:setTouchScaleChangeEnabled(true)
        -- end
        -- item:setContentSize(self.btn_defult:getContentSize())
	    -- item:setPosition(cc.p(panelSize.width - clickSize.width / 2 - 30, panelSize.height / 2))
	    -- item:addTo( self.list_select)
	    item:addTouchEventListener(function(pWidget,EventType)
            if EventType == ccui.TouchEventType.ended then
	    	  self:setSelectIndex(k)
              if self.m_data.clickback then self.m_data.clickback() end
            end
	    end)
	    self.list_select:pushBackCustomItem(item)
	    -- item:addTouchEventListener(handler(self, self.onClickedExit))
	    -- item:setOpacity(kOpacity)
	end
end

function DropItem:setSelectIndex(index,isNotCall)
	self.m_data.index=index
	self.btn_defult:setTitleText(self.m_data.radios[self.m_data.index])
    self.btn_defult:setTitleColor(selectColor)
	self.list_select:setVisible(false)
	if self.m_data.callback and not isNotCall then self.m_data.callback(index) end
    self.img_arrow:setRotation(self.list_select:isVisible() and 0 or 180)
end

function DropItem:hideList()
   self.list_select:setVisible(false)
   self.img_arrow:setRotation(self.list_select:isVisible() and 0 or 180)
end

function DropItem:setTitleColorNormal()
     self.btn_defult:setTitleColor(commonColor)
end

return DropItem