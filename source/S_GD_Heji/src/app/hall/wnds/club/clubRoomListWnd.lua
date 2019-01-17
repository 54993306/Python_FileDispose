-----------------------------------------------------------
--  @file   ClubRoomListWnd.lua
--  @brief  亲友圈房间列表
--  @author Huang Rulin
--  @DateTime:2017-07-31 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================


local ClubRoomListProcesser = class("ClubRoomListProcesser", FriendRoomSocketProcesser)

local clubRoomModel = require("app.hall.wnds.club.clubRoomModel")

local RequestRoomCount = 30

function ClubRoomListProcesser:ctor(delegate)
    ClubRoomListProcesser.super.ctor(self, delegate)

    local severCmdEventFuncMap = {}

    severCmdEventFuncMap[HallSocketCmd.CODE_FRIEND_ROOM_ENTER] = self.s_severCmdEventFuncMap[HallSocketCmd.CODE_FRIEND_ROOM_ENTER]
    severCmdEventFuncMap[HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = self.s_severCmdEventFuncMap[HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO]
    severCmdEventFuncMap[HallSocketCmd.CODE_REC_CLUBMODEL] = self.s_severCmdEventFuncMap[HallSocketCmd.CODE_REC_CLUBMODEL]


    severCmdEventFuncMap[HallSocketCmd.CODE_REC_CLUBROOMLIST]     = self.directForward;

    self.s_severCmdEventFuncMap = severCmdEventFuncMap
end


local ClubRoomListWnd = class("ClubRoomListWnd", UIWndBase)
local CircleClippingNode = require("app.games.common.custom.CircleClippingNode")
local ClubMemberTypeWnd = require("app.hall.wnds.club.clubMemberTypeWnd")
local ClubMatchRecord = require("app.hall.wnds.club.clubMatchRecord")

function ClubRoomListWnd:ctor(clubInfo, mode)
    self.super.ctor(self,"hall/clubRoomListWnd.csb")
    self.mode = mode
    self.clubInfo = clone(clubInfo)
    Log.d("=========>>> ClubRoomListWnd " , clubInfo)
    self.m_SocketProcesser = ClubRoomListProcesser.new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_SocketProcesser)
end

function ClubRoomListWnd:onClose()
    if self.m_SocketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_SocketProcesser)
        self.m_SocketProcesser = nil
    end
end

function ClubRoomListWnd:btnCallBack(widget, touchType)
    if touchType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if widget:getName() == "btn_close" then
            self:keyBack()
        elseif widget:getName() == "btn_clubInfo" then
            UIManager.getInstance():pushWnd(ClubMemberTypeWnd, self.clubInfo, self.mode)
        elseif widget:getName() == "btn_myRecord" then
            UIManager.getInstance():pushWnd(ClubMatchRecord, self.clubInfo)
        elseif widget:getName() == "btn_refreshList" then
            self:getRoomList(1, RequestRoomCount)
        elseif widget:getName() == "btn_model" then
            LoadingView.getInstance():show("获取模版列表中...")
            SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_CLUBMODEL)
        elseif widget:getName() == "btn_invite" then
            if kServerInfo:getCantEnterRoom() then -- 即将维护, 禁止开局
                Toast.getInstance():show("服务器即将进行维护! ")
                return
            end
            -- local data = {}
            -- data.cmd = NativeCall.CMD_CLIPBOARD_COPY;
            -- data.content = tostring(self.clubInfo.clubID)
            -- Log.i("-----copy code----->" .. data.content)
            -- NativeCall.getInstance():callNative(data);
            -- local CommonTips = require "app.hall.common.CommonTips"
            -- local data = {}
            -- data.content = "亲友圈ID已复制，请前往微信分享"
            -- UIManager.getInstance():pushWnd(CommonTips, data)

            local data = {};
            data.clubInfo = kSystemConfig:getOwnerClubInfo();
            if next(data.clubInfo) then--kSystemConfig:IsClubOwner() and
                UIManager:getInstance():pushWnd(FriendRoomCreate, data)
            elseif next(self.clubInfo) then
                data.clubInfo = self.clubInfo
                UIManager:getInstance():pushWnd(FriendRoomCreate, data)
            else
                Toast.getInstance():show("亲友圈信息已过期，请重新打开本界面")
            end
        end
    end
end

