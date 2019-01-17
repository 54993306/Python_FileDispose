-------------------------------------------------------------
--  @file   PDKGameRule.lua
--  @brief  跑得快游戏规则类
--  @author 徐志军
--  @DateTime:2018-07-02
--  Version: 1.0.0
--  Note: 跑得快牌型检测，牌型提示
--  Copyright  Copyright (c) 2018
--============================================================

local CardSet = require('package_src.games.paodekuai.pdkpoker.CardSet')

local PDKGameRule = class("PDKGameRule", require("package_src.games.paodekuai.pdkpoker.GameRule"))
require("package_src.games.paodekuai.pdkfuckFaster.PDKCardsdef")

function PDKGameRule:ctor()

	PDKGameRule.super.ctor(self)

	--不同牌型间的大小关系数组（数组一维存储目标牌型，二维存储比目标牌型大的牌型）
	self.ms_arrMapCompare = {} 


	self:Initialize()
end
--函数功能：	是否需要先出黑桃三
--返回值：		Boolean
function PDKGameRule:GetIsSpades()
	return DDZGUIZE.isSpades3
end
--函数功能：	设置是否需要先出黑桃三
--isSpades:		目标值
--返回值：		无
function PDKGameRule:SetIsSpades(isSpades)
	DDZGUIZE.isSpades3 = isSpades
end

--函数功能：	设置是否是赢家先手
--xianshou：	目标值
--返回值：		无
function PDKGameRule:SetYinJiaXianShou(xianshou)
	DDZGUIZE.yinjiaxianshou = xianshou
end
--函数功能：	获取赢家先手
--返回值：		boolan
function PDKGameRule:GetYinJiaXianShou()
	return DDZGUIZE.yinjiaxianshou
end

--函数功能：	选择规则三带几
--kinds:	   带几张
--返回值：		无
function PDKGameRule:SetRule3Kinds(kinds)
	DDZGUIZE.stRule3kinds = kinds
end
--函数功能：	获取规则三带几
--返回值：		带的张数
function PDKGameRule:GetRule3Kinds()
	return DDZGUIZE.stRule3kinds
end

--函数功能：	设置三张是否可少带
--isWhole：		Boolean（是否可少带）
--返回值:		无
function PDKGameRule:SetIsWhole(isWhole)
	DDZGUIZE.isWhole = isWhole
end
--函数功能：	获取三张是否可少带
--返回值：		Boolean
function PDKGameRule:GetIsWhole()
	return DDZGUIZE.isWhole
end

--函数功能：	设置三顺是否可少带
--iskindsWhole:boolean(是否可少带)
--返回值:		无
function PDKGameRule:SetIsKindsWhole(isWhole)
	DDZGUIZE.iskindsWhole = isWhole
end
--函数功能：	获取三顺是否可少带
--返回值：		Boolean
function PDKGameRule:GetIsKindsWhole()
	return DDZGUIZE.iskindsWhole
end

--函数功能：	设置玩家手牌数量
--number:		数量
--返回值：		无
function PDKGameRule:SetSelfCardsNumber(number)
	DDZGUIZE.selfCardsNumber = number
end
--函数功能：		获取玩家手牌数量
--返回值：			手牌数量
function PDKGameRule:GetSelfCardsNumber()
	return DDZGUIZE.selfCardsNumber
end

--函数功能：	设置三个A是否算炸弹
--kinds:		是否算炸弹
--返回值：		无
function PDKGameRule:SetAKindsAndBomb(bomb)
	DDZGUIZE.AkindsAndBomb = bomb
end
--函数功能：	获取三个A是否算炸弹
--返回值：		是否是炸弹
function PDKGameRule:GetAKindsAndBomb()
	return DDZGUIZE.AkindsAndBomb
end

--函数功能：	设置是否能四带二
--kinds:		是否允许
--返回值：		无
function PDKGameRule:SetIs4Kinds2(kinds)
	DDZGUIZE.is4Kinds2 = kinds
end
--函数功能：	获取四带二
--返回值：		无
function PDKGameRule:GetIsKinds2()
	return DDZGUIZE.is4Kinds2
end

--函数功能：	设置是否是自己打的牌
--site:			是否是自己
--返回值：		无
function PDKGameRule:SetSiteMy(site)
	DDZGUIZE.isSiteMy = site
end
--函数功能：	获取是否是自己打的牌
--返回值：		是否是自己
function PDKGameRule:GetSiteMy()
	return DDZGUIZE.isSiteMy
end

--函数功能：     获取牌型
--obCards:      目标牌集
--返回值：       牌型值，最小牌点数
function PDKGameRule:Initialize()
	--初始化玩法规则
	local stSetting = clone(RULESETTING)
	-- stSetting.unSign = 0x1B84
	self:Config(stSetting)
	self:CleanData()
	self:updateWanFa()
end

function PDKGameRule:CleanData()
	self:SetIsSpades(false)
	self:SetYinJiaXianShou(false)
	self:SetRule3Kinds(2)
	self:SetIsWhole(false)
	self:SetIsKindsWhole(false)
	self:SetYinJiaXianShou(false)
	self:SetAKindsAndBomb(false)
	self:SetIs4Kinds2(false)
end

--函数功能：     获取玩法规则
function PDKGameRule:updateWanFa()
	local wanfa = DataMgr:getInstance():getWanfaData()
	if wanfa then
        local tmpWanfa = ""
        for i=1,#wanfa do
			local w = wanfa[i]
			local title = kFriendRoomInfo:getPlayingInfoByTitle(w)
            if title then
				if title.title == "3dai2" then
					self:SetRule3Kinds(2)
				elseif title.title == "3dai1" then
					self:SetRule3Kinds(1)
				end
				if title.title == "3zsdjw" then
					self:SetIsWhole(true)
				end
				if title.title == "fjsdjw" then
					self:SetIsKindsWhole(true)
				end
				if title.title == "yjxj"  then
					self:SetYinJiaXianShou(true)
				end
				if title.title == "AAAzhadan" then
					self:SetAKindsAndBomb(true)
				end
				if title.title == "4dai2" then
					self:SetIs4Kinds2(true)
				end
            end
        end
    end
end

--函数功能：     获取牌型
--obCards:      目标牌集
--返回值：       牌型值，最小牌点数
function PDKGameRule:GetCardsType(obCards,last_cards)
	return self:CardsType(obCards,last_cards)
end

--函数功能：	获取牌型（直接传元值）
--obCards:		目标牌集
--返回值：		牌型
function PDKGameRule:GetobCardsType(obCards,last_cards)
	local selfCardSet = CardSet.new()
	selfCardSet:AddOriCards(obCards)
	return self:GetCardsType(selfCardSet,last_cards)
end

--函数功能：	转换牌型类型（三个A）
--obCards:		目标牌集
--返回值：		牌型
function PDKGameRule:GetSendCardsType(obCards,lastOutCards)
	local selfType = self:GetobCardsType(obCards,lastOutCards)
	if selfType == enmCardType.EBCT_BASETYPE_BOMB then
		if #obCards == 3 then
			return enmDDZCardType.EBCT_BASETYPE_AAA
		end
	end
	return selfType
end

--函数功能：	判断两张牌的level是否相同
--selfCards:	手牌的值
--obCards:		目标牌值
--返回值：		是否相等
function PDKGameRule:CompareCardLevel(selfCard,obCard)
	local card_1 = PokerUtil.parseSvrDataCard(selfCard)
	local card_2 = PokerUtil.parseSvrDataCard(obCard)
	if card_1.level == card_2.level then
		return true
	end
	return false
