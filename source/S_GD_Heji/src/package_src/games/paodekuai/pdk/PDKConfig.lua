DDZModules = {
"package_src.games.paodekuai.pdkcommon.sound.PokerSoundPlayer",
"package_src.games.paodekuai.pdkcommon.data.DataMgr",
"package_src.games.paodekuai.pdkcommon.data.HallConst",
"package_src.games.paodekuai.pdkcommon.widget.PokerTouchCaptureView",
"package_src.games.paodekuai.pdkcommon.widget.PokerUIWndBase",
"package_src.games.paodekuai.pdkcommon.widget.PokerUIManager",
"package_src.games.paodekuai.pdkcommon.widget.PokerToast",
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
end