local DDZTWOPCard = require("package_src.games.paodekuai.pdkcommon.utils.card.DDZPKCard")

DDZTWOPCard.WIDTH   = 160  --牌的实际宽度
DDZTWOPCard.HEIGHT  = 220  --牌的实际高度
DDZTWOPCard.SElFSCALE = 0.75--自己的牌的缩放系数
DDZTWOPCard.OTHERSCALE = 0.8--对家的牌的缩放系数

DDZTWOPCard.NORMALCOLOR = cc.c3b(255,255,255)  --牌正常颜色
DDZTWOPCard.NORMALSELECTCOLOR = cc.c3b(158, 198, 228) --正常牌选中颜色

DDZTWOPCard.OTHERHANDWIDTH = 768  --对手手牌牌宽
DDZTWOPCard.OTHERHANDHEIGHT = 172 -- 对手手牌牌高

DDZTWOPCard.NORMALSPACE = 50
DDZTWOPCard.OTHERMAXSPACE = 60
DDZTWOPCard.MAXSPACE = 50
DDZTWOPCard.POPHEIGHT = 33

DDZTWOPCard.STATUS_SHOWRANG = 6 --显示为让牌时的状态

--debug模式牌值
DDZTWOPCard.DEBUGCARD = -1

return DDZTWOPCard