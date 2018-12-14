--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local layerColor = cc.c4b(0,0,0,150)                --翻马层的颜色

local fmBgOffectY = 100                 --翻马的大背景的偏移量
local fmBgPosYIndex = 130               --翻马背景的Y索引值
local fmBgDOffectY = 120                --多人翻马的偏移值

local nameSubNum = 5                --名字最长显示的数
local headScakeIndex = 150          --头像缩放的索引值（显示的大小）
local headOffect = 20               --头像的偏移量
local headBgScale = 0.5             --头像的缩放值
local headKuangScale = 1.6          --头像框的缩放值
local nameFontSize = 40             --名字的字体大小(因为整体缩放后的效果所以字体偏大)
local nameFontColor = cc.c3b(255, 255, 255)  --名字的颜色
local headBgOffect_Y = 10           --头像背景的偏移值
local headAnchor = cc.p(0,0)        --头像锚点

local imgHeadScaleIndex = 70                --拉取到头像后的缩放索引

local bgHeight = 200                --麻将背景的高度
local bgDheight = 100               --当有两个以上人时的高度
local bgColor = cc.c4b(0,0,0,150)   --背景的颜色
local mjsIndex = {21,22,23,24}      --默认翻马的麻将(防止报错)

local bgLocal = 10              --背景的层级
local mjBgFrame = 5             --麻将背景的动画帧数
local mjBgAnimation = 0.08      --麻将背景的每帧动画时间 
local mjBgTimeIndex = 5         --麻将牌的动画时间索引比值

local mjScaleMax = 8            --麻将牌的正常最大显示个数
local mjClearance = 10          --每张麻将之间的间隔
local mjScaleRatio = 0.03       --超过8张牌时的缩放比值
local mjScaleMax_1 = 12         --缩放时超过12张需要特殊判断（这里需要优化）
local mjOffect_X = 5            --麻将的缩放的偏移量
local mjScaleRatio_1 = 0.08     --麻将牌超过8张并在12张之内的缩放比值
local mjDScale = 0.5            --超过两个人时麻将牌的缩放比值
local mjDScaleMax = 16          --超过两个人时正常麻将牌的最大值
local mjDHeanOffectScale_x = 130     --空出头像后缩放的距离
local mjDHeanOffect_x = 60      --空出头像的距离
local mjDMoveTime = 0.5         --麻将动画执行的最小时间值
local mjDMoveIndex = 0.32       --麻将动画的时间索引

local mjScale = 1.4             --麻将牌的缩放大小
local mjOffsetX = 3             --麻将牌的X偏移
local mjOffsetY = 20            --麻将牌的Y偏移
local mjColor = cc.c3b(128, 128, 128)   --麻将牌改变后的颜色

local lightFrameNum  = 14        --闪光动画总帧数
local lightFrameTime = 0.05      --闪光动画的每帧动画时间
local lightFrameAnimationTime = 0.6 --闪光动画的移动时间


local fanmaPath = "package_res/games/maomingmj/game/fangma.plist"                  --翻马动画图片路径
local lightPath = "package_res/games/maomingmj/game/fanmalight.plist"                   --光效动画图片路径
local titlePath = "package_res/games/maomingmj/game/fanma_text.png"         --标题路径
local headBgPath = "hall/Common/default_head_2.png"                 --默认头像背景框路径
local headPath = "hall/Common/default_head_2.png"                   --默认头像路径
local playerBoxPath = "games/common/mj/games/game_player_box.png"              --翻马框路径
local fontPath = "hall/font/fangzhengcuyuan.TTF"                                    --文字字体路径
local quanmaTextPath = "package_res/games/maomingmj/game/quanma_text.png"      --全马文字路径

local FanMaAnimation = class("FanMaAnimation",function()
    local layer = display.newColorLayer(layerColor)
    layer:setContentSize(cc.size(display.width,display.height))
    return layer
end)

function FanMaAnimation:ctor(data,quanma)
    self.m_data = data
    if quanma == nil then
        quanma = false
    end
    self.m_quanma = quanma
--    self:adListenner()
    self:addCache()
    self:createBg()
end

function FanMaAnimation:addCache()
   	cc.SpriteFrameCache:getInstance():addSpriteFrames(fanmaPath)
   	cc.SpriteFrameCache:getInstance():addSpriteFrames(lightPath)
