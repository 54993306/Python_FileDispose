--玩家电话，地址，姓名信息确认ui。

RankingConfirmInfo = class("RankingConfirmInfo", UIWndBase);

function RankingConfirmInfo:ctor(...)
    self.super.ctor(self, "hall/ranking/RankingConfirmInfo.csb", ...);
    self.m_data=...;
	Log.i("请确认玩家电话，地址，姓名信息",self.m_data )
	
	self.m_socketProcesser = RankingSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
end

function RankingConfirmInfo:onClose()
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
end

function RankingConfirmInfo:onInit()
 
   --关闭按钮
   self.closeButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "closeButton");
   self.closeButton:addTouchEventListener(handler(self, self.onCloseButton));
   
   --取消上传
   self.cancelButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "cancelButton");
   self.cancelButton:addTouchEventListener(handler(self, self.onClickButton));
   
   --上传
   self.upButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "upButton");
   self.upButton:addTouchEventListener(handler(self, self.onClickButton));
   
   --增加阴影
   self:addShowder()
   
end

-- 响应窗口显示
function RankingConfirmInfo:onShow()
   local nameLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "nameLabel");
   local iphone = ccui.Helper:seekWidgetByName(self.m_pWidget, "iphone");
   local address = ccui.Helper:seekWidgetByName(self.m_pWidget, "address");
   nameLabel:setString("姓名:" .. self.m_data.name);
   iphone:setString("电话:" .. self.m_data.iphone);
   address:setString("地址:" .. self.m_data.address);
end

--增加阴影
function RankingConfirmInfo:addShowder()
  --self:getWidget(self.m_pWidget,"Label_23",{shadow=true})
  --self:getWidget(self.m_pWidget,"Label_5",{shadow=true})
end

--关闭按钮
function RankingConfirmInfo:onCloseButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
		UIManager:getInstance():popWnd(RankingConfirmInfo);
    end
end

--取消与上传按钮
function RankingConfirmInfo:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
	    if(pWidget==self.cancelButton) then
		    UIManager:getInstance():popWnd(RankingConfirmInfo);
		elseif(pWidget==self.upButton) then
			 local tmpData={}
			 tmpData.na = self.m_data.name;
			 tmpData.ph = self.m_data.iphone;
			 tmpData.ad = self.m_data.address;
			 tmpData.re = -1;
             RankingSocketProcesser.sendAddressInfoData(tmpData)
		end
    end
end

function RankingConfirmInfo:keyBack()
    UIManager:getInstance():popWnd(RankingConfirmInfo);
end

--上传数据结果返回值
function RankingConfirmInfo:recvAddressInfoData(packetInfo)
   if(packetInfo.re ==0) then --##  re  int  结果(0:操作成功 )
      Log.i("上传成功数据成功");
      Toast.getInstance():show("上传成功");
      UIManager:getInstance():popWnd(RankingConfirmInfo);
	  local frontUI = UIManager.getInstance():getWnd(RankingAddressNameInfo);
	  if(frontUI~=nil)then
	    UIManager:getInstance():popWnd(RankingAddressNameInfo);
	  end
   else
      Toast.getInstance():show("上传失败,请重新上传");
   end
end

RankingConfirmInfo.s_socketCmdFuncMap = {
 [HallSocketCmd.CODE_RANKING_SET_PALYERDATA] = RankingConfirmInfo.recvAddressInfoData, --InviteRoomEnter  退出邀请房结果
};