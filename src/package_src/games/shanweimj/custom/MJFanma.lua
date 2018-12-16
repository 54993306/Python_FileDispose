--
local MJFanMa = class("MJFanMa", function ()
	 return display.newLayer()
end);

function MJFanMa:ctor(data,isTouchClose)
    self.m_data = clone(data)
    self.m_isTouchClose=isTouchClose
    self:onInit()

end


function MJFanMa:createHeadPanel(playerID)
    local lGameSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local lPlayersInfo = lGameSystem:gameStartGetPlayers()
    local lPlayerIndex = lGameSystem:getPlayerSiteById(playerID)
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
            lHeadIMG:setScale(0.14)
        end
    else
        local lImgName = "hall/Common/default_head_2.png"
        local lHeadFile = cc.FileUtils:getInstance():fullPathForFilename(lImgName)
        if io.exists(lHeadFile) then
            lHeadIMG:setTexture(lHeadFile)
            lHeadIMG:setScale(0.6)
        end
    end


    --  头像框
    local lHeadBG = cc.Sprite:create("games/common/game/friendRoom/mjOver/bg_head.png")
    lHeadNode:addChild(lHeadBG)
    local lHeadBGSize = lHeadBG:getContentSize()

    --  庄家图标
    local lBankerIcon = cc.Sprite:create("games/common/game/friendRoom/mjOver/zhuang.png")
    lHeadBG:addChild(lBankerIcon)
    lBankerIcon:setPosition(cc.p(0, lHeadBGSize.height))

    local lBanker = lPlayersInfo[lPlayerIndex]:getProp(enCreatureEntityProp.BANKER)
    if lBanker then
        lBankerIcon:setVisible(true)
    else
        lBankerIcon:setVisible(false)
    end

    --  昵称
    local lNameLab = cc.Label:create()
    lHeadBG:addChild(lNameLab)
    lNameLab:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
    lNameLab:setColor(cc.c3b(252, 234, 67))
    lNameLab:setAnchorPoint(cc.p(0, 1))
    lNameLab:setPosition(cc.p(0, lHeadBGSize.height * 0.05))
    lNameLab:setSystemFontSize(30)

    local lStrName = ""
    lStrName = ToolKit.subUtfStrByCn(lScoreItems[lPlayerIndex].nick, 0, 5, "")
    lNameLab:setString(lStrName)
    Util.updateNickName(lNameLab, lStrName)

    return lHeadNode
end

function MJFanMa:getMaxCount(data)
	return #data.fanma,math.ceil(#data.fanma/self.m_num)
	-- local maxCount=1
	-- local totalRow=0
	-- for k,v in pairs(data.fanma) do

	-- 	local row=math.ceil(v.faI6/self.m_num)
	-- 	totalRow=totalRow+row

	-- 	if v.faI6>maxCount then
	-- 		maxCount=v.faI6
	-- 	end
	-- end
	-- return maxCount,totalRow
end

function MJFanMa:getTotalCount(data)
	return #data.fanma
	-- local total=0
	-- for k,v in pairs(data.fanma) do
	-- 	total=total+v.faI6
	-- end
	-- return total
end

