local InviteFriendView = class("InviteFriendView", UIWndBase)
local Str_Diamond = ""--"钻石"
local Str_DiamondMeasure ="" --"颗"
local PlayerListDialog = require("app.hall.wnds.PlayerListDialog")
local CircleClippingNode = require("app.games.common.custom.CircleClippingNode")
local ShareToWX = require "app.hall.common.ShareToWX"
local UmengClickEvent = require("app.common.UmengClickEvent")
local BackEndStatistics = require("app.common.BackEndStatistics")

function InviteFriendView:ctor()
    self.super.ctor(self, "hall/obtain_diamond.csb");
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    self.m_head_imgs = {};
    self.m_data = kUserInfo:getInviteInfo()

    self.socketProcesser = InviteRewardSocketProcesser.new(self)
    SocketManager:getInstance():addSocketProcesser(self.socketProcesser)
end

function InviteFriendView:onClose()
    if self.socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.socketProcesser);
        self.socketProcesser = nil;
    end
end

function InviteFriendView:initFirstView()
    self.ListView = ccui.Helper:seekWidgetByName(self.m_pWidget, "ListView");
    local list_item = ccui.Helper:seekWidgetByName(self.m_pWidget, "list_item")
    list_item:setTouchEnabled(true)
    self.ListView:setItemModel( list_item:clone() )
    list_item:removeFromParent()

    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_shareFriend = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_friend");
    self.btn_shareFriend:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_shareCircle = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_circle");
    self.btn_shareCircle:addTouchEventListener(handler(self, self.onClickButton));

    self.lab_totalReward = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_totalReward");
    self.lab_jiangli = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_jiangli")


    self.lab_nextReward = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_nextReward");

    self.lab_inviteSyTip = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_inviteSyTip");
    self.lab_inviteId = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_inviteId");

    if IsPortrait then -- TODO
        self.lab_allInvited = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_allInvited");

        self.panel_canInvite = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_canInvite");
        self.panel_allInvited = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_allInvited");

        self.lab_noInviteTip = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_noInviteTip");
        self.lab_noInviteTip:setVisible(false)

        self.lab_invitedTip = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_invitedTip");
        self.lab_invitedTip:setString("")
    else
        self.diamound_img = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_41_0");
        self.total_panel = ccui.Helper:seekWidgetByName(self.m_pWidget, "total_panel");
        self.panel_begin = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_begin");
        self.lab_inviteId_0 = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_inviteId_0");

        self.mark_noReword = ccui.Helper:seekWidgetByName(self.m_pWidget, "mark_noReword");
        self.mark_noInvite = ccui.Helper:seekWidgetByName(self.m_pWidget, "mark_noInvite");
        self.mark_noReword:setVisible(false)
        self.mark_noInvite:setVisible(false)
    end

    self.redTip = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_tips");
    self:initPlayerList()
end

function InviteFriendView:initHeadImage(item)
    local headImage = ccui.Helper:seekWidgetByName(item,"img_head")
    if item.data.he and string.len(item.data.he) > 4 then
        local imgName = string.format("%d.jpg",item.data.usI)
        local headPath = cc.FileUtils:getInstance():fullPathForFilename(imgName)
        if io.exists(headPath) then
            if IsPortrait then -- TODO
                headImage:loadTexture(headPath)
                headImage:removeAllChildren()
                local cirHead = CircleClippingNode.new(headPath, true, headImage:getContentSize().width)
                cirHead:setPosition(headImage:getContentSize().width/2, headImage:getContentSize().height/2)
            else
                headImage:removeAllChildren()
                local cirHead = CircleClippingNode.new(headPath, true, 80)
                cirHead:setPosition(headImage:getContentSize().width/2, headImage:getContentSize().height/2)
                headImage:addChild(cirHead)
            end
        else
            self.netImagesTable[imgName] = headImage
            HttpManager.getNetworkImage(item.data.he, imgName)
        end
        self.headImages[imgName] = headImage
    end
end

function InviteFriendView:initItem(item)
    local iNWidth = 320             --id的宽度
    if IsPortrait then -- TODO
        iNWidth = 410             --id的宽度
    end
    local itemName = ccui.Helper:seekWidgetByName(item,"lab_name") --item.data.na or ""
    local name = ToolKit.subUtfStrByCn(string.format("%s",item.data.na or ""), 0, 6, "...")
    Util.updateNickName(itemName, name, 20)
    local itemID   = ccui.Helper:seekWidgetByName(item,"lab_id") 
    local idStr = string.format("ID:%d",item.data.usI or 0)
    itemID:setString(idStr)
    local usIwidth,usILen = Util.getTextWidth(idStr,26)
    if IsPortrait then -- TODO
        usIwidth,usILen = Util.getTextWidth(idStr,32)
    end
    if usILen >= 10 then
        itemID:setFontSize(iNWidth/usILen)
    end
    self:initHeadImage(item)
