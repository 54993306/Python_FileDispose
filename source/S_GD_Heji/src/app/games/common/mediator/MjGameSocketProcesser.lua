-- 牌局中消息处理

local Define 			= require "app.games.common.Define"
local MjGameSocketProcesser = class("MjGameSocketProcesser", SocketProcesser)
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function MjGameSocketProcesser:ctor()

end

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function MjGameSocketProcesser:dtor()

end

--[[
-- @brief  开始游戏回调函数
-- @param  cmd 命令
-- @param  table 数据
-- @return void
--]]
function MjGameSocketProcesser:handle_gameStart(cmd, data)
	Log.i("MjGameSocketProcesser:handle_gameStart == ", data)
	-- -- 设置开始游戏数据
	MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):setGameStartAllDatas(cmd, data)
	-- -- 设置时间系统数据
	-- MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.CLOCK_SYSTEM):setClockSystemDatas(cmd, data)
	-- -- MjMediator:getInstance():onGameStart()
	-- -- 分发游戏开始通知
	-- MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_START_NTF)
	local datas = {
		command = cmd,
		data    = data,
	}
	-- 检查游戏状态是否需要改变
	MjMediator.getInstance():getStateManager():checkStateChange(datas)
	return true
end

--[[
-- @brief  打牌消息回调函数
-- @param  cmd 命令
-- @param  data 数据
-- @return void
--]]
function MjGameSocketProcesser:handle_playCard(cmd, data)
	Log.i("MjGameSocketProcesser:handle_playCard == ", data)
	-- MjMediator:getInstance():onPlayCard()	
	-- 由于会重复发送数据所以这里做特殊处理
	if data.re == 1 then
		-- or data.plC == 0 then
		-- print("MjGameSocketProcesser:handle_playCard 无效消息")
	else
        if data.ac0 and #data.ac0 == 1 and data.ac0[1] == 31 then
            return;
        end
		-- 分发打牌通知
		-- MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):setPlayCardDatas(cmd, data)
		-- MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_HANDLE_PLAY_CARD_NTF)
		local datas = {
			command = cmd,
			data    = data,
		}

		-- 检查游戏状态是否需要改变
		MjMediator.getInstance():getStateManager():checkStateChange(datas)
	end
	return true
end

--[[
-- @brief  吃碰杠消息回调函数
-- @param  cmd 命令
-- @param  info 数据
-- @return void
--]]
function MjGameSocketProcesser:handle_mjAction(cmd, info)
    Log.i("MjGameSocketProcesser:handle_mjAction == ", info)	
    -- if self.distrFinishFlag then
  --   	MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM):setOperateSystemDatas(cmd, info)
		-- MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACTION_NTF)
	-- else
		
 --    end
 	local datas = {
		command = cmd,
		data    = info,
	}

	if info.acID and 
		(info.acID == enOperate.OPERATE_XIA_PAO 
			or info.acID == enOperate.OPERATE_LAZHUANG 
			or info.acID == enOperate.OPERATE_ZUO 
			or info.acID == enOperate.OPERATE_XIADI) then
		MjMediator.getInstance():getStateManager():handlerLaPaZuoMsg(cmd, info)
	else
		-- 检查游戏状态是否需要改变
		MjMediator.getInstance():getStateManager():checkStateChange(datas)
	end

	return true
end
--[[
-- @brief  补花消息回调函数
-- @param  cmd 命令
-- @param  info 数据
-- @return void
--]]
function MjGameSocketProcesser:handle_flowerAction(cmd, info)
    Log.i("MjGameSocketProcesser:handle_flowerAction == ", info)
    MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.FLOWER_OPERATE_SYSTEM):setFlowerOperateDatas(cmd, info)
    -- MjMediator:getInstance():on_flower()
    -- MjMediator:getInstance():on_otherFlower()
    return true
