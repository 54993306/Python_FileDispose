
local PokerDismissDeskView = class("PokerDismissDeskView",PokerUIWndBase)
local PokerUtils = require("package_src.games.guandan.gdcommon.commontool.PokerUtils")
local PokerRoomDialogView = require("package_src.games.guandan.gdcommon.widget.PokerRoomDialogView")
local UmengClickEvent = require("app.common.UmengClickEvent")

function PokerDismissDeskView:ctor(...)
    self.super.ctor(self,"package_res/games/guandan/dismiss_desk.csb", ...)
end

function PokerDismissDeskView:onInit()
    -- 同意
    self.btn_agree = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_agree")
    self.btn_agree:addTouchEventListener(handler(self, self.onClickButton))
    -- 不同意
    self.btn_disagree = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_disagree")
    self.btn_disagree:addTouchEventListener(handler(self, self.onClickButton))

	self.txtTitle = ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_title")

    self.self_agree_tip = ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_agree_tip")
    if self.self_agree_tip then
        self.self_agree_tip:setVisible(false)
    end

    for i = 1, 4 do
        local pan_head = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_head" .. i)
        pan_head:setVisible(false)
    end
	 
    -- 倒计时
    self.lab_time = ccui.Helper:seekWidgetByName(self.m_pWidget, "txt_time")
    self.lab_time:setVisible(false)
    -- 玩家信息
    self:addPlayers()
end

-- 窗口被关闭响应
function PokerDismissDeskView:onClose()
	if self.refreshTimeSchedule then 
		scheduler.unscheduleGlobal(self.refreshTimeSchedule)
		self.refreshTimeSchedule=nil
	end
end
		
function PokerDismissDeskView:updateTime(packetInfo)
   if(self.m_time~=nil) then --已经接收过最新时间，不用再接收更新
      return 
   end
   -- Log.i("接收时间" .. packetInfo.CoD)
   self.m_time = packetInfo.CoD  --int  倒计时
   self.lab_time:setString(string.format("%d秒", self.m_time))
   self.m_startTime= os.time() --用于后台导致暂停不更新

    local refreshTimeFun = function ()
	    local sud = os.time() - self.m_startTime
        if sud > self.m_time or sud< 0 then
		    self.lab_time:setString("0秒")
		    --玩家选择时间为30秒，如果30内玩家未选择，时间结束后，系统默认选择同意
			self.btn_agree:setVisible(false)
            self.btn_disagree:setVisible(false)
            if self.refreshTimeSchedule then 
                scheduler.unscheduleGlobal(self.refreshTimeSchedule)
				self.refreshTimeSchedule=nil
				return
            end
        end	
		local tmpSub =  math.floor(self.m_time-sud)
		if(tmpSub<0)then
		   tmpSub=0
		end
        self.lab_time:setString(string.format("%d秒", tmpSub))
    end
    self.refreshTimeSchedule = scheduler.scheduleGlobal(refreshTimeFun,0.2)   
end

function PokerDismissDeskView:addPlayers()
    self.labTips = {}
    self.agree_img = {}

    local room_info = HallAPI.DataAPI:getRoomInfo()
    local player_list = room_info.pl
    if not player_list then return end 
    local my_id = HallAPI.DataAPI:getUserId()

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
        local pan_head = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_head" .. i)
        pan_head:setVisible(true)
        local img_head = ccui.Helper:seekWidgetByName(pan_head, "img_head")
        local lab_nick = ccui.Helper:seekWidgetByName(pan_head, "lab_nick")
        local lab_tip  = ccui.Helper:seekWidgetByName(pan_head, "lab_tip")
        local agree_img  = ccui.Helper:seekWidgetByName(pan_head, "agree_img")
        local playerID = my_info[i].usI

		local toStr = "" .. playerID
		--玩家昵称
        local strNickName = my_info[i].niN
		local retName = PokerUtils:subUtfStrByCn(strNickName,0,5,"")
        PokerUtils:updateNickName(lab_nick, retName, 22)
		 
        self.labTips[toStr] = lab_tip
        self.agree_img[toStr] = agree_img
		local imgURL = my_info[i].heI or ""
        -- Log.i("imgURL...", imgURL, "string.len(imgURL)...", string.len(imgURL), "site...", i)
        local imgName = playerID .. ".jpg"
        if string.len(imgURL) > 3 then
            -- Log.i("imagename ....", imgName, "site....", i)
            local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName)
            if io.exists(headFile) then
                img_head:loadTexture(imgName)
                img_head:setScale(92 / img_head:getContentSize().width)
            else -- TODO
                -- self:getNetworkImage(imgURL, imgName)
            end
        else              
            local headFile = "hall/Common/default_head_2.png"
            headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile)
            if io.exists(headFile) then
                img_head:loadTexture(headFile)
                img_head:setScale(92 / img_head:getContentSize().width)
            end
        end   
    end
