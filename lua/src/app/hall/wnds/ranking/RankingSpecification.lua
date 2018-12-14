--排行榜奖励规则说明
RankingSpecification = class("RankingSpecification", UIWndBase);

function RankingSpecification:ctor(...)
    self.super.ctor(self, "hall/ranking/RankingSpecification.csb", ...);
    self.m_data=...;
	Log.i("排行榜奖励规则说明",self.m_data )
	
self.ContentText=[[
一、活动简介
【房主争霸赛】麻将一出，谁与争锋？四海八荒的房主们，比拼你们的开房数量吧！

二、活动时间
2017年4月12日00:00:00-2017年4月18日23:59:59

三、活动规则
1.活动期间根据开房次数判定排名，前50可获得高价值实物奖励，51-500均有珍惜道具奖励！
2.开房次数相同时，根据当天达到次数的时间先后顺序判定。
3.活动结束后3天内请点击领取按钮上传有效信息。
4.获得虚拟奖励的玩家，活动结束后点击领取按钮可直接拿到虚拟奖励。

四、活动奖励
第1名：Apple iPad mini2 苹果平板电脑7.9英寸
第2名：荣耀 畅玩5C 全网通 高配版 3GB+32GB
第3名：美的（Midea）家用微波炉 变频 烧烤 M1-L201B升级款
第4-10名：小米米兔蓝牙音响
第11-50名：小米5000mAh移动电源
第51-100名：30钻石道具礼包
第101-500名：20钻石道具礼包
]];

	self.ContentText = kRankingSystem:getRankingRule()
	if(self.ContentText==nil or self.ContentText=="") then
	  self.ContentText = "l暂无提示内容"
	end
end

function RankingSpecification:onClose()

end

function RankingSpecification:onInit()
 
   --关闭按钮
   self.closeButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "closeButton");
   self.closeButton:addTouchEventListener(handler(self, self.onCloseButton));
   --规则区域
   self.titlelistView = ccui.Helper:seekWidgetByName(self.m_pWidget, "titlelistView");
  
   --增加阴影
   self:addShowder()
   
end

-- 响应窗口显示
function RankingSpecification:onShow()
    local content = ccui.Text:create();
    content:setFontName("hall/font/bold.ttf")
    content:setColor(cc.c3b(120,68,10))
    content:setTextAreaSize(cc.size(520,0));
    -- 规则显示 
    content:setString(self.ContentText or "提示内容");
    content:setFontSize(26);
    content:ignoreContentAdaptWithSize(false)
    self.titlelistView:pushBackCustomItem(content);
end

--增加阴影
function RankingSpecification:addShowder()
  --self:getWidget(self.m_pWidget,"Label_23",{shadow=true})
  --self:getWidget(self.m_pWidget,"Label_5",{shadow=true})
end

--关闭按钮
function RankingSpecification:onCloseButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
		UIManager:getInstance():popWnd(RankingSpecification);
    end
end

function RankingSpecification:keyBack()
    UIManager:getInstance():popWnd(RankingSpecification);
end