function MJFanMa:createFamaPanel(fanmaList)

	self.m_num=12+math.floor(self:getTotalCount(self.m_data)/20)

	local layer=cc.Layer:create()--cc.LayerColor:create(cc.c4b(math.random(1,255),math.random(1,255),math.random(1,255),255))

	--牌的初始化大小
	local mjWidth=127
	local mjHeight=185
	local scale=0.8

	local count,totalRow=self:getMaxCount(self.m_data)--#fanmaList
	local row=math.ceil(#fanmaList/self.m_num)
	local col=count <self.m_num and count or self.m_num

	--麻将最大内容区域
	local padding=10
	local maxWidth=display.width*0.88-(col-1)*padding-padding*2
	local maxHeight=row/totalRow*(display.height*0.58)

	if mjWidth*col>maxWidth then
		scale=(maxWidth-(col-1)*padding)/(mjWidth*col)
		print("333333")
	end

	if mjHeight*row>maxHeight then
		scale=maxHeight/(mjHeight*row)--(maxHeight-(row-1)*padding-padding*2)/(mjHeight*row)
		print("44444")
	end

	if mjWidth*col>maxWidth and mjHeight*row>maxHeight then
		local scaleX=(maxWidth-(col-1)*padding)/(mjWidth*col)
		local scaleY=maxHeight/(mjHeight*row)--(maxHeight-(row-1)*padding-padding*2)/(mjHeight*row)
		scale = scaleX>scaleY and scaleY or scaleX
		print("55555".." x:"..scaleX.."y:"..scaleY)
	end

	scale=scale>0.8 and 0.8 or scale

	print("scale:"..scale.." maxHeight:"..maxHeight)
	
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


function MJFanMa:onInit()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/shanweimj/game/fama/fangma.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/shanweimj/game/fama/light.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/shanweimj/game/fama/explode.plist")

    local title=display.newSprite("package_res/games/shanweimj/game/fama/title.png")
    title:addTo(self,1):setPosition(display.width/2, display.height-title:getContentSize().height/2-10)

    local playerCount=#self.m_data

    local height = 0
    local panels={}

    self.m_panels={}
    -- for i = 1, playerCount do
		local fanmaList = self.m_data.fanma;
		if #fanmaList>0 then
			local famaPanel,famas=self:createFamaPanel(fanmaList)
			self:addChild(famaPanel)
			height=height+famaPanel:getContentSize().height

			self.m_panels={panel=famaPanel,famas=famas}
			table.insert(panels,famaPanel)

			-- famaPanel:performWithDelay(function()
				-- self:composeAnimation(1)
			-- end, 3)
		end
	-- end

	local y=(display.height-height)/2
	for k,v in pairs(panels) do
		v:setPositionY(y)
		y=y+v:getContentSize().height
	end
   	
   	local bgLayer=cc.LayerColor:create(cc.c4b(0,0,0,200))
   	self:addChild(bgLayer,-1)
   	bgLayer:setContentSize(display.width,display.height*0.7)
   	bgLayer:setPositionY((display.height-bgLayer:getContentSize().height)/2)


   	if self.m_isTouchClose then
   		self:initListener()
   	end
end


function MJFanMa:famaAnimation(fama,data)
	local frames    = display.newFrames("fanma%d.png",1,5)
	-- local fama      = display.newSprite(frames[1])
	local animation = display.newAnimation(frames,0.04)
	local arr={
		cc.DelayTime:create(0.5),
		cc.Animate:create(animation),
		cc.CallFunc:create(function()
			local lCardTexture = getCardPngByValue(data.faI6)
			if not lCardTexture then print(data.faI6) end
			local lWrod = cc.Sprite:createWithSpriteFrameName(lCardTexture)
			lWrod:setPosition(cc.p(fama:getContentSize().width/2,fama:getContentSize().height/2+20))
			fama:addChild(lWrod)
		end),
		cc.DelayTime:create(0.25),
	}

	if data.isM==1 then
		table.insert(arr,cc.CallFunc:create(function()
			local lFrames = display.newFrames("fanmalight%d.png", 1, 14)
			local lLight = display.newSprite(lFrames[1])
			local lAniLight = display.newAnimation(lFrames, 1 / 14)
			transition.playAnimationOnce(lLight, lAniLight, true)
			fama:addChild(lLight)
			lLight:setScale(3)
			lLight:setPosition(cc.p(fama:getContentSize().width/2,fama:getContentSize().height/2+20))
		end))
	else
		table.insert(arr,cc.DelayTime:create(1))
		table.insert(arr,cc.CallFunc:create(function()
			fama:setColor(cc.c3b(120,120,120))
		end))
		-- table.insert(arr,cc.DelayTime:create(1))
		-- table.insert(arr,cc.RemoveSelf())
	end

	fama:runAction(cc.Sequence:create(arr))
end

function MJFanMa:createComposeFamas(datas,layer)
	local num=12+math.floor(self:getTotalCount({{faI9=datas}})/20)

	-- local layer=cc.Layer:create()

	--牌的初始化大小
	local mjWidth=127
	local mjHeight=185
	local scale=0.8

	local count,totalRow=self:getMaxCount({{faI9=datas}})--#fanmaList
	local row=math.ceil(#datas/num)
	local col=count <num and count or num

	--麻将最大内容区域
	local padding=10
	local maxWidth=display.width*0.88-(col-1)*padding-padding*2
	local maxHeight=layer:getContentSize().height-(row-1)*padding-padding*2 --row/totalRow*(display.height*0.58)

	print(layer:getContentSize().height.." "..maxHeight)

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
--[[
function MJFanMa:composeAnimation(index)
	local datas,disDatas=self:compose(index)
	if #datas>0 then
		local famas=self:createComposeFamas(datas,self.m_panels[index].panel)

		for k,v in pairs(self.m_panels[index].famas) do
				for _,fama in pairs(v) do
					local arr={
					}
					if famas[k] and fama:getColor().r~=120 then --根据颜色判断是否是中的马
						local totalFama=famas[k][1]
						totalFama:setVisible(false)

						
						local famaNum=display.newSprite("package_res/games/shanweimj/game/fama/maCount"..(#v>4 and 4 or #v)..".png")
						totalFama:addChild(famaNum)
						famaNum:setPosition(103, 161)
						table.insert(arr,cc.DelayTime:create(1))
						table.insert(arr,cc.Spawn:create(cc.MoveTo:create(0.5,cc.p(totalFama:getPosition())),cc.ScaleTo:create(0.5,totalFama:getScale())))
						table.insert(arr,cc.CallFunc:create(function ()
							totalFama:setVisible(true)
						end))
					else
						
						table.insert(arr,cc.CallFunc:create(function ()
							local frames    = display.newFrames("explode%d.png",1,12)
							local explode      = display.newSprite(frames[1])
							local animation = display.newAnimation(frames,0.04)
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
--]]

--[[
function MJFanMa:compose(index)
	local keys={}
	local datas={}
	local disDatas={}

	-- for _,score in pairs(self.m_data[index].faI9) do
		for k,v in pairs(self.m_data.fanma) do
			if v.isM==1 then
				if  keys[v.faI9] then
					local data=self:getFamaData(datas,v.faI9)
					data.count=data.count+1
				else
					keys[v.faI9]=true
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
--]]

--[[
function MJFanMa:getFamaData(datas,value)
	for k,v in pairs(datas) do
		if v.faI6==value then
			return v
		end
	end
end
--]]

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
        self:removeFromParent()
    end

    self.m_Listener = cc.EventListenerTouchOneByOne:create()
    self.m_Listener:setSwallowTouches(true)
    self.m_Listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    self.m_Listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    self.m_Listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_Listener, self)
end


return MJFanMa