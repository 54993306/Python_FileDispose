--
--通用对话框界面
--使用方法
-- local data = {}
-- data.type = 1                              --对话框类型：1,一个"确定"按钮  2，一个“取消”按钮和一个“确定”按钮 3. 只有内容
-- data.contentType = COMNONDIALOG_TYPE_NETWORK;  --对话框提示内容类型
-- data.content = "提示内容"                  --对话框提示内容
-- data.yesCallback                           --确定按钮回调
-- data.cancalCallback                        --取消按钮回调
-- data.closeCallback                         --关闭按钮回调
-- data.switchBtn                             --互换按钮位置
-- data.yesStr                                --确定按钮文本
-- data.cancalStr                             --取消按钮文本
-- data.closeStr                              --关闭按钮文本
-- data.canKeyBack                            --能按物理返回键关闭
-- data.backupLabel                           --备用label
-- UIManager.getInstance():pushWnd(CommonDialog, data);

CommonDialog = class("CommonDialog", UIWndBase)

function CommonDialog:ctor(data, zorder)
    self.super.ctor(self, "hall/common_dialog.csb", data, WND_ZORDER_COMMONDDIALOG);
end

--获取内容类型
function CommonDialog:getContentType()
    return self.m_data.contentType;
end

function CommonDialog:onInit()
    -- Log.i("CommonDialog:onInit...",self.m_data)
    self.m_data.content = string.gsub( self.m_data.content,"|","\n")
    self.baseShowType = UIWndBase.BaseShowType.RTOL

    --btn_return
    self.btn_return = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_return");
    if self.m_data.contentType == COMNONDIALOG_TYPE_NETWORK or self.m_data.contentType == COMNONDIALOG_TYPE_KICKED then
        self.btn_return:setVisible(false)
    else
        if not IsPortrait then -- TODO
            self:addWidgetClickFunc(self.m_pWidget, handler(self, self.CommonClose))
        end
        self:addWidgetClickFunc(self.btn_return, handler(self, self.CommonClose))
    end

    --关闭
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));
    --取消
    self.btn_cancal = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_cancal");
    self.btn_cancal:addTouchEventListener(handler(self, self.onClickButton));
    --确定
    self.btn_yes = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_yes");
    self.btn_yes:addTouchEventListener(handler(self, self.onClickButton));

    --标题
    self.lab_title = ccui.Helper:seekWidgetByName(self.m_pWidget, "title")

    self.lab_yes = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_yes");
    self.lab_cancal = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_cancal");
    self.lab_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_close");

    if IsPortrait then -- TODO
        --标题阴影
        self.lab_title_shadow = ccui.Helper:seekWidgetByName(self.m_pWidget, "title_0")
        self.lab_cancal_image = ccui.Helper:seekWidgetByName(self.btn_cancal,"Image_24")
        self.label_yes_image = ccui.Helper:seekWidgetByName(self.btn_yes,"Image_22")
        self.label_close_image = ccui.Helper:seekWidgetByName(self.btn_close,"Image_23")
    else
        self.playerID = ccui.Helper:seekWidgetByName(self.m_pWidget, "playerID");
        --用户ID或者备用
        if self.playerID ~=nil then
            if self.m_data.backupLabel ~= nil and self.m_data.backupLabel ~= "" then
                self.playerID:setString("用户ID:"..self.m_data.backupLabel)
                self.playerID:setColor(cc.c3b(255,255,255))
                self.playerID:setVisible(true)
            else
                self.playerID:setVisible(false)
            end        
        end
    end
    --按钮

    if not self.m_data.type or self.m_data.type == 1 then
        self.btn_cancal:setVisible(false);
        self.btn_yes:setVisible(false);
    elseif IsPortrait and self.m_data.type == 2 then -- TODO
        self.btn_return:setVisible(false);
        self.btn_close:setVisible(false);
    else
        if not IsPortrait and self.m_data.switchBtn == true then
            local pos1 = cc.p(self.btn_cancal:getPosition())
            local pos2 = cc.p(self.btn_yes:getPosition())
            self.btn_cancal:setPosition(pos2)
            self.btn_yes:setPosition(pos1)
        end
        self.btn_close:setVisible(false);
    end

    if type(self.m_data.yesStr) == "string" then
        self.lab_yes:setString(self.m_data.yesStr)
        if IsPortrait then -- TODO
            self.lab_yes:setVisible(true)
            self.label_yes_image:setVisible(false)
        end
    end
    if type(self.m_data.cancalStr) == "string" then
        self.lab_cancal:setString(self.m_data.cancalStr)
        if IsPortrait then -- TODO
            self.lab_cancal:setVisible(true)
            self.lab_cancal_image:setVisible(false)
        end
    end
    if type(self.m_data.closeStr) == "string" then
        if IsPortrait then -- TODO
            self.lab_close:setVisible(true)
            self.label_close_image:setVisible(false)
        end
        self.lab_close:setString(self.m_data.closeStr)
    end
    if IsPortrait then -- TODO
        if self.m_data.closeImg then
            self.lab_close:setVisible(false)
            self.label_close_image:setVisible(true)
            self.label_close_image:loadTexture(self.m_data.closeImg)
        end
    end
    if type(self.m_data.title) == "string" then
        self.lab_title:setString(self.m_data.title)
        if IsPortrait then -- TODO
            self.lab_title_shadow:setString(self.m_data.title)
        end
    end

    self:DynamicLabel()

    if IsPortrait then -- TODO
        self:subjoinLabel()
    end