end
--[[
-- @brief  游戏结束消息回调函数
-- @param  cmd 命令
-- @param  info 数据
-- @return void
--]]
function MjGameSocketProcesser:handle_gameOver(cmd, info)
	Log.i("MjGameSocketProcesser:handle_gameOver == ", info)
	if UIManager:getInstance():getWnd(FriendOverView) then
		Log.i("已经在结算界面了")
		return
	end
    -- MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):setGameOverDatas(cmd, info)
	-- -- MjMediator:getInstance():on_msgGameOver()	
	-- -- 发送游戏结束通知
	-- MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_GAME_OVER_NTF)

	local datas = {
		command = cmd,
		data    = info,
	}
	-- 检查游戏状态是否需要改变
	MjMediator:getInstance():getStateManager():checkStateChange(datas)
	return true

end
--[[
-- @brief  托管消息回调函数
-- @param  cmd 命令
-- @param  info 数据
-- @return void
--]]
function MjGameSocketProcesser:handle_substitute(cmd, info)
	Log.i("MjGameSocketProcesser:handle_substitute == ", info)
	MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):setGameSubstituteDatas(cmd, info)
	-- MjMediator:getInstance():on_substitute()
	-- 分发打牌通知
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_HANDLE_SUB_NTF)
	return true
end

--[[
-- @brief  更新玩家在线状态
-- @param  void
-- @return void
--]]
function MjGameSocketProcesser:handle_repUpdatePlayerLeaveStatus(cmd, info)
	Log.i("MjGameSocketProcesser:handle_repUpdatePlayerLeaveStatus == ", info)
	MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):setPlayeOnlineDatas(cmd, info)
	-- MjMediator:getInstance():on_substitute()
	-- 分发打牌通知
	--MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_HANDLE_SUB_NTF)
	return true
end

--[[
-- @brief  自定义聊天消息回调函数
-- @param  void
-- @return void
--]]
function MjGameSocketProcesser:handle_chat(cmd, info)
    Log.i("MjGameSocketProcesser:handle_chat == ", info)
    MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.CHAT_SYSTEM):setChatCustomInfo(cmd, info)
	-- MjMediator:getInstance():on_msgChat()
	MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_CHAT_USER_MESSAGE_RES)
	return true
end
--[[
-- @brief  默认聊天消息回调函数
-- @param  void
-- @return void
--]]
function MjGameSocketProcesser:handle_defaultChar(cmd, info)
    Log.i("MjGameSocketProcesser:handle_defaultChar == ", info)
    MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.CHAT_SYSTEM):setChatDefaultInfo(cmd, info)
    -- MjMediator:getInstance():on_msgDefaultChar()
    MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_CHAT_DEFAULT_MESSAGE_RES)
end
--[[
-- @brief  恢复游戏回调函数
-- @param  void
-- @return void
--]]
function MjGameSocketProcesser:handle_gameResume(cmd, data)
	Log.i("MjGameSocketProcesser:handle_gameResume ==", data)
	if UIManager:getInstance():getWnd(FriendOverView) then
		Log.i("已经在结算界面了")
		return
	end
    local playSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local msgs = playSystem:getLpzResumeMsgs(data)
    for i, v in ipairs(msgs) do
        self:handle_mjAction(v.cmd, v.msg)
    end
   	MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):setGameStartAllDatas(cmd, data)
	local datas = {
		command = cmd,
		data    = data,
	}
	-- 检查游戏状态是否需要改变
	MjMediator.getInstance():getStateManager():checkStateChange(datas)
	return true
end

function MjGameSocketProcesser:handle_exitRoom(cmd, table)
	MjMediator:getInstance():exitGame()
	return true
end
--[[
-- @brief  拿牌回调函数
-- @param  void
-- @return void
--]]
function MjGameSocketProcesser:handle_dispenseCard(cmd, data)
    Log.i("MjGameSocketProcesser:handle_dispenseCard == ", data)
	-- MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):setDispenseCardDatas(cmd, data)
	-- MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_DISPENSE_START_NTF) 
	local datas = {
		command = cmd,
		data    = data,
	}
	-- 检查游戏状态是否需要改变
	MjMediator.getInstance():getStateManager():checkStateChange(datas)
	return true
end

function MjGameSocketProcesser:handle_roomStart(cmd,table)
	Log.i("------MjGameSocketProcesser:handle_roomStart", table)
	return true	
end

