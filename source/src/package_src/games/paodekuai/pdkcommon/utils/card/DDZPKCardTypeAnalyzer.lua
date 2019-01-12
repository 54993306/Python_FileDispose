--
-- 斗地主牌型分析
--
local DDZPKCard = require("package_src.games.paodekuai.pdkcommon.utils.card.DDZPKCard")
local DDZPKCardTypeAnalyzer = {}
local ddzRule = require("package_src.games.paodekuai.pdkfuckFaster.PDKGameRule"):new()

----------------------------------------------------------------
-- @desc 获取cards的牌的类型
-- @pram cards:待测牌型的牌
----------------------------------------------------------------
function DDZPKCardTypeAnalyzer.getCardType(cards)
	if not cards or #cards <= 0 then
		return enmCardType.EBCT_TYPE_NONE,0
	end
	local obCards = {}
    for i,v in pairs(cards) do
        local card = DDZPKCard.ConvertToserver(v)
        table.insert(obCards,card)
    end
	local cardsType = ddzRule:GetobCardsType(obCards)
	return cardsType,cards[1]
end

----------------------------------------------------------------
-- @desc 选牌是否符合规则
-- @pram myCards:自己选择的牌
-- 		 lastCards:上手牌
-- 		 lastType:上手牌的类型
--		 lastKeyCard:上手牌的关键牌
----------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isLegal(myCards, lastCards, lastType, lastKeyCard)
	local cardType, keyCard = DDZPKCardTypeAnalyzer.getCardType(myCards)

	if cardType == DDZPKCard.CT_ERROR then
		return false, cardType
	end

	if not lastCards or #lastCards == 0 then
		return true, cardType
	end

	local cardType2, keyCard2
	if lastType or lastType == 0 or not lastKeyCard then
		table.sort(lastCards)
		cardType2, keyCard2 = DDZPKCardTypeAnalyzer.TypeFuncMap[lastType](lastCards)
		cardType2 = cardType2 and lastType or cardType2
		print("<mzd  DDZPKCardTypeAnalyzer.isLegal **********************>")
		dump(cardType2)
		dump(keyCard2)
	else
		cardType2 = lastType
		keyCard2 = lastKeyCard
	end

	if cardType >= DDZPKCard.CT_BOMB and cardType2 < cardType then
		return true, cardType
	end

	if cardType == cardType2 then
		if #myCards ~= #lastCards then
			return false, cardType
		end

		if keyCard > keyCard2 then
			if cardType == DDZPKCard.CT_THREE_LINE then --三连特殊判断
				if DDZPKCardTypeAnalyzer.isSameAirPlane(lastCards,myCards) then
					return true
				else
					return false
				end
			end
			return true, cardType
		else
			return false, cardType
		end
	end

	return false, cardType
end


--------------------------------------------------------------------------
-- @desc 判断cards牌组中以startPos开始每相隔interval的count个数是不是一样的 333
-- @pram cards:牌组
--       startPos:起始下标
--       count:一共要判断的牌的张数
--       interval:以startPos 开始的牌的interval
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isAllSame(cards, startPos, count, interval)
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
function DDZPKCardTypeAnalyzer.isLine(cards, startPos, count, interval)
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
function DDZPKCardTypeAnalyzer.isMultiLine(cards, startPos, count, nLines)
    for i = startPos, count + startPos - 1, nLines do
		if not DDZPKCardTypeAnalyzer.isAllSame(cards, i, nLines) then
			return false
		end
	end
	if not DDZPKCardTypeAnalyzer.isLine(cards, startPos, count, nLines) then
		return false
	end
	return true
end