end

function InviteFriendView:initPlayerList(  )
    if IsPortrait then -- TODO
        self.itemList = {}
        self.netImagesTable = {}
        self.headImages = {}
        -- for i = 1, 10 do
        --     local data = {};
        --     data.na = "1111111111111";
        --     data.usI = 1;
        --     table.insert(self.m_data.li, data);
        -- end

        if not self.m_data.li then end
        local playerList = {}
        for i,v in ipairs(self.m_data.li) do
            playerList[#playerList + 1] = {na = v.na, usI = v.usI, he = v.ic}
        end

        for i,data in pairs(playerList) do
            local lay = self.ListView:getItem((i-1)/2)
            if not lay then
                self.ListView:pushBackDefaultItem()
                lay = self.ListView:getItem(#self.ListView:getItems() - 1)
                lay.frontData = data
                for d=0,1 do
                    ccui.Helper:seekWidgetByName(lay, "panel_"..d):setVisible(false)
                end
            end
            lay.lastData = data
            local item = ccui.Helper:seekWidgetByName(lay, "panel_"..(i-1)%2)
            item:setVisible(true)
            item.data = data
            self:initItem(item)
            table.insert(self.itemList,item)
        end

        self.lab_noInviteTip:setVisible(#playerList == 0)
        self.lab_invitedTip:setString("已邀请: ".. #playerList .."人")
    else
        self.itemList = {}
        self.netImagesTable = {}
        self.headImages = {}
        -- for i = 1, 7 do
        --     local data = {};
        --     data.na = "user12";
        --     data.usI = 88888888;
        --     table.insert(self.m_data.li, data);
        -- end

        if not self.m_data.li then
            self.mark_noInvite:setVisible(true)
        end
        local playerList = {}
        for i,v in ipairs(self.m_data.li) do
            playerList[#playerList + 1] = {na = v.na, usI = v.usI, he = v.ic}
        end

        self.mark_noInvite:setVisible(#self.m_data.li == 0)
        for i,data in pairs(playerList) do
            local lay = self.ListView:getItem((i-1)/3)
            if not lay then
                self.ListView:pushBackDefaultItem()
                lay = self.ListView:getItem(#self.ListView:getItems() - 1)
                lay.frontData = data
                for d=0,2 do
                    ccui.Helper:seekWidgetByName(lay, "panel_"..d):setVisible(false)
                end
            end
            lay.lastData = data
            local item = ccui.Helper:seekWidgetByName(lay, "panel_"..(i-1)%3)
            item:setVisible(true)
            item.data = data
            self:initItem(item)
            table.insert(self.itemList,item)
        end
    end
end

function InviteFriendView:initSecondView()
    self.lab_curCanAward = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_curCanAward");
    self.list_received = ccui.Helper:seekWidgetByName(self.m_pWidget, "list_received");
    self.lab_agentAward = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_agentAward");
    local receivedItemModel = ccui.Helper:seekWidgetByName(self.m_pWidget, "item_received")
    receivedItemModel:setVisible(true)
    self.list_received:setItemModel(receivedItemModel:clone())
    receivedItemModel:setVisible(false)

    self.btn_receivePrize = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_receivePrize");
    self.btn_receivePrize:addTouchEventListener(handler(self, self.onClickButton));

    self.agent_inputBg = ccui.Helper:seekWidgetByName(self.m_pWidget, "agent_inputBg")

    self.btn_sendAgent = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_sendAgent");
    self.btn_sendAgent:addTouchEventListener(handler(self, self.onClickButton));
    self.tex_input = self:getWidget(self.m_pWidget, "tex_input");

    if IsPortrait then -- TODO
        self.lab_noReceiveTip = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_noReceiveTip");
        self.lab_noReceiveTip:setVisible(false)
    end

    self.img_listPrecent = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_listPrecent")

    -- 注册帧事件
    self.img_listPrecent:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
            local innerHeight = self.list_received:getInnerContainerSize().height
            local contentHeight = self.list_received:getContentSize().height
            if innerHeight <= contentHeight then
                self.img_listPrecent:setVisible(false)
            else
                self.img_listPrecent:setVisible(true)

                local rid = -1 * self.list_received:getInnerContainer():getPositionY() / (innerHeight - contentHeight)
                rid = math.min(1, math.max(rid, 0))
                self.img_listPrecent:setPositionY(rid * self.img_listPrecent:getParent():getContentSize().height)
            end
        end )
    self.img_listPrecent:scheduleUpdate()    

    if self.tex_input.setInputMode then self.tex_input:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC) end

    self.img_agentEndMark = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_agentEndMark")

end

function InviteFriendView:onClickSwitchButton(pWidget, EventType, hideVoice)
    if EventType == ccui.TouchEventType.ended then
        if not hideVoice then SoundManager.playEffect("btn") end
        for i,v in ipairs(self.btn_pans) do
            if pWidget == v then
                v.bindView:setVisible(true)
                v.selectBgs[1]:setVisible(true)
                v.selectBgs[2]:setVisible(false)
            else
                v.bindView:setVisible(false)
                v.selectBgs[1]:setVisible(false)
                v.selectBgs[2]:setVisible(true)       
            end
        end
        local tag = pWidget:getTag()
        if tag == 1 then
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GetDiamondPage)
        elseif tag == 2 then
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GetCanGetPage)
        end
    end
end

function InviteFriendView:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    self.btn_pans = {}

    for i = 1, 2 do
        self.btn_pans[i] = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_pan"..i);
        self.btn_pans[i].selectBgs = {
            ccui.Helper:seekWidgetByName(self.btn_pans[i], "Image_select")
            , ccui.Helper:seekWidgetByName(self.btn_pans[i], "Image_unselect")
        }
        self.btn_pans[i].bindView = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_view"..i);
    end

    for i,v in ipairs(self.btn_pans) do
        v:addTouchEventListener(handler(self, self.onClickSwitchButton));
        v:setTag(i)
    end

    self:initFirstView()

    self:initSecondView()

    self:onClickSwitchButton(self.btn_pans[1], ccui.TouchEventType.ended, true)

    self.m_data.li = self.m_data.li or {};      -- 被邀请人列表
    self.m_data.reL = self.m_data.reL or {}     -- 奖励列表

    self:refreshShowInfo()
    -- self:addTestData()                   -- 测试数据
end

function InviteFriendView:refreshShowInfo()
    local totalAwardNum = 0
    local canAwardNum = 0
    local nextAwardNum = 0
    local nextAwardInvite = 0
    local curInviteNum = self.m_data.inN1 or 0    --#self.m_data.li -- 修改获取当前邀请人数的方法
    local reachIdx = 0
    local agentAward = self.m_data.reN
    local agentId = self.m_data.myI
    local rewardRecords = {}

    ----testdata 
    -- for i=1,20 do
    --     local data = {}
    --     data.inN = 2
    --     data.reN0 = 1
    --     data.isR = 1
    --     table.insert(self.m_data.reL,data)
    -- end

    for i,v in ipairs(self.m_data.reL) do
        totalAwardNum = totalAwardNum + v.reN0
        if v.inN > curInviteNum and nextAwardNum == 0 then
            nextAwardNum = v.reN0
            nextAwardInvite = v.inN
        end
        if curInviteNum >= v.inN then --达到领取条件
            reachIdx = i
            if v.isR == 0 then --未领取
                canAwardNum = canAwardNum + v.reN0
            end
        end

        if v.isR == 1 then
            rewardRecords[#rewardRecords+1] = { v.inN, v.reN0 }
        end
    end


    self.lab_totalReward:setString("x"..tostring(totalAwardNum))
    local pos_x, pos_y = self.lab_totalReward:getPositionX(),self.lab_totalReward:getPositionY()
    local pos = self.m_pWidget:convertToWorldSpace(cc.p(pos_x, pos_y))
    local size = self.lab_totalReward:getContentSize()
    self.lab_jiangli:setPosition(pos.x + size.width + 10,pos.y)

    self.lab_inviteId:setString(tostring(kUserInfo:getUserId()))

    if IsPortrait then -- TODO
        if nextAwardNum >0 then
            self.panel_canInvite:setVisible(true)
            self.panel_allInvited:setVisible(false)
            self.lab_nextReward:setString("x"..tostring(nextAwardNum)..Str_DiamondMeasure..Str_Diamond)
            self.lab_inviteSyTip:setString("再邀请"..tostring(nextAwardInvite-curInviteNum).."名好友可再得:")
        else
            self.panel_canInvite:setVisible(false)
            self.panel_allInvited:setVisible(true)
            if canAwardNum > 0 then
                self.lab_allInvited:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
                self.lab_allInvited:setString("已经完成全部邀请目标。\n请点击右上角切换页面领取奖励。")
            else
                self.lab_allInvited:setString("已经领取所有邀请奖励。")
            end
        end

        self.lab_curCanAward:setString("钻石x"..tostring(canAwardNum)..Str_DiamondMeasure..Str_Diamond) 
        self.lab_agentAward:setString("钻石x"..tostring(agentAward)..Str_DiamondMeasure..Str_Diamond)
    else
        self.total_panel:setVisible(false)
        self.panel_begin:setVisible(true)
        if nextAwardNum >0 then
            self.lab_nextReward:setVisible(true) 
            self.diamound_img:setVisible(true)
            self.lab_nextReward:setString("x"..tostring(nextAwardNum)..Str_DiamondMeasure..Str_Diamond)
            self.lab_inviteSyTip:setString("再邀请"..tostring(nextAwardInvite-curInviteNum).."名好友可再得:")
        else
            self.lab_nextReward:setVisible(false)
            self.diamound_img:setVisible(false)
            if canAwardNum > 0 then
                self.lab_inviteId_0:setString(tostring(kUserInfo:getUserId()))
                self.total_panel:setVisible(true)
                self.panel_begin:setVisible(false)
            else
                self.lab_inviteSyTip:setString("已经领取所有邀请奖励")
            end
        end

        self.lab_curCanAward:setString("x"..tostring(canAwardNum)..Str_DiamondMeasure..Str_Diamond) 
        self.lab_agentAward:setString("x"..tostring(agentAward)..Str_DiamondMeasure..Str_Diamond)
    end

    if canAwardNum > 0 then
        self.btn_receivePrize:setTouchEnabled(true)
        self.btn_receivePrize:setBright(true)
        self.redTip:setVisible(true)
    else
        self.btn_receivePrize:setTouchEnabled(false)
        self.btn_receivePrize:setBright(false)
        self.redTip:setVisible(false)
    end

    if agentId > 0 then
        self.agent_inputBg:setVisible(false)
        self.img_agentEndMark:setVisible(true)
    else
        self.agent_inputBg:setVisible(true)
        self.img_agentEndMark:setVisible(false)
    end

    self.list_received:removeAllItems()
    if agentId > 0 then
        self.list_received:insertDefaultItem(0)
        local item = self.list_received:getItem(0)
        ccui.Helper:seekWidgetByName(item, "lab_des"):setString(string.format("填写邀请人奖励%d钻石", agentAward))
        ccui.Helper:seekWidgetByName(item, "lab_st"):setString("已领取")
    end

    for i,v in ipairs(rewardRecords) do
        self.list_received:insertDefaultItem(0)
        local item = self.list_received:getItem(0)
        ccui.Helper:seekWidgetByName(item, "lab_des"):setString(string.format("邀请%d人奖励%d钻石", v[1], v[2]))
        ccui.Helper:seekWidgetByName(item, "lab_st"):setString("已领取")
    end

    if IsPortrait then -- TODO
        self.lab_noReceiveTip:setVisible(#self.list_received:getItems() == 0)
    else
        self.mark_noReword:setVisible(#rewardRecords == 0)
    end
end

-- 返回领取状态
-- ##  id  int  奖项id
-- ##  re  int  结果(0:操作成功 1:条件不满足 2:已经领过奖)
function InviteFriendView:repeatReward(info)
    if self.clickBtn then
        self.clickBtn = nil
        if info.re == 0 then
            Toast.getInstance():show("钻石领取成功");
            local curInviteNum = self.m_data.inN1 or 0
            Log.i("curInviteNum ", curInviteNum)
            dump(self.m_data)
            --不从服务器拉数据 直接改本地数据为已经领取
            if info.id == -1 then
                for i,v in ipairs(self.m_data.reL) do
                    if curInviteNum >= v.inN then --达到领取条件
                        v.isR = 1
                    end
                end
            else
                for i,v in ipairs(self.m_data.reL) do
                    if info.id == v.id then --达到领取条件
                        v.isR = 1
                        return
                    end
                end
            end
            self:refreshShowInfo()
        elseif info.re == 1 then
            Toast.getInstance():show("不满足领取条件");
        elseif info.re == 2 then
            Toast.getInstance():show("您已经领过该奖励");
        else
            Toast.getInstance():show("钻石领取失败");
        end
    end
end


function InviteFriendView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_shareFriend then
            Util.disableNodeTouchWithinTime(pWidget)
            Log.i("self.m_data....",self.m_data)
            local data = json.decode(self.m_data.sh)
            LoadingView.getInstance():show("正在分享,请稍后...", 2)
            -- data.shardMold = 4
            WeChatShared.getWechatShareInfo(WeChatShared.ShareType.FRIENDS, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.GET_DIAMOND_FRIEND, handler(self, self.shareResult),ShareToWX.DiamoundShareFriendQun,data)
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GetGroupShareButton)
            local data = {}
            data.wa = BackEndStatistics.HallGetDiamondGroup
            SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
        elseif pWidget == self.btn_list then
            --todo push playerDialog

            if #self.m_data.li == 0 then
                Toast.getInstance():show("您还没有邀请玩家");                
            else
                local playerList = {}
                for i,v in ipairs(self.m_data.li) do
                    playerList[#playerList + 1] = {na = v.na, usI = v.usI, he = v.ic}
                end
                local wnd = UIManager.getInstance():pushWnd(PlayerListDialog, playerList);
                wnd:setTitle("已邀请好友")
            end
        elseif pWidget == self.btn_shareCircle then
            if not IsPortrait then -- TODO
                Util.disableNodeTouchWithinTime(pWidget)
            end
            local data = json.decode(self.m_data.sh)
            data.shardMold = 5
            LoadingView.getInstance():show("正在分享,请稍后...", 2)
            WeChatShared.getWechatShareInfo(WeChatShared.ShareType.TIMELINE, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.GET_DIAMOND, handler(self, self.shareResult),ShareToWX.DiamoundShareFriendQuan,data)
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GetShareFriendCircle)
            local data = {}
            data.wa = BackEndStatistics.HallGetDiamondMoments
            SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
        elseif pWidget == self.btn_receivePrize then
            if not self.clickBtn then
                self.clickBtn = pWidget                    -- 服务器消息没有返回之前不允许点击第二个按钮
                local data = {};
                data.id = -1;
                SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_RECV_YAOQING_REWARD, data);
            end
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GetDiamondRightNow)
        elseif pWidget == self.btn_sendAgent then            
            local account = self.tex_input:getText();
            if not account then
                Toast.getInstance():show("无效ID，请重新输入");
                return;
            elseif string.len(account) < 6 then
                Toast.getInstance():show("无效ID，请重新输入");
                return;
            else
                local len = string.len(account);
                local wAccount = string.match(account, "%w+")
                if not wAccount or len ~= string.len(wAccount) then
                    Toast.getInstance():show("无效ID，请重新输入");
                elseif wAccount == kUserInfo:getUserId() then
                    Toast.getInstance():show("不能设置自己为邀请人");
                else
                    local data = {};
                    data.inI = tonumber(account);
                    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_YAOQING_ID, data);
                    LoadingView.getInstance():show();
                end
            end

            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GetDiamondGet)
        elseif pWidget == self.btn_close then 
            self:keyBack()
        end
    end
end

function InviteFriendView:shareResult(info)
    Log.i("shard button:", info);
    LoadingView.getInstance():hide();
    if info.errCode == 0 then --成功
        Toast.getInstance():show("分享成功");
    elseif (info.errCode == -8) then
        Toast.getInstance():show("您手机未安装微信");
    else
        Toast.getInstance():show("分享失败");
    end
end


function InviteFriendView:onRepYaoingResult(info)
    LoadingView.getInstance():hide();
    --0:操作成功，获得XX钻石  1:邀请人已达邀请上限哦  2:无效ID，请重新输入  3:已经设置过邀请人 4:对方设置过自己为邀请人，自己不能再设置对方为邀请人
    if info.re == 0 then
        self.m_data.myI = info.inI
        self:refreshShowInfo()
    elseif info.re == 1 then
        Toast.getInstance():show("邀请人已达邀请上限哦");
    elseif info.re == 2 then
        Toast.getInstance():show("无效ID，请重新输入");
    elseif info.re == 3 then
        Toast.getInstance():show("已经设置过邀请人");
    elseif info.re == 4 then
        Toast.getInstance():show("对方设置您为邀请人,互设为邀请人无效");
    end
end

function InviteFriendView:repYaoqingInfo(info)
    self.m_data = kUserInfo:getInviteInfo()
    self:refreshShowInfo()
end

InviteFriendView.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_RECV_YAOQING_INFO]   = InviteFriendView.repYaoqingInfo;
    [HallSocketCmd.CODE_RECV_YAOQING_REWARD] = InviteFriendView.repeatReward;
    [HallSocketCmd.CODE_RECV_YAOQING_ID] = InviteFriendView.onRepYaoingResult;
};

return InviteFriendView