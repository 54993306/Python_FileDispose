-----------------------------------------------------------
--  @file   club.lua
--  @brief  亲友圈
--  @author linxiancheng
--  @DateTime:2017-07-26 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local Club = class("club", UIWndBase)

local CommonTips = require "app.hall.common.CommonTips"
local FontName = "res_TTF/1016001.TTF"
local FontColor = cc.c4b(0xff,0xff,0xff,0x08)
if IsPortrait then -- TODO
    FontColor = cc.c4b(0x33,0x33,0x33,0xff)
end
local clubSocketProcesser = require("app.hall.wnds.club.clubSocketProcesser")
local ClubTips = require("app.hall.wnds.club.clubtips")
local ClubApplyRecordWnd = require("app.hall.wnds.club.clubApplyRecordWnd")
local LocalEvent = require("app.hall.common.LocalEvent")
local UmengClickEvent = require("app.common.UmengClickEvent")

function Club:ctor(data)
    self.type = data and data.type
    if self.type == nil then self.type = 1 end
    if self.type == 1 then
        self.super.ctor(self, "hall/clubApplyModeAWnd.csb")
    else
        self.super.ctor(self, "hall/clubApplyModeBWnd.csb")
    end

    self.clubNameCache = {}
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    self.m_SocketProcesser = clubSocketProcesser.new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_SocketProcesser)

    self.m_strNum={}
end

function Club:onClose()
    if self.m_SocketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_SocketProcesser)
        self.m_SocketProcesser = nil
    end
end

local function createLabInsertList(title, text,list)
        local labTitle = ccui.Text:create();
        labTitle:setFontName(FontName)
        labTitle:setColor(FontColor)
        labTitle:setString(title or "");
        labTitle:setFontSize(26);
        if IsPortrait then -- TODO
            labTitle:setAnchorPoint(0, 1.2)
        else
            labTitle:setAnchorPoint(0, 1)
        end
        labTitle:ignoreContentAdaptWithSize(false)
        local tSize = labTitle:getContentSize()

        local content = ccui.Text:create();
        content:setFontName(FontName)
        content:setColor(FontColor)
        content:setTextAreaSize(cc.size(list:getContentSize().width - tSize.width, 0));
        content:setString(text or "");
        content:setFontSize(26);
        if IsPortrait then -- TODO
            content:setAnchorPoint(0, 1.2)
        else
            content:setAnchorPoint(0, 1)
        end
        content:ignoreContentAdaptWithSize(false)
        local cSize = content:getContentSize()

        local height = tSize.height>cSize.height and tSize.height or cSize.height

        labTitle:setPosition(0, height)
        content:setPosition(tSize.width, height)

        local lay = ccui.Layout:create()
        lay:setContentSize(cc.size(list:getContentSize().width, height))
        lay:addChild(labTitle)
        lay:addChild(content)

        list:pushBackCustomItem(lay);

        return height
end

local function initWelfare(self)
    local welfareList = ccui.Helper:seekWidgetByName(self.m_pWidget,"list_welfare")
    if welfareList then
        local height = 0
        local margin = welfareList:getItemsMargin()
        for i,v in ipairs( _CLUB.WELFARE ) do
            height = height + margin + createLabInsertList(string.format("福利%d：", i), v, welfareList)
        end
        height = height - margin
        welfareList:doLayout()
        if IsPortrait then -- TODO
            if height > welfareList:getContentSize().height then
                welfareList:setContentSize(cc.size(welfareList:getContentSize().width, height))
            end
        else
            if height < welfareList:getContentSize().height then
                welfareList:setContentSize(cc.size(welfareList:getContentSize().width, height))
            end
        end
    end
end

local function initExplain(self)
    local explainList = ccui.Helper:seekWidgetByName(self.m_pWidget,"list_explain")
    if explainList then
        for i,v in ipairs( _CLUB.EXPLAIN ) do
            createLabInsertList(string.format("%d. ", i), v, explainList)
        end
    end
end

