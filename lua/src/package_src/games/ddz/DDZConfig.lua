DDZModules = {
"package_src.games.pokercommon.sound.PokerSoundPlayer",
"package_src.games.pokercommon.data.DataMgr",
"package_src.games.pokercommon.data.HallConst",
"package_src.games.pokercommon.widget.PokerTouchCaptureView",
"package_src.games.pokercommon.widget.PokerUIWndBase",
"package_src.games.pokercommon.widget.PokerUIManager",
"package_src.games.pokercommon.widget.PokerToast",
}

for k,v in pairs(DDZModules) do
	require(v)
end


GC_GameFiles = {
    common = {
        },
    game = {
        },
}