--游戏基类
PokerOpenRoomGame = class("PokerOpenRoomGame",PokerUIWndBase)

--构造函数
function PokerOpenRoomGame:ctor(...)
    Log.i("PokerOpenRoomGame:ctor")
    --占时用个空层
    self.super.ctor(self, "hall/null_layer.csb", ...);
    
	self.m_data = ...
	self.m_delegate = self.m_data.m_delegate
	self.roomGameType=self.m_data.roomGameType
	
    self.m_infoCache={} --网络信息缓存
	self.m_isShowGameOverUI = false --当前是否显示结算UI
	
	local tmpParam={}
	tmpParam.roomGameType = self.roomGameType
	
	_gameUserChatTxt = true;--大厅麻将及斗地主聊天内都不显示输入框内容，朋友开房进入的游戏界面显示聊天内的输入框内容。
end

--析构函数
function PokerOpenRoomGame:dtor()
    Log.i("PokerOpenRoomGame:dtor")
	_gameUserChatTxt = false;--大厅麻将及斗地主聊天内都不显示输入框内容，朋友开房进入的游戏界面显示聊天内的输入框内容。
	if(self.m_timerProxy~=nil) then
        self.m_timerProxy:finalizer()
		self.m_timerProxy:removeTimer("continue_duration_timer")
		self.m_timerProxy=nil
   end
	kFriendRoomInfo:clearData()
end

--游戏初始化
function PokerOpenRoomGame:init()
  
	Log.i("PokerOpenRoomGame:init")
end

--开始游戏
function PokerOpenRoomGame:starGame()
   Log.i("PokerOpenRoomGame:starGame")
   
end

--游戏进行中
function PokerOpenRoomGame:gameDoing()
  Log.i("PokerOpenRoomGame:gameDoing")
  
end

--结束游戏
function PokerOpenRoomGame:endGame()
 Log.i("PokerOpenRoomGame:endGame")
end

--下一轮/下一局 游戏
function PokerOpenRoomGame:nextRoundGame()
 Log.i("PokerOpenRoomGame:nextRoundGame")

end

--游戏结算UI回调
function PokerOpenRoomGame:gameOverUICallBack(tmpData)
   --奖励的UI层次要大于关闭房间的UI层次
   function comps(a,b)
	  return a.zorder < b.zorder
   end
   table.sort(self.m_infoCache,comps);


   for k, v in pairs(self.m_infoCache) do
      Log.i("游戏结算UI出现后回调:",k)
      if v.obj then
           v.funCall(v.obj,v.param);
      else
           v.funCall(v.param);
      end
   end
   self.m_infoCache=nil
   self.m_infoCache={}
end

--在游戏中点击退出游戏
function PokerOpenRoomGame:normalQuitGame()
    local roomInfo = kFriendRoomInfo:getRoomInfo()
    local curCount=roomInfo.noRS
    local awardCount = kFriendRoomInfo:getCurRoomBaseInfo().roS --发奖的对局数
    local totalCount = kFriendRoomInfo:getCurRoomBaseInfo().roS0--总对局数
   
    local tmpCount =0
    local isAward=false --是否已经发放过奖励,发送过以后,局数计算重新计算,策划设定只会只会发放一次奖励
    if(curCount<awardCount) then
      tmpCount = awardCount-curCount
    else
      tmpCount = totalCount-curCount
	  isAward=true
    end
	
	local data = {}
	data.type = 2;
	data.title = "提示";                        
	data.yesTitle  = "确定";
	data.cancelTitle = "取消";

	local userID =HallAPI.DataAPI:getUserId()
	local isRoom = kFriendRoomInfo:isRoomMain(userID)
	
	if(isRoom) then--如果是房主
	  --
	  if(isAward) then
	    data.content = string.format("本房间已经游戏%d局,再游戏%d局将自动关闭,退出游戏后将托管至本局结束并关闭好友房间.确定要退出吗?",curCount,tmpCount);
	  else
	     data.content = string.format("本房间已经游戏%d局,再游戏%d局将获得房间奖励,退出游戏后将托管至本局结束并关闭好友房间.确定要退出吗?",curCount,tmpCount);
	  end
	else
	  --
	  if(isAward) then
	     data.content = string.format("本房间已经游戏%d局,再游戏%d局将自动关闭,此操作将托管至本局结束并退出好友房间.确定要退出吗？",curCount,tmpCount);
	  else
	     data.content = string.format("本房间已经游戏%d局,再游戏%d局将获得房间奖励,此操作将托管至本局结束并退出好友房间,确定要退出吗?",curCount,tmpCount);
	  end
	end

	data.yesCallback = function()
		self:closeRoom()
	end

	local tipUI =PokerUIManager.getInstance():pushWnd(CommonDialog, data)
	--tipUI.m_pWidget:setGlobalZOrder(99999)
