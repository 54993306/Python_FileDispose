

-- 邀请面板     any question by linxiancheng


YaoqingDialog = class("YaoqingDialog", UIWndBase)

function YaoqingDialog:ctor(info)
    self.super.ctor(self, "hall/yaoqinghaoyou.csb", info);
    self.m_head_imgs = {};

    self.socketProcesser = InviteRewardSocketProcesser.new(self)
    SocketManager:getInstance():addSocketProcesser(self.socketProcesser)
end

function YaoqingDialog:onClose()
    if self.socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.socketProcesser);
        self.socketProcesser = nil;
    end
end

function YaoqingDialog:addTestData()
    for i = 1, 7 do
        local data = {};
        data.na = " 11111111111111111111111111111111111111";
        data.usI = 1;
        table.insert(self.m_data.li, data);
    end
end

function YaoqingDialog:onInit()
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_input = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_input");
    self.btn_input:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_yaoqing = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_yaoqing");
    self.btn_yaoqing:addTouchEventListener(handler(self, self.onClickButton));

    self.m_data.li = self.m_data.li or {};      -- 被邀请人列表
    self.m_data.reL = self.m_data.reL or {}     -- 奖励列表
    self.completeNum = 0                        -- 已完成的邀请人数

    -- self:addTestData()                   -- 测试数据

    self:initInviter()                   -- 初始化邀请我的人信息

    self:initOtherUnit()                 -- 初始化部件信息

    self:initInviterList()               -- 初始化被邀请列表

    self:initProBar()                    -- 初始化邀请进度条

    self:initAwardList()                 -- 初始化奖励列表
end

-- 初始化邀请进度条
function YaoqingDialog:initProBar()
    local lisCount = #self.m_data.li;    -- 已邀请好友列表
    local bar = ccui.Helper:seekWidgetByName(self.m_pWidget, "pb_friend");  -- 进度条
    bar:setVisible(false)
    if #self.m_data.li > 0 then          -- 九宫格反向拉伸,会有显示bug
        bar:setVisible(true)
        local lab_none = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_none");
        lab_none:setVisible(false);

        local rewardCount = #self.m_data.reL;   --奖励列表
        local index1 = 1;
        local index2 = 1;
        for i = 1, rewardCount do
            index1 = i;
            index2 = i + 1;
            if index2 > rewardCount then
                index1 = rewardCount;
                index2 = rewardCount;
                break;
            end
            local data1 = self.m_data.reL[index1];
            local data2 = self.m_data.reL[index2];
            if data1.inN > lisCount then           -- 需要邀请数量
                index1 = 0;
                index2 = 1;
            end
            if data2.inN > lisCount then
                break;
            end
        end
        Log.i("------index1", index1);
        Log.i("------index2", index2);
        local percent = 0;
        local percentCom = index1;
        local percentCom1 = 0;
        self.completeNum = index1;
        if index1 ~= index2 then
            local count1 = 0;
            if index1 > 0 then
                count1 = self.m_data.reL[index1].inN;
            end
            local count2 = self.m_data.reL[index2].inN;
            percentCom1 = (lisCount - count1)/(count2 - count1);
        else
             percentCom = index1;
        end
        percent = (percentCom + percentCom1)/rewardCount * 100;
        bar:setPercent(percent);
    end
end

--初始化奖励列表
function YaoqingDialog:initAwardList()
    local lis_pro = ccui.Helper:seekWidgetByName(self.m_pWidget, "lis_pro");
    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/yaoqing_pro_item.csb");
    for i = 1, #self.m_data.reL do       --奖励列表
        local data = self.m_data.reL[i];
        local item = itemModel:clone();

        local lb_zuan = ccui.Helper:seekWidgetByName(item, "lb_zuan")
        lb_zuan:setString("x" .. data.reN0)
        local lb_num = ccui.Helper:seekWidgetByName(item, "lb_num")
        lb_num:setString(data.inN .. "人");

        local btn_reward = ccui.Helper:seekWidgetByName(item, "img_head")
        btn_reward.data = data
        btn_reward.index = i
        self:initRewardBtn(btn_reward)
        lis_pro:pushBackCustomItem(item);
    end
end

-- 奖励按钮
function YaoqingDialog:initRewardBtn(pBtn)
    pBtn.data.isR = pBtn.data.isR or 1                  --默认已领取状态
    if pBtn.index > self.completeNum then
        pBtn:setOpacity(51);
    else
        if pBtn.data.isR ~= 0 then
            return                                       -- 奖励未领取
        end
        local sequence = transition.sequence({
            cc.ScaleTo:create(0.2, 0.95),
            cc.ScaleTo:create(0.2, 1.15),
            cc.ScaleTo:create(0.2, 1)
        });
        pBtn:runAction(cc.RepeatForever:create(sequence));    -- 服务器消息返回领取成功的时停止按钮动作
        pBtn:addTouchEventListener( handler( pBtn.data ,function( pData, pWdiget, pEventType )
            if pEventType ==  ccui.TouchEventType.ended and not self.clickBtn then
                self.clickBtn = pWdiget                    -- 服务器消息没有返回之前不允许点击第二个按钮
                local data = {};
                data.id = pData.id;
                SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_RECV_YAOQING_REWARD, data);
            end
        end))
    end
