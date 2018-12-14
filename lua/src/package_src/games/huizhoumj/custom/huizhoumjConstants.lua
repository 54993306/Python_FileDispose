local currentModuleName = ...
-- import(".EntityDef", currentModuleName) 
-- import(".SystemDef", currentModuleName) 
-- import(".PartDef", currentModuleName) 
-- import(".MessageDef", currentModuleName) 
-- import(".EventDef", currentModuleName) 
-- import(".StateDef", currentModuleName) 
require("app.games.common.common.EntityDef")
require("app.games.common.common.SystemDef")
require("app.games.common.common.PartDef")
require("app.games.common.common.MessageDef")
require("app.games.common.common.EventDef")
require("app.games.common.common.StateDef")




-- 座位的方向，注意:方向是按照逆时针
enSiteDirection = {
	SITE_MYSELF = 1, -- 自己 
	SITE_RIGHT 	= 2, -- 右边 
	SITE_OTHER 	= 3, -- 对面 
	SITE_LEFT 	= 4, -- 左边 
}

-- 门风方向逆时针 东-南-西-北
enDoorWind = {
	EAST 	= 1, -- 东 
	SOUTH 	= 2, -- 南
	WEST 	= 3, -- 西 
	NORTH   = 4, -- 北
}
enHandCardPos = {
	-- 手牌的起始位置
	HAND_CARD_OFFSET_X 		= 70,	-- 手牌X轴起始位置
	HAND_CARD_OFFSET_Y		= 120,  -- 手牌Y轴起始位置
	-- 凸起麻将的高度
	STANDING_HEIGHT   		= 30, 	-- 选中的牌上升的高度
	HAND_CARD_LAST_OFFSET   = 16,   -- 最后一个牌偏移量
}
-- 组件路径
enComponentName = {
	BUTTON_ACTION           = "app.games.common.ui.common.ButtonAction",
}
-- 玩家的操作
enOperate = {
	OPERATE_CHI 		= 1,	-- 吃
	OPERATE_PENG 		= 2,	-- 碰
	OPERATE_MING_GANG 	= 3,	-- 明杠
	OPERATE_JIA_GANG    = 4,	-- 加杠
	OPERATE_AN_GANG     = 5,    -- 暗杠
	OPERATE_TING		= 6,	-- 听
	OPERATE_DIAN_PAO_HU = 7,	-- 点炮胡
	OPERATE_ZI_MO_HU    = 8,	-- 自模胡
	OPERATE_QIANG_GANG_HU    = 9,	-- 抢杠胡
	OPERATE_DI_HU     		 = 10, -- 地胡
    OPERATE_DIAN_DI_HU       = 11, -- 点炮地胡
    OPERATE_DI_XIA_HU       = 12, -- 地下胡
    OPERATE_GANG_KAI       = 13, -- 杠开
	OPERATE_BU_HUA      = 23,   -- 补花
	OPERATE_XIA_PAO     = 29,	-- 下跑
	OPERATE_ZHUA_PAI    = 100,  -- 抓牌
    OPERATE_ASK_BU_HUA    = 99,  -- 问询补花
	OPERATE_GUO    	 	= 101,  -- 过
	OPERATE_JIA_BEI 	= 102,	-- 加倍
	OPERATE_MISSION     = 103,  -- 任务
	OPERATE_BU_TING     = 110,	-- 不听
    OPERATE_CANCEL_TING     = 111,  -- 撤销听牌状态
	OPERATE_TIAN_TING   = 34,	-- 天听
	OPERATE_TIAN_HU     = 35,	-- 天胡
	OPERATE_DIAN_TIAN_HU     = 36,	-- 点炮天胡
    OPERATE_CHANGE_FANZI = 40,  -- 改变翻子的值
    OPERATE_CHUPAI = 31,  -- 改变翻子的值
    OPERATE_DINGQUE = 37,        --定缺
    OPERATE_TING_RECONNECT = 38,        --恢复对局后的听牌提示

    OPERATE_LAZHUANG = 32, -- 下拉（闲家）
    OPERATE_ZUO = 33, -- 坐（庄家）
    OPERATE_XIADI = 39, -- 下底（所有人）

    OPERATE_JIADI=39, --加底
    OPERATE_CAN_OUT_CARD=41, --可以出牌	
    OPERATE_CLOCK_POINTER  = 50,	--用来在对局指示谁出牌
    OPERATE_BAO_DA_GE  = 51,	--报大哥
    OPERATE_YANGMA = 94, ---养马
}