end

--游戏打完一局后,手动点击退出游戏,才能向服务器发送关闭房间 
function PokerOpenRoomGame:quitGame()
   local roomInfo = kFriendRoomInfo:getRoomInfo()
   local curCount=roomInfo.noRS
   local awardCount = kFriendRoomInfo:getCurRoomBaseInfo().roS --发奖的对局数
   local totalCount = kFriendRoomInfo:getCurRoomBaseInfo().roS0--总对局数
   
    local tmpCount =0
    local isAward=false --是否已经发放过奖励,发送过以后,局数计算重新计算,策划设定只会只会发放一次奖励
    if(curCount<awardCount) then
      tmpCount = awardCount-curCount
    else
      tmpCount = totalCount-curCount
	  isAward=true
    end
   
	local data = {}
	data.type = 2;
	data.title = "提示";                        
	data.yesTitle  = "确定";
	data.cancelTitle = "取消";

	local userID =HallAPI.DataAPI:getUserId()
	local isRoom = kFriendRoomInfo:isRoomMain(userID)
	
	if(isRoom) then--如果是房主
	  --
	  if(isAward) then
	    data.content = string.format("本房间已经游戏%d局,再游戏%d局将自动关闭,退出游戏将关闭好友房间,确定要退出吗?",curCount,tmpCount);
	  else
	    data.content = string.format("本房间已经游戏%d局,再游戏%d局将获得房间奖励,此操作将关闭好友房间,确定要关闭吗?",curCount,tmpCount);
	  end
	else
	  --
	  if(isAward) then
	    data.content = string.format("本房间已经游戏%d局,再游戏%d局将自动关闭,退出游戏将退出好友房间,确定要退出吗?",curCount,tmpCount);
	  else
	    data.content = string.format("本房间已经游戏%d局,再游戏%d局将获得房间奖励,退出游戏将退出好友房间,确定要退出吗？",curCount,tmpCount);
	  end
	 
	end

	data.yesCallback = function()
		local tmpData={}
		tmpData.usI= HallAPI.DataAPI:getUserId()
		--FriendRoomSocketProcesser.sendRoomQuit(tmpData)
	end

	local tipUI = PokerUIManager.getInstance():pushWnd(CommonDialog, data);
    --tipUI.m_pWidget:setGlobalZOrder(99999)
end

--游戏打完一局后,才能向服务器发送关闭房间
function PokerOpenRoomGame:recvRoomQuit(packetInfo)
    Log.i("退出邀请房结果",packetInfo)
	
	--##  usI  long  玩家id
    --re  int  结果（-1 失败，1 成功）
	if(packetInfo.re==1) then
	
	   if(self.m_isShowGameOverUI) then--如果已经显示结算UI
	        self:onRecvRoomQuit(packetInfo)
	   else
	      	local tmpData={}
	        tmpData.param = packetInfo
	        tmpData.funCall= self.onRecvRoomQuit
			tmpData.obj = self
			tmpData.zorder=10
	        self.m_infoCache["recvRoomQuit"] = tmpData 
			Log.i("缓存退出邀请房结果recvRoomQuit")
	   end
	end
end

