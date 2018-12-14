
package.loaded["app.games.common.common.Constants"] = nil
package.loaded["app.games.common.event.MjEvent"] = nil
package.loaded["app.games.common.init"] = nil
package.loaded["app.games.common.proxy.MjProxy"] = nil
package.loaded["app.games.common.mediator.MjMediator"] = nil
package.loaded["app.games.common.custom.MJCommonDialog"] = nil
package.loaded["app.games.common.custom.MJToast"] = nil
package.loaded["app.games.common.custom.MJLoadingView"] = nil
package.loaded["app.hall.wnds.set.HallSetDialog"] = nil
package.loaded["app.games.common.custom.DismissDeskView"] = nil
package.loaded["app.games.common.ui.gameover.FriendOverView"] = nil
--package.loaded["app.games.common.ui.gameover.FriendTotalOverView"] = nil
package.loaded["app.games.common.hall.FriendRoomEnterInfo"] = nil
package.loaded["app.games.common.hall.FriendRoomCreate"] = nil
package.loaded["app.games.common.ui.bglayer.PlayerChat"] = nil

require("app.games.common.common.Constants")
--require "app.games.common.init"
require "app.games.common.proxy.MjProxy"
require("app.games.common.mediator.MjMediator")
--require("app.games.common.custom.MJCommonDialog")
--require("app.games.common.custom.MJToast")

--require ("app.games.common.custom.MJLoadingView")
require("app.hall.wnds.set.HallSetDialog");
require("app.games.common.custom.DismissDeskView")

require("app.games.common.ui.bglayer.PlayerChat")

package.loaded["app.games.common.CommonAudioConfig"] = nil
require("app.games.common.CommonAudioConfig")
-- common 为需要在加载游戏时释放的文件, game 为需要加载的游戏文件
GC_GameFiles = {
    common = {
        "app.hall.friendRoom.FriendRoomEnterInfo",
        "app.games.common.ui.gameover.FriendTotalOverView",
        },
    game = {
        "package_src.games.maomingmj.ui.gameover.FriendTotalOverView",
        "package_src.games.maomingmj.hall.FriendRoomEnterInfo",
        },
}


