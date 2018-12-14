local Define 		= require "app.games.common.Define"
local timerProxy 	= require "app.common.TimerProxy".new()
local Mj    		= require "app.games.common.mahjong.Mj"
local LocalEvent 	= require "app.hall.common.LocalEvent"
local HandCardsPanel = require("app.games.common.ui.playlayer.HandCardsPanel")
local huaijimjHandCardsPanel = class("huaijimjHandCardsPanel", HandCardsPanel)

function huaijimjHandCardsPanel:doubleClickPutOutMj(touch)
	-- 判断双击
	-- local intervalTime = os.clock() - self.clickTimeInterval
	local cardIndex = 0
	-- 进入双击麻将处理逻辑
	-- if intervalTime <= 0.4 then
		for i=1,#self.handCardsObjs do
			if self.handCardsObjs[i]:isContainsTouch(touch:getLocation().x, touch:getLocation().y)
			and self.handCardsObjs[i]:getMjState() == enMjState.MJ_STATE_ALREADY_SELECTED then
				local flowers = self.playSystem:getGameStartDatas().isFlowers
			    -- 判断是否为花牌
			    if flowers and #flowers > 0 then
		            for j=1, #flowers do
		                if self.handCardsObjs[i]:getValue() == flowers[j] then
		                	Toast.getInstance():show("花牌不能打出")
		                	return
		                end
		            end
			    end
			    -- 如果规则上赖子不能打出则进行判断
			    if CAN_NOT_PUT_OUT_LAIZI then
					local laiziList = self.playSystem:getGameStartDatas().laizi
					for k, v in pairs(laiziList) do
						if self.handCardsObjs[i]:getValue() == v then
							Toast.getInstance():show("温馨提示：混子牌不能被打出哟")
							return
						end
					end
				end
			    if self:isDingqueCheckValid(self.handCardsObjs[i]) then
					cardIndex = i
				end
				break;
	    	end
		end	
    -- end

    --判断没有翻马的状况，最后4张牌不可以打出去
	if cardIndex > 0 then
		-- 存储要打出去的牌的数据
  		local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    	local hasF = sys:getGameStartDatas().wfKou
  		local count = SystemFacade:getInstance():getRemainPaiCount()--最后剩几张牌
  		Log.d(" ..............SystemFacade:getInstance():getRemainPaiCount()...",count)
  		Log.d(" ..............sys:getGameStartDatas().wfKou...",hasF)
		if hasF == false and count < 4 then --没有翻马，并且最后4张牌
			Log.d("...........sbs:getGameStartDatas().wfKou.............")
			return
		else
			local posx, posy = self.handCardsObjs[cardIndex]:getPosition()  
			self:putOutCard(cardIndex, posx, posy)
		end
	end
end

--[[
-- @brief  拖拽出牌
-- @param  void
-- @return void
--]]
function huaijimjHandCardsPanel:dragOutMj(touch)
	local cardIndex = 0
	-- 进入双击麻将处理逻辑
	for i=1,#self.handCardsObjs do
		if self.handCardsObjs[i]:getMjState() == enMjState.MJ_STATE_ALREADY_SELECTED then
			if self:isDingqueCheckValid(self.handCardsObjs[i]) then
				cardIndex = i
			end
		elseif self.handCardsObjs[i]:getMjState() == enMjState.MJ_STATE_SELECTED then
			if self:isDingqueCheckValid(self.handCardsObjs[i]) then
				cardIndex = i
			end
		end
	end

    -- 判断是否为花牌
	local flowers = self.playSystem:getGameStartDatas().isFlowers
    if flowers and #flowers > 0 then
        for j=1, #flowers do
            if self.handCardsObjs[cardIndex]:getValue() == flowers[j] then
            	Toast.getInstance():show("温馨提示：花牌不能打出哟")
            	return
            end
        end
    end
    -- 如果规则上赖子不能打出则进行判断
    if CAN_NOT_PUT_OUT_LAIZI then
		local laiziList = self.playSystem:getGameStartDatas().laizi
		for k, v in pairs(laiziList) do
			if self.handCardsObjs[cardIndex]:getValue() == v then
				Toast.getInstance():show("温馨提示：混子牌不能被打出哟")
				return
			end
		end
	end

	--打牌操作
	if cardIndex > 0 then
  		local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    	local hasF = sys:getGameStartDatas().wfKou
  		local count = SystemFacade:getInstance():getRemainPaiCount()--最后剩几张牌
		if hasF == false and count < 4 then--没有翻马，并且最后4张牌
			Log.d("...........sys:getGameStartDatas().wfKou.............")
			return
		else
			self:putOutCard(cardIndex, touch:getLocation().x, touch:getLocation().y)
		end
	end
end

return huaijimjHandCardsPanel