--因为结算界面做了时间严时，所以提示框得在它后面创建
function PokerOpenRoomGame:onRecvRoomQuit(packetInfo)

    local exitUserID = packetInfo.usI
	local localUserID = HallAPI.DataAPI:getUserId()
	
	--如果是房主退出
	if(kFriendRoomInfo:isRoomMain(exitUserID)) then
	
		if(exitUserID == localUserID) then--如果是房主
		
		    HallAPI.ViewAPI:showToast("房间已关闭!");
		   --HallAPI.DataAPI:send(CODE_TYPE_ROOM, DDZSocketCmd.CODE_SEND_ExitRoom, {});
		   self:closeRoom()
		  
		else
			--房主已退出，此房间已经关闭，请选择其他游戏！确定
			local data = {}
			data.type = 1;
			data.title = "提示";
			data.closeTitle = "退出房间";
			data.content = "房主关闭当前房间,请重新选择其他游戏！";
			data.closeCallback = function ()
				  --HallAPI.DataAPI:send(CODE_TYPE_ROOM, DDZSocketCmd.CODE_SEND_ExitRoom, {});
				  Log.i("点击房主关闭当前房间确定按钮")
				  self:closeRoom()
			end
			
			PokerUIManager.getInstance():pushWnd(CommonDialog, data)

		end
	
	else  
	    --别的玩家退出
		--local exitPlayerInfo = kFriendRoomInfo:getRoomPlayerListInfo(exitUserID)
		
		--自己方收到消息则不用提示
		if(exitUserID ~= localUserID) then 
		    local playerName = packetInfo.niN--exitPlayerInfo.niN
            local str = string.format("%s退出当前房间,请重新邀请其他人继续游戏！",playerName)
		   	
			local data = {}
			data.type = 1;
			data.title = "提示";
			data.closeTitle = "退出房间";
			data.content = str;
			data.closeCallback = function ()
				--HallAPI.DataAPI:send(CODE_TYPE_ROOM, DDZSocketCmd.CODE_SEND_ExitRoom, {});
				Log.i("点击退出房间确定按钮")
				self:returnRoomUI()
			end
			
			local tmpUI  = PokerUIManager.getInstance():pushWnd(CommonDialog, data);
			tmpUI.m_pWidget:performWithDelay(function ()
			  	self:returnRoomUI()		
		    end,5);--如果有的玩家一直不点击确定按钮,刚等到一定时间自动把玩家拉回到房间

		else
			self:closeRoom()
		end 	
	end
	
	--更新玩家列表，从列表中删除退出房间的人
	--kFriendRoomInfo:removeRoomPlayerInfo(exitUserID)

end

--发放奖励
function PokerOpenRoomGame:recvRoomReWard(packetInfo)
  
   if(self.m_isShowGameOverUI) then--如果已经显示结算UI
		self:OnRecvRoomReWard(packetInfo)
   else
		local tmpData={}
		tmpData.param = packetInfo
		tmpData.funCall= self.OnRecvRoomReWard
		tmpData.obj = self
		tmpData.zorder=50
		self.m_infoCache["recvRoomReWard"] = tmpData 
		Log.i("邀请房发放奖励结果recvRoomReWard")
   end
	
end

function PokerOpenRoomGame:OnRecvRoomReWard(packetInfo)
--[[
   		local data = {}
		data.type = 1;
		data.title = "提示";
		data.content = packetInfo.ti;
		data.closeCallback = function ()
		    Log.i("点击领取奖励确定按钮")
			--PokerUIManager.getInstance():popWnd(CommonDialog)
		end
		PokerUIManager.getInstance():pushWnd(CommonDialog, data) 
]]	
		--CommonAnimManager.getInstance():showMoneyWinAnim(100)
		local param={}
		param.roomGameType = self.roomGameType;
		PokerUIManager.getInstance():pushWnd(OpenRoomReward,param);

end

-- --房间关闭时
-- function PokerOpenRoomGame:recvRoomEnd(packetInfo)
    
--    if(self.m_isShowGameOverUI) then--如果已经显示结算UI
-- 		self:onRecvRoomEnd(packetInfo)
--    else
-- 		local tmpData={}
-- 		tmpData.param = packetInfo
-- 		tmpData.funCall= self.onRecvRoomEnd
-- 		tmpData.obj = self
-- 		tmpData.zorder=10
-- 		self.m_infoCache["recvRoomEnd"] = tmpData 
-- 		Log.i("邀请房房间关闭结果recvRoomEnd")
--    end
-- end

function PokerOpenRoomGame:recvRoomEnd(packetInfo)
	 if not kFriendRoomInfo:isRoomMain(HallAPI.DataAPI:getUserId()) or packetInfo.ty ~= 1 then
        local data = {};
        data.type = 1;
        data.title = "提示";
        data.content = packetInfo.ti;
        data.closeCallback = function ()
           kFriendRoomInfo:clearData()
           self:closeRoomSceneUI();
        end
        PokerUIManager.getInstance():pushWnd(CommonDialog, data);
    else
        kFriendRoomInfo:clearData()
        self:closeRoomSceneUI();
    end
end

function PokerOpenRoomGame:closeRoomSceneUI(tmpData)
    PokerUIManager:getInstance():popWnd(self.m_delegate);
    --当从游戏返回时,屏幕会黑屏
    local tmpRet = PokerUIManager:getInstance():getWnd(HallMain)
    if(tmpRet==nil) then
        PokerUIManager:getInstance():pushWnd(HallMain);
    end
    --是否有打开退出房间提示框
    if(PokerUIManager.getInstance():getWnd(CommonDialog)~=nil) then
       PokerUIManager.getInstance():popWnd(CommonDialog)
    end
