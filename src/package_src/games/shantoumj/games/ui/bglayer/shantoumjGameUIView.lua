local GameUIView = import("app.games.common.ui.bglayer.GameUIView")
local shantoumjGameUIView = class("shantoumjGameUIView", GameUIView)

function shantoumjGameUIView:ctor( ... )
	self.super.ctor(self, ...)
end

--[[
-- @brief 初始化底版块函数
-- @param panel 拉跑坐底的版块， btns 按钮的集合，tag 大模块的tag
-- @return void
]]
function shantoumjGameUIView:initDiPaoLaZuoPanel(panel, btns, tag)
    -- local bumaiBtn = ccui.Helper:seekWidgetByName(panel, "no_btn")
    -- bumaiBtn:addTouchEventListener(handler(self, self.onClickDiPaoLaZuoBtn))
    -- bumaiBtn:setTag(tag * 10)
    -- local btnText = bumaiBtn:getChildByName("no_word")
    -- btnText:removeFromParent()

    local bumaiBtn = ccui.Button:create()
    bumaiBtn:loadTextureNormal("games/common/game/common/btn_buxia.png")
    bumaiBtn:loadTexturePressed("games/common/game/common/btn_buxia.png")
    panel:addChild(bumaiBtn)
    bumaiBtn:addTouchEventListener(handler(self, self.onClickDiPaoLaZuoBtn))
    bumaiBtn:setTag(tag * 10)
    -- bumaiBtn:setTitleText("不买马") -- 设置按钮文字
    -- bumaiBtn:setTitleColor(cc.c3b(255, 255, 255)) -- 设置按钮文字
    -- bumaiBtn:setTitleFontSize(32); -- 按钮文字的字体大小

    local text = ccui.Text:create();
    text:setString("不买马")
    text:setFontSize(32)
    text:setPosition(bumaiBtn:getContentSize().width * 0.5, bumaiBtn:getContentSize().height * 0.5)
    text:setFontName("hall/font/fangzhengcuyuan.TTF")
    text:setColor(cc.c3b(255, 255, 255))
    bumaiBtn:addChild(text)
    table.insert(btns, bumaiBtn)
    bumaiBtn:setTouchEnabled(true)


    local maimaBtn = ccui.Helper:seekWidgetByName(panel, "run_btn_1")
    maimaBtn:setTag(tag * 10 + 1)
    maimaBtn:removeAllChildren()


    local text2 = ccui.Text:create();
    text2:setString("买马")
    text2:setFontSize(32)
    text2:setPosition(maimaBtn:getContentSize().width * 0.5, maimaBtn:getContentSize().height * 0.5)
    text2:setFontName("hall/font/fangzhengcuyuan.TTF")
    text2:setColor(cc.c3b(255, 255, 255))
    maimaBtn:addChild(text2)


    maimaBtn:addTouchEventListener(handler(self, self.onClickDiPaoLaZuoBtn))
    maimaBtn:setTouchEnabled(true)
    table.insert(btns, maimaBtn)
end

function shantoumjGameUIView:parseLaPaoZuoDiBtn(parent, btns, dataList)
    table.sort(dataList, function(a, b) return a <= b end)
    local lastBtns = {}
    for i, v in ipairs(dataList) do
        table.insert(lastBtns, btns[v + 1]:clone())
    end

    parent:removeAllChildren()
    local size = parent:getContentSize()
    local i = 1
    while (i <= #lastBtns) do
        local btn = lastBtns[i]
        -- btn:setPosition(cc.p(size.width - btn:getContentSize().width * (#lastBtns - i + 0.5), size.height * 0.5))
        btn:setPosition(cc.p(size.width / 2 - (btn:getContentSize().width + 50) * (#lastBtns - i - 0.5), size.height * 0.5 - 50))
        btn:setTouchEnabled(true)
        btn:addTouchEventListener(handler(self, self.onClickDiPaoLaZuoBtn));
        parent:addChild(btn)
        i = i + 1
    end
    
    return lastBtns
end

return shantoumjGameUIView