end

function CommonDialog:CommonClose()
    SoundManager.playEffect("btn");

    UIManager.getInstance():popWnd(self);

    if self.m_data.commonCloseCallback then
        self.m_data.commonCloseCallback();
        return;
    end

    if self.m_data.keyBackCallback then
        self.m_data.keyBackCallback()
    end    

    if not self.m_data.type or self.m_data.type == 1 then
        if self.m_data.closeCallback then
            self.m_data.closeCallback();
            return;
        end
    elseif self.m_data.type ~= 3 then
        if self.m_data.cancalCallback then
            self.m_data.cancalCallback()
            return;
        end
    end
end


--提出封装成一个公用的方法
function CommonDialog:DynamicLabel()
    -- params.text = "了肯德基爱丽丝肯德基阿斯达搜啊交换机狂欢节啊交换机狂欢节啊交换机狂欢节啊交换机狂欢节啊交换机狂欢节啊交换机狂欢节"
    local content = ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_content");
    if self.m_data.type == 3 then
        content = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_content");
    end
    content:setVisible(false)
    local textSize = 36
    local params = {}
    params.text = self.m_data.content or "暂无信息"
    params.font = "hall/font/fangzhengcuyuan.TTF"
    if IsPortrait then -- TODO
        params.size = self.m_data.textSize or textSize
    else
        params.size = textSize
    end
    params.align =  cc.TEXT_ALIGNMENT_CENTER
    params.valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    if IsPortrait then -- TODO
        params.color = cc.c3b(51,51,51)
    else
        params.color = cc.c3b(255,255,255)              --cc.c3b
    end
    local lenth = ToolKit.widthSingle(params.text)
    local tDynamicLabel = display.newTTFLabel(params)
    local tMaxLength = 15
    if lenth < tMaxLength then
        tDynamicLabel:setDimensions(lenth*textSize,textSize+20)
    else
        local texLen = math.ceil(lenth/tMaxLength)
        tDynamicLabel:setDimensions(tMaxLength*textSize,(textSize+10)*texLen)
    end
    local contentSize = tDynamicLabel:getContentSize()
    tDynamicLabel:setPosition(content:getPosition())
    content:getParent():addChild(tDynamicLabel)
    self.content = tDynamicLabel
end

