-----------------------------------------------------------
--  @file   EmailPanel.lua
--  @brief  邮件内容界面
--  @author linxiancheng
--  @DateTime:2017-05-04 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
--[[
    type = 5,code=50024, 返回邮件读取  Server->Client
    -------------------------------
    ##  maI  long  mail id
    ##  ti  String  标题
    ##  co  String  内容
    ##  go  String  赠送道具列表
    ##  maT  int  邮件类型 0 系统邮件 1用户邮件
    ##  stT  String  上线时间
    ##  enT  String  结束时间
]]

local EmailContent = class("EmailContent")

function EmailContent:ctor(widget)
    self.widget = widget
    if not IsPortrait then -- TODO
        local title = ccui.Helper:seekWidgetByName(self.widget, "lab_title")
        title:enableShadow(cc.c4b(0, 0, 0,255),cc.size(2,-2));
    end
end

function EmailContent:deleteMail(mailId)
    if mailId == self.data.maI then
        self.widget:setVisible(false)
    end
end

function EmailContent:sendGetItem()
    local data = {};
    data.maI = self.data.maI;
    data.ty  = self.data.maT;
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_REC_GETITEM, data);
    LoadingView.getInstance():show("正在领取奖励...");
end 

function EmailContent:sendDeleteMail()
    local data = {};
    data.maI = self.data.maI;
    data.ty  = self.data.maT;
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_PICKUP, data);
    LoadingView.getInstance():show("邮件删除中...");
end 
--刷新数据，同时刷新面板，需要跟父面板进行通信，数据在两个层之间互传
function EmailContent:onClickCallBack(pButton,pEventType)
    if pEventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pButton:getName() == "btn_get" then
            self:sendGetItem()
            if IsPortrait then -- TODO
                self.Panel_bg_content:setVisible(false)
            end
        elseif pButton:getName() == "btn_delete" then
            self:sendDeleteMail()
            if IsPortrait then -- TODO
                self.Panel_bg_content:setVisible(false)
            end
        elseif IsPortrait and (self.Panel_bg_content == pButton or pButton:getName() == "btn_close" or pButton:getName() == "btn_confirm_panelcontent") then
            self.widget:setVisible(false)
            self.Panel_bg_content:setVisible(false)
        end
    end
end


function EmailContent:dateCount(pData)
    local day = tonumber((pData.enT-os.time())/(24*60*60))
    if pData.enT == 0 then
        if IsPortrait then -- TODO
            return "永久有效"
        end
        return "(永久有效)"
    end
    if day >= 1 then
        day = math.floor(day)
        if IsPortrait then -- TODO
            return day.."天后过期自动删除"
        end
        return "("..day.."天后过期自动删除"..")"
    else
        day = math.floor(day*24)
        if day == 0 then
            if IsPortrait then -- TODO
                return "1小时内过期自动删除"
            end
            return ""
        else
            if IsPortrait then -- TODO
                return day.."小时后过期自动删除"
            end
            return "("..day.."小时后过期自动删除"..")"
        end
    end
end