end
-- --房间关闭时
-- function PokerOpenRoomGame:recvRoomEnd(packetInfo)
    
--    if(self.m_isShowGameOverUI) then--如果已经显示结算UI
-- 		self:onRecvRoomEnd(packetInfo)
--    else
-- 		local tmpData={}
-- 		tmpData.param = packetInfo
-- 		tmpData.funCall= self.onRecvRoomEnd
-- 		tmpData.obj = self
-- 		tmpData.zorder=10
-- 		self.m_infoCache["recvRoomEnd"] = tmpData 
-- 		Log.i("邀请房房间关闭结果recvRoomEnd")
--    end
-- end

-- function PokerOpenRoomGame:onRecvRoomEnd(packetInfo)
--     Log.i("房主关闭房间,或者打满一定局数游戏自动关闭房间")
-- 	local data = {}
-- 	data.type = 1;
-- 	data.title = "提示";
-- 	data.content = packetInfo.ti;
-- 	data.closeCallback = function ()
-- 	   Log.i("点击房间关闭确定按钮")
-- 	   self:closeRoom(packetInfo);
-- 	end
-- 	PokerUIManager.getInstance():pushWnd(CommonDialog, data) 
-- end


--房主关闭房间,或者打满一定局数游戏自动关闭房间
function PokerOpenRoomGame:closeRoom(tmpData)
   Log.i("有玩家退出房间")
   if(self.roomGameType == FriendRoomGameType.DDZ ) then

       self.m_delegate:requestExitRoom()
	   
   elseif(self.roomGameType == FriendRoomGameType.MJ ) then
		MjMediator:getInstance():requestExitRoom()
        --MjMediator:getInstance():exitGame();
   end
   
end


--如果不是房主关闭房间,刚别的玩家一局游戏结束后,自己把别的玩家拉到房间UI界面上
function PokerOpenRoomGame:returnRoomUI(tmpData)
 
   Log.i("不是房主退出房间,玩家强制拉回到房间UI界面上");
   Log.i("不能发送正常游戏的20014消息,会导致服务端把房间关闭,导致房间不存在");
   if(self.roomGameType == FriendRoomGameType.DDZ) then
		self.m_delegate:onExitRoom();	
   elseif(self.roomGameType == FriendRoomGameType.MJ ) then
        MjMediator:getInstance():exitGame();
   end
end

--
function PokerOpenRoomGame:recvRoomSceneInfo(packetInfo)
	print("*******************************mzd cmd")
	dump(cmd)
	Log.i("ddzFriendRoomSocketProcesser 接收邀请房信息",packetInfo)
    packetInfo = checktable(packetInfo)
	kFriendRoomInfo:setRoomInfo(packetInfo)
	self.m_delegate:updateRoomSceneInfo()
   Log.i("有玩家掉线后重新回到游戏中.........")
end


function PokerOpenRoomGame:recvFriendRoomStartGame(packetInfo)
   Log.i("收到玩家点击继续玩游戏按钮消息.........")
   -- LoadingView.getInstance():hide();
   
   self.m_isShowGameOverUI=false;
   if(self.m_timerProxy~=nil) then
        self.m_timerProxy:finalizer()
		self.m_timerProxy:removeTimer("continue_duration_timer")
		self.m_timerProxy=nil
   end
   
   if(self.roomGameType == FriendRoomGameType.DDZ) then
   
      self.m_delegate:repGameStart(packetInfo);

   elseif(self.roomGameType == FriendRoomGameType.MJ ) then
   
   end
end

--玩家解散
function PokerOpenRoomGame:recvFriendRoomLeaveGame(packetInfo)
	print("<mzd>___________________________解散玩家")
	dump(packetInfo)
    local dismissDeskView = PokerUIManager.getInstance():getWnd(DismissDeskView);
    if dismissDeskView == nil then
        dismissDeskView = PokerUIManager:getInstance():pushWnd(DismissDeskView, nil, 100, self)
	end
    dismissDeskView:updateUI(packetInfo)
end

