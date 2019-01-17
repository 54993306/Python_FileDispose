-- 更新界面

HallLoading = class("HallLoading", UIWndBase);

function HallLoading:ctor(info)
    self.super.ctor(self, "hall/hallUpdate.csb", info);
end

function HallLoading:onShow()
    self.pb:setPercent(0)
    SocketManager.getInstance().pauseDispatchMsg = true
    self.pb:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.DelayTime:create(0.01),
                cc.CallFunc:create(
                    function()
                        local per = self.pb:getPercent()
                        if per < 100 then
                            per = per + 4
                            self.pb:setPercent(per)
                            self.lb_percent:setString((per<100 and per or 100).."%");
                        else
                            self.pb:stopAllActions()
                            self:switchToMain()
                        end
                        self.pb:setVisible(per >= 2)
                    end
                    )
                )
            )
        )
end

function HallLoading:switchToMain()
    SocketManager.getInstance().pauseDispatchMsg = false
    UIManager.getInstance():replaceWnd(HallMain);
end

-- 响应窗口回到最上层
function HallLoading:onResume()
end

function HallLoading:onClose()

end

function HallLoading:onInit()
    if IsPortrait then -- TODO
        local logoPath=GC_GameHallLogoPath or string.format("games/%s/hall/login/logo.png", GC_GameTypes[CONFIG_GAEMID])
        local img_logo = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_logo")
        img_logo:loadTexture(logoPath)
    else
        local bg = ccui.Helper:seekWidgetByName(self.m_pWidget,"bg")
        local logo = display.newSprite(GC_GameHallLogoPath)
        local logoSize = logo:getContentSize()
        if logoSize.width > 300 then
            logo:setScale(0.5)
        else
            logo:setAnchorPoint(cc.p(1, 1))
        end
        logo:setAnchorPoint(0, 1)
        logo:setPosition(cc.p(42 ,display.height - 12))
        logo:addTo(bg)
    end
    self.pb = ccui.Helper:seekWidgetByName(self.m_pWidget, "pb");
    self.pb:setVisible(false)               --用九宫格做进度条，当进度较小时，九宫格往回拉会有表现问题


    self.lb_percent = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_percent");

    self.lb_status = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_status");
    self.lb_status:setString("正在加载资源，不消耗流量...");

    self.lab_copyright = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_copyright");
    self.lab_publishcompany = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_publishcompany");
    self.lab_AuditingFileNo = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_AuditingFileNo");
    self.lab_ISBN = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_ISBN");

    self.lab_copyright:setString(_copyright and _copyright or "")
    self.lab_publishcompany:setString(_publishcompany and _publishcompany or "")
    self.lab_AuditingFileNo:setString(_AuditingFileNo and _AuditingFileNo or "")
    self.lab_ISBN:setString(_ISBN and _ISBN or "")

    if not IsPortrait then -- TODO
        -- 改变登录/ 更新/ 大厅 界面的logo
        local logo = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_22")
        if logo then
            Util.changeHallLogo(logo, 0, 3)
        end
    end
    self:haveNewBgimage()
end

-- 是否有新的背景图需要更新
function HallLoading:haveNewBgimage()
    if HANENEWBGIMAGE and PRODUCT_ID == 5542 then
        self.bg_image = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg");
        self.bg_image:loadTexture ( "hall/huanpi2/main_portrait/5542newbg.png" )
    end
end

--返回
function HallLoading:keyBack()

end
