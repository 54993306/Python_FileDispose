--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

NoticeWnd = class("NoticeWnd", UIWndBase)


function NoticeWnd:ctor(info)
    self.super.ctor(self, "hall/hall_notice.csb", info)
end


function NoticeWnd:onInit()
    --local content = kServerInfo:getAdTxt()--"代理招募请加微信：mmmssss11，客服投诉请关注公众号：来来蚌埠麻将。请玩家文明娱乐，远离赌博"--kServerInfo:getAdTxt();
    self.m_pWidget:addTouchEventListener(function(obj,event)
        if event == ccui.TouchEventType.ended then
            UIManager:getInstance():popWnd(NoticeWnd)
        end
    end)
        
    local content = kServerInfo:getContentTxt()
    if content == nil then
        return
    end

    local textSize = 26
    local params = {}
    params.text = content
    params.font = "hall/font/bold.ttf"
    params.size = textSize
    params.x = 0
    params.y = 0
    params.color = cc.c3b(255,209,69)

    local content_label = display.newTTFLabel(params)
    content_label:setAnchorPoint(cc.p(0.5,0.5))
    content_label:setDimensions(0,0)
    content_label:setLineBreakWithoutSpace(true)

    local notice_Image = ccui.Helper:seekWidgetByName(self.m_pWidget,"notice_Image")
    content_label:addTo(notice_Image)

    local noticeBgSize = notice_Image:getContentSize()
    if content_label:getContentSize().width > (noticeBgSize.width-30) then
        content_label:setDimensions(noticeBgSize.width - 30,0)
    end
    

    local contentSize = content_label:getContentSize()
--    content_label:setLineBreakWithoutSpace(false)

    local contentWidth = contentSize.width
    local contentHeight = contentSize.height
    if contentHeight < 30 then
        contentHeight = 30
    end
    local bgSize = cc.size(noticeBgSize.width, contentHeight+30)
    notice_Image:setContentSize(bgSize)
    content_label:setPosition(cc.p(bgSize.width/2, bgSize.height / 2))

end
--endregion
