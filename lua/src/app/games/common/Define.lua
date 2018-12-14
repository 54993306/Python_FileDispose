-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成



-- endregion

local Define = {
    ViewSizeType = 0,
    
	g_pai_width = 85,
	-- 本家麻将牌的宽度
	g_pai_start_x = 85,
	-- 本家手牌显示的起始x坐标
	g_pai_y = 90,
	-- 本家手牌显示的高度
	g_action_pai_x = 43,
	-- 吃碰杠牌的x
	g_action_pai_y = 70,
	-- 吃碰杠牌的y
	g_pai_peng_space = 165,
	-- 本家碰牌的宽度
	g_pai_gang_space = 165,
	-- 本家杠牌的宽度
    g_pai_out_x = 457,
    -- 本家牌桌上牌的起始x坐标
    g_pai_out_x_two_player = 250,
    -- 两人房本家牌桌上牌的起始x坐标
    g_pai_out_x_three_player = 426,
    -- 三人房本家牌桌上牌的起始x坐标
	g_pai_out_y = 235,
	-- 本家牌桌上牌的y坐标
	g_pai_out_space = 38,
	-- 自己打得牌的间隔
	g_pai_out_height = 56,
	-- 自己打出去的牌的高度
	g_action_pai_width = 49,
	-- 本家吃碰杠牌的宽度
	g_action_tang_pai_width = 61,
	-- 本家碰躺着的牌的宽度
    g_action_tang_pai_height = 33,
    --本家碰杠躺着的牌的高度
	g_other_pai_start_x = 870,
	-- 对家手牌的起始x坐标
	g_other_pai_y = 635,
	-- 对家手牌高度
	g_other_pai_peng_space = 125,
	-- 对家碰牌的宽度
	g_other_pai_gang_space = 125,
	-- 对家杠牌的宽度
	g_other_pai_width = 38,
	-- 对家麻将宽度
	g_other_pai_action_width = 38,
	-- 对家麻将碰宽度
	g_other_pai_tang_action_width = 36,
	-- 对家麻将躺碰宽度
    g_other_pai_tang_action_height = 26,
    --对家麻将躺着的高度
    g_other_pai_gai_width = 34,
    --对家牌盖着的宽度
    g_other_pai_gai_height = 26,
    --对家牌盖着的高度
	g_other_show_pai_y = 620,
	-- 对家展示牌的y坐标
	g_other_pai_out_x = 780,
	-- 对家牌桌上牌的起始x坐标
	g_other_pai_out_y = 527,
	-- 对家牌桌上牌的y坐标
	g_other_pai_out_height = 56,
	-- 对家打出去的牌的高度
	g_other_pai_out_space = 38,
	-- 对家打得牌的间隔
	g_side_peng_pai_space = 110,
	-- 两边碰牌之间间距（）
	g_side_gang_pai_space = 107,
	-- 两边杠牌之间间距（）
    g_side_tang_pai_width = 31,
    --两边躺着的牌的宽度
	g_side_tang_pai_height = 41,
	-- 碰躺着的牌的高度
	g_side_pai_height = 24,
	-- 两边麻将高度
	g_side_pai_out_width = 48,
	-- 两边打出去的牌的宽度
	g_side_end_ming_pai_height = 32,
	-- 两边结束时明牌的高度
	g_left_pai_out_space = 29,
	-- 左边打得牌的间隔
	g_left_pai_x = 192,
	-- 左边手牌显示的x坐标
	g_left_show_pai_x = 265,
	-- 左边玩家打出大牌的x坐标
	g_left_show_pai_y = 370,
	-- 左边玩家展示牌的y坐标
	g_left_pai_action_x = 200,
	-- 左边玩家吃碰杠x坐标
	g_left_pai_out_x = 384,
	-- 左家打出牌的起始x坐标
	g_left_pai_out_y = 514,
	-- 左家打出牌的起始y坐标
    g_left_action_pai_width = 50,
	g_left_action_pai_height = 31,

	g_left_pai_start_y = 590,
	g_left_pai_action_start_y = 590,

    -- 对家打得牌的间隔
	g_right_peng_pai_space = 120,
    -- 两边碰牌之间间距（）
	g_right_gang_pai_space = 112,
    -- 左边牌显示的起始Y坐标
	g_right_pai_out_space = 32,
	-- 左边打得牌的间隔
	g_right_pai_x = 1125,
	-- 右边手牌显示的x坐标
	g_right_show_pai_x = 1053,
	-- 右边玩家展示大牌的x坐标
	g_right_show_pai_y = 370,
	-- 右边玩家展示牌的y坐标
	g_right_pai_action_x = 1000,
	-- 右边玩家吃碰杠x坐标
	g_right_pai_start_y = 190,
	-- 右家牌墙开始Y坐标
	g_right_action_pai_start_y = 100,
	-- 右家动作牌墙开始Y坐标
	g_right_pai_out_x = 898,
	-- 右家打出牌的起始x坐标
	g_right_pai_out_y = 250,
	-- 右家打出牌的起始y坐标
    g_right_pai_tang_width = 52,
    --右家碰杠躺着的宽度
    g_right_pai_tang_heigh = 36,
    --右家碰杠躺着的高度
	g_right_action_pai_height = 31,
	-- 吃碰杠操作显示起始X轴
	g_action_start_x = 680,
	-- 吃碰杠操作显示起始Y轴
    g_action_start_y = 180,

    --右家打出牌的宽度
	action_chi = 1,
	-- 吃
	action_peng = 2,
	-- 碰
	action_mingGang = 3,
	-- 明杠
	action_jiaGang = 4,
	-- 加杠
	action_anGang = 5,
	-- 暗杠
	action_ting = 6,
	-- 可听
	action_dianPaoHu = 7,
	-- 点炮胡
	action_ziMoHu = 8,
	-- 自摸胡
    action_buhua = 23,
    -- 下跑
    action_xiaPao = 29,
    -- 拉庄
    action_laZhuang = 32,
    -- 坐
    action_zuo = 33,
    --补花
	action_guo = 101,
	-- 过
	action_jiaBei = 102,
	-- 加倍
	action_task = 103,
	-- 任务
	action_buTing = 110,
	-- 不听

	-- 吃碰杠补花
	e_zorder_player_layer_action = 5,
	-- 操作栏
	e_zorder_player_layer_substitute = 6,
	-- 托管妹子
	e_zorder_dialog = 100,
	-- 弹框
	e_tag_player_layer_action = 22,

	-- 操作栏
    site_self = 1,              --本家位置编号
    site_right = 2,             --右家位置编号
    site_other = 3,             --对家位置编号
    site_left = 4 ,        	--左家位置编号
 	visibleWidth = 0,
	visibleHeight = 0,
    isVisibleTrick = false,      --是否发完牌

    --面前牌的墩数
    mj_tricks =  18,
    --牌局开始拿走多少手
    mj_myCards_position_x = 840,
    --玩家牌墩的x起始位置（牌是从右到左算）
    mj_myCards_position_y = 230,
    --玩家牌墩的y起始位置
    mj_leftCards_position_x = 410,
    --左边玩家的牌墩的x起始位置
    mj_leftCards_position_y = 280,
    --左边牌墩的y起始位置（牌是从下往上算）
    mj_otherCards_position_x = 440,
    --对面玩家牌墩的x起始位置（牌是从右往左）
    mj_otherCards_position_y = 640,
    --对面玩家拍段的y起始位置
    mj_rightCards_position_x = 870,
    --右边玩家牌墩的x起始位置
    mj_rightCards_position_y = 580,
    --右边玩家牌墩的y起始位置(牌是从上往下)
    
    mj_takes = 12,
    shaizi_time = 0.82,            --掷色子时间

    cards_tricks_position_x = 0 ,
    --发牌的牌墩x位置
    cards_tricks_position_y = 0,
    --发牌的牌墩y位置
	gameId_changzhou = 10008,
	--常州麻将游戏id	
	gameId_xuzhou = 10007,
    --徐州麻将游戏id 

    game_chuji_roomId = 1081,
    --初级场
    game_zhongji_roomId = 1082,
    --中级场
    game_gaoji_roomId = 1083,
    --高级场
    game_dashi_roomid = 1084,
    --大师场
    game_distrMjAction_time = 0.25,
    --发牌动画时间
    majiang_shoupai_zuoyou_scale = 0.8,
    --左右手牌的缩放

    mj_ui_chahu_panel_y = 345,

    --本家手牌缩放
    mj_myCards_scale = 1,
    --对于全面屏的公用缩放
    mj_buhua_pos_scale = 1,
    --对于全面屏的公用缩放
    mj_common_scale = 1,
    --对于全面屏的牌局右下角三个按钮的位置偏移
    mj_ui_chat_panel_offset_y = 0,
}

return Define
