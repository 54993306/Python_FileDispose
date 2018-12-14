DDZTWOPModules = {
"package_src.games.ddztwop.proxy.delegate.DDZTWOPSocketCmd",
"package_src.games.pokercommon.widget.PokerUIWndBase",
"package_src.games.pokercommon.widget.PokerUIManager",
"package_src.games.pokercommon.widget.PokerTouchCaptureView",
"package_src.games.pokercommon.data.DataMgr",
"package_src.games.pokercommon.sound.PokerSoundPlayer",
"package_src.games.pokercommon.data.HallConst",
"package_src.games.pokercommon.widget.PokerOpenRoomGame",
"package_src.games.pokercommon.widget.PokerToast",
}

for i,v in ipairs(DDZTWOPModules) do
	require(v)
end

GC_GameFiles = {
    common = {
        },
    game = {
        },
}


