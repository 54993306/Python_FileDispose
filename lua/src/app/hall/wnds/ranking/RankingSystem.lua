--排行榜数据处理系统
RankingSystem = class("FriendRoomInfo");

RankingSystem.getInstance = function()
    if not RankingSystem.s_instance then
        RankingSystem.s_instance = RankingSystem.new();
    end

    return RankingSystem.s_instance;
end

--设置排行榜入口数据
function RankingSystem:setPlayerRankingData(tmpData)
    self.m_playerRankingData={};
	self.m_playerRankingData.ruC = tmpData.ruC;	--ruC  String  详情/规则
	self.m_playerRankingData.myR = tmpData.myR;	--    myR  int  我的排名
 	self.m_playerRankingData.myRN = tmpData.myRN;  	--    myRN  int  我的开房次数
 	self.m_playerRankingData.btS = tmpData.btS;  	--    btS  int  按钮状态（0：不能领取  1：实物，弹出界面  2：非实物，直接领取）
	self.m_playerRankingData.acS = tmpData.acS; --acS  int  活动状态（1：未开始 2：活动阶段 3：领奖阶段 4：已结束）
    self.m_playerRankingData.leH = tmpData.leH; --leH  int  距下一阶段剩余时间（单位：小时，0为已结束）

	--奖品名称数组
	self.m_playerRankingData.rewardArray={};
	for i=1,#tmpData.reL do
	   table.insert(self.m_playerRankingData.rewardArray,tmpData.reL[i])
	end
	
	--第1，2，3排名信息
	self.m_playerRankingData.rankingDataArray={};
	for i=1,#tmpData.raL do
	    local v= tmpData.raL[i];
	    local tmpData={};
	   	tmpData.ra =v.ra;  --     ra  int  名次
	  	tmpData.ic =v.ic;  --     ic  String  头像
	  	tmpData.na =v.na;  --     na  String  昵称
	  	tmpData.usI =v.usI;--     usI  int  ID
	  	tmpData.roN =v.roN;--     roN  int  开房次数
	  	tmpData.reI =v.reI;--     reI  int  奖品index
	    table.insert(self.m_playerRankingData.rankingDataArray,tmpData)
	end	
end

--获取排行榜入口数据
function RankingSystem:getRankingEnterData()
   return self.m_playerRankingData;
end

--设置排行榜页面数据 
function RankingSystem:setRankingPageData(tmpData)
    self.m_playerRankingData.myR = tmpData.myR;	--    myR  int  我的排名
 	self.m_playerRankingData.myRN = tmpData.myRN;  	--    myRN  int  我的开房次数
	self.m_playerRankingData.toN = tmpData.toN;--   toN  int  总个数

	self.m_playerRankingData.upT = tmpData.upT;--   upT  String  排行更新时间
	self.m_playerRankingData.buI = tmpData.buI;--   buI  int  缓存阶段id
	
	--排名汇总数据
	self.m_playerRankingData.simpleRankNode={}
    for i=1,#tmpData.noL  do
	   local v = tmpData.noL[i]
	   local tmpData={}
	   tmpData.ra=v.ra;--    ra  int  排行节点
	   tmpData.roN=v.roN;--    --    roN  int  房间数
	   table.insert(self.m_playerRankingData.simpleRankNode,tmpData)
	end
end

--改变排行榜页面数据 
function RankingSystem:changRankingPageData(tmpData)    
	self.m_playerRankingData.rankingDataArray={};
	for i=1,#tmpData.raL do
	   local v= tmpData.raL[i];
	   local tmpData={};
	   	tmpData.ra =v.ra;  --     ra  int  名次
	  	tmpData.ic =v.ic;  --     ic  String  头像
	  	tmpData.na =v.na;  --     na  String  昵称
	  	tmpData.usI =v.usI;--     usI  int  ID
	  	tmpData.roN =v.roN;--     roN  int  开房次数
	  	tmpData.reI =v.reI;--     reI  int  奖品index
	    table.insert(self.m_playerRankingData.rankingDataArray,tmpData)
	end	
end

--获取奖励物品描述
function RankingSystem:getRewardDescribing(tmpIndex)
   if(tmpIndex<0 or tmpIndex>#self.m_playerRankingData.rewardArray) then
     Log.i("没有查找到奖励物品描述");
     return ""
   end
   Log.i("奖励物品描述",tmpIndex);
   return self.m_playerRankingData.rewardArray[tmpIndex].re;
end

--获取第1，2，3排名信息
function RankingSystem:getRankingDataArray()
   return self.m_playerRankingData.rankingDataArray;
end

--详情/规则
function RankingSystem:getRankingRule()
   return self.m_playerRankingData.ruC;
end

--排名汇总数据
function RankingSystem:getRankingSimpleRankNode()
   return self.m_playerRankingData.simpleRankNode;
end

--##  raR  int   是否可领排行榜奖励(0:不可以领 1:可以领)
--##  roRB  int   是否显示主界面房主排行按钮(0:不显示 1:显示 -1:不修改状态)
function RankingSystem:setRankingMainUIData(tmpData)
   self.m_rankMainUIData = tmpData
end

function RankingSystem:getRankingMainUIData()
   return self.m_rankMainUIData
end
--
kRankingSystem = RankingSystem.getInstance();