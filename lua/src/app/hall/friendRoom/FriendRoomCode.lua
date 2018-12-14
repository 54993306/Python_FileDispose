--创建与进入房间UI

FriendRoomCode = class("FriendRoomCode", UIWndBase);

-- 提示的显示时间
local ToastShowTime = 3

function FriendRoomCode:ctor(...)
    self.super.ctor(self, "hall/friendRoomCode.csb", ...);
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    self.m_data=...;
    self.m_strNum=""
    self.m_socketProcesser = FriendRoomSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
end

function FriendRoomCode:onClose()

    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end

end

local function drawUnderline(node)
    local drawNode = cc.DrawNode:create()
    local color = node:getTextColor()
    local size = node:getContentSize()
    -- debugDraw(node)
    -- 2b4c01
    drawNode:drawLine(cc.p(0, 0), cc.p(size.width, 0), cc.c4f(1,1,1, 120/255))
    drawNode:setPosition(cc.p(0, 0))
    drawNode:setAnchorPoint(cc.p(0, 0))
    node:addChild(drawNode)
end

function FriendRoomCode:onInit()

    self:addShowder()

    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end

    self.closeBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "closeBtn");
    self.closeBtn:addTouchEventListener(handler(self, self.onClickButton));
    self.numLabels = {}
    for i=0,5 do
        self.numLabels[#self.numLabels + 1]= ccui.Helper:seekWidgetByName(self.m_pWidget, "numLabel_"..i);
        self.numLabels[#self.numLabels]:setString("")
    end 
    --self.numLabel:setString("")
    --self.numLabel:enableShadow(cc.c4b(0, 0, 255,255),cc.size(1.5,-1.5));

    self.last_roomNumber = self:getSaveNumber();
    if self.last_roomNumber and string.len(self.last_roomNumber) >= 6 then
        self.roomLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "roomLabel");
        self.roomLabel:setString(self.last_roomNumber);
        self.roomLabel:addTouchEventListener(handler(self, self.onClickButton));
        -- print("=============================>",self.roomLabel:getContentSize().width)
        drawUnderline(self.roomLabel)
    else
        ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_record"):setVisible(false);
    end


   self.numberScrollView = ccui.Helper:seekWidgetByName(self.m_pWidget, "numberScrollView");

   self.clearButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "clearButton");
   self.clearButton:addTouchEventListener(handler(self, self.onClickButton));

   self.backButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "backButton");
   self.backButton:addTouchEventListener(handler(self, self.onClickButton));
   --
   for i = 0, 9 do
    local btn = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_code" .. i);
    btn:addTouchEventListener(handler(self, self.onIconClick));
    btn:setTag(i);
   end
   self.m_tstr = ""
end

function FriendRoomCode:setNumStr(str)
  local len = string.len(str and str or "")
  for i,v in ipairs(self.numLabels) do
    if i > len then
      v:setString("")
    else
      v:setString(string.sub(str,i,i))
    end
  end
end