end
function FanMaAnimation:adListenner()
    -- 创建一个事件监听器类型为 OneByOne 的单点触摸  
    local  listenner = cc.EventListenerTouchOneByOne:create()  
      -- 实现 onTouchBegan 事件回调函数  
    listenner:registerScriptHandler(function(touch, event)  
        local location = touch:getLocation()  
  
        print("EVENT_TOUCH_BEGAN")  
        return true  
    end, cc.Handler.EVENT_TOUCH_BEGAN )  
      
    -- 实现 onTouchMoved 事件回调函数  
    listenner:registerScriptHandler(function(touch, event)  
        local locationInNodeX = self:convertToNodeSpace(touch:getLocation()).x       
  
        print("EVENT_TOUCH_MOVED")  
    end, cc.Handler.EVENT_TOUCH_MOVED )  
      
    -- 实现 onTouchEnded 事件回调函数  
    listenner:registerScriptHandler(function(touch, event)  
        local locationInNodeX = self:convertToNodeSpace(touch:getLocation()).x  
  
        print("EVENT_TOUCH_ENDED")  
    end, cc.Handler.EVENT_TOUCH_ENDED )
    -- ture 吞并触摸事件,不向下级传递事件;  
    -- fasle 不会吞并触摸事件,会向下级传递事件;  
    -- 设置是否吞没事件，在 onTouchBegan 方法返回 true 时吞没  
    listenner:setSwallowTouches(true)  
     local eventDispatcher = self:getEventDispatcher()  
    -- 添加监听器  
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
end

