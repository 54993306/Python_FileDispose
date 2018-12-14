--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Define        = require "app.games.common.Define"
local BgLayer = require("app.games.common.ui.bglayer.BgLayer")

local guangdongyibaizhangmjBgLayer = class("guangdongyibaizhangmjBgLayer", BgLayer)


-- latters: 指定麻将后缀, 如{"红中"}
function guangdongyibaizhangmjBgLayer:addGameName(latters)
    local offX = 80 -- 左右偏移的距离
    local offY = 30  --距离中间的距离
    local gameName = kFriendRoomInfo:getRoomBaseInfo().gameName -- 游戏名称(必须含有麻将)
    Log.i("BgLayer:addGameName() gameName", gameName)
    if gameName then
        local extName = latters or {"麻将","推倒胡","杠杠胡","红中宝","做牌","鸡胡","100张"}
        local majInx = nil
        for i,v in pairs(extName) do
            if not majInx then
                majInx = string.find(gameName, v)
            end
        end
        if not majInx then
            majInx = #gameName - #extName[1] + 1
        end
        local newName = string.sub(gameName, 1, majInx - 1)
        extName = string.sub(gameName, majInx, #gameName)
        Log.i("newName", newName, extName, #gameName)
        local gameLabel = cc.Label:createWithTTF(newName, "hall/font/fangzhengcuyuan.TTF", 50)
        gameLabel:setColor(display.COLOR_BLACK)
        gameLabel:setOpacity(0.2 * 255)
        gameLabel:setAnchorPoint(cc.p(1, 0.5))
        gameLabel:setPosition(cc.p(Define.visibleWidth * 0.5 - offX, Define.visibleHeight * 0.5 + offY))
        self:addChild(gameLabel)

        local majLabel = cc.Label:createWithTTF(extName, "hall/font/fangzhengcuyuan.TTF", 50)
        majLabel:setColor(display.COLOR_BLACK)
        majLabel:setOpacity(0.2 * 255)
        majLabel:setAnchorPoint(cc.p(0, 0.5))
        majLabel:setPosition(cc.p(Define.visibleWidth * 0.5 + offX, Define.visibleHeight * 0.5 + offY))
        self:addChild(majLabel)
    end
end

return guangdongyibaizhangmjBgLayer

--endregion
