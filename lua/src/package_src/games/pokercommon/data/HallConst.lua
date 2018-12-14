--
-- Author: Jinds
-- Date: 2017-11-11
-- 主要是大厅那边的一些常量定义
--

COMNONDIALOG_TYPE_NETWORK = 1; --网络异常
COMNONDIALOG_TYPE_KICKED = 2; --网络异常

POKERCONST_EVENT_NETDISPATCH = "PokerConst_EVENT_NETDISPATCH" --网络层消息透传事件
POKERCONST_EVENT_THRESHOLD = "PokerConst_EVENT_THRESHOLD" --网络层队列派发开关事件
----------------------------------------------
--@以下全局变量从朋友房拷贝过来
--@begin
-------------------------------------------

CODE_TYPE_SYS = 0;                 -- 系统
CODE_TYPE_HALL = 1;					-- 大厅
CODE_TYPE_ROOM = 2;					-- 房间
CODE_TYPE_GAME = 3;					-- 对局
CODE_TYPE_PROP = 4;					-- 道具
CODE_TYPE_USER = 5;        			-- 用户相关
CODE_TYPE_BROCAST = 6;				-- 通知
CODE_TYPE_CHARGE_COIN = 7;			-- 兑换钻石   (表示活动服的连接)
CODE_TYPE_MALL = 7;                 -- 兑换商城
CODE_TYPE_CHARGE = 9;              -- 充值
CODE_TYPE_CLUB = 10;              -- 亲友圈
if IS_IN_DATING_GAME then
    CODE_TYPE_GOLD_HALL = 1;		   -- 钻石场大厅
    CODE_TYPE_GOLD_ROOM = 2;		   -- 钻石场房间
    CODE_TYPE_GOLD_GAME = 3;		   -- 钻石场对局
    CODE_TYPE_GOLD_PROP = 4;		   -- 钻石场道具
    CODE_TYPE_GOLD_USER = 5;		   -- 钻石场用户相关
else
    CODE_TYPE_GOLD_HALL = 1001;		   -- 钻石场大厅
    CODE_TYPE_GOLD_ROOM = 1002;		   -- 钻石场房间
    CODE_TYPE_GOLD_GAME = 1003;		   -- 钻石场对局
    CODE_TYPE_GOLD_PROP = 1004;		   -- 钻石场道具
    CODE_TYPE_GOLD_USER = 1005;		   -- 钻石场用户相关
end


CODE_TYPE_INSERT = 20;              -- 插入
CODE_TYPE_UPDATE = 21;              -- 更新
CODE_TYPE_DELETE = 22;              -- 删除

CODE_HEARTBEAT = 255;              -- 心跳

CHATTYPE = {
    CUSTOMCHAT = 0,
    VOICECHAT = 1,
}

-- 开始游戏入口
StartGameType =
{
    NONE = 0,
    -- 未知状态
    FIRENDROOM = 1,
    -- 朋友开房
    MATCH = 2,-- 比赛
}

--朋友房玩家付费类型
PAYTYPE={  
    PAYTYPE0 = 0,--AA付费
    PAYTYPE1 = 1, --房主付费
    PAYTYPE2 = 2,--大赢家付费
    PAYTYPE3 = 3,--AA付费

}




----------------------------------------------
--@end
-------------------------------------------
