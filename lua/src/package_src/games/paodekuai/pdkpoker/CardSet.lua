-------------------------------------------------------------
--  @file   Cards.lua
--  @brief  主要手牌的操作，是一个容器类
--  @author 徐志军
--  @DateTime:2018-06-27
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2018
--  Modigy:
--  2018-06-28 diyal.yin 实现一些基本API
--============================================================

local CardSet = class("package_src.games.paodekuai.pdkpoker.CardSet")

PokerUtil = require("package_src.games.paodekuai.pdkpoker.PokerUtil")
local NUM_CHAR_LEN = 128

-- 函数功能：   构造函数
-- 返回值：     无
function CardSet:ctor()
    --self.logTag = self.__cname..".lua"
    -- wwlog(self.logTag, "CardSet Init")
    self.m_nCurrentLength = 0

	--用来根据点数统计牌的张数信息。如：m_arrCardCount[ECN_NUM_K] == 2，表示K有2张
	self.m_arrCardCount = {}

	local CARD = require("package_src.games.paodekuai.pdkpoker.Card"):new()

	self.m_Cards = {}
	-- for i=1, MAX_CARDS_LEN do
	-- 	table.insert(self.m_Cards, CARD)
	-- end
end

--函数功能：	清理所有值
--返回值：		无
function CardSet:ClearAll()
	self.m_nCurrentLength = 0
	self.m_arrCardCount = {}
	self.m_Cards = {}
end

--函数功能：     给操作对象添加一张牌
--card：        被添加的牌(解析后的牌值)
--返回值：       添加成功返回为TRUE，否则返回FALSE
function CardSet:AddCard(card)
	local bSucc = false

	if (self.m_nCurrentLength < MAX_CARDS_LEN) then
		if ((card.shape >= enmCardShape.ECS_SHAPE_DIAMONDS and card.shape <= enmCardShape.ECS_SHAPE_SPADE
             and card.number >= enmCardNumber.ECN_NUM_A and card.number <= enmCardNumber.ECN_NUM_JOKER)
            or (enmCardShape.ECS_SHAPE_NONE == card.shape 
                and (enmCardNumber.ECN_NUM_Joker == card.number or enmCardNumber.ECN_NUM_JOKER == card.number)) 
            or enmCardNumber.ECN_NUM_NONE == card.number ) then
		    self.m_nCurrentLength = self.m_nCurrentLength + 1
		    self.m_Cards[self.m_nCurrentLength] = card
		    bSucc = true
        end
	end
	return bSucc
end

--函数功能：     给操作对象添加一张牌
--cards         解析后的Card集合
--返回值：       添加成功返回为TRUE，否则返回FALSE
function CardSet:AddCards(cards)
	local bSucc = false

	for i=1, #cards do
		self:AddCard(cards[i])
	end
	return bSucc
end

--函数功能：     给操作对象添加一张牌
--cards         元Card集合
--返回值：       添加成功返回为TRUE，否则返回FALSE
function CardSet:AddOriCards(cards)
	local bSucc = false
	local paserEndCards = PokerUtil.parseSvrData(cards)

	for i,v in ipairs(paserEndCards) do
		local CARD = require("package_src.games.paodekuai.pdkpoker.Card"):new()
		CARD:setCard(v)
		self:AddCard(CARD)
	end
	return bSucc
end

--函数功能：     删除对象中给oriValue的牌 只针对单付牌
--nIndex：      要删除牌所在的位置
function CardSet:DelCardByOriValue(oriValue)

    local resltIndex = 0
    for i = 1, self.m_nCurrentLength do
        if self.m_Cards[i].originalVal == oriValue then
            resltIndex = i
            break
        end
    end
    if (0 ~= resltIndex) then
        self:DelCard(resltIndex)
    end
end

--函数功能：     删除对象中给定索引号的牌
--nIndex：      要删除牌所在的位置
function CardSet:DelCard(nIndex)
	if (nIndex >= 0) and (nIndex <= self.m_nCurrentLength) then
		table.remove( self:GetCards(),nIndex)
		self.m_nCurrentLength = self.m_nCurrentLength - 1
	end
end

