--
-- Author: Van
-- Date: 2017-06-27 16:07:22
--
local SelectRadioBtn = require("app.hall.common.SelectRadioBtn")
local DropItem = class("DropItem", function() 
    local ret = ccui.Layout:create()
    return ret
end)

local commonColor=G_ROOM_INFO_FORMAT.normalDropFontColor--cc.c3b(43,76,1)
local selectColor=G_ROOM_INFO_FORMAT.selectColor--cc.c3b(255,0,0)
local disbaleColor=cc.c3b(160,160,160)

-- 按钮的透明度
-- local kOpacity = {
--     disabled = 0.5 * 255,   -- 被禁用
--     normal = 255,           -- 正常状态
--     hidden = 0,             -- 隐藏状态
-- }

function DropItem:ctor(data)
    --[[
    data = {
        title="",
        radios      = {"",},  -- 未选中情况下的文字
        index           = 1, -- 序号
        callback        = nil, -- 选中选项时的回调
        clickback=nil, --点击按钮回调
        zorder=1,
        width=100, --调整条目的宽
    }
    ]]
    -- dump(data)


    -- dump(_gameType)
    self.m_data = data or {}
    self.m_data.index=data.index or 1

    if IsPortrait then -- TODO
        self.m_data.width=data.width or G_ROOM_INFO_FORMAT.dropDwonBoxSize.width
    end
    -- dump(data)
    -- dump(self.m_data)

    local x=0
    if self.m_data.title then
        local title=ccui.Text:create()
        title:setString(self.m_data.title)
        title:setFontName("hall/font/fangzhengcuyuan.TTF")
        title:addTo(self)
        if IsPortrait then -- TODO
            title:setFontSize(G_ROOM_INFO_FORMAT.titleFontSize)
            title:setColor(G_ROOM_INFO_FORMAT.titleFontColor)
            x=title:getContentSize().width+20
            title:setPosition(title:getContentSize().width/2+G_ROOM_INFO_FORMAT.titlePosX, G_ROOM_INFO_FORMAT.lineHeight/2)
        else
            title:setFontSize(28)
            title:setColor(G_ROOM_INFO_FORMAT.normalColor)
            title:setAnchorPoint(cc.p(0, 0.5))
            x=G_ROOM_INFO_FORMAT.titlePosX+title:getContentSize().width
            title:setPosition(G_ROOM_INFO_FORMAT.titlePosX,30)--title:getContentSize().width/2+5, 30)
        end
    end

    if self.m_data.initX then
        x=x+self.m_data.initX
    end

    -- 载入UI
    self.m_pWidget = CSBManager.getInstance():getCSBFile("games/common/game/down_item.csb")--ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/down_item.csb")
    self.m_pWidget:addTo(self)
    self.m_pWidget:setPositionX(x)

    self.list_select=ccui.Helper:seekWidgetByName(self.m_pWidget, "list_select")
    self.img_arrow = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_arrow")

    self.btn_defult = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_defult")
    self.btn_defult:setTitleText(data.radios[self.m_data.index] .. "　")
    self.btn_defult:setTitleFontName("hall/font/fangzhengcuyuan.TTF")
    self.btn_defult:setTitleColor(selectColor)

    if IsPortrait then -- TODO
        self.btn_defult:setTitleFontSize(G_ROOM_INFO_FORMAT.fontSize)
        self.btn_defult:setContentSize(cc.size(G_ROOM_INFO_FORMAT.dropDwonBoxSize.width,G_ROOM_INFO_FORMAT.dropDwonBoxSize.height + 9))
    end
    -- self.m_text = ccui.Helper:seekWidgetByName(self.m_pWidget, "text")
    -- self.m_text:setString(self.m_data.textNormal)

    self:setSelectIndex(self.m_data.index,true)

    local listSize=self.list_select:getContentSize()
    if #self.m_data.radios<=4 then
        self.list_select:setContentSize(cc.size(self.m_data.width or listSize.width,#self.m_data.radios*50))
    else
        self.list_select:setContentSize(cc.size(self.m_data.width or listSize.width,listSize.height+25))
    end

    if self.m_data.width then
        if IsPortrait then -- TODO
            self.m_pWidget:setContentSize(cc.size(self.m_data.width,G_ROOM_INFO_FORMAT.lineHeight))
        else
            self.m_pWidget:setContentSize(cc.size(self.m_data.width,60))
        end
        local btnSize=self.btn_defult:getContentSize()
        self.btn_defult:setContentSize(cc.size(self.m_data.width,btnSize.height))
    end

    

    self.btn_defult:addTouchEventListener(function(pWidget,EventType)
        if EventType == ccui.TouchEventType.ended then
           self.list_select:setVisible(not  self.list_select:isVisible())
           if self.m_data.clickback then  self.m_data.clickback(self) end

           self.img_arrow:setScaleY(self.list_select:isVisible() and 1 or -1)

        end
    end)

    self:initList(self.m_data.radios)

    self:setContentSize(cc.size(x+self.m_pWidget:getContentSize().width,self.m_pWidget:getContentSize().height))
    self:setLocalZOrder(self.m_data.zorder or 1)


    if data.line then
        local line=display.newSprite("hall/Common/line2.png")
        line:setScaleX(1000)
        line:setAnchorPoint(cc.p(0,0))
        line:addTo(self,-1)
    end
    ccui.Helper:doLayout(self.m_pWidget)
end

function DropItem:initList(datas)
    for k,v in pairs(datas) do
        local item=ccui.Text:create()
        item:setSwallowTouches(false)
        item:setString(v)
        if IsPortrait then -- TODO
            item:setFontSize(G_ROOM_INFO_FORMAT.fontSize)
        else
            item:setFontSize(24)
        end
        item:setFontName("hall/font/fangzhengcuyuan.TTF")
        item:setTextAreaSize(cc.size(self.m_data.width or 200,50))
      
        item:setColor(commonColor)
        item:setTouchEnabled(true)

        if k~=#datas then
            local line=display.newSprite("hall/main/linellae.png")
            line:setPositionX(item:getContentSize().width/2)
            if IsPortrait then -- TODO
                line:setScale(0.2*(item:getContentSize().width/200),1.4)
            else
                line:setScale(0.2*(item:getContentSize().width/200),1.3)
            end
            item:addChild(line)
        end

        item:addTouchEventListener(function(pWidget,EventType)
            if EventType == ccui.TouchEventType.ended then
              self:setSelectIndex(k)
              if self.m_data.clickback then self.m_data.clickback() end
            end
        end)
        self.list_select:pushBackCustomItem(item)
    end
end

function DropItem:setSelectIndex(index,isNotCall)
	self.m_data.index=index or self.m_data.index
    self.btn_defult:setTitleText(self.m_data.radios[self.m_data.index].."    ")
    self.btn_defult:setTitleColor(selectColor)
    self.list_select:setVisible(false)
    if self.m_data.callback  then self.m_data.callback(self.m_data.index) end --and not isNotCall
    self.img_arrow:setScaleY(self.list_select:isVisible() and 1 or -1)
    --self.img_arrow:setRotation(self.list_select:isVisible() and 0 or 180)
end

function DropItem:hideList()
    self.list_select:setVisible(false)
    self.img_arrow:setScaleY(self.list_select:isVisible() and 1 or -1)
    --self.img_arrow:setRotation(self.list_select:isVisible() and 0 or 180)
end

function DropItem:setTitleColorNormal()
    if IsPortrait then -- TODO
        self.btn_defult:setTitleColor(G_ROOM_INFO_FORMAT.normalColor)
    else
        self.btn_defult:setTitleColor(commonColor)
    end
end

function DropItem:setEnabled(b)
    if b then
        self.btn_defult:setTitleColor(selectColor)
        self.img_arrow:setColor(cc.c3b(255,255,255))
        self:setSelectIndex()
    else
        self.btn_defult:setTitleColor(disbaleColor)
        self.img_arrow:setColor(disbaleColor)
        self:hideList()
    end
    self.btn_defult:setEnabled(b)
end

function DropItem:refreshRadios(radios,index)
    self.m_data.index=1
    self.list_select:removeAllChildren()
    self:initList(radios)
    self:setSelectIndex(index)

    local listSize=self.list_select:getContentSize()
    if #radios<=4 then
        self.list_select:setContentSize(cc.size(self.m_data.width or listSize.width,#radios*50))
    else
        self.list_select:setContentSize(cc.size(self.m_data.width or listSize.width,225))
    end
    self:setContentSize(cc.size(self:getContentSize().width,self.m_pWidget:getContentSize().height))
    -- ccui.Helper:doLayout(self.m_pWidget)
end

function DropItem:getCurIndex()
    return  self.m_data.index
end

return DropItem
