--
-- Author: Jinds
-- Date: 2017-07-10 11:00:42
--
local  PlayerHead = require("app.games.common.ui.bglayer.PlayerHead")
local huizhoumjPlayerHead = class("huizhoumjPlayerHead", PlayerHead)



--玩家听牌ui
function huizhoumjPlayerHead:showBaoDaGeOp(site,visible)
    local head = self:getHead(site)
    local tinPaiOpImage = self:getWidget(head,"tinPaiOpImage")
    local imgPath = "package_res/games/huizhoumj/games/img_bao_da_ge_head.png"
    tinPaiOpImage:loadTexture(imgPath, ccui.TextureResType.localType)
    tinPaiOpImage:setVisible(visible)
end



return huizhoumjPlayerHead