end
--函数功能：     获取牌型提示列表
--obCards:      目标牌集
--last_cards:   参照牌集
--返回值：       分析出来的
function PDKGameRule:GetCardTips(obCards, last_cards,ismove)
    local reslt = {}
	if not last_cards or last_cards:CurrentLength() == 0 then
		--首发出牌
		local first = {}
		if not ismove then
			first = self:GetFirst(obCards)
		else
			first = self:GetMoveFirst(obCards)
		end
        reslt = first
		return reslt
	end
	
	local unBombs = self:GetCommonStyle(obCards, last_cards)
	--删除比对家牌小的牌
	if last_cards then
		for i = #unBombs,1,-1 do
			if self:GetSortCardsLevel(unBombs[i]) < self:GetSortCardsLevel(last_cards:GetCards()) then
				table.remove(unBombs,i)
			end
		end
	end
	-- local bombs = self:GetBombStyle(obCards, last_cards)
	local bombs = self:GetBombStyle(obCards, last_cards)
	--当对家的牌为炸弹时需要去检测删牌
	if last_cards then
		if self:GetCardsType(last_cards,last_cards) == enmCardType.EBCT_BASETYPE_BOMB 
			or self:GetCardsType(last_cards,last_cards) == enmCardType.EBCT_BASETYPE_KINGBOMB then
				for i = #bombs,1,-1 do
					if bombs[i][1].level < last_cards:GetCards()[1].level then
						table.remove(bombs,i)
					end
				end
		end
	end
	local kings = {}
	--因为王炸时大小王拆牌需要单独处理
	if self:GetCardsType(last_cards,last_cards) == enmCardType.EBCT_BASETYPE_SINGLE then
		if bombs then
			for i ,v in ipairs(bombs) do
				if #v == 2 then
					for j,jv in pairs(v)do
						kings[#kings+1] = kings[#kings+1] or {}
						table.insert(kings[#kings],jv)
					end
				end
			end
		end
	end

	DiyalTool.Tab_insertto(reslt, unBombs)
	DiyalTool.Tab_insertto(reslt, bombs)
	DiyalTool.Tab_insertto(reslt, kings)

	reslt = self:removeCardType(reslt,obCards)
	return reslt
end

function PDKGameRule:removeCardType(result,obCards)
	local function removeCards()
		for i,v in pairs(result) do
			--如果是手牌的最后一手则直接跳过
			if table.nums(v) >= table.nums(obCards:GetCards()) then
				return
			end
			for j,k in pairs(v) do
				if k.cardType ~= nil then
					table.remove(v,j)
					return removeCards()
				end
			end

		end
	end
	removeCards()
	return result
end

--函数功能：	按牌型排序获取牌型最小那张
function PDKGameRule:GetSortCardsLevel(cards,last_cards)
	if not cards then
		return 0
	end
	local tmp_cards = {}
	for i,v in pairs(cards) do
		table.insert(tmp_cards,v.originalVal)
	end
	if #tmp_cards <= 0 then
		return 0
	end
	local selfCardSet = CardSet.new()
	selfCardSet:AddOriCards(tmp_cards)
	local cardType = self:GetCardsType(selfCardSet,last_cards)
	if cardType == enmCardType.EBCT_BASETYPE_3KIND
		or cardType == enmCardType.EBCT_BASETYPE_3AND1
		or cardType == enmCardType.EBCT_BASETYPE_3AND2
		or cardType == enmCardType.EBCT_BASETYPE_3KINDS
		or cardType == enmDDZCardType.EBCT_BASETYPE_3ANDX then
			local kind = self:GetCountsByLevel(selfCardSet,3)
			if not kind or #kind <= 0 then
				kind = self:FindAllBOMB(selfCardSet)
			end
			return kind[1][1].level
	elseif cardType == enmCardType.EBCT_BASETYPE_3KINDSAND1
		or cardType == enmCardType.EBCT_BASETYPE_3KINDSAND2
		or cardType == enmDDZCardType.EBCT_BASETYPE_3KINDSANDX then
			return self:GetCompKindsLevel(selfCardSet)
	elseif cardType == enmCardType.EBCT_BASETYPE_SINGLE
		or cardType == enmCardType.EBCT_BASETYPE_SISTER
		or cardType == enmCardType.EBCT_BASETYPE_PAIR
		or cardType == enmCardType.EBCT_BASETYPE_PAIRS then
			selfCardSet:SortByLevel()
			return selfCardSet:GetCards()[1].level
	elseif cardType == enmCardType.EBCT_BASETYPE_4KINDSAND2
		or cardType == enmCardType.EBCT_BASETYPE_4KINDSAND2s then
			local bomb = self:FindAllBOMB(selfCardSet) 
			return bomb[1][1].level
	else
			return selfCardSet:GetCards()[1].level
		end
end

--函数功能：	查找三顺个中最小的三个
--obCards:		目标牌集
--返回值：		最小牌的level
function PDKGameRule:GetCompKindsLevel(selfCardSet)
	local kind = self:FindAll3KINDS(selfCardSet)--self:GetCountsByLevel(selfCardSet,3)
	local bomb = self:FindAllBOMB(selfCardSet)
	-- if not bomb or #bomb <= 0 then
	-- 	return kind[1][1].level
	-- elseif not kind or #kind <=0 then
	-- 	return bomb[1][1].level
	-- else
		if kind or #kind > 0 then
			return kind[1][1].level
		elseif bomb or #bomb > 0 then
			return bomb[1][1].level
		end
	-- end
end

--函数功能：     获取首发出牌
--obCards:      目标牌集
--last_cards:   参照牌集
--返回值：       分析出来的
function PDKGameRule:GetFirst(obCards)
    local tmp_cards = clone(obCards)
	local reslt = {}
	local re_cards = {}
    --判断是否是黑桃三首轮出牌
	tmp_cards:SortCards(0)
	if obCards:CurrentLength() == self:GetSelfCardsNumber()  then
		self:SetIsSpades(self:CompareSpades(tmp_cards)) 
	end
	
	--查找所有的三顺带
	local all3KINDS = self:FindAll3KINDSANDX(tmp_cards)
	if all3KINDS and #all3KINDS > 0 then
		if self:GetIsSpades() then
			local cards = self:GetSpadesThreeCards(all3KINDS)
			if cards and #cards > 0 then
				local data = {}
				data.name = enmCardType.EBCT_BASETYPE_3KINDS
				data.cards = cards
				table.insert(reslt,data)
			end
		else
			local count = 0
			for i,v in ipairs(all3KINDS) do
				if #v == tmp_cards:CurrentLength() then
					return {v}
				end
			end
			
		end
	end
	--查找所有的三张
	local all3KIND = self:FindAll3AND(tmp_cards)
	if all3KIND and #all3KIND > 0 then
		if self:GetIsSpades() then
			local cards = self:GetSpadesThreeCards(all3KIND)
			if cards and #cards > 0 then
				local data = {}
				data.name = enmCardType.EBCT_BASETYPE_3KIND
				data.cards = cards
				table.insert(reslt,data)
			end
		else
			local count = 0
			for i,v in ipairs(all3KIND) do
				count = count + #v
			end
			if count == #tmp_cards:GetCards() and #all3KIND == 1 then
				return all3KIND
			end
		end
	end

	--查找所有的三带X
	local all3KINDX = self:FindAll3ANDX(tmp_cards)
    if all3KINDX and #all3KINDX > 0 then
		local count = 0
		for i,v in ipairs(all3KINDX) do
			count = count + #v
		end
		if count == #tmp_cards:GetCards() and #all3KINDX == 1 then
			return all3KINDX
		end
	end 
        
	
	--查找所有的连对
    local allPAIRS = self:FindAllPAIRS(tmp_cards)
    if allPAIRS and #allPAIRS > 0 then
        if not self:GetIsSpades() then
			for i,v in ipairs(allPAIRS) do
				local data = {}
				data.name = enmCardType.EBCT_BASETYPE_PAIRS
				data.cards = v
				table.insert(reslt,data)
            end
        else
            local cards = self:GetSpadesThreeCards(allPAIRS)
            if cards and #cards > 0 then
                local data = {}
				data.name = enmCardType.EBCT_BASETYPE_PAIRS
				data.cards = cards
				table.insert(reslt,data)
            end
        end
    end
	--查找所有的顺子
    local allSISTER = self:FindAllSISTER(tmp_cards)
    if allSISTER and #allSISTER > 0 then
        if not self:GetIsSpades() then
            for i,v in ipairs(allSISTER) do
                local data = {}
				data.name = enmCardType.EBCT_BASETYPE_SISTER
				data.cards = v
				table.insert(reslt,data)
            end
        else
            local cards = self:GetSpadesThreeCards(allSISTER)
            if cards and #cards > 0 then
                local data = {}
				data.name = enmCardType.EBCT_BASETYPE_SISTER
				data.cards = cards
				table.insert(reslt,data)
            end
        end
    end

	--查找所有的对子
    local allPAIR = self:FindAllPAIR(tmp_cards)
    if allPAIR and #allPAIR > 0 then
        if not self:GetIsSpades() then
            for i,v in ipairs(allPAIR) do
                local data = {}
				data.name = enmCardType.EBCT_BASETYPE_PAIR
				data.cards = v
				table.insert(reslt,data)
            end
        else
            local cards = self:GetSpadesThreeCards(allPAIR)
            if cards and #cards > 0 then
                local data = {}
				data.name = enmCardType.EBCT_BASETYPE_PAIR
				data.cards = cards
				table.insert(reslt,data)
            end
        end
    end
	
	--查找所有的单张
    local allSingle = self:FindAllSingle(tmp_cards)
	if not self:GetIsSpades() then
		if allSingle and #allSingle > 0 then
			for i,v in pairs(allSingle) do
				local data = {}
				data.name = enmCardType.EBCT_BASETYPE_SINGLE
				data.cards = v
				table.insert(reslt,data)
			end
		end
	else
		if allSingle and#allSingle > 0 then
			local cards = self:GetSpadesThreeCards(allSingle)
			if cards and #cards > 0 then
				local data = {}
				data.name = enmCardType.EBCT_BASETYPE_SINGLE
				data.cards = cards
				table.insert(reslt,data)
			end
		end
	end
	 
	--查找所有的炸弹(炸弹为最后提示而且所有牌型不排除炸弹所以放最后去判断)
	local bombs = self:GetBombStyle(tmp_cards)

	if bombs and #bombs>0 then
		if self:GetIsSpades() then
			local cards = self:GetSpadesThreeCards(bombs)
			if cards and #cards > 0  then
				table.insert(re_cards,cards)
				return re_cards
			end
		else
			local count = 0
			for i,v in ipairs(bombs) do
				if #v == obCards:CurrentLength() then
					return bombs
				end
				local data = {}
				data.name = enmCardType.EBCT_BASETYPE_BOMB
				data.cards = v
				table.insert(reslt,data)
			end
		end
	end
    --找张数最多的
    if reslt and #reslt then
        local cards = {}
        for i,v in ipairs(reslt) do
			cards[#v.cards] = cards[#v.cards] or {}
			table.insert(cards[#v.cards],v)
		end

		local function comparetocards(re_cards)
			local index = 1
			for i,v in pairs(re_cards) do
				if index < i then
					index = i
				end
			end
			local bomb = true
			for i = #re_cards[index],1,-1 do
				local v = re_cards[index][i]
				if v.name == enmCardType.EBCT_BASETYPE_3KIND or v.name == enmCardType.EBCT_BASETYPE_3KINDS then
					-- table.remove(re_cards[index],i)
					re_cards[index][i] = nil
				end
				if v.name ~= enmCardType.EBCT_BASETYPE_BOMB then
					bomb =false
				end
			end
			if #re_cards[index] <= 0 then
				re_cards[index] = nil
			end
			--如果炸弹为最长牌型时直接去除
			if bomb then
				-- table.remove(re_cards,index)
				re_cards[index] = nil
			end
			--如果最长的在牌型外则再次获取
			if not re_cards[index] or #re_cards[index] <= 0 then
				return comparetocards(re_cards)
			end
			local cmp_reslt = {}
			for i,v in pairs(re_cards[index]) do
				table.insert(cmp_reslt,v.cards)
			end
			return cmp_reslt
		end
        return comparetocards(cards)
    end

	return allSingle
end

--函数功能：	是否需要带上黑桃三
--obCards:		目标牌集
function PDKGameRule:CompareSpades(tmp_cards)
	if self:GetYinJiaXianShou() and HallAPI.DataAPI:getJuNowCnt() ~= 1 then
		return false
	end
	if #tmp_cards:GetCards() >= enmCardOriginalVal.cardsnumber then
		for i,v in ipairs(tmp_cards:GetCards()) do
			if v.originalVal == enmCardOriginalVal.Spades3 then
				return true
			end
			if v.level > 1 or self.ms_isSpades3 then
				break
			end
		end
	end
	return false
end

--函数功能：     获取首发出牌
--obCards:      目标牌集
--last_cards:   参照牌集
--返回值：       分析出来的
function PDKGameRule:GetMoveFirst(obCards)
    local tmp_cards = clone(obCards)
	local reslt = {}
	local re_cards = {}
    --判断是否是黑桃三首轮出牌
    tmp_cards:SortCards(0)
   	
	if (HallAPI.DataAPI:getJuNowCnt() ~= 1 or self:GetSelfCardsNumber() ~= enmCardOriginalVal.cardsnumber) and self:GetYinJiaXianShou() then
		self:SetIsSpades(false)
	end

	--查找所有的四带二
	local allBombAnd2 = self:FindAll4KingAnd2(tmp_cards)
	if allBombAnd2 and #allBombAnd2 > 0 then
		for i,v in ipairs(allBombAnd2) do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_4KINDSAND2
			data.cards = v
			table.insert(reslt,data)
		end
	end
	--查找所有的三顺带
	local all3KINDS = self:FindAll3KINDSANDX(tmp_cards,0)
	if all3KINDS and #all3KINDS > 0 then
		for i,v in ipairs(all3KINDS) do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_3KINDS
			data.cards = v
			table.insert(reslt,data)
		end
	end
	--查找所有的三张
	local all3KIND = self:FindAll3AND(tmp_cards)
	if all3KIND and #all3KIND > 0 then
		for i,v in ipairs(all3KIND) do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_3KIND
			data.cards = v
			table.insert(reslt,data)
		end
	end

	--查找所有的三带X
	local all3KINDX = self:FindAll3ANDX(tmp_cards,nil,true)
    if all3KINDX and #all3KINDX > 0 then
		for i,v in ipairs(all3KINDX) do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_3KIND
			data.cards = v
			table.insert(reslt,data)
		end
	end    
	
	--查找所有的连对
    local allPAIRS = self:FindAllPAIRS(tmp_cards)
    if allPAIRS and #allPAIRS > 0 then
		for i,v in ipairs(allPAIRS) do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_PAIRS
			data.cards = v
			table.insert(reslt,data)
		end
        
    end
	--查找所有的顺子
    local allSISTER = self:FindAllSISTER(tmp_cards)
    if allSISTER and #allSISTER > 0 then
		for i,v in ipairs(allSISTER) do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_SISTER
			data.cards = v
			table.insert(reslt,data)
		end
        
    end

	--查找所有的对子
    local allPAIR = self:FindAllPAIR(tmp_cards)
    if allPAIR and #allPAIR > 0 then
		for i,v in ipairs(allPAIR) do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_PAIR
			data.cards = v
			table.insert(reslt,data)
		end
       
    end
	
	--查找所有的单张
    local allSingle = self:FindAllSingle(tmp_cards)
	if allSingle and #allSingle > 0 then
		for i,v in pairs(allSingle) do
			local data = {}
			data.name = enmCardType.EBCT_BASETYPE_SINGLE
			data.cards = v
			table.insert(reslt,data)
		end
	end
	
	 
	--查找所有的炸弹(炸弹为最后提示而且所有牌型不排除炸弹所以放最后去判断)
	local bombs = self:GetBombStyle(tmp_cards)
	if bombs and #bombs>0 then
		if self:GetIsSpades() then
			local cards = self:GetSpadesThreeCards(bombs)
			if cards and #cards > 0  then
				table.insert(re_cards,cards)
				return re_cards
			end
		else
			local count = 0
			for i,v in ipairs(bombs) do
				local data = {}
				data.name = enmCardType.EBCT_BASETYPE_BOMB
				data.cards = v
				table.insert(reslt,data)
			end
		end
	end
    --找张数最多的
    if reslt and #reslt then
        local cards = {}
        for i,v in ipairs(reslt) do
			cards[#v.cards] = cards[#v.cards] or {}
			table.insert(cards[#v.cards],v)
		end

		local function comparetocards(re_cards)
			local index = 1
			for i,v in pairs(re_cards) do
				if index < i then
					index = i
				end
			end
			if #re_cards[index] <= 0 then
				re_cards[index] = nil
			end
			--如果最长的在牌型外则再次获取
			if not re_cards[index] or #re_cards[index] <= 0 then
				return comparetocards(re_cards)
			end
			local cmp_reslt = {}
			for i,v in pairs(re_cards[index]) do
				table.insert(cmp_reslt,v.cards)
			end
			return cmp_reslt
		end
        return comparetocards(cards)
    end

	return allSingle
end

--函数功能：	根据权值统计操作对象中大于或等于给定张数的牌的点数
--obCards:		目标牌集
--nCount:		给定张数
--mod:			模式（取0时，将张数大于nCount的数组保存，取1时将张数等于nCount的数组保存）
--返回值：		符合条件的牌组
function PDKGameRule:GetCountsByLevel(obCards,nCount,mod)
	--重写该方法因为判断时可以不排除炸弹
	mod = mod or 0

	local fenxi = self:CardsFenXi(obCards)
	local tmp_cards = {}
	for i,v in pairs(fenxi) do
		--判断是否寻找的是炸弹，如果不是则不能拆炸弹，如果是直接找比炸弹多的牌则直接检测炸弹
		local vNum = table.nums(v)
		local minBomLevel = mod == 0 and vNum >= nCount  or vNum == nCount
		local maxBomLevel = mod == 0 and vNum >= nCount  or vNum == nCount
		if (nCount < RULESETTING.nLimitBom and minBomLevel)
			 or ( nCount >= RULESETTING.nLimitBom and maxBomLevel ) then
			table.insert(tmp_cards,v)
		end
	end
	return tmp_cards
end

--函数功能：	查找牌型元值是否包含黑桃三
--cardsTable:	牌型table
--返回值：		Boolean
function PDKGameRule:GetSpadesThreeOriCards(cardsTable)
	local selfCardSet = CardSet.new()
	selfCardSet:AddOriCards(cardsTable)
	local Objcards = {}
	for i,v in pairs(selfCardSet:GetCards()) do
		table.insert(Objcards,v)
	end
	local cards = self:GetSpadesThreeCards(Objcards)
	if cards and cards.number then
		return true
	end
	return false
end

--函数功能：    查找牌型是否有包含黑桃三
--cardsTable:  牌型table
--返回值：      包含黑桃三的牌值
function PDKGameRule:GetSpadesThreeCards(cardsTable)
    local function search(cards,index)
        for j,jv in ipairs(cards) do
            index = index or j
            if jv.originalVal then
                if jv.originalVal == enmCardOriginalVal.Spades3 then
                    return jv,index
                end
            else
                return search(jv,index)
            end
        end
    end
    local card,index = search(cardsTable)
    return cardsTable[index]
end

--函数功能：    获取最小的指定个数牌
--obCards:     目标牌值
--selfCards:   自己的牌值(防止有的时候查找到自己一样的牌)
--number：     获取的指定张数
--iskinds:		是否只是轮询三个
--返回值：      最小类型的指定张数
function PDKGameRule:GetSmallTypeCard(obCards,selfCards,number,iskinds)
	local tmp_cards = {}
	number = number or obCards:CurrentLength()

	for i,v in ipairs(obCards:GetCards()) do
		local lev = v.level
		if tmp_cards[lev] == nil then
			tmp_cards[lev] = {}
		end
		table.insert( tmp_cards[lev],v)
	end
	obCards:SortByLevel()
	local result = {}
	local small = 0
    for i,v in ipairs(obCards:GetCards()) do
        local alike = false
        for j,jv in ipairs(selfCards) do
           if jv.level == v.level then
                alike = true
                break
           end
        end
        if not alike then
			if #result < number and #tmp_cards[v.level] <= 4 then
				small = small + 1
				v.cardType = "single"
                table.insert(result,v)
            else
                break
            end
        end
	end

	if iskinds and small < number then
		local bomb = self:FindAllBOMB(obCards)
		local function removeBomb() 
			for i,v in pairs(result) do
				for j,k in pairs(bomb) do
					if v.number == k[1].number then
						table.remove(bomb,j)
						return removeBomb()
					end
				end
			end
		end
		removeBomb()

		if bomb and #bomb > 0 and small < number then
			for i,v in pairs(bomb) do
				small = small + 1
				local value = bomb[i][1]
				value.cardType = "single"
				table.insert(result,value)
			end
		end
	end


    return result
end

--函数功能：	在指定牌集里删除相同的牌
--objectCards： 指定的牌集
--selfCards：	需要删除的牌
function PDKGameRule:removeFindCards(objectCards,selfCards)
	local function findSingle()
		for i,v in pairs(objectCards) do
			for j,k in pairs(selfCards) do
				if v.number == k.number then
					table.remove(objectCards, i)
					return findSingle()
				end
			end
		end
	end
	findSingle()
	return objectCards
end



--函数功能：     获取炸弹牌型提示
--obCards:      目标牌集
--last_cards:   参照牌集
--返回值：       分析出来的
function PDKGameRule:GetBombStyle(obCards, last_cards)
    local result = {}

	--找出普通炸
	local hand_cards_bombs = self:FindAllBOMB(obCards)
	-- wwdump(hand_cards_bombs)
	-- DiyalTool.Tab_insertto(result,hand_cards_bombs,hand_cards_kings)
	if hand_cards_bombs and #hand_cards_bombs > 0 then
		for i,v in ipairs(hand_cards_bombs) do
			table.insert( result,v)
		end
	end

	if last_cards and self:GetCardsType(last_cards,last_cards) == enmCardType.EBCT_BASETYPE_BOMB then
		for i = #result,1,-1 do
			if result[i][1].level < last_cards:GetCards()[1].level then
				table.remove(result,i)
			end
		end
	end

	return result
end

--函数功能：	检测是否带有炸弹
--obCards:		目标牌值
--返回值：		是否带有炸弹
function PDKGameRule:IsCardsAnBomb(obCards)
	local obCardSet = CardSet.new()
	obCardSet:AddOriCards(obCards)
	local bomb = self:GetBombStyle(obCardSet)
	if bomb and #bomb > 0 then
		return true
	end
	return false
end

--函数功能：	找出三个A
--obCards:		需要查找牌型的目标牌集
--返回值：		目标牌集
function PDKGameRule:GetKindsA(obCards)
	local fenxi = self:CardsFenXi(obCards,3,1)
	local result = {}
	for i,v in pairs(fenxi) do
		if v[1].number ==enmCardOriginalVal.cardsA and #v == 3 then
			result = v
			break
		end
	end
	return result
end

--函数功能：     牌型判断
--obCards:      需要查找牌型的目标牌集
--返回值：       目标牌集的牌型 int
function PDKGameRule:CardsType(obCards,lastCards)
	local cardType = enmCardType.EBCT_TYPE_NONE
	if obCards:CurrentLength() > 0 then
		local tmpCards = clone(obCards) --生成临时变量

		if self:Find_SINGLE(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_SINGLE
		elseif self:Find_PAIR(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_PAIR
		elseif self:Find_SISTER(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_SISTER
		elseif self:Find_PAIRS(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_PAIRS
		elseif self:Find_THREEKIND(tmpCards) and not lastCards then
			cardType = enmCardType.EBCT_BASETYPE_3KIND
		elseif self:Find_THREEKINDS(tmpCards) and not lastCards then
			cardType = enmCardType.EBCT_BASETYPE_3KINDS
		elseif self:Find_THREEANDONE(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_3AND1
		elseif self:Find_THREEANDTWO(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_3AND2
		elseif self:Find_THREEANDX(tmpCards) then
			cardType = enmDDZCardType.EBCT_BASETYPE_3ANDX
		elseif self:Find_THREEKINDSANDONE(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_3KINDSAND1		
		elseif self:Find_THREEKINDSANDTWO(tmpCards,lastCards) then
			cardType = enmCardType.EBCT_BASETYPE_3KINDSAND2
		elseif self:Find_THREEKINDSANDX(tmpCards) then
			cardType = enmDDZCardType.EBCT_BASETYPE_3KINDSANDX
		elseif self:Find_BOMBANDTOWONE(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_4KINDSAND2
		end
		--因为跑得快可能会存在两种情况都有的情况，所以得区分判断
		if self:Find_BOMB(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_BOMB
		elseif self:Find_King_BOMB(tmpCards) then
			cardType = enmCardType.EBCT_BASETYPE_KINGBOMB
		elseif cardType == enmCardType.EBCT_TYPE_NONE then
			--拓展特殊牌型
			-- for i,v in ipairs(self.ms_nCountSpecialType) do
			if self.ms_nCountSpecialType and self.ms_nCountSpecialType > 0 then
				for i=1, self.ms_nCountSpecialType do
					if self.ms_arrSpecialType[i] ~= nil then
						cardType = self.ms_arrSpecialType[i]:CardsType(tmpCards)
						if cardType ~= enmCardType.EBCT_TYPE_NONE then
							break
						end
					end
				end
			end
		end
	end
	return cardType
end

--函数功能：     查找顺子 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function PDKGameRule:Find_SISTER(obCards)
	obCards:SortCards(0)
	local result = false
	if obCards:CurrentLength() >= RULESETTING.nLimitSister then
		--检查是否是不相同的单张，如果是则检查是否是顺子
		local tmp_cards = self:GetCountsByLevel(obCards,1,1)
		if table.nums(tmp_cards) == obCards:CurrentLength() then
			local bSucc = true
			for i=2, obCards:CurrentLength() do
				if ((obCards:Card(i).level - (i-1)) ~= obCards:Card(1).level) or obCards:Card(i).number == enmCardOriginalVal.cards2 then
					bSucc = false
					break
				end
			end
			result = bSucc
		end
	end
	return result
end
--函数功能：     查找三张 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function PDKGameRule:Find_THREEKIND(obCards)
	if not self:GetIsWhole() or obCards:CurrentLength() ~= self:GetSelfCardsNumber() then
		return false
	end
	if 3 == obCards:CurrentLength() then
		local tmp_cards = self:FindAll3KIND(obCards)
		if table.nums(tmp_cards) > 0 then
			return true
		end
	end
	return false
end

--函数功能：     查找三顺 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function PDKGameRule:Find_THREEKINDS(obCards)
	if not self:GetIsKindsWhole() or obCards:CurrentLength() ~= self:GetSelfCardsNumber() then
		return false
	end
	local result = false
	if RULESETTING.nLimit3Kinds <= obCards:CurrentLength()/3 and obCards:CurrentLength()%3 == 0 then
		local tmp_cards =self:FindAll3KIND(obCards)
		
		local count_3Kind = 0
		if table.nums(tmp_cards) > 1 then
			for i = 2,table.nums(tmp_cards) do
				if tmp_cards[i][1].level - (i-1) ~= tmp_cards[1][1].level then
					return false
				else
					count_3Kind = count_3Kind + 1
					if count_3Kind >= RULESETTING.nLimit3Kinds - 1 and count_3Kind == table.nums(tmp_cards) -1  then
						result = true
					end
				end
			end
		end
	end
	return result
end

--函数功能：     查找三带一 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function PDKGameRule:Find_THREEANDONE(obCards)
	local kindCardsNumber = 4
	--如果勾选三带二时直接返回
	if self:GetRule3Kinds() == 2 then
		return false
	end
	if kindCardsNumber == obCards:CurrentLength() then
		local tmp_cards = self:FindAll3KIND(obCards)
		if (1 == table.nums(tmp_cards) and obCards:CurrentLength() == kindCardsNumber)  then
			return true
		end
	end
	return false
end

--函数功能：     查找三带二 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function PDKGameRule:Find_THREEANDTWO(obCards)
	local kindCardsNumber = 5
	--如果勾选三带一时直接返回
	if self:GetRule3Kinds() == 1 then
		return false
	end
	if kindCardsNumber == obCards:CurrentLength() then
		local tmp_cards = self:FindAll3KIND(obCards)
		if (1 == table.nums(tmp_cards) and obCards:CurrentLength() == kindCardsNumber) then
			return true
		end
		--炸弹带一也算成三带二
		local bomb_cards = self:GetCountsByLevel(obCards,4,1)
		if (1 == table.nums(bomb_cards)  and obCards:CurrentLength() == kindCardsNumber) then
			return true
		end
	end
	return false
end

--函数功能：     查找三带X virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function PDKGameRule:Find_THREEANDX(obCards)
	local kindCardsNumber = self:GetRule3Kinds() + MAX_3Kinds
	--如果勾选三带一时直接返回
	if kindCardsNumber > obCards:CurrentLength() then
		local tmp_cards = self:FindAll3KIND(obCards)
		if (1 == table.nums(tmp_cards) and (obCards:CurrentLength() == self:GetSelfCardsNumber() or not self:GetSiteMy())) then
			return true
		end
	end
	return false
end

--函数功能：     查找三顺带一 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function PDKGameRule:Find_THREEKINDSANDONE(obCards)
	--如果勾选三带二时直接返回
	if self:GetRule3Kinds() == 2 then
		return false
	end
	obCards:SortByLevel()
	local count_3Kind = self:FindAll3KINDS(obCards)
	if count_3Kind and #count_3Kind > 0 then
		for i,v in pairs(count_3Kind) do
		-- local kinds = count_3Kind[1]
			if v and #v>0 then
				local kindsNum = #v/3
				if #v + kindsNum*self:GetRule3Kinds() == obCards:CurrentLength() then
					return true
				end
			end
		end
	end
	return false
end

--函数功能：     查找三顺带二 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function PDKGameRule:Find_THREEKINDSANDTWO(obCards,lastCards)
	--如果勾选三带一时直接返回
	if self:GetRule3Kinds() == 1 then
		return false
	end
	local count_3Kind = self:FindAll3KINDS(obCards)
	-- local count_bomb = self:FindAllBOMB(obCards)
	if count_3Kind and #count_3Kind > 0 then
		for i,v in pairs(count_3Kind) do
			if v and #v>0 then
				local kindsNum = #v/3
				if #v + kindsNum*self:GetRule3Kinds() == obCards:CurrentLength() then
					return true
				end
			end
		end
	end
	return false
end

--函数功能：     查找三顺带X virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function PDKGameRule:Find_THREEKINDSANDX(obCards)
	--如果勾选三带一时直接返回
	local count_3Kind = self:FindAll3KINDS(obCards)
	local count_bomb = self:FindAllBOMB(obCards)
	--检查是否是大于三顺的最小牌型，并且带的单张是否是等于三顺的个数
	if #count_3Kind > 0 and (obCards:CurrentLength() == self:GetSelfCardsNumber() or not self:GetSiteMy())then
		local fenxi = self:CardsFenXi(obCards)
		local count = 0
		local kind = {}
		local sing = 0
		for i,v in pairs(fenxi) do
			local vNum = table.nums(v)
			if vNum >= 3 then
				if kind and #kind > 0 then
					if v[1].level - count == kind[1].level then
						if (i-sing) > 1 and (i-sing)*self:GetRule3Kinds() + (i-sing)*3 >= obCards:CurrentLength() then
							return true
						end
					else
						return false
					end
				else
					kind = v
				end
				count = count + 1
			else
				-- local cards = {}
				sing = i
				-- for j = i ,#fenxi ,1 do
				-- 	for k,kv in pairs(fenxi[j]) do
				-- 		table.insert(cards,kv)
				-- 	end
				-- end
				-- if i*self:GetRule3Kinds() >= table.nums(cards) then
				-- 	return true
				-- end
			end
		end
		return false
	end
	return false
end

--函数功能：     查找炸弹 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function PDKGameRule:Find_BOMB(obCards)
	--判断牌张数是否大于炸弹
	--判断是否是相同的牌并且向东的张数是否大于炸弹最小数
	if obCards:CurrentLength() >= RULESETTING.nLimitBom then
		local fenxi = self:CardsFenXi(obCards)
		local fenxiNum = table.getn(fenxi)
		local counter = 0
		for i,v in pairs(fenxi) do
			counter = table.nums(v)
		end
		if table.nums(fenxi) == 1 and counter >= RULESETTING.nLimitBom then
			return true
		end
	elseif self:GetAKindsAndBomb() and obCards:CurrentLength() == 3 then
		local fenxi = self:CardsFenXi(obCards)
		if table.nums(fenxi) == 1 and fenxi[1][1].number == enmCardOriginalVal.cardsA then
			return true
		end
	end
	return false
end

--函数功能：	查找四带二
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function PDKGameRule:Find_BOMBANDTOWONE(obCards)
	if not self:GetIsKinds2() then
		return
	end
	local count_bom = self:GetCountsByLevel(obCards,RULESETTING.nLimitBom)--self:FindAllBOMB(obCards)--self:GetCountsByLevel(obCards,RULESETTING.nLimitBom)
	if 1 == table.nums(count_bom) then
		local number = obCards:CurrentLength()-table.nums(count_bom)*RULESETTING.nLimitBom
		--如果是A的话，则只有三张
		if count_bom[1][1].number == enmCardOriginalVal.cardsA then
			number = obCards:CurrentLength()-table.nums(count_bom)*3
		end
		if number == 2 then
			return true
		end
	end

	return false
end

--函数功能：     查找王炸 virtual
--obCards:      目标牌集
--返回值：       比较结果 BOOL
function PDKGameRule:Find_King_BOMB(obCards)
	--因为没有王所以王炸为空的判断
	return false
end

--函数功能：     查找所有的单张（所有单子）
--obCards:      目标牌集
--返回值：       找出的所有牌值
function PDKGameRule:FindPressAllSingle(obCards)
	
	local tmp_cards = {}
	obCards:SortCards()
	for i,v in ipairs(obCards:GetCards()) do
		local lev = v.level
		if tmp_cards[lev] == nil then
			tmp_cards[lev] = {}
		end
		table.insert( tmp_cards[lev],v)
	end

	--排序
	local result = {}
	for i,v in pairs(tmp_cards) do
		local data = {}
		data.index = i
		data.cards = v
		table.insert(result,data)
	end
	table.sort(result,function(a,b) return a.index < b.index end)
	tmp_cards = result
	
    result = {}
	for i,v in pairs(tmp_cards) do
		result[#result + 1] = result[#result + 1] or {}
		table.insert(result[#result],v.cards[1])
    end
	--wwdump(result,"single:")
	return result
end

--函数功能：     查找所有的对子（拆牌后的所有对子）
--obCards:      目标牌集
--返回值：       找出的所有牌值
function PDKGameRule:FindPressPair(obCards)
	local result = {}
	local pair = self:GetCountsByLevel(obCards,2)
	for i,v in pairs(pair) do
		result[i] = result[i] or {}
		for j,jv in pairs(v) do
			table.insert(result[i],jv)
			if j == 2 then
				break
			end
		end
	end
	return result
end

--函数功能：     查找所有的三张（拆牌后的所有三张）
--obCards:      目标牌集
--返回值：       找出的所有牌值
function PDKGameRule:FindPressAll3KIND(obCards)
	local result = {}
	--查找所有的飞机里面的三张
	local all3KINDS = self:FindAll3KINDS(obCards)
	if all3KINDS and #all3KINDS > 0 then
		for i=#all3KINDS,1,-1 do
			local tmp_cards = {}
			for j=#all3KINDS[i],1,-1 do
				table.insert(tmp_cards,all3KINDS[i][j])
				if j%3 == 1 then
					table.insert(result,1,tmp_cards)
					tmp_cards = {}
				end
			end
		end
	end
	--查找所有的顺子
	local allSISTER = self:FindAllSISTER(obCards)
	if allSISTER and #allSISTER > 0 then
		local pair = {}
		for i,v in ipairs(obCards:GetCards()) do
			local lev = v.level
			if pair[lev] == nil then
				pair[lev] = {}
			end
			table.insert( pair[lev],v)
		end
		for i = #allSISTER,1,-1 do
			for j = #allSISTER[i],1,-1 do
				if #pair[allSISTER[i][j].level] >= 3 then
					local tmp_cards = {}
					for k,kv in ipairs(pair[allSISTER[i][j].level]) do
						table.insert(tmp_cards,kv)
						if #tmp_cards >= 3 then
							break
						end
					end
					table.insert(result,1,tmp_cards)
				end
			end
		end
	end
	--查找所有的三张
	local all3KIND = self:FindAll3KIND(obCards)
	if all3KIND and #all3KIND > 0 then
		for i = #all3KIND,1,-1 do
			local tmp_cards = {}
			for j = #all3KIND[i],1,-1 do
				table.insert(tmp_cards,all3KIND[i][j])
				if j%3 == 1 then
					table.insert(result,1,tmp_cards)
					tmp_cards = {}
				end
			end
			
		end
	end
	--去重
	local tmp_cards = {}
	for i,v in pairs(result) do
		tmp_cards[v[1].level] = tmp_cards[v[1].level] or {}
		tmp_cards[v[1].level].index = i
		tmp_cards[v[1].level].cards = v
	end
	--排序
	result = {}
	for i,v in pairs(tmp_cards) do
		local data = {}
		data.index = v.index
		data.cards = v.cards
		table.insert(result,data)
	end
	table.sort(result,function(a,b) return a.index < b.index end)
	tmp_cards = {}
	for i,v in pairs(result) do
		table.insert(tmp_cards,v.cards)
	end
	return tmp_cards
end

--函数功能：     查找所有的三带一或者三带二(如果牌不够时可以直接压)
--obCards:      目标牌集
--isWhole：		是否需要全带（true全带，false可以少带）
--返回值：       找出的所有牌值
function PDKGameRule:FindAll3AND(obCards)
	local reslt = {}
	--find all 3kind
	local kind3s = self:FindAll3KIND(obCards)
	--find all single
	--检测所有的三张然后带除三张之外最小的
	if (#kind3s > 0)then
		for ii,vv in ipairs(kind3s) do
			local singles = self:GetSmallTypeCard(obCards,vv,self:GetRule3Kinds(),true)
			local kind = DiyalTool.Tab_insertto(vv,singles)
			table.insert(reslt, kind)
		end
		
		--检测没有带全直接删除
		for i=#reslt,1,-1 do
			if #reslt[i] < MAX_3Kinds + self:GetRule3Kinds() then
				table.remove(reslt,i)
			end
		end
	end

	return reslt
end

--函数功能：     查找所有的三带一(如果牌不够时可以直接压)
--obCards:      目标牌集
--isWhole：		是否需要全带（true全带，false可以少带）
--返回值：       找出的所有牌值
function PDKGameRule:FindAll3ANDX(obCards,lastCards,ismove)
	local isWhole = self:GetIsWhole() or false
	local reslt = {}
	--find all 3kind
	local kind3s = self:FindAll3KIND(obCards)
	--find all single
	--检测所有的三张然后带除三张之外最小的
	if (#kind3s > 0)then
		for ii,vv in ipairs(kind3s) do
			local singles = self:GetSmallTypeCard(obCards,vv,self:GetRule3Kinds(),true)
			local kind = DiyalTool.Tab_insertto(vv,singles)
			table.insert(reslt, kind)
		end
		
		--如果不可以少带时，检测没有带到的直接删除
		if not ismove then
			for i=#reslt,1,-1 do
				--需要全带或者个数大于1或者不是最后一手的时候不能少带
				local whole = false
				if ((lastCards and #lastCards:GetCards() > 0 and not isWhole and #reslt[i] == self:GetSelfCardsNumber()))
					or ( not lastCards and  #reslt[i] > self:GetSelfCardsNumber()) then
						whole = true
				end
				if #reslt[i] < self:GetSelfCardsNumber() then
					whole = true
				end
				if#reslt[i] < MAX_3Kinds + self:GetRule3Kinds() and whole then
					table.remove(reslt,i)
				end
			end
		end
	end


	return reslt
end

--函数功能：     查找所有的三张
--obCards:      目标牌集
--返回值：       找出的所有牌值
function PDKGameRule:FindAll3KIND(obCards)
	obCards = clone(obCards)
	local kind = self:GetCountsByLevel(obCards,3,1)
	local bomb = self:FindAllBOMB(obCards)
	--如果勾选了三个A算炸弹则去除三个A
	if self:GetAKindsAndBomb() then
		for i,v in pairs(kind) do
			if v[1].number ==enmCardOriginalVal.cardsA then
				table.remove(kind,i)
				break
			end
		end
		for i,v in pairs(bomb) do
			if v[1].number ==enmCardOriginalVal.cardsA then
				table.remove(bomb,i)
				break
			end
		end
	end
	--炸弹带一张可能也是三带二
	if bomb and #bomb > 0  and obCards:CurrentLength() > RULESETTING.nLimitBom then
		for i,v in pairs(bomb) do
			kind[#kind + 1] = kind[#kind + 1] or {}
			for j,jv in pairs(v) do
				if j <= 3 then
					table.insert(kind[#kind],jv)
				end
			end

		end
	end

	--排序(防止中间有炸弹的情况)
	local tmp_cards = {}
	for i,v in pairs(kind) do
		-- tmp_cards[v[1].level] = tmp_cards[v[1].level] or {}
		local data = {}
		data.level = v[1].level
		data.cards = v
		table.insert(tmp_cards,data)
	end
	table.sort(tmp_cards,function(a,b) return a.level < b.level end)
	kind = {}
	for i,v in pairs(tmp_cards) do
		table.insert(kind,v.cards)
	end
	return kind
end

--函数功能：	检测压牌时的对方有多少个三张
--obCards:		目标牌集
--返回值：		多少三张
function PDKGameRule:FindKindsNumber(obCards)
	local kind3 = self:FindAll3KIND(obCards)
	local function removerCard()
		if table.nums(kind3) >= RULESETTING.nLimit3Kinds + 1 and obCards:CurrentLength()-3*table.nums(kind3) < table.nums(kind3)*self:GetRule3Kinds() then
			table.remove(kind3,1)
			if obCards:CurrentLength()-3*table.nums(kind3) < table.nums(kind3)*self:GetRule3Kinds() then
				removerCard()
			end
		end
	end
	removerCard()
	return table.nums(kind3)
end
--函数功能：     查找所有的三顺带一 JJJQQQ...+KA...
--obCards:      目标牌集
--count：		多少个组合（不传时为全部）
--返回值：       找出的所有牌值
function PDKGameRule:FindAll3KINDSAND(obCards,count)
	local reslt = {}
	local cards = {}
	count = count or 0
	local kind3s = self:FindAll3KINDS(obCards,count)
	
	if kind3s and #kind3s > 0 then
		for i,v in ipairs(kind3s) do
			local number = count > 0 and count*self:GetRule3Kinds() or #v/3*self:GetRule3Kinds()
			local singles = self:GetSmallTypeCard(obCards,v,number,true)
			local kind = DiyalTool.Tab_insertto(clone(v),singles)
			table.insert(reslt, kind)
		end
	end

	for i=#reslt,1,-1 do
		--需要全带或者个数大于1或者不是最后一手的时候不能少带
		local kindsNum = math.floor(#kind3s[i]/MAX_3Kinds)*self:GetRule3Kinds() + #kind3s[i]
		if #reslt[i] < kindsNum then
			table.remove(reslt,i)
		end
	end
	
	return reslt
end

--函数功能：     查找所有的三顺带一 JJJQQQ...+KA...
--obCards:      目标牌集
--count：		多少个组合（不传时为全部）
--返回值：       找出的所有牌值
function PDKGameRule:FindAll3KINDSANDX(obCards,count,lastCards)
	local reslt = {}
	local cards = {}
	count = count or 0
	local isWhole = self:GetIsKindsWhole() or false
	local kind3s = self:FindAll3KINDS(obCards,count)
	
	if kind3s and #kind3s > 0 then
		for i,v in ipairs(kind3s) do
			local number = count > 0 and count*self:GetRule3Kinds() or #v/3*self:GetRule3Kinds()
			local singles = self:GetSmallTypeCard(obCards,v,number,true)
			local kind = DiyalTool.Tab_insertto(clone(v),singles)
			table.insert(reslt, kind)
		end
	end

	for i=#reslt,1,-1 do
		--需要全带或者个数大于1或者不是最后一手的时候不能少带
		local whole = false
		if (lastCards and #lastCards:GetCards() > 0 and not isWhole and #reslt[i] == self:GetSelfCardsNumber()
			or not lastCards and #reslt[i] < self:GetSelfCardsNumber()) then
				whole = true
		end
		if #reslt[i] < self:GetSelfCardsNumber() then
			whole = true
		end
		if (#reslt[i] < #kind3s/MAX_3Kinds*self:GetRule3Kinds() + #kind3s and whole) then
			table.remove(reslt,i)
		end
	end
	
	return reslt
end

--函数功能：     查找所有的三顺（三连）
--obCards:      目标牌集
--count:        连续点数
--返回值：       找出的所有牌值
function PDKGameRule:FindAll3KINDS(obCards, count)

	local reslt = {}
	local cards = {}
	
	--find all 3kind
	local kind3 = self:FindAll3KIND(obCards)--self:GetCountsByLevel(obCards, 3, 1)
	
	if not count or count == 0 then
		count = #kind3
	end
	local tmp_cards = {}
	local counter = 1
	--查找是否是顺子
	for i,v in pairs(kind3) do
		if i <= 1 or v[1].level - 1 == kind3[i-1][1].level then
			tmp_cards[counter] = tmp_cards[counter] or {}
			table.insert(tmp_cards[counter], v)
		else
			counter = counter + 1
			tmp_cards[counter] = tmp_cards[counter] or {}
			table.insert(tmp_cards[counter], v)
		end
	end
	--先排除不连续的
	for i=#tmp_cards,1,-1 do
		if #tmp_cards[i]<2 then
			table.remove(tmp_cards,i)
		end
	end
	
	--当三个和带牌对不上时排除最小的三个
	local function removerCard(index)
		kind3 = tmp_cards[index]
		local kindNumber = 0
		for i,v in pairs(kind3) do
			kindNumber = kindNumber+#v
		end

		if table.nums(kind3) >= RULESETTING.nLimit3Kinds + 1 and obCards:CurrentLength()-kindNumber < table.nums(kind3)*self:GetRule3Kinds() and count == #kind3
			and (obCards:CurrentLength() < self:GetSelfCardsNumber() or not self:GetSiteMy()) then
			table.remove(kind3,1)
			if obCards:CurrentLength()-3*table.nums(kind3) < table.nums(kind3)*2 then
				if count == #kind3 + 1 then
					count = #kind3
				end
				removerCard(index)
			end
		end
	end
	for i,v in pairs(tmp_cards) do
		removerCard(i)
	end
	
	--拆分出需要的飞机相连个数
	for i,v in pairs(tmp_cards) do
		kind3 = tmp_cards[i]
		for i = 1, #kind3 do
			local cc = 1
			local tmp = {}
			table.insert(tmp, kind3[i])
			if i <= #kind3 - 1 then
				for j = i + 1, #kind3 do --calc from i+1
					if kind3[j][1].level == kind3[j - 1][1].level + 1 and kind3[j][1].number < enmCardOriginalVal.cards2 then
						-- wwdump(kind3[i], "kind3[i]")
						cc = cc + 1
						table.insert(tmp, kind3[j])
						if cc == count or count == 0 then
							table.insert(cards, tmp)
							break
						end
						if j == #kind3 then
							table.insert(cards, tmp)
						end
					else
						if #tmp > 1 then
							table.insert(cards, tmp)
						end
						break
					end
				end
			end
		end
	end
	--把所有查出来的顺子整合到一起
	for i,v in ipairs(cards) do
		for j,k in ipairs(v) do
			reslt[i] = reslt[i] or {}
			for m,n in ipairs(k) do
				table.insert( reslt[i],n)
			end
		end
	end
	return reslt
end

--函数功能：	查找所有的四带二
--mod:		   1为四带两张，2为四带两对
--返回值：		满足条件的牌
function PDKGameRule:FindAll4KingAnd2(obCards,mod)
	if not self:GetIsKinds2() then
		return {}
	end
	local reslt = {}
	local bombs = self:GetCountsByLevel(obCards,RULESETTING.nLimitBom)--self:FindAllBOMB(obCards)
	local tmp_cards = clone(obCards)
	--删除牌集里面所有相同的牌
	local function removeCards(cards)
		for i,v in pairs(tmp_cards:GetCards()) do
			for j, k in pairs(cards) do
				if v.number == k[1].number then
					tmp_cards:DelCard(i)
					return removeCards(cards)
				end
			end
		end
	end
	removeCards(bombs)

	local daipai = {}
	daipai = self:GetAnalyzeSingle(self:GetAnalyzeCards(tmp_cards),2)
	if #daipai < 2 then
		return reslt
	end
	
	for i,v in ipairs(bombs) do
		local cards = {}
		for j,jv in pairs(v) do
			table.insert(cards,jv)
		end

		for j,jv in ipairs(daipai) do
			if j<= 2 then
				table.insert(cards,jv)
			end
		end
		table.insert(reslt,cards)
	end
	

	
	return reslt
end


--函数功能：     查找所有的 炸弹
--obCards:      目标牌集
--返回值：       找出的所有牌值
function PDKGameRule:FindAllBOMB(obCards)
	--其它特殊牌型，如510作为炸弹，可以取得FindAllBOMB和特殊牌型组合使用
	obCards:SortByLevel()
	local bombs = self:GetCountsByLevel(obCards, 4)
	--如果勾选了三个A算炸弹则计算
	if self:GetAKindsAndBomb()  then
		local akinds = self:GetKindsA(obCards)
		if akinds and #akinds > 0 then
			table.insert(bombs,self:GetKindsA(obCards))
		end
	end
	return bombs
end
--函数功能：     获取非炸弹牌型提示
--obCards:      目标牌集
--last_cards:   参照牌集
--返回值：       分析出来的
function PDKGameRule:GetCommonStyle(obCards, last_cards)
	--压牌轮没有黑桃三概念
	self:SetIsSpades(false)
	
	local result = {}

	
	last_cards = last_cards or obCards
	local last_card_type = self:GetCardsType(last_cards,last_cards)

	local tmp_cards1 = {}

	--找出非炸弹牌型
	if last_card_type == enmCardType.EBCT_BASETYPE_SINGLE then
		tmp_cards1 = self:FindPressAllSingle(obCards)
	elseif last_card_type == enmCardType.EBCT_BASETYPE_PAIR then
		tmp_cards1 = self:FindPressPair(obCards)
	elseif last_card_type == enmCardType.EBCT_BASETYPE_SISTER then
		tmp_cards1 = self:FindAllSISTER(obCards, last_cards:CurrentLength())
	elseif last_card_type == enmCardType.EBCT_BASETYPE_PAIRS then
		tmp_cards1 = self:FindAllPAIRS(obCards,last_cards:CurrentLength()/2)
	elseif last_card_type == enmCardType.EBCT_BASETYPE_3AND1 
		or last_card_type == enmCardType.EBCT_BASETYPE_3AND2
		or last_card_type == enmCardType.EBCT_BASETYPE_3KIND then
		tmp_cards1 = self:FindAll3AND(obCards)
	elseif last_card_type == enmCardType.EBCT_BASETYPE_3KINDSAND1
		or last_card_type == enmCardType.EBCT_BASETYPE_3KINDSAND2
		or last_card_type == enmCardType.EBCT_BASETYPE_3KINDS then
		tmp_cards1 = self:FindAll3KINDSAND(obCards,self:FindKindsNumber(last_cards))
	elseif last_card_type == enmCardType.EBCT_BASETYPE_4KINDSAND2 then
		tmp_cards1 = self:FindAll4KingAnd2(obCards,(last_cards:CurrentLength()-RULESETTING.nLimitBom)/2)
	end
	if not tmp_cards1 or #tmp_cards1 <= 0 then
		if last_card_type == enmCardType.EBCT_BASETYPE_3AND1 
			or last_card_type == enmCardType.EBCT_BASETYPE_3AND2
			or last_card_type == enmCardType.EBCT_BASETYPE_3KIND 
			or last_card_type == enmDDZCardType.EBCT_BASETYPE_3ANDX then
			tmp_cards1 = self:FindAll3ANDX(obCards,last_cards)
		elseif last_card_type == enmCardType.EBCT_BASETYPE_3KINDSAND1
			or last_card_type == enmCardType.EBCT_BASETYPE_3KINDSAND2
			or last_card_type == enmCardType.EBCT_BASETYPE_3KINDS 
			or last_card_type == enmDDZCardType.EBCT_BASETYPE_3KINDSANDX then
			tmp_cards1 = self:FindAll3KINDSANDX(obCards,table.nums(self:FindAll3KIND(last_cards)),last_cards)
		end
	end
	-- wwdump(tmp_cards1)

	--筛选`
	for k, v in ipairs(tmp_cards1) do
		local cardSet = require("package_src.games.paodekuai.pdkpoker.CardSet"):new()
		cardSet:AddCards(v)
		local cmpRlt = self:Compare(cardSet, last_cards)
		if cmpRlt == enmTypeCompareResult.ETCR_MORE then
			print(cmpRlt)
			table.insert(result, v)
		end
	end

	return result
end
--函数功能：	检测是否是有效牌型
--selfCards:	手牌
--obCards:		需要压的牌
--返回值：		是否能压死
function PDKGameRule:CompareByCardType(selfCards,obCards)
	if not selfCards or #selfCards <= 0 then
		return false
	end
	if not obCards or #obCards <= 0 then
		local selfCardsType = self:GetobCardsType(selfCards)
		if selfCardsType and selfCardsType ~= enmCardType.EBCT_TYPE_NONE then
			if selfCardsType == enmCardType.EBCT_BASETYPE_3KIND or selfCardsType == enmCardType.EBCT_BASETYPE_3KINDS then
				if #selfCards == self:GetSelfCardsNumber() then
					return true
				else
					return false
				end
			end
			if ((selfCardsType == enmCardType.EBCT_BASETYPE_3AND1 or selfCardsType == enmCardType.EBCT_BASETYPE_3KINDSAND1) 
				and self:GetRule3Kinds() == 2)
			or ((selfCardsType == enmCardType.EBCT_BASETYPE_3AND2 or selfCardsType == enmCardType.EBCT_BASETYPE_3KINDSAND2)
				 and self:GetRule3Kinds() == 1) then
				return false
			end
			return true
		end
		return false
	end

	local selfCardSet = CardSet.new()
	selfCardSet:AddOriCards(selfCards)
	local obCardsSet = {}
	if obCards and #obCards > 0 then
		obCardsSet = CardSet.new()
		obCardsSet:AddOriCards(obCards)
	end
	local cmpRlt = self:Compare(selfCardSet,obCardsSet)
	if cmpRlt >= enmTypeCompareResult.ETCR_MORE then
		return true
	end
	return false
end

--函数功能：     根据level对两牌集的比较
--selfCards:    被比较的牌集
--obCards:      参照的目标牌集
--返回值：       比较结果 int
function PDKGameRule:Compare(selfCards, obCards)

	local reslt = enmTypeCompareResult.ETCR_OTHER
	local tmpSelfCards = selfCards
	local tmpObCards = obCards
	local selfType = self:CardsType(tmpSelfCards,tmpObCards)
	local obType = self:CardsType(tmpObCards)
	if (selfType ~= enmCardType.EBCT_TYPE_NONE) and (obType ~= enmCardType.EBCT_TYPE_NONE) then
		local is3andx = false
		if (selfType == enmDDZCardType.EBCT_BASETYPE_3ANDX and 
			(obType == enmCardType.EBCT_BASETYPE_3AND1 
				or obType == enmCardType.EBCT_BASETYPE_3AND2 
				or obType == enmCardType.EBCT_BASETYPE_3KIND)) then
				is3andx = true
		elseif(selfType == enmDDZCardType.EBCT_BASETYPE_3KINDSANDX and 
				(obType == enmCardType.EBCT_BASETYPE_3KINDSAND1 
				or obType == enmCardType.EBCT_BASETYPE_3KINDSAND2 
				or obType == enmCardType.EBCT_BASETYPE_3KINDS)) then
				is3andx = true
		end
		if selfType == obType or is3andx then --牌型相同时的比较
			if selfType == enmCardType.EBCT_BASETYPE_SINGLE
				or selfType == enmCardType.EBCT_BASETYPE_PAIR
				or selfType == enmCardType.EBCT_BASETYPE_PAIRS
				or selfType == enmCardType.EBCT_BASETYPE_SISTER then
				reslt = self:Compare_ByMinLevel(tmpSelfCards,tmpObCards)
			elseif selfType == enmCardType.EBCT_BASETYPE_3KINDS
				or selfType == enmCardType.EBCT_BASETYPE_3KIND
				or selfType == enmCardType.EBCT_BASETYPE_3AND1
				or selfType == enmCardType.EBCT_BASETYPE_3AND2
				or selfType == enmCardType.EBCT_BASETYPE_3KINDSAND1
				or selfType == enmCardType.EBCT_BASETYPE_3KINDSAND2 then
					reslt = self:Compare_ByMinLevel3Kind(tmpSelfCards,tmpObCards,selfType)
			elseif selfType == enmDDZCardType.EBCT_BASETYPE_3ANDX then
					if self:GetIsWhole() then
						reslt = self:Compare_ByMinLevel3Kind(tmpSelfCards,tmpObCards,selfType)
					end
			elseif selfType == enmDDZCardType.EBCT_BASETYPE_3KINDSANDX then
					if self:GetIsKindsWhole() then
						reslt = self:Compare_ByMinLevel3Kind(tmpSelfCards,tmpObCards,selfType)
					end
			elseif selfType == enmCardType.EBCT_BASETYPE_4KINDSAND2
				or selfType == enmCardType.EBCT_BASETYPE_4KINDSAND2s then
					reslt = self:Compare_ByMinLevel4Kind(tmpSelfCards,tmpObCards)
			elseif selfType == enmCardType.EBCT_BASETYPE_BOMB then
				reslt = self:Compare_Bomb(tmpSelfCards,tmpObCards)
			else
				reslt = self:Compare_BetweenTypes(selfType,obType)
			end
		elseif selfType == enmCardType.EBCT_BASETYPE_BOMB then
				reslt = enmTypeCompareResult.ETCR_MORE
		end
	end
	return reslt
end

--函数功能：     通过Level3Kind进行比较
--selfCards:	自己的牌集
--obCards:      目标牌集
--返回值：       比较结果
function PDKGameRule:Compare_ByMinLevel3Kind(selfCards,obCards,selfType)
	local reslt = enmTypeCompareResult.ETCR_OTHER
	if selfCards:CurrentLength() == obCards:CurrentLength() 
		or (selfCards:CurrentLength() <= obCards:CurrentLength() 
			and (self:GetIsWhole() or self:GetIsKindsWhole()) 
			and selfCards:CurrentLength() == self:GetSelfCardsNumber())  then
			--
		local self3Kind = self:FindAll3KIND(selfCards)
		local ob3Kind = self:FindAll3KIND(obCards)
		if selfType == enmCardType.EBCT_BASETYPE_3KINDSAND1 
			or selfType == enmCardType.EBCT_BASETYPE_3KINDSAND2
			or selfType == enmCardType.EBCT_BASETYPE_3KINDSANDX then
				self3Kind = self:FindAll3KINDS(selfCards)
				ob3Kind = self:FindAll3KINDS(obCards)
		end
		
		local selfObCards = {}
		for i,v in pairs(self3Kind) do
			if #v == #ob3Kind[1] then
				selfObCards = v
			end
		end

		if selfObCards and #selfObCards > 0 and ob3Kind and #ob3Kind > 0 then
			if selfObCards[#selfObCards].level > ob3Kind[#ob3Kind][1].level then
				reslt = enmTypeCompareResult.ETCR_MORE
			elseif selfObCards[#selfObCards].level < ob3Kind[#ob3Kind][1].level then
				reslt = enmTypeCompareResult.ETCR_LESS
			else
				reslt = enmTypeCompareResult.ETCR_EQUAL
			end
		end

	end
	return reslt
end


--函数功能：     通过Bomb进行比较
--selfCards:	自己的牌集
--obCards:      目标牌集
--返回值：       比较结果
function PDKGameRule:Compare_Bomb(selfCards,obCards)
	local reslt = enmTypeCompareResult.ETCR_OTHER 
	local selfBomb = self:FindAllBOMB(selfCards)
	local obBomb = self:FindAllBOMB(obCards)
	
	if selfBomb and #selfBomb > 0 and obBomb and #obBomb > 0 then
		if selfBomb[#selfBomb][1].level > obBomb[#obBomb][1].level then
			reslt = enmTypeCompareResult.ETCR_MORE
		elseif selfBomb[#selfBomb][1].level < obBomb[#obBomb][1].level then
			reslt = enmTypeCompareResult.ETCR_LESS
		else
			reslt = enmTypeCompareResult.ETCR_EQUAL
		end
	end
	return reslt
end

--函数功能：	通过Level4Kind进行比较
--selfCards:	自己的牌集
--obCards:      目标牌集
--返回值：       比较结果
function PDKGameRule:Compare_ByMinLevel4Kind(selfCards,obCards)
	local reslt = self:Compare_Bomb(selfCards,obCards)
	local selfBomb = self:FindAllBOMB(selfCards)
	local obBomb = self:FindAllBOMB(obCards)
	if selfCards:CurrentLength() - #selfBomb[1] ~= 2 or obCards:CurrentLength()-#obBomb[1] ~= 2 then
		reslt = enmTypeCompareResult.ETCR_OTHER 
	end
	-- end
	return reslt
end

--函数功能：	查能压的牌
--selfCards:	手牌
--obCards:	   需要压的牌
--isMove		是否是滑动选牌
function PDKGameRule:PressCard(selfCards,obCards,isMove)
    if not selfCards then
		return 
	end

	local selfCardSet = CardSet.new()
	selfCardSet:AddOriCards(selfCards)
	
	local obCardsSet = nil
	if obCards and #obCards > 0 then
		obCardsSet = CardSet.new()
		obCardsSet:AddOriCards(obCards)
	end
	-- tipsType = tipsType or 1
	local result = {}
	local cardTips = self:GetCardTips(selfCardSet,obCardsSet,isMove)
	for i,v in ipairs(cardTips) do
		result[i] = result[i] or {}
		for j,jv in ipairs(v) do
			table.insert(result[i],jv.originalVal)
		end
	end
	if selfCardSet then
		selfCardSet:ClearAll()
	end
	if obCardsSet then
		obCardsSet:ClearAll()
	end
	return result
end


return PDKGameRule