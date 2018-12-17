-------------------------------------------------------------------------
-- Desc:   二人斗地主动画层UI 继承DDZTWOPRoomView
-- Author:   
-------------------------------------------------------------------------
local DDZTWOPRoomView = require("package_src.games.ddztwop.mediator.widget.DDZTWOPRoomView")
local DDZTWOPConst = require("package_src.games.ddztwop.data.DDZTWOPConst")
local DDZTWOPCard = require("package_src.games.ddztwop.utils.card.DDZTWOPCard")
local DDZTWOPAnimView = class("DDZTWOPAnimView", DDZTWOPRoomView)

---------------------------------------
-- 函数功能：   初始化UI数据
-- 返回值：     无
---------------------------------------
function DDZTWOPAnimView:initView()
    self.m_width = display.width
    self.m_height = display.height
    --玩家头像位置
    self.seatPos = {
        [DDZTWOPConst.SEAT_MINE] = cc.p(70,100),
        [DDZTWOPConst.SEAT_RIGHT] = cc.p(display.width - 246,display.height - 185)
        }

    --手牌动画-----------------------
    --手牌位移距离
    self.handCardDis = 250

    --手牌动画位置
    self.handCardPos = {
        [DDZTWOPConst.SEAT_MINE] = cc.p(display.cx-self.handCardDis-35,275),
        [DDZTWOPConst.SEAT_RIGHT] = cc.p(display.cx-self.handCardDis-35,display.height - 265)
    }
    --手牌动画第一段时间
    self.handDelayTime1 = 0.2
    --手牌动画第二段时间
    self.handDelayTime2 = 0.7
    --手牌动画渐现时间
    self.handFadeInTime = 0.5
    --手牌渐隐时间
    self.handFadeOutTime = 0.2
    --手牌动画中间位移时间
    self.handCenterMoveTime = 1
    --手牌动画中间位移距离
    self.handCenterMoveDis = 3
    --光效播放延迟时间
    self.lightTime = 0.3
    --光效移除延迟时间
    self.lightDelayTime = 2
    --光效偏移
    self.lightOffsetY = 30
    --手牌动画-----------------------

    --炸弹丢出时间
    self.zhandanTime = 0.6
    --炸弹最终位置
    self.zhadanEndPos = cc.p(display.cx,display.cy)
    --炸弹消失时间
    self.zhadanDelayTime = 1


    --火箭起始位置
    self.huojianBeganPos = cc.p(display.cx,display.cy)
    --火箭上升终点位置
    self.upEndPos = cc.p(display.cx,display.height+300)
    --火箭掉落终止位置
    self.dwonEndPos = cc.p(display.cx,display.cy)
    --火箭上升时间
    self.huojianUpTime = 0.4
    --火箭下落时间
    self.huojianDwonTime = 0.3
    --火箭爆炸消失时间
    self.huojianDelayTime = 2
    --火箭旋转角度
    self.rotation = -180


    --春天动画位置
    self.springPos = cc.p(display.cx,display.cy)
    --春天动画消失时间
    self.springDelayTime = 1.5


    --飞机动画起始位置
    self.feijiBeganPos = cc.p(0,display.cy + 50)
    --飞机动画结束时间
    self.feijiEndPos = cc.p(display.width,display.cy - 50)
    --飞机动画时间
    self.feijiTime = 3
    self.pan_game = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_game")
    self.pan_mf = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_mf")
end

---------------------------------------
-- 函数功能：   展示UI
-- 返回值：     无
---------------------------------------
function DDZTWOPAnimView:show()
    self.m_pWidget:setVisible(true)
end

