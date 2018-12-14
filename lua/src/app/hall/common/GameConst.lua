TRAN_RIGHT_TO_LEFT = 1;
PUSH_BOTTOM_TO_TOP = 11;

RECHARGE_PATH_FAST = 1; --快充（进入房间时豆不够），统计游戏ID、房间ID
RECHARGE_PATH_STORE = 2; --商城充值（更多充值）
RECHARGE_PATH_BREAK = 3; --破产时弹出的充值（游戏中豆不够、游戏结束时豆不够提示），统计游戏ID、房间ID
RECHARGE_PATH_ROOM = 4; --游戏中充值（游戏桌面），统计游戏ID、房间ID

NETWORK_NORMAL = 1; --网络正常
NETWORK_EXCEPTION = 0; --网络异常

COMNONDIALOG_TYPE_NETWORK = 1; --网络异常
COMNONDIALOG_TYPE_KICKED = 2; --网络异常

WND_ZORDER_COMMONDDIALOG = 1000; --对话框显示层级
WND_ZORDER_TOAST = 1001; --toast显示层级
WND_ZORDER_LOADINGVIEW = 1002; --正在加载中显示层级
-- 聊天类型
enChatType = {
	DEFAULT = 0, -- 默认 
	FACE 	= 1, -- 表情 
	PHRASE	= 2, -- 短语 
	MAGIC   = 3, -- 魔法
}
