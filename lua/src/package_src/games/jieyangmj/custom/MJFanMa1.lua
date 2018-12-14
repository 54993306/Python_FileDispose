--打牌结束的翻马页面
local MJFanMa = class("MJFanMa1", function ()
	 return display.newLayer()
end);

function MJFanMa:ctor(data,isTouch)
    self.m_data = data
    self.m_isTouchClose=  isTouch
    self:onInit()

end


-- function MJFanMa:createHeadPanel(playerID)
--     local lGameSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
--     local lPlayersInfo = lGameSystem:gameStartGetPlayers()
--     local lPlayerIndex = lGameSystem:getPlayerSiteById(playerID)
--     local lScoreItems = lGameSystem:getGameOverDatas().score

--     --  头像节点
--     local lHeadNode = cc.Node:create()

--     --  头像
--     local lHeadIMG = cc.Sprite:create()
--     lHeadNode:addChild(lHeadIMG)

--     --  获取头像文件
--     local lUserID = lPlayersInfo[lPlayerIndex]:getProp(enCreatureEntityProp.USERID)
--     local lImgURL = lGameSystem:gameStartGetPlayerByUserid(lUserID):getProp(enCreatureEntityProp.ICON_ID) .. "";
--     if string.len(lImgURL) > 3 then
--         local lImgName = lGameSystem:gameStartGetPlayerByUserid(lUserID):getProp(enCreatureEntityProp.USERID) .. ".jpg";
--         local lHeadFile = cc.FileUtils:getInstance():fullPathForFilename(lImgName);
--         if io.exists(lHeadFile) then
--             lHeadIMG:setTexture(lHeadFile)
--             lHeadIMG:setScale(0.14)
--         end
--     else
--         local lImgName = "hall/Common/default_head_2.png"
--         local lHeadFile = cc.FileUtils:getInstance():fullPathForFilename(lImgName)
--         if io.exists(lHeadFile) then
--             lHeadIMG:setTexture(lHeadFile)
--             lHeadIMG:setScale(0.6)
--         end
--     end


--     --  头像框
--     local lHeadBG = cc.Sprite:create("games/common/game/friendRoom/mjOver/bg_head.png")
--     lHeadNode:addChild(lHeadBG)
--     local lHeadBGSize = lHeadBG:getContentSize()

--     --  庄家图标
--     local lBankerIcon = cc.Sprite:create("games/common/game/friendRoom/mjOver/zhuang.png")
--     lHeadBG:addChild(lBankerIcon)
--     lBankerIcon:setPosition(cc.p(0, lHeadBGSize.height))

--     local lBanker = lPlayersInfo[lPlayerIndex]:getProp(enCreatureEntityProp.BANKER)
--     if lBanker then
--         lBankerIcon:setVisible(true)
--     else
--         lBankerIcon:setVisible(false)
--     end

--     --  昵称
--     local lNameLab = cc.Label:create()
--     lHeadBG:addChild(lNameLab)
--     lNameLab:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
--     lNameLab:setColor(cc.c3b(252, 234, 67))
--     lNameLab:setAnchorPoint(cc.p(0, 1))
--     lNameLab:setPosition(cc.p(0, lHeadBGSize.height * 0.05))
--     lNameLab:setSystemFontSize(30)

--     local lStrName = ""
--     lStrName = ToolKit.subUtfStrByCn(lScoreItems[lPlayerIndex].nick, 0, 5, "")
--     lNameLab:setString(lStrName)
--     Util.updateNickName(lNameLab, lStrName)

--     return lHeadNode
-- end