function MjGameSocketProcesser:handle_roomResume(cmd,table)
	Log.i("MjGameSocketProcesser:handle_roomResume == ", table)
	MjProxy:getInstance()._msgCache = {}
    if table.re == 1 then
        -- Toast.getInstance():show("重连成功");
    else
    	MjMediator:getInstance():requestExitRoom()
        MjMediator:getInstance():exitGame()
        Toast.getInstance():show("对局已结束");
    end
	return true
end

function MjGameSocketProcesser:handle_reqSendPoker(cmd,table)
	Log.i("MjGameSocketProcesser:handle_reqSendPoker == ")
	if table.opS and table.opS == -1 then
		Log.i("MjGameSocketProcesser:handle_reqSendPoker erro ")
		SocketManager.getInstance():send(CODE_TYPE_GAME, HallSocketCmd.CODE_SEND_RESUMEGAME,  { plID = MjProxy:getInstance():getPlayId()});
	end
	return true
end
--[[
-- @brief  续局
-- @param  void
-- @return void
--]]
function MjGameSocketProcesser:handle_reqContinue(cmd,table)
	Log.i("MjGameSocketProcesser:handle_reqContinue == ", table)
	if table and  table.usI then
		MjMediator:getInstance():on_continueReady(table.usI)
	end

	-- local datas = {
	-- 	command = cmd,
	-- 	data    = data,
	-- }
	-- -- 检查游戏状态是否需要改变
	-- MjMediator.getInstance():getStateManager():checkStateChange(datas)
	return true
end

function MjGameSocketProcesser:handle_repPaoMaDeng(cmd,table)
	if table.co then
		MjMediator:getInstance():on_showPaoMaDeng(table.co)
	end
	return true
end
--[[
-- @brief  更新财富值函数
-- @param  void
-- @return void
--]]
function MjGameSocketProcesser:handle_repUpdateTakenCash(cmd,table)
	-- 重设财富值
	MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):resetFortune(table)
	return true
end

--支付成功
function MjGameSocketProcesser:recChargeResult(cmd, packetInfo)
--    info = checktable(packetInfo);
--    self.m_delegate:handleSocketCmd(cmd, info);
	kChargeListInfo:dalateApplePayInfo(packetInfo.orI)
    MjMediator:getInstance():on_recChargeResult(packetInfo)
end
--获取订单号
function MjGameSocketProcesser:recOrder(cmd,info)
--    Log.i("MjGameSocketProcesser:recOrder....",info)
    LoadingView.getInstance():hide();
    kGameManager:reCharge(info);
end
-- 散桌
function MjGameSocketProcesser:handle_dismissDesk(cmd,table)
	if table.deI then
		-- if table.deI == MjProxy:getInstance():getPlayId() then
		MjProxy:getInstance():setDeskDismiss(true)
		MjMediator:getInstance():on_dismissDesk(packetInfo)
		-- end
	end
end

-- 服务器通知
function MjGameSocketProcesser:repBrocast(cmd, packetInfo)
    MjMediator:getInstance():repBrocast(packetInfo);
end

--麻将信息提示 1 包牌提示 2 不能胡提示
function MjGameSocketProcesser:repPromptInfo(cmd, packetInfo)
    Log.i("麻将信息提示 1 包牌提示 2 不能胡提示",packetInfo);
	local m_pWidget=nil;
	if(packetInfo.type==1) then --1 包牌提示 2 不能胡提示
	   m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/mjGameCrossband.csb");
	else
	   m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/mjGameFanHuCrossband.csb");
	end 
	display.getRunningScene():addChild(m_pWidget);
		
	local text = ccui.Helper:seekWidgetByName(m_pWidget,"text")
	text:setString(packetInfo.text);
	
	local w = text:getContentSize().width;
	local midPanel = ccui.Helper:seekWidgetByName(m_pWidget,"midPanel")
	local tw = w+35;
	midPanel:setContentSize(cc.size(tw,midPanel:getContentSize().height));
	m_pWidget:setPosition(cc.p(display.width/2,220));
	midPanel:setAnchorPoint(0.5,0.5);
	
	Util.runScaleToHideAction(midPanel,m_pWidget,0.1,6);
