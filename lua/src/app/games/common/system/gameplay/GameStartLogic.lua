-------------------------------------------------------------
--  @file   GameStartLogic.lua
--  @brief  开始游戏逻辑
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 19:59:17
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Component = cc.Component
local GameStartLogic = class("GameStartLogic", Component)

local EntityFactory =  require("app.games.common.entity.EntityFactory")
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function GameStartLogic:ctor()
	GameStartLogic.super.ctor(self, "GameStartLogic")
	
end
--[
-- @brief  绑定
-- @param  void
-- @return void
--]
function GameStartLogic:onBind_()
	self.players = {}
	self.handMjs = {}
    self.m_huMjs = {} --查胡麻将
	self.gameStartDatas = {}
	self._isGameStarted = false
	self._isMjDistrubuteEnd = false
end

--[
-- @brief  解绑
-- @param  void
-- @return void
--]
function GameStartLogic:onUnbind_()
	self.players = {}
	self.handMjs = {}
    self.m_huMjs = {} 
	self.gameStartDatas ={}
	self._isGameStarted = false
	self._isMjDistrubuteEnd = false
end

--[[
-- @brief  重设数据函数
-- @param  void
-- @return void
--]]
function GameStartLogic:setGameStartAllDatas(cmd, context)
	self:gameStartReleasePlayer()
	self:gameStartReleaseHandMj()
	self.players = {}
	self.handMjs = {}
	-- self._isGameStarted = true

	-- 设置剩余局数
	-- local remain = SystemFacade:getInstance():getRemainGameCount() - 1
	-- SystemFacade:getInstance():setRemainGameCount(remain)
	local selfRemoteSite = 1
	-- 确定自己的位置
	for i=1,context.plN do
		if self.target_.myUserId == context.usII[i].usID then
			selfRemoteSite = i
			break
		end
	end
	-- 初始化玩家数据
	for i=1, context.plN do

		-- dump(context.usII[i])
		-- 确定先出牌的玩家，也称庄家
		if context.baUID == context.usII[i].usID then
			context.usII[i].banker = true
		else
			context.usII[i].banker = false
		end
		-- 创建玩家实体对象
		local site = (i - selfRemoteSite + context.plN)%context.plN +1
		context.usII[i].site = site
		local player = EntityFactory.createPlayerEntity(_gameType,context.usII[i])--MjMediator:getInstance():getEntityModule():createEntity(enEntityType.PLAYER, context.usII[i])
		self.players[site] = player
	end

	-- 确定东风的位置
	local eastWind = 1
	for i=1,#self.players do
		self.players[i]:getProp(enCreatureEntityProp.USERID)
		if self.players[i]:getProp(enCreatureEntityProp.USERID) == context.baUID then
			eastWind = i
			break
		end
	end
	-- 设置门风
	for i=1,#self.players do
		-- 创建玩家实体对象
		-- local door = (i - eastWind + (#self.players))%(#self.players) +1
		-- self.players[i]:setProp(enCreatureEntityProp.DOOR_WIND, door)
        --self.players[i]:setProp(enCreatureEntityProp.DOOR_WIND, context.usII[i].doW)
	end
	-- 初始化游戏数据
	self:setGameStartDatas(cmd, context)
	-- 设置开局标志
	MjProxy:getInstance():setStartGame(true)

    if not IsPortrait then -- TODO
        -- 牌局开始时获取一次定位
        NativeCall.getInstance():callNative({cmd = NativeCall.CMD_LOCATION}, function(info)
            local tmpData = {}
            tmpData.jiD = info.longitude
            tmpData.weD = info.latitude
            SocketManager.getInstance():send(CODE_TYPE_HALL, HallSocketCmd.CODE_SEND_LOCATION, tmpData);
        end)
    end
end
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function GameStartLogic:setGameStartDatas(cmd, context)
	-- dump(context)
	self.gameStartDatas = {}
	self.gameStartDatas.actions = {}
	self.gameStartDatas.addGangCards = context.adGC or {} -- 加杠
	self.gameStartDatas.anGangCards = context.anGC or {}  -- 暗杠
	self.gameStartDatas.bankerUID 	= context.baUID or 0  -- 庄家id 
	self.gameStartDatas.base 		= context.ba or 0     -- 底注
	self.gameStartDatas.closeCards 	= context.clC or {}   -- 盖起来的手牌
	self.gameStartDatas.flowerCard 	= context.flCM or{}   -- 花牌
	self.gameStartDatas.firstplay 	= context.neUID or 0  -- 第一个出牌的玩家
	self.gameStartDatas.gamePlayID 	= context.plID or 0   -- 游戏id
	self.gameStartDatas.totalFan 	= context.toF or 0    -- 总番数
	self.gameStartDatas.tingCards 	= context.tiC or {}   -- 听牌
	self.gameStartDatas.tingAftCards = context.tiHC or {} -- 听牌之后可胡的牌组
	self.gameStartDatas.rRemainCount = context.reC or 0   -- 剩余牌数
	if context.notAcID and #context.notAcID > 0 then
		self.gameStartDatas.isChooseGuo = true  
	else
		self.gameStartDatas.isChooseGuo = false
	end

	self.gameStartDatas.xiaPaoList 	= context.xi or {}    -- 下跑列表
	self.gameStartDatas.xiaDiList   = context.jiDL or {}    -- 下底列表
	self.gameStartDatas.xiaZuoList 	= context.zuL or {}   -- 下坐列表
	if cmd == enMjMsgReadId.MSG_READ_GAME_RESUME then
		self.gameStartDatas.xiaLaList 	= context.laZL or {}   -- 下拉列表
	elseif cmd == enMjMsgReadId.MSG_READ_GAME_START then
		self.gameStartDatas.xiaLaList 	= context.laZ or {}   -- 下拉列表
	end

	self.gameStartDatas.dice 		= context.di or {}    -- 骰子值 
 	
 	self.gameStartDatas.fanzi 		= context.fa or -1    -- 番子值 
 	self.gameStartDatas.isFlowers 	= context.fl or context.flCA or {}    -- 是否是花牌 (开局是fl, 恢复对局是flCA, 明天找黄泳霖问问能不能改)
    self.gameStartDatas.handFlowers = context.mufs or {}  -- 手动补花列表(这些花牌将由玩家决定是否打出)
 	self.gameStartDatas.wanFa 		= context.wa or {}    -- 玩法
    self.gameStartDatas.isTing      = context.isT or false;    --是否可以听牌
    self.gameStartDatas.neOAG      = context.neOAG or false;    --暗杠是否要显示
    self.gameStartDatas.diQ      = context.diQ or false;    --是否有定缺
    self.gameStartDatas.chiCards 	= context.chC or {} -- 吃牌组
    self.gameStartDatas.yangmaCards  = context.yangMC or {}  -- 养马
    self.gameStartDatas.actionCard = context.laPC or 0 --- 牌局的最后一张图
    self.gameStartDatas.bet = context.jiDL or {} --下注
    self.gameStartDatas.GangHuaCards = context.fanPiGus or {}    --  杠花
    self.gameStartDatas.ChosedGang = context.gangChoses or {}    --  杠牌列表

    self.gameStartDatas.isHuHintNeedTing = context.huHNT or false -- 是否必须在听牌后才显示胡牌提示
	self.gameStartDatas.isGuoQueRen      = context.gisps or false;    --胡牌过是否要二次确认
    self.gameStartDatas.isHaveNextAct      = context.haA or false;    --是否后续有操作(胡, 杠, 听等)
    self.m_huMjs     = context.huC or {};  -- 查胡的牌
	self.gameStartDatas.showTingBtn =  context.showTingBtn; --是否显示天听和听按钮
 	-- 设置剩余局数
 	SystemFacade:getInstance():setRemainPaiCount(self.gameStartDatas.rRemainCount)
	self:setGuoQueRenUIShowOnce(false);
 	-- 恢复对局和开局癞子的key有区别
 	-- if context.la1 then
 	-- 	self.gameStartDatas.laizi 		= context.la1 or 1    -- 癞子
 	-- else
 	-- 	self.gameStartDatas.laizi 		= context.la or 1    -- 癞子
 	-- end

 	self.gameStartDatas.laizi 		= context.waNP or {}  -- 癞子
 	self.gameStartDatas.playerNum 	= context.plN or 4    -- 玩家数量
 	self.gameStartDatas.doorCard 	= context.DoC or 0    -- 门牌
	self.gameStartDatas.ciW = context.ciW or 1 --风圈
 	-- 
	
	self:setAttachDatas(context);
	
 	-- self.gameStartDatas.userStatus  = context.usS or 0    -- 玩家状态
 	-- 处理操作数据
 	local index = 0
 	if context.ac then
		for i=1,#context.ac do
			if context.ac[i] ~= enOperate.OPERATE_XIA_PAO --下跑, 下底，拉庄，坐庄等不在action里面处理
				and context.ac[i] ~= enOperate.OPERATE_LAZHUANG
	            and context.ac[i] ~= enOperate.OPERATE_ZUO
	            and context.ac[i] ~= enOperate.OPERATE_XIADI
				and context.ac[i] ~= enOperate.OPERATE_BU_HUA 
                and context.ac[i] ~= enOperate.OPERATE_CHUPAI then 
					index = index + 1
					self.gameStartDatas.actions[index] = context.ac[i]
			end
		end
	end
	-- 创建实体
	-- for i=1,#self.gameStartDatas.closeCards do
	-- 	self:addHandMj(self.gameStartDatas.closeCards[i], 1)
	-- end
	-- 重设操作牌
	local operateSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM)
	-- 重设动作数据
	local actionDatas = {
		doorCard   		= self.gameStartDatas.doorCard,
		flowerCards 	= self.gameStartDatas.flowerCard,
		actions   		= self.gameStartDatas.actions,
		addGangCards 	= self.gameStartDatas.addGangCards,
		anGangCards  	= self.gameStartDatas.anGangCards,
		tingCards       = self.gameStartDatas.tingCards,
		tingAftCards    = self.gameStartDatas.tingAftCards,
		chiCards 		= self.gameStartDatas.chiCards,
		yangmaCards     = self.gameStartDatas.yangmaCards,
		GangHuaCards    = self.gameStartDatas.GangHuaCards,
        ChosedGang      = self.gameStartDatas.ChosedGang,
        isChooseGuo 	= self.gameStartDatas.isChooseGuo,
	}
	operateSystem:resetActionDatas(actionDatas)

	if self:hasLaPaoZuoDi() and self:checkGameStart() and cmd == enMjMsgReadId.MSG_READ_GAME_RESUME then
		self._isGameStarted = true
		self._isMjDistrubuteEnd = true
	end
end

function GameStartLogic:getActionCard()
	return self.gameStartDatas.actionCard
end

--设置不同麻将附加数据，可以给子类重写该方法
function GameStartLogic:setAttachDatas(context)
   Log.i("overwrite GameStartLogic:setAttachDatas");
end

--[[
-- @brief  添加麻将实体
-- @param  void
-- @return void
--]]
function GameStartLogic:addHandMj(value, number)
    number = number or 1
    -- 已经存在，修改数量
    if self.handMjs[value] then
        local oldNumber = self.handMjs[value]:getProp(enGoodsProp.NUMBER)
        local newNumber = oldNumber + number
        self.handMjs[value]:setProp(enGoodsProp.NUMBER, newNumber)
    else
        -- 不存在，新建
        local context = {
            ["value"] 		= value,
            ["number"]     	= number,
        }
        local handMj = MjMediator:getInstance():getEntityModule():createEntity(enEntityType.HAND_MJ, context)
        self.handMjs[value] = handMj
    end
end

--[
-- @brief  移除手牌
-- @param
-- @return void
--]
function GameStartLogic:removeHandMj(value, number)
    local handMj = self.handMjs[value]
    if nil == handMj then
    	printError("GameStartLogic:removeHandMj 无效的麻将值 = %d", value)
    end
    -- 如果数量小于要删除的数量，则删除
    if handMj:getProp(enGoodsProp.NUMBER) <= number then
    	self.handMjs[value]:release()
       	self.handMjs[value] = nil
        return
    end
    -- 否则，数量减1
    local oldNumber = self.handMjs[value]:getProp(enGoodsProp.NUMBER)
    local newNumber = oldNumber - number
    self.handMjs[value]:setProp(enGoodsProp.NUMBER, newNumber)
end

--[[
-- @brief  通过座次玩家实体
-- @param  void
-- @return void
--]]
function GameStartLogic:gameStartGetPlayerBySite(site)
	return self.players[site]
end

--[[
-- @brief  释放玩家实体
-- @param  void
-- @return void
--]]
function GameStartLogic:gameStartReleasePlayer()
	for k, v in pairs(self.players) do
		v:release()
	end
end

--[[
-- @brief  获取麻将
-- @param  void
-- @return void
--]]
function GameStartLogic:gameStartGetHandMjs()
	return self.handMjs
end

--[[
-- @brief  释放麻将实体
-- @param  void
-- @return void
--]]
function GameStartLogic:gameStartReleaseHandMj()
	for k, v in pairs(self.handMjs) do
		v:release()
	end
end

--[[
-- @brief  通过用户id玩家实体
-- @param  void
-- @return void
--]]
function GameStartLogic:gameStartGetPlayerByUserid(userid)
	for i=1, #self.players do
		if userid == self.players[i]:getProp(enCreatureEntityProp.USERID) then
			return self.players[i]
		end
	end
	return nil
end

--[[
-- @brief  通过用户id获取玩家index
-- @param  void
-- @return void
--]]
function GameStartLogic:getPlayerSiteById(userid)
	for i=1, #self.players do
		if userid == self.players[i]:getProp(enCreatureEntityProp.USERID) then
			return i
		end
	end
	return 1
end

--[[
-- @brief  获取所有玩家
-- @param  void
-- @return void
--]]
function GameStartLogic:gameStartGetPlayers()
	return self.players
end

--[[
-- @brief  获取开始游戏数据
-- @param  void
-- @return void
--]]
function GameStartLogic:getGameStartDatas()
	return self.gameStartDatas
end

--[[
-- @brief  重设财富值
-- @param  void
-- @return void
--]]
function GameStartLogic:resetFortune(table)
	if table and table.usI then
		local site = self:getPlayerSiteById(table.usI)
		self.players[site]:setProp(enCreatureEntityProp.FORTUNE, tonumber(table.ca))
	end
end

--[[
-- @brief  获取庄家座次数据
-- @param  void
-- @return void
--]]
function GameStartLogic:gameStartGetBankerSite()
	for i=1,#self.players do
		if self.players[i]:getProp(enCreatureEntityProp.BANKER) then
			return i
		end
	end
	return 1
end

--[[
-- @brief 获取庄家ID
--]]
function GameStartLogic:getBankerID()
	return self.gameStartDatas.bankerUID
end

--[[
-- @brief 是否支持听牌
--]]
function GameStartLogic:getIsHasTing()
    if self.gameStartDatas.isTing then
        return true;
    else
        return false;
    end
end

--[[
-- @brief 暗杠是否要显示一张出来
--]]
function GameStartLogic:getIsAnGangShow()
    if self.gameStartDatas.neOAG then
        return true;
    else
        return false;
    end
end

--[[
-- @brief 是否要定缺
--]]
function GameStartLogic:getIsHasDingQue()
    if self.gameStartDatas.diQ then
        return true;
    else
        return false;
    end
end

--[[
-- @brief 是否只能在听牌后显示胡牌提示
--]]
function GameStartLogic:getIsHuHintNeedTing()
    if self.gameStartDatas.isHuHintNeedTing then
        return true;
    else
        return false;
    end
end

--[[
-- @brief  获取查胡麻将
-- @param  void
-- @return void
--]]
function GameStartLogic:gameStartLogic_getHuMjs()
    return self.m_huMjs or {};
end

--[[
-- @brief 点击过按钮是否要进行二次确认（胡牌过是否要二次确认框）
--]]
function GameStartLogic:getIsHasGuoQueRen()
    if self.gameStartDatas.isGuoQueRen then
        return true;
    else
        return false;
    end
end

--[[
-- @brief 设置点击过按钮出现二次确认框,仅能出现一次
--]]
function GameStartLogic:setGuoQueRenUIShowOnce(isOnlyOnce)
   self.m_GuoQueRenUIShowOnlyOnce = isOnlyOnce
end
--[[
-- @brief 获取点击过按钮出现二次确认框,仅能出现一次
--]]
function GameStartLogic:getGuoQueRenUIShowOnce()
   return self.m_GuoQueRenUIShowOnlyOnce; --默认仅显示一次
end

--[[
-- @brief  获取开始游戏数据
-- @param  void
-- @return void
--]]
function GameStartLogic:gameStartLogic_setHuMjs(huMjs)
    self.m_huMjs = huMjs;
end

--[[
	-- @brief 判断是否有拉跑坐功能
	-- @param type 类型
	-- @return true 有， false 没有
]]
function GameStartLogic:checkLaPaoZuoDi(type)
	if type == enOperate.OPERATE_XIA_PAO then
        return self.gameStartDatas.xiaPaoList and #self.gameStartDatas.xiaPaoList > 0
    elseif type == enOperate.OPERATE_LAZHUANG then
        return self.gameStartDatas.xiaLaList and #self.gameStartDatas.xiaLaList > 0
    elseif type == enOperate.OPERATE_ZUO then
        return self.gameStartDatas.xiaZuoList and #self.gameStartDatas.xiaZuoList > 0
    elseif type == enOperate.OPERATE_XIADI then
        return self.gameStartDatas.xiaDiList and #self.gameStartDatas.xiaDiList > 0
    end
    return false
end

--[[
	-- @brief 没有任何拉跑坐底的任何一项操作
	-- @param void
	-- return true 有， false 没有
]]
function GameStartLogic:hasLaPaoZuoDi()
	return (self:checkLaPaoZuoDi(enOperate.OPERATE_XIADI) 
		or self:checkLaPaoZuoDi(enOperate.OPERATE_XIA_PAO)
		or self:checkLaPaoZuoDi(enOperate.OPERATE_LAZHUANG)
		or self:checkLaPaoZuoDi(enOperate.OPERATE_ZUO))
end

--[[
	-- @brief 判断所有的玩家是否已经完成拉跑坐底操作
	-- @param void
	-- @return true 已经全部选择相应操作， false 没选完拉跑坐底操作
]]
function GameStartLogic:checkGameStart()
	local isTrue = true
	-- 判断所有玩家是否已经选择了底操作
	if self:checkLaPaoZuoDi(enOperate.OPERATE_XIADI) then
		for _, v in ipairs(self.players) do
			isTrue = isTrue and v:getProp(enCreatureEntityProp.XIA_DI_NUM) >= 0
			if not isTrue then
				return isTrue
			end
		end
	end

	-- 判断所有玩家是否已经选择了跑操作
	if self:checkLaPaoZuoDi(enOperate.OPERATE_XIA_PAO) then
		for _, v in ipairs(self.players) do
			isTrue = isTrue and v:getProp(enCreatureEntityProp.XIA_PAO_NUM) >= 0
			if not isTrue then
				return isTrue
			end
		end
	end

	-- 判断所有闲家是否已经选择了拉操作
	if self:checkLaPaoZuoDi(enOperate.OPERATE_LAZHUANG) then
		for _, v in ipairs(self.players) do
			if not v:getProp(enCreatureEntityProp.BANKER) then
				isTrue = isTrue and v:getProp(enCreatureEntityProp.XIA_LA_NUM) >= 0
				if not isTrue then
					return isTrue
				end
			end
		end
	end

	-- 判断所有庄家是否已经选择了坐操作
	if self:checkLaPaoZuoDi(enOperate.OPERATE_ZUO) then
		for _, v in ipairs(self.players) do
			if v:getProp(enCreatureEntityProp.BANKER) then
				isTrue = isTrue and v:getProp(enCreatureEntityProp.XIA_ZUO_NUM) >= 0
				if not isTrue then
					return isTrue
				end
			end
		end
	end

	return isTrue
end

function GameStartLogic:isGameStarted()
	return self._isGameStarted
end

function GameStartLogic:setGameStarted(isStarted)
	self._isGameStarted = isStarted
end

function GameStartLogic:isMjDistrubuteEnd()
	return self._isMjDistrubuteEnd
end

function GameStartLogic:setMjDistrubuteEnd(isEnd)
	self._isMjDistrubuteEnd = isEnd
end

function GameStartLogic:buildLpzResumeMsg(lpzNum, actionID, userID)
    local actionMsg = {}
    actionMsg.acID = actionID
    actionMsg.usID = userID
    actionMsg.acC0 = lpzNum
    actionMsg.haA = false
     -- {"opS":0,"plID":"private_rooms_622632-170","usID":4281150847,"acC0":1,"acID":39,"acR":1,"ca":0,"ro":false,"isN":false,"laPUID":0,"cl":0,"se":0,"ch":[],"isLG":false,"haA":false,"snId":24606,"recUserId":4244983560}
     Log.i("actionMsg", actionMsg)
    return {cmd = enMjMsgReadId.MSG_READ_MJ_ACTION, msg = actionMsg}
end
--[[
(info.acID == enOperate.OPERATE_XIA_PAO 
            or info.acID == enOperate.OPERATE_LAZHUANG 
            or info.acID == enOperate.OPERATE_ZUO 
            or info.acID == enOperate.OPERATE_XIADI)
            ]]
function GameStartLogic:getLpzResumeMsgs(context)
    local msgs = {}
    -- 初始化玩家数据
    for i = 1, #context.usII do
        local data = context.usII[i]
        Log.i(string.format("context.usII[%d]", i), data)
        local userID = data.usID
        local player = self:gameStartGetPlayerByUserid(userID)
        if not player then break end
        if data.xiN and data.xiN ~= player:getProp(enCreatureEntityProp.XIA_PAO_NUM) and data.xiN >=0 and player:getProp(enCreatureEntityProp.XIA_PAO_NUM) >= 0 then
            table.insert(msgs, self:buildLpzResumeMsg(data.xiN, enOperate.OPERATE_XIA_PAO, userID))
        end
        if data.laZN and data.laZN ~= player:getProp(enCreatureEntityProp.XIA_LA_NUM) and data.laZN >= 0 and player:getProp(enCreatureEntityProp.XIA_LA_NUM) >= 0 then
            table.insert(msgs, self:buildLpzResumeMsg(data.laZN, enOperate.OPERATE_LAZHUANG, userID))
        end
        if data.zuN and data.zuN ~= player:getProp(enCreatureEntityProp.XIA_ZUO_NUM) and data.zuN >= 0 and player:getProp(enCreatureEntityProp.XIA_ZUO_NUM) >= 0 then
            table.insert(msgs, self:buildLpzResumeMsg(data.zuN, enOperate.OPERATE_ZUO, userID))
        end
        if data.ji and data.ji ~= player:getProp(enCreatureEntityProp.XIA_DI_NUM) and data.ji >= 0 and player:getProp(enCreatureEntityProp.XIA_DI_NUM) >= 0 then
            table.insert(msgs, self:buildLpzResumeMsg(data.ji, enOperate.OPERATE_XIADI, userID))
        end

            -- self:setProp(enCreatureEntityProp.XIA_PAO_NUM,    context.xiN or -1)    ----    下跑数：xiN
            -- self:setProp(enCreatureEntityProp.XIA_LA_NUM,    (context.laZN and not context.banker) and context.laZN or -1)  ---- 下拉数：laZN, 只有闲家才能有拉
            -- self:setProp(enCreatureEntityProp.XIA_ZUO_NUM,   (context.zuN and context.banker) and context.zuN or -1)    --   坐数：zuN, 只有庄家才能有坐
            -- self:setProp(enCreatureEntityProp.XIA_DI_NUM,    context.ji or -1)      -- 下底数：xdN
        -- self.players[site] = player
    end
    return msgs
end

--[[
-- @brief  导出函数
-- @param  void
-- @return void
--]]
function GameStartLogic:exportMethods()
	self:exportMethods_({
        "setGameStartAllDatas",
        "gameStartGetPlayerByUserid",
        "getGameStartDatas",
        "gameStartGetPlayerBySite",
        "gameStartGetPlayers",
        "gameStartGetBankerSite",
        "getPlayerSiteById",
        "resetFortune",
        "gameStartGetHandMjs",
        "gameStartReleasePlayer",
        "gameStartReleaseHandMj",
        "addHandMj",
        "removeHandMj",
        "getActionCard",
        "isGameStarted",
        "setGameStarted",
        "isMjDistrubuteEnd",
        "setMjDistrubuteEnd",
        "checkLaPaoZuoDi",
        "checkGameStart",
        "hasLaPaoZuoDi",
		"getBankerID",
        "getIsHasTing",
        "getIsAnGangShow",
        "getIsHasDingQue",
        "getIsHuHintNeedTing",
        "gameStartLogic_getHuMjs",
        "gameStartLogic_setHuMjs",
		"getIsHasGuoQueRen",
		"setGuoQueRenUIShowOnce",
		"getGuoQueRenUIShowOnce",
        "getLpzResumeMsgs",
    })
    return self.target_
end

return GameStartLogic
