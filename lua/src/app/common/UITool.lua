---------------------------
-- 设置UI的工具函数

local UITool = {}

---------------------------
local titleShadowStyle = { -- 标题阴影样式
    color = cc.c4b(0, 0, 0, 127),
    offSet = cc.size(3, -3),
}
-- 设置标题样式
-- @author 周思宇
UITool.setTitleStyle = function(titleLabel)
    if not titleLabel then
        -- printError("UITool.setTitleStyle: no titleLabel")
        -- print(debug.traceback())
        return 
    end
    titleLabel:setFontName("hall/font/fangzhengcuyuan.TTF");
    titleLabel:setColor(cc.c3b(0xff,0xd2,0x69));
    titleLabel:setFontSize(50)
    titleLabel:setCascadeColorEnabled(true)
    titleLabel:enableShadow(titleShadowStyle.color, titleShadowStyle.offSet) -- blurRadius无效
end

---------------------------
local bg = {path = "res/hall/huanpi2/Common/panel_black.png", capInsets = cc.rect(10,10,20,20), minSize = cc.size(20, 20)} -- 底框的配置
local baseOffConfig = {left = 0, right = 0, up = 0, bottom = 0} -- 默认的偏移
-- 设置规则的底框
-- @author 周思宇
UITool.addRuleBgPanel = function(panel, offConfig)
    local panelBox = panel:getChildByName("panelBox")
    if panelBox then
        panelBox:removeFromParent()
    end
    local offConfig = offConfig or {}
    local formatConfig = baseOffConfig
    for k, v in pairs(offConfig) do
        formatConfig[k] = v
    end
    local size = panel:getContentSize()
    local bgSize = cc.size(size.width + formatConfig.left + formatConfig.right, size.height + formatConfig.up + formatConfig.bottom)
    -- Log.i("bgSize", bgSize)
    if bgSize.width < bg.minSize.width or bgSize.height < bg.minSize.height then return end
    local bg = display.newScale9Sprite(bg.path, - formatConfig.left , - formatConfig.bottom, bgSize, bg.capInsets)
    bg:setAnchorPoint(cc.p(0, 0))
    bg:setName("panelBox")
    bg:addTo(panel)
end

return UITool