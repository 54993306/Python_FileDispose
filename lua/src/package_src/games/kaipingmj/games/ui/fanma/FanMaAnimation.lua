--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local FanMaAnimation = class("FanMaAnimation",function()
    local layer = display.newColorLayer(cc.c4b(0,0,0,150))
    layer:setContentSize(cc.size(display.width,display.height))
    return layer
end)

function FanMaAnimation:ctor(data)
    self.m_data = data
    self.imgHeads = {}
    self:adListenner()
    self:addCache()
    self:createBg()
end
function FanMaAnimation:addCache()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/kaipingmj/fanma/fangma.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/kaipingmj/fanma/fanmalight.plist")
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
        local posY = display.cy - 100
        if #data > 1 then
            posY = display.cy+((#data/2)-(i-1))*130
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
    local fmt = display.newSprite("package_res/games/kaipingmj/fanma/fanma_text.png")
    fmt:addTo(bgLayer)
    local bgCS = bgLayer:getContentSize()
    fmt:setPosition(cc.p(bgCS.width/2,bgCS.height+fmt:getContentSize().height/2))
end
--绘制头像
function FanMaAnimation:drawHeand(index,bgLayer)
    local userId = self.m_data[index]
    local gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local operateSite   = gamePlaySystem:getPlayerSiteById(userId)
    local playerObj = gamePlaySystem:gameStartGetPlayerBySite(operateSite)
    local imgURL = playerObj:getProp(enCreatureEntityProp.ICON_ID)
    local strNickName = playerObj:getProp(enCreatureEntityProp.NAME)
    local nickName = ToolKit.subUtfStrByCn(strNickName,0,5,"")
    local headBg = display.newSprite("hall/Common/default_head_2.png")
    local headSprite = display.newSprite("hall/Common/default_head_2.png")
    local hS= self:getPlayerHead(headSprite,operateSite)
    if hS then
        headSprite = hS
    end
    local hsCS = headSprite:getContentSize()
    headSprite:setScaleX(150/hsCS.width)
    headSprite:setScaleY(150/hsCS.height)
    headSprite:setContentSize(cc.size(150,150))
    headSprite:addTo(headBg)
    headSprite:setPosition(cc.p(headSprite:getPositionX()+20,headSprite:getPositionY()+20))
    hsCS = headBg:getContentSize()
    headBg:addTo(bgLayer)
    headBg:setScale(0.5)
    headBg:setPosition(cc.p(hsCS.width/2,bgLayer:getContentSize().height/2 + 10))
    local headKuang = display.newSprite("games/common/mj/games/game_player_box.png")
    headKuang:addTo(headBg)
    local hkCS = headKuang:getContentSize()
    headKuang:setScale(1.6)
    headKuang:setPosition(cc.p(hsCS.width/2,hsCS.height/2))

    local name = display.newTTFLabel({
                text = nickName,
                font = "hall/font/fangzhengcuyuan.TTF",
                size = 40,
                color = cc.c3b(255, 255, 255),
                align = cc.TEXT_ALIGNMENT_LEFT,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
            })
    name:addTo(headBg)
    name:setPosition(cc.p(hsCS.width/2,-20))
end
function FanMaAnimation:getPlayerHead(headSprite,site)
    --头像
    local player = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(site)
    local imgURL = player:getProp(enCreatureEntityProp.ICON_ID)
    Log.i("------ PlayerHead imgURL", imgURL);
    if string.len(imgURL) > 3 then
        local imgName = player:getProp(enCreatureEntityProp.USERID).. ".jpg";
        local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(headFile) then
            headSprite:setTexture(headFile);
        else
            self.imgHeads[imgName] = headSprite;
            self:getNetworkImage(imgURL, imgName);
        end
    else
        local headFile = "hall/Common/default_head_2.png";
        headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
        if io.exists(headFile) then
            headSprite:setTexture(headFile);
        end
    end
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
    if not imgName then return end
    local imgHead = self.imgHeads[imgName];
    if tolua.isnull(imgHead) then return end
    if imgHead then
        imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(imgName) then
            imgHead:setTexture(imgName);
            imgHead:setScale(70 / imgHead:getContentSize().width)
            --imgHead:setScale(100/self.imgHeads[i]:getContentSize().width ,100/self.imgHeads[i]:getContentSize().height);
        end
    end
end
function FanMaAnimation:drawFanMaTitle(bgLayer)
    local text = display.newSprite("")
end 
--绘制背景
function FanMaAnimation:drawBg(index,rsNum)
    local height = 200
    if rsNum > 1 then
        height = 100
    end
    local bgLayer = display.newColorLayer(cc.c4b(0,0,0,150))
    bgLayer:setContentSize(cc.size(display.width,height))
    bgLayer:addTo(self)
    local mjs = self.m_data[index].fanma
    local zhongma = self.m_data[index].zhongma or {}
    if #mjs > 0  then
        self:drawFanMaMj(bgLayer,mjs,zhongma,rsNum)
    end
    
    return bgLayer
end
--绘制翻马麻将牌动画
function FanMaAnimation:drawFanMaMj(bgLayer,mjs,zhongma,rsNum)
    -- for i,v in pairs(mjs) do
    --     local isSelect = false
    --     if #zhongma > 0 then
    --         for j,k in pairs(zhongma) do
    --             if v == k then
    --                 isSelect = true
    --                 break
    --             end
    --         end
    --     end
    --     local sprite = self:drawActionMjSprite(bgLayer,v,isSelect,i)
    --     local posX = 0
    --     local posY = 0
    --     if rsNum <= 1 then
    --         if #mjs < 8 then
    --             posX = display.cx+((#mjs/2) - (i-1/2))*(sprite:getContentSize().width+10)
                
    --         else
    --             --因为8个之内不用缩放所以区分出两种
    --             local scale = 1-(#mjs)*0.03
    --             if #mjs > 12 then
    --                 scale = 1-(#mjs)*0.03
    --             else
    --                 scale = 1-(#mjs-8)*0.08
    --             end
    --             sprite:setScale(scale)
    --             posX = display.cx+(4)*(sprite:getContentSize().width+15) - (i-1)*(sprite:getContentSize().width+10)*scale
    --         end
    --     else
    --         local scale = 0.5
    --         sprite:setScale(scale)
    --         if #mjs < 16 then
    --             posX = display.cx+((#mjs/2) - (i-1/2))*(sprite:getContentSize().width+10)*scale
    --         else
    --             scale = 0.5-(#mjs-16)*0.02
    --             posX = display.cx+(4)*(sprite:getContentSize().width+15) - (i-1)*(sprite:getContentSize().width+10)*scale
    --         end
    --         sprite:setScale(scale)
    --     end
    --     posY = bgLayer:getContentSize().height/2
    --     sprite:setPosition(cc.p(posX,posY))
    -- end
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
            if #mjs <= 8 then
                posX = display.cx+((#mjs/2) - (i-1/2))*(sprite:getContentSize().width+10)
                
            else
                --因为8个之内不用缩放所以区分出两种
                local scale = 1-(#mjs)*0.03
                if #mjs > 12 then
                    scale = 1-(#mjs)*0.03
                else
                    scale = 1-(#mjs-8)*0.08
                end
                sprite:setScale(scale)
                posX = display.cx+(4)*(sprite:getContentSize().width+15) - (i-1)*(sprite:getContentSize().width+10)*scale
            end
        else
            local scale = 0.5
            sprite:setScale(scale)
            if #mjs < 16 then
                posX = display.cx+((#mjs/2) - (i-1/2))*(sprite:getContentSize().width+10)*scale
            else
                scale = 0.5-(#mjs-16)*0.02
                posX = display.cx+(4)*(sprite:getContentSize().width+15) - (i-1)*(sprite:getContentSize().width+10)*scale
            end
            sprite:setScale(scale)
        end
        posY = bgLayer:getContentSize().height/2
        sprite:setPosition(cc.p(posX,posY))
    end
   
end
--绘制翻马动画
function FanMaAnimation:drawActionMjSprite(bgLayer,mj,isSelect,index)
    if index == nil then
        index = 0
    end
    local sprite = display.newSprite("#startFrame.png")
    Log.i("mj---------------",mj)
    local mjValue = mj
    bgLayer:addChild(sprite,10)
    local frames    = display.newFrames("fanma%d.png",1,5)
    local animation = display.newAnimation(frames,0.08)
    local animate = cc.Animate:create(animation)
    local function mjSptite(node,mj)
        self:drawMjSprite(mj.node,mj.value,mj.isSelect)
    end
    local sequence = transition.sequence({
                cc.DelayTime:create(index/5),
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
    mjSprite:setScale(1.4)
    local spriteCS = sprite:getContentSize()
    mjSprite:setPosition(cc.p(spriteCS.width/2 + 3,spriteCS.height - mjSprite:getContentSize().height/2 - 20))
    if isSelect then
        self:drawEffectAnimation(mjSprite)
    else
        sprite:setColor(cc.c3b(128, 128, 128))
    end
    
end
--绘制特效动画
function FanMaAnimation:drawEffectAnimation(sprite)
    local effect = display.newSprite("#fanmalight1.png")
    local sCS = sprite:getContentSize()
    local eCs = effect:getContentSize()
    effect:setPosition(cc.p(sCS.width,sCS.height))
    sprite:addChild(effect)
    local frames = display.newFrames("fanmalight%d.png",1,14)
    local animation = display.newAnimation(frames,0.05)
    local animate = cc.Animate:create(animation)
    local spawn = cc.Spawn:create(animate,cc.MoveBy:create(0.6,cc.p(-sCS.width,0)))
   
    local sequence = cc.Sequence:create(spawn,cc.CallFunc:create(function(node) node:removeFromParent() end))
    effect:runAction(sequence)
--    effect:runAction(cc.MoveBy:create(cc.p(-sCS.width,0))
end
return FanMaAnimation
--endregion
