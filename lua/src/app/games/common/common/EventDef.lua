-- 麻将游戏过程中的事件
enMjPlayEvent =
{
	GAME_PLAY_DISTR_FINISH_NTF 		= "MJ.GAME.PLAY.DISTRFINISHNTF", 	-- 游戏中发牌结束通知
	GAME_PLAY_PUT_OUT_FINISH_NTF 	= "MJ.GAME.PLAY.PUTOUTFINISHNTF", 	-- 游戏中出牌落地通知
	GAME_PLAY_START_NTF				= "MJ.GAME.PLAY.STARTNTF",          -- 开始游戏通知
	GAME_PLAY_RESUME_NTF			= "MJ.GAME.PLAY.RESUMENTF",         -- 恢复游戏通知
	GAME_PLAY_CARD_NTF				= "MJ.GAME.PLAY.CARDNTF",           -- 打牌通知
	GAME_PLAY_ACTION_NTF			= "MJ.GAME.PLAY.ACTIONNTF",         -- 执行动作通知
	GAME_PLAY_BUHUA_NTF  			= "MJ.GAME.PLAY.BUHUANTF",          -- 补花动作通知
	GAME_PLAY_GAME_OVER_NTF  		= "MJ.GAME.PLAY.GAMEOVERNTF",       -- 游戏结束通知
	GAME_PLAY_DISPENSE_NTF  		= "MJ.GAME.PLAY.DISPENSENTF",       -- 发牌通知
	GAME_PLAY_ROOM_START_NTF  		= "MJ.GAME.PLAY.ROOMSTARTNTF",      -- 进入房间通知
	GAME_PLAY_ROOM_RESUME_NTF  		= "MJ.GAME.PLAY.ROOMRESUMENTF",     -- 恢复房间通知
	GAME_PLAY_TRICKS_END_NTF  		= "MJ.GAME.PLAY.TRICKSENDNTF",      -- 骰子结束通知
	GAME_PLAY_RUN_CARD_NTF  		= "MJ.GAME.PLAY.RUNCARD.NTF",       -- 运行打牌动画通知
	GAME_SELECTED_TING_CARD_NTF 		= "MJ.SELECTED.TING.CARD.NTF",			-- 选中麻将通知
	GAME_CANCEL_SELECTED_TING_CARD_NTF   = "MJ.CANCEL.SELECTED.TING.CARD.NTF",	-- 取消选中麻将通知
	GAME_TING_ARROW_NTF 			= "MJ.TING.ARROW.NTF",				-- 听牌时显示或隐藏箭头
	GAME_SELECTED_CHAHU_NTF 		= "MJ.SELECTED.CHAHU.NTF",			-- 选中查胡通知
	GAME_CANCEL_SELECTED_CHAHU_NTF  = "MJ.CANCEL.SELECTED.CHAHU.NTF",	-- 取消选中查胡通知
    GAME_SELECTED_CHAPAI_NTF        = "MJ.SELECTED.CHAPAI.NTF",         -- 选中查打出去的麻将
    GAME_CANCEL_SELECTED_CHAPAI_NTF = "MJ.CANCEL.SELECTED.CHAPAI.NTF",  -- 取消查到的牌
	GAME_SET_CHAHU_BUTTON_STATUS_NTF = 'MJ.SET.CHAHU.BUTTON.STATUS.NTF', 	--摸牌的时候，不显示胡牌提示按钮
	GAME_SET_ENTER_FOREGROUND_NTF 	= "MJ.SET.ENTER.FOREGROUND.NTF",		--获取返回游戏通知
}
-- 麻将操作事件
enMjOperateEvent = {
	OPERATE_CHI 		= "MJ.OPERATE.CHI", 		-- 吃
	OPERATE_PENG 		= "MJ.OPERATE.PENG", 		-- 碰
	OPERATE_MING_GANG 	= "MJ.OPERATE.MINGGANG", 	-- 明杠
	OPERATE_AN_GANG 	= "MJ.OPERATE.ANGANG", 		-- 暗杠
	OPERATE_JIA_GANG 	= "MJ.OPERATE.JIAGANG", 	-- 加杠
	OPERATE_TING 		= "MJ.OPERATE.TING", 		-- 听
	OPERATE_TIAN_TING 	= "MJ.OPERATE.TIANTING", 	-- 天听
	OPERATE_DIAN_PAO_HU = "MJ.OPERATE.DIANPAOHU",	-- 点炮胡
	OPERATE_ZI_MO_HU    = "MJ.OPERATE.ZIMOHU",		-- 自模胡
	OPERATE_QIANG_GANG_HU = "MJ.OPERATE.QIANGGANGHU",		-- 抢杠胡
	OPERATE_BU_HUA      = "MJ.OPERATE.BUHUA",   	-- 补花
	OPERATE_XIA_PAO     = "MJ.OPERATE.XIAPAO",		-- 下跑
	OPERATE_GUO    	 	= "MJ.OPERATE.GUO",  		-- 过
	OPERATE_JIA_BEI 	= "MJ.OPERATE.JIABEI",		-- 加倍
	OPERATE_MISSION     = "MJ.OPERATE.MISSION",  	-- 任务
	OPERATE_BU_TING     = "MJ.OPERATE.BUTING",		-- 不听
}

