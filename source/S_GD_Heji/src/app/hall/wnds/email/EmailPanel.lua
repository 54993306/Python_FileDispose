-----------------------------------------------------------
--  @file   EmailPanel.lua
--  @brief  邮件系统
--  @author linxiancheng
--  @DateTime:2017-05-04 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local EmailPanel = class("EmailPanel", UIWndBase)
local EmailContent = require "app.hall.wnds.email.EmailContent"

function EmailPanel:ctor(...)
    self.super.ctor(self,"hall/email_panel.csb",...)
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    self.m_socketProcesser = EmailSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
end

function EmailPanel:onClose()
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
end

local function getItemByID(self, mailID)
    for _,item in pairs(self.listview:getItems()) do
        if item.data.maI == mailID then
            return item
        end
    end
    return nil
end 

local function sendOpenMail(pData)
    local data = {};
    data.maI = pData.maI;
    data.ty  = pData.maT;
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_CONTEXTINFO, data);
    LoadingView.getInstance():show("正在打开邮件,请稍后...");
end

-- 显示被选择效果
local function showClickState(self, data)
    for _,item in pairs( self.listview:getItems() ) do
        local clickbg = ccui.Helper:seekWidgetByName(item, "img_click")
        if item.data.maI == data.maI then
            clickbg:setVisible(true)
        else
            clickbg:setVisible(false)
        end
    end
end

--邮箱列表按钮回调
local function onClickCallBack(pData,widget,touchType)
    if touchType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if widget:getName() == "btn_close" then
            pData:keyBack()
        elseif IsPortrait and widget:getName() == "btn_confirm" then -- TODO
            pData:keyBack()
        elseif widget:getName() == "btn_mail" then
            showClickState(pData.self, pData.data)
            sendOpenMail(pData.data)
        else
            print("[ ERROR ] Email:onClickCallBack")
        end
    end
end
--时间计算
local function dateCut(pData)
    -- print(os.date("1--------------------------/%Y-%m-%d-/%H:%M:%S",pData.stT),pData.ti)
    local sendMonth = tonumber(os.date("%m",pData.stT or 0)) or 0
    local nowMonth = tonumber(os.date("%m",os.time() or 0)) or 0
    local sendDay = tonumber(os.date("%d",pData.stT or 0)) or 0
    local nowDay = tonumber(os.date("%d",os.time() or 0)) or 0
    local cutDay = (nowMonth - sendMonth) * 30 + nowDay - sendDay
    if cutDay > 0 then
        return string.format("%d天前",cutDay)
    else
        return "今天"
    end
end
--清理过期邮件,服务器不需要通知
local function clearDueMail()
    local _Data = kUserData_userExtInfo:getInstance():getEmailData()
    for i = #_Data,1,-1 do
        -- print(os.date("2-------------------------/%Y-%m-%d-/%H:%M:%S",_Data[i].enT))
        if _Data[i].enT ~= 0 and os.time() > _Data[i].enT then
            table.remove(_Data,i)     --_Data和单例中的table是同一份内存
        end
    end
end
--多重比较,先判断已读情况再判断时间
local function sortFunc(aMail,bMail)
    if aMail.reS == bMail.reS then
        return aMail.stT > bMail.stT
    else
        return aMail.reS < bMail.reS
    end
end

local function sortMail()
    local _Data = kUserData_userExtInfo:getInstance():getEmailData()
    table.sort(_Data,sortFunc)
end
--[[
    --初始化邮箱列表,动态根据已读和未读状态以及时间做一个排序显示处理
    type = 5,code=50022, 返回邮件列表  Server->Client
    SimpleMailItem
    ##    maI  long  id
    ##    maT  int  邮件类型 0 系统邮件 1用户邮件
    ##    ti  String  标题
    ##    stT  long  上线时间
    ##    enT  long  结束时间
    ##    reS  int  是否已读（0 未读，1 已读）
    ##    reS0  int  是否有附件
    -------------------------------
    ##  li:[SimpleMailItem]  li  List<SimpleMailItem>  数据列表
]]

