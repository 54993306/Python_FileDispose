--
-- Author: Van
-- Date: 2017-10-30 16:00:36
--
return {
    -- 游戏玩法规则  
    -- fangpaokehu|sihui|qihui|kepeng|bukebaoting|baotingjiafan
	_gamePalyingName={
	    [1] = {title = "yg_true",           ch = "带鬼"},
	    [2] = {title = "wg_false",         ch = "不带鬼"},

	    [3] = {title = "wghbkch_false",         ch = "无鬼不可吃胡"},
	    [4] = {title = "wghkch_true",           ch = "无鬼可吃胡"},

	    [5] = {title = "ps_136",           ch = "136张"},
	    [6] = {title = "ps_120",         ch = "120张"},
	    [7] = {title = "ps_112",           ch = "112张"},
	    [8] = {title = "ps_108",         ch = "108张"},

	    [9] = {title = "gui_47",           ch = "白板鬼"},
	    [10] = {title = "gui_45",         ch = "红中鬼"},

	    [11] = {title = "lzsmwz_false",           ch = "鬼按位置看马"},
	    [12] = {title = "lzsmsy_true",         ch = "鬼算所有人的马"},

	    [13] = {title = "wghzcfm_0",           ch = "无鬼胡正常翻马"},
	    [14] = {title = "wghmsj_2",         ch = "无鬼胡马牌数+2"},
	    [15] = {title = "wghmsj_4",           ch = "无鬼胡马牌数+4"},

	    [16] = {title = "zpms_5",         ch = "玩1马时字牌为5马"},
	    [17] = {title = "zpms_10",           ch = "玩1马时字牌为10马"},

	    [18] = {title = "ms_6",         ch = "6马"},
	    [19] = {title = "ms_4",           ch = "4马"},
	    [20] = {title = "ms_8",         ch = "8马"},
	    [21] = {title = "ms_10",           ch = "10马"},
	    [22] = {title = "ms_1",         ch = "1马"},

	    [23] = {title = "mplb159_true",           ch = "1,5,9鬼为马"},
	    [24] = {title = "mplbwz_false",         ch = "按位置看马"},

	    [25] = {title = "d_1",           ch = "1分"},
	    [26] = {title = "d_2",         ch = "2分"},
	    [27] = {title = "d_5",           ch = "5分"},
	    [28] = {title = "d_10",         ch = "10分"},

	    [29] = {title = "zmf_1",           ch = "1分2分"},
	    [30] = {title = "zmf_2",         ch = "2分4分"},
	    [31] = {title = "zmf_5",           ch = "5分10分"},
	    [32] = {title = "zmf_10",         ch = "10分20分"},
	}

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