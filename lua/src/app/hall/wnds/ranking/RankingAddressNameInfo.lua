--获取奖励要填的信息：电话，地址，姓名

RankingAddressNameInfo = class("RankingAddressNameInfo", UIWndBase);

function RankingAddressNameInfo:ctor(...)
    self.super.ctor(self, "hall/ranking/RankingAddressNameInfo.csb", ...);
    self.m_data=...;
	Log.i("排行榜奖励规则说明",self.m_data )
end

function RankingAddressNameInfo:onClose()
  
end

function RankingAddressNameInfo:onInit()
	--关闭按钮
	self.closeButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "closeButton");
	self.closeButton:addTouchEventListener(handler(self, self.onCloseButton));
	--玩家信息上传
	self.uploadButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "uploadButton");
	self.uploadButton:addTouchEventListener(handler(self, self.onUploadButton));
	--取玩家姓名
	self.myNameEditLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "myNameEditLabel");
	--取玩家电话
	self.myIphoneEditLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "myIphoneEditLabel");
	--取玩家地址
	self.myAddressEditLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "myAddressEditLabel");
	--增加阴影
	self:addShowder()
end

-- 响应窗口显示
function RankingAddressNameInfo:onShow()
   --用户昵称
   local rankingEnterData = kRankingSystem:getRankingEnterData();
   local nameLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "nameLabel");
   -- nameLabel:setString(ToolKit.subUtfStrByCn(kUserInfo:getUserName(), 0, 6, "..."));
   Util.updateNickName(nameLabel, ToolKit.subUtfStrByCn(kUserInfo:getUserName(), 0, 6, "..."), 22)
  
  --排名
   local paimingLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "paimingLabel");
   paimingLabel:setString("" .. rankingEnterData.myR);
   
   --我的排名信息描述
   local s = string.format("开房 %d 次",rankingEnterData.myRN);
   local openRoomTitle = ccui.Helper:seekWidgetByName(self.m_pWidget, "openRoomTitle");
   openRoomTitle:setString(s);
   
   --玩家头像
    local headImage = ccui.Helper:seekWidgetByName(self.m_pWidget, "headImage");
    local imgName = kUserInfo:getUserId() .. ".jpg";
    local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
    if io.exists(headFile) then
		headImage:loadTexture(headFile);
	end
end

--增加阴影
function RankingAddressNameInfo:addShowder()
  --self:getWidget(self.m_pWidget,"Label_23",{shadow=true})
  --self:getWidget(self.m_pWidget,"Label_5",{shadow=true})
end

--关闭按钮
function RankingAddressNameInfo:onCloseButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
		UIManager:getInstance():popWnd(RankingAddressNameInfo);
    end
end

function RankingAddressNameInfo:onUploadButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
	    local paramInfo={}
		paramInfo.name=""
		paramInfo.iphone ="";
		paramInfo.address =""
		--取玩家姓名
        paramInfo.name = self.myNameEditLabel:getString();
		if(paramInfo.name=="") then
		   Toast.getInstance():show("姓名不能为空");
		   return;
		end
		--取玩家电话
        paramInfo.iphone = self.myIphoneEditLabel:getString();
		if(paramInfo.iphone=="") then
		   Toast.getInstance():show("电话不能为空");
		   return;
		else
		   --
		   local n = tonumber(paramInfo.iphone);
		   if(n==nil) then
		     Toast.getInstance():show("电话只能为数字");
			 return;
		   end
		end

		--取玩家地址
        paramInfo.address = self.myAddressEditLabel:getString();
		if(paramInfo.address=="") then
		   Toast.getInstance():show("地址不能为空");
		   return;
		end
        Log.i("开始上传玩家信息,姓名:" .. paramInfo.name .."电话:" .. paramInfo.iphone .."地址:" .. paramInfo.address);
		UIManager:getInstance():pushWnd(RankingConfirmInfo,paramInfo);
    end
end

function RankingAddressNameInfo:keyBack()
    UIManager:getInstance():popWnd(RankingAddressNameInfo);
end