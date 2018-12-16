--排行榜网络
RankingSocketProcesser = class("RankingSocketProcesser", SocketProcesser)

--type = 5,code=51005, 获取排行入口界面数据  Client->Server
function RankingSocketProcesser.sendRoomGetRoomInfo()
   SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RANKING_GETRANKINGDATA,{});
end


--[[
   type = 5,code=51007,设置玩家地址 Client<->Server
   -------------------------------
	
 	  	##  na  String  姓名
 	  	##  ph  String  phone
 	  	##  ad  String  address
 	  	##  re  int  结果(0:操作成功 )
  
]]
function RankingSocketProcesser.sendAddressInfoData(tmpData)
   SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_RANKING_SET_PALYERDATA,tmpData);
end

function RankingSocketProcesser:recvAddressInfoData(cmd, packetInfo)
	packetInfo = checktable(packetInfo)
	Log.i("接收到服务器玩家地址数据",packetInfo)
	self.m_delegate:handleSocketCmd(cmd,packetInfo)
end

--[[
 type = 5,code=51008, 获取排行界面数据  Client->Server
 	  	##  pa  int  页数
 	  	##  buI  int  缓存阶段id（0：表示获取首页内容，返回51009接口；否则设置为打开后的阶段id，返回51010接口，如果对应缓存阶段过期，会返回51009接口进行首页刷新）
 ]]
function RankingSocketProcesser.sendAllRankingData(tmpData)
   SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RANKING_ALLDATA,tmpData);
end
 
--[[
 ==========================================================================
type = 5,code=51009, 获取排行界面数据  Server->Client
 
		SimpleRankNode		
	  	##    ra  int  排行节点
	  	##    roN  int  房间数	
	-------------------------------
 	  	##  noL:[SimpleRankNode]  noL  List<SimpleRankNode>  
 	  	##   toN  int  总个数
 	  	##   myR  int  我的排名
 	  	##   myRN  int  我的开房次数
 	  	##   upT  String  排行更新时间
 	  	##   buI  int  缓存阶段id
  
 ]]
function RankingSocketProcesser:recvPageRankingData(cmd, packetInfo)
	packetInfo = checktable(packetInfo)
	Log.i("接收到服务器排行界面个人数据",packetInfo)
	kRankingSystem:setRankingPageData(packetInfo)
	self.m_delegate:handleSocketCmd(cmd,packetInfo)
end


--[[
 type = 5,code=51010, 获取排行界面数据  Server->Client
 
		SimpleRankItem		
	  	##    ra  int  名次
	  	##    ic  String  头像
	  	##    na  String  昵称
	  	##    usI  int  ID
	  	##    roN  int  开房次数
	  	##    reI  int  奖品index
	-------------------------------
 	  	##   pa  int  当前页
 	  	##  raL:[SimpleRankItem]  raL  List<SimpleRankItem>  
 ]]
function RankingSocketProcesser:recvRankingNextPageData(cmd, packetInfo)
	packetInfo = checktable(packetInfo)
	--Log.i("接收到服务器排行界面下一个页面数据",packetInfo)
	kRankingSystem:changRankingPageData(packetInfo);
	self.m_delegate:handleSocketCmd(cmd,packetInfo)
end

--[[
 type = 5,code=51011,领奖 Client<->Server
 	##  re  int  结果(0:操作成功 1:未上榜 2:无奖励 3:实物奖励)
]]
function RankingSocketProcesser.sendRankingAwardResult()
 SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_RECV_RANKING_GETAWARDRESULT,{});
end

function RankingSocketProcesser:recvRankingAwardResult(cmd, packetInfo)
	packetInfo = checktable(packetInfo)
	Log.i("接收到服务器领取奖励结果",packetInfo)
	self.m_delegate:handleSocketCmd(cmd,packetInfo)
end

RankingSocketProcesser.s_severCmdEventFuncMap = {
[HallSocketCmd.CODE_RECV_RANKING_GETRANKINGDATA ] = RankingSocketProcesser.recvRankingData, --type = 5,code=51006, 返回排行入口界面数据  Server->Clien
[HallSocketCmd.CODE_RANKING_SET_PALYERDATA ] =RankingSocketProcesser.recvAddressInfoData, --type = 5,code=51007,设置玩家地址 Client<->Server
[HallSocketCmd.CODE_RECV_RANKING_ALLDATA ] = RankingSocketProcesser.recvPageRankingData, --type = 5,code=51009, 获取排行界面数据  Server->Client
[HallSocketCmd.CODE_RECV_RANKING_ALLDATA_Next ] = RankingSocketProcesser.recvRankingNextPageData, --type = 5,code=51010, 获取排行界下一页面数据  Server->Client
[HallSocketCmd.CODE_RECV_RANKING_GETAWARDRESULT] = RankingSocketProcesser.recvRankingAwardResult,
};
