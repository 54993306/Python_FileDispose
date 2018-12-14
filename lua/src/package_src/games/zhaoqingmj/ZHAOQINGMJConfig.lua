
package.loaded["app.games.common.common.Constants"] = nil
package.loaded["app.games.common.event.MjEvent"] = nil
package.loaded["app.games.common.proxy.MjProxy"] = nil
package.loaded["app.games.common.mediator.MjMediator"] = nil
package.loaded["app.hall.wnds.set.HallSetDialog"] = nil
package.loaded["app.games.common.custom.DismissDeskView"] = nil
package.loaded["app.games.common.ui.gameover.FriendOverView"] = nil
package.loaded["app.games.common.ui.gameover.FriendTotalOverView"] = nil

-- package.loaded["app.games.common.hall.FriendRoomCreate"] = nil
package.loaded["app.games.common.ui.bglayer.PlayerChat"] = nil

require("app.games.common.common.Constants")
require "app.games.common.proxy.MjProxy"
require("app.games.common.mediator.MjMediator")

-- ÉèÖÃ¶Ô»°¿ò
require("app.hall.wnds.set.HallSetDialog");
require("app.games.common.custom.DismissDeskView")


-- ÅóÓÑ·¿

-- require("app.games.suzhoumj.hall.FriendRoomCreate")
require("app.games.common.ui.bglayer.PlayerChat")

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
	EMPTY_MYSELF_OUT	= 110, -- 空麻将自己打的牌
	EMPTY_LEFT_OUT		= 111, -- 空麻将左邊打的牌
	EMPTY_OTHER_OUT		= 112, -- 空麻将左邊打的牌
	EMPTY_RIGHT_OUT		= 113, -- 空麻将左邊打的牌
}


-- common 为需要在加载游戏时释放的文件, game 为需要加载的游戏文件
GC_GameFiles = {
    common = {
        "app.games.common.ui.gameover.FriendOverView",
        "app.games.common.ui.gameover.FriendTotalOverView",
        },
    game = {
		"package_src.games.zhaoqingmj.games.ui.gameover.zhaoqingmjFriendOverView",
		"package_src.games.zhaoqingmj.games.ui.gameover.zhaoqingmjFriendTotalOverView",
        },
		
}
