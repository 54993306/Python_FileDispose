--
-- 斗地主牌型分析
--
local GDPKCard = require("package_src.games.guandan.gdcommon.utils.card.GDPKCard")
local GDPKCardTypeAnalyzer = {}
local ddzRule = require("package_src.games.guandan.gdfuckFaster.GDGameRule"):new()

----------------------------------------------------------------
-- @desc 获取cards的牌的类型
-- @pram cards:待测牌型的牌
----------------------------------------------------------------
function GDPKCardTypeAnalyzer.getCardType(cards, lastCardType)
	if not cards or #cards <= 0 then
		return enmCardType.EBCT_TYPE_NONE,0
	end
	local obCards = {}
    for i,v in pairs(cards) do
        local card = GDPKCard.ConvertToserver(v)
        table.insert(obCards,card)
    end
    ddzRule:updateWanFa()
	local cardsType = ddzRule:GetCardType(obCards, lastCardType)
	return cardsType,cards[1]
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组中以startPos开始每相隔interval的count个数是不是一样的 333
-- @pram cards:牌组
--       startPos:起始下标
--       count:一共要判断的牌的张数
--       interval:以startPos 开始的牌的interval
--------------------------------------------------------------------------
function GDPKCardTypeAnalyzer.isAllSame(cards, startPos, count, interval)
	startPos = startPos or 1
	count = count or #cards
	interval = interval or 1

	local v = cards[startPos]
	for i = startPos + interval, startPos + count - 1, interval do
		if v ~= cards[i] then
			return false
		end
	end
	return true
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组中以startPos开始每相隔interval的count个数是不是单连 345678
-- @pram cards:牌组
--       startPos:起始下标
--       count:一共要判断的牌的张数
--       interval:以startPos 开始的牌的interval
--------------------------------------------------------------------------
function GDPKCardTypeAnalyzer.isLine(cards, startPos, count, interval)
	startPos = startPos or 1
	count = count or #cards
	interval = interval or 1
	local tmp = cards[startPos]
	for i = startPos + interval, startPos + count - 1, interval do
		if tmp + 1 ~= cards[i] then
			return false
		end
		tmp = cards[i]
	end
	if count > interval and tmp >= 15 then
	    return false
	end
	return true
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组中以startPos开始每相隔interval的count个数是不是多连 334455667788  333444555666777888
-- @pram cards:牌组
--       startPos:起始下标
--       count:一共要判断的牌的张数
--       nLines:多少张牌
--------------------------------------------------------------------------
function GDPKCardTypeAnalyzer.isMultiLine(cards, startPos, count, nLines)
    for i = startPos, count + startPos - 1, nLines do
		if not GDPKCardTypeAnalyzer.isAllSame(cards, i, nLines) then
			return false
		end
	end
	if not GDPKCardTypeAnalyzer.isLine(cards, startPos, count, nLines) then
		return false
	end
	return true
end

function GDPKCardTypeAnalyzer.isError()
	return true
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否单牌
-- @pram cards:牌组
--------------------------------------------------------------------------
function GDPKCardTypeAnalyzer.isSingle(cards)
	return true, cards[1]
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否对子
-- @pram cards:牌组
--------------------------------------------------------------------------
function GDPKCardTypeAnalyzer.isDouble(cards)
	return GDPKCardTypeAnalyzer.isAllSame(cards), cards[1]
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否三个
-- @pram cards:牌组
--------------------------------------------------------------------------
function GDPKCardTypeAnalyzer.isThree(cards)
	return GDPKCardTypeAnalyzer.isAllSame(cards), cards[1]
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否单连
-- @pram cards:牌组
--------------------------------------------------------------------------
function GDPKCardTypeAnalyzer.isOneLine(cardsType)
	local boolean = false
	if cardsType ~= enmCardType.EBCT_BASETYPE_SINGLE 
		and cardsType ~= enmCardType.EBCT_BASETYPE_PAIR
		and cardsType ~= enmCardType.EBCT_BASETYPE_3KIND
		and cardsType ~= enmCardType.EBCT_BASETYPE_3AND2 then
			boolean = true
		end
	return boolean
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否三带一对
-- @pram cards:牌组
--------------------------------------------------------------------------
function GDPKCardTypeAnalyzer.isThreeLineTakeDouble(cards)
	--首先判断是不是5的倍数
	if #cards%5 ~= 0 then
		return false
	end
    local n = #cards/5
    for i = 1, n*2 + 1, 2 do
        if GDPKCardTypeAnalyzer.isMultiLine(cards, i, n*3, 3) then
            for j = 1, i - 1, 2 do
                if not GDPKCardTypeAnalyzer.isAllSame(cards, j, 2, 1) then
                    return false
                end
            end
            for j = i + n*3, #cards, 2 do
                if not GDPKCardTypeAnalyzer.isAllSame(cards, j, 2, 1) then
                    return false
                end
            end
            return true, cards[i]
       end
   end
   return false
end
-------------------------------------------------------
-- @desc 添加牌到类中
-- @pram cards :要添加的牌一般是自己手牌
-- return 无
-------------------------------------------------------
function GDPKCardTypeAnalyzer:add(cards)
	if not cards then
		return;
	end

	local arrv = {};
	local arrn = {};
	for _, v in pairs(cards) do 
		local n = arrv[v] or 0;
		if arrn[n] and arrn[n][v] then
		    arrn[n][v] = nil;
		end
		
	    arrv[v] = n + 1;
        arrn[n + 1] = arrn[n+1] or {};
        arrn[n + 1][v] = true; 
	end
	return arrv,arrn 
end


--------------------------------------------------------------------------
-- @desc 判断cards牌组是否炸弹
-- @pram cards:牌组
--------------------------------------------------------------------------
function GDPKCardTypeAnalyzer.isBomb(cards)
	return GDPKCardTypeAnalyzer.isAllSame(cards), cards[1]
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否火箭
-- @pram cards:牌组
--------------------------------------------------------------------------
function GDPKCardTypeAnalyzer.isMissile(cards)
	if cards[1] == 29 and cards[2] == 30 then
		return true
	end
end


--此处判断是否是两个炸弹连着的
function GDPKCardTypeAnalyzer.isDoubleFourLine(cards)
	-- body
	local n = #cards
	local n1 = 1
	local isOneFour = false
	local isDoubleFour = false
	if n>=8 then
		for i=1,n-3 do
			n1 = i
			if GDPKCardTypeAnalyzer.isAllSame(cards,i,4) then
				n1 = i + 4
				isOneFour = true
				break
			end
		end
		if n - n1 <3 then
			return false
		end

		for i=n1,n-3 do
			if GDPKCardTypeAnalyzer.isAllSame(cards,i,4) then
				isDoubleFour = true
				break
			end
		end
		if isOneFour and isDoubleFour then
			return true
		end
	end
	return false
end

return GDPKCardTypeAnalyzer