end

function PokerDismissDeskView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.btn_agree then 
            local tmpData={}
			tmpData.usI =  HallAPI.DataAPI:getUserId()
			tmpData.re= 1
			tmpData.niN = HallAPI.DataAPI:getUserName()
			tmpData.isF=1
			SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_LEAVE,tmpData)
            NativeCallUmengEvent(UmengClickEvent.GDGameAgree)
            
        elseif pWidget == self.btn_disagree then
            local tmpData={}
			tmpData.usI =  HallAPI.DataAPI:getUserId()
			tmpData.re= 2
			tmpData.niN = HallAPI.DataAPI:getUserName()
			tmpData.isF=1
			SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_LEAVE,tmpData)
            NativeCallUmengEvent(UmengClickEvent.GDGameDisagree)
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
function PokerDismissDeskView:updateUI(packetInfo)
    -- Log.i("收到玩家解散桌子信息",packetInfo)
	self:updateTime(packetInfo)
    self.lab_time:setVisible(true)
	-- 谁发起的解散
    local strNickName = packetInfo.niN
    local strNickNameLen = string.len(strNickName)
    local nickName = ""
    nickName = PokerUtils:subUtfStrByCn(strNickName,0,4,"")
    PokerUtils:updateNickName(self.txtTitle, string.format("【%s】发起解散牌局申请", nickName), 32)
    DataMgr:getInstance():setDisMissFlag(true)
	--玩家点击“同意”或“不同意”按钮以后，该玩家的“同意”和“不同意”按钮消失
	if(packetInfo.usI == HallAPI.DataAPI:getUserId() and packetInfo.re~=-1 and  packetInfo.re~=0) then
		self.btn_agree:setVisible(false)
        self.btn_disagree:setVisible(false)
        if self.self_agree_tip then
            self.self_agree_tip:setVisible(true)
        end
	end
	
	local toStr = "" .. packetInfo.usI
    local lab_tip = self.labTips[toStr] 
    local agree_img = self.agree_img[toStr]   
    lab_tip:setVisible(true)
    
	local playerInfo = self:getRoomPlayerListInfo(packetInfo.usI)
	if  packetInfo.re == 1 then --1:同意
        lab_tip:setString("同意")
        agree_img:setVisible(true)
        lab_tip:setVisible(false)
	elseif(packetInfo.re == 2 )  then --2:不同意
	    --如果有1名选择选择不同意，则其他玩家无需在继续选择，4名玩家全部自动关闭该界面，并弹出另一提示框，提示内容：玩家xx不同意解散房间。设有“确定”按钮，点击“确定”关闭弹出框；
        lab_tip:setString("不同意")
        agree_img:setVisible(false)
	    local data = {}
		data.type = 1
		data.title = "提示"
		data.closeTitle = "提示"
        local strNickName = playerInfo.niN
        local strNickNameLen = string.len(strNickName)
        local nickName = ""
        nickName = PokerUtils:subUtfStrByCn(strNickName,0,5,"")
		data.content = string.format("【%s】不同意解散房间！", nickName)
		PokerUIManager.getInstance():popWnd(PokerDismissDeskView)
        DataMgr:getInstance():setDisMissFlag(false)
		--如果是自己发起的不同意则不用显示提示UI
		if packetInfo.usI ~= HallAPI.DataAPI:getUserId() then
            local dialog = PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data)
		end
	end
end

----------------------------------------------------
-- @desc 获取玩家信息
-- @pram playerID:玩家id
----------------------------------------------------
function PokerDismissDeskView:getRoomPlayerListInfo(playerID)
    roomInfo = HallAPI.DataAPI:getRoomInfo()
    if (roomInfo.pl ~= nil) then
        for k, v in pairs(roomInfo.pl) do
            if (v.usI == playerID) then
                return v
            end
        end
    end
    return nil
end

-- 收到返回键事件
function PokerDismissDeskView:keyBack()
end

return PokerDismissDeskView