end

-- 返回领取状态
-- ##  id  int  奖项id
-- ##  re  int  结果(0:操作成功 1:条件不满足 2:已经领过奖)
function YaoqingDialog:repeatReward(info)
    if self.clickBtn then
        self.clickBtn:stopAllActions()
        self.clickBtn:removeAllChildren()
        self.clickBtn = nil
        Toast.getInstance():show("钻石已领取");
    end
end

-- 初始化被邀请列表
function YaoqingDialog:initInviterList()
    local lis_friend = ccui.Helper:seekWidgetByName(self.m_pWidget, "lis_friend");
    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/yaoqing_friend_item.csb");

    for i = 1, #self.m_data.li do
        local data = self.m_data.li[i];
        local item = itemModel:clone();

        local lb_name = ccui.Helper:seekWidgetByName(item, "lb_name");
        Util.updateNickName(lb_name, ToolKit.subUtfStrByCn(data.na, 0, 5, "..."), 22)

        local img_head = ccui.Helper:seekWidgetByName(item, "img_head");
        self.m_head_imgs[i] = img_head;
        local imgUrl = data.ic;
        if imgUrl and string.len(imgUrl) > 4 then
            local imgName = data.usI .. ".jpg";
            local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
            if io.exists(headFile) then
                img_head:loadTexture(headFile);
            else
                HttpManager.getNetworkImage(imgUrl, data.usI .. ".jpg");
            end
        end
        lis_friend:pushBackCustomItem(item);
    end
end

--初始化邀请人信息
function YaoqingDialog:initInviter()
    if self.m_data.myI > 0 then
        self.btn_input:setVisible(false);
        local pan_input = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_input");
        pan_input:setVisible(true);
        local lb_input1 = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_input1");
        lb_input1:setString("ID:" .. self.m_data.myI);
        local lb_input2 = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_input2");
        local nickName = ToolKit.subUtfStrByCn(self.m_data.myIN, 0, 7, "...")
        Util.updateNickName(lb_input2, "昵称:" .. nickName, 22)
    end
end

--初始化一些显示信息
function YaoqingDialog:initOtherUnit()

    local lb_num = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_des_0_1");
    lb_num:setString("(" .. #self.m_data.li .. "人)");                            --显示已经邀请的人数

    local img_left = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_left");    -- 判断邀请人数，初始化左右箭头
    local img_right = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_right");
    if #self.m_data.li < 8 then
        img_left:setVisible(false);
        img_right:setVisible(false);
        -- lis_friend:setDirection(cc.SCROLLVIEW_DIRECTION_NONE)                   -- 当人数少于7人时不允许滑动listview(未实现)
        -- lis_friend:setTouchEnabled(false)
        -- lis_friend:setBounceEnabled(false)
        -- lis_friend:setInertiaScrollEnabled(false)
    end
end

--返回网络图片
function YaoqingDialog:onResponseNetImg(fileName)
    Log.i("------HallMain:onResponseNetImg fileName", fileName);
    if fileName == nil then
        return;
    end
    for i = 1, #self.m_data.li do
        local data = self.m_data.li[i];
        local imgName = data.usI .. ".jpg";
        if fileName == imgName then
            local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
            if io.exists(headFile) then
                self.m_head_imgs[i]:loadTexture(headFile);
            end
        end
    end
end

function YaoqingDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_close then
            self:keyBack()
        elseif pWidget == self.btn_yaoqing then
            Util.disableNodeTouchWithinTime(pWidget)
            local data = {};
            --分享标题 shT2="";
            --分享描述shD="";
            --分享链接shL="";
            --
            local serverInviteShareInfo = kServerInfo:getInviteShareInfo()
            data.cmd = NativeCall.CMD_WECHAT_SHARE;
            data.title = serverInviteShareInfo.shareTitle or self.m_data.shT;
            data.desc = serverInviteShareInfo.shareDesc or self.m_data.shD;
            data.url = serverInviteShareInfo.shareLink or self.m_data.shL;
            data.headUrl = "";
            data.type = 2;
            --Log.i("------data", data);
            TouchCaptureView.getInstance():showWithTime()
            NativeCall.getInstance():callNative(data, self.shareResult, self);
        elseif pWidget == self.btn_input then
            UIManager:getInstance():pushWnd(YaoqingDialogDetail,self.m_data.reN);
        end
    end
end

function YaoqingDialog:shareResult(info)
    Log.i("shard button:", info);
    LoadingView.getInstance():hide();
    if info.errCode == 0 then --成功
        local data = {}
        data.wa = 2
        SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
    elseif (info.errCode == -8) then
        Toast.getInstance():show("您手机未安装微信");
    else
        Toast.getInstance():show("分享失败");
    end
end


function YaoqingDialog:getGift()
    if self.m_shareGiftInfo then
        local data = {};
        data.quI = self.m_shareGiftInfo.Id;
        SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_TASKFINISH, data);
    end
end

YaoqingDialog.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_RECV_YAOQING_REWARD] = YaoqingDialog.repeatReward;
};