function DDZPKCardTypeAnalyzer.isError()
	return true
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否单牌
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isSingle(cards)
	return true, cards[1]
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否对子
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isDouble(cards)
	return DDZPKCardTypeAnalyzer.isAllSame(cards), cards[1]
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否三个
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isThree(cards)
	return DDZPKCardTypeAnalyzer.isAllSame(cards), cards[1]
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否单连
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isOneLine(cardsType)
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
-- @desc 判断cards牌组是否双连
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isDoubleLine(cards)
	return DDZPKCardTypeAnalyzer.isMultiLine(cards, 1, #cards, 2), cards[1]
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否三连
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isAirPlaneTakeNone(cards)
	-- 判断是否为4的倍数
	if #cards%3 ~= 0 then
		return false
	end
	-- --特殊判断 777788889999可以是飞机
	-- if #cards > 8 then
	-- 	if DDZPKCardTypeAnalyzer.isMultiLine(cards, 1, #cards, 4) then
	-- 		return DDZPKCardTypeAnalyzer.isMultiLine(cards, 1, #cards, 4), cards[1]
	-- 	end
	-- end

	return DDZPKCardTypeAnalyzer.isMultiLine(cards, 1, #cards, 3), cards[1],DDZPKCard.CT_THREE_LINE
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否三带一单
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isThreeLineTakeOne(cards)
	-- 判断是否为4的倍数
	if #cards%4 ~= 0 then
		return false
	end
    local n = #cards/4
	for i = 1, n+1 do
		if DDZPKCardTypeAnalyzer.isMultiLine(cards, i, n*3, 3) then --cards, startPos, count, nLines
			return true, cards[i]
		end
	end
	return false
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否三带一对
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isThreeLineTakeDouble(cards)
	--首先判断是不是5的倍数
	if #cards%5 ~= 0 then
		return false
	end
    local n = #cards/5
    for i = 1, n*2 + 1, 2 do
        if DDZPKCardTypeAnalyzer.isMultiLine(cards, i, n*3, 3) then
            for j = 1, i - 1, 2 do
                if not DDZPKCardTypeAnalyzer.isAllSame(cards, j, 2, 1) then
                    return false
                end
            end
            for j = i + n*3, #cards, 2 do
                if not DDZPKCardTypeAnalyzer.isAllSame(cards, j, 2, 1) then
                    return false
                end
            end
            return true, cards[i]
       end
   end
   return false
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否四带一单
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isFourLineTakeOne(cards)
	for i = 1, 3 do
		if DDZPKCardTypeAnalyzer.isAllSame(cards, i, 4) then
			return true, cards[i]
		end
	end
	return false
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否四带一对
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isFourLineTakeDouble(cards)
	--88889999  <  3333AAAA
	-- if DDZPKCardTypeAnalyzer.isAllSame(cards, 1, 4) and DDZPKCardTypeAnalyzer.isAllSame(cards, 5, 4) then
	-- 	return true, cards[1] > cards[5] and cards[1] or cards[5]
	-- end	
	-- 这里将判断改了，改成了飞机
	if DDZPKCardTypeAnalyzer.isAllSame(cards, 1, 4) and DDZPKCardTypeAnalyzer.isAllSame(cards, 5, 4) then
		return false
	end	

	if DDZPKCardTypeAnalyzer.isAllSame(cards, 1, 4) and DDZPKCardTypeAnalyzer.isAllSame(cards, 5, 2) and DDZPKCardTypeAnalyzer.isAllSame(cards, 7, 2) then
		return true, cards[1]
	end

	if DDZPKCardTypeAnalyzer.isAllSame(cards, 1, 2) and DDZPKCardTypeAnalyzer.isAllSame(cards, 3, 4) and DDZPKCardTypeAnalyzer.isAllSame(cards, 7, 2) then
		return true, cards[3]
	end

	if DDZPKCardTypeAnalyzer.isAllSame(cards, 1, 2) and DDZPKCardTypeAnalyzer.isAllSame(cards, 3, 2) and DDZPKCardTypeAnalyzer.isAllSame(cards, 5, 4) then
		return true, cards[5]
	end

	return false
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否飞机
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isThreeLine(cards)
	Log.i("--wangzhi--进入三连的判断--",cards)

	--飞机带一个
	if DDZPKCardTypeAnalyzer.isAirPlaneTakeSingle(cards) then
		Log.i("--wangzhi--判断三连带一张--")
		return DDZPKCardTypeAnalyzer.isAirPlaneTakeSingle(cards)
	end

	--三连 飞机不带
	if DDZPKCardTypeAnalyzer.isAirPlaneTakeNone(cards) then
		Log.i("--wangzhi--判断三连不带--")
		return DDZPKCardTypeAnalyzer.isAirPlaneTakeNone(cards)
	end


	--飞机带一对
	if DDZPKCardTypeAnalyzer.isAirPlaneTakeDouble(cards) then
		Log.i("--wangzhi--判断三连带一对--")
		return DDZPKCardTypeAnalyzer.isAirPlaneTakeDouble(cards)
	end

	-- 2个炸弹组合出
	if DDZPKCardTypeAnalyzer.isAllSame(cards, 1, 4) and DDZPKCardTypeAnalyzer.isAllSame(cards, 5, 4) then
		return DDZPKCardTypeAnalyzer.isAirPlaneTakeSingle(cards)
	end	

	return false
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否飞机带一个 34445556
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isAirPlaneTakeSingle(cards)
	local nGroup = #cards / 4

	Log.i("飞机带一个nGroup", nGroup)
	if nGroup <= 1  then
		return false
	end
	local more = #cards%4
	Log.i("more", more)

	if more ~= 0 then
		return false
	end

	local valueCountMap = DDZPKCardTypeAnalyzer:add(cards)
	Log.i("valueCountMap001", valueCountMap)
	for k,v in pairs(valueCountMap) do
		for i=1, nGroup do
			Log.i("i ", i)
			if not valueCountMap[k+i-1] then
				break
			end
			if valueCountMap[k+i-1] < 3 then
				break
			else
				if (k+i-1) >= 15 then
					break
				end
			end

			if i == nGroup  then
				return true, k,DDZPKCard.CT_THREE_LINE_TAKE_ONE
			end
		end
	end
	return false
end


--------------------------------------------------------------------------
-- @desc 判断cards牌组是否飞机带一对 3344455566
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isAirPlaneTakeDouble(cards)
	
	local nGroup = #cards / 5

	Log.i("飞机带一对nGroup", nGroup)
	if nGroup <= 1  then
		return false
	end
	local more = #cards%5
	Log.i("more", more)

	if more ~= 0 then
		return false
	end

	--检查剩下的牌是不是对子
	local function checkLeftDouble(leftValueCountMap)
		for k,v in pairs(leftValueCountMap) do
			if v ==1 or v == 3 then
				return false
			end
		end
		return true
	end

	local valueCountMap = DDZPKCardTypeAnalyzer:add(cards)
	local leftValueCountMap = clone(valueCountMap)  --去除飞机主体后剩下的牌
	Log.i("valueCountMap002", valueCountMap)
	for k,v in pairs(valueCountMap) do
		for i=1, nGroup do
			Log.i("--wangzhi--k--i--", k,i)
			local value = k+i-1 
			if not valueCountMap[value] then
				break
			end
			if valueCountMap[value] ~= 3 then
				break
			end

			if i == nGroup  then
				--判断去除主体后剩下的牌是不是对子
				for j=1, nGroup do
					local mainAir = k+j-1
					leftValueCountMap[mainAir] = leftValueCountMap[mainAir] - 3
				end
				if checkLeftDouble(leftValueCountMap) then
					return true, k,DDZPKCard.CT_THREE_LINE_TAKE_DOUBLE
				end
			end
		end
	end
	return false
end

--------------------------------------------------------------------------
-- @desc 获取飞机本牌数量 3344455566  ->444555
-- @pram cards:牌组 
-- return  本牌数量
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.getAirPlaneBaseCards(cards)
	local valueCountMap = DDZPKCardTypeAnalyzer:add(cards)
	local num = 0
	Log.i("DDZPKCardTypeAnalyzer.getAirPlaneBaseCards", valueCountMap)
	for k,v in pairs(valueCountMap) do
		if valueCountMap[k] >= 3 and k < 15 then
			num  = num + 1
		end
	end
	-- Log.i(" 获取飞机本牌数量",num)

	return num
end

--------------------------------------------------------------------------
-- @desc 判断是否相同类型飞机 3344455566  6677788899
-- @pram cards:牌组
-- @pram newCards:牌组
-- return  true 相同，fasle 不同
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isSameAirPlane(cards,newCards)

	--三连 飞机不带
	if DDZPKCardTypeAnalyzer.isAirPlaneTakeNone(cards) and DDZPKCardTypeAnalyzer.isAirPlaneTakeNone(newCards) then
		if DDZPKCardTypeAnalyzer.getAirPlaneBaseCards(newCards) == DDZPKCardTypeAnalyzer.getAirPlaneBaseCards(cards) then
			return true
		end
	end

	--飞机带一个
	if DDZPKCardTypeAnalyzer.isAirPlaneTakeSingle(cards) and DDZPKCardTypeAnalyzer.isAirPlaneTakeSingle(newCards) then
		Log.i("isSameAirPlane---is one")
		-- Log.i("isSameAirPlane--22-is one",DDZPKCardTypeAnalyzer.getAirPlaneBaseCards(newCards))
		-- Log.i("isSameAirPlane--33-is one",DDZPKCardTypeAnalyzer.getAirPlaneBaseCards(cards))

		-- +1兼容 333444555666和677788899922这种情况
		if DDZPKCardTypeAnalyzer.getAirPlaneBaseCards(newCards) + 1 >= DDZPKCardTypeAnalyzer.getAirPlaneBaseCards(cards) then
			return true
		end
	end

	--飞机带一对
	if DDZPKCardTypeAnalyzer.isAirPlaneTakeDouble(cards) and DDZPKCardTypeAnalyzer.isAirPlaneTakeDouble(newCards) then
		Log.i("isSameAirPlane---is double")
		if DDZPKCardTypeAnalyzer.getAirPlaneBaseCards(newCards) + 1 >= DDZPKCardTypeAnalyzer.getAirPlaneBaseCards(cards) then
			return true
		end
	end

	return false
end

-------------------------------------------------------
-- @desc 添加牌到类中
-- @pram cards :要添加的牌一般是自己手牌
-- return 无
-------------------------------------------------------
function DDZPKCardTypeAnalyzer:add(cards)
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
function DDZPKCardTypeAnalyzer.isBomb(cards)
	return DDZPKCardTypeAnalyzer.isAllSame(cards), cards[1]
end

--------------------------------------------------------------------------
-- @desc 判断cards牌组是否火箭
-- @pram cards:牌组
--------------------------------------------------------------------------
function DDZPKCardTypeAnalyzer.isMissile(cards)
	if cards[1] == 29 and cards[2] == 30 then
		return true
	end
end


--此处判断是否是两个炸弹连着的
function DDZPKCardTypeAnalyzer.isDoubleFourLine(cards)
	-- body
	local n = #cards
	local n1 = 1
	local isOneFour = false
	local isDoubleFour = false
	if n>=8 then
		for i=1,n-3 do
			n1 = i
			if DDZPKCardTypeAnalyzer.isAllSame(cards,i,4) then
				n1 = i + 4
				isOneFour = true
				break
			end
		end
		if n - n1 <3 then
			return false
		end

		for i=n1,n-3 do
			if DDZPKCardTypeAnalyzer.isAllSame(cards,i,4) then
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

----------------------------------------------------------------------------------------

DDZPKCardTypeAnalyzer.NumFuncMap =
{
	[1] 	= {DDZPKCardTypeAnalyzer.isSingle},
	[2] 	= {DDZPKCardTypeAnalyzer.isDouble, DDZPKCardTypeAnalyzer.isMissile},
	[3] 	= {DDZPKCardTypeAnalyzer.isThree},
	[4] 	= {DDZPKCardTypeAnalyzer.isBomb, DDZPKCardTypeAnalyzer.isThreeLineTakeOne},
	[5] 	= {DDZPKCardTypeAnalyzer.isThreeLineTakeDouble},
	[6] 	= {DDZPKCardTypeAnalyzer.isFourLineTakeOne, DDZPKCardTypeAnalyzer.isThreeLine, DDZPKCardTypeAnalyzer.isDoubleLine},
	[7] 	= {DDZPKCardTypeAnalyzer.isError},
	[8] 	= {DDZPKCardTypeAnalyzer.isFourLineTakeDouble, DDZPKCardTypeAnalyzer.isThreeLineTakeOne, DDZPKCardTypeAnalyzer.isDoubleLine},
	[25] 	= {DDZPKCardTypeAnalyzer.isThreeLine}, --5
	[20] 	= {DDZPKCardTypeAnalyzer.isThreeLine, DDZPKCardTypeAnalyzer.isDoubleLine}, --4
	-- [15] 	= {DDZPKCardTypeAnalyzer.isThreeLineTakeDouble,DDZPKCardTypeAnalyzer.isThreeLine }, -- 3
	[15] 	= {DDZPKCardTypeAnalyzer.isThreeLine }, -- 3
	-- [10] 	= {DDZPKCardTypeAnalyzer.isDoubleLine,DDZPKCardTypeAnalyzer.isThreeLineTakeDouble,DDZPKCardTypeAnalyzer.isThreeLineTakeOne, DDZPKCardTypeAnalyzer.isThreeLine}, --2
	[10] 	= {DDZPKCardTypeAnalyzer.isDoubleLine,DDZPKCardTypeAnalyzer.isThreeLine}, -- 这里的三连判断会额外返回
	-- [12] 	= {DDZPKCardTypeAnalyzer.isThreeLine} --2
}


DDZPKCardTypeAnalyzer.FuncTypeMap =
{
	[DDZPKCardTypeAnalyzer.isError] 				= DDZPKCard.CT_ERROR,           --
	[DDZPKCardTypeAnalyzer.isSingle] 				= DDZPKCard.CT_SINGLE,
	[DDZPKCardTypeAnalyzer.isDouble] 				= DDZPKCard.CT_DOUBLE,
	[DDZPKCardTypeAnalyzer.isThree] 				= DDZPKCard.CT_THREE,
	[DDZPKCardTypeAnalyzer.isOneLine] 				= DDZPKCard.CT_ONE_LINE,
	[DDZPKCardTypeAnalyzer.isDoubleLine] 			= DDZPKCard.CT_DOUBLE_LINE,
	[DDZPKCardTypeAnalyzer.isThreeLine] 			= DDZPKCard.CT_THREE_LINE,
	[DDZPKCardTypeAnalyzer.isThreeLineTakeOne] 		= DDZPKCard.CT_THREE_LINE_TAKE_ONE,
	[DDZPKCardTypeAnalyzer.isThreeLineTakeDouble] 	= DDZPKCard.CT_THREE_LINE_TAKE_DOUBLE,
	[DDZPKCardTypeAnalyzer.isFourLineTakeOne]		= DDZPKCard.CT_FOUR_LINE_TAKE_ONE,
	[DDZPKCardTypeAnalyzer.isFourLineTakeDouble]	= DDZPKCard.CT_FOUR_LINE_TAKE_DOUBLE,
	[DDZPKCardTypeAnalyzer.isBomb]					= DDZPKCard.CT_BOMB,
	[DDZPKCardTypeAnalyzer.isMissile]				= DDZPKCard.CT_MISSILE,  
	-- [DDZPKCardTypeAnalyzer.isAirPlane]				= DDZPKCard.CT_AIRPLANE,
}

DDZPKCardTypeAnalyzer.TypeFuncMap =
{
	[DDZPKCard.CT_ERROR]					= DDZPKCardTypeAnalyzer.isError,
	[DDZPKCard.CT_SINGLE]					= DDZPKCardTypeAnalyzer.isSingle,
	[DDZPKCard.CT_DOUBLE]					= DDZPKCardTypeAnalyzer.isDouble,
	[DDZPKCard.CT_THREE]					= DDZPKCardTypeAnalyzer.isThree,
	[DDZPKCard.CT_ONE_LINE]					= DDZPKCardTypeAnalyzer.isOneLine,
	[DDZPKCard.CT_DOUBLE_LINE]				= DDZPKCardTypeAnalyzer.isDoubleLine,
	[DDZPKCard.CT_THREE_LINE]				= DDZPKCardTypeAnalyzer.isThreeLine,
	[DDZPKCard.CT_THREE_LINE_TAKE_ONE]		= DDZPKCardTypeAnalyzer.isThreeLineTakeOne,
	[DDZPKCard.CT_THREE_LINE_TAKE_DOUBLE]	= DDZPKCardTypeAnalyzer.isThreeLineTakeDouble,
	[DDZPKCard.CT_FOUR_LINE_TAKE_ONE]		= DDZPKCardTypeAnalyzer.isFourLineTakeOne,
	[DDZPKCard.CT_FOUR_LINE_TAKE_DOUBLE]	= DDZPKCardTypeAnalyzer.isFourLineTakeDouble,
	[DDZPKCard.CT_BOMB]						= DDZPKCardTypeAnalyzer.isBomb,
	[DDZPKCard.CT_MISSILE]					= DDZPKCardTypeAnalyzer.isMissile,
	-- [DDZPKCard.CT_AIRPLANE]					= DDZPKCardTypeAnalyzer.isAirPlane,
}

--[[
DDZPKCard.CT_ERROR                            = 0   --0.错误
DDZPKCard.CT_SINGLE                           = 1   --1.单牌，如：3，4，5
DDZPKCard.CT_DOUBLE                           = 2   --2.对牌，如：33，44，55
DDZPKCard.CT_THREE                            = 3   --3.三条，如：333，444，555
DDZPKCard.CT_ONE_LINE                         = 4   --4.顺子，如：34567，5678910，78910JQKA   (连牌五张以上)
DDZPKCard.CT_DOUBLE_LINE                      = 5   --5.连对，如：33＋44＋55，33＋44＋55＋66...(三对以上)
DDZPKCard.CT_THREE_LINE                       = 6   --6.飞机，如：333＋444，333＋444＋555...
DDZPKCard.CT_THREE_LINE_TAKE_ONE              = 7   --7.三带一单，如：333＋4，33344456 
DDZPKCard.CT_THREE_LINE_TAKE_DOUBLE           = 8   --8.三带一双，如：333＋44，777888+5566
DDZPKCard.CT_FOUR_LINE_TAKE_ONE               = 9   --9.四带两单，如：3333＋45，7777＋89
DDZPKCard.CT_FOUR_LINE_TAKE_DOUBLE            = 10  --10.四带两双，如：3333＋4455，7777＋8899
DDZPKCard.CT_BOMB                             = 11  --11.炸弹，如3333，4444，5555
DDZPKCard.CT_MISSILE                    	  = 12  --12.火箭，大小王
--]]

return DDZPKCardTypeAnalyzer
