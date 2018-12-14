local BgLayer     = import("app.games.common.ui.bglayer.BgLayer")
local zhongshanmjBgLayer       = class("zhongshanmjBgLayer", BgLayer)
local kRuleBtnSize = cc.size(70, 40)

-- local rules={
		
-- 		yougui={
--             ["false"]="不带鬼",
--             ["true"]="带鬼",
--         },

--         wuguikechihu={
--             ["false"]="",
--             ["true"]="无鬼可吃胡",
--         },

--         paishu={
--         	["136"]="136张牌",
--         	["120"]="120张牌",
--         	["112"]="112张牌",
--         	["108"]="108张牌",
--         },

--         gui={
--             ["47"]="白板鬼",
--             ["45"]="红中鬼",
--         },

--         laizishima={
--             ["false"]="鬼按位置看马",
--             ["true"]="鬼算所有人的马",
--         },

--         wuguihumapaishu={
--             ["0"]="无鬼胡正常翻马",
--             ["2"]="无鬼胡马牌数+2",
--             ["4"]="无鬼胡马牌数+4",
--         },

--         zipaimashu={
--             ["5"]="玩1马时字牌为5马",
--             ["10"]="玩1马时字牌为10马",
--         },

--         mashu={
--             ["6"]="6马",
--             ["4"]="4马",
--             ["8"]="8马",
--             ["10"]="10马",
--             ["1"]="1马",
--         },

--         mapailiebiao={
--             ["true"]="1,5,9鬼为马",
--             ["false"]="按位置看马",
--         },

--         dpfen={
--             ["1"]="1分",
--             ["2"]="2分",
--             ["5"]="5分",
--             ["10"]="10分",
--         },

--         zmfen={
--             ["2"]="1分2分",
--             ["4"]="2分4分",
--             ["10"]="5分10分",
--             ["20"]="10分20分",
--         },
-- }

-- @brief  刷新剩余数据
-- @param  void
-- @return void
--]]
-- function zhongshanmjBgLayer:refreshRemainCount(event)
--     if self._shengyu then
--         local count = SystemFacade:getInstance():getRemainPaiCount()
--         if count < 0 then
--             count = 0
--         end
--         -----------------------回放-----------------------------------
--         if VideotapeManager.getInstance():isPlayingVideo() then
--             local jushu  = kPlaybackInfo:getCurrentGamesNum()
--             local syText = string.format("剩余 %s 张    第 %d 局", count, jushu)
--             self._shengyu:setString(syText) 
--         else
--             if event then
--                 local animation = unpack(event._userdata)
--                 -- 胡牌动作发生时, 不再刷新牌局数量
--                 if animation == "AnimationHU" then
--                     return
--                 end
--             end
--             local currCount     = SystemFacade:getInstance():getCurrentGameCount()
--             local totalCount    = SystemFacade:getInstance():getTotalGameCount()
--             local syText = string.format("剩余 %s 张    第 %d/%d 局",count, currCount, totalCount)
--             self._shengyu:setString(syText)
--         end
--         ----------------------------------------------------------------
--         -- 提示流局(提示的两个数字应改为服务器下发)
--         if count ~= self.remainCount then
--             self.remainCount = count
--             if count == 14 + 4 and not VideotapeManager.getInstance():isPlayingVideo() then                
--                 Toast.getInstance():show(string.format("剩余 %d 张流局", 4))
--             end
--         end
--     end
-- end

-- function zhongshanmjBgLayer:ctor()
-- 	zhongshanmjBgLayer.super.ctor(self)
--     self:createRuleTip()
-- end

--------------------------
-- 创建规则
-- @string str 规则文字
-- function zhongshanmjBgLayer:createRuleTip()
--     Log.i("zhongshanmjBgLayer:createRuleTip")
--     -------------------回放相关-------------------------------
--     if VideotapeManager.getInstance():isPlayingVideo() then
--         self:addCustomRule()
--     else
--         -- 将规则说明放到GameUIView中
--         self:addRuleBtn()
--     end
-- end

-- function zhongshanmjBgLayer:showViews()
--     Log.i("------zhongshanmjBgLayer:showViews")
--     -- 移除速配界面
--     self:removeMatchLoading()
--     -- 设置门风位置
--     self._clock:setDoorDirect()
--     -- 设置打牌玩家
--     local startData = self.gamePlaySystem:getGameStartDatas()
--     local site = self.gamePlaySystem:getPlayerSiteById(startData.firstplay)
--     self._clock:setThePoint(site, enClockType.PLAY_CARD)

--     self:refreshRemainCount()
--     self:showShengyuStr()

--     -----------------------回放-----------------------------------
--     -- if VideotapeManager.getInstance():isPlayingVideo() then
--     --     local ruleStr = ""
--     --     local palyingInfo = kFriendRoomInfo:getPlayingInfo()
--     --     for k, v in pairs(palyingInfo) do
--     --         ruleStr = ruleStr..v
--     --     end
--     --     if self.ruleText then self.ruleText:setString(ruleStr) end
--     -- end
--     ---------------------------------------------------
-- end

---------------------
-- 添加规则按钮
-- function zhongshanmjBgLayer:addRuleBtn()
--     -- 规则触摸容器
--     self.ruleBtnLayout = ccui.Layout:create()
--     self.ruleBtnLayout:setContentSize(kRuleBtnSize)
--     self:addChild(self.ruleBtnLayout)

--     self.ruleBtnLayout:setAnchorPoint(cc.p(0.5, 0.5))
--     self.ruleBtnLayout:setPosition(cc.p(display.cx, display.cy - 80))