local function initMailTips(pWidget, data)
    local labtips = ccui.Helper:seekWidgetByName(pWidget,"labTips")
    if #data > 0 then
        labtips:setVisible(false)
    else
        labtips:setVisible(true)
    end
end

local function initItem(self, item)
    local tTitle = ccui.Helper:seekWidgetByName(item,"lab_title")
    tTitle:setString(ToolKit.subUtfStrByCn(item.data.ti, 0, 10, "..."))

    if item.data.reS == 1 then
        local mailicon = ccui.Helper:seekWidgetByName(item, "Image_box")
        mailicon:loadTexture("real_res/1004608.png")
        tTitle:setOpacity(128)
    end

    local btnEmail = ccui.Helper:seekWidgetByName(item,"btn_mail")
    btnEmail:addTouchEventListener(handler({self = self,data = item.data},onClickCallBack))

    local gift = ccui.Helper:seekWidgetByName(item,"img_gift")
    gift:setVisible(item.data.reS0 > 0)

    --days,计算时间差
    local tLabDay = ccui.Helper:seekWidgetByName(item,"lab_day")
    tLabDay:setString(dateCut(item.data))
end

local function initListView(self)
    clearDueMail()
    sortMail()
    local data = kUserData_userExtInfo:getInstance():getEmailData()
    --labtips
    initMailTips(self.m_pWidget, data)
    --ItenList
    self.listview:removeAllItems();

    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/email_item.csb")
    for k,tData in pairs(data) do
        local item = itemModel:clone()
        item.data = tData
        initItem(self, item)
        self.listview:pushBackCustomItem(item)
    end
end

local function removeEmail(self,pEmailID)
    local _Data = kUserData_userExtInfo:getInstance():getEmailData()
    for k,v in pairs(_Data) do
        if v.maI == pEmailID then
            table.remove(_Data,k)
            break
        end
    end
    initListView(self)
    LoadingView.getInstance():hide();
    if self.ContentPanel then
        self.ContentPanel:deleteMail(pEmailID)
    end
end

--读邮件刷新列表,要动态排序根据已读和未读状态
local function readEmail(pEmailID)
    local _Data = kUserData_userExtInfo:getInstance():getEmailData()
    for k,v in pairs(_Data) do
        if v.maI == pEmailID then
            if  v.reS > 0 then
                return
            else
                v.reS = 1          --邮件打开后标记已读
            end
            break
        end
    end
end

