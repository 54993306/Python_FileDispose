--排行榜前500名玩家列表
RankingInfo = class("RankingInfo", UIWndBase);

local RankingNode= require "app.hall.wnds.ranking.RankingNode"

function RankingInfo:ctor(...)
    self.super.ctor(self, "hall/ranking/RankingInfo.csb", ...);
	self.m_rankingEnterData = kRankingSystem:getRankingEnterData();
	--Log.i("排行榜入口数据",self.m_rankingEnterData);
end

function RankingInfo:onClose()
    Log.i("关闭窗口");
end

function RankingInfo:onInit()
 
   --关闭按钮
   self.closeButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "closeButton");
   self.closeButton:addTouchEventListener(handler(self, self.onCloseButton));
   --排名节点
   self.baimingButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "baimingButton");
   self.baimingButton:addTouchEventListener(handler(self, self.onBaiMingButton));

   self.netWaitPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "netWaitPanel");
   self.netWaitPanel:setVisible(false);
   self.netTitle = ccui.Helper:seekWidgetByName(self.m_pWidget, "netTitle");
   
   self.timeLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "timeLabel");
   --增加阴影
   self:addShowder()
   
end

-- 响应窗口显示
function RankingInfo:onShow()
   --我的排名信息
   local baiMingLabel =  ccui.Helper:seekWidgetByName(self.m_pWidget, "baiMingLabel");
   local s =""
   if(self.m_rankingEnterData.myR<=0) then
      s = string.format("我的排名:未上榜     开房%d次",self.m_rankingEnterData.myRN);
   else
      s =  string.format("我的排名：%d     开房%d次",self.m_rankingEnterData.myR,self.m_rankingEnterData.myRN);
   end
   baiMingLabel:setString(s);

   --
   self:createScrollView();
   --更新时间
   self.timeLabel:setString("最近更新:".. self.m_rankingEnterData.upT);
end

--创建”没有更多数据“ui
function RankingInfo:createLastTitle()
    local content = ccui.Text:create();
    content:setFontName("hall/font/bold.ttf")
    --content:setColor(cc.c3b(120,68,10))
    content:setTextAreaSize(cc.size(880,0));
    -- 规则显示 
    content:setString("没有更多数据了");
    content:setFontSize(32);
    content:ignoreContentAdaptWithSize(false)
	content:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.infoListView:addChild(content)
end

function RankingInfo:createScrollView()
    self.m_headImageList={}
    local rankingNode = RankingNode.new();
    local scrollview = ccui.Helper:seekWidgetByName(self.m_pWidget, "infoScrollView");
	scrollview:removeAllChildren()
	local tipLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "tipLabel");
	--临时数据占位符
	self.m_rankingData=kRankingSystem:getRankingDataArray();
	--dump(rankingData)
	if(#self.m_rankingData>0)then
	    tipLabel:setVisible(false);
		local function scrollFunc(data,mWight,nIndex,from)
			 Log.i("视图滑动到第" .. nIndex .. "页");
			 rankingNode:updateUI(mWight,data);
			 --动态拉取玩家头像
			 local headImageUI = rankingNode:getHeadImage(mWight)
			 self.m_headImageList[nIndex] = headImageUI;
			 local imgUrl = data.ic;
			 Log.i("------imgUrl", imgUrl);
			 if string.len(imgUrl) > 4 and string.sub(imgUrl,1,4) == "http" then
				local imgName = data.usI .. ".jpg";
				local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
				if io.exists(headFile) then
				   headImageUI:loadTexture(headFile);
				else
				   HttpManager.getNetworkImage(imgUrl,imgName);
				end
			 end
		end
		
		self.rankingNodeCSB = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/ranking/RankingNode.csb"); 
		self.playerInfoPanel = ccui.Helper:seekWidgetByName(self.rankingNodeCSB, "playerInfoPanel");
		self.scrollViewUI = new_cScrollView(scrollview,self.playerInfoPanel,self.m_rankingData,scrollFunc,0,5)
	else
       tipLabel:setVisible(true);
	end
end

function RankingInfo:updateRankingData(tmpData)
    local tmpData1={}
	tmpData1.index=1;
	tmpData1.id=2000;
	tmpData1.name="zuojs";
	self.scrollViewUI:updateSclData(1,tmpData1);
end

--显示正在拉取数据
function RankingInfo:showNetWaitUI()
    self.netWaitPanel:setVisible(true);
	if(not self.m_isRunAction) then
		self.m_isRunAction=true;
		local actionString="......"
		local function labelActionFunc()
			local asLen = string.len(actionString)
			if asLen>=0 and asLen < 5 then
				actionString = actionString.."."
			else
				actionString = ""
			end 
			self.netTitle:setString("正在拉取数据中"..actionString)
			local cf = cc.CallFunc:create(labelActionFunc)
			local dt = cc.DelayTime:create(0.3)
			self.netTitle:runAction(cc.Sequence:create(dt,cf))
		end
		labelActionFunc()
	end
end

--增加阴影
function RankingInfo:addShowder()
  --self:getWidget(self.m_pWidget,"Label_23",{shadow=true})
  --self:getWidget(self.m_pWidget,"Label_5",{shadow=true})
end

--关闭按钮
function RankingInfo:onCloseButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
		UIManager:getInstance():popWnd(RankingInfo);
    end
end

--排名节点
function RankingInfo:onBaiMingButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
		UIManager:getInstance():pushWnd(RankingRewardInfo);
    end
end

--返回网络图片
function RankingInfo:onResponseNetImg(fileName)
    Log.i("------RankingInfo:onResponseNetImg fileName", fileName);
    if fileName == nil then
        return;
    end
	for i=1,#self.m_rankingData do
	    local v=self.m_rankingData[i]
	    local imgName = v.usI .. ".jpg"
	    if fileName == imgName then
            local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
			if io.exists(headFile) then
               self.m_headImageList[i]:loadTexture(headFile);
            end
        end
	end
end

function RankingInfo:keyBack()
    UIManager:getInstance():popWnd(RankingInfo);
end