local function sendJoinClubRequest(str)
    local data = {}
    data.clI = str
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_QUERYCLUB, data)
    LoadingView.getInstance():show("信息发送中...")
end

local function numberJudge(str)
    for i=1,string.len(str) do  -- 0-9 对应的sacll码是  48-57
        local ascllNum = string.byte(str,i)
        if 57 < ascllNum or ascllNum < 48 then
            return false
        end
    end
    return true
end

local function inputDispose(str)
    if string.len(str) == 0 then        
        Toast.getInstance():show("请输入亲友圈ID")
    elseif string.match(str, "^[0-9]*$") ~= str then
        Toast.getInstance():show("亲友圈ID必须为数字")
    else
        sendJoinClubRequest(str)
    end
end

local function joinClub(self)
    local inputstr = ""
    if self.type == 1 or not IsPortrait then
        inputstr = self.input:getText()
    else
        inputstr = self.text_label:getString()
    end
    inputDispose(inputstr)
end

local function btnCallBack(self, widget, touchType)
    if touchType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if widget:getName() == "btn_sure" then
            joinClub(self)
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.JoinClubButton)
        end
    end
end

function Club:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    local btn_back = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_back");
    if btn_back then
        btn_back:addTouchEventListener(function(widget,touchType)
            if touchType == ccui.TouchEventType.ended then
                SoundManager.playEffect("btn");
                self.keyBack()
            end
        end); 
    end

    local btn_applyRecord = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_applyRecord");
    if btn_applyRecord then
        btn_applyRecord:addTouchEventListener(function(widget,touchType) 
            if touchType == ccui.TouchEventType.ended then
                SoundManager.playEffect("btn");
                UIManager.getInstance():pushWnd(ClubApplyRecordWnd)
            end
        end); 
        local applyRedRefresh = function()
            local visible = kSystemConfig:isClubApplyChanged()
            local clubBtnSize = btn_applyRecord:getContentSize()
            Util.createRedPointTip(btn_applyRecord, visible, cc.p(clubBtnSize.width-8, clubBtnSize.height-8))
        end
        local updateClubRedPoint = cc.EventListenerCustom:create(LocalEvent.ClubApplyRedChange, applyRedRefresh)
        if IsPortrait then -- TODO
            btn_applyRecord:getEventDispatcher():addEventListenerWithSceneGraphPriority(updateClubRedPoint, btn_applyRecord)    
        else
            cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(updateClubRedPoint, btn_applyRecord)    
        end
        applyRedRefresh()
    end

    local btn_return = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_return")
    btn_return:addTouchEventListener(function(widget,touchType) 
        if touchType == ccui.TouchEventType.ended then
            SoundManager.playEffect("btn");
            self.keyBack()
        end
    end);

    if self.type == 1 or not IsPortrait then -- TODO 
        local btn_sure = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_sure")
        btn_sure:addTouchEventListener(handler(self,btnCallBack))   -- 多加了一个self传入到方法当中
    end
    local lab_title = ccui.Helper:seekWidgetByName(self.m_pWidget, "title")
    if not IsPortrait then -- TODO
        if self.type == 1 then
            lab_title:setString("加入亲友圈")
        else
            lab_title:setString("加入亲友圈")
        end
        -- 输入框有Bug，基类重新创建了一个
    end

    
    self.input = self:getWidget(self.m_pWidget, "tex_input");
    if self.input and self.input.setInputMode then self.input:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC) end

    if self.type == 1 then 
        -- self.input = self:getWidget(self.m_pWidget, "tex_input");
        -- if self.input.setInputMode then self.input:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC) end
        if IsPortrait then -- TODO
            self.input:setPlaceholderFontColor(cc.c3b(175,175,170))
        end
    else
        self.text_label = self:getWidget(self.m_pWidget, "tex_Label");
    end
    
    
    initWelfare(self)
    initExplain(self)


    local lab_joinedCount = self:getWidget(self.m_pWidget, "lab_joinedCount");
    local lab_limitCount = self:getWidget(self.m_pWidget, "lab_limitCount");

    if lab_joinedCount then lab_joinedCount:setString(tostring(#kSystemConfig:getMyClubsInfo())) end
    if lab_limitCount then lab_limitCount:setString(tostring(kSystemConfig:getClubJoinLimitCount())) end
    if IsPortrait then
        if self.type ~= 1 then
            for i = 0, 9 do
                local btn = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_code" .. i);
                btn:addTouchEventListener(handler(self, self.onIconClick));
                btn:setTag(i);
            end
            self.m_tstr = ""

            self.clearButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "clearButton");
            self.clearButton:addTouchEventListener(handler(self, self.onClickButton));

            self.backButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "backButton");
            self.backButton:addTouchEventListener(handler(self, self.onClickButton));
        end
    end
   
