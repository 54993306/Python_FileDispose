--获取奖励要填的信息：电话，地址，姓名

RankingRewardInfo = class("RankingRewardInfo", UIWndBase);

function RankingRewardInfo:ctor(...)
    self.super.ctor(self, "hall/ranking/RankingRewardInfo.csb", ...);
    self.m_data=...;
	Log.i("排行榜奖励规则说明",self.m_data )
end

function RankingRewardInfo:onClose()

end

function RankingRewardInfo:onInit()
 
   --关闭按钮
   self.closeButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "closeButton");
   self.closeButton:addTouchEventListener(handler(self, self.onCloseButton));
 
   --增加阴影
   self:addShowder()
   
end

-- 响应窗口显示
function RankingRewardInfo:onShow()
   
    local rd = kRankingSystem:getRankingSimpleRankNode();

	local listview = ccui.Helper:seekWidgetByName(self.m_pWidget, "listview"); 
	local color_1 = ccui.Helper:seekWidgetByName(self.m_pWidget, "color_1");
	local color_2 = ccui.Helper:seekWidgetByName(self.m_pWidget, "color_2");
	Log.i("dkkkkkk",rd);
	for i=1,#rd do
		 local v =rd[i]
		 local cloneUI;
		 if(i%2==0)then
		   cloneUI=color_1:clone();
		 else
		   cloneUI=color_2:clone();
		 end
		 local valueLabel_1 = ccui.Helper:seekWidgetByName(cloneUI, "valueLabel_1");
		 local valueLabel_2 = ccui.Helper:seekWidgetByName(cloneUI, "valueLabel_2");
		 valueLabel_1:setString("" .. v.ra)
		 valueLabel_2:setString("" .. v.roN)
		 
		 listview:addChild(cloneUI)
	end
end

--增加阴影
function RankingRewardInfo:addShowder()
  --self:getWidget(self.m_pWidget,"Label_23",{shadow=true})
  --self:getWidget(self.m_pWidget,"Label_5",{shadow=true})
end

--关闭按钮
function RankingRewardInfo:onCloseButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
		UIManager:getInstance():popWnd(RankingRewardInfo);
    end
end

function RankingRewardInfo:keyBack()
    UIManager:getInstance():popWnd(RankingRewardInfo);
end