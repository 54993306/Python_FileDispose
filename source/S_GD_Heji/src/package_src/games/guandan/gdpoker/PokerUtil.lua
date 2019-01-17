-------------------------------------------------------------
--  @file   PokerUtil.lua
--  @brief  PokerLib Util
--  @author 徐志军
--  @DateTime:2018-06-28
--  Version: 1.0.0
--  Copyright  Copyright (c) 2018
--  Modigy:
--============================================================
local PokerUtil = {}

--解析服务器的返回的牌数据，解析成花点牌表
--元数据 oriCards
function PokerUtil.parseSvrData(oriCards)
	
	--组装牌结构
	local pokerTb = {}

	for i,v in ipairs(oriCards) do
		local b = v
		-- print(b)
		local poker = PokerUtil.parseSvrDataCard(b)
		-- Log.i("--wangzhi--poker--",poker)
		table.insert(pokerTb, poker)
	end

	-- wwdump(pokerTb, "pokerTb")

	return pokerTb
end

function PokerUtil.parseSvrDataCard(oriCard)
	local pokerNum = bit.band(oriCard, 0x0F) + 2 --牌值
	local color = bit.brshift(oriCard, 4)--math.floor(b / 16)
	local poker = {}
	poker.number = pokerNum --点数
	if color == enmCardShape.ECS_SHAPE_JOKER then
		if poker.number == 3 then
			poker.number = 16
		elseif poker.number == 4 then
			poker.number = 17
		end
	end
	poker.level = PokerUtil.setCardLevel(poker.number) --权重
	poker.shape = color --花色
	poker.kind = 0 --类型
	poker.originalVal = oriCard  --元牌值
	return poker
end

function PokerUtil.parseSvrData2(oriCards)
	Log.i("--wangzhi--转换之前的牌--",oriCards)
	
	--组装牌结构
	local pokerTb = {}

	for i,v in ipairs(oriCards) do
		local b = v
		-- print(b)

		local pokerNum = b % 16
		local color = math.floor(b / 16)
		local poker = {}
		poker.number = pokerNum --点数
		poker.level = PokerUtil.setCardLevel(pokerNum) --权重
		poker.shape = color --花色
		poker.kind = 0 --类型
		poker.originalVal = v  --元牌值
		table.insert(pokerTb, poker)
	end

	-- wwdump(pokerTb, "pokerTb")
	Log.i("--wangzhi--转换之后的牌--",pokerTb)

	return pokerTb
end


--默认权重排列
--不同规则可以在自行转换
function PokerUtil.setCardLevel(oldNum)
	local afterNum = 0
	
	if oldNum == enmCardNumber.ECN_NUM_NONE then
		afterNum = 0
	-- -- 现将2调换到最小,2为最小的牌
	elseif oldNum == enmCardNumber.ECN_NUM_2 then
		afterNum = oldNum - 12
	elseif oldNum == enmCardNumber.ECN_NUM_Joker then
		afterNum = oldNum
	elseif oldNum == enmCardNumber.ECN_NUM_JOKER then
		afterNum = oldNum
	else
		afterNum = oldNum
	end
	-- 然后集体减少2
	if RULESETTING.nLevelCard == 15 then
		afterNum = afterNum - 2
	elseif oldNum < RULESETTING.nLevelCard then
		afterNum = afterNum - 1
	elseif oldNum > RULESETTING.nLevelCard then
		afterNum = afterNum - 2
	end

	-- 这里RULESETTING.nLevelCard为自定义的掼蛋级牌概念。
	if oldNum == RULESETTING.nLevelCard then
		afterNum = 13
	end

	return afterNum
end

--选择牌面，字节转换 客户端牌型转换
--@param pokerData 元牌值
function PokerUtil.parseLocalData( pokerData )
	
	local serverNum = 0

	if pokerData.shape and pokerData.number then
		local shape = pokerData.shape
		local number = pokerData.number
		
		serverNum = shape * 16 + number
	end

	return serverNum
end

-- 获得解析后的牌列表中的Byte字节牌表
function PokerUtil.getBytePoker(pokerData)
    --解析返回
    local retTable = {}
    for i, v in ipairs(pokerData) do
        table.insert(retTable, v.originalVal)
    end
    return retTable
end

-- 获得解析后的牌列表中的Byte字节牌表
--oriPokeValue 扑克原始值
function PokerUtil.getSingleCardByOriValue(oriPokeValue)
	local paserEndCards = PokerUtil.parseSvrData({ oriPokeValue })
	if(#paserEndCards~=1) then
		return 
	end
    local retCard =paserEndCards[1]
    local tempcardBase = EntityFactoryInstance:CreateEntity('CardBase')
    tempcardBase:SetCard(retCard)
    return tempcardBase
end

--排序 大到小
function PokerUtil.cardDetectionBigToSmallSort( cardList )
	-- body
	--先排序一次
	if next(cardList) == nil then
		return
	end

	--从大到小排序
	table.sort( cardList, function (a,b)

		a.level = a.level or PokerUtil.serverToLocalNumber(a.pokerValue)
		b.level = b.level or PokerUtil.serverToLocalNumber(b.pokerValue)

		if a.level > b.level then
			return true
		elseif a.level < b.level then
			return false
		else
			-- return a.pokerColor < b.pokerColor --黑梅方红
			return a.pokerColor > b.pokerColor --黑梅方红
		end
	end )
end

--判断两个牌表是否相等(客户端格式值)
function PokerUtil.equalPokers(pokersA, pokersB)

	PokerUtil.cardDetectionBigToSmallSort(pokersA)
	PokerUtil.cardDetectionBigToSmallSort(pokersB)

	local isSame = true

	if #pokersA ~= #pokersB then
		isSame = false
	else
		for i=1, #pokersA do
			local cellPokerA = pokersA[i].originalVal
			local cellPokerB = pokersB[i].originalVal
			if cellPokerA ~= cellPokerB then
				isSame = false
			end
		end
	end
	return isSame
end

--将数组顺序打乱
function PokerUtil.shuffle(t)
    if type(t)~="table" then
        return
    end
    local l=#t
    local tab={}
    local index=1
    while #t~=0 do
        local n=math.random(0,#t)
        if t[n]~=nil then
            tab[index]=t[n]
            table.remove(t,n)
            index=index+1
        end
    end
    return tab
end

--派牌 不发好牌
--@return 洗牌后的扑克牌
function PokerUtil.deal()
	local pokers = {}

	for i=1, 4 do
		for j=1, 13 do
			local pokerNum = i * 16 + j
			-- print(pokerNum)
			table.insert(pokers, pokerNum)
		end
	end

	if RULESETTING.nHadJokers then
		table.insert(pokers, enmCardNumber.ECN_NUM_Joker)
		table.insert(pokers, enmCardNumber.ECN_NUM_JOKER)
	end

	return PokerUtil.shuffle(pokers)
end

--派牌 取得指定段的连续Array
--@return 一个连续的table 
function PokerUtil.getArrayByIndex(oriTable, nIndexStart, nIndexEnd)
	local pokers = {}

	for i=nIndexStart, #oriTable do
		if i <= nIndexEnd then
			table.insert(pokers, oriTable[i])
		end
	end

	return pokers
end

return PokerUtil