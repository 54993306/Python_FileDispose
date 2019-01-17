DDZModules = {

}

for k,v in pairs(DDZModules) do
	require(v)
end

if IsPortrait then
	GC_GameFiles = {
	    common = {
	        },
	    game = {
	        "package_src.games.paodekuai.pdkpk.hall.GameRoomInfoUI_pdkpk",
	        },
	}
else
	GC_GameFiles = {
	    common = {
	        "app.hall.friendRoom.FriendRoomScene",
	        },
	    game = {
			"package_src.games.paodekuai.pdkpk.hall.friendRoom.pdkpkFriendRoomScene",
	        "package_src.games.paodekuai.pdkpk.hall.GameRoomInfoUI_pdkpk",
	        },
	}
end
	