--     -- 文字
--     self.ruleBtnLabel = cc.Label:createWithTTF("规则", "hall/font/fangzhengcuyuan.TTF", 17)
--     self.ruleBtnLabel:setColor(cc.c3b(255, 254, 173))
--     self.ruleBtnLabel:setPosition(cc.p(kRuleBtnSize.width / 2, kRuleBtnSize.height / 2))
--     self.ruleBtnLayout:addChild(self.ruleBtnLabel)

--     -- 下划线
--     local labelSize = self.ruleBtnLabel:getContentSize()
--     local startX = self.ruleBtnLabel:getPositionX() - labelSize.width * self.ruleBtnLabel:getAnchorPoint().x
--     local startY = self.ruleBtnLabel:getPositionY() - labelSize.height * self.ruleBtnLabel:getAnchorPoint().y
--     local points = {}
--     points[1] = {startX, startY}
--     points[2] = {startX + labelSize.width, startY}
--     local ruleBtnLineParams = {}
--     ruleBtnLineParams.borderColor = cc.c4f(255 / 255, 254 / 255, 173 / 255, 1)
--     ruleBtnLineParams.borderWidth = 1.5
--     self.ruleBtnLine = display.newLine(points, ruleBtnLineParams)
--     self.ruleBtnLine:addTo(self.ruleBtnLabel:getParent())

--     -- 触摸事件
--     self.ruleBtnLayout:setTouchEnabled(true)
--     self.ruleBtnLayout:setTouchSwallowEnabled(true)
--     self.ruleBtnLayout:addTouchEventListener(function (pWidget,EventType)
--             if EventType == ccui.TouchEventType.ended then
--                 -- local widget = tolua.cast(pWidget, ccui.Widget)
--                 Log.i("ended", pWidget:getTouchEndPosition().x)
--                 MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_setRuleVisible, true)
--                 -- UIManager.getInstance():pushWnd(DebugWnd)
--             elseif EventType == ccui.TouchEventType.began then
--                 Log.i("began", pWidget:getTouchBeganPosition().x)
--             end
--         end)
-- end

-- function zhongshanmjBgLayer:addCustomRule()
--     local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
--     local itemList= json.decode(palyingInfo.wa)--Util.analyzeString_2(wanfa)
--     Log.i("itemList.....",itemList)
--     local ruleStr = ""
--     -- if (#itemList > 0 ) then
--     for i, v in pairs(itemList) do
--             print (i)
--             print (tostring(v))
--             if rules[i] then
--                 local str=""
--                 if i=="dpfen" then

--                 elseif i== "zmfen" then
--                     if itemList.dpfen ==  v then
--                         str=rules["dpfen"][tostring(v)]
--                     else
--                         str=rules[i][tostring(v)]
--                     end
--                 elseif i=="paishu" then
--                     str=rules[i][tostring(v)]
--                     if v==112 then
--                         if itemList.mapailiebiao then
--                             str=str..rules["mapailiebiao"]["true"]
--                         else
--                             str=str..rules["mapailiebiao"]["false"]
--                         end
--                     end
--                 elseif i=="wuguikechihu" then
--                     -- error(itemList.yougui)
--                     -- error(i)

--                     if itemList.yougui==true then
--                         str=rules[i][tostring(v)]
--                     else
--                         -- error("....")
--                     end
--                 else
--                     str=rules[i][tostring(v)]
--                 end

--                 if str then
--                     ruleStr=ruleStr.." "..str
--                 end
--             end
--     end

--     self:createCustomRuleTip(cc.size(320, 3 * 20 + 2), ruleStr)
-- end

--------------------------
-- 创建规则
-- @param size 规则文字的大小尺寸, 在此只用到了width
-- @string str 规则文字
-- function zhongshanmjBgLayer:createCustomRuleTip(size, str)
--     if str == nil then
--         str = ""
--     end

--     -- error(str)
-- -- str = "随便测试一下长规ad则看看 是什么形式 随便测试一 下长规则看看是什么形式 下长规则看看是什么形式"
--     -- 初始化规则背景
--     self.ruleTextBg = ccui.Scale9Sprite:create(cc.rect(10, 10, 2, 2), "hall/Common/rule_bg.png")
--     -- bg:setContentSize(cc.size(size.width+10,size.height))

--     self.ruleText = cc.Label:createWithTTF(str, "hall/font/fangzhengcuyuan.TTF", 16)
--     self.ruleText:setMaxLineWidth(size.width) -- 通过此方法可以设置最大宽度, 同时其contentSize也为自动适应的大小
--     self.ruleTextBg:setContentSize(cc.size(size.width + 10, self.ruleText:getContentSize().height + 4))
--     self.ruleText:setPosition(cc.p(self.ruleTextBg:getContentSize().width * 0.5, self.ruleTextBg:getContentSize().height * 0.5))
--     self.ruleText:setAnchorPoint(cc.p(0.5, 0.5))
--     self.ruleText:setColor(cc.c3b(0xb1, 0xcc, 0xa3))
--     -- ruleText:setDimensions(size.width,size.height) -- 通过此方法可以设置大小和高度, 一旦设置后, setMaxLineWidth就无效了, 其contentSize为设置的Dimensions的大小
    
--     self.ruleText:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
--     self.ruleText:setAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)

--     self.ruleTextBg:addChild(self.ruleText)

--     self.ruleTextBg:setAnchorPoint(cc.p(0.5, 1))
--     self.ruleTextBg:setPosition(cc.p(display.cx, display.cy - 70))
--     self.ruleTextBg:addTo(self)
-- end

return zhongshanmjBgLayer