if IsPortrait then -- TODO
    function EmailContent:createTextInList(list,text, horizontalAlignment, autoLineHeight, customOpacity)
        if autoLineHeight == nil then autoLineHeight = false end
        local params = {}
        params.text = text
        params.font = "hall/font/fangzhengcuyuan.TTF"
        params.size = 26
        params.x = 0
        params.y = 0
        params.color = cc.c3b(0x00,0x00,0x00)

        local content_label = display.newTTFLabel(params)
        content_label:setDimensions(0,0)
        content_label:setLineBreakWithoutSpace(true)
        if not autoLineHeight then content_label:setLineHeight(26+28) end

        local lineWidth = list:getContentSize().width

        if content_label:getContentSize().width > lineWidth then
            content_label:setDimensions(lineWidth,0)
            if horizontalAlignment then
                content_label:setTextHorizontalAlignment(horizontalAlignment)
            end
            content_label:setAnchorPoint(cc.p(0,0))
            content_label:setPosition(0, 0)
        else
            if cc.TEXT_ALIGNMENT_RIGHT == horizontalAlignment then
                content_label:setAnchorPoint(cc.p(1,0))
                content_label:setPosition(lineWidth, 0)
            else
                content_label:setAnchorPoint(cc.p(0,0))
                content_label:setPosition(0, 0)
            end
        end
        content_label:setOpacity(customOpacity and customOpacity or 204)

        local content = ccui.Layout:create()
        content:setContentSize(lineWidth, content_label:getContentSize().height)
        content:addChild(content_label)
        list:pushBackCustomItem(content);
        return content:getContentSize().height
    end
    --点击不同意按钮
    function  EmailContent:onClickButongyi(pButton,pEventType)
        if pEventType == ccui.TouchEventType.ended then
            SoundManager.playEffect("btn");
            -- Toast.getInstance():show("不同意")
            local data = {};
            data.maI = self.data.maI
            data.acS = 2
            data.st = 0
            SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_REC_CLUB_APPLY, data);
            LoadingView.getInstance():show("正在发送,请稍后...");
        end
    end

    --点击同意按钮
    function EmailContent:onClickTongyi(pButton,pEventType)
        if pEventType == ccui.TouchEventType.ended then
            SoundManager.playEffect("btn");
            -- Toast.getInstance():show("同意")
            local data = {};
            data.maI = self.data.maI
            data.acS = 1
            data.st = 0
            SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_REC_CLUB_APPLY, data);
            LoadingView.getInstance():show("正在发送,请稍后...");
        end
    end
    function EmailContent:applyBear(pInfo)
        if pInfo == nil  then
            return
        end
        if pInfo.st == 0 then
            LoadingView.getInstance():hide()
            local btn_butongyi = ccui.Helper:seekWidgetByName(self.widget,"btn_butongyi")
            local btn_tongyi = ccui.Helper:seekWidgetByName(self.widget,"btn_tongyi")
            btn_butongyi:setVisible(false)
            btn_tongyi:setVisible(false)
            local lab_tongyi = ccui.Helper:seekWidgetByName(self.widget,"lab_tongyi")
            lab_tongyi:setVisible(true)
            lab_tongyi:setString("已同意")
            if pInfo.acS == 2 then
                lab_tongyi:setString("已拒绝")
            end
        end
        if pInfo.ms and pInfo.ms ~= "" then
            local data = {}
            data.type = 1;
            data.title = "提示";
            data.content = pInfo.ms;
            -- data.yesCallback = function()
            --     MyAppInstance:exit()
            -- end
            data.closeCallback = function ()
            end
            UIManager.getInstance():pushWnd(CommonDialog, data);
        end
    end
else
    function EmailContent:createTextInList(list,text, horizontalAlignment, customOpacity)
        local content = ccui.Text:create();
        content:setFontName("hall/font/fangzhengcuyuan.TTF")
        content:setColor(cc.c3b(0xff,0xff,0xff))
        content:setOpacity(customOpacity and customOpacity or 204)
        content:setTextAreaSize(cc.size(850, 0));
        content:setString(text);
        content:setFontSize(26);
        if horizontalAlignment then
            content:setTextHorizontalAlignment(horizontalAlignment)
        end
        content:ignoreContentAdaptWithSize(false)
        list:pushBackCustomItem(content);
        return content:getContentSize().height
    end
end

function EmailContent:fillBlank(list,textHeight)
    local lineHeight = 29
    if IsPortrait then -- TODO
        lineHeight = 26+28
    end
    local listHeight = list:getContentSize().height
    local blankLineNum = (listHeight - (lineHeight * 5) - textHeight) / lineHeight
    if IsPortrait then -- TODO
        blankLineNum = (listHeight - (lineHeight * 2) - textHeight) / lineHeight
    end
    blankLineNum = blankLineNum > 0 and blankLineNum or 1    -- 内容过长时只需空一行即可

    for i=1,tonumber(blankLineNum) do
        self:createTextInList(list," ")
    end
end

function EmailContent:createInterval(list)
    local content = ccui.Text:create();
    content:setFontName("hall/font/fangzhengcuyuan.TTF")
    content:setFontSize(5);
    content:setString(" ");
    list:pushBackCustomItem(content);
end

if IsPortrait then -- TODO
end