--提出一个封装的附加内容方法
function CommonDialog:subjoinLabel()
    if not self.m_data.subjoin then
        return
    end
    local content = ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_content");
    local copyBtnLayout = ccui.Layout:create()
    -- local copyBtnLayout = display.newColorLayer(cc.c4b(100,100,100,255))
    copyBtnLayout:setContentSize(cc.size(content:getParent():getContentSize().width,60))
    content:getParent():addChild(copyBtnLayout)
    -- copyBtnLayout:setPosition(cc.p(15,
    --                                 -self.content:getContentSize().height / 2 + copyBtnLayout:getContentSize().height/2 - 5))

    local lenth = ToolKit.widthSingle(self.m_data.subjoin)
    local textSize = self.m_data.textSize or 28
    
    
    local subjoinLabel = cc.Label:create()
    subjoinLabel:setString(self.m_data.subjoin)
    subjoinLabel:setColor(cc.c3b(255,0,0))
    subjoinLabel:setSystemFontSize(textSize)
    subjoinLabel:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
    copyBtnLayout:addChild(subjoinLabel)

    -- copyBtnLayout:setPosition(cc.p(subjoinLabel:getContentSize().width,self.content:getContentSize().height + copyBtnLayout:getContentSize().height - 5))
    Log.i("self.content",self.content:getContentSize(),self.content:getPositionY())
    copyBtnLayout:getLayoutParameter():setMargin({ top = content:getPositionY()+ self.content:getContentSize().height/2 + copyBtnLayout:getContentSize().height})
    subjoinLabel:setPosition(cc.p(subjoinLabel:getContentSize().width/2 + 20,copyBtnLayout:getContentSize().height/2))

    if not self.m_data.handle then
        return
    end

    copyBtnLayout:setTouchEnabled(true)
    copyBtnLayout:setTouchSwallowEnabled(true)
    copyBtnLayout:addTouchEventListener(handler(self,self.onLabelClickButton));
    

    local copyLabel = cc.Label:create()
    copyLabel:setString(self.m_data.handle)
    copyLabel:setColor(cc.c3b(255,0,0))
    copyLabel:setSystemFontSize(textSize)
    copyLabel:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
    copyLabel:setPosition(cc.p(subjoinLabel:getContentSize().width + 60,copyBtnLayout:getContentSize().height/2))
    copyBtnLayout:addChild(copyLabel)
    

    local copyRoomIdLine = cc.Label:create()
    copyRoomIdLine:setString("_____")
    copyRoomIdLine:setColor(cc.c3b(255,0,0))
    copyRoomIdLine:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
    copyRoomIdLine:setSystemFontSize(textSize)
    copyRoomIdLine:setPosition(cc.p(subjoinLabel:getContentSize().width + 60,copyBtnLayout:getContentSize().height/2 - 5))
    copyBtnLayout:addChild(copyRoomIdLine)

end

function CommonDialog:onLabelClickButton(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
        -- Log.i("复制成功")
        local data = {};
        data.cmd = NativeCall.CMD_CLIPBOARD_COPY;
        data.content  = kUserInfo:getUserId()
        -- Log.i("copy code:" .. data)
        NativeCall.getInstance():callNative(data);
        Toast.getInstance():show("复制成功"); 
    end
end

function CommonDialog:getContentLabel()
    return self.content
end

function CommonDialog:getCancelBtn()
    return self.btn_cancal
end

function CommonDialog:getYesBtn()
    return self.btn_yes
end

function CommonDialog:getCloseBtn()
    return self.btn_close
end

function CommonDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        self.m_data.canKeyBack = true;
                
        if self.m_data.canKeyBack == nil or  self.m_data.canKeyBack == true then
            UIManager.getInstance():popWnd(self);
        end
        if self.m_data.keyBackCallback then
            self.m_data.keyBackCallback()
        end
        
        if pWidget == self.btn_close then
            if self.m_data.closeCallback then
                self.m_data.closeCallback();
                return;
            end
        elseif pWidget == self.btn_yes then
            if self.m_data.yesCallback then
                self.m_data.yesCallback()
            end
        elseif pWidget == self.btn_cancal then
            if self.m_data.cancalCallback then
                self.m_data.cancalCallback()
            end
        end
    end
end

function CommonDialog:onShow()
    if IsPortrait then -- TODO
        return
    end
    TouchCaptureView.getInstance():show();
    --SoundManager.playEffect("dialog_pop", "hall");
    self.m_pWidget:setTouchEnabled(false);
    local contentView = ccui.Helper:seekWidgetByName(self.m_pWidget, "content");
    contentView:setAnchorPoint(cc.p(0.5, 0.5));
    -- transition.execute(contentView, cc.ScaleTo:create(0.1, 0.9) ,{
    --     onComplete = function()
    --         transition.execute(contentView, cc.ScaleTo:create(0.1, 1) ,{
    --         onComplete = function()
    --             self.m_pWidget:setTouchEnabled(true);
    --             TouchCaptureView.getInstance():hide();
    --         end
    --         });
    --     end
    -- });
end

--返回
function CommonDialog:keyBack()
    if self.m_data.contentType == COMNONDIALOG_TYPE_NETWORK or self.m_data.contentType == COMNONDIALOG_TYPE_KICKED then
        return 
    end
    if self.m_data.canKeyBack == nil or  self.m_data.canKeyBack == true then
        UIManager.getInstance():popWnd(self);
    end
    if self.m_data.keyBackCallback then
        self.m_data.keyBackCallback()
    end
    if self.m_data.cancalCallback then
        self.m_data.cancalCallback()
    end
end