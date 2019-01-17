-- 红中麻将文本描述
-- 庄加2底   2、无红中加1底   3、抢杠包三家   4、无马算全马   5、全马加1马
local gamePalyingName={
    [1]={title="zhuangjia2di", ch="庄加2底"},
    [2]={title="wuhongzhongjiayidi", ch="无红中加1底"},
    [3]={title="qianggangbaosanjia", ch="抢杠包三家"},
    [4]={title="wumasuanquanma", ch="无马算全马"},
    [5]={title="quanmajia1ma", ch="全马加1马"},
    [6]={title="kechi", ch="可吃"},
    [7]={title="qixiaoduikehu", ch="七小对"},
    [8]={title="kedianpao", ch="可点炮"},
    [9]={title="suportmutihu", ch="可一炮多响"},
}

local wanfaInfo = {
    fanma = {pos = "front", wanfa = "_ma", text = "%s马", selected = "", special = {["99_ma"] = "1马(乘点数)", ["91_ma"] = "1马(加点数)", },},
}

return {

    -- 游戏玩法规则
    -- fangpaokehu|sihui|qihui|kepeng|bukebaoting|baotingjiafan
    _gamePalyingName = gamePalyingName,

    --------------------------
    -- 规则获取放在这儿, 方便不同游戏修改规则文本
    -- @return table: {ch = "xx"}
    kGetPlayingInfoByTitle = function (title)
        -- Log.i("title", title)
        for k, v in pairs(wanfaInfo) do
            local pos = string.find(title, v.wanfa)
            if pos then
                if v.special[title] then return {ch = v.special[title], title = title, model = k} end
                local num = string.sub(title, #v.wanfa + 1)
                if v.pos == "front" then
                    -- Log.i("string.find(v.wanfa)", string.find(title, v.wanfa))
                    num = string.sub(title, 1, string.find(title, v.wanfa) - 1)
                end
                local text = string.format(v.text, num)
                return {ch = text, title = title, model = k}
            end
        end
        for k, v in pairs(gamePalyingName) do
            if (v.title == title) then
                v.model = "common"
                return v
            end
        end
        -- return nil
        return {ch = title, title = title, model = "common"}
    end,
    -- -- 获取额外的规则信息
-- getGamePalyingText = function getGamePalyingText
--     Log.i("getGamePalyingText", kFriendRoomInfo:getSelectRoomInfo())
--     local ret = {}
--     local fa = kFriendRoomInfo:getSelectRoomInfo().fa
--     local text = string.format(kFanMaInfo.fanmaText, fa)
--     if fa == kFanMaInfo.specialFanma then text = kFanMaInfo.specialText end
--     table.insert(ret, text)
--     return ret
-- end,
}
