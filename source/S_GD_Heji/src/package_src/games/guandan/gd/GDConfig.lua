GDModules = {
"package_src.games.guandan.gdcommon.sound.PokerSoundPlayer",
"package_src.games.guandan.gdcommon.data.DataMgr",
"package_src.games.guandan.gdcommon.data.HallConst",
"package_src.games.guandan.gdcommon.widget.PokerTouchCaptureView",
"package_src.games.guandan.gdcommon.widget.PokerUIWndBase",
"package_src.games.guandan.gdcommon.widget.PokerUIManager",
"package_src.games.guandan.gdcommon.widget.PokerToast",
"package_src.games.guandan.gdpoker.init",
"package_src.games.guandan.gdfuckFaster.GDCardsdef"
}

for k,v in pairs(GDModules) do
	require(v)
end


if IsPortrait then
	GC_GameFiles = {
    	common = {
      	  "app.hall.friendRoom.FriendRoomScene"
        },
    	game = {
    		"package_src.games.guandan.hall.friendRoom.guandanFriendRoomScene",
        },
	}
else
	GC_GameFiles = {
    	common = {
      	  "app.hall.friendRoom.FriendRoomScene"
       	},
    	game = {
    		"package_src.games.guandan.hall.friendRoom.FriendRoomScene",
        },
	}
end