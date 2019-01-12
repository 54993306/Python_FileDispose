
DismissDeskView = class("DismissDeskView",UIWndBase)
local UmengClickEvent = require("app.common.UmengClickEvent")


function DismissDeskView:ctor(...)
    self.super.ctor(self,"games/common/mj/dismiss_desk.csb", ...);
	self.m_playerNameList={};
end

function DismissDeskView:onInit()

    -- 同意
    self.btn_agree = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_agree");
    self.btn_agree:addTouchEventListener(handler(self, self.onClickButton));
 
    -- 不同意
    self.btn_disagree = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_disagree");
    self.btn_disagree:addTouchEventListener(handler(self, self.onClickButton));

	self.lab_title = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_title");

    self.self_agree_tip = ccui.Helper:seekWidgetByName(self.m_pWidget, "self_agree_tip")
    if self.self_agree_tip then
        self.self_agree_tip:setVisible(false)
    end

    for i = 1, 4 do
        local pan_head = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_head" .. i);
        pan_head:setVisible(false)
    end
	 
    -- 倒计时
    self.lab_time = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_time");
    self.lab_time:setVisible(false)
    -- 玩家信息
    self:addPlayers()
end

-- 窗口被关闭响应
function DismissDeskView:onClose()
    Log.i("DismissDeskView:onClose()")
	if self.refreshTimeSchedule then 
		scheduler.unscheduleGlobal(self.refreshTimeSchedule)
		self.refreshTimeSchedule=nil
	end
    self.imgHeads = {}
end

		
function DismissDeskView:updateTime(packetInfo)
   if(self.m_time~=nil) then --已经接收过最新时间，不用再接收更新
      return 
   end
  
   Log.i("接收时间" .. packetInfo.CoD)
  
   self.m_time = packetInfo.CoD  --int  倒计时
   self.lab_time:setString(string.format("%d秒", self.m_time))
   self.m_startTime= os.time(); --用于后台导致暂停不更新

    local refreshTimeFun = function ()
	    local sud = os.time() - self.m_startTime;
		--Log.i("系统时间" .. os.time() .. "time:" .. self.m_time)
        if sud > self.m_time or sud< 0 then
		    self.lab_time:setString("0秒")
		    --玩家选择时间为30秒，如果30内玩家未选择，时间结束后，系统默认选择同意
			self.btn_agree:setVisible(false)
            self.btn_disagree:setVisible(false)
            if self.refreshTimeSchedule then 
                scheduler.unscheduleGlobal(self.refreshTimeSchedule)
				self.refreshTimeSchedule=nil
				return;
            end
        end	
		local tmpSub =  math.floor(self.m_time-sud);
		if(tmpSub<0)then
		   tmpSub=0
		end
        self.lab_time:setString(string.format("%d秒", tmpSub))
    end
    self.refreshTimeSchedule = scheduler.scheduleGlobal(refreshTimeFun,0.2)   

end

function DismissDeskView:addPlayers()
    self.imgHeads = {}
    self.labTips = {}
    self.agree_img = {}
    self.gameSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    --local players = self.gameSystem:gameStartGetPlayers()

    local room_info = kFriendRoomInfo:getRoomInfo()
    local player_list = room_info.pl
    if not player_list then return end 
    local my_id = kUserInfo:getUserId()

    local my_info = {}
    local other_info = {}
    for k,v in pairs(player_list) do
        if v.usI == my_id then
            my_info[#my_info + 1] = v
        else
            other_info[#other_info + 1] = v
        end
    end

    for k,v in pairs(other_info) do
        my_info[#my_info + 1] = v
    end

    for i=1, #my_info do
        local pan_head = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_head" .. i);
        pan_head:setVisible(true)
        local img_head = ccui.Helper:seekWidgetByName(pan_head, "img_head");
        local lab_nick = ccui.Helper:seekWidgetByName(pan_head, "lab_nick");
        local lab_tip  = ccui.Helper:seekWidgetByName(pan_head, "lab_tip");
		--local playerID = players[i]:getProp(enCreatureEntityProp.USERID);
        local playerID = my_info[i].usI;

		local toStr = "" .. playerID;
        Log.i("player id :", toStr);
		
		--玩家昵称
		--local strNickName = players[i]:getProp(enCreatureEntityProp.NAME)
        local strNickName = my_info[i].niN

		local retName = ToolKit.subUtfStrByCn(strNickName,0,5,"")
        Util.updateNickName(lab_nick, retName, 22)
        -- lab_nick:setString(retName)
		 
		-- lab_tip:setVisible(false);
		-- lab_tip:setString("")
        self.labTips[toStr] = lab_tip
        if IsPortrait then -- TODO
            self.agree_img[toStr] = ccui.Helper:seekWidgetByName(pan_head, "agree_img")
        end
		local imgURL = my_info[i].heI or ""
       
        
        Log.i("imgURL...", imgURL, "string.len(imgURL)...", string.len(imgURL), "site...", i)
        local imgName = playerID .. ".jpg";
    
        if string.len(imgURL) > 3 then
            Log.i("imagename ....", imgName, "site....", i)
            local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
            if io.exists(headFile) then
                img_head:loadTexture(imgName);
                if IsPortrait then -- TODO
                    img_head:setScale(92 / img_head:getContentSize().width)
                else
                    img_head:setScale(70 / img_head:getContentSize().width)
                end
            else
                self.imgHeads[imgName] = img_head;
                self:getNetworkImage(imgURL, imgName);
            end
        else              
            local headFile = "hall/Common/default_head_2.png";
            headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
            if io.exists(headFile) then
                img_head:loadTexture(headFile);
                if IsPortrait then -- TODO
                    img_head:setScale(92 / img_head:getContentSize().width)
                else
                    img_head:setScale(70 / img_head:getContentSize().width)
                end
            end
        end   
        -- img_head:setScale(100/img_head:getContentSize().width , 100/img_head:getContentSize().height)
    end
end

function DismissDeskView:getNetworkImage(preUrl, fileName)
    Log.i("DismissDeskView.getNetworkImage", "-------url = " .. preUrl);
    Log.i("DismissDeskView.getNetworkImage", "-------fileName = ".. fileName);
    if preUrl == "" then
        return
    end
    local onReponseNetworkImage = function (event)
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
            Log.i("------onReponseNetworkImage code", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        request:saveResponseData(savePath);
        self:onResponseNetImg(fileName);
    end
    local url = preUrl;
    --
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end

function DismissDeskView:onResponseNetImg(imgName)
    if not imgName or not self.imgHeads then return end
    for k, v in pairs(self.imgHeads) do
        if imgName == k then
            imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
            if io.exists(imgName) then
                v:loadTexture(imgName);
                v:setScale(70 / v:getContentSize().width)
                break
            end
        end
    end
end

function DismissDeskView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.btn_agree then 

            Log.i("press btn_agree")
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameAgree)

            local tmpData={}
			tmpData.usI =  kUserInfo:getUserId()
			tmpData.re= 1
			tmpData.niN =kUserInfo:getUserName()
			tmpData.isF=1
			SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_LEAVE,tmpData);
            
        elseif pWidget == self.btn_disagree then

            Log.i("press btn_disagree")
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameDisagree)

            local tmpData={}
			tmpData.usI =  kUserInfo:getUserId()
			tmpData.re= 2
			tmpData.niN =kUserInfo:getUserName()
			tmpData.isF=1
			SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_LEAVE,tmpData);
        end
    end