--游戏中点击继续按钮
function PokerOpenRoomGame:onContinueButton(tmpDataParam)
 
  	local data = {};
    data.gaI = MjProxy:getInstance():getGameId()
    data.roI = MjProxy:getInstance():getRoomId()
    data.ty = ctype -- 1 续局 2 换桌
    Log.i("MjMediator:continueGame data=", data)
    HallAPI.DataAPI:send(CODE_TYPE_ROOM, DDZSocketCmd.CODE_SEND_GAMESTART, data)

    
   --播放背景音乐
   --  _playGameMusic();
   
   -- LoadingView.getInstance():show("您的好友还没选择继续,请耐心等待!");
   -- if(self.roomGameType == FriendRoomGameType.DDZ) then
	  --  local function updateContinue()
		 --  LoadingView.getInstance():show("您的好友还没选择继续,请耐心等待!");
	  --  end
	  --  if(self.m_timerProxy==nil) then
		 --   self.m_timerProxy = require "app.common.TimerProxy".new()
		 --   self.m_timerProxy:addTimer("continue_duration_timer", updateContinue,15,-1)
	  --  end
   -- end
   
   --self:updateCountUI();
end

--显示游戏结算界面时
function PokerOpenRoomGame:onShowGameOverUI(tmpDataParam)
    --self.m_isShowGameOverUI=true
	--self:nextRoundGame();
	--self:gameOverUICallBack()
	
end

--设置还有多少局
function PokerOpenRoomGame:setCountUI(tmpWidget)

   local roomInfo = kFriendRoomInfo:getRoomInfo()
   local curCount=roomInfo.noRS
   local awardCount = kFriendRoomInfo:getCurRoomBaseInfo().roS --发奖的对局数
   local totalCount = kFriendRoomInfo:getCurRoomBaseInfo().roS0--总对局数
   
    self.m_substituteLabel = cc.Label:create()
	local n = totalCount-curCount-1;
	if(n<=0)then
	   n=0;
	end
	local strC = string.format("房间关闭还剩%d局",n)
    self.m_substituteLabel:setString(strC);
    self.m_substituteLabel:setSystemFontSize(25)
    self.m_substituteLabel:setSystemFontName ("hall/font/bold.ttf")
	self.m_substituteLabel:setColor(cc.c3b(0,0,0));
	tmpWidget:addChild(self.m_substituteLabel);
	
	local visibleWidth = cc.Director:getInstance():getVisibleSize().width
	local visibleHeight = cc.Director:getInstance():getVisibleSize().height
	
	if(self.roomGameType == FriendRoomGameType.DDZ) then
	   self.m_substituteLabel:setPosition(cc.p(visibleWidth*0.5,visibleHeight-135))
	else
	  self.m_substituteLabel:setPosition(cc.p(visibleWidth*0.5,visibleHeight*0.5+80))
	end
end

--更新还有多少局
function PokerOpenRoomGame:updateCountUI()
    local roomInfo = kFriendRoomInfo:getRoomInfo()
    local curCount=roomInfo.noRS
    local awardCount = kFriendRoomInfo:getCurRoomBaseInfo().roS --发奖的对局数
    local totalCount = kFriendRoomInfo:getCurRoomBaseInfo().roS0--总对局数
   
	local n = totalCount-curCount-1;
	if(n<=0)then
	   n=0;
	end
	local strC = string.format("房间关闭还剩%d局",n)
    self.m_substituteLabel:setString(strC);
end
	
--
-- PokerOpenRoomGame.s_socketCmdFuncMap = {
--     [DDZSocketCmd.CODE_FRIEND_ROOM_INFO_QUIT] = PokerOpenRoomGame.recvRoomQuit; --InviteRoomEnter	 退出邀请房结果
-- 	[DDZSocketCmd.CODE_RECV_FRIEND_ROOM_REWARD] = PokerOpenRoomGame.recvRoomReWard; 	--InviteRoomRankAward	 邀请房排行奖励
-- 	[DDZSocketCmd.CODE_RECV_FRIEND_ROOM_END] = PokerOpenRoomGame.recvRoomEnd; 	--InviteRoomEnd	 邀请房结束
-- 	[DDZSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = PokerOpenRoomGame.recvRoomSceneInfo; --InviteRoomInfo	 邀请房信息
-- 	[DDZSocketCmd.CODE_RECV_FRIEND_ROOM_START] = PokerOpenRoomGame.recvFriendRoomStartGame; --邀请房对局开始
-- 	[DDZSocketCmd.CODE_FRIEND_ROOM_LEAVE] = PokerOpenRoomGame.recvFriendRoomLeaveGame
-- };


return PokerOpenRoomGame