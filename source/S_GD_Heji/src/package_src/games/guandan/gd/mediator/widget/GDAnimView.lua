-------------------------------------------------------------------------
-- Desc:   斗地主动画层UI 继承GDRoomView
-- Author:   Machine
-------------------------------------------------------------------------
local GDRoomView = require("package_src.games.guandan.gd.mediator.widget.GDRoomView")
local GDAnimView = class("GDAnimView", GDRoomView)
local GDDataConst = require("package_src.games.guandan.gd.data.GDDataConst")
local GDConst = require("package_src.games.guandan.gd.data.GDConst")
local GDCard = require("package_src.games.guandan.gd.utils.card.GDCard")
local PokerUtils = require("package_src.games.guandan.gdcommon.commontool.PokerUtils")
local PokerClippingNode = require("package_src.games.guandan.gdcommon.commontool.PokerClippingNode")
local GDDefine = require("package_src.games.guandan.gd.data.GDDefine")

function GDAnimView:initView()
    self.size = cc.size(420,100)
    --玩家头像位置
    self.seatPos = {
        [GDConst.SEAT_MINE] = cc.p(70,100),
        [GDConst.SEAT_RIGHT] = cc.p(display.width - 239,display.height - 185),
        [GDConst.SEAT_LEFT] = cc.p(239,display.height - 185),
        [GDConst.SEAT_TOP] = cc.p(display.width-256, display.height - 15),
        }

    --手牌动画-----------------------
    --手牌位移距离
    self.handCardDis = 250
    self.handOffsetX = 20
    self.handOffSetY = -20
    --手牌动画位置
    if self.m_data == GDConst.GAME_UP_TYPE.UP_GRADE then--升级场
        self.handCardPos = {
            [GDConst.SEAT_MINE] = cc.p(display.cx, display.height-302),
            [GDConst.SEAT_LEFT] = cc.p(193, display.height - 192),
            [GDConst.SEAT_RIGHT] = cc.p(display.width - 190,display.height - 192),
            [GDConst.SEAT_TOP] = cc.p(display.width-451, display.height - 17),
        }
    else
        self.handCardPos = {
            [GDConst.SEAT_MINE] = cc.p(display.cx, display.height-302),
            [GDConst.SEAT_LEFT] = cc.p(193, display.height - 192 - 60),
            [GDConst.SEAT_RIGHT] = cc.p(display.width - 190,display.height - 192- 60),
            [GDConst.SEAT_TOP] = cc.p(display.width-451, display.height - 17 - 60),
        }
    end
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

    self.headSize = cc.size(149, 165)
end

function GDAnimView:show()
    self.m_pWidget:setVisible(true)
end

---------------------------------------
-- 函数功能：    根据玩家座位和牌型播放对应的动画
-- 返回值：      无
-- id:   事件id
---------------------------------------
function GDAnimView:showCardTypeAnim(seat, cardType, cardLenght)
    -- Log.i("--wangzhi--seat--cardType--cardLenght--",seat,cardType,cardLenght)
    local isPlay = true
    if cardType == enmCardType.EBCT_BASETYPE_3AND2 then
        self:showShunAnim("package_res/games/guandan/anim/image/threeTakeTwo.png",seat)
    elseif cardType == enmCardType.EBCT_BASETYPE_SISTER then
        self:showShunAnim("package_res/games/guandan/anim/image/shunzi.png",seat, 36)
    elseif cardType == enmCardType.EBCT_CUSTOMERTYPE_BOMB then
        self:showZhaDan(seat)
    elseif cardType == enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB then
        self:showAnimationGuandan(enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB)
    elseif cardType == enmCardType.EBCT_CUSTOMERTYPE_PAIRS then
        --木板
        self:showAnimationGuandan(cardType)
    elseif cardType == enmCardType.EBCT_CUSTOMERTYPE_3KINDS then
        --钢板
        self:showAnimationGuandan(cardType)
    elseif cardType == enmCardType.EBCT_CUSTOMERTYPE_SISTER_BOMB then
        --同花顺
        self:showAnimationGuandan(cardType)
        self:showSisterAnim("package_res/games/guandan/anim/image/sister_bomb.png")
    end
end