---------------------------------------
-- 函数功能：    根据玩家座位和牌型播放对应的动画
-- 返回值：      无
--[[
    参数：
    seat        播放动画位置
    cardType    动画类型  牌型
    cardLenght  牌组的长度   有多少张牌
]]
---------------------------------------
function DDZTWOPAnimView:showCardTypeAnim(seat, cardType, cardLenght)
    Log.i("--wangzhi--seat--cardType--cardLenght--",seat,cardType,cardLenght)
    local isPlay = true
    if cardType == DDZTWOPCard.CT_THREE_LINE_TAKE_ONE then
        if cardLenght == 4 then
            self:showShunAnim(DDZTWOPConst.HANDANIMPATH[DDZTWOPCard.CT_THREE_LINE_TAKE_ONE],seat)
        else
            if isPlay then
                kPokerSoundPlayer:playEffect("feiji")
            end
            self:showFeiji()
        end
    elseif cardType == DDZTWOPCard.CT_THREE_LINE_TAKE_DOUBLE then
        if cardLenght == 5 then
            self:showShunAnim(DDZTWOPConst.HANDANIMPATH[DDZTWOPCard.CT_THREE_LINE_TAKE_DOUBLE],seat)
        else
            if isPlay then
                kPokerSoundPlayer:playEffect("feiji")
            end
            self:showFeiji()
        end  
    elseif cardType == DDZTWOPCard.CT_FOUR_LINE_TAKE_ONE then
        self:showShunAnim(DDZTWOPConst.HANDANIMPATH[DDZTWOPCard.CT_FOUR_LINE_TAKE_ONE],seat)
    elseif cardType == DDZTWOPCard.CT_FOUR_LINE_TAKE_DOUBLE then
        self:showShunAnim(DDZTWOPConst.HANDANIMPATH[DDZTWOPCard.CT_FOUR_LINE_TAKE_DOUBLE],seat)
    elseif cardType == DDZTWOPCard.CT_ONE_LINE then
        if isPlay then
            kPokerSoundPlayer:playEffect("shunzi_liandui")
        end
        self:showShunAnim(DDZTWOPConst.HANDANIMPATH[DDZTWOPCard.CT_ONE_LINE],seat)
    elseif cardType == DDZTWOPCard.CT_DOUBLE_LINE then
        if isPlay then
            kPokerSoundPlayer:playEffect("shunzi_liandui")
        end
        self:showShunAnim(DDZTWOPConst.HANDANIMPATH[DDZTWOPCard.CT_DOUBLE_LINE],seat) 
    elseif cardType == DDZTWOPCard.CT_THREE_LINE then
        if isPlay then
            kPokerSoundPlayer:playEffect("feiji")
        end
        self:showFeiji()
    elseif cardType == DDZTWOPCard.CT_BOMB then
        if isPlay then
            kPokerSoundPlayer:playEffect("zhadan")
        end
        self:showZhaDan(seat)
    elseif cardType == DDZTWOPCard.CT_MISSILE then
        if isPlay then
            kPokerSoundPlayer:playEffect("huojian")
        end
        self:showHuojian()          
    end
end

---------------------------------------
-- 函数功能：    播放动画函数
-- 返回值：      无
--[[
    参数：
    seat        播放动画位置
    type        动画的类型  牌型
]]
---------------------------------------
function DDZTWOPAnimView:showGameAnim(seat, type)
    self.pan_game:stopAllActions()
    self.pan_game:removeAllChildren()
    if type == 1 then
        kPokerSoundPlayer:playEffect("spring")
        self:showSpring()
    elseif type == 2 then
        kPokerSoundPlayer:playEffect("spring")
        self:showSpring()
    elseif type == 3 then
        kPokerSoundPlayer:playEffect("double")
        self:showDouble()        
    end
end

---------------------------------------
-- 函数功能：    播放春天动画
-- 返回值：      无
---------------------------------------
function DDZTWOPAnimView:showSpring()
    local armature = ccs.Armature:create("AnimationZhadan3")
    armature:getAnimation():play("AnimationChuntian")
    armature:setPosition(self.springPos)
    self.pan_game:addChild(armature)
    armature:performWithDelay(function()
        armature:removeFromParent(true)
    end, self.springDelayTime);
end