-- 麻将ui事件
enMjEventUi =
{
	GAME_OVER_PANEL_DETAIL_BTN 	= "MJ.UI.GAMEOVERPANELDETAILBTN", 	-- 更新详情按钮
	GAME_CLOSE_DETAIL_PANEL_BTN = "MJ.UI.GAMECLOSEDETAILPANELBTN",	-- 详细信息关闭按钮
}
-- 麻将游戏通知
enMjNtfEvent = {
	GAME_TRICKS_END_NTF 	= "MJ.TRICKS.END.NTF", 			-- 打骰子结束通知
	GAME_HANDLE_PLAY_CARD_NTF = "MJ.HANDLE.PLAY.CARD.NTF", 	-- 打牌消息回来通知
	GAME_CANCEL_SUB_NTF     = "MJ.CANCEL.SUB.NTF", 			-- 取消托管通知
	GAME_HANDLE_SUB_NTF     = "MJ.HANDLE.SUB.NTF", 			-- 托管通知
	GAME_ACTION_NTF         = "MJ.ACTION.NTF",	 			-- 动作通知
	GAME_ACTION_TIME_OUT_NTF    = "MJ.ACTION.TIME.OUT.NTF",	-- 动作操作超时通知
	GAME_GAME_OVER_NTF      = "MJ.GAME.OVER.NTF",			-- 游戏结束通知
	GAME_TING_NTF      		= "MJ.TING.NTF",				-- 听牌通知
	GAME_TIAN_TING_NTF      = "MJ.TIAN.TING.NTF",			-- 天听通知

	GAME_START_NTF 			= "MJ.START.NTF",				-- 游戏开局通知
	GAME_START_FINISH_NTF 	= "MJ.START.FINISH.NTF", 		-- 开局结束通知

	GAME_RESUME_START_NTF 	= "MJ.RESUME.START.NTF",		-- 游戏开始恢复通知
	GAME_RESUME_FINISH_NTF 	= "MJ.RESUME.FINISH.NTF",		-- 游戏结束恢复通知

	GAME_PUT_OUT_START_NTF  = "MJ.PUT.OUT.START.NTF", 		-- 打牌开始通知
	GAME_PUT_OUT_FINISH_NTF = "MJ.PUT.OUT.FINISH.NTF", 		-- 打牌落地通知

	GAME_ACTION_START_NTF   = "MJ.ACTION.START.NTF",		-- 操作栏显示通知
	GAME_ACTION_FINISH_NTF  = "MJ.ACTION.FINISH.NTF",		-- 操作栏隐藏通知

	GAME_ACT_ANIMATE_START_NTF   = "MJ.ACT.ANIMATE.START.NTF",	-- 操作动画开始通知
	GAME_ACT_ANIMATE_FINISH_NTF  = "MJ.ACT.ANIMATE.FINISH.NTF",	-- 操作动画结束通知

	-- GAME_BUHUA_START_NTF    = "MJ.BUHUA.START.NTF",		    -- 补花开始通知
	-- GAME_BUHUA_FINISH_NTF   = "MJ.BUHUA.FINISH.NTF",		-- 补花结束通知

	GAME_DISPENSE_START_NTF = "MJ.DISPENSE.START.NTF",		-- 开始拿牌通知
	GAME_DISPENSE_FINISH_NTF= "MJ.DISPENSE.FINISH.NTF",		-- 结束拿牌通知

	GAME_OVER_START_NTF 	= "MJ.OVER.START.NTF",			-- 开始结算通知
	GAME_OVER_FINISH_NTF	= "MJ.OVER.FINISH.NTF",			-- 结束结算通知

	GAME_CONTINUE_START_NTF 	= "MJ.CONTINUE.START.NTF",	-- 开始续局通知
	GAME_CONTINUE_FINISH_NTF	= "MJ.CONTINUE.FINISH.NTF",	-- 结束续局通知

	GAME_CHAT_USER_MESSAGE_RES   	= "MJ.CHAT.USER.MESSAGE.RES.NTF",    	-- 聊天用户信息返回通知
	GAME_CHAT_DEFAULT_MESSAGE_RES   = "MJ.CHAT.DEFAULT.MESSAGE.RES.NTF",    -- 聊天自定义信息返回通知
	GAME_GUAN_NTF = "MJ.GUAN.NTF",
	GAME_CHECK_START_NTF = "MJ.CHECK.START.NTF", -- 检测是否开局游戏
	GAME_CHECK_RESUME_NTF = "MJ.CHECK.RESUME.NTF", -- 检查恢复牌局时候的发牌结束
	GAME_TING_SHOW_ANGANG_NTF="MJ.TING.SHOW.ANGANG.NTF",  --听牌后显示暗杠的那张牌（没报听之前，暗杠不会显示出来）
}

