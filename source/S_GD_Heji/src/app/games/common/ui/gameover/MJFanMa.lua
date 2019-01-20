
local kTimeBeilv = 0.5 -- 整体时间倍率

local kComposeType = {
    NONE = 0, -- 不合并
    PAI_NUM = 1, -- 翻的牌大于一定数量后合并(所有玩家的最大牌数)
    MA_NUM = 2, -- 翻出的马大于一定数量后合并(所有玩家的最大牌数)
}

local MJFanMa = class("MJFanMa", function ()
     return display.newLayer()
end);

-- 构造函数
--[[
config = {
    -- titlePng = "games/".._gameType.."/game/fanmaTitle.png", -- 标题图片
    -- titleScale = 2.0, -- 标题缩放大小
    -- titleOff = cc.p(0, -20), -- 标题偏移
    -- hideHead = false, -- 是否隐藏头像
    -- composeType = 2, -- 0 不合并, 1 翻的牌大于一定数量后合并(所有玩家的最大牌数), 2 翻出的马大于一定数量后合并(所有玩家的最大牌数)
    -- composeMinNum = 5, -- 合并麻将的起始值, 比如设定为大于等于10张后合并
    -- isTouchClose = true, -- 点击后关闭
}
]]
function MJFanMa:ctor(data, config)
    self.m_data = data -- clone(data.score)
    self.m_config = config or {}
    self:onInit()
end

-- 创建头像层
function MJFanMa:createHeadPanel(lPlayerIndex)
    local lGameSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local lPlayersInfo = lGameSystem:gameStartGetPlayers()
    -- local lPlayerIndex = lGameSystem:getPlayerSiteById(playerID)
    local lScoreItems = lGameSystem:getGameOverDatas().score

    --  头像节点
    local lHeadNode = cc.Node:create()

    --  头像
    local lHeadIMG = cc.Sprite:create()
    lHeadNode:addChild(lHeadIMG)

    --  获取头像文件
    local lUserID = lPlayersInfo[lPlayerIndex]:getProp(enCreatureEntityProp.USERID)
    local lImgURL = lGameSystem:gameStartGetPlayerByUserid(lUserID):getProp(enCreatureEntityProp.ICON_ID) .. "";
    if string.len(lImgURL) > 3 then
        local lImgName = lGameSystem:gameStartGetPlayerByUserid(lUserID):getProp(enCreatureEntityProp.USERID) .. ".jpg";
        local lHeadFile = cc.FileUtils:getInstance():fullPathForFilename(lImgName);
        if io.exists(lHeadFile) then
            lHeadIMG:setTexture(lHeadFile)
            -- lHeadIMG:setScale(0.6)
            lHeadIMG:setScale(70 / lHeadIMG:getContentSize().width)
        end
    else
        local lImgName = "real_res/1004043.png"
        local lHeadFile = cc.FileUtils:getInstance():fullPathForFilename(lImgName)
        if io.exists(lHeadFile) then
            lHeadIMG:setTexture(lHeadFile)
            -- lHeadIMG:setScale(0.6)
            lHeadIMG:setScale(70 / lHeadIMG:getContentSize().width)
        end
    end


    --  头像框
    local lHeadBG = cc.Sprite:create("real_res/1004123.png")
    lHeadNode:addChild(lHeadBG)
    local lHeadBGSize = lHeadBG:getContentSize()

    --  庄家图标
    local lBankerIcon = cc.Sprite:create("real_res/1004177.png")
    lHeadBG:addChild(lBankerIcon)
    lBankerIcon:setPosition(cc.p(0, lHeadBGSize.height))

    local lBanker = lPlayersInfo[lPlayerIndex]:getProp(enCreatureEntityProp.BANKER)
    if lBanker then
        lBankerIcon:setVisible(true)
    else
        lBankerIcon:setVisible(false)
    end

    --  昵称
    local lNameLab = ccui.Text:create()
    lHeadBG:addChild(lNameLab)
    lNameLab:setFontName("res_TTF/1016001.TTF")
    lNameLab:setColor(cc.c3b(252, 234, 67))
    lNameLab:setAnchorPoint(cc.p(0, 1))
    lNameLab:setPosition(cc.p(0, lHeadBGSize.height * 0.05))
    lNameLab:setFontSize(22)

    local lStrName = ""
    lStrName = ToolKit.subUtfStrByCn(lScoreItems[lPlayerIndex].nick, 0, 5, "")
    lNameLab:setString(lStrName)
    Util.updateNickName(lNameLab, lStrName)

    return lHeadNode