--函数功能：     获取所有牌对象
--返回值：       
function CardSet:Card(nIndex)
	if (nIndex < 1) or (nIndex > #self.m_Cards) then
		return nil
	end
	return self.m_Cards[nIndex]
end

--函数功能：     获取所有牌对象
--返回值：       
function CardSet:GetCards()
	return self.m_Cards
end

--函数功能：     获取所有元值 
--返回值：       
function CardSet:GetOriCards()
	return self.m_Cards
end

--函数功能：     获得操作对象中有效牌对象的长度
--返回值：       当前有效对象长度
function CardSet:CurrentLength()
	return self.m_nCurrentLength
end

--函数功能：     查询操作对象的最大存储空间
--返回值：       最大存储空间
function CardSet:Capacity()
	return MAX_CARDS_LEN
end

--函数功能：     查询操作对象是否为同一花色
--返回值：       是否相同true/false
function CardSet:IsSameShape()
local reslt = true
for i = 1, self.m_nCurrentLength do
    -- wwdump(self.m_Cards[i])
    if self.m_Cards[i].shape ~= self.m_Cards[1].shape then
        reslt = false
        break
    end
end
return reslt
end

--函数功能：     查询操作对象是否为同一类型 类型可以任意设置
--返回值：       是否相同true/false
function CardSet:IsSameKind()
	local reslt = true
	for i=1, self.m_nCurrentLength do
		if self.m_Cards[i].kind ~= self.m_Cards[1].kind then
			reslt = false
			break
		end
	end
	return reslt
end

--函数功能：     查询操作对象是否为同一颜色 例如红桃和方块为同一颜色
--返回值：       是否相同true/false
function CardSet:IsSameColor()
	local reslt = true
	for i=1, self.m_nCurrentLength do
		if (self.m_Cards[i].shape - self.m_Cards[1].shape) % 2 ~= 0 then
			reslt = false
			break
		end
	end
	return reslt
end

--函数功能：     查询操作对象中点数为number的牌的个数
--number:       给定牌的点数
--返回值：       操作对象中点数为给定值的牌对象的个数
function CardSet:CountNum(number)
	local counter = 0
	local save = {}
	for i=1, self.m_nCurrentLength do
		if self.m_Cards[i].number == number then
			counter = counter + 1
			table.insert(save, self.m_Cards[i])
		end
	end
	return save, counter
end

--函数功能：     查询操作对象中给定类型牌的个数
--cKind:        给定牌的类型（主或非主）
--返回值：       操作对象中点数为给定值的牌对象的个数
function CardSet:CountByKind(cKind)
	local counter
	for i=1, self.m_nCurrentLength do
		if self.m_Cards[i].kind == cKind then
			counter = counter + 1
		end
	end
	return counter
end

--函数功能：     根据点数统计操作对象中大于或等于给定张数的牌的点数
--nCount:       给定张数
--nSize:		存储数组的维度(eg:找到N个只需要取得nSize个)
--mod:          模式
-- 取值为0时，将张数等于nCount的牌的点数return
-- 取值为1时，将张数大于等于nCount的牌的点数return
--返回值：       save 符合上述条件的牌的个数
function CardSet:StateCountsByNumber(nCount, nSize, mod)
	nCount = nCount or 0
	nSize = nSize or 0
	mod = mod or 0

	local save = {}

	for i=1, self.m_nCurrentLength do
		if (self.m_Cards[i].number >= 0) and (self.m_Cards[i].number < COUNT_CARDNUM) then
			local lastNumber = self.m_arrCardCount[self.m_Cards[i].number] or 0
			self.m_arrCardCount[self.m_Cards[i].number] = lastNumber + 1 --统计同一点数牌的张数，可能会重复操作
		end
	end

	local counter = 0
	--统计点数相同牌的张数为nCount的信息
	if nCount > 0 then
		for i,v in pairs(self.m_arrCardCount) do --i=1, table.nums(self.m_arrCardCount) do -- i = 1 ,不计nuber = 0的情况
			if ((mod == 0) and (self.m_arrCardCount[i] >= nCount)) 
				or ((mod == 1) and (self.m_arrCardCount[i] == nCount)) then
				counter = counter + 1
				if save and counter < nSize then
					save[counter] = i
				end
			end
		end
	end
	return save, counter
end

--函数功能：     根据权值统计操作对象中大于或等于给定张数的牌的权重
--nCount:       给定张数
--nSize:		存储数组的维度
--mod:          模式
-- 取值为0时，将张数等于nCount的牌的点数return
-- 取值为1时，将张数大于等于nCount的牌的点数return
--返回值：       save 符合上述条件的牌的个数
function CardSet:StateCountsByLevel(nCount, nSize, mod)
	nCount = nCount or 0
	nSize = nSize or 0
	mod = mod or 0

	local save = {}
	local counter = 0
	local shCount = {}
	for i=1, self.m_nCurrentLength do
		if (self.m_Cards[i].level < NUM_CHAR_LEN) and (self.m_Cards[i].level >= 0) then
			local lastLevel = shCount[self.m_Cards[i].level] or 0
			shCount[self.m_Cards[i].level] = lastLevel + 1 --统计同一权值牌的张数,可能会重复操作
		end
	end

	-- wwdump(shCount, "shCount:")

	--统计点数相同牌的张数为nCount的信息
	if nCount > 0 then
		for i,v in pairs(shCount) do --i=1, table.nums(self.m_arrCardCount) do -- i = 1 ,不计nuber = 0的情况
			if ((mod == 0) and (shCount[i] >= nCount)) 
				or ((mod == 1) and (shCount[i] == nCount)) then
				counter = counter + 1
				if save and counter < nSize then
					save[counter] = i
				end
			end
		end
	end
	return save, counter
end

--函数功能：     根据牌(元)值统计操作对象中大于或等于给定张数的牌的点数（两副牌的时候用的比较多）
--nCount:       给定张数
--nSize:		存储数组的维度
--mod:          模式
-- 取值为0时，将张数等于nCount的牌的点数return
-- 取值为1时，将张数大于等于nCount的牌的点数return
--返回值：       save 符合上述条件的牌的个数
function CardSet:StateCountsByValue(nCount, nSize, mod)
	nCount = nCount or 0
	nSize = nSize or 0
	mod = mod or 0

	local save = {}
	local counter = 0
	local shCount = {}
	local cValue = 0

	for i=1, self.m_nCurrentLength do
		cValue = self.m_Cards[i].originalVal
		print(cValue)
		if cValue then
			shCount[cValue] = (shCount[cValue] or 0) + 1
		end
	end

	if nCount > 0 then
		for i,v in pairs(shCount) do 
			if ((mod == 0) and (shCount[i] >= nCount)) 
				or ((mod == 1) and (shCount[i] == nCount)) then
				counter = counter + 1
				if save and counter < nSize then
					save[counter] = i
				end
			end
		end
	end
	return save, counter
end

--@brief 交换操作对象给定序列号牌的位置 交换后不会影响其他牌的序列号
function CardSet:Swap(iIndex, jIndex)
	if iIndex == jIndex or iIndex < 0 or jIndex < 0 or iIndex >= self.m_nCurrentLength or jIndex >= self.m_nCurrentLength then
		return
	end
	local tCard = self.m_Cards[iIndex]
	self.m_Cards[iIndex] = self.m_Cards[jIndex]
	self.m_Cards[jIndex] = self.m_Cards[iIndex]
end

--函数功能：     判断给定牌集是否为操作对象的子集
--obCards:          给定的比较牌集对象
--mod:          排序模式
--取值为0，获取所有牌中最小的level
--取值为1，获取单张中最小的level
--返回值：       BOOL, 符合条件的牌集
function CardSet:IsSubset(obCards, mod)
	if not mod then
		mod = 0
	end
	local reslt = true

	local saveCards = {}

	if (obCards:CurrentLength() > 0) and (obCards:CurrentLength() <= self.m_nCurrentLength) then
		local i, j = 0, 0
		if mod == 0 then
			--TODO 排序
			self:StateCountsByNumber()
			obCards:StateCountsByNumber()

			-- for i=1, COUNT_CARDNUM do
			for i,v in pairs(obCards.m_arrCardCount) do
				if (obCards.m_arrCardCount[i] or 0) > (self.m_arrCardCount[i] or 0) then
					reslt = false
					break
				end
			end
			local table = {}
			if reslt then
				if self.m_nCurrentLength == obCards:CurrentLength() then
					saveCards = self:GetCards()
				else
					local dupCards = self

					for ii=1, obCards:CurrentLength() do
						for jj=1, dupCards:CurrentLength() do
							if obCards.m_Cards[ii].number ~= dupCards.m_Cards[jj].number then
								table.insert( saveCards, dupCards.m_Cards[jj])
							end
						end
					end
				end
			end
		end
	end
	return saveCards or self:GetCards()
end

--函数功能：	综合排序函数
--mod：		   模式
--			  (取值为0时，按权值level(不考虑花色)降序排列(相同权值level内按类型kind升序排列)）
--			  (取值为1时，按同一点数number牌的张数降序排列(相同张数内按权值level降序排列);
--			  (取值为2时，按类型kind值升序排列(相同类型kind内按权值level降序排列)
function CardSet:SortCards(mod)
	if 0 == self.m_nCurrentLength then
		return
	end
	if 0 == mod then
		self:SortByLevel()
	elseif 1 == mod then
		self:SortByNumer()
	elseif 2 == mod then
		self:SortByKind()
	end
end

--函数功能：	根据权值level排序函数
--mod:		   排序模式
--				(取值为0时，按权值level(考虑花色)升序排列)
--				(取值为1时，按权值level(考虑花色)降序排列)
function CardSet:SortByLevel(mod)

mod = mod or 0
if 0 == mod then
    table.sort(self:GetCards(), function(a, b)
        a.level = a.level or PokerUtil.setCardLevel(a.pokerValue)
        b.level = b.level or PokerUtil.setCardLevel(b.pokerValue)

        if a.level > b.level then
            return false
        elseif a.level < b.level then
            return true
        else
            -- return a.pokerColor < b.pokerColor --黑梅方红
            return a.shape > b.shape --黑梅方红
        end
    end)
elseif 1 == mod then
    table.sort(self:GetCards(), function(a, b)
        a.level = a.level or PokerUtil.setCardLevel(a.pokerValue)
        b.level = b.level or PokerUtil.setCardLevel(b.pokerValue)
        if a.level > b.level then
            return true
        elseif a.level < b.level then
            return false
        else
            return a.shape > b.shape --黑梅方红
        end
    end)
end
end

--函数功能：	根据类型number排序函数
--mod:		   排序模式
--				（取值为0时，按number 值升序排列）
--				（取值为1时，按number 值降序排列）
function CardSet:SortByNumer(mod)
	if not mod then
		mod = 0
	end
	if 0 == mod then
		table.sort( self:GetCards(), function (a,b)
			a.number = a.number or PokerUtil.setCardLevel(a.pokerValue)
			b.number = b.number or PokerUtil.setCardLevel(b.pokerValue)
	
			if a.number > b.number then
				return false
			elseif a.number < b.number then
				return true
			else
				-- return a.pokerColor < b.pokerColor --黑梅方红
				return a.shape > b.shape --黑梅方红
			end
		end )
	elseif 1 == mod then
		table.sort( self:GetCards(), function(a,b)
			a.number = a.number or PokerUtil.setCardLevel(a.pokerValue)
			b.number = b.number or PokerUtil.setCardLevel(b.pokerValue)
			if a.number > b.number then
				return true
			elseif a.number < b.number then
				return false
			else
				return a.shape > b.shape --黑梅方红
			end
		end)
	end
end

--函数功能：	根据类型kind排序函数
--mod:		   排序模式
--				（取值为0时，按kind 值升序排列）
--				（取值为1时，按kind 值降序排列）
function CardSet:SortByKind(mod)
	if not mod then
		mod = 0
	end
	if 0 == mod then
		table.sort( self:GetCards(), function (a,b)
			a.kind = a.kind or PokerUtil.setCardLevel(a.pokerValue)
			b.kind = b.kind or PokerUtil.setCardLevel(b.pokerValue)
	
			if a.kind > b.kind then
				return false
			elseif a.kind < b.kind then
				return true
			else
				-- return a.pokerColor < b.pokerColor --黑梅方红
				return a.shape > b.shape --黑梅方红
			end
		end )
	elseif 1 == mod then
		table.sort( self:GetCards(), function(a,b)
			a.kind = a.kind or PokerUtil.setCardLevel(a.pokerValue)
			b.kind = b.kind or PokerUtil.setCardLevel(b.pokerValue)
			if a.kind > b.kind then
				return true
			elseif a.kind < b.kind then
				return false
			else
				return a.shape > b.shape --黑梅方红
			end
		end)
	end
end

return CardSet