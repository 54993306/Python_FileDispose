enMjType = {
	MYSELF_NORMAL 		= 1, -- 自己的正常牌
	MYSELF_PENG   		= 2, -- 自己碰，杠牌
	MYSELF_PENG_TANG    = 3, -- 自己碰，杠躺下
	MYSELF_OUT    		= 4, -- 自己打出去的牌
	LEFT_PENG     		= 5, -- 左边碰，杠的牌
	LEFT_PENG_TANG     	= 6, -- 左边碰，杠躺下的牌
	LEFT_OUT      		= 7, -- 左边打出去的牌
	RIGHT_PENG    		= 8, -- 右边碰，杠的牌
	RIGHT_PENG_TANG    	= 9, -- 右边碰，杠躺的牌
	RIGHT_OUT     		= 10, -- 右边打出去的牌
	OTHER_PENG    		= 11, -- 其他碰，杠的牌
	OTHER_PENG_TANG    	= 12, -- 其他碰，杠躺的牌
	OTHER_OUT     		= 13, -- 其他打出去的牌
	-- 从101开始就是空的麻将
	EMPTY_MYSELF_GANG 	= 101, -- 空麻将自己杠的牌
	EMPTY_RIGHT_GANG  	= 102, -- 空麻将右杠的牌
	EMPTY_RIGHT_IDLE  	= 103, -- 空麻将右立的牌
	EMPTY_LEFT_GANG   	= 104, -- 空麻将左杠的牌
	EMPTY_LEFT_IDLE   	= 105, -- 空麻将左立的牌
	EMPTY_OTHER_GANG  	= 106, -- 空麻将其他杠的牌
	EMPTY_OTHER_IDLE  	= 107, -- 空麻将其他立的牌
	EMPTY_SHU_PAI  		= 108, -- 空麻将竖的牌
	EMPTY_HENG_PAI  	= 109, -- 空麻将横的牌
}

-- 麻将状态
enMjState = {
	MJ_STATE_NORMAL 		= 1,
	MJ_STATE_SELECTED 		= 2,
	MJ_STATE_TOUCH_INVALID 	= 3,
	MJ_STATE_TOUCH_VALID    = 4,
	MJ_STATE_ALREADY_SELECTED = 5, -- 已经选中
    MJ_STATE_TOUCH_OUT      = 6,   -- 跟选中的麻将相同
    MJ_STATE_CANT_TOUCH    	= 44, -- 永久不能被选中
}
-- 摆放方式相关
enMjExhibitionStyle = {
	EXHIBITION_CHI 			= 1, -- 吃
	EXHIBITION_PENG 		= 2, -- 碰
	EXHIBITION_MING_GANG 	= 3, -- 明杠
	EXHIBITION_AN_GANG 	    = 4, -- 暗杠
	EXHIBITION_JIA_GANG 	= 5, -- 加杠
}

-- 实体类型
enEntityType = {
	INVALID_TYPE = 0, -- 无效类型
	PLAYER       = 1, -- 玩家
	HAND_MJ      = 2,-- 麻将手牌
}

-- 生物实体属性
enCreatureEntityProp = {
	USERID  = 1, 	-- 用户id
	NAME 	= 2,	-- 名字  
	LEVEL   = 3,    -- 等级
	GENDER  = 4,    -- 性别
	FORTUNE = 5,    -- 财富
	VIP_EXP = 6,    -- VIP经验
	VIP     = 7,    -- VIP等级
	ICON_ID = 8,    -- 头像 
	WIN     = 9,    -- 赢
	WIN_PRE = 10,   -- 之前赢
	TOTAL   = 11,   -- 总
	SEX     = 12,   -- 性别
	FLOWER  = 13,   -- 花牌
	BANKER  = 14,   -- 庄家或者是先出牌的玩家
	DOOR_WIND = 15, -- 门风方便显示哪家打牌
	USER_STATUS = 16, 	-- 玩家状态
	TING_STATUS = 17, 	-- 听状态
	SITE 	 = 18, 		-- 座次
	OUT_CARD = 19,  -- 打出去的牌列表
	CARD_NUM = 20,  -- 手牌数
	IP 		 = 21,  -- IP

	JING_DU  = 22,  -- 经度  
	WEI_DU   = 23,  -- 纬度  
	-- 动作相关属性
	OPERATE_CARD 	= 24,   -- 动作牌第一个牌
	OPERATE_TYPE 	= 25,   -- 动作类型
	BEOPERATER_ID 	= 26,  -- 被操作玩家的用户id
	ACTION_CARD 	= 27,    -- 动作的牌
	DINGQUE_VAL 	= 28,    -- 定缺的值
	MONEY_NEI_VAL 	= 29,    -- 园内/体内 财富
	MONEY_WAI_VAL 	= 30,    -- 园外/体外 财富
	requestH 		= 31,			--是否同意黄庄
	baopai			= 32,			--是否已经包牌了
	baopaiPlayCard	= 33,			--标记包牌的牌

	XIA_DI_NUM		= 34,	--下了多少底
	XIA_LA_NUM		= 35,	--下多少拉
	XIA_PAO_NUM		= 36,   --下多少跑
	XIA_ZUO_NUM		= 37,   --下多少坐

	BET  = 34,  -- 下注
	OPERATE_CARD_LIST 	= 40,   -- 动作牌数组

	LOCATION_TIME = 51,    --定位取到的时间

	HAVE_PLAY_CARD = 80,--是否打过牌了

	RESUME_CHICKEN  = 90, -- 恢复对局的鸡牌

	XUANPAI_VALUE = 98, 	-- 选的牌
	HUANPAI_VALUE = 99, 	-- 收到换的牌
	
	LOCATION_TIME = 51    --定位取到的时间
}

-- 物体属性
enGoodsProp = {
	VALUE  	= 1, 	-- 麻将值
	NUMBER  = 2, 	-- 数量
}