function EmailContent:initListByText()
    local ListText = ccui.Helper:seekWidgetByName(self.widget,"list_text")
    ListText:removeAllItems()

    local gameName = string.format("%s%s",string.rep("",1),string.format("%s",_GameName or ""))
    local sendTime = string.format("%s%s",string.rep("",1),os.date("%Y-%m-%d",self.data.stT or os.time()))
    
    if IsPortrait then -- TODO
        local textTotalHeight = self:createTextInList(ListText, string.format("%s%s",string.rep(" ",4),self.data.co or ""))
            
        textTotalHeight = textTotalHeight + self:createTextInList(ListText, gameName, cc.TEXT_ALIGNMENT_RIGHT)
        textTotalHeight = textTotalHeight + self:createTextInList(ListText, sendTime, cc.TEXT_ALIGNMENT_RIGHT, true)
        local labDelTime = ccui.Helper:seekWidgetByName(self.widget,"lab_del_time")
        if labDelTime then
            labDelTime:setString(self:dateCount(self.data))
        else
            textTotalHeight = textTotalHeight + self:createTextInList(ListText, self:dateCount(self.data), cc.TEXT_ALIGNMENT_RIGHT)
        end

        if textTotalHeight < ListText:getContentSize().height then
            local fil = ccui.Layout:create()
            fil:setContentSize(cc.size(10, ListText:getContentSize().height - textTotalHeight))
            ListText:insertCustomItem(fil, 1)
        end
        
    else
        self:createInterval(ListText)
        local textHeight = self:createTextInList(ListText, string.format("%s%s",string.rep(" ",7),self.data.co or ""))
        
        self:fillBlank(ListText, textHeight)
        
        self:createTextInList(ListText, gameName, cc.TEXT_ALIGNMENT_RIGHT)
        self:createInterval(ListText)
        self:createTextInList(ListText, sendTime, cc.TEXT_ALIGNMENT_RIGHT)
        self:createInterval(ListText)
        self:createTextInList(ListText, self:dateCount(self.data), cc.TEXT_ALIGNMENT_RIGHT, 140)
    end

    local btn_butongyi = ccui.Helper:seekWidgetByName(self.widget,"btn_butongyi")
        btn_butongyi:addTouchEventListener(handler(self,self.onClickButongyi))
        local btn_tongyi = ccui.Helper:seekWidgetByName(self.widget,"btn_tongyi")
        btn_tongyi:addTouchEventListener(handler(self,self.onClickTongyi))

        local lab_tongyi = ccui.Helper:seekWidgetByName(self.widget,"lab_tongyi")
        if self.data.opS ~= nil and self.data.opS == 0 then
            ListText:setBounceEnabled(false)
            btn_butongyi:setVisible(true)
            btn_tongyi:setVisible(true)
            lab_tongyi:setVisible(false)
        else
            btn_butongyi:setVisible(false)
            btn_tongyi:setVisible(false)
            if self.data.opS ~= nil and self.data.opS > 0 then
                ListText:setBounceEnabled(false)
                lab_tongyi:setVisible(true)
                lab_tongyi:setString("已同意")
                if self.data.opS == 2  then
                    lab_tongyi:setString("已拒绝")
                end
            else
                lab_tongyi:setVisible(false)
            end
        end
end

if IsPortrait then -- TODO
end

--种类目前就是房卡和兑换券,写一个根据id拿到图片的方法
function EmailContent:initItemImage(data)
    if not string.split(data, "|") then
        print("[ ERROR ] by Linxiancheng server data error ")
        return 
    end
    for _,tab in pairs( string.split(data, "|") ) do
        local item_num = string.split(tab, ":");
        if #item_num <=1 then
            print("[ ERROR ] EmailContent initItemPanel server data Error ")
            return
        end
        local Itemnum = ccui.Helper:seekWidgetByName(self.widget,"Label_num")
        Itemnum:setString("x"..item_num[2])
        if not IsPortrait then -- TODO
            Itemnum:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(2, -2));
        end
    end
end

function EmailContent:initTextPanel()
    local BtnDelete = ccui.Helper:seekWidgetByName(self.widget,"btn_delete")
    BtnDelete:setVisible(not(#self.data.go > 0))
    BtnDelete:addTouchEventListener(handler(self,self.onClickCallBack))

    local LabTitle = ccui.Helper:seekWidgetByName(self.widget,"lab_title")
    LabTitle:setString(ToolKit.subUtfStrByCn(self.data.ti, 0, 17, "..."));

    self:initListByText()
end

function EmailContent:initPanelByData()
    local Panel_item = ccui.Helper:seekWidgetByName(self.widget,"Panel_item")
    Panel_item:setVisible(#self.data.go > 0);

    local btn_get = ccui.Helper:seekWidgetByName(Panel_item,"btn_get")
    btn_get:addTouchEventListener(handler(self,self.onClickCallBack))

    if IsPortrait then -- TODO
        self.Panel_bg_content = ccui.Helper:seekWidgetByName(self.widget:getParent(), "Panel_bg_content");
        self.Panel_bg_content:addTouchEventListener(handler(self,onClickCallBack))

        --删除按钮
        local BtnClose = ccui.Helper:seekWidgetByName(self.widget,"btn_close")
        BtnClose:addTouchEventListener(handler(self,self.onClickCallBack))

        local btn_confirm_item = ccui.Helper:seekWidgetByName(self.widget,"btn_confirm_panelcontent");
        btn_confirm_item:addTouchEventListener(handler(self,self.onClickCallBack))
    end
    
    if #self.data.go > 0 then  --初始化显示内容
        self:initItemImage(self.data.go)
    end

    self:initTextPanel()
end

function EmailContent:initData(data)
    self.data = data
    self.widget:setVisible(true)
    self:initPanelByData()
end

return EmailContent