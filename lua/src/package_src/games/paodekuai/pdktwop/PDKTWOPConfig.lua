DDZTWOPModules = {
"package_src.games.paodekuai.pdktwop.proxy.delegate.DDZTWOPSocketCmd",
"package_src.games.paodekuai.pdkcommon.widget.PokerUIWndBase",
"package_src.games.paodekuai.pdkcommon.widget.PokerUIManager",
"package_src.games.paodekuai.pdkcommon.widget.PokerTouchCaptureView",
"package_src.games.paodekuai.pdkcommon.data.DataMgr",
"package_src.games.paodekuai.pdkcommon.sound.PokerSoundPlayer",
"package_src.games.paodekuai.pdkcommon.data.HallConst",
"package_src.games.paodekuai.pdkcommon.widget.PokerOpenRoomGame",
"package_src.games.paodekuai.pdkcommon.widget.PokerToast",
"package_src.games.paodekuai.pdkcommon.widget.PokerRoomDialogView",
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


