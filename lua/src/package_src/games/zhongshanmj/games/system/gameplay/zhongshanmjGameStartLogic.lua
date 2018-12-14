--
-- Author: Your Name
-- Date: 2017-05-25 16:50:04
--

local GameStartLogic = import("app.games.common.system.gameplay.GameStartLogic")
local zhongshanmjGameStartLogic = class("zhongshanmjGameStartLogic", GameStartLogic)


-- local EntityFactory =  require("app.games.common.entity.EntityFactory")
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
-- function zhongshanmjGameStartLogic:ctor()
-- 	zhongshanmjGameStartLogic.super.ctor(self, "zhongshanmjGameStartLogic")
	
-- end


-- function zhongshanmjGameStartLogic:setGameStartDatas(cmd, context)
	-- local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
	-- local itemList= json.decode(palyingInfo.wa)
	-- if itemList.paishu==108 then
	-- 	GC_TurnLaiziPath = "package_res/games/zhongshanmj/game/fanpai.png"
	-- else
	-- 	context.fa=itemList.gui
	-- 	GC_TurnLaiziPath = "package_res/games/zhongshanmj/game/guipai.png"
	-- end
	-- zhongshanmjGameStartLogic.super.setGameStartDatas(self,cmd, context)

-- 	-- dump(context)
-- 	self.gameStartDatas = {}
-- 	self.gameStartDatas.actions = {}
-- 	self.gameStartDatas.addGangCards = context.adGC or {} -- 加杠
-- 	self.gameStartDatas.anGangCards = context.anGC or {}  -- 暗杠
-- 	self.gameStartDatas.bankerUID 	= context.baUID or 0  -- 庄家id 
-- 	self.gameStartDatas.base 		= context.ba or 0     -- 底注
-- 	self.gameStartDatas.closeCards 	= context.clC or {}   -- 盖起来的手牌
-- 	self.gameStartDatas.flowerCard 	= context.flCM or{}   -- 花牌
-- 	self.gameStartDatas.firstplay 	= context.neUID or 0  -- 第一个出牌的玩家
-- 	self.gameStartDatas.gamePlayID 	= context.plID or 0   -- 游戏id
-- 	self.gameStartDatas.totalFan 	= context.toF or 0    -- 总番数
-- 	self.gameStartDatas.tingCards 	= context.tiC or {}   -- 听牌
-- 	self.gameStartDatas.tingAftCards = context.tiHC or {} -- 听牌之后可胡的牌组
-- 	self.gameStartDatas.rRemainCount = context.reC or 0   -- 剩余牌数
-- 	self.gameStartDatas.xiaPaoList 	= context.xi or {}    -- 下跑列表
--  	self.gameStartDatas.dice 		= context.di or {}    -- 骰子值 
--  	self.gameStartDatas.fanzi 		= context.fa or -1    -- 番子值 
--  	self.gameStartDatas.isFlowers 	= context.fl or context.flCA or {}    -- 是否是花牌 (开局是fl, 恢复对局是flCA, 明天找黄泳霖问问能不能改)
--  	self.gameStartDatas.wanFa 		= context.wa or {}    -- 玩法
--     self.gameStartDatas.isTing      = context.isT or false;    --是否有听牌
--     self.gameStartDatas.neOAG      = context.neOAG or false;    --暗杠是否要显示
--     self.gameStartDatas.diQ      = context.diQ or false;    --是否有定缺

--     self.gameStartDatas.isHuHintNeedTing = context.huHNT or false -- 是否必须在听牌后才显示胡牌提示
-- 	self.gameStartDatas.isGuoQueRen      = context.gisps or false;    --胡牌过是否要二次确认
--     self.gameStartDatas.isHaveNextAct      = context.haA or false;    --是否后续有操作(胡, 杠, 听等)
--     self.m_huMjs     = context.huC or {};  -- 查胡的牌

-- 	self.gameStartDatas.wfKou = context.kjisKoudan or false
--  	-- 设置剩余局数
--  	SystemFacade:getInstance():setRemainPaiCount(self.gameStartDatas.rRemainCount)
-- 	self:setGuoQueRenUIShowOnce(false);
--  	-- 恢复对局和开局癞子的key有区别
--  	-- if context.la1 then
--  	-- 	self.gameStartDatas.laizi 		= context.la1 or 1    -- 癞子
--  	-- else
--  	-- 	self.gameStartDatas.laizi 		= context.la or 1    -- 癞子
--  	-- end

--  	self.gameStartDatas.laizi 		= context.waNP or {}  -- 癞子
--  	self.gameStartDatas.playerNum 	= context.plN or 4    -- 玩家数量
--  	self.gameStartDatas.doorCard 	= context.DoC or 0    -- 门牌
-- 	self.gameStartDatas.ciW = context.ciW or 1 --风圈
--  	-- 
	
-- 	self:setAttachDatas(context);
	
--  	-- self.gameStartDatas.userStatus  = context.usS or 0    -- 玩家状态
--  	-- 处理操作数据
--  	local index = 0
--  	if context.ac then
-- 		for i=1,#context.ac do
-- 			if context.ac[i] ~= enOperate.OPERATE_XIA_PAO 
-- 				and context.ac[i] ~= enOperate.OPERATE_BU_HUA 
--                 and context.ac[i] ~= enOperate.OPERATE_CHUPAI then --下跑不在action里面处理
-- 				index = index + 1
-- 				self.gameStartDatas.actions[index] = context.ac[i]
-- 			end
-- 		end
-- 	end
-- 	-- 创建实体
-- 	-- for i=1,#self.gameStartDatas.closeCards do
-- 	-- 	self:addHandMj(self.gameStartDatas.closeCards[i], 1)
-- 	-- end
-- 	-- 重设操作牌
-- 	local operateSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM)
-- 	-- 重设动作数据
-- 	local actionDatas = {
-- 		doorCard   		= self.gameStartDatas.doorCard,
-- 		flowerCards 	= self.gameStartDatas.flowerCard,
-- 		actions   		= self.gameStartDatas.actions,
-- 		addGangCards 	= self.gameStartDatas.addGangCards,
-- 		anGangCards  	= self.gameStartDatas.anGangCards,
-- 		tingCards       = self.gameStartDatas.tingCards,
-- 		tingAftCards    = self.gameStartDatas.tingAftCards,

-- 	}
-- 	operateSystem:resetActionDatas(actionDatas)
-- end

return zhongshanmjGameStartLogic