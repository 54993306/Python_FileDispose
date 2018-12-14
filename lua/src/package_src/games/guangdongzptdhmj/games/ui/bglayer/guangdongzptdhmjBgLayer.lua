local Mj            = require "app.games.common.mahjong.Mj"
local Define        = require "app.games.common.Define"
local bgLayer = import("app.games.common.ui.bglayer.BgLayer")
local guangdongzptdhmjBgLayer = class("guangdongzptdhmjBgLayer", bgLayer)

function guangdongzptdhmjBgLayer:ctor()
    self.mjNameScale = 0.7  -- 麻将名称字体缩放，三个字原大小会被落地的麻将挡住
    self.super.ctor(self);
end
-- 功能： 在牌桌上显示游戏名称
-- 返回值： 无
-- latters：table 方便加入其它后半部分字串
function guangdongzptdhmjBgLayer:addGameName( latters )
    local offX = 80 -- 左右偏移的距离
    local offY = 30  --距离中间的距离
    local gameName = kFriendRoomInfo:getRoomBaseInfo().gameName -- 游戏名称(必须含有麻将)
    Log.i("BgLayer:addGameName() gameName", gameName)
    if gameName then
        local newName = ""
        local extName = ""
        if string.find(gameName, "做牌推倒胡") then
            newName = "做牌"
            extName = "推倒胡"
        else
            local extNames = {"麻将","推倒胡","杠杠胡","红中宝","做牌","鸡胡"}
            if latters then
                -- 连接两个表格
                table.insertto(extNames, latters)
            end
            local majInx = nil
            for i,v in pairs(extNames) do
                if not majInx then
                    majInx = string.find(gameName, v)
                end
            end
            if not majInx then
                majInx = #gameName - #extNames[1] + 1
            end
            newName = string.sub(gameName, 1, majInx - 1)
            extName = string.sub(gameName, majInx, #gameName)
        end
        Log.i("newName", newName, extName, #gameName)
        local gameLabel = cc.Label:createWithTTF(newName, "hall/font/fangzhengcuyuan.TTF", 50)
        gameLabel:setColor(display.COLOR_BLACK)
        gameLabel:setOpacity(0.2 * 255)
        gameLabel:setAnchorPoint(cc.p(1, 0.5))
        gameLabel:setPosition(cc.p(Define.visibleWidth * 0.5 - offX, Define.visibleHeight * 0.5 + offY))
        self:addChild(gameLabel)
        gameLabel:setScale(self.mjNameScale);

        local majLabel = cc.Label:createWithTTF(extName, "hall/font/fangzhengcuyuan.TTF", 50)
        majLabel:setColor(display.COLOR_BLACK)
        majLabel:setOpacity(0.2 * 255)
        majLabel:setAnchorPoint(cc.p(0, 0.5))
        majLabel:setPosition(cc.p(Define.visibleWidth * 0.5 + offX, Define.visibleHeight * 0.5 + offY))
        self:addChild(majLabel)
        majLabel:setScale(self.mjNameScale);
    end
end

return guangdongzptdhmjBgLayer