end

-- 获取玩家最大牌数和总行数
function MJFanMa:getMaxCount(data)
    local maxCount=1
    local totalRow=0
    for k,v in pairs(data) do

        local row=math.ceil(#v/self.m_num)
        totalRow=totalRow+row

        if #v>maxCount then
            maxCount=#v
        end
    end
    return maxCount,totalRow
end

-- 获取总牌数
function MJFanMa:getTotalCount(data)
    local total=0
    for k,v in pairs(data) do
        total=total+#v
    end
    return total
end

-- 获取玩家最大中马数
function MJFanMa:getMaxMaCount(data)
    local maxCount=0
    for k, v in pairs(data) do
        local count = 0
        for _, fanpai in ipairs(v) do
            if fanpai.isM == 1 then
                count = count + 1
            end
        end
        maxCount = maxCount < count and count or maxCount
    end
    return maxCount
end

-- 创建翻马层
function MJFanMa:createFamaPanel(fanmaList)

    self.m_num=12+math.floor(self:getTotalCount(self.m_data)/20)

    local layer=cc.Layer:create()--cc.LayerColor:create(cc.c4b(math.random(1,255),math.random(1,255),math.random(1,255),255))

    --牌的初始化大小
    local mjWidth=127
    local mjHeight=185
    local scale=0.8

    local count,totalRow=self:getMaxCount(self.m_data)--#fanmaList
    -- 翻的牌大于一定数量后合并(所有玩家的最大牌数)
    if self.m_config.composeType == kComposeType.PAI_NUM then
        if self.m_config.composeMinNum then -- 判断是否需要合并翻马
            self.m_composeFanma = count >= self.m_config.composeMinNum
        else -- 没有配置composeMinNum时, 允许合并
            self.m_composeFanma = true
        end
    end
    -- 翻出的马大于一定数量后合并(所有玩家的最大牌数)
    if self.m_config.composeType == kComposeType.MA_NUM then
        local maxMaCount = self:getMaxMaCount(self.m_data)
        if self.m_config.composeMinNum then -- 判断是否需要合并翻马
            self.m_composeFanma = maxMaCount >= self.m_config.composeMinNum
        else -- 没有配置composeMinNum时, 允许合并
            self.m_composeFanma = true
        end
    end

    local row=math.ceil(#fanmaList/self.m_num)
    local col=count <self.m_num and count or self.m_num

    --麻将最大内容区域
    local padding=10
    local maxWidth=display.width*0.88-(col-1)*padding-padding*2
    local maxHeight=row/totalRow*(display.height*0.58)

    if mjWidth*col>maxWidth then
        scale=(maxWidth-(col-1)*padding)/(mjWidth*col)
        -- print("333333")
    end

    if mjHeight*row>maxHeight then
        scale=maxHeight/(mjHeight*row)--(maxHeight-(row-1)*padding-padding*2)/(mjHeight*row)
        -- print("44444")
    end

    if mjWidth*col>maxWidth and mjHeight*row>maxHeight then
        local scaleX=(maxWidth-(col-1)*padding)/(mjWidth*col)
        local scaleY=maxHeight/(mjHeight*row)--(maxHeight-(row-1)*padding-padding*2)/(mjHeight*row)
        scale = scaleX>scaleY and scaleY or scaleX
        -- print("55555".." x:"..scaleX.."y:"..scaleY)
    end

    scale=scale>0.8 and 0.8 or scale

    -- print("scale:"..scale.." maxHeight:"..maxHeight)
    
    mjWidth=mjWidth*scale
    mjHeight=mjHeight*scale
    layer:setContentSize(display.width,row*mjHeight+(row-1)*padding+padding*2)

    local famas={}
    for i=1,row do
        for j=1,col do
            local index=(i-1)*col+j
            local maData=fanmaList[index]
            if maData then

                local fama = display.newSprite("#fanma1.png")
                layer:addChild(fama)
                fama:setScale(scale)
                fama:setPosition((display.width-((col-1)*padding+col*mjWidth))/2+mjWidth/2+(j-1)*(mjWidth+padding), (row-i)*(mjHeight+padding)+mjHeight/2+padding)

                self:famaAnimation(fama,maData)

                if not famas[maData.faI6] then famas[maData.faI6]={} end
                table.insert(famas[maData.faI6],fama)
            end

        end

    end
    return layer,famas
end

-- 初始化
function MJFanMa:onInit()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res_plist/1008025.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res_plist/1008006.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res_plist/1008008.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res_plist/1008007.plist")

    local title=display.newSprite(self.m_config.titlePng or "real_res/1004090.png")
    -- 设置标题缩放
    if self.m_config.titleScale then
        title:setScale(self.m_config.titleScale)
    end
    title:addTo(self,1)
    local titlePos = cc.p(display.width/2, display.height-title:getContentSize().height/2-10)
    if self.m_config.titleOff then
        titlePos = cc.p(titlePos.x + self.m_config.titleOff.x, titlePos.y + self.m_config.titleOff.y)
    end
    title:setPosition(titlePos)
    -- self.gameSystem     = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    -- local players  = self.gameSystem:gameStartGetPlayers()

    local playerCount=#self.m_data--#players

    local height = 0
    local panels={}

    self.m_panels={}
    for i = 1, playerCount do
        
        local fanmaList = self.m_data[i];
        if #fanmaList>0 then

            -- local datas=self:compose(fanmaList)
            local famaPanel,famas=self:createFamaPanel(fanmaList)
            self:addChild(famaPanel)
            height=height+famaPanel:getContentSize().height

            self.m_panels[i]={panel=famaPanel,famas=famas}
            table.insert(panels,famaPanel)

            famaPanel:performWithDelay(function()
                self:composeAnimation(i)
            end, 3 * kTimeBeilv)
            
            -- dump(famas)

            -- local userId = self.m_data[i].usID
            if not self.m_config.hideHead then -- 默认显示头像
                local head=self:createHeadPanel(i)
                famaPanel:addChild(head)
                head:setPosition(80, famaPanel:getContentSize().height/2)
            end
        end


        

    end

    local y=(display.height-height)/2
    for k,v in pairs(panels) do
        v:setPositionY(y)
        y=y+v:getContentSize().height
    end
    
    local bgLayer=cc.LayerColor:create(cc.c4b(0,0,0,200))
    self:addChild(bgLayer,-1)
    bgLayer:setContentSize(display.width,display.height*0.7)
    bgLayer:setPositionY((display.height-bgLayer:getContentSize().height)/2)


    -- if  then
    self:initListener()
    -- end
end

-- 翻马动画
function MJFanMa:famaAnimation(fama,data)
    local frames    = display.newFrames("fanma%d.png",1,5)
    -- local fama      = display.newSprite(frames[1])
    local animation = display.newAnimation(frames,0.04 * kTimeBeilv)
    local arr={
        cc.DelayTime:create(0.5 * kTimeBeilv),
        cc.Animate:create(animation),
        cc.CallFunc:create(function()
            local lCardTexture = getCardPngByValue(data.faI6)
            if not lCardTexture then print(data.faI6) end
            local lWrod = cc.Sprite:createWithSpriteFrameName(lCardTexture)
            lWrod:setPosition(cc.p(fama:getContentSize().width/2,fama:getContentSize().height/2+20))
            fama:addChild(lWrod)
        end),
        cc.DelayTime:create(0.25 * kTimeBeilv),
    }

    if data.isM==1 then
        table.insert(arr,cc.CallFunc:create(function()
            local lFrames = display.newFrames("fanmalight%d.png", 1, 14)
            local lLight = display.newSprite(lFrames[1])
            local lAniLight = display.newAnimation(lFrames, 1 / 14 * kTimeBeilv)
            transition.playAnimationOnce(lLight, lAniLight, true)
            fama:addChild(lLight)
            lLight:setScale(3)
            lLight:setPosition(cc.p(fama:getContentSize().width/2,fama:getContentSize().height/2+20))
        end))
    else
        table.insert(arr,cc.DelayTime:create(1 * kTimeBeilv))
        table.insert(arr,cc.CallFunc:create(function()
            fama:setColor(cc.c3b(120,120,120))
        end))
        -- table.insert(arr,cc.DelayTime:create(1))
        -- table.insert(arr,cc.RemoveSelf())
    end

    fama:runAction(cc.Sequence:create(arr))
end

-- 创建翻马组
function MJFanMa:createComposeFamas(datas,layer)
    local num=12+math.floor(self:getTotalCount({datas})/20)

    -- local layer=cc.Layer:create()

    --牌的初始化大小
    local mjWidth=127
    local mjHeight=185
    local scale=0.8

    local count,totalRow=self:getMaxCount({datas})--#fanmaList
    local row=math.ceil(#datas/num)
    local col=count <num and count or num

    --麻将最大内容区域
    local padding=10
    local maxWidth=display.width*0.88-(col-1)*padding-padding*2
    local maxHeight=layer:getContentSize().height-(row-1)*padding-padding*2 --row/totalRow*(display.height*0.58)

    -- print(layer:getContentSize().height.." "..maxHeight)

    if mjWidth*col>maxWidth then
        scale=(maxWidth-(col-1)*padding)/(mjWidth*col)
    end

    if mjHeight*row>maxHeight then
        scale=maxHeight/(mjHeight*row)
    end

    if mjWidth*col>maxWidth and mjHeight*row>maxHeight then
        local scaleX=(maxWidth-(col-1)*padding)/(mjWidth*col)
        local scaleY=maxHeight/(mjHeight*row)--(maxHeight-(row-1)*padding-padding*2)/(mjHeight*row)
        scale = scaleX>scaleY and scaleY or scaleX
    end

    scale=scale>0.8 and 0.8 or scale

    mjWidth=mjWidth*scale
    mjHeight=mjHeight*scale

    local y=(maxHeight-row*mjHeight)/2 ---(row-1)*padding-padding*2

    local famas={}
    for i=1,row do
        for j=1,col do
            local index=(i-1)*col+j
            local maData=datas[index]
            if maData then

                local fama = display.newSprite("#fanma5.png")
                layer:addChild(fama)
                fama:setScale(scale)
                fama:setPosition((display.width-((col-1)*padding+col*mjWidth))/2+mjWidth/2+(j-1)*(mjWidth+padding), (row-i)*(mjHeight+padding)+mjHeight/2+padding+y)

                local lCardTexture = getCardPngByValue(maData.faI6)
                local lWrod = cc.Sprite:createWithSpriteFrameName(lCardTexture)
                lWrod:setPosition(cc.p(fama:getContentSize().width/2,fama:getContentSize().height/2+20))
                fama:addChild(lWrod)

                -- self:famaAnimation(fama,maData)

                if not famas[maData.faI6] then famas[maData.faI6]={} end
                table.insert(famas[maData.faI6],fama)
            end

        end

    end
    return famas
end

-- 翻马的组合动画
function MJFanMa:composeAnimation(index)
    local datas,disDatas=self:compose(index)
    if #datas>0 then
        -- dump(self.m_panels[index])
        local famas=self:createComposeFamas(datas,self.m_panels[index].panel)

        for k,v in pairs(self.m_panels[index].famas) do
                -- dump(v)
                -- local num=0
                for j,fama in pairs(v) do
                    local arr={
                    }
                    if famas[k] and fama:getColor().r~=120 then --根据颜色判断是否是中的马
                        local totalFama=famas[k][j]

                        if self.m_composeFanma then -- 显示合并的麻将
                            totalFama=famas[k][1]
                            local famaNum=display.newSprite("games/common/game/fanma/maCount"..(#v>4 and 4 or #v)..".png")
                            totalFama:addChild(famaNum)
                            famaNum:setPosition(103, 161)
                        end

                        totalFama:setVisible(false)
                        table.insert(arr,cc.DelayTime:create(1 * kTimeBeilv))
                        table.insert(arr,cc.Spawn:create(cc.MoveTo:create(0.5 * kTimeBeilv,cc.p(totalFama:getPosition())),cc.ScaleTo:create(0.5 * kTimeBeilv,totalFama:getScale())))
                        table.insert(arr,cc.CallFunc:create(function ()
                            totalFama:setVisible(true)
                            -- num=num+1
                            -- num=num<4 and num+1 or 4
                            -- print(num.." k:"..k)
                            -- famaNum:setTexture("games/common/game/fanma/maCount"..num..".png")
                        end))
                    else
                        
                        table.insert(arr,cc.CallFunc:create(function ()
                            local frames    = display.newFrames("explode%d.png",1,12)
                            local explode      = display.newSprite(frames[1])
                            local animation = display.newAnimation(frames,0.04 * kTimeBeilv)
                            explode:runAction(cc.Sequence:create(cc.Animate:create(animation),cc.RemoveSelf:create()))
                            fama:getParent():addChild(explode)
                            explode:setPosition(cc.p(fama:getPosition()))
                        end))
                    end
                    table.insert(arr,cc.RemoveSelf:create())
                    if #arr>0 then
                        fama:runAction(cc.Sequence:create(arr))
                    end
                end
        end
    end
end

-- 统计相同中马麻将数量
function MJFanMa:compose(index)
    local keys={}
    local datas={}
    local disDatas={}

    -- dump(self.m_data[index])

    -- for _,score in pairs(self.m_data[index]) do
        -- dump(score)
        for k,v in pairs(self.m_data[index]) do
            if v.isM==1 then
                if self.m_composeFanma then
                    if keys[v.faI6] then
                        -- v.count=v.count+1
                        local data=self:getFamaData(datas,v.faI6)
                        ---- dump(data)
                        data.count=data.count+1
                    else
                        keys[v.faI6]=true
                        v.count=1
                        table.insert(datas,v)
                    end
                else
                    v.count=1
                    table.insert(datas,v)
                end
            else
                table.insert(disDatas,v)
            end
        end

    -- end
    return datas,disDatas
end


function MJFanMa:getFamaData(datas,value)
    for k,v in pairs(datas) do
        if v.faI6==value then
            return v
        end
    end
end


--  初始化监听事件
function MJFanMa:initListener()
    --  注册单点触摸事件
    local function onTouchBegan(touch, event)
        -- Log.i("onTouchBegan")
        return true
    end
    local function onTouchMoved(touch, event)
        -- Log.i("onTouchMoved")
    end
    local function onTouchEnded(touch, event)
        -- Log.i("onTouchEnded")
        if self.m_config.isTouchClose then
            self:removeFromParent()
        end
    end

    self.m_Listener = cc.EventListenerTouchOneByOne:create()
    self.m_Listener:setSwallowTouches(true)
    self.m_Listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    self.m_Listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    self.m_Listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_Listener, self)
end


return MJFanMa