function ClubRoomListWnd:checkBoxCallFunc(checkBox)
    self.checkBoxAll:setSelected(false)
    self.checkBoxLackOne:setSelected(false)
    if IsPortrait then -- TODO
        self.checkBoxAll.labTxt:setColor(cc.c3b(0x33, 0x33, 0x33))
        self.checkBoxLackOne.labTxt:setColor(cc.c3b(0x33, 0x33, 0x33))
        checkBox:setSelected(true)
        checkBox.labTxt:setColor(cc.c3b(0x33, 0x33, 0x33))
    else
        self.checkBoxAll.labTxt:setColor(cc.c3b(255, 255, 255))
        self.checkBoxLackOne.labTxt:setColor(cc.c3b(255, 255, 255))
        checkBox:setSelected(true)
        checkBox.labTxt:setColor(cc.c3b(38, 204, 38))
    end

    local needRefresh =  false
    if checkBox == self.checkBoxLackOne then
        needRefresh = self.showType ~= 2
        self.showType = 2
    else
        needRefresh = self.showType ~= 1
        self.showType = 1
    end
    Log.i("refresh checkBoxCallFunc " .. self.showType)
    if needRefresh then
        self:refreshRoomList(self.mRoomList, self.showType)
    end
end

function ClubRoomListWnd:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end

    local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close")
    btn_close:addTouchEventListener(handler(self, ClubRoomListWnd.btnCallBack))

    local btnsPanel = self.m_pWidget
    if not IsPortrait then
        if kUserInfo:getUserId() == self.clubInfo.clubOwnerID then  -- 不是我的俱乐部不显示管理房间模版按钮
            self.pan_model = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_model")
            self.pan_btns = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_btns")
            btnsPanel = self.pan_model
            btnsPanel:setVisible(true)
            self.pan_btns:setVisible(false)

            local btn_model = ccui.Helper:seekWidgetByName(btnsPanel,"btn_model")
            btn_model:addTouchEventListener(handler(self, ClubRoomListWnd.btnCallBack))
        end
    end
    local btn_clubInfo = ccui.Helper:seekWidgetByName(btnsPanel,"btn_clubInfo")
    btn_clubInfo:addTouchEventListener(handler(self, ClubRoomListWnd.btnCallBack))

    local btn_myRecord = ccui.Helper:seekWidgetByName(btnsPanel,"btn_myRecord")
    btn_myRecord:addTouchEventListener(handler(self, ClubRoomListWnd.btnCallBack))

    local btn_invite = ccui.Helper:seekWidgetByName(btnsPanel,"btn_invite")
    btn_invite:addTouchEventListener(handler(self, ClubRoomListWnd.btnCallBack))

    local btn_refreshList = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_refreshList")
    btn_refreshList:addTouchEventListener(handler(self, ClubRoomListWnd.btnCallBack))

    local roomModel = ccui.Helper:seekWidgetByName(self.m_pWidget, "roomItemModel")
    self.roomList = ccui.Helper:seekWidgetByName(self.m_pWidget, "list_rooms")
    self.roomList:setItemModel(roomModel:clone())
    roomModel:setVisible(false)

    if IsPortrait then
        self.magModel = ccui.Helper:seekWidgetByName(self.m_pWidget, "magmodel")
        self.magModel:setVisible(false)
    end

    self.lab_memberNum = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_memberNum")
    self.lab_diamondState = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_diamondState")
    self.lab_title = ccui.Helper:seekWidgetByName(self.m_pWidget, "title")
    self.lab_noRoomTip = ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_noRoomTip")

    self.checkBoxAll = ccui.Helper:seekWidgetByName(self.m_pWidget,"checkbox_allRoom")
    self.checkBoxLackOne = ccui.Helper:seekWidgetByName(self.m_pWidget,"checkbox_lackOne")

    self.checkBoxAll.labTxt = ccui.Helper:seekWidgetByName(self.checkBoxAll,"lab_txt")
    self.checkBoxLackOne.labTxt = ccui.Helper:seekWidgetByName(self.checkBoxLackOne,"lab_txt")

    local btn_allRoom = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_allRoom")
    self:addWidgetClickFunc(btn_allRoom, function() self:checkBoxCallFunc(self.checkBoxAll) end)
    local btn_lackOne = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_lackOne")
    self:addWidgetClickFunc(btn_lackOne, function() self:checkBoxCallFunc(self.checkBoxLackOne) end)

    self.img_down = ccui.Helper:seekWidgetByName(self.m_pWidget , "img_down")
    self.img_up = ccui.Helper:seekWidgetByName(self.m_pWidget , "img_up")
    self.img_down:setVisible(false)
    self.img_up:setVisible(false)

    self.showType = 1
    self.checkBoxAll:setSelected(true)

    self:refreshClubInfo()

    --to req room list
    self:getRoomList(1, RequestRoomCount)

    kFriendRoomInfo:setRoomState(CreateRoomState.normal)

    local curUserid = kUserInfo:getUserId()
    local userToken = kUserInfo:getUserToken()

    local phpVa = kSystemConfig:getPHPActivityList()


    local function onFinish(nErrorCode,tData)
        if nErrorCode == -1 then
           return
        end
        self.m_activityData = tData
        Log.d("self.m_activityData....",self.m_activityData)
        self:initLiangYouInf(self.m_activityData)
    end
    if phpVa and phpVa.act_switch and tonumber(phpVa.act_switch) == 1 and phpVa.act_request and table.nums(phpVa.act_request) > 0 then
        local phpLogin = phpVa.act_request[1]
        if phpLogin and phpLogin.club and phpLogin.club ~= "" then
            local htURL = string.format("%s?clubid=%s&product_id=%s&usertoken=%s",phpLogin.club,self.clubInfo.clubID,PRODUCT_ID,userToken)
            self:getURLData(htURL,function(activityData)
                if activityData and activityData.status == nil and table.nums(activityData) > 0 then
                    local data = {}
                    data.clubid = self.clubInfo.clubID
                    data.activityData = activityData
                    UIManager:getInstance():pushWnd(LiangYouClubTips,data)
                end
            end)
        end
    end
