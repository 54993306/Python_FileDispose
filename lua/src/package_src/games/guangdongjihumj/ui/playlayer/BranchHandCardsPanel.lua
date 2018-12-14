--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local HandCardsPanel = require("app.games.common.ui.playlayer.HandCardsPanel")

local Define 		= require "app.games.common.Define"
local Mj    		= require "app.games.common.mahjong.Mj"

local BranchHandCardsPanel = class("BranchHandCardsPanel",HandCardsPanel)

function BranchHandCardsPanel:ctor(mjgroups)
    self.super.ctor(self,mjgroups)
    self:setkLaiziPng("package_res/games/guangdongjihumj/game/guiicon.png")
end

return BranchHandCardsPanel


--endregion
