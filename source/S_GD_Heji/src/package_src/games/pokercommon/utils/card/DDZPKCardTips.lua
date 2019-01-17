--
-- 斗地主的牌型提示相关
--
local DDZPKCardTypeAnalyzer = require("package_src.games.pokercommon.utils.card.DDZPKCardTypeAnalyzer")
local DDZPKCard = require("package_src.games.pokercommon.utils.card.DDZPKCard")
local DDZPKCardTips = class("DDZPKCardTips")

DDZPKCardTips.defaultValue = 2

-------------------------------------------------------
-- @desc 构造函数
-- @pram cards 传入自己的手牌
-- return 无
-------------------------------------------------------
function DDZPKCardTips:ctor(cards)
    self:reset()
	if not cards then
		return
	end
    self:add(cards)
end

-------------------------------------------------------
-- @desc 重置相关变量 
--        self.m_valueCountMap:值-数对
--        self.m_countValueMap:数-值对
--        self.m_hasMissile:   是否有火箭
--        self.m_lastKey:	   
-- @pram 无
-- return 无
-------------------------------------------------------
function DDZPKCardTips:reset()
	self.m_valueCountMap = {}
	self.m_countValueMap = {}
	self.m_hasMissile = false
    self.m_lastKey = nil
end 

-------------------------------------------------------
-- @desc 打印手上的牌
-- @pram 无
-- return 无
-------------------------------------------------------
function DDZPKCardTips:print()
	local ret = {}
	for k, v in pairs(self.m_valueCountMap) do	
		for i = 1, v do
			ret[#ret + 1] = k
		end
	end
	table.sort(ret, function (a, b)
		return a > b
	end)
	for i = 1, #ret do
		local k = ret[i]
		if k == 15 then
			x = 2
		elseif k == 14 then
			x = "A"
		elseif k == 13 then
			x = "K"
		elseif k == 12 then
			x = "Q"
		elseif k == 11 then
			x = "J"
		else
			x = k
		end
		ret[i] = x
	end
	Log.d(table.concat(ret, ", "))
end

-------------------------------------------------------
-- @desc 获得 值-数对
-- @pram 无
-- return 返回值-数对
-------------------------------------------------------
function DDZPKCardTips:getValueCountMap()
	return self.m_valueCountMap
end

-------------------------------------------------------
-- @desc 获得 数-值对
-- @pram 无
-- return 返回 数-值对
-------------------------------------------------------
function DDZPKCardTips:getCountValueMap()
	return self.m_countValueMap
end

-------------------------------------------------------
-- @desc 获取是否有火箭
-- @pram 无
-- return bool 是否有火箭
-------------------------------------------------------
function DDZPKCardTips:hasMissile()
    return self.m_hasMissile
end

-------------------------------------------------------
-- @desc 添加牌到类中
-- @pram cards :要添加的牌一般是自己手牌
-- return 无
-------------------------------------------------------
function DDZPKCardTips:add(cards)
	-- dump(cards)
	if not cards then
		return
	end
	-- dump(self.m_valueCountMap)
	-- dump(self.m_countValueMap)
	local arrv = self.m_valueCountMap
 
	local arrn = self.m_countValueMap
	for _, v in pairs(cards) do 
		local n = arrv[v] or 0
		if arrn[n] and arrn[n][v] then
		    arrn[n][v] = nil
		end
		
	    arrv[v] = n + 1
        arrn[n + 1] = arrn[n+1] or {}
        arrn[n + 1][v] = true 
	end
	
	if  arrv[29] and arrv[30] then
	    self.m_hasMissile = true
    else
        self.m_hasMissile = false
	end
	-- print("<mzd:_________________>")
	-- dump(self.m_valueCountMap)
	-- dump(self.m_countValueMap)
end

-------------------------------------------------------
-- @desc 移除牌 并更新到 两个表中
-- @pram cards 要移除的牌
-- return 无
-------------------------------------------------------
function DDZPKCardTips:remove(cards)
	if not cards then
		return
	end
	local arrv = self.m_valueCountMap
 
	local arrn = self.m_countValueMap

	for _, v in pairs(cards) do
		local n = arrv[v]
		if n then
			if arrn[n] and arrn[n][v] then
			    arrn[n][v] = nil
			end
			if n - 1 > 0 then 
			    arrv[v] = n - 1
	            arrn[n - 1] = arrn[n - 1] or {}
	            arrn[n - 1][v] = true 
	        else
	            arrv[v] = nil
	        end
	    else
	    	printLog("Error in DDZPKCardTips.remove:n is nil")
	    end
	end
	
	if not arrv[29] or not arrv[30] then
	    self.m_hasMissile = false
	end
end


---------------------------------------
-- 函数功能：   获取同样牌值的牌
-- keyCard:    上次提示关键牌
-- count:      相同牌值的牌数量
-- doFullScan: 是否全部扫描
-- orginalKeyCard: 上手牌关键牌
-- notUseBombType: 不使用炸弹
-- 返回值：    牌值大于keyCard 相同牌值的count张牌 
---------------------------------------
function DDZPKCardTips:getSameCards(keyCard, count, doFullScan, orginalKeyCard, notUseBombType)
    local keys = {keyCard, orginalKeyCard}--keyCard 上次提示关键牌  orginalKeyCard上一手关键牌
    -- print("<mzd:**********getSameCards>")
    -- dump(keyCard) -- 8
    -- dump(count)   -- 2
    -- dump(doFullScan) -- false
    -- dump(orginalKeyCard) --8
    -- dump(notUseBombType) --true
    
    local begIndex = self.m_valueCountMap[keyCard]--上次提示关键牌有几张
    local endIndex = begIndex--上已手关键牌有几张
    if not begIndex or (keyCard == orginalKeyCard) or doFullScan then
        begIndex = count--如果手牌中没有该牌  张数==count
        endIndex = table.maxn(self.m_countValueMap)--上一手关键牌数量==手牌中数量最多牌的数量
    end
            
    for k, v in ipairs(keys) do 
        if k==2 then --上一手牌关键牌
            begIndex = begIndex +1 --上手提示牌关键牌数量+1
            endIndex = table.maxn(self.m_countValueMap) --上手牌关键牌数量==手牌中数量最多的牌的数量
        end
        endIndex = (notUseBombType and endIndex>=4) and 3 or endIndex--不使用炸弹类型且上手牌关键牌数量大于等于4张 endIndex = 3
        
        for i=begIndex,endIndex do 
            local array = self.m_countValueMap[i]---array>>{[3] = {[4] = true,[5] = true}} ==>> 4和5都有三张
            if array then
                local maxIndex = table.maxn(array)--相同数量牌中最大的一张牌的牌值
                for j=v+1,maxIndex do ----v  上次提示关键牌牌值或者上手牌关键牌牌值
                    if array[j] and not(i==1 and self:hasMissile() and j>=29) then --i表示相同牌的张数
                        local ret = {}
                        for k=1,count do 
                            ret[k] = j
                        end
                        return ret
                    end 
                end
            end
        end
   end
end

---------------------------------------
-- 函数功能：   获取单张牌型
-- keyCard:    关键牌
-- length：    不同牌值的牌的张数
-- doFullScan:
-- orginalKeyCards: 上家打出的牌关键牌
-- notUseBomType:
-- 返回值：     无
---------------------------------------

function DDZPKCardTips:getSingle(keyCard, length, doFullScan, orginalKeyCard, notUseBombType)
	return self:getSameCards(keyCard, 1, doFullScan, orginalKeyCard, notUseBombType)
end

---------------------------------------
-- 函数功能：   获取对子牌型
-- keyCard:    关键牌
-- length：    不同牌值的牌的张数
-- doFullScan: 是否全部扫描
-- orginalKeyCards: 上家打出的牌关键牌
-- notUseBomType: 不使用炸弹
-- 返回值：     无
---------------------------------------

function DDZPKCardTips:getDouble(keyCard, length, doFullScan, orginalKeyCard, notUseBombType)
	return self:getSameCards(keyCard, 2, doFullScan, orginalKeyCard, notUseBombType)
end

---------------------------------------
-- 函数功能：   获取三张牌型
-- keyCard:    关键牌
-- length：    不同牌值的牌张数
-- doFullScan: 是否全部扫描
-- orginalKeyCards: 上家打出的牌关键牌
-- notUseBomType: 不使用炸弹
-- 返回值：     无
---------------------------------------

function DDZPKCardTips:getThree(keyCard, length, doFullScan, orginalKeyCard, notUseBombType)
	--return self:getSameCards(keyCard,3,doFullScan,orginalKeyCard,notUseBombType)
	return self:getMultiLines(keyCard, 1, 3, notUseBombType)
end

---------------------------------------
-- 函数功能：   获取顺牌型  如顺子、连对、飞机等
-- keyCard:    关键牌
-- length：    顺子牌的数量  如34567  ==> lenght = 5    334455 ==> lenght = 3
-- count：  单张1 对子2 三张3 如34567 ==> count = 1     334455 ==> count = 2
-- orginalKeyCards: 上家打出的牌关键牌
-- notUseBomType: 不使用炸弹
-- 返回值：     关键牌大于keyCard的顺子牌型
---------------------------------------

function DDZPKCardTips:getMultiLines(keyCard, length, count, notUseBombType)
	local arr = self.m_valueCountMap--手牌数据--》 {[3(牌值)] = 5(数量)}
	local maxValue = table.maxn(arr)--返回当前手牌最大的牌
	local bound = length > 1 and 14 or 15--牌值范围
	local result={}

	maxValue = maxValue>bound and bound or maxValue--顺子牌最大牌牌值是14  A
	

	local key = keyCard-- 上次提示牌关键牌
	local lastKey = key--上手牌关键牌
	while maxValue-key >= length do --判断最大牌减去关键牌张数是否大于等于需要的顺子牌张数
        for i=1,length do 
            --遍历范围内的手牌 如果关键牌不存在 或者牌少于需要的牌数量 或者牌数量等于4（炸弹）且需要的牌数量不等于4（需要的不是炸弹）且不使用炸弹   key递增
			if (not arr[i+key]) or arr[i+key] < count or (arr[i+key] == 4 and count ~= 4 and notUseBombType) then --判断顺子牌是否有连续的且够数量的牌
				key = key +1
				break
			end
		end
		if key == lastKey then
			local ret = {}
			for i=1,length do 
				for j=1,count do 
					ret[(i-1)*count+j] = key +i 
				end
			end
			--table.insert(result,ret)
			--return result
			return ret, key+1  --返回符合需要的顺子牌型
			--key=key+1
		end
		lastKey = key
	end
	
	--[[if #result==1 then
		return result[1]
	end
	local haveMore--提示的牌里是否有牌的张数大于实际需要的牌的张数
    for i,v in ipairs(result) do
    	local x={}
    	for i=1,#v,count do
    		table.insert(x,v[i])
    	end
    	for _,vv in pairs(x) do
    		if arr[vv]>count then
    			haveMore=true
    			break
    		end
    		haveMore=false
    	end
    	if not haveMore then
    		return v
    	elseif i==#result then
    		return result[1]
    	end
    end]]

end

---------------------------------------
-- 函数功能：   获取顺子
-- keyCard:    关键牌
-- length：    牌的张数
-- 返回值：     无
---------------------------------------

function DDZPKCardTips:getOneLine(keyCard, length)
	return self:getMultiLines(keyCard, length, 1)
end

---------------------------------------
-- 函数功能：   获取对子
-- keyCard:    关键牌
-- length：    牌的张数
-- 返回值：     无
---------------------------------------

function DDZPKCardTips:getDoubleLine(keyCard,length)
	return self:getMultiLines(keyCard,length,2)
end

---------------------------------------
-- 函数功能：   获取飞机
-- keyCard:    关键牌
-- length：    牌的张数
-- 返回值：     无
---------------------------------------

function DDZPKCardTips:getThreeLine(keyCard,length,_,__,notUseBombType)
	return self:getMultiLines(keyCard,length,3,notUseBombType)
end

-------------------------------------------------------
-- @desc 
-- @pram
--			length:返回多少个数
-- 
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getSameCardsRaw(count, length, disposeCards, disposeCount) -- takeCount 带几张,nTakes,dis,count
	local ret = {}
	local arr
    --missile won't be seprated as a take   (炸弹不会被拆为带的牌)
    local checkMissile = function(ret, curKey)--判断手中有火箭的时候不拆火箭为带的牌
        if (curKey==30 or curKey==29) and self.m_hasMissile then
            return false
        end 
        return true
    end
    --disposeCards 不晓得是啥子意思啊
    --找出牌数量大于等于count张且小于disposeCount张的牌 存到ret中
	for i=count,disposeCount-1 do
		arr = self.m_countValueMap[i] --得到同一数量的牌有哪些
		if arr then 
            for j=1,table.maxn(arr) do 
                if arr[j] and checkMissile(ret, j) then 
                    for k=1,i/count do 
                        ret[length] = j
                        length = length -1
                    end
                end
                if length <= 0 then 
                    return ret
                end
            end
        end
	end
	
	--找到带的牌?
	for i=disposeCount, math.min(3, table.maxn(self.m_countValueMap)) do
		arr = self.m_countValueMap[i]
		if arr then 
            for j=1, table.maxn(arr) do --bomb won't be seprated as a take
                if arr[j] and checkMissile(ret, j) then 
                    local nGets = i
                    for k,v in ipairs(disposeCards) do 
                        if v == j then
                            nGets = 0--the value in lines won't become a take
                            break
                        end
                    end
			         
                    --takes can't contain a 3-line according to svr's logic
                    for k=1, math.min(nGets/count, 2) do 
                        ret[length] = j
                        length = length -1
                    end
                end
                if length <= 0 then 
                    return ret
                end
            end
	    end
	end
end


-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
--nA带mB形式，A为同牌值的三张牌或四张牌，n取值范围为满足斗地主规则的A的个数
--            B为同牌值的单张或对子，m为nA可带的B的个数
--length：n
--count：单个A的牌数
--nTakes：m
--takeCount：单个B的牌数                             1     4     2      1
function DDZPKCardTips:getLinesTakes(keyCard,length,count,nTakes,takeCount,notUseBombType)
    local keyValue = keyCard
    local ret
    while true do
        ret, keyValue = self:getMultiLines(keyValue,length,count,notUseBombType)
        if not ret then
            return nil
        end
        
    	local dis = {}
    	for i=1,#ret,count do 
    		dis[#dis+1] = ret[i]
    	end
    	local takes = self:getSameCardsRaw(takeCount,nTakes,dis,count)
    	if takes then
            for _,v in ipairs(takes) do 
                for i=1,takeCount do  
                    ret[#ret+1] = v
                end
            end
            return ret, keyValue 
        end
    end
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getThreeLineTakeOne(keyCard,length,_,_,notUseBombType)
    local ret, keyValue = self:getLinesTakes(keyCard,length,3,length,1,notUseBombType)
    while ret and DDZPKCardTypeAnalyzer.getCardType(ret)~=DDZPKCard.CT_THREE_LINE_TAKE_ONE do
        ret, keyValue = self:getLinesTakes(keyValue,length,3,length,1,notUseBombType)
    end
    return ret
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getThreeLineTakeDouble(keyCard,length,_,_,notUseBombType)
	return self:getLinesTakes(keyCard,length,3,length,2,notUseBombType)
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getFourLineTakeOne(keyCard)
	return self:getLinesTakes(keyCard,1,4,2,1)
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getFourLineTakeDouble(keyCard)
    local ret,keyValue = self:getLinesTakes(keyCard,1,4,2,2)
    while ret and DDZPKCardTypeAnalyzer.getCardType(ret)~=DDZPKCard.CT_FOUR_LINE_TAKE_DOUBLE do
        ret, keyValue = self:getLinesTakes(keyValue,1,4,2,2)
    end
    return ret
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getBomb(keyCard)
    if not keyCard then
        return self:getSameCards(DDZPKCardTips.defaultValue,4)
    else
		return self:getSameCards(keyCard,4)
	end
end

-------------------------------------------------------
-- @desc 获取火箭
-- @pram 无
-- return 火箭的牌值
-------------------------------------------------------
function DDZPKCardTips:getMissile()
    if self.m_hasMissile then
        return {29,30}
    end
end


DDZPKCardTips.TypeFuncMap =
{
	[DDZPKCard.CT_SINGLE]				    = DDZPKCardTips.getSingle,
	[DDZPKCard.CT_DOUBLE]				    = DDZPKCardTips.getDouble,
	[DDZPKCard.CT_THREE]					= DDZPKCardTips.getThree,
	[DDZPKCard.CT_ONE_LINE]				= DDZPKCardTips.getOneLine,
	[DDZPKCard.CT_DOUBLE_LINE]			= DDZPKCardTips.getDoubleLine,
	[DDZPKCard.CT_THREE_LINE]			    = DDZPKCardTips.getThreeLine,
	[DDZPKCard.CT_THREE_LINE_TAKE_ONE]	= DDZPKCardTips.getThreeLineTakeOne,
	[DDZPKCard.CT_THREE_LINE_TAKE_DOUBLE] = DDZPKCardTips.getThreeLineTakeDouble,
	[DDZPKCard.CT_FOUR_LINE_TAKE_ONE]	    = DDZPKCardTips.getFourLineTakeOne,
	[DDZPKCard.CT_FOUR_LINE_TAKE_DOUBLE]	= DDZPKCardTips.getFourLineTakeDouble,
	[DDZPKCard.CT_BOMB]			    = DDZPKCardTips.getBomb,
	[DDZPKCard.CT_MISSILE]			= DDZPKCardTips.getMissile
}


DDZPKCardTips.TypeLengthFactorMap =
{
	[DDZPKCard.CT_SINGLE]				    = 1,
	[DDZPKCard.CT_DOUBLE]				    = 1,
	[DDZPKCard.CT_THREE]					= 1,
	[DDZPKCard.CT_ONE_LINE]				= 1,
	[DDZPKCard.CT_DOUBLE_LINE]			= 2,
	[DDZPKCard.CT_THREE_LINE]			    = 3,
	[DDZPKCard.CT_THREE_LINE_TAKE_ONE]	= 4,
	[DDZPKCard.CT_THREE_LINE_TAKE_DOUBLE] = 5,
	[DDZPKCard.CT_FOUR_LINE_TAKE_ONE]	    = 1,
	[DDZPKCard.CT_FOUR_LINE_TAKE_DOUBLE]	= 1,
	[DDZPKCard.CT_BOMB]			    = 1,
	[DDZPKCard.CT_MISSILE]			= 1
}

-----------------------------------------------------------
--@ decs typeParam 这手牌的类型  
--@ ...   这手牌的关键牌、 X因素、是否上手别人的牌、
function DDZPKCardTips:onTypeFuncMap(typeParam , ...)
	if DDZPKCardTips.TypeFuncMap[typeParam] then
		return DDZPKCardTips.TypeFuncMap[typeParam](self,...)
	end
end

function DDZPKCardTips:onTypeLengthFactorMap(typeParam)
	if DDZPKCardTips.TypeLengthFactorMap[typeParam] then
		return DDZPKCardTips.TypeLengthFactorMap[typeParam]
	else
		return 1
	end
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
--如果cards的牌型是單張、对子、三带一、三带二 返回true   飞机 返回false
function DDZPKCardTips:isBombFirstType(cards)
	local cardType, _ = DDZPKCardTypeAnalyzer.getCardType(cards)
	return (cardType <= DDZPKCard.CT_THREE or cardType == DDZPKCard.CT_THREE_LINE or cardType == DDZPKCard.CT_THREE_LINE_TAKE_ONE or cardType == DDZPKCard.CT_THREE_LINE_TAKE_DOUBLE) and #cards < 6 
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
--orginalCards   上一次出牌牌值集合
--lastCards 上一次提起牌牌值集合
--cardType --上一次出牌类型
function DDZPKCardTips:getTipsLoop(orginalCards, lastCards, cardType)
	local lastKey = DDZPKCardTips.lastKey--上次提示牌关键牌
	DDZPKCardTips.lastKey = nil 
	if not orginalCards or #orginalCards == 0 then --如果无上次出牌  获取提示牌
		return self:getTipsWithNoOriginalCards(lastCards)
	end

    if cardType and cardType >= DDZPKCard.CT_MISSILE then --如果牌型大于火箭  直接返回
        return
    end

	if not lastCards or #lastCards==0 then--如果无上次提示牌   上次提示牌等于上次出的牌
		lastCards = orginalCards
	end

	local cardsArr = {lastCards, orginalCards}--{上次提示牌，上次出牌}
	local keyCards = {}--关键牌集合
	local typeArr = {} --牌型集合
	
	for k, v in ipairs(cardsArr) do 
		local cards = cardsArr[k]
		table.sort(checktable(cards))
		typeArr[k], keyCards[k] = DDZPKCardTypeAnalyzer.getCardType(cards)
	end

	if self:isBombFirstType(orginalCards, cardType) then
		for k, v in ipairs(cardsArr) do 
			local ret
			local ctype = typeArr[k]
			
			local lastType, _ = DDZPKCardTypeAnalyzer.getCardType(lastCards)--lasttype 上次提示的牌型

			--单张火箭提示优化，先提示火箭，再拆火箭
            if not (ctype==DDZPKCard.CT_SINGLE and self:hasMissile() and #v==1 and v[1]==30) then
                if ctype==DDZPKCard.CT_SINGLE and self:hasMissile() and #v==1 and v[1]==29 then
                    return {30}
                end
                if not self.m_valueCountMap[keyCards[k]] or self.m_valueCountMap[keyCards[k]]<= 4 or lastType==DDZPKCard.CT_BOMB then
                    --不拆炸弹的提示
                    if ctype < DDZPKCard.CT_MISSILE and ctype>0 then
                        ret = self:onTypeFuncMap(ctype,keyCards[k],#v/self:onTypeLengthFactorMap(ctype),(k==2),keyCards[#keyCards],true)
                    end
					--单张2  先提示小王
					if not ret then
						if ctype == DDZPKCard.CT_SINGLE and lastKey == 15 and self:hasMissile() then
							ret = {29}
						end
					end
                    --炸弹提示   
                    if not ret then 
                        ctype = ctype +1
                        ctype = ctype < DDZPKCard.CT_BOMB and DDZPKCard.CT_BOMB  or ctype
                        for i=ctype,DDZPKCard.CT_MISSILE do 
                            ret = self:onTypeFuncMap(i)
                            if ret then
                                break
                            end
                        end
                    end
                end
                --拆炸弹提示
                if not ret and ( cardType ~= DDZPKCard.CT_SINGLE )then
                	Log.i("============拆炸弹提示====cardType====ctype==ssssssssssssssssssssssss", cardType, ctype)

					lastKey = lastKey or keyCards[table.maxn(keyCards)]
					local tempRet = self:getBombs(lastKey)
					if tempRet and self:onTypeBaseNum(cardType) and ( ctype ~= DDZPKCard.CT_BOMB) then
						local tempType,tempKey = DDZPKCardTypeAnalyzer.getCardType(tempRet)
						local cardType,_ = DDZPKCardTypeAnalyzer.getCardType(orginalCards)
						if DDZPKCard.CT_SINGLE == cardType  then--炸弹拆出单张
							ret, self.m_lastKey =  {tempKey}, tempKey

						elseif DDZPKCard.CT_DOUBLE == cardType then--炸弹拆出对子
							ret, self.m_lastKey = {tempKey, tempKey}, tempKey
						
						elseif DDZPKCard.CT_THREE_LINE_TAKE_DOUBLE == cardType or (DDZPKCard.CT_THREE_LINE_TAKE_ONE == cardType )then
							ret, self.m_lastKey = {tempKey, tempKey,tempKey, tempKey}, tempKey

						else

							local takes = self:onTypeBaseNum(cardType)-3 --带几张
							ret = {tempKey,tempKey,tempKey}
							ret = takes>0 and self:getTakes(ret, 1, takes) or ret
							DDZPKCardTips.lastKey = tempRet[1]
						end
					end
                end
                
                if ret then
                    return ret
                end
                if cardType == DDZPKCard.CT_SINGLE and self:hasMissile() then
                    return {29}
                end
            end
		end
	else
		for k, v in ipairs(cardsArr) do 
			local ret
			local ctype = typeArr[k]
			if ctype < DDZPKCard.CT_MISSILE and ctype > 0 then
			    ret = self:onTypeFuncMap(ctype, keyCards[k], #v/self:onTypeLengthFactorMap(ctype), (k==2), keyCards[#keyCards])
			end
			
			if not ret then 
				ctype = ctype +1
				ctype = ctype < DDZPKCard.CT_BOMB and DDZPKCard.CT_BOMB  or ctype
				for i=ctype,DDZPKCard.CT_MISSILE do 
					ret = self:onTypeFuncMap(i)
					if ret then
						break
					end
				end
			end
			
			if ret then
				return ret
			end
		end
	end
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getTipsWithNoOriginalCards(lastCards)
	Log.i("getTipsWithNoOriginalCards ", lastCards)
	local ret = {} 
	local arr = {}
	local index = 1
	for i = 1, table.maxn(self.m_valueCountMap) do
		if self.m_valueCountMap[i] then 
			arr[index] = {i, self.m_valueCountMap[i]}
			index = index + 1
		end
	end
    if #arr >= 2 and arr[#arr][1] == 30 and arr[#arr-1][1] == 29 then
        arr[#arr - 1][2] = 2
        table.remove(arr, #arr)
    end
	table.sort(arr, function(a, b)
		if a and b then
			return a[1] < b[1]
		else
			return false
		end
	end)
	if not lastCards or #lastCards ==0 or arr[#arr][1] <= lastCards[1] then
		if arr[1] and arr[1][2] then
			for i=1, arr[1][2] do
				ret[i]=arr[1][1]
			end
	        if 29 == ret[2] then
	            ret[2] = 30
	        end
			return ret
		end
	else
		for i = 1, #arr do
			if arr[i][1] > lastCards[1] then
				for j = 1, arr[i][2] do
			        ret[j] = arr[i][1]
		        end
                if 29 == ret[2] then
                    ret[2] = 30
                end
		        return ret
		    end
		end
    end
    return nil
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:emptyFunc()
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getSameCardsByPart(partCardsKey,count)
	partCardsKey = number.valueOf(partCardsKey)
	count = number.valueOf(count)
    if number.valueOf(self.m_valueCountMap[partCardsKey]) >= count then 
        local ret = {}
        for i=1,count do 
            ret[i] = partCardsKey
        end
        return ret
    end
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getDoubleByPart(partCardsKey)
    return self:getSameCardsByPart(partCardsKey,2)
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getThreeByPart(partCardsKey)
    return self:getSameCardsByPart(partCardsKey,3)
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getMultiLinesByPart(partCardsKey, length, count)
    local ret = true
    for i = 1, length do 
        if not self.m_valueCountMap[partCardsKey + i - 1] or self.m_valueCountMap[partCardsKey + i - 1] < count or partCardsKey + i - 1 > 14 then
            ret = false
            break
        end
    end
    
    if ret then
        ret = {}
        for i = 1, length do 
            for j = 1, count do 
                ret[(i - 1) * count + j] = partCardsKey + i - 1
            end
        end
        return ret
    end
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getOneLineByPart(partCardsKey, length)
    return self:getMultiLinesByPart(partCardsKey, length, 1)
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getDoubleLineByPart(partCardsKey, length)
    return self:getMultiLinesByPart(partCardsKey, length, 2)
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getThreeLineByPart( partCardsKey, length)
    return self:getMultiLinesByPart(partCardsKey, length, 3)
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getBombByPart(partCardsKey,length)
    return self:getMultiLinesByPart(partCardsKey,length,4)
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:emptyCheckFunc()
    return true
end

DDZPKCardTips.TypePartFuncMap =
{
	[DDZPKCard.CT_SINGLE]				    = DDZPKCardTips.emptyFunc,
	[DDZPKCard.CT_DOUBLE]				    = DDZPKCardTips.getDoubleByPart,
	[DDZPKCard.CT_THREE]					= DDZPKCardTips.getThreeByPart,
	[DDZPKCard.CT_ONE_LINE]				= DDZPKCardTips.getOneLineByPart,
	[DDZPKCard.CT_DOUBLE_LINE]			= DDZPKCardTips.emptyFunc,
	[DDZPKCard.CT_THREE_LINE]			    = DDZPKCardTips.emptyFunc,
	[DDZPKCard.CT_THREE_LINE_TAKE_ONE]	= DDZPKCardTips.emptyFunc,
	[DDZPKCard.CT_THREE_LINE_TAKE_DOUBLE] = DDZPKCardTips.emptyFunc,
	[DDZPKCard.CT_FOUR_LINE_TAKE_ONE]	    = DDZPKCardTips.emptyFunc,
	[DDZPKCard.CT_FOUR_LINE_TAKE_DOUBLE]	= DDZPKCardTips.emptyFunc,
	[DDZPKCard.CT_BOMB]			        = DDZPKCardTips.emptyFunc,
	[DDZPKCard.CT_MISSILE]			    = DDZPKCardTips.emptyFunc
}

DDZPKCardTips.TypeBaseNum =
{
	[DDZPKCard.CT_THREE]				     = 3,
	[DDZPKCard.CT_THREE_LINE]			     = 3,
	[DDZPKCard.CT_THREE_LINE_TAKE_ONE]	 = 4,
	[DDZPKCard.CT_THREE_LINE_TAKE_DOUBLE]  = 5
}


-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:onTypePartFuncMap(typeParam , ...)
	if DDZPKCardTips.TypePartFuncMap[typeParam] then
		return DDZPKCardTips.TypePartFuncMap[typeParam](self,...)
	end
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:onTypeBaseNum(typeParam )
	if DDZPKCardTips.TypeBaseNum[typeParam] then
		return DDZPKCardTips.TypeBaseNum[typeParam]
	else
		return 3
	end
end

-------------------------------------------------------
-- @desc 	根据部分值来获取到提示
-- @pram 	partCards:用来获取提示的部分值  一般是选中的手牌
-- @return 	返回提示牌
-------------------------------------------------------
function DDZPKCardTips:getTipsByPart( partCards)
	Log.i("DDZPKCardTips:getTipsByPart ", partCards)
    local partCardsKey = partCards[#partCards]
    for i = 1, #partCards do
        if i ~= #partCards then
            if partCards[i] == partCards[i + 1] then
                return nil
            end
        end
    end
	if partCards[1] - partCardsKey == #partCards - 1 then --如果选择的牌可能是单连
        local len = 5 - (partCards[1] - partCardsKey) - 1 
        if len > 3 then  --如果选择的牌是相同的牌
            return nil
        end
        for i = 0, len do 
            local ret = self:onTypePartFuncMap(DDZPKCard.CT_ONE_LINE, partCardsKey - i, 5)
            if ret then 
                return ret
            end
        end
    end
	
	return nil
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getMultiLinesFromCards(cards, count, length)
    local lineCards = {cards[#cards]}
    for i=#cards-1,1,-1 do 
        if cards[i] ~= lineCards[#lineCards] then
            lineCards[#lineCards+1] = cards[i]
        end
    end
    
    local valueCards = {}
    for k,v in ipairs(cards) do 
        valueCards[v] = valueCards[v] or 0
        valueCards[v] = valueCards[v] +1
    end
	
	local arr = {}
	for i,v in ipairs(lineCards) do 
		if valueCards[v] >= count and v<15 then
		    arr[#arr+1] = v
		end
	end
	
	lineCards = arr
	
	if #lineCards < length then 
		return 
	end
    
    local holes = {}
    for k,v in pairs(lineCards) do 
        holes[v] = k
    end
    
    local lastIndex = lineCards[1]-1
    local lastHole = lastIndex
    local long = 0
    for i=lineCards[1],lineCards[#lineCards]+1 do
        if not holes[i] then
            if i - lastHole > long then
                long = i-lastHole
                lastIndex = i
            end
            lastHole = i
        end
    end
    
    if long > length then 
        local ret = {}
        for i=1,long-1 do 
            local tmp = i+lastIndex-long
            for j=1,count do 
                ret[(i-1)*count+j] = tmp
            end
        end
        return ret
    end
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getOneLineFromCards(cards)
    return self:getMultiLinesFromCards(cards, 1, 5)
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getDoubleLineFromCards(cards)
    return self:getMultiLinesFromCards(cards, 2, 3)
end

-------------------------------------------------------
-- @desc 获取cards中的牌的数量大于2的牌的集合
-- @pram cards:源牌
-- return ret 牌数量大于2的所有牌的集合
-------------------------------------------------------
function DDZPKCardTips:getDouble(cards)
    local valueCards = {}
    --得到cards中每张牌的数量
    for k,v in ipairs(cards) do 
        valueCards[v] = valueCards[v] or 0
        valueCards[v] = valueCards[v] +1
    end
    
    --将牌的数量大于2的牌先存到ret中
    local ret = {}
	for i,v in ipairs(cards) do 
		if valueCards[v] >= 2 then
			ret[#ret+1] = v
		end
	end
    
	return ret
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
function DDZPKCardTips:getTipsWithCards( cards)
	local cardTmp = {}
	for i, v in ipairs(cards) do 
		cardTmp[i] = v
	end
	
	local ret = DDZPKCardTypeAnalyzer.getCardType(cardTmp)
	if ret ~= DDZPKCard.CT_ERROR then
		return ret, cards
	end
	
	if #cards < 5 then
		return DDZPKCard.CT_ERROR
	end
	
	local ret = self:getOneLineFromCards(cards)
	-- local ret1 = self:getDoubleLineFromCards(cards)
	-- if ret1 and (not ret or #ret1 > #ret) then
	-- 	return DDZPKCard.CT_DOUBLE_LINE, ret1
	-- end

    if ret then
        return DDZPKCard.CT_ONE_LINE, ret
    end
	
	return DDZPKCard.CT_ERROR
end

-------------------------------------------------------
-- @desc   此函数较混乱  需要检查   外面的逻辑好像是调不进来的
-- @pram
-- return 无
-------------------------------------------------------
--由一张牌获取提示
function DDZPKCardTips:getTipsBy1card(cards, card)
	--获取牌型
    local ret = DDZPKCardTypeAnalyzer.getCardType(cards)

    if ret == DDZPKCard.CT_FOUR_LINE_TAKE_ONE or ret == DDZPKCard.CT_FOUR_LINE_TAKE_DOUBLE then
        local count = self.m_valueCountMap[card]
        if count and count > 0 then
            local reCards = {}
            for i = 1, count do
                reCards[i] = card
            end
            return reCards
        else
            return {card}
        end
    elseif ret == DDZPKCard.CT_ERROR then
        return {card}
    else
        return cards
    end
end

-------------------------------------------------------
-- @desc 
-- @pram
-- return 无
-------------------------------------------------------
-- line :333   nTakes:？  takeCount:带2张
function DDZPKCardTips:getTakes(line, nTakes,takeCount)
    if not line then
        return nil
    end
    
	local dis = {}
	for i=1,#line,3 do 
		dis[#dis+1] = line[i]
	end
	local takes = self:getSameCardsRaw(takeCount,nTakes,dis,3) 
	if not takes then
        return nil
    end
	
	for _,v in ipairs(takes) do 
	    for i=1,takeCount do  
		    line[#line+1] = v
		end
	end
	
	return line 
end

-------------------------------------------------------
-- @desc 火箭不是Bomb,本函数作用是获取大于keyCard的最大的炸弹 Boo!!
-- @pram keyCard:number 牌值
-- return {}返回炸弹 
-------------------------------------------------------
function DDZPKCardTips:getBombs(keyCard)
    if not keyCard then 
        return
    end
	local min = 29
	for k, v in pairs(self.m_valueCountMap) do
		if k < min and k > keyCard and v == 4 then 
            min = k 
        end
	end
	if min ~= 29 then 
        return {min, min, min, min}
	end
end

return DDZPKCardTips