-- 实体事件
enEntityEvent = {
	ENTITY_PROP_CHANGED_NTF = "ENTITY.PROP.CHANGED.NTF", 	-- 实体属性改变消息
	ENTITY_STATE_CHANGED_NTF = "ENTITY.STATE.CHANGED.NTF", 	-- 实体状态改变消息
}

--region *.lua
--Date 2015/11/11
--麻将事件定义
local prefixFlag = "MJ_EVENT_"
MJ_EVENT =
{
	MJ_ENTRY			= prefixFlag .. "MjEntry",				--进入麻将
	HALL_ENTRY			= prefixFlag .. "HallEntry",			--进入大厅
	GAME_ENTRY			= prefixFlag .. "GameEntry",			--进入房间

	GAME_msgGameStart	= prefixFlag .. "GAME_gameStart",		--开始游戏
	GAME_startAniEnd	= prefixFlag .. "GAME_startAniEnd",		--开局动画结束
	GAME_distrubuteEnd	= prefixFlag .. "GAME_distrubuteEnd",	--发牌结束
	--GAME_jiaoEnd		= prefixFlag .. "GAME_jiaoEnd",			--叫牌结束
	GAME_msgFlower		= prefixFlag .. "GAME_flowerMsg",		--补花
	GAME_putDownMj		= prefixFlag .. "GAME_putDownMj",		--麻将落地
	--GAME_clockPoint		= prefixFlag .. "GAME_clockPoint",		--闹钟指针
	GAME_delTingQuery	= prefixFlag .. "GAME_delTingQuery",	--移除听牌查询
	GAME_enterError		= prefixFlag .. "GAME_enterError",		--进入房间失败



	GAME_msgPlayCard	= prefixFlag .. "GAME_playCard",		--收到打牌消息
	GAME_msgAction		= prefixFlag .. "GAME_action",			--收到特殊操作消息
    GAME_msgFlowAction  = prefixFlag .. "GAME_flowaction",      --收到补花操作消息
	GAME_dispense		= prefixFlag .. "GAME_dispense",			--收到摸牌消息
	GAME_msgSubstitute	= prefixFlag .. "GAME_msgSubstitute",	--收到托管消息
	GAME_msgCommonOver  = prefixFlag .. "GAME_msgCommonOver",	--收到通用结算
	GAME_msgGameOver	= prefixFlag .. "GAME_msgGameOver",		--收到结算消息
	GAME_msgTingQuery	= prefixFlag .. "GAME_msgTingQuery",	--收到听牌查询消息
	GAME_msgMission		= prefixFlag .. "GAME_msgMission",		--收到任务消息
	GAME_msgUserInfo	= prefixFlag .. "GAME_msgUserInfo",		--收到玩家资料消息
	GAME_msgChat		= prefixFlag .. "GAME_msgChat",			--收到聊天消息
	GAME_msgProp		= prefixFlag .. "GAME_msgProp",			--收到道具消息
    GAME_msgBuyProp     = prefixFlag .. "GAME_msgBuyProp",      --收到购买互动道具消息
	GAME_msgResume		= prefixFlag .. "GAME_msgResume",		--收到恢复对局消息
	MSG_SEND			= prefixFlag .. "MsgSend",				--发送消息
	GAME_dingque_Anim_start			= prefixFlag .. "dingque_Anim_start",				--定缺动画开始
	GAME_dingque_Anim_finsh			= prefixFlag .. "dingque_Anim_finsh",				--定缺动画结束
	GAME_LAPAOZUO_EVENT				= prefixFlag .. "lapaozuo_event",					-- 拉跑坐事件

	GAME_REFRESH_OPERATOR_OVER_TIME				= prefixFlag .. "refresh_op_over_time",					-- 根据手牌更新出牌超时
	GAME_setRuleVisible = prefixFlag .. "GAME_setRuleVisible",	--设置规则可见性
}
-- 麻将ui事件
enMjEventUi =
{
	GAME_OVER_PANEL_DETAIL_BTN 	= "MJ.UI.GAMEOVERPANELDETAILBTN", 	-- 更新详情按钮
	GAME_CLOSE_DETAIL_PANEL_BTN = "MJ.UI.GAMECLOSEDETAILPANELBTN",	-- 详细信息关闭按钮
}
