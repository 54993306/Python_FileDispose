-------------------------------------------------------------------------
-- Desc:   斗地主动画层UI 继承DDZRoomView
-- Author:   Machine
-------------------------------------------------------------------------
local DDZDataConst = require("package_src.games.paodekuai.pdk.data.DDZDataConst")
local DDZConst = require("package_src.games.paodekuai.pdk.data.DDZConst")
local DDZRoomView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZRoomView")
local DDZCard = require("package_src.games.paodekuai.pdk.utils.card.DDZCard")
local DDZAnimView = class("DDZAnimView", DDZRoomView)

function DDZAnimView:initView()
    self.m_width = display.width
    self.m_height = display.height
    self.size = cc.size(420,100)
    --玩家头像位置
    self.seatPos = {
        [DDZConst.SEAT_MINE] = cc.p(70,100),
        [DDZConst.SEAT_RIGHT] = cc.p(display.width - 239,display.height - 185),
        [DDZConst.SEAT_LEFT] = cc.p(239,display.height - 185)
        }

    --手牌动画-----------------------
    --手牌位移距离
    self.handCardDis = 250
    self.handOffsetX = 20
    self.handOffSetY = -20
    --手牌动画位置
    self.handCardPos = {
        [DDZConst.SEAT_MINE] = cc.p(display.cx-self.handCardDis-35,310),
        [DDZConst.SEAT_RIGHT] = cc.p(display.width - 219,display.height - 235),
        [DDZConst.SEAT_LEFT] = cc.p(219,display.height - 235)
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


    --春天动画位置
    self.springPos = cc.p(display.cx,display.cy)
    --春天动画消失时间
    self.springDelayTime = 1.5


    --赢了动画位置
    self.winPos = cc.p(display.cx,display.cy)
    --赢了动画消失时间
    self.winDelayTime = 1.5

    --飞机动画起始位置
    self.feijiBeganPos = cc.p(0,display.cy + 50)
    --飞机动画结束时间
    self.feijiEndPos = cc.p(display.width,display.cy - 50)
    --飞机动画时间
    self.feijiTime = 3
    self.pan_game = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_game")
    self.pan_mf = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_mf")
end

function DDZAnimView:show()
    self.m_pWidget:setVisible(true)
end

---------------------------------------
-- 函数功能：    根据玩家座位和牌型播放对应的动画
-- 返回值：      无
-- id:   事件id
---------------------------------------
function DDZAnimView:showCardTypeAnim(seat, cardType, cardLenght)
    Log.i("--wangzhi--seat--cardType--cardLenght--",seat,cardType,cardLenght)
    --self.pan_game:stopAllActions()
    --self.pan_game:removeAllChildren()
    --self:showZhaDan(seat)
    --self:showHuojian() 
    --self:showSpring()
    --self:showShunAnim("package_res/games/pokercommon/anim/image/shunzi.png",seat)
    --self:showFeiji()
    local isPlay = true
    if cardType == DDZCard.CT_THREE_LINE_TAKE_ONE
        or ((cardType == DDZCard.CT_THREE_LINE_TAKE_X or cardType == DDZCard.CT_THREE_TAKE_X) and DDZGUIZE.stRule3kinds == 1) then
        if cardLenght <= 4 then
            self:showShunAnim("package_res/games/pokercommon/anim/image/threeTakeOne.png",seat)
        else
            if isPlay then
                kPokerSoundPlayer:playEffect("feiji")
            end
            self:showFeiji()
        end
    elseif cardType == DDZCard.CT_THREE_LINE_TAKE_DOUBLE
            or cardType == DDZCard.CT_THREE_TAKE_ONE
            or cardType == DDZCard.CT_THREE_TAKE_DOUBLE
            or ((cardType == DDZCard.CT_THREE_LINE_TAKE_X or cardType == DDZCard.CT_THREE_TAKE_X) and DDZGUIZE.stRule3kinds == 2) then
        if cardLenght <= 5 then
            self:showShunAnim("package_res/games/pokercommon/anim/image/image_3dai2.png",seat)
        else
            if isPlay then
                kPokerSoundPlayer:playEffect("feiji")
            end
            self:showFeiji()
        end  
    elseif cardType == DDZCard.CT_FOUR_LINE_TAKE_ONE then
        self:showShunAnim("package_res/games/pokercommon/anim/image/foreTakeOne.png",seat)
    elseif cardType == DDZCard.CT_FOUR_LINE_TAKE_DOUBLE then
        self:showShunAnim("package_res/games/pokercommon/anim/image/foreTakeOne.png",seat)
    elseif cardType == DDZCard.CT_ONE_LINE then
        if isPlay then
            kPokerSoundPlayer:playEffect("shunzi_liandui")
        end
        self:showShunAnim("package_res/games/pokercommon/anim/image/shunzi.png",seat)
    elseif cardType == DDZCard.CT_DOUBLE_LINE then
        if isPlay then
            kPokerSoundPlayer:playEffect("shunzi_liandui")
        end
        self:showShunAnim("package_res/games/pokercommon/anim/image/liandui.png",seat) 
    elseif cardType == DDZCard.CT_THREE_LINE then
        if isPlay then
            kPokerSoundPlayer:playEffect("feiji")
        end
        self:showFeiji()
    elseif cardType == DDZCard.CT_BOMB then
        if isPlay then
            kPokerSoundPlayer:playEffect("zhadan")
        end
        self:showZhaDan(seat)
    elseif cardType == DDZCard.CT_MISSILE then
        if isPlay then
            kPokerSoundPlayer:playEffect("huojian")
        end
        self:showHuojian()          
    end
end

function DDZAnimView:showGameAnim(seat, type,spring)
    self.pan_game:stopAllActions()
    self.pan_game:removeAllChildren()
    if type == 1 then
        kPokerSoundPlayer:playEffect("spring")
        self:showSpring(spring)
    elseif type == 2 then
        kPokerSoundPlayer:playEffect("spring")
        self:showSpring(spring)
    elseif type == 3 then
        kPokerSoundPlayer:playEffect("double")
        -- self:showDouble()     
    elseif type == 4 then
        self:myWinAnim()
        -- kPokerSoundPlayer:playEffect("double")
        -- self:showDouble()      
    end
end

function DDZAnimView:showGuanAnim(type,pos,site)
    kPokerSoundPlayer:playEffect("spring")
    self:showSpring(type,pos,site)
end

function DDZAnimView:showMFAnim(ty, dSeat, dpx, dpy, sSeat, spx, spy)
    Log.i("------showMFAnim type", ty)
    local sex = ""
    if ty == 1 then
        self:showHezuo(dSeat, dpx, dpy, sSeat, spx, spy)
    elseif ty == 3 then
        self:showJinggubang(dSeat, dpx, dpy, sSeat, spx, spy)
    elseif ty == 2 then
        self:showSongtao(dSeat, dpx, dpy, sSeat, spx, spy)
    elseif ty == 4 then
        self:showJinguzou(dSeat, dpx, dpy, sSeat, spx, spy)
        local playerInfo = DDZPlayerManager.getInstance():getPlayerInfo(dSeat)
        sex = "0"
        if playerInfo and playerInfo.se == 1 then
            sex = "1"
        end
    elseif ty == 5 then
        self:showWuzhishan(dSeat, dpx, dpy, sSeat, spx, spy)
    end
    kPokerSoundPlayer:playEffect("magic_face_" .. ty .. sex)
end

function DDZAnimView:showSpring(type,pos,site)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/paodekuai/animation/AnimationGuanpai5.csb")
    local armature = ccs.Armature:create("AnimationGuanpai5")
    local playName = "AniGuanpai"
    pos = pos or self.springPos
    if type == 1 then
        playName = "AniGuanpai"
    elseif type == 2 then
        playName = "AniGuanpai"
    elseif type == 3 then
        playName = "AniDaguan"
    elseif type == 4 then
        playName = "AniXiaoguan"
    end
    if type == 3 then
        if site == 1 then
            pos.x = pos.x + 5
            pos.y = pos.y - 18
        elseif site == 2 then
            pos.x = pos.x -10
            pos.y = pos.y + 13
        elseif site == 3 then
            pos.x = pos.x + 10
            pos.y = pos.y + 20
        end
    elseif type == 4 then
        if site == 1 then
            pos.x = pos.x + 5
            pos.y = pos.y - 58
        elseif site == 2 then
            pos.x = pos.x -10
            pos.y = pos.y -27
        elseif site == 3 then
            pos.x = pos.x + 10
            pos.y = pos.y -20
        end
    end
    armature:getAnimation():play(playName)
    armature:setPosition(pos)
    self.pan_game:addChild(armature)
    armature:performWithDelay(function()
        armature:removeFromParent(true)
    end, self.springDelayTime*1.5)
end

-- 赢了的动画
function DDZAnimView:myWinAnim()
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/paodekuai/animation/AnimationWin2.csb")
    local armature = ccs.Armature:create("AnimationWin2")
    armature:getAnimation():play("AniWin2")
    armature:setPosition(self.winPos)
    self.pan_game:addChild(armature)
    armature:performWithDelay(function()
        armature:removeFromParent(true)
    end, self.winDelayTime);
end



function DDZAnimView:showShunAnim(file,seat)
    Log.i("--wangzhi-file--seat--",file,seat)
    local cards =  DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_LASTOUTCARDS)
    local pos = self.handCardPos[seat]
    if seat == DDZConst.SEAT_RIGHT then
        pos = cc.p(pos.x - ((#cards-1)*self:getSpace(#cards)+DDZCard.WIDTH)/2-self.handCardDis,pos.y+ self.handOffSetY)
    elseif seat == DDZConst.SEAT_LEFT then
        pos = cc.p(pos.x + ((#cards-1)*self:getSpace(#cards)+DDZCard.WIDTH)/2-self.handCardDis - self.handOffsetX ,pos.y+ self.handOffSetY)
    elseif seat == DDZConst.SEAT_MINE then
        pos = cc.p(pos.x,pos.y - 50 + self.handOffSetY)
    end
    local root = display.newSprite("package_res/games/pokercommon/anim/image/boost.png")
    root:setPosition(pos)
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

    transition.execute(root,cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function()
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/anim/AnimationLight.csb")
        local armature = ccs.Armature:create("AnimationLight")
        armature:getAnimation():play("AnimationLight")
        armature:setPosition(root:getContentSize().width/2 + 30,root:getContentSize().height/2)
        root:addChild(armature,1)
        armature:performWithDelay(function()
            armature:removeFromParent(true)
        end, 2);
    end)))
   
    local seq  = cc.Sequence:create(cc.Spawn:create(func1,moveAction1),cc.MoveBy:create(self.handCenterMoveTime,cc.p(self.handCenterMoveDis,0)),cc.Spawn:create(func2,moveAction2))
    transition.execute(root,seq,{onComplete = function()
        root:removeFromParent()
    end})

end

function DDZAnimView:setCustomOpacity(parent,value)
    parent:setOpacity(value)
    for i,v in ipairs(parent:getChildren()) do
        v:setOpacity(value)
    end
end

function DDZAnimView:showFeiji()
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/anim/AnimationZhadan3.csb")
    local armature = ccs.Armature:create("AnimationZhadan3")
    armature:getAnimation():play("AnimationFeiji")
    armature:setPosition(self.feijiBeganPos)
    self.pan_game:addChild(armature)
    transition.execute(armature,cc.MoveTo:create(self.feijiTime,self.feijiEndPos),{onComplete = function()
        armature:removeFromParent(true)
    end})
end

function DDZAnimView:showZhaDan(seat)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/anim/AnimationZhadan3.csb")
    local armature = ccs.Armature:create("AnimationZhadan3")
    armature:getAnimation():play("AnimationZhadan1")
    armature:setPosition(self.seatPos[seat])
    self.pan_game:addChild(armature)

    local bezier
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

function DDZAnimView:showHuojian()
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/anim/AnimationZhadan3.csb")
    local armature = ccs.Armature:create("AnimationZhadan3")
    armature:getAnimation():play("AnimationHuojian1")
    armature:setPosition(self.huojianBeganPos)
    self.pan_game:addChild(armature)

    transition.execute(armature,cc.EaseExponentialIn:create(cc.MoveTo:create(self.huojianUpTime,self.upEndPos)),{onComplete = function()
        armature:setRotation(-180)
        transition.execute(armature,cc.EaseExponentialIn:create(cc.MoveTo:create(self.huojianDwonTime,self.dwonEndPos)),{onComplete = function()
            armature:setRotation(0)
            armature:getAnimation():play("AnimationHuojian")
            armature:performWithDelay(function()
                armature:removeFromParent(true)
            end, self.huojianDelayTime);
        end})
    end})
    
end

--返回牌距
function DDZAnimView:getSpace(cardNum)
    local space = DDZCard.NORMALSPACE * DDZCard.OPRASCALE;
    if cardNum > 1 then
        space = (self.size.width - DDZCard.WIDTH * DDZCard.OPRASCALE)/(cardNum - 1);
    else
        return 0;
    end
    space = space > DDZCard.MAXSPACE * DDZCard.OPRASCALE and DDZCard.MAXSPACE * DDZCard.OPRASCALE or space;

    return space;
end


return DDZAnimView