--创建背景（可能是多个玩家一起翻马所以得单个创建）
function FanMaAnimation:createBg()
    if self.m_bgLayer == nil then
        self.m_bgLayer = {}
    end
    local data = self.m_data
    for i,v in pairs(data) do
        local bgLayer = self:drawBg(i,#data)
        local posY = display.cy - fmBgOffectY
        if #data > 1 then
            posY = display.cy+((#data/2)-(i-1))*fmBgPosYIndex - fmBgDOffectY
            self:drawHeand(i,bgLayer)
        end
        bgLayer:setPositionY(posY)
        table.insert(self.m_bgLayer,bgLayer)
        if i == 1 then
            self:drawFanMaText(bgLayer)
        end
    end
end

--绘制翻马文字
function FanMaAnimation:drawFanMaText(bgLayer)
    local fmt = display.newSprite(titlePath)
    fmt:addTo(bgLayer)
    local bgCS = bgLayer:getContentSize()
    fmt:setPosition(cc.p(bgCS.width/2,bgCS.height+fmt:getContentSize().height/2))
end

--绘制头像
function FanMaAnimation:drawHeand(index,bgLayer)
    local userId = self.m_data[index].userid
    local gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local operateSite   = gamePlaySystem:getPlayerSiteById(userId)
    local playerObj = gamePlaySystem:gameStartGetPlayerBySite(operateSite)
    local imgURL = playerObj:getProp(enCreatureEntityProp.ICON_ID)
    local strNickName = playerObj:getProp(enCreatureEntityProp.NAME)
    local nickName = ToolKit.subUtfStrByCn(strNickName,0,nameSubNum,"")
    local headBg = display.newSprite(headBgPath)
    local headSprite = display.newSprite(headPath)
    local hS,isHead = self:getPlayerHead(headSprite,operateSite)
    if hs then
        headSprite = hS
    end
    local hsCS = headSprite:getContentSize()
    headSprite:setScaleX(headScakeIndex/hsCS.width)
    headSprite:setScaleY(headScakeIndex/hsCS.height)
    headSprite:setContentSize(cc.size(headScakeIndex,headScakeIndex))
    headSprite:addTo(headBg)
    if isHead then
        headSprite:setAnchorPoint(headAnchor)
        headSprite:setPosition(cc.p(headSprite:getPositionX(),headSprite:getPositionY()))
        -- headSprite:setPosition(cc.p(headSprite:getPositionX()+headOffect,headSprite:getPositionY()+headOffect))
    else
        headSprite:setPosition(cc.p(headSprite:getContentSize().width/2,headSprite:getContentSize().height/2))
    end
    hsCS = headBg:getContentSize()
    headBg:addTo(bgLayer)
    headBg:setScale(headBgScale)
    headBg:setPosition(cc.p(hsCS.width/2,bgLayer:getContentSize().height/2 + headBgOffect_Y))
    local headKuang = display.newSprite(playerBoxPath)
    headKuang:addTo(headBg)
    local hkCS = headKuang:getContentSize()
    headKuang:setScale(headKuangScale)
    headKuang:setPosition(cc.p(hsCS.width/2,hsCS.height/2))

    local name = display.newTTFLabel({
                text = nickName,
                font = fontPath,
                size = nameFontSize,
                color = nameFontColor,
                align = cc.TEXT_ALIGNMENT_LEFT,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
            })
    Util.updateNickName(name, ToolKit.subUtfStrByCn(strNickName, 0, nameSubNum, "..."), nameFontSize)
    name:addTo(headBg)
    name:setPosition(cc.p(hsCS.width/2,-headOffect))
end
function FanMaAnimation:getPlayerHead(headSprite,site)
    --头像
    local player = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(site)
    local imgURL = player:getProp(enCreatureEntityProp.ICON_ID)
    Log.i("------ PlayerHead imgURL", imgURL);
    local isHead = false
    if string.len(imgURL) > 3 then
        local imgName = player:getProp(enCreatureEntityProp.USERID).. ".jpg";
        local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(headFile) then
            headSprite:setTexture(headFile);
        else
            self.imgHeads[imgName] = headSprite;
            self:getNetworkImage(imgURL, imgName);
        end
        isHead = true
    else
        local headFile = headPath;
        headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
        if io.exists(headFile) then
            headSprite:setTexture(headFile);
        end
    end
    return headSprite,isHead
end

function FanMaAnimation:getNetworkImage(preUrl, fileName)
    Log.i("FriendOverViewFriendOverView.getNetworkImage", "-------url = " .. preUrl);
    Log.i("FriendOverView.getNetworkImage", "-------fileName = ".. fileName);
    if preUrl == "" or preUrl == nil then
        return
    end
    local onReponseNetworkImage = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkImage code", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        request:saveResponseData(savePath);
        self:onResponseNetImg(fileName);
    end
    local url = preUrl;
    --
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end

function FanMaAnimation:onResponseNetImg(imgName)
    local imgHead = self.imgHeads[imgName];
    if imgHead then
        imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(imgName) then
            imgHead:setTexture(imgName);
            imgHead:setScale(imgHeadScaleIndex / imgHead:getContentSize().width)
            --imgHead:setScale(100/self.imgHeads[i]:getContentSize().width ,100/self.imgHeads[i]:getContentSize().height);
        end
    end
end
function FanMaAnimation:drawFanMaTitle(bgLayer)
    local text = display.newSprite("")
end 

--绘制背景
function FanMaAnimation:drawBg(index,rsNum)
    local height = bgHeight
    if rsNum > 1 then
        height = bgDheight
    end
    local bgLayer = display.newColorLayer(bgColor)
    bgLayer:setContentSize(cc.size(display.width,height))
    bgLayer:addTo(self)
    local mjs = self.m_data[index].fanma or mjsIndex
    local zhongma = self.m_data[index].zhongma or {}
    
    if #mjs > 0 and not self.m_quanma then
        self:drawFanMaMj(bgLayer,mjs,zhongma,rsNum)
    elseif self.m_quanma then
        local quanma = display.newSprite(quanmaTextPath)
        quanma:addTo(bgLayer)
        local blCS = bgLayer:getContentSize()
        quanma:setPosition(cc.p(blCS.width/2,blCS.height/2))
        local df = cc.DelayTime:create(1)
        local cf = cc.CallFunc:create(function()
            self:removeFromParent() 
--            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF)
        end)
        quanma:runAction(cc.Sequence:create(df,cf))
    end
    if not mjs and #mjs <=0 and not self.m_quanma then
        self:removeFromParent() 
    end
    return bgLayer
end


--绘制翻马麻将牌动画
function FanMaAnimation:drawFanMaMj(bgLayer,mjs,zhongma,rsNum)
    for i,v in pairs(mjs) do
        local isSelect = false
        if #zhongma > 0 then
            for j,k in pairs(zhongma) do
                if v == k then
                    isSelect = true
                    break
                end
            end
        end
        local sprite = self:drawActionMjSprite(bgLayer,v,isSelect,i)
        local posX = 0
        local posY = 0
        if rsNum <= 1 then
            if #mjs <= mjScaleMax then
                posX = display.cx+((#mjs/2) - (i-1/2))*(sprite:getContentSize().width+mjClearance)
            else
                --因为8个之内不用缩放所以区分出两种
                local scale = 1-(#mjs)*mjScaleRatio
                local offect_x = 0
                if #mjs > mjScaleMax_1 then
--                    scale = 1-(#mjs)*0.028
                    scale = (display.width/#mjs)/(sprite:getContentSize().width+mjOffect_X)
                else
                    scale = 1-(#mjs-mjScaleMax)*mjScaleRatio_1
                end
                sprite:setScale(scale)
                local width = display.cx + ((#mjs+1)/2)*(sprite:getContentSize().width+mjOffect_X)*scale
                posX = width - i*(sprite:getContentSize().width+5)*scale
            end
        else
            local scale = mjDScale
            sprite:setScale(scale)
            if #mjs < mjDScaleMax then
                posX = display.cx+((#mjs/2) - (i-1/2))*(sprite:getContentSize().width+mjClearance)*scale
            else
                scale = ((display.width-mjDHeanOffectScale_x)/#mjs)/(sprite:getContentSize().width+mjOffect_X)
                local width = display.cx + ((#mjs+1)/2)*(sprite:getContentSize().width+mjOffect_X)*scale
                posX = mjDHeanOffect_x+width - i*(sprite:getContentSize().width+5)*scale
--                if #mjs >= 20 then
--                    posX = posX + 30
--                end
            end
            sprite:setScale(scale)
        end
        posY = bgLayer:getContentSize().height/2
        sprite:setPosition(cc.p(posX,posY))
    end
    local df = cc.DelayTime:create(mjDMoveTime+#mjs*mjDMoveIndex)
    local cf = cc.CallFunc:create(function()
        self:removeFromParent() 
--        MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF)
    end)
    bgLayer:runAction(cc.Sequence:create(df,cf))
end

--绘制翻马动画
function FanMaAnimation:drawActionMjSprite(bgLayer,mj,isSelect,index)
    if index == nil then
        index = 0
    end
    local sprite = display.newSprite("#startFrame.png")
    local mjValue = mj
    bgLayer:addChild(sprite,bgLocal)
    local frames    = display.newFrames("fanma%d.png",1,mjBgFrame)
    local animation = display.newAnimation(frames,mjBgAnimation)
    local animate = cc.Animate:create(animation)
    local function mjSptite(node,mj)
        self:drawMjSprite(mj.node,mj.value,mj.isSelect)
    end
    local sequence = transition.sequence({
                cc.DelayTime:create(index/mjBgTimeIndex),
                animate,
                cc.CallFunc:create(mjSptite,{node = sprite,value = mjValue,isSelect = isSelect})
            })
    sprite:runAction(sequence)
    return sprite
end

--绘制麻将牌
function FanMaAnimation:drawMjSprite(sprite,mj,isSelect)
    Log.i("mj....................",mj)
    local pai = getCardPngByValue(mj)
    local mjSprite = display.newSprite("#"..pai)
    sprite:addChild(mjSprite)
    mjSprite:setScale(mjScale)
    local spriteCS = sprite:getContentSize()
    mjSprite:setPosition(cc.p(spriteCS.width/2 + mjOffsetX,spriteCS.height - mjSprite:getContentSize().height/2 - mjOffsetY))
    if isSelect then
        self:drawEffectAnimation(mjSprite)
    else
        sprite:setColor(mjColor)
    end
    
end

--绘制特效动画
function FanMaAnimation:drawEffectAnimation(sprite)
    local effect = display.newSprite("#fanmalight1.png")
    local sCS = sprite:getContentSize()
    local eCs = effect:getContentSize()
    effect:setPosition(cc.p(sCS.width,sCS.height))
    sprite:addChild(effect)
    local frames = display.newFrames("fanmalight%d.png",1,lightFrameNum)
    local animation = display.newAnimation(frames,lightFrameTime)
    local animate = cc.Animate:create(animation)
    local spawn = cc.Spawn:create(animate,cc.MoveBy:create(lightFrameAnimationTime,cc.p(-sCS.width,0)))
   
    local sequence = cc.Sequence:create(spawn,cc.CallFunc:create(function(node) node:removeFromParent() end))
    effect:runAction(sequence)
--    effect:runAction(cc.MoveBy:create(cc.p(-sCS.width,0))
end
return FanMaAnimation
--endregion
