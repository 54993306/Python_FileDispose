--
-- Author: Jinds
-- Date: 2017-11-06 11:01:16
-- 为方便扩展，游戏继承过去增加属性的时候 属性ID从100开始
-- 注意如果某属性本文件已有定义，自己继承过去的就不要覆盖掉了
--

local BasePlayerDefine = {}

BasePlayerDefine.USERID 	= 1		-- 用户id
BasePlayerDefine.NAME 		= 2		-- 名字
BasePlayerDefine.LEVEL   	= 3    	-- 等级
BasePlayerDefine.SEX  		= 4    	-- 性别
BasePlayerDefine.MONEY 		= 5	    -- 钻石
BasePlayerDefine.ICON_ID 	= 8	    -- 头像 
BasePlayerDefine.CARD_NUM 	= 9		-- 手牌数
BasePlayerDefine.HAND_CARDS = 10	-- 手牌
BasePlayerDefine.IP    		= 11	-- IP
BasePlayerDefine.BANKER		= 12	-- 庄家
BasePlayerDefine.SITE 		= 13	-- 座位
BasePlayerDefine.USER_STATUS= 14	-- 玩家状态
BasePlayerDefine.JING_DU	= 15	-- 经度
BasePlayerDefine.WEI_DU		= 16	-- 纬度
BasePlayerDefine.BET 		= 17	-- 下注数
BasePlayerDefine.FIRST_PLAY	= 18	-- 是否第一個操作的人
BasePlayerDefine.LOCATION_TIME = 19	-- 获取到定位的时间


return BasePlayerDefine