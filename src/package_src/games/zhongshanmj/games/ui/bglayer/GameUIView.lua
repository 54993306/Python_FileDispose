require("app.games.common.ui.bglayer.GameUIView")


-- local rules={
        
--         yougui={
--             ["false"]="不带鬼",
--             ["true"]="带鬼",
--         },

--         wuguikechihu={
--             ["false"]="",
--             ["true"]="无鬼可吃胡",
--         },

--         paishu={
--             ["136"]="136张牌",
--             ["120"]="120张牌",
--             ["112"]="112张牌",
--             ["108"]="108张牌",
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

-- function GameUIView:ctor(data)
--     self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/gameItem.csb");
--     self.m_data = data
--     self._selectBtn = {
--         agree = false,
--         agreeTime = 0.5,
--     }
--     self.finishXia = false -- 下嘴完成标志

--     self:initRule()

--     self.handlers = {};
--     self.Events   = {};
--     table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(MJ_EVENT.GAME_dingque_Anim_start, 
--         handler(self, self.onDingqueAnimStart)))
--     table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(MJ_EVENT.GAME_setRuleVisible, 
--         handler(self, self.setRuleVisible)))
--     table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(enMjPlayEvent.GAME_SET_CHAHU_BUTTON_STATUS_NTF, 
--         handler(self, self.setChaHuButtonHide)))

--     self:listenerExit()
-- end

-- function GameUIView:initRule()
--     local ruleStr = ""
--     local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
--     local itemList= json.decode(palyingInfo.wa)--Util.analyzeString_2(wanfa)
--     dump(itemList)
--     -- Log.i("itemList.....",itemList)
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
--     -- palyingInfo = {"测试规则"}
--     -- local count = 0
--     -- for k, v in pairs(palyingInfo) do
--     --     count = count + 1
--     --     if count % 4 == 0 then
--     --         ruleStr = ruleStr .. "\n"
--     --     end
--     --     ruleStr = ruleStr..v 
--     -- end

--     -- if #palyingInfo > 0 then
--         -- local line = math.ceil(#palyingInfo / 4)
--         self:createRuleTip(cc.size(320, 3 * 20 + 2), ruleStr)
--     -- end
-- end

--------------------------
-- 创建规则
-- @param size 规则文字的大小尺寸, 在此只用到了width
-- @string str 规则文字
-- function GameUIView:createRuleTip(size, str)
--     Log.i("GameUIView:createRuleTip")
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
--     self.ruleTextBg:addTo(self.m_pWidget)
--     -- 初始化为不可见
--     self:setRuleVisible(nil, false)
-- end


------------------
-- 设置规则可见性
-- @bool isVisible 可见性
-- function GameUIView:setRuleVisible(event, isVisible)
--     if event then
--         Log.i("------GameUIView:setRuleVisible event", unpack(event._userdata))
--         isVisible = unpack(event._userdata)
--     end
--     self.ruleTextBg:setVisible(isVisible)
--     -- self.ruleBtnLayout:setVisible(not isVisible)
--     -- self.ruleBtnLayout:setOpacity(isVisible and 0 or 255)
--     -- self.ruleBtnLabel:setVisible(not isVisible)
--     -- self.ruleBtnLine:setVisible(not isVisible)
-- end

