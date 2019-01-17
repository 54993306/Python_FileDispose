--
-- 斗地主游戏内的事件
-- Author: Jinds
-- Date: 2017-11-09
--
local GDGameEvent = {}

local prefix = "GD.GAME."

GDGameEvent.ONGAMESTART 	= prefix .. "ONGAMESTART"
GDGameEvent.ONSTRATPLAY 	= prefix .. "ONSTRATPLAY"
GDGameEvent.ONOUTCARD 		= prefix .. "ONOUTCARD"
GDGameEvent.GAMEOVER 		= prefix .. "GAMEOVER"
GDGameEvent.ONTUOGUAN 		= prefix .. "ONTUOGUAN"
GDGameEvent.ONRECONNECT 	= prefix .. "ONRECONNECT"
GDGameEvent.ONEXITROOM 	= prefix .. "ONEXITROOM"
GDGameEvent.ONUSERDEFCHAT 	= prefix .. "ONUSERDEFCHAT"
GDGameEvent.ONCOINUPDATE	= prefix .. "ONCOINUPDATE"
GDGameEvent.RECVBROCAST	= prefix .. "RECVBROCAST"
GDGameEvent.ONRECVENTERROOM= prefix .. "ONRECVENTERROOM"
GDGameEvent.ONRECVREQDISSMISS = prefix .. "ONRECVREQDISSMISS"
GDGameEvent.ONRECVDISSMISSEND = prefix .. "ONRECVDISSMISSEND"
GDGameEvent.ONRECVFRIENDCONTINUE = prefix .. "ONRECVFRIENDCONTINUE"
GDGameEvent.ONRECVTOTALGAMEOVER = prefix .. "ONRECVTOTALGAMEOVER"
GDGameEvent.ONLINE = prefix .. "ONLINE"
GDGameEvent.ONDEALGONG 	= prefix .. "ONDEALGONG"
GDGameEvent.ONPLAYERCARD 	= prefix .. "ONPLAYERCARD"


local uiprefix = "GD.GAME.UI."
GDGameEvent.UPDATEOPERATION 	= uiprefix .. "UPDATEOPERATION"
GDGameEvent.REQCHANGEDESK 		= uiprefix .. "REQCHANGEDESK"
GDGameEvent.UIREQCHANGEDESK 	= uiprefix .. "UIREQCHANGEDESK"
GDGameEvent.REQCONTINUE 		= uiprefix .. "REQCONTINUE"
GDGameEvent.UIREQCONTINUE 		= uiprefix .. "UIREQCONTINUE"
GDGameEvent.REQEXITROOM 		= uiprefix .. "REQEXITROOM"
GDGameEvent.REQSENDDEFCHAT 	= uiprefix .. "REQSENDDEFCHAT"
GDGameEvent.REQTUOGUAN 		= uiprefix .. "REQTUOGUAN"
GDGameEvent.ONDEALCARDEND 		= uiprefix .. "ONDEALCARDEND"
GDGameEvent.HIDEMORELAYER		= uiprefix .. "HIDEMORELAYER"
GDGameEvent.SHOWSETTING		= uiprefix .. "SHOWSETTING"
GDGameEvent.SHOWNOBIGGER		= uiprefix .. "SHOWNOBIGGER"
GDGameEvent.RESAYCHAT          = uiprefix .. "RESAYCHAT"
GDGameEvent.SHOWEXCHANGEHEAD          = uiprefix .. "SHOWEXCHANGEHEAD"

return GDGameEvent
