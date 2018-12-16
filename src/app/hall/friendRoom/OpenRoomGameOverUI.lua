--朋友开房间结算基类
OpenRoomGameOverUI = class("OpenRoomGameOverUI",UIWndBase)

--构造函数
function OpenRoomGameOverUI:ctor(...)
    Log.i("OpenRoomGameOverUI:ctor")
    --占时用个空层
    self.super.ctor(self, "hall/null_layer.csb", ...);
    
	self.m_data = ...
	self.roomGameType=self.m_data.roomGameType
end

--析构函数
function OpenRoomGameOverUI:dtor()
    Log.i("OpenRoomGameOverUI:dtor")
end

function OpenRoomGameOverUI:setGameOverUIDelegate(tmpDelegate)
    self.m_delegate = tmpDelegate
end

--改变游戏结算UI用于适应朋友开房UI,以后可能单独做朋友开房UI
function OpenRoomGameOverUI:changBalanceUI(tmpData)

   if(self.roomGameType == FriendRoomGameType.DDZ) then
      Log.i("改变游戏结算UI继续按钮位置")
	  local btn_change = ccui.Helper:seekWidgetByName(self.m_delegate.m_pWidget,"btn_change");
      local btn_continue = ccui.Helper:seekWidgetByName(self.m_delegate.m_pWidget,"btn_continue");
      btn_change:setVisible(false);
	  btn_continue:setVisible(false);
	  
	  local btn_friendRoomContinue = ccui.Helper:seekWidgetByName(self.m_delegate.m_pWidget,"btn_friendRoomContinue");
	  btn_friendRoomContinue:setVisible(true);
   elseif(self.roomGameType == FriendRoomGameType.MJ ) then
      
		local Btn_change = ccui.Helper:seekWidgetByName(self.m_delegate.m_pWidget,"Btn_change");
		Btn_change:setVisible(false);
		local Btn_continue = ccui.Helper:seekWidgetByName(self.m_delegate.m_pWidget,"Btn_continue");
		Btn_continue:setVisible(false);
		
		--朋友开房继续按钮
		local btn_friendRoomContinue = ccui.Helper:seekWidgetByName(self.m_delegate.m_pWidget,"btn_friendRoomContinue");
		btn_friendRoomContinue:setVisible(true);
   end
end

--在有人不在房间时，再显示UI
function OpenRoomGameOverUI:showPlayerLeaveTipUI(tmpData)

end