--初始化邮件界面
function EmailPanel:onInit()
    if IsPortrait then -- TODO
        local UITool = require("app.common.UITool")
        UITool.setTitleStyle(ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_title"))
        UITool.setTitleStyle(ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_title2"))
    else
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close");
    btn_close:addTouchEventListener(handler(self,onClickCallBack));
    self.listview = ccui.Helper:seekWidgetByName(self.m_pWidget,"lst_item")
    local widget = ccui.Helper:seekWidgetByName(self.m_pWidget, "Panel_content")
    widget:setVisible(false)
    -- self.listview:addEventListener(function(listview, pEventType) 
    --     if pEventType == ccui.ListViewEventType.ONSELECTEDITEM_END then  -- 不脱手的时候不需要改变ListView的Item情况1`q            
    --         showClickState(self,listview:getCurSelectedIndex()+1)
    --     end
    --     print(pEventType)
    -- end)
    if IsPortrait then -- TODO
        local widgetBg = ccui.Helper:seekWidgetByName(self.m_pWidget, "Panel_bg_content")
        widgetBg :setVisible(false)

        local btn_confirm = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_confirm")
        btn_confirm:addTouchEventListener(handler(self,onClickCallBack))
    else
        local title = ccui.Helper:seekWidgetByName(self.m_pWidget, "xiaoxi")
        title:enableShadow(cc.c4b(0, 0, 0,255),cc.size(2,-2));
    end
    
    initListView(self)
end

local function changeMailIcon(self,mailID)
    local item = getItemByID(self,mailID)
    if item then
        local mailicon = ccui.Helper:seekWidgetByName(item, "Image_box")
        mailicon:loadTexture("real_res/1004608.png")
    end
end

--[[
    --显示邮件内容
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

function EmailPanel:ShowEmailContent(pInfo)
    LoadingView.getInstance():hide();
    if not self.ContentPanel then
        local widget = ccui.Helper:seekWidgetByName(self.m_pWidget, "Panel_content")
        self.ContentPanel = EmailContent.new(widget)
    end
    if IsPortrait then -- TODO
        -- bg shadow
        local widgetBg = ccui.Helper:seekWidgetByName(self.m_pWidget, "Panel_bg_content")
        widgetBg:setVisible(true)
    end
    self.ContentPanel:initData(pInfo)
    readEmail(pInfo.maI)
    changeMailIcon(self,pInfo.maI)
    -- initListView(self)
    showClickState(self, pInfo)
end


--[[
    --物品领取成功
    type = 5,code=50025, 提取附件  c<->s
    -------------------------------
    ##  maI  long  mail id
    ##  ty  int  邮件类型 0 系统邮件，1 用户邮件
    ##  st  int  领取状态（0 成功，1 邮件不存在 2 无奖励）
]]
function EmailPanel:getItemSucceed(pInfo)
    if pInfo == {} then
        print("[ ERROR ] EmailPanel:getItemSucceed")
        return
    end
    removeEmail(self,pInfo.maI);
    if not IsPortrait then -- TODO
        Toast.getInstance():show("领取成功");
    end
end


--[[
    --新增邮件
    type = 5,code=50026, 新增一条消息  s->c
    -------------------------------
    ##  maI  int  邮件Id
    ##  ti  String  标题
    ##  maT  int  邮件类型 0 系统邮件[无读取状态] 1用户邮件
    ##  stT  String  上线时间
    ##  enT  String  结束时间
]]
function EmailPanel:newEmail(pInfo)
    local _Data = kUserData_userExtInfo:getInstance():getEmailData()
    table.insert(_Data,1,pInfo)         --插入表中,后面的顺序变化
    local maxMail = 50
    if #_Data > maxMail then                 --删除超出50封的邮件
        table.remove(_Data,#_Data)
    end
    initListView(self)
    Toast.getInstance():show("收到新消息");
end


--[[
    --邮件删除成功
    type = 5,code=50027, 删除邮件 c<->s
    -------------------------------
    ##  maI  long  mail id
    ##  ty  int  邮件类型 0 系统邮件，1 用户邮件
    ##  st  int  领取状态（0 成功，1 邮件不存在）
]]
function EmailPanel:EmailDelete(pInfo)
    if pInfo == {} then
        print("[ ERROR ] EmailPanel:EmailDelete")
        return
    end
    removeEmail(self,pInfo.maI);
    Toast.getInstance():show("删除成功");
end

--[[
     type = 5,code=50020, 操作功能性邮件 c<->s
     -------------------------------
 
     ##  maI  long  mail id
     ##  acS  int  操作动作(0 未操作，1 同意，2 不同意)
     ##  st  int  领取状态（0 成功，1 邮件不存在，2 非功能性邮件    
--]]
function EmailPanel:EmailApplyBear(pInfo)
    -- Log.i("self.ContentPanel........",tolua.isnull(self.ContentPanel))
    if (pInfo.ms and pInfo.ms ~= "") or self.ContentPanel ~= nil  then
        self.ContentPanel:applyBear(pInfo)
    end
end

EmailPanel.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_CONTEXTINFO]    = EmailPanel.ShowEmailContent;           --如果是一个局部方法，会如何
    [HallSocketCmd.CODE_REC_GETITEM]        = EmailPanel.getItemSucceed;
    [HallSocketCmd.CODE_REC_NEWMAIL]        = EmailPanel.newEmail;
    [HallSocketCmd.CODE_SEND_PICKUP]        = EmailPanel.EmailDelete;
    [HallSocketCmd.CODE_REC_CLUB_APPLY]     = EmailPanel.EmailApplyBear;        --申请结果
};

return EmailPanel