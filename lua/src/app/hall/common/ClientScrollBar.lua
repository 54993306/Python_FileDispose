--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local director = cc.Director:getInstance()
local scheduler = director:getScheduler()

ClientScrollBar = class("ClientScrollBar")

--local data = {
--    parent = nil;                   --父节点
--    bgSprite = "";                  --背景层资源
--    scrollSprite = "";              --滚动块资源
--    bgSize = cc.size(0,0);          --背景大小
--}
function ClientScrollBar:ctor(data)
    self.m_data = data
    self:init()
end

function ClientScrollBar:init()
    self.m_bgSprite = display.newScale9Sprite(self.m_data.bgSprite,0,0,self.m_data.bgSize)
    self.m_bgSprite:addTo(self.m_data.parent)

    self.m_scrollSprite = display.newSprite(self.m_data.scrollSprite)
    self.m_scrollSprite:addTo(self.m_bgSprite)
    local spSize = self.m_scrollSprite:getContentSize()
    local bsSize = self.m_bgSprite:getContentSize()
    self.m_scrollSprite:setPosition(cc.p(spSize.width/2 - bsSize.width/2,spSize.height/2- bsSize.height/2))
    self.orientation = "vertical"
    if self.m_data.bgSize.width>self.m_data.bgSize.height then
        self.orientation = "horizontal"
    end
    if self.orientation == "vertical" then
        self.m_scrollSprite:setPositionY(bsSize.height-spSize.height/2)
    end

end
function ClientScrollBar:setPosition(x,y)
    self.m_bgSprite:setPosition(cc.p(x,y))
end
--总滑动百分比
function ClientScrollBar:setProgress(percent)
    if self.orientation == "vertical" then
        local bsSizeH = self.m_bgSprite:getContentSize().height - self.m_scrollSprite:getContentSize().height/2
        local progress = bsSizeH*percent
        self.m_scrollSprite:setPositionY(bsSizeH -progress )
    else
        local bsSizeW = self.m_bgSprite:getContentSize().width - self.m_scrollSprite:getContentSize().width/2
        local progress = bsSizeW*percent
        self.m_scrollSprite:setPositionX(bsSizeW+progress)
    end
end
--实时更新百分比
function ClientScrollBar:setSlideProgress(percent)
     if self.orientation == "vertical" then
        local progress = self.m_data.bgSize.height*percent
        Log.i("progress........",progress,self.m_scrollSprite:getPositionY())
        self.m_scrollSprite:setPositionY(self.m_scrollSprite:getPositionY()-progress)
    else
        local progress = bgSize.width*percent
        self.m_scrollSprite:setPositionX(self.m_scrollSprite:getPositionX()+progress)
    end
end
return ClientScrollBar


--endregion