end


function Club:onIconClick(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
      SoundManager.playEffect("btn");
        if kServerInfo:getCantEnterRoom() then -- 即将维护, 禁止开局
            Toast.getInstance():show("服务器即将进行维护! ", ToastShowTime)
            return
        end
        local tag = pWidget:getTag()
        -- local ser = self.m_strNum .. tag;
        if table.nums(self.m_strNum) < 6 then
            table.insert( self.m_strNum, tag )
            local str = ""
            for i,v in pairs(self.m_strNum) do
                str = string.format( "%s%s",str,v )
            end
            self.text_label:setString(str)
        else
            Toast.getInstance():show("亲友圈不存在! ")
        end
    end
end

function Club:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
      if pWidget == self.clearButton then
        self.m_strNum = {}
        self.text_label:setString("请输入亲友圈ID...")
      elseif pWidget == self.backButton then
        joinClub(self)
        NativeCallUmengEvent(UmengClickEvent.JoinClubButton)
      end

    end

end


function Club:commonTips(str)
    local data = {}
    data.type = 1;
    data.title = "提示";
    data.content = str;
    UIManager.getInstance():pushWnd(CommonTips, data);
end

function Club:frostClub(info)
    local data = {}
    data.type = 2
    data.title = "提示";
    data.yesTitle  = "确定";
    data.cancelTitle = "取消";
    data.content = "该亲友圈管理员冻结中，\n无法进行购买钻石，是否继续加入"
    data.yesCallback = function()
        self.ClubTips = UIManager.getInstance():pushWnd(ClubTips,info)
    end
    UIManager.getInstance():pushWnd(CommonDialog, data)
end
-- 查询亲友圈信息返回
function Club:onClubInfoReceive(info)
    if info == nil or info.clN == nil or info.clN == "" then
        self:commonTips("亲友圈不存在")
    else
        if info.clS == 2 then
            self:frostClub(info)
        else
            self.ClubTips = UIManager.getInstance():pushWnd(ClubTips,info)
        end
        if info.clI ~= nil then
            self.clubNameCache[info.clI] = info.clN
        end
    end
    LoadingView.getInstance():hide()
end
-- 加入亲友圈结果返回
function Club:onJoinClubReceive(info)
    LoadingView.getInstance():hide()

    if self.ClubTips then
       UIManager.getInstance():popWnd(self.ClubTips);
       self.ClubTips = nil
    end
    
    if info.re == 0 or info.re == 4 then
        if info.clI and self.clubNameCache[info.clI] then
            self:commonTips(string.format("您申请加入<%s>的申请已提交\n请等待管理员审批", self.clubNameCache[info.clI]))
        else
            self:commonTips("您的申请已提交\n请等待管理员审批")
        end
        self:keyBack()
    elseif info.re == 1 then
        self:commonTips("亲友圈不存在")
    elseif info.re == 2 then
        self:commonTips("您已是该亲友圈亲友")
    elseif info.re == 3 then
        self:commonTips("您加入的亲友圈数量已达上限")
    else
        self:commonTips("数据错误请联系客服处理")
    end
end

Club.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_QUERYCLUB] = Club.onClubInfoReceive,
    [HallSocketCmd.CODE_REC_JOINCLUB] = Club.onJoinClubReceive,
}

return Club