end

-- 立即结算
function MjGameSocketProcesser:handle_jieSuanImmediately(cmd, packetInfo)
    Log.i("MjGameSocketProcesser:handle_jieSuanImmediately", packetInfo.pl)
    MjMediator:getInstance():onHandleJieSuanImmediately(packetInfo)
end

-- 接收玩家的定位数据
function MjGameSocketProcesser:repLocationInfo(cmd, packetInfo)
    Log.i("MjGameSocketProcesser:repLocationInfo", packetInfo)
    MjMediator:getInstance():repLocationInfo(packetInfo)
end


MjGameSocketProcesser.s_severCmdEventFuncMap={
	[enMjMsgReadId.MSG_READ_GAME_START] = MjGameSocketProcesser.handle_gameStart;
	[enMjMsgReadId.MSG_READ_PLAY_CARD] = MjGameSocketProcesser.handle_playCard;
	[enMjMsgReadId.MSG_READ_MJ_ACTION] = MjGameSocketProcesser.handle_mjAction;
	[enMjMsgReadId.MSG_READ_GAME_OVER] = MjGameSocketProcesser.handle_gameOver;
	[enMjMsgReadId.MSG_READ_SUBSTITUTE] = MjGameSocketProcesser.handle_substitute;
	[enMjMsgReadId.MSG_READ_GAME_RESUME] = MjGameSocketProcesser.handle_gameResume;
	[HallSocketCmd.CODE_REC_ExitRoom] = MjGameSocketProcesser.handle_exitRoom;
	[HallSocketCmd.CODE_REC_GAMESTART] = MjGameSocketProcesser.handle_roomStart;
	[HallSocketCmd.CODE_REC_RESUMEGAME] =  MjGameSocketProcesser.handle_roomResume;
	[enMjMsgReadId.MSG_READ_DISPENSE_CARD] = MjGameSocketProcesser.handle_dispenseCard;
	[enMjMsgSendId.MSG_SEND_TURN_OUT] = MjGameSocketProcesser.handle_reqSendPoker;
	[enMjMsgReadId.MSG_READ_CONTINUE] = MjGameSocketProcesser.handle_reqContinue;
	[HallSocketCmd.CODE_REC_PAOMADENG] = MjGameSocketProcesser.handle_repPaoMaDeng;
    [enMjMsgReadId.MSG_READ_USER_CAHT] = MjGameSocketProcesser.handle_chat;
    -- [HallSocketCmd.CODE_FRIEND_ROOM_SAYMSG] = MjGameSocketProcesser.handle_chat;
    [enMjMsgReadId.MSG_READ_DEFAULT_CHAT] = MjGameSocketProcesser.handle_defaultChar;
    [enMjMsgReadId.MSG_READ_UPDATE_TAKEN_CASH] = MjGameSocketProcesser.handle_repUpdateTakenCash;
    [enMjMsgReadId.MSG_READ_PLAYER_LEAVE_STATUE] = MjGameSocketProcesser.handle_repUpdatePlayerLeaveStatus;
    
	[enMjMsgReadId.MSG_READ_DISMISS_DESK] = MjGameSocketProcesser.handle_dismissDesk;
    [enMjMsgReadId.MSG_READ_FLOWER] = MjGameSocketProcesser.handle_flowerAction;

    [HallSocketCmd.CODE_REC_GETORDER] = MjGameSocketProcesser.recOrder;
    [HallSocketCmd.CODE_REC_CHARGERESULT]   = MjGameSocketProcesser.recChargeResult;
    [HallSocketCmd.CODE_REC_BROCAST] = MjGameSocketProcesser.repBrocast;
	[enMjMsgReadId.MSG_READ_PROMPT_INFO] = MjGameSocketProcesser.repPromptInfo;
    [enMjMsgReadId.MSG_READ_JIESUAN_IMMEDIATELY] = MjGameSocketProcesser.handle_jieSuanImmediately;
    [HallSocketCmd.CODE_REC_LOCATION] = MjGameSocketProcesser.repLocationInfo;
}

return MjGameSocketProcesser
