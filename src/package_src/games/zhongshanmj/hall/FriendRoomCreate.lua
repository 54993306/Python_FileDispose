--
-- Author: Van
-- Date: 2017-06-28 11:21:20
--
require("app.hall.friendRoom.FriendRoomCreate")

function FriendRoomCreate:areaSelectBack()
    local gameId = kFriendRoomInfo:getGameID()
    local bgPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "guizhe_ScrollView")
    bgPanel:removeAllChildren()
    if GC_GameTypes[gameId] then
        loadGame(gameId)
        local tmpPath = "package_src.games." .. GC_GameTypes[gameId] .. ".hall.GameRoomInfoUI_" .. GC_GameTypes[gameId]
        local cls = import(tmpPath, kCurrentModule)
        if nil == cls then
            print("FriendRoomCreate:areaSelectBack 创建UI失败")
            return
        end
        -- local bgSize = bgPanel:getContentSize()
        self.entity = cls.new(bgPanel)
        bgPanel:removeAllChildren()
        bgPanel:addChild(self.entity)
       
    else
        Toast.getInstance():show("GC_GameTypes中尚未添加该游戏" .. gameId);
    end
end
-- return FriendRoomCreate