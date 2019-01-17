-- 更新界面

HallUpdate = class("HallUpdate", UIWndBase);

function HallUpdate:ctor(info)
    self.super.ctor(self, "hall/hallUpdate.csb", info);
    self.percent = 0
end

local checkNewVersion = function(oldVersion, newVersion)
    if not oldVersion then return true end
    local oldVerTab = string.split(oldVersion, ".")
    local newVerTab = string.split(newVersion, ".")
    for i, v in ipairs(oldVerTab) do
        if not newVerTab[i] then
            return false
        elseif tonumber(v) > tonumber(newVerTab[i]) then
            return false
        elseif tonumber(v) < tonumber(newVerTab[i]) then
            return true
        end
    end
    return false
end

function HallUpdate:onShow()
    if self.m_data.neVDRL then
        -- dump(self.m_data)
        local data = {};
        data.cmd = NativeCall.CMD_UPDATE_VERSION;
        data.URL = self.m_data.neVDRL;
        local serverNotifyData = kServerInfo:getServerNotifyData()
        -- serverNotifyData.mainVersion = {}
        -- serverNotifyData.mainVersion[CONFIG_GAEMID] = {version = "1.0.20", versionUrl = "sdfsakdfjsa"}
        if serverNotifyData and serverNotifyData.mainVersion then
            local updateInfo = serverNotifyData.mainVersion[tostring(CONFIG_GAEMID)]
            if updateInfo then
                local version = updateInfo.version or "1.0.0"
                if checkNewVersion(self.m_data.newVersion, version) and updateInfo.versionUrl then
                    -- print("sfslakjdflksa")
                    data.URL = updateInfo.versionUrl
                end
            end
        end
        data.path = WRITEABLEPATH .. "update/";
--
        -- dump(data)
        --
        NativeCall.getInstance():callNative(data, HallUpdate.upCallBack, self);
    end
end

function HallUpdate:updatePro(info)
    if info.pro < self.pb:getPercent() then
        self.pb:setPercent((info.pro - self.percent)/2 + self.pb:getPercent());
        self.percent = info.pro
    else
        self.pb:setPercent(info.pro)
    end
    if info.pro == 100 or self.pb:getPercent() == 100 then
        -- self.lb_status:setString("内容解压中，不消耗流量，请稍候");
        self.lb_status:setString("内容解压中，不消耗流量，请耐心等待，不要关闭游戏...");
    end
    self.lb_percent:setString(string.format("%d%%",self.pb:getPercent()));
end

function HallUpdate:upCallBack(info)
    if info.type == 1 then
        self:updatePro(info)
    elseif info.type == 3 then
        LoadingView.getInstance():hide();

        package.loaded["app.hall.HallConfig"] = nil;
        require("app.hall.HallConfig");
        package.loaded["app.config"] = nil;
        require("app.config");

        UIManager.getInstance():pushWnd(HallLogin);
    elseif info.type == 4 then
        Toast.getInstance():show("解压失败");
    end
end

-- 响应窗口回到最上层
function HallUpdate:onResume()
end

function HallUpdate:onClose()

end

function HallUpdate:onInit()
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

    self.lb_status = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_status");
    self.lb_percent = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_percent");
    self.pb = ccui.Helper:seekWidgetByName(self.m_pWidget, "pb");
    self.pb:setVisible(false)               --用九宫格做进度条，当进度较小时，九宫格往回拉会有表现问题


    self.lb_percent:performWithDelay(function()     -- 闭包方法,可调用它上层的方法的参数
        self.lb_percent:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(
            function()
                local percent = self.pb:getPercent() + 1.2
                if  percent >= 50 then
                    self.lb_percent:stopAllActions()
                    percent = 50
                end
                self.pb:setPercent(percent)
                self.lb_percent:setString(string.format("%d%%",self.pb:getPercent()));
                if self.pb:getPercent() > 2 then
                   self.pb:setVisible(true)
                end
            end))))
        end,0.5)

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

    ---- 测试方法
    -- local pro = 0
    -- self.m_pWidget:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
    --     local data = {}
    --     pro = pro + 1
    --     if pro > 100 then
    --         self.m_pWidget:stopAllActions()
    --         return
    --     end
    --     data.pro = pro
    --     self:updatePro(data)
    -- end))))

    self:haveNewBgimage()
end

-- 是否有新的背景图需要更新
function HallUpdate:haveNewBgimage()
    if HANENEWBGIMAGE and PRODUCT_ID == 5542 then
        self.bg_image = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg");
        self.bg_image:loadTexture ( "hall/huanpi2/main_portrait/5542newbg.png" )
    end
end

--返回
function HallUpdate:keyBack()

end