---------------------------------------
-- 函数功能：    播放顺子、三带一、四带二、连对等动画
-- 返回值：      无
--[[
    参数：
    file     动画资源路径
    seat     是哪个位置播放动画
]]
---------------------------------------
function DDZTWOPAnimView:showShunAnim(file,seat)
    Log.i("--wangzhi-file--seat--",file,seat)
    local root = display.newSprite(DDZTWOPConst.HANDANIMBGPATH)
    root:setPosition(self.handCardPos[seat])
    self.pan_game:addChild(root)

    local image = display.newSprite(file)
    image:setPosition(root:getContentSize().width/2 + 30,root:getContentSize().height/2)
    root:addChild(image,2)
    self:setCustomOpacity(root,0)
    local moveAction1 = cc.EaseSineOut:create(cc.MoveBy:create(self.handDelayTime1,cc.p(self.handCardDis,0)))
    local moveAction2 = cc.EaseSineIn:create(cc.MoveBy:create(self.handDelayTime2,cc.p(self.handCardDis,0)))
    local func1 = cc.CallFunc:create(function()
        transition.fadeIn(root,{time = self.handFadeInTime})
        for i,v in ipairs(root:getChildren()) do
            transition.fadeIn(v,{time = self.handFadeInTime})
        end
    end)
    local func2 = cc.CallFunc:create(function()
        transition.fadeOut(root,{time = self.handFadeOutTime})
        for i,v in ipairs(root:getChildren()) do
            transition.fadeOut(v,{time = self.handFadeOutTime})
        end
    end)

    transition.execute(root,cc.Sequence:create(cc.DelayTime:create(self.lightTime),cc.CallFunc:create(function()
        local armature = ccs.Armature:create("AnimationLight")
        armature:getAnimation():play("AnimationLight")
        armature:setPosition(root:getContentSize().width/2 + self.lightOffsetY,root:getContentSize().height/2)
        root:addChild(armature,1)
        armature:performWithDelay(function()
            armature:removeFromParent(true)
        end, self.lightDelayTime);
    end)))
   
    local seq  = cc.Sequence:create(cc.Spawn:create(func1,moveAction1),cc.MoveBy:create(self.handCenterMoveTime,cc.p(self.handCenterMoveDis,0)),cc.Spawn:create(func2,moveAction2))
    transition.execute(root,seq,{onComplete = function()
        root:removeFromParent()
    end})
end

---------------------------------------
-- 函数功能：    设置节点的透明度
-- 返回值：      无
--[[
    参数：
    parent:     需要设置透明度的节点
    value：     需要设置的透明度
]]
---------------------------------------
function DDZTWOPAnimView:setCustomOpacity(parent,value)
    parent:setOpacity(value)
    for i,v in ipairs(parent:getChildren()) do
        v:setOpacity(value)
    end
end

---------------------------------------
-- 函数功能：    播放飞机动画
-- 返回值：      无
---------------------------------------
function DDZTWOPAnimView:showFeiji()
    local armature = ccs.Armature:create("AnimationZhadan3")
    armature:getAnimation():play("AnimationFeiji")
    armature:setPosition(self.feijiBeganPos)
    self.pan_game:addChild(armature)
    transition.execute(armature,cc.MoveTo:create(self.feijiTime,self.feijiEndPos),{onComplete = function()
        armature:removeFromParent(true)
    end})
end

---------------------------------------
-- 函数功能：    播放炸弹动画
-- 返回值：      无
--[[
    参数：
    seat        播放动画位置
]]
---------------------------------------
function DDZTWOPAnimView:showZhaDan(seat)
    local armature = ccs.Armature:create("AnimationZhadan3")
    armature:getAnimation():play("AnimationZhadan1")
    armature:setPosition(self.seatPos[seat])
    self.pan_game:addChild(armature)

    local controlPos1 = self.seatPos[seat]
    local controlPos2 = self.zhadanEndPos
    controlPoint1 = controlPos1
    contrloPoint2 = cc.p((controlPos1.x+controlPos2.x)/2,(controlPos1.y+controlPos2.y)/2+180)
    endPosition = controlPos2

    local bezier = cc.BezierTo:create(self.zhandanTime,{controlPoint1,contrloPoint2,endPosition})
    transition.execute(armature,cc.BezierTo:create(self.zhandanTime,{controlPoint1,contrloPoint2,endPosition}),{onComplete = function()
        armature:getAnimation():play("AnimationZhadan")
        armature:performWithDelay(function()
            armature:removeFromParent(true)
        end, self.zhadanDelayTime);
    end})
end

---------------------------------------
-- 函数功能：    播放火箭动画
-- 返回值：      无
---------------------------------------
function DDZTWOPAnimView:showHuojian()
    local armature = ccs.Armature:create("AnimationZhadan3")
    armature:getAnimation():play("AnimationHuojian1")
    armature:setPosition(self.huojianBeganPos)
    self.pan_game:addChild(armature)

    transition.execute(armature,cc.EaseExponentialIn:create(cc.MoveTo:create(self.huojianUpTime,self.upEndPos)),{onComplete = function()
        armature:setRotation(self.rotation)
        transition.execute(armature,cc.EaseExponentialIn:create(cc.MoveTo:create(self.huojianDwonTime,self.dwonEndPos)),{onComplete = function()
            armature:setRotation(0)
            armature:getAnimation():play("AnimationHuojian")
            armature:performWithDelay(function()
                armature:removeFromParent(true)
            end, self.huojianDelayTime);
        end})
    end})
    
end

return DDZTWOPAnimView