end

--[[
type = 2,code=22020, 私有房解散牌局问询  client  <-->  server
##  usI  long  玩家id
##  re  int  结果(-1:没有问询   0:还没有回应   1:同意  2:不同意)
##  CoD  --int  倒计时
##  asI  long  发起的用户Id
##  niN  String  发起的用户昵称
##  isF  int  是否是刚发起的问询, 如果是刚发起的需要起定时器(0:是  1:不是)
]]
function DismissDeskView:updateUI(packetInfo)
    if packetInfo.usI == nil or tonumber(packetInfo.usI) == 0 then
        Toast.getInstance:show("发起解散失败")
        return
    end
    Log.i("收到玩家解散桌子信息",packetInfo)
	self:updateTime(packetInfo)
    self.lab_time:setVisible(true)
	-- 谁发起的解散
    local strNickName = packetInfo.niN
    local strNickNameLen = string.len(strNickName)
    local nickName = ""
    nickName = ToolKit.subUtfStrByCn(strNickName,0,5,"")
    if IsPortrait then -- TODO
        Util.updateNickName(self.lab_title, string.format("【%s】发起解散牌局申请", nickName), 32)
    else
        Util.updateNickName(self.lab_title, string.format("【%s】", nickName), 32)
    end
    -- self.lab_title:setString(string.format("【%s】发起解散牌局申请", nickName))

	--玩家点击“同意”或“不同意”按钮以后，该玩家的“同意”和“不同意”按钮消失
	if(packetInfo.usI == kUserInfo:getUserId() and packetInfo.re~=-1 and  packetInfo.re~=0) then
		self.btn_agree:setVisible(false)
        self.btn_disagree:setVisible(false)
        if self.self_agree_tip then
            self.self_agree_tip:setVisible(true)
        end
	end
	
	local toStr = "" .. packetInfo.usI
    local lab_tip = self.labTips[toStr];    
    lab_tip:setVisible(true)
    
	local playerInfo = kFriendRoomInfo:getRoomPlayerListInfo(packetInfo.usI)
	
	if  packetInfo.re == 1 then --1:同意
        lab_tip:setString("同意")
        lab_tip:setVisible(false)

        if IsPortrait then -- TODO
            self.agree_img[toStr]:setVisible(true)
        else
            local agreeFlag = cc.Sprite:create("games/common/mj/common/green_flag.png")
            agreeFlag:setPosition(lab_tip:getPosition())
            agreeFlag:setAnchorPoint(lab_tip:getAnchorPoint())
            lab_tip:getParent():addChild(agreeFlag)
        end
	elseif(packetInfo.re == 2 )  then --2:不同意
	    --如果有1名选择选择不同意，则其他玩家无需在继续选择，4名玩家全部自动关闭该界面，并弹出另一提示框，提示内容：玩家xx不同意解散房间。设有“确定”按钮，点击“确定”关闭弹出框；
        lab_tip:setString("不同意")
        if IsPortrait then -- TODO
            self.agree_img[toStr]:setVisible(false)
        end
	   
	    local data = {}
		data.type = 1;
		data.title = "提示";
		data.closeTitle = "提示";
        local strNickName = playerInfo.niN
        local strNickNameLen = string.len(strNickName)
        local nickName = ""
        nickName = ToolKit.subUtfStrByCn(strNickName,0,5,"")
		data.content = string.format("【%s】不同意解散房间！", nickName);
		UIManager.getInstance():popWnd(DismissDeskView);
		
		--如果是自己发起的不同意则不用显示提示UI
		if packetInfo.usI ~= kUserInfo:getUserId() then
            local dialog = UIManager.getInstance():pushWnd(CommonDialog, data);
            local content = dialog:getContentLabel()
            Util.updateNickName(content, data.content, 32)
		end
	end
end

-- 收到返回键事件
function DismissDeskView:keyBack()
end