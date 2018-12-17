

-- common 为需要在加载游戏时释放的文件, game 为需要加载的游戏文件

GC_GameFiles = {
    common = {
       -- "app.games.common.mediator.MjMediator",
        "app.games.common.ui.gameover.FriendOverView",
        "app.games.common.ui.gameover.FriendTotalOverView",
        },
    game = {
        --"package_src.games.guangdongtuidaohumj.games.MJFanMa",
        --"package_src.games.guangdongtuidaohumj.games.mediator.MjMediator",
        "package_src.games.guangdongtuidaohumj.games.ui.gameover.guangdongtuidaohumjFriendOverView",
        "package_src.games.guangdongtuidaohumj.games.ui.gameover.guangdongtuidaohumjFriendTotalOverView",
        --"package_src.games.guangdongtuidaohumj.games.ui.bglayer.guangdongtuidaohumjBgLayer",
        },
}