function FriendRoomCode:onIconClick(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if kServerInfo:getCantEnterRoom() then -- 即将维护, 禁止开局
            Toast.getInstance():show("服务器即将进行维护! ", ToastShowTime)
            return
        end
        local tag = pWidget:getTag()
        self.m_strNum = self.m_strNum .. tag;
        self:setNumStr(self.m_strNum)
        if(string.len(self.m_strNum) == 6) then
            local tmpData={}
            tmpData.pa = tonumber(self.m_strNum)
  			FriendRoomSocketProcesser.sendRoomEnter(tmpData)
  			LoadingView.getInstance():show("正在查找房间,请稍后......");
		  end
    end
end

--增加阴影
function FriendRoomCode:addShowder()
  self:getWidget(self.m_pWidget,"Label_23",{shadow=true})
  self:getWidget(self.m_pWidget,"Label_5",{shadow=true})
end

function FriendRoomCode:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
      if pWidget == self.closeBtn then
		      UIManager:getInstance():popWnd(FriendRoomCode);
      elseif pWidget == self.clearButton then
		   	self.m_strNum = ""
		    self:setNumStr(self.m_strNum)

		  elseif pWidget == self.backButton then

            local tmpLen = string.len(self.m_strNum)
            if(tmpLen>0) then
                self.m_strNum = string.sub(self.m_strNum,0,tmpLen-1)
            end
            self:setNumStr(self.m_strNum)
        elseif pWidget == self.roomLabel then
            if kServerInfo:getCantEnterRoom() then -- 即将维护, 禁止开局
                Toast.getInstance():show("服务器即将进行维护! ", ToastShowTime)
                return
            end
            local tmpData={}
            tmpData.pa = tonumber(self.last_roomNumber)
            FriendRoomSocketProcesser.sendRoomEnter(tmpData)
            LoadingView.getInstance():show("正在查找房间,请稍后......");
        end
    end
end

function FriendRoomCode:recvGetRoomEnter(packetInfo)
    --## re  int  结果（-2 = 无可用房间，1 成功找到）
    --Log.i("进入结果：" .. tmpData.re)
    local tmpData = packetInfo
    Log.i("进入结果：", tmpData)
    self.m_strNum = ""
    self:setNumStr(self.m_strNum)
    LoadingView.getInstance():hide();
    if(-1 == tmpData.re) then
        Toast.getInstance():show("人数已满", ToastShowTime);
    elseif(-2 == tmpData.re) then
        Toast.getInstance():show("房间不存在", ToastShowTime);
    elseif -3 == tmpData.re then
        -- RoJST int   付费类型 1 =房主付费，2 =大赢家付费，3 =AA付费
        if IS_YINGYONGBAO then
            Toast.getInstance():show("加入房间失败", ToastShowTime)
            return
        end
        -- if tmpData.RoJST and tmpData.RoJST == 2 then
        --     Toast.getInstance():show("该房间为大赢家付房费，您钻石不足", ToastShowTime)
        --     return
        -- elseif tmpData.RoJST and tmpData.RoJST == 3 then
        --     Toast.getInstance():show("该房间为AA制付房费，您钻石不足", ToastShowTime)
        --     return
        -- else
        --     Toast.getInstance():show("钻石不足!", ToastShowTime)
        -- end
        local data = {}
        data.type = 1;
        local tips = kSystemConfig:getDataByKe("config_noDiamondTips")
        local content = _NoDiamondTips
        if tips and tips.va then
            content = tips.va
        end
        data.content = content; --kServerInfo:getRechargeInfo();
        UIManager.getInstance():pushWnd(CommonDialog, data);
    elseif(-4 == packetInfo.re) then
        Toast.getInstance():show("您不是该亲友圈亲友", ToastShowTime);
    elseif(-7 == packetInfo.re) then
        Toast.getInstance():show("服务器即将进行维护!", ToastShowTime);
    elseif(-7 == packetInfo.re) then
        Toast.getInstance():show("服务器即将进行维护!", ToastShowTime);
    elseif(-7 == packetInfo.re) then
        Toast.getInstance():show("服务器即将进行维护!", ToastShowTime);
    elseif tmpData.re == 1 and packetInfo.pa and packetInfo.pa > 0 then
        kFriendRoomInfo:saveNumber(packetInfo.pa);
    elseif -5 == tmpData.re or -6 == tmpData.re then
        self:showDialog(tmpData)
   end
   -- UIManager:getInstance():popWnd(FriendRoomCode);
end
function FriendRoomCode:showDialog(tmpData)
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
function FriendRoomCode:onOpenKf()
    local data = {};
    data.cmd = NativeCall.CMD_KE_FU;
    data.uid, data.uname = self.getKfUserInfo()
    NativeCall.getInstance():callNative(data, self.kefuCallBack, self)
	
end

function FriendRoomCode:getKfUserInfo()
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
function  FriendRoomCode:getSaveNumber()
  local roomNumberKey = cc.UserDefault:getInstance():getStringForKey("roomNumberKey");
  if(roomNumberKey ~= nil and roomNumberKey ~= "") then
	    return roomNumberKey
	end
  return nil;
end

function FriendRoomCode:recvRoomSceneInfo(packetInfo)
    Log.i("FriendRoomCode FriendRoomCode:recvRoomSceneInfo......")
    Log.i("packetInfo", packetInfo)
    LoadingView.getInstance():hide();
    
    local data = {};
    data.isFirstEnter = true;
    local gameId = packetInfo.gaID or kFriendRoomInfo:getGameID()
    if loadGame(gameId) then
        UIManager:getInstance():pushWnd(FriendRoomScene);
    else
        Toast.getInstance():show("未配置该游戏: ID " .. gameId, ToastShowTime)
    end
    UIManager:getInstance():popWnd(FriendRoomCode, true);
end


FriendRoomCode.s_socketCmdFuncMap = {
  [HallSocketCmd.CODE_FRIEND_ROOM_ENTER] = FriendRoomCode.recvGetRoomEnter; --InviteRoomEnter	 进入邀请房结果
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = FriendRoomCode.recvRoomSceneInfo; --InviteRoomEnter	邀请房信息
};