function MJFanMa:getMaxCount()
	local maxCount=1
	local totalRow=0
	local row=math.ceil(#self.m_data.fanma/self.m_num)
	totalRow=totalRow+row

	if #self.m_data.fanma > maxCount then
		maxCount=#self.m_data.fanma
	end
	return maxCount,totalRow
end

function MJFanMa:getTotalCount(Mtotal)
	return Mtotal
end

function MJFanMa:createFamaPanel(fanmaList)
	local layer=cc.Layer:create()--cc.Layer:create()--cc.LayerColor:create(cc.c4b(math.random(1,255),math.random(1,255),0,255))--

	--牌的初始化大小
	local mjWidth=127
	local mjHeight=185
	local scale=0.8

	

	local count,totalRow=self:getMaxCount()--#fanmaList
	local row=math.ceil(#fanmaList/self.m_num)
	local col=count <self.m_num and count or self.m_num

	--麻将最大内容区域
	local padding=10
	local maxWidth=display.width*0.88-(col-1)*padding-padding*2
	local maxHeight=row/totalRow*(display.height*0.58)--display.height-(row-1)*padding-padding*2

	-- print(display.height.." "..(mjHeight*col))

		-- if mjWidth*col>display.width and height*row>display.height then
		-- 	if width*col>height*row then
		-- 		scale=display.width/(width*col)
		-- 		print("11111")
		-- 	else
		-- 		scale=display.height/(height*row)
		-- 		print("22222")
		-- 	end
		-- else
		if mjWidth*col>maxWidth then
			scale=(maxWidth-(col-1)*padding)/(mjWidth*col)
			dump(scale, "<janlog> 33333 scale")
			print("333333")
		end

		if mjHeight*row>maxHeight then
			scale=maxHeight/(mjHeight*row)--(maxHeight-(row-1)*padding-padding*2)/(mjHeight*row)
			dump(scale, "<janlog> 44444 scale")
			print("44444")
		end

	if mjWidth*col>maxWidth and mjHeight*row>maxHeight then
		local scaleX=(maxWidth-(col-1)*padding)/(mjWidth*col)
		local scaleY=maxHeight/(mjHeight*row)--(maxHeight-(row-1)*padding-padding*2)/(mjHeight*row)
		scale = scaleX>scaleY and scaleY or scaleX
		print("55555".." x:"..scaleX.."y:"..scaleY)
	end

	scale=scale>0.8 and 0.8 or scale

	-- if width*col>height*row and height*row<display.height then
	-- 	if width*col>display.width*0.9 then
	-- 		scale=(display.width*0.9)/(width*col)

	-- 		width=width*scale
	-- 		height=height*scale
	-- 	end
	-- else
	-- 	if height*row>display.height then
	-- 		scale=(display.height)/(height*row)

	-- 		width=width*scale
	-- 		height=height*scale
	-- 	end
	-- end

	print("scale:"..scale.." maxHeight:"..maxHeight)
	
	mjWidth=mjWidth*scale
	mjHeight=mjHeight*scale
	-- display.width*0.8-width*col

	layer:setContentSize(display.width,row*mjHeight+(row-1)*padding+padding*2)
	-- dump(layer:getContentSize())


	-- print(col)
	for i=1,row do
		for j=1,col do
			local index=(i-1)*col+j
			if fanmaList[index] then
				local frames    = display.newFrames("fanma%d.png",1,5)
				local fama      = display.newSprite(frames[1])
				local animation = display.newAnimation(frames,0.04)
				-- transition.playAnimationOnce(tmpData.card,animation, false,animationFinish,0.04)
				layer:addChild(fama)
				fama:setScale(scale)
				fama:setPosition((display.width-((col-1)*padding+col*mjWidth))/2+mjWidth/2+(j-1)*(mjWidth+padding), (row-i)*(mjHeight+padding)+mjHeight/2+padding) --mjWidth/2+(j-1)*(mjWidth+padding)

				local arr={
					cc.DelayTime:create(0.5),
					cc.Animate:create(animation),
					cc.CallFunc:create(function()
						local lCardTexture = getCardPngByValue(fanmaList[index].faI6)
						local lWrod = cc.Sprite:createWithSpriteFrameName(lCardTexture)
						lWrod:setPosition(cc.p(fama:getContentSize().width/2,fama:getContentSize().height/2+20))
						fama:addChild(lWrod)
					end),
					cc.DelayTime:create(0.25),
				}

	  				if fanmaList[index].isM==2 then
						table.insert(arr,cc.CallFunc:create(function()
						    local lFrames = display.newFrames("fanmalight%d.png", 1, 14)
						    local lLight = display.newSprite(lFrames[1])
						    local lAniLight = display.newAnimation(lFrames, 1 / 14)
						    -- local function AniCallBack()

						        -- self.m_IconFront:setColor(display.COLOR_WHITE)
						    -- end
						    transition.playAnimationOnce(lLight, lAniLight, true)
						    fama:addChild(lLight)
						    lLight:setScale(3)
						    lLight:setPosition(cc.p(fama:getContentSize().width/2,fama:getContentSize().height/2+20))
						end))
				else
					if  self.m_isTouchClose == false then
					table.insert(arr,cc.DelayTime:create(1))
					else
					  table.insert(arr,cc.DelayTime:create(0.5))
					  table.insert(arr,cc.CallFunc:create(function()
						fama:setColor(cc.c3b(120,120,120))
					  end))
				    end
				end

				fama:runAction(cc.Sequence:create(arr))
			end

		end

	end
	return layer
end


function MJFanMa:onInit()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/jieyangmj/game/fangma.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/jieyangmj/game/fanmalight.plist")

    local title=display.newSprite("package_res/games/jieyangmj/game/fanmaTitle.png")
    title:addTo(self,1):setPosition(display.width/2, display.height-title:getContentSize().height/2)

    self.m_num=12+math.floor(self:getTotalCount(#self.m_data.fanma)/20)


    -- self.gameSystem     = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    -- local players  = self.gameSystem:gameStartGetPlayers()


    local playerCount=#self.m_data.score--#players



    local height = 0
    local panels={}
    	
	local fanmaList = self.m_data.fanma;
	if #fanmaList>0 then

			
		local famaPanel=self:createFamaPanel(fanmaList)
		self:addChild(famaPanel)
		height=height+famaPanel:getContentSize().height
		table.insert(panels,famaPanel)


			-- local userId = players[i]:getProp(enCreatureEntityProp.USERID)
			-- local head=self:createHeadPanel(userId)
			-- famaPanel:addChild(head)
			-- head:setPosition(80, famaPanel:getContentSize().height/2)

		

	end

	local y=(display.height-height)/2
	for k,v in pairs(panels) do
		v:setPositionY(y)
		y=y+v:getContentSize().height
	end
   	
   	local bgLayer=cc.LayerColor:create(cc.c4b(0,0,0,200))
   	self:addChild(bgLayer,-1)
   	bgLayer:setContentSize(display.width,display.height * 0.7)
   	bgLayer:setPositionY((display.height-bgLayer:getContentSize().height)/2)


   	if self.m_isTouchClose then
   		self:initListener()
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
        print("<janlog> onTouchEndedonTouchEndedonTouchEnded")
        self:removeFromParent(true)
    end

    self.m_Listener = cc.EventListenerTouchOneByOne:create()
    self.m_Listener:setSwallowTouches(true)
    self.m_Listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    self.m_Listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    self.m_Listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_Listener, self)
end


return MJFanMa