end

function ClubRoomListWnd:getURLData(url, hookFun)
    Log.i("HttpManager.getURL", "-------url = " .. url);
    local onReponseGetURL = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseUrl code", code);
            return;
        end
        Log.i("HttpManager.getURL");

        local body=request:getResponseString()
        local json = json.decode(body)
        hookFun(json)
    end
    --
    local request = network.createHTTPRequest(onReponseGetURL, url, "POST");
    request:start();
end


function ClubRoomListWnd:getRoomList(pageIdx, pageCount)
    LoadingView.getInstance():show("获取房间列表中...")
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_CLUBROOMLIST, {clI = self.clubInfo.clubID, pa = pageIdx, roN = pageCount})
end

function ClubRoomListWnd:refreshClubInfo()
    if IsPortrait then -- TODO
        Util.updateNickName(self.lab_title, ToolKit.subUtfStrByCn(self.clubInfo.clubName, 0, 9, "..."))
    else
        local clibLabel =string.sub(self.clubInfo.clubName, #self.clubInfo.clubName-8, #self.clubInfo.clubName)
        local userName = string.sub(self.clubInfo.clubName,1, #self.clubInfo.clubName-9)
        local clibName = ToolKit.subUtfStrByCn(userName, 0, 6, "...") .. clibLabel
        Util.updateNickName(self.lab_title, clibName)
    end
    self.lab_memberNum:setString(string.format("%d", self.clubInfo.clubMemNum))
    local diaStr, diaClr = Util.formatClubDiamondSt(self.clubInfo.diamondSt)
    self.lab_diamondState:setString(diaStr)
    self.lab_diamondState:setColor(diaClr)
end


function ClubRoomListWnd:initMagRoomModel()
    -- 只有亲友圈群主才能显示房间模版管理功能
    if not kSystemConfig:IsClubOwner() then return end
    if kUserInfo:getUserId() ~= self.clubInfo.clubOwnerID then  -- 不是我的俱乐部不显示管理房间模版按钮
        return
    end
    if not IsPortrait then
        return
    end
    local item = self.magModel:clone()
    item:setVisible(true)
    self.roomList:pushBackCustomItem(item);

    local whatpan = ccui.Helper:seekWidgetByName(item, "pan_mag")
    whatpan:addTouchEventListener(function (pWidget, EventType)
                    if EventType == ccui.TouchEventType.ended then
                        UIManager.getInstance():pushWnd(clubRoomModel , {showtips = true});
                    end
                end)

    local btn_roommodel = ccui.Helper:seekWidgetByName(item, "btn_roommodel")
    btn_roommodel:addTouchEventListener(function (pWidget, EventType)
                    if EventType == ccui.TouchEventType.ended then -- 拉取房间模版列表
                        LoadingView.getInstance():show("获取模版列表中...")
                        SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_CLUBMODEL)
                        -- UIManager.getInstance():pushWnd(clubRoomModel);
                    end
                end)
end

function ClubRoomListWnd:initTipsArrow(size)
    Log.i("ClubRoomListWnd:initTipsArrow :" .. tostring(size))
    -- if not IsPortrait then
    --     return
    -- end
    self.img_down:setVisible(false)
    self.img_up:setVisible(false)
    self.img_up:stopAllActions()
    self.img_down:stopAllActions()
    local move1 = cc.MoveBy:create(0.5,cc.p(0,15))
    local move2 = cc.MoveBy:create(0.5,cc.p(0,-15))
    self.img_up:runAction(cc.RepeatForever:create(cc.Sequence:create(move1:clone(),cca.fadeOut(0.2),move2:clone(),cca.fadeIn(0.1))))
    self.img_down:runAction(cc.RepeatForever:create(cc.Sequence:create(move2:clone(),cca.fadeOut(0.2),move1:clone(),cca.fadeIn(0.1))))

    self.first = true
    self.roomList:addScrollViewEventListener(
    function(pListWidget, pEventType)
        if size <= 4 then
            return
        end   -- 4个item不显示箭头
        if pEventType == ccui.ScrollviewEventType.scrollToBottom then
            -- print("ClubRoomListWnd scrollToBottom")
             self.img_down:setVisible(false)
        elseif pEventType == ccui.ScrollviewEventType.bounceBottom then
            -- print("ClubRoomListWnd bounceBottom")
             self.img_down:setVisible(false)
        elseif pEventType == ccui.ScrollviewEventType.scrolling then
            if self.first then
                self.first = false
                self.img_up:setVisible(false)
                return
            end
            self.img_down:setVisible(true)
            self.img_up:setVisible(true)
        elseif pEventType == ccui.ScrollviewEventType.scrollToTop then
            -- print("ClubRoomListWnd scrollToTop")
            self.img_up:setVisible(false)
        elseif pEventType == ccui.ScrollviewEventType.bounceTop then
            self.img_up:setVisible(false)
            -- print("ClubRoomListWnd bounceTop")
        end
    end)
    if size > 4 then
        self.img_down:setVisible(true)
    end
end

-- 对添加房间类别进行判断
function ClubRoomListWnd:judgeAddItem(data , showType)
    local mjDescMap = kFriendRoomInfo:getMjDescInfoMap()
    if  GC_GameTypes[data.gaI] ~= nil
    and mjDescMap[data.gaI] ~= nil
    and (   kSystemConfig:IsClubOwner()
            or (data.roI ~= nil and data.roI ~= 0 )
            or (data.teI ~= nil and data. teI ~= 0))
    and ((showType == 2 and #data.meL == data.roAUC-1) or showType ~= 2) then --本地有对应麻将包以及服务器有推送该麻将
        if self.lab_noRoomTip:isVisible() then self.lab_noRoomTip:setVisible(false) end
        return mjDescMap[data.gaI].gameName
    end
    return ""
end

function ClubRoomListWnd:refreshRoomList(roomsData, showType)
    self.roomList:removeAllChildren()
    self:initMagRoomModel()
    self.netImgsTable = {}
    if type(roomsData) ~= "table" then
        return
    end
    Log.i("------------refreshRoomList",roomsData)

    self.lab_noRoomTip:setVisible(true)
    local itemsize = 0
    for i,data in ipairs(roomsData) do
        local gameName = self:judgeAddItem(data , showType)
        if gameName ~= "" then
            itemsize = itemsize + 1
            self.roomList:pushBackDefaultItem()
            local lay = self.roomList:getItem(#self.roomList:getItems() - 1)
            if data.teI and data.teI ~=  0 then
                lay:setColor(cc.c4b(255,255,50,255))
            end

            local btnClickCall = function(roomID)
                if (data.roI == nil or data.roI == 0) and (not data.teI or data.teI ==  0) then
                    return
                end
                LoadingView.getInstance():show("正在进入,请稍后......");
                local tmpData={}
                tmpData.pa = roomID
                tmpData.teI = data.teI or 0
                tmpData.clI = self.clubInfo.clI or self.clubInfo.clubID
                FriendRoomSocketProcesser.sendRoomEnter(tmpData)
            end

            for j=1, 4 do
                local playerPanel = ccui.Helper:seekWidgetByName(lay, string.format("player_panel_%d", j))
                local labName = ccui.Helper:seekWidgetByName(playerPanel, "player_name")
                local head = ccui.Helper:seekWidgetByName(playerPanel, "img_head")
                local roomOwner = ccui.Helper:seekWidgetByName(playerPanel, "img_room_owner")
                local waitHead = ccui.Helper:seekWidgetByName(playerPanel, "img_waitHead")
                local btn_join = ccui.Helper:seekWidgetByName(playerPanel, "btn_join")
                if #data.meL >= j then
                    local memberInfo = data.meL[j]
                    waitHead:setVisible(false)
                    Util.updateNickName(labName, ToolKit.subUtfStrByCn(memberInfo.usN,0,5,""))
                    roomOwner:setVisible(data.owI == memberInfo.usI)
                    if memberInfo.usA and string.len(memberInfo.usA) > 4 then
                        local imgName = memberInfo.usI .. ".jpg"
                        local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName)
                        if io.exists(headFile) then
                            --[[head:removeAllChildren()
                            local cirHead = CircleClippingNode.new(headFile, true, head:getContentSize().width)
                            cirHead:setPosition(head:getContentSize().width/2, head:getContentSize().height/2)
                            head:addChild(cirHead)--]]
                            if not IsPortrait then
                                local headIamge = CircleClippingNode.new(headFile, true , 80)
                                headIamge:setPosition(head:getContentSize().width/2, head:getContentSize().height/2)
                                head:addChild(headIamge);
                            else
                                head:loadTexture(headFile);
                            end
                        else
                            self.netImgsTable[imgName] = head
                            HttpManager.getNetworkImage(memberInfo.usA, imgName)
                        end
                    end
                else
                    if j > data.roAUC then
                        playerPanel:setVisible(false)
                    else
                        roomOwner:setVisible(false)
                        labName:setString("待加入")
                        self:addWidgetClickFunc(btn_join, function() btnClickCall(data.roI) end)
                    end
                end
            end

            --设置麻将信息
            local mj_image = ccui.Helper:seekWidgetByName(lay, "mj_image")
            local pk_image = ccui.Helper:seekWidgetByName(lay, "pk_image")
            if data.gaI > 20000 then
                pk_image:setVisible(true)
            else
                mj_image:setVisible(true)
            end

            local lab_roomInfo = ccui.Helper:seekWidgetByName(lay, "lab_roomInfo")
            lab_roomInfo:setString(string.format("%s", gameName))
            local lab_rulerInfo = ccui.Helper:seekWidgetByName(lay, "lab_rulerInfo")
            if data.gaI == 10029 and data.roRC >= 50 then
                lab_roomInfo:setString(string.format("%s(%s)", gameName, "进园子"))
                lab_rulerInfo:setVisible(false)
            elseif data.gaI == 20011 and string.find(data.ru,"|shengji") then
                if data.roRC == 4 or data.roRC == 40 then
                    lab_rulerInfo:setString("过6")
                elseif data.roRC == 8 or data.roRC == 80 then
                    lab_rulerInfo:setString("过10")
                elseif data.roRC == 12 or data.roRC == 120 then
                    lab_rulerInfo:setString("过A")
                end
                lab_rulerInfo:setVisible(true)
            else
                lab_rulerInfo:setString(string.format("%d局",data.roRC))    -- 需要新增一个进度显示
                lab_rulerInfo:setVisible(true)
            end

            if IsPortrait then
                local lab_playNum = ccui.Helper:seekWidgetByName(lay, "lab_playNum")
                lab_playNum:setString(string.format("(%d人房)" , data.roAUC))
            end

            local wfList = kFriendRoomInfo:formatWafaData(data.ru, data.gaI)
            local wfStr = ""
            if #wfList > 0 then
                for len = 1, #wfList-1, 1 do
                    wfStr = wfStr..wfList[len]..","
                end
                wfStr = wfStr..wfList[#wfList]
            else
                wfStr = "当前房主未自定义玩法"
            end
            --wfStr = ToolKit.subUtfStrByCn(wfStr, 0, 13, "...")

            local lab_roomNum = ccui.Helper:seekWidgetByName(lay, "lab_roomNum")
            if (data.roI ~= nil and data.roI ~= 0) then
                if IsPortrait then
                    lab_roomInfo:setString(string.format("%s", gameName))
                end
                lab_roomNum:setString("房间号:"..data.roI)
            else
                lab_roomNum:setVisible(false)
            end

            local btn_mj_rule = ccui.Helper:seekWidgetByName(lay, "btn_mj_rule")
            btn_mj_rule:addTouchEventListener(function (pWidget, EventType)
                if EventType == ccui.TouchEventType.ended then
                    self:addMaJiangRule(wfStr,btn_mj_rule)
                end
            end)
            local labYingcang = ccui.Helper:seekWidgetByName(lay,"lab_yingcang")
            labYingcang:setVisible(false)
            local joinBtn = ccui.Helper:seekWidgetByName(lay, "btn_enterRoom")
            if (data.roRUC == 0 or data.roI == nil or data.roI == 0)
                and (not data.teI or data.teI ==  0) then
                joinBtn:setVisible(false)
                if data.roI == nil or data.roI == 0 then
                    labYingcang:setVisible(true)
                end
            end
            self:addWidgetClickFunc(joinBtn, function() btnClickCall(data.roI) end)
        end
    end
    self:initTipsArrow(itemsize)
end

function ClubRoomListWnd:addMaJiangRule(content,btn)
    if IsPortrait then -- TODO
            if not content or content == ""then
            return
        end
        if self.mjRuleTips then
            self.mjRuleTips:removeFromParent()
            self.mjRuleTips = nil
        end
        self.mjRuleTips = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/mjRuleTips.csb")
        self.mjRuleTips:addTouchEventListener(function(obj,event)
            if event == ccui.TouchEventType.ended then
                self.mjRuleTips:setVisible(false)
                self.mjRuleTips:removeAllChildren()
                self.mjRuleTips = nil
            end
        end)
        self.m_pWidget:addChild(self.mjRuleTips,10)
        self.mjRuleTips:setAnchorPoint(cc.p(0,1))
        rule_lable = ccui.Helper:seekWidgetByName(self.mjRuleTips, "rule_lable")
        rule_lable:setString("")
        bg_img = ccui.Helper:seekWidgetByName(self.mjRuleTips, "bg_img")
        local pos_x,pos_y = btn:getPosition()
        local parentPos_Y = btn:getParent():getPositionY()
        local listPosY = self.roomList:getContentSize().height--setMargin
        local world_pos = btn:getParent():convertToWorldSpace(cc.p(pos_x,pos_y))
        local content_txt = ccui.Text:create();
        content_txt:setFontName("hall/font/fangzhengcuyuan.TTF")
        content_txt:setColor(cc.c3b(255,255,255))
        content_txt:setTextAreaSize(cc.size(330, 0));
        content_txt:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        content_txt:setString(content);
        content_txt:setFontSize(26);
        content_txt:ignoreContentAdaptWithSize(false)
        local visibleWidth = cc.Director:getInstance():getOpenGLView():getFrameSize().width
        local visibleHeight = cc.Director:getInstance():getOpenGLView():getFrameSize().height

        if visibleHeight/visibleWidth >= 1.78 then
            world_pos.y = world_pos.y - 1280*(visibleHeight/visibleWidth - 1.78)/2 - 50
        end

        local tab_size = content_txt:getContentSize()
        bg_img:setContentSize(cc.size(tab_size.width + 20, tab_size.height + 20))
        local size = bg_img:getContentSize()
        bg_img:setPosition(cc.p(world_pos.x - size.width/2 - 10, world_pos.y + 30))
        content_txt:setPosition(cc.p(size.width/2,size.height/2))
        bg_img:addChild(content_txt)
    else
        if self.mjRuleTips then
            self.mjRuleTips:removeFromParent()
            self.mjRuleTips = nil
        end
        self.mjRuleTips = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/mjRuleTips.csb")
        self.mjRuleTips:addTouchEventListener(function(obj,event)
            if event == ccui.TouchEventType.ended then
                self.mjRuleTips:setVisible(false)
            end
        end)
        self.m_pWidget:addChild(self.mjRuleTips,10)

        local rule_lable = ccui.Helper:seekWidgetByName(self.mjRuleTips, "rule_lable")
        rule_lable:setString("")
        local bg_img = ccui.Helper:seekWidgetByName(self.mjRuleTips, "bg_img")
        local pos_x,pos_y = btn:getPosition()
        local world_pos = btn:getParent():convertToWorldSpace(cc.p(pos_x,pos_y))
        bg_img:setAnchorPoint(cc.p(0.5,0))

        local visibleWidth = cc.Director:getInstance():getOpenGLView():getFrameSize().width
        local visibleHeight = cc.Director:getInstance():getOpenGLView():getFrameSize().height

        if visibleHeight/visibleWidth >= 1.78 then
            world_pos.y = world_pos.y - 1280*(visibleHeight/visibleWidth - 1.78)/2 - 50
        end


        local content_txt = ccui.Text:create();
        content_txt:setFontName("hall/font/fangzhengcuyuan.TTF")
        content_txt:setColor(cc.c3b(255,255,255))
        content_txt:setTextAreaSize(cc.size(450, 0));
        content_txt:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        content_txt:setString(content);
        content_txt:setFontSize(26);
        content_txt:ignoreContentAdaptWithSize(false)
        bg_img:addChild(content_txt)

        local tab_size = content_txt:getContentSize()
        bg_img:setContentSize(cc.size(tab_size.width + 20, tab_size.height + 20))
        local size = bg_img:getContentSize()
        bg_img:setPosition(cc.p(world_pos.x, world_pos.y + 30))
        content_txt:setPosition(cc.p(size.width/2,size.height/2))
    end
end

function ClubRoomListWnd:onResponseNetImg(imgName)
    local headImg = self.netImgsTable[imgName];
    local imageName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
    if not tolua.isnull(headImg) and io.exists(imageName) then
        if IsPortrait then -- TODO
            headImg:loadTexture(imageName);
        else
            headImg:removeAllChildren()
            local cirHead = CircleClippingNode.new(imageName, true, 80)
            cirHead:setPosition(headImg:getContentSize().width/2, headImg:getContentSize().height/2)
            headImg:addChild(cirHead)
        end
    end
end

function ClubRoomListWnd:recClubRoomList(info)
    if self.clubInfo.clubID == info.clI then
        self.clubInfo.clubName    = info.clN
        self.clubInfo.clubOwnerName = info.clON
        self.clubInfo.clubOlNum   = info.clOMC
        self.clubInfo.clubMemNum  = info.clAMC
        self.clubInfo.diamondSt   = info.diRS

        LoadingView.getInstance():hide()
        self:refreshClubInfo()
        self.mRoomList = info.roL
        self:refreshRoomList(self.mRoomList, self.showType)
    end
end

function ClubRoomListWnd:recvGetRoomEnter(packetInfo)
    --## re  int  结果（-2 = 无可用房间，1 成功找到）
    --Log.i("进入结果：" .. tmpData.re)
    local tmpData = packetInfo
    Log.i("进入结果：", tmpData)
    LoadingView.getInstance():hide();
    if(-1 == tmpData.re) then
      Toast.getInstance():show("人数已满");
    elseif(-2 == tmpData.re) then
      Toast.getInstance():show("房主已解散该房间");
    elseif -3 == tmpData.re then
        -- RoJST int   付费类型 1 =房主付费，2 =大赢家付费，3 =AA付费
        if tmpData.RoJST and tmpData.RoJST == 2 then
            Toast.getInstance():show("该房间为大赢家付房费，您钻石不足")
            return
        elseif tmpData.RoJST and tmpData.RoJST == 3 then
            Toast.getInstance():show("该房间为AA制付房费，您钻石不足")
            return
        else
            Toast.getInstance():show("钻石不足!")
        end
    elseif(-4 == packetInfo.re) then
        Toast.getInstance():show("您不是该亲友圈亲友");
    elseif (-7 == packetInfo.re) then
        Toast.getInstance():show("服务器关服倒计时中");
    elseif (-8 == packetInfo.re) then
        Toast.getInstance():show("模板不存在或已被删除，请刷新");
    elseif (-9 == packetInfo.re) then
        Toast.getInstance():show("亲友圈不存在，请联系客服");
    elseif (-10 == packetInfo.re) then
        Toast.getInstance():show("创建模板房间失败");
    elseif tmpData.re == 1 and packetInfo.pa and packetInfo.pa > 0 then
      kFriendRoomInfo:saveNumber(packetInfo.pa);
    elseif(-5 == tmpData.re) then
        self:showDialog(tmpData)
   end
end

function ClubRoomListWnd:showDialog(tmpData)
    local data = {}
    data.type = 2;
    data.textSize = 30
    data.title = "提示";
    data.yesStr = "是"
    data.cancalStr = "联系客服"
    data.content = string.format("您的房间信息异常，您已在房间%s内登陆，是否重新登陆恢复。",(tmpData and tmpData.roI) and tmpData.roI or "");
    data.subjoin = string.format( "您的游戏id为%s",kUserInfo:getUserId())
    data.handle = "(复制)"
    data.yesCallback = function()
        -- MyAppInstance:exit()
        SocketManager.getInstance():closeSocket()
        local info = {};
        info.isExit = true;
        UIManager.getInstance():replaceWnd(HallLogin, info);
        SocketManager.getInstance():openSocket()
    end
    data.cancalCallback = function ()
        self:onOpenKf()
    end
    UIManager.getInstance():pushWnd(CommonDialog, data);
    LoadingView.getInstance():hide()
end
function ClubRoomListWnd:onOpenKf()
    local data = {};
    data.cmd = NativeCall.CMD_KE_FU;
    data.uid, data.uname = self.getKfUserInfo()
    NativeCall.getInstance():callNative(data, self.kefuCallBack, self)

end
function ClubRoomListWnd:kefuCallBack(result)
    local event = cc.EventCustom:new(LocalEvent.HallCustomerService)
    event._userdata = result
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function ClubRoomListWnd:getKfUserInfo()
    local uid = kUserInfo:getUserId();
    local uname = kUserInfo:getUserName();
    if uid == 0 then
        local lastAccount = kLoginInfo:getLastAccount();
        if lastAccount and lastAccount.usi then
            uid = lastAccount.usi
        end
    end

    if uname == "" or uname == nil then
        if uid == nil or uid == 0 then
            uname = "游客"
        else
            uname = "游客"..uid
        end
    end

    --此时uid需要传入字符串类型.否则ios那边解析会出问题.
    return ""..uid, uname
end
function ClubRoomListWnd:recvRoomSceneInfo(packetInfo)
    Log.i("ClubRoomListWnd ClubRoomListWnd:recvRoomSceneInfo......")
    Log.i("packetInfo", packetInfo)
    LoadingView.getInstance():hide();

    local data = {};
    data.isFirstEnter = true;
    local gameId = packetInfo.gaID or kFriendRoomInfo:getGameID()
    if loadGame(gameId) then
        UIManager:getInstance():popToWnd(HallMain, true);
        UIManager:getInstance():pushWnd(FriendRoomScene);
    else
        Toast.getInstance():show("未配置该游戏: ID " .. gameId)
    end
end

function ClubRoomListWnd:showRoomModel(packageinfo)
    self:keyBack()
    LoadingView.getInstance():hide()

    local data = {};
    data.clubInfo = kSystemConfig:getOwnerClubInfo();
    -- Log.i("=========== >> showRoomModel1 :" , data.clubInfo)
    if not next(data.clubInfo) then
        data.clubInfo = self.clubInfo
    end
    packageinfo.clubInfo = data.clubInfo or {}
    UIManager.getInstance():pushWnd(clubRoomModel,packageinfo);
end

--网络接收接口定义
ClubRoomListWnd.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_CLUBROOMLIST]    = ClubRoomListWnd.recClubRoomList;
    [HallSocketCmd.CODE_FRIEND_ROOM_ENTER] = ClubRoomListWnd.recvGetRoomEnter; --InviteRoomEnter    进入邀请房结果
    [HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = ClubRoomListWnd.recvRoomSceneInfo; --InviteRoomEnter    邀请房信息
    [HallSocketCmd.CODE_REC_CLUBMODEL] = ClubRoomListWnd.showRoomModel; --InviteRoomEnter    显示房间模版
}


return ClubRoomListWnd
