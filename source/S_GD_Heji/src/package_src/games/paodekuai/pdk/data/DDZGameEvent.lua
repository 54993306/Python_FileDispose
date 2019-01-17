--
-- 斗地主游戏内的事件
-- Author: Jinds
-- Date: 2017-11-09
--
local DDZGameEvent = {}

local prefix = "DDZ.GAME."

DDZGameEvent.ONGAMESTART 	= prefix .. "ONGAMESTART"
DDZGameEvent.ONCALLLORD 	= prefix .. "ONCALLLORD"
DDZGameEvent.ONROBLORD 		= prefix .. "ONROBLORD"
DDZGameEvent.ONDOUBLE 		= prefix .. "ONDOUBLE"
DDZGameEvent.ONSTRATPLAY 	= prefix .. "ONSTRATPLAY"
DDZGameEvent.ONOUTCARD 		= prefix .. "ONOUTCARD"
DDZGameEvent.GAMEOVER 		= prefix .. "GAMEOVER"
DDZGameEvent.ONTUOGUAN 		= prefix .. "ONTUOGUAN"
DDZGameEvent.ONRECONNECT 	= prefix .. "ONRECONNECT"
DDZGameEvent.ONEXITROOM 	= prefix .. "ONEXITROOM"
DDZGameEvent.ONUSERDEFCHAT 	= prefix .. "ONUSERDEFCHAT"
DDZGameEvent.ONCOINUPDATE	= prefix .. "ONCOINUPDATE"
DDZGameEvent.RECVBROCAST	= prefix .. "RECVBROCAST"
DDZGameEvent.ONRECVENTERROOM= prefix .. "ONRECVENTERROOM"
DDZGameEvent.ONRECVREQDISSMISS = prefix .. "ONRECVREQDISSMISS"
DDZGameEvent.ONRECVDISSMISSEND = prefix .. "ONRECVDISSMISSEND"
DDZGameEvent.ONRECVFRIENDCONTINUE = prefix .. "ONRECVFRIENDCONTINUE"
DDZGameEvent.ONRECVTOTALGAMEOVER = prefix .. "ONRECVTOTALGAMEOVER"
DDZGameEvent.ONLINE = prefix .. "ONLINE"


-- DDZGameEvent.ONNETCLOSE		= prefix .. "ONNETCLOSE"
-- DDZGameEvent.ONNETRECONNECT	= prefix .. "ONNETRECONNECT"
-- DDZGameEvent.ONNETCONNECTFAIL= prefix .. "ONNETCONNECTFAIL"



local uiprefix = "DDZ.GAME.UI."
DDZGameEvent.UPDATEOPERATION 	= uiprefix .. "UPDATEOPERATION"
DDZGameEvent.REQCHANGEDESK 		= uiprefix .. "REQCHANGEDESK"
DDZGameEvent.UIREQCHANGEDESK 	= uiprefix .. "UIREQCHANGEDESK"
DDZGameEvent.REQCONTINUE 		= uiprefix .. "REQCONTINUE"
DDZGameEvent.UIREQCONTINUE 		= uiprefix .. "UIREQCONTINUE"
DDZGameEvent.REQEXITROOM 		= uiprefix .. "REQEXITROOM"
DDZGameEvent.REQSENDDEFCHAT 	= uiprefix .. "REQSENDDEFCHAT"
DDZGameEvent.REQTUOGUAN 		= uiprefix .. "REQTUOGUAN"
DDZGameEvent.ONDEALCARDEND 		= uiprefix .. "ONDEALCARDEND"
DDZGameEvent.HIDEMORELAYER		= uiprefix .. "HIDEMORELAYER"
DDZGameEvent.SHOWSETTING		= uiprefix .. "SHOWSETTING"
DDZGameEvent.SHOWNOBIGGER		= uiprefix .. "SHOWNOBIGGER"
DDZGameEvent.RESAYCHAT          = uiprefix .. "RESAYCHAT"

-- DDZGameEvent. = uiprefix .. ""



return DDZGameEvent



