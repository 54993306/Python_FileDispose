GDModules = {

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