function GDAnimView:showShunAnim(file,seat, disX, isJiefeng)
    disX = disX or 0
    local cards =  DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_LASTOUTCARDS)
    local pos = self.handCardPos[seat]
    local cardWidth = (#cards-1)*self:getSpace(#cards)+GDCard.WIDTH
    if isJiefeng then
        cardWidth = 0
    end

    if seat == GDConst.SEAT_MINE then
        pos = cc.p(pos.x-270+disX, pos.y-68)
    elseif seat == GDConst.SEAT_RIGHT then
        pos = cc.p(pos.x+41-cardWidth+disX, pos.y-65)
    elseif seat == GDConst.SEAT_TOP then
        pos = cc.p(pos.x+40-cardWidth+disX, pos.y-60)
    elseif seat == GDConst.SEAT_LEFT then
        pos = cc.p(pos.x+259-cardWidth+disX, pos.y-65)
    end
    local root = display.newSprite("package_res/games/guandan/anim/image/boost.png")
    root:setPosition(pos)
    self.m_pWidget:addChild(root)
    
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
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/guandan/anim/AnimationLight.csb")
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

function GDAnimView:setCustomOpacity(parent,value)
    parent:setOpacity(value)
    for i,v in ipairs(parent:getChildren()) do
        v:setOpacity(value)
    end
end

function GDAnimView:showZhaDan(seat)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/guandan/anim/AnimationZhadan3.csb")
    local armature = ccs.Armature:create("AnimationZhadan3")
    armature:getAnimation():play("AnimationZhadan1")
    armature:setPosition(self.seatPos[seat])
    self.m_pWidget:addChild(armature)

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

function GDAnimView:showHuojian()
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/guandan/anim/AnimationZhadan3.csb")
    local armature = ccs.Armature:create("AnimationZhadan3")
    armature:getAnimation():play("AnimationHuojian1")
    armature:setPosition(self.huojianBeganPos)
    self.m_pWidget:addChild(armature)

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

function GDAnimView:showAnimationGuandan(aniType)
    local aniName = ""
    local posY = 0
    if aniType == enmCardType.EBCT_CUSTOMERTYPE_3KINDS then
        aniName = "AnimGangban"
        posY = 100
    elseif aniType == enmCardType.EBCT_CUSTOMERTYPE_PAIRS then
        aniName = "AnimMuban"
    elseif aniType == enmCardType.EBCT_CUSTOMERTYPE_SISTER_BOMB then
        aniName = "AnimShunzi"
    elseif aniType == enmCardType.EBCT_CUSTOMERTYPE_KING_BOMB then
        aniName = "Animwangzha1"
    elseif aniType == "kang_gong" then
        aniName = "AnimKanggong"
    else
        return
    end
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/guandan/anim/guandanAni/AnimationGuandan2.csb")
    local armature = ccs.Armature:create("AnimationGuandan2")
    armature:getAnimation():play(aniName)
    armature:setPosition(cc.p(display.cx, display.cy+posY))
    self.m_pWidget:addChild(armature)
    local function animationEvent(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.complete then
            if movementID == "Animwangzha1" then
                armature:getAnimation():play("Animwangzha2")
            else
                armature:removeFromParent()
            end
        end
    end
    armature:getAnimation():setMovementEventCallFunc(animationEvent)
end

--返回牌距
function GDAnimView:getSpace(cardNum)
    local space = GDCard.NORMALSPACE * GDCard.OPRASCALE;
    if cardNum > 1 then
        space = (self.size.width - GDCard.WIDTH * GDCard.OPRASCALE)/(cardNum - 1);
    else
        return 0;
    end
    space = space > GDCard.MAXSPACE * GDCard.OPRASCALE and GDCard.MAXSPACE * GDCard.OPRASCALE or space;

    return space;
end

function GDAnimView:headExchange(playerId, playerTab, call)
    for i=1, 2 do
        local player = DataMgr:getInstance():getPlayerInfo(playerId[i])
        local sex = player:getProp(GDDefine.SEX)
        local name = player:getProp(GDDefine.NAME)
        local url = player:getProp(GDDefine.ICON_ID)
        local nHeadSize = 115
        local sp = ccui.Scale9Sprite:createWithSpriteFrameName("common/head_bg.png", cc.rect(21, 20, 10, 10))
        sp:setContentSize(self.headSize)
        if i == 1 then
            sp:setPosition(cc.p(display.cx-130, display.cy))
        else
            sp:setPosition(cc.p(display.cx+130, display.cy))
        end
        self.m_pWidget:addChild(sp,1)

        local pLabel = cc.Label:createWithTTF(PokerUtils:subUtfStrByCn(name, 1, 4, ".."), "hall/font/fangzhengcuyuan.TTF", 25)
        pLabel:setAnchorPoint(cc.p(0.5, 0))
        pLabel:setPosition(cc.p(self.headSize.width/2, 10))
        sp:addChild(pLabel)
        
        local defMale = "package_res/games/guandan/head/defaultHead_male.png"
        local defFemale = "package_res/games/guandan/head/defaultHead_female.png"
        local stencil = "package_res/games/guandan/head/cicleHead.png"
        local pos = cc.p(self.headSize.width/2, self.headSize.height/2+10)
        if not PokerUtils:isNetWorkHeadUrl(url) then
            local headFile = sex == GDConst.MALE and defMale or defFemale
            local head = PokerClippingNode.new(stencil, headFile, nHeadSize)
            head:setPosition(pos)
            sp:addChild(head)
        else
            local fileName = player:getProp(GDDefine.USERID) .. ".jpg"
            PokerUtils:updateHead(fileName, url, stencil, nHeadSize, sp, nil, 10, pos)
        end

        local delay = cc.DelayTime:create(1)
        local jumpTo
        if i == 1 then
            jumpTo = cc.JumpTo:create(0.5, cc.p(display.cx+130, display.cy), 100, 1)
        else
            jumpTo = cc.JumpTo:create(0.5, cc.p(display.cx-130, display.cy), -100, 1)
        end
        local delay2 = cc.DelayTime:create(0.5)
        local remove = cc.RemoveSelf:create()
        local callFunc = cc.CallFunc:create(function()
            if i == 2 and call then
                call()
            end

            for k, v in pairs(playerTab) do
                v:show()
            end
        end)
        local seq = cc.Sequence:create(delay, jumpTo, delay2, remove, callFunc)
        sp:runAction(seq)
    end
    local imageView = ccui.ImageView:create("package_res/games/guandan/hall/huanpi2/Common/img_exchange_success.png")
    imageView:setPosition(cc.p(display.cx, display.cy))
    self.m_pWidget:addChild(imageView, 1)

    local delay = cc.DelayTime:create(1)
    local rotate = cc.RotateBy:create(0.5, 180)
    local delay2 = cc.DelayTime:create(0.5)
    local remove = cc.RemoveSelf:create()
    local seq = cc.Sequence:create(delay, rotate, delay2, remove)
    imageView:runAction(seq)
end

function GDAnimView:showSisterAnim(file)
    local root = display.newSprite("package_res/games/guandan/anim/image/boost.png")
    root:setPosition(cc.p(display.cx-20, display.cy-80))
    root:setOpacity(0)
    self.m_pWidget:addChild(root)
    
    local image = display.newSprite(file)
    image:setPosition(root:getContentSize().width/2 + 30,root:getContentSize().height/2)
    image:setOpacity(0)
    root:addChild(image,2)

    local easeOut = cc.EaseSineOut:create(cc.MoveBy:create(0.2,cc.p(10,0)))
    local easeIn = cc.EaseSineIn:create(cc.MoveBy:create(0.2,cc.p(10,0)))
    local func1 = cc.CallFunc:create(function()
        transition.fadeIn(root,{time = 0.2})
        for i,v in ipairs(root:getChildren()) do
            transition.fadeIn(v,{time = 0.2})
        end
    end)
    local func2 = cc.CallFunc:create(function()
        transition.fadeOut(root,{time = 0.2})
        for i,v in ipairs(root:getChildren()) do
            transition.fadeOut(v,{time = 0.2})
        end
    end)
    local seq = cc.Sequence:create(
        cc.Spawn:create(func1, easeOut)
        , cc.MoveBy:create(0.6,cc.p(20,0))
        , cc.Spawn:create(func2, easeIn))
    transition.execute(root,seq,{onComplete = function()
        root:removeFromParent()
    end})
    transition.execute(root,
        cc.Sequence:create(
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(function()
                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/guandan/anim/AnimationLight.csb")
                local armature = ccs.Armature:create("AnimationLight")
                armature:getAnimation():play("AnimationLight")
                armature:setPosition(root:getContentSize().width/2 + 30,root:getContentSize().height/2)
                root:addChild(armature,1)
                armature:performWithDelay(function()
                    armature:removeFromParent(true)
                end, 0.8);
            end)
    ))
end

return GDAnimView