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
	        },
	}
else
	GC_GameFiles = {
	    common = {
	        "app.hall.friendRoom.FriendRoomScene",
	        },
	    game = {
			"package_src.games.ddzpk.hall.friendRoom.ddzpkFriendRoomScene",
	        },
	}

end
