-------------------------------------------------------------
--  @file   StateDef.lua
--  @brief  状态定义
--  @author Zhu Can Qin
--  @DateTime:2016-09-08 18:14:54
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

-- 生物实体状态
enCreatureEntityState = {
	SUBSTITUTE 			= 1, -- 托管
	TING    			= 2, -- 听
	GUAN 				= 3, --关
	TIANTING    		= 4, -- 听
	JIAOTING			= 4, -- 叫听(用的是天听的字段)
	ONLINE				= 5, -- 在线状态
	
	GAME_STATUS = 100, -- 游戏状态
}

-- 托管消息回来的状态
enSubstitusStatus = {
	CANCEL 		= 0, 	-- 取消托管状态
	SUBSTITUTE	= 1, 	-- 托管状态
}
-- 在线消息回来的状态
enOnlineStatus = {
	ONLINE 		= 0, 	-- 在线状态
	OFFLINE		= 1, 	-- 离线状态
}

-- 听的状态
enTingStatus = {
	TING_FALSE	= 0, 	-- 不听
	TING_TRUE	= 1, 	-- 听
	TING_BTN_ON = 2,    -- 听按钮开
	TING_BTN_OFF = 3,        -- 听按钮关
	TIAN_TING_BTN_ON = 4,    -- 听按钮开
	TIAN_TING_BTN_OFF = 5,   -- 听按钮关
}

-- 游戏状态
enGamePlayingState = {
	STATE_IDLE      = 0, -- 空闲状态
	STATE_START		= 1, -- 开始状态
	STATE_RESUME    = 2, -- 恢复对局状态
	-- STATE_BUHU		= 3, -- 补花状态
	-- STATE_ACTION    = 4, -- 弹出动作状态
	STATE_ACT_ANIMATE = 5, 	-- 播放动作动画状态
	STATE_PLAY_CARD = 6, 	-- 打牌状态
	STATE_DISTR     = 7, 	-- 拿牌状态
	STATE_GAME_OVER = 8, 	-- 结算状态
	STATE_CONTINUE  = 9, 	-- 续局状态
}