--  胡牌类型
enHuType = 
{
    TYPE_NONE = 0,                  --  无
    TYPE_DI_XIA_SHI_SAN_YAO = 1,    --  地下十三幺
    TYPE_SHI_FENG = 2,              --  十风
}

-- 时钟类型
enClockType = {
	PLAY_CARD 	= 1, 	-- 打牌时钟
	ACTION 		= 2, 	-- 操作时钟
}
-- 用户托管状态
enUserStatus = {
	NORMAL 		= 0, 	-- 正常状态
	SUBSTITUTE  = 1, 	-- 托管状态
}

-- 层级定义
enZorderDef = {
	GAME_LAYER 	= 1, 	-- 游戏容器层
	BG_LAYER 	= 2, 	-- 游戏背景层
	PLAY_LAYER 	= 3, 	-- 游戏层
	CHAT_LAYER 	= 4, 	-- 聊天层
	OPERATE_LAYER = 5, 	-- 吃碰杠操作层
	SUBSTITUTE_LAYER = 6,	-- 托管层
}

-- 个人结果 re
enResult =
{
    DEFAULT = 0, -- 默认
    WIN 	= 1, -- 赢
    FAILED 	= 2, -- 输
    BUREAU  = 3, -- 流局
    FANGPAO = 4, -- 放炮
	FANGHEIPAO = 6, -- 放黑炮
};

-- 结算类型 wi
enGameOverType =
{
    ZI_MO 		= 1, -- 自摸
    FANG_PAO 	= 2, -- 放炮
    BUREAU  	= 3, -- 流局
    ERROR  	    = 4, -- 出错
    FANGHEIPAO  = 6, -- 放黑炮
    QIANG_GANG_HU = 11, -- 抢杠胡
    GANG_HOU_PAO  = 12, -- 杠后炮
};

enRadioButtonMode =
{
    TEXTURE = 1,  -- 图片模式
    FRAME   = 2,  -- 模板模式
    TEXT    = 3,  -- 文字模式
    CHANGE  = 4,  -- 替换底图模式
};
-- 手牌对3求余的结果
enHandCardRemainder =
{
    PROHIBIT_PLAY   = 1,  -- 禁止打牌
    CAN_PLAY        = 2,  -- 可以打牌
};

SELF_HAND_CARD_WIDTH 	= 89 -- 自己手牌宽度定义
LEFT_HAND_CARD_HEIGHT   = 30 -- 左边宽度定义
RIGHT_HAND_CARD_HEIGHT  = 30 -- 右边宽度定义
OTHER_HAND_CARD_WIDTH   = 30 -- 对家宽度定义

LAI_ZI_VALUE = 0 -- 癞子默认值设置为0确保癞子优先排序
LAI_ZI_COLOR = cc.c3b(140, 140, 140)


local pai_png = {
	{ "1w.png", "2w.png", "3w.png", "4w.png", "5w.png", "6w.png", "7w.png", "8w.png", "9w.png" },
	{ "1t.png", "2t.png", "3t.png", "4t.png", "5t.png", "6t.png", "7t.png", "8t.png", "9t.png" },
	{ "1b.png", "2b.png", "3b.png", "4b.png", "5b.png", "6b.png", "7b.png", "8b.png", "9b.png" },
	{ "f_dong.png", "f_nan.png", "f_xi.png", "f_bei.png", "f_zhong.png", "f_fa.png", "f_bai.png" },
	{ "h_chun.png", "h_xia.png", "h_qiu.png", "h_dong.png","h_mei.png", "h_lan.png", "h_ju.png", "h_zhu.png" },
	{ "t_dabaiban.png", "t_baida.png" } -- t代表特殊 -- 
}

function getCardPngByValue(value)
	local pai = pai_png[math.modf(value / 10)][value % 10]
	return pai
end
