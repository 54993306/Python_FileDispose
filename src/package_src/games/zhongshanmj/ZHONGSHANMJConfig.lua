-- common 为需要在加载游戏时释放的文件, game 为需要加载的游戏文件
GC_GameFiles = {
    common = {
        "app.games.common.ui.gameover.FriendOverView",
        "app.games.common.ui.gameover.FriendTotalOverView",
        -- "app.hall.friendRoom.FriendRoomCreate",
        "app.games.common.ui.bglayer.GameUIView",
        },
    game = {
        "package_src.games.zhongshanmj.games.ui.gameover.FriendOverView",
        "package_src.games.zhongshanmj.games.ui.gameover.FriendTotalOverView",
        -- "package_src.games.zhongshanmj.hall.FriendRoomCreate",
        "package_src.games.zhongshanmj.games.MJFanMa",
        "package_src.games.zhongshanmj.games.ui.bglayer.GameUIView",
        },
}


-- HallSocketCmd.CODE_REC_USERDATA  = 22021;  -- 游戏中分数发生改变

