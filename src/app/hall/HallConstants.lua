
G_ROOM_INFO_FORMAT = {
--这些项目基本上都是可以自定义配置的。
--这里设定的是默认值
--具体可根据具体排版创建的时候传参数修改
    normalColor = cc.c3b(67, 67, 67), --未选文本颜色
    normalDropFontColor = cc.c3b(255, 255, 255),
    selectColor = cc.c3b(15, 148, 29), --选中文本颜色
    fontSize = 28, --文本默认大小
    lineHeight = 60, --单行高度
    lineWidth = 1052, --单行宽度
    dropDwonBoxSize = cc.size(230, 45), --下拉框单项默认大小
    radioItemOffset = 295,
    firstPosX = 130,
    titleSuffix = ":", -- 玩法标题后缀
    titlePosX = 42,
    groupColMax = 3, --group单行项默认值
    itemTextOffsetX = 64,
    itemTextOffsetY = 14,

    --下面是一些资源的路径
    LineFilePath = "hall/Common/line2.png", --分割线
    DropBoxNormalImg = "games/common/game/drop_down_box_bg.png",--下拉框背景
    DropBoxContentImg = "games/common/game/drop_down_box_content_bg.png", --下拉框展开背景
    DropBoxIconNormalImg = "games/common/game/handle_down.png", --下拉框向下箭头
    DropBoxIconShowImg = "games/common/game/handle_up.png", --下拉框向上箭头

    CheckBoxPanelCsb = "games/common/game/checkbox_panel.csb", --复选项 custom/CheckBoxPanel.lua用到的csb

    --第一种单选按钮custom/RadioButtonGroup.lua用到的csb
    RadioButtonGroupCsb = "games/common/game/radiobutton_panel.csb",

    --另一种单选按钮(SelectPanel)用到的图片资源
    SelectRadioSelectImg       = "hall/huanpi2/Common/btn_b_on2.png", -- 选中的图片
    SelectRadioBackgroundImg   = "hall/huanpi2/Common/radio_yellow_box2.png", -- 背景图片
}

if IsPortrait then -- TODO
    G_ROOM_INFO_FORMAT.normalDropFontColor = cc.c3b(67, 67, 67)

    G_ROOM_INFO_FORMAT.fontSize = 32 --文本默认大小
    G_ROOM_INFO_FORMAT.lineHeight = 80 --单行高度
    G_ROOM_INFO_FORMAT.lineWidth = 688 --单行宽度

    G_ROOM_INFO_FORMAT.radioItemOffset = 289
    G_ROOM_INFO_FORMAT.firstPosX = 110

    G_ROOM_INFO_FORMAT.titlePosX = 20
    G_ROOM_INFO_FORMAT.titleFontSize = 40
    G_ROOM_INFO_FORMAT.titleFontColor = cc.c3b(0x83, 0x40, 0x05)
    G_ROOM_INFO_FORMAT.groupColMax = 2 --group单行项默认值
end

CLOSE_REPLAY_ID_LIST = {
    -- 20009,
}

-- 需要和麻将区分，一些值的命名不一样
REPLAY_ID_LIST_CHANGER = {
    20009,
    20010,
}