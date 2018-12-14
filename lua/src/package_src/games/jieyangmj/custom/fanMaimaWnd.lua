--买马结算

fanMaimaWnd = class("fanMaimaWnd", UIWndBase);

local getZhuangText = function(zhuangSite, site, playerCount)
    local siteMap4 = {
            [1] = {
            [2] = "庄下家",
            [3] = "庄对家",
            [4] = "庄上家",
            },
            [2] = {
            [1] = "庄上家",
            [3] = "庄下家",
            [4] = "庄对家",
            },
            [3] = {
            [1] = "庄对家",
            [2] = "庄上家",
            [4] = "庄下家",
            },
            [4] = {
            [1] = "庄下家",
            [2] = "庄对家",
            [3] = "庄上家",
            }
    }

    local siteMap3 = {
        [1] = {
        [2] = "庄下家",
        [3] = "庄上家",
        },
        [2] = {
        [1] = "庄上家",
        [3] = "庄下家",
        },
        [3] = {
        [1] = "庄下家",
        [2] = "庄上家",
        },
    }

    if playerCount == 4 then
        return siteMap4[zhuangSite][site]
    elseif playerCount == 3 then
        return siteMap3[zhuangSite][site]
    else
        return ""
    end

end

function fanMaimaWnd:ctor(...)
    self.super.ctor(self, "package_res/games/jieyangmj/game/fangma.csb", ...);
    self.gameSystem     = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.m_data = self.gameSystem:getGameOverDatas()
    self.m_posTable={}
	self.m_uiTable={}
	self.m_lightNum=0
	self.m_maNum=0;
end

function fanMaimaWnd:onClose()

end

function fanMaimaWnd:keyBack()
	-- body
end

function fanMaimaWnd:onInit()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/jieyangmj/game/fangma.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/jieyangmj/game/fanmalight.plist")
   
    local titleImage = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_38")
    titleImage:loadTexture("package_res/games/jieyangmj/game/maimaTitle.png")
    titleImage:setScale(1.6)
    local titleMargin = titleImage:getLayoutParameter():getMargin()
    titleMargin.top = 20
    titleMargin.bottom = display.top - 20
    titleImage:getLayoutParameter():setMargin(titleMargin)

    local animationPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "animationPanel");
    animationPanel:setContentSize(animationPanel:getContentSize().width, 520)

    for k=1,#self.m_data.score do

    	local maimaInfo = self.m_data.score[k].maCards or {}
    	-- dump(maimaInfo, "sunbinLog:maimaInfo ==================")
	    local num=#maimaInfo;
	    self.clonePanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "clonePanel");
	  
	    local nsize = self.clonePanel:getContentSize()
	    -- self.clonePanel:setContentSize(nsize.width, 720)
	    Log.i("size ... " .. nsize.width)
	    local posY = 500 - 120 * k
	    local interval=80 --间隔50
	    -- local nTotalSize =(nsize.width*num) + (num-1)*interval
	    -- local midSize = nTotalSize*0.5

    	self:createHead(animationPanel, self.m_data.score[k], cc.p(420, posY + 20), #self.m_data.score)
	   
	    local visibleWidth  = animationPanel:getContentSize().width
	    local visibleHeight = cc.Director:getInstance():getVisibleSize().height
	    local startPos = 480
	    local index=num
	    -- if num > 6 then
	   	-- 	animationPanel:setScale(0.7)
	    -- end

	   self.m_uiTable[k] = {}
	   self.m_posTable[k] = {}
	    for i=1,num do
	        local tmpMaData= maimaInfo[i];
	    	-- dump(tmpMaData, "sunbinLog:fanmaData ===============")
	        local posX = startPos+(index-1)*interval--+ 770*(4-k)
	    	-- print("sunbinLog:------------ k === i ==== posX ==== ", k, i, posX)
	        local clone = self.clonePanel:clone();
		    animationPanel:addChild(clone)
		   
			local card      = cc.Sprite:createWithSpriteFrameName("startFrame.png");
		   	card:setAnchorPoint(cc.p(0,0))
			clone:addChild(card)
			-- if num > 6 then
				clone:setScale(0.5)
			-- end
	                                                                     
			--card:setBlendFunc(gl.ZERO,gl.ONE_MINUS_SRC_ALPHA)
			Log.i("...aaaaaa....tmpData.mjData...bbbbbb...:",tmpMaData )
		   
		   clone:setPosition(cc.p(visibleWidth + 20,posY));--设置在屏幕外面

	       table.insert(self.m_posTable[k],cc.p(posX, posY)); 
		   
		   local uiData={}
		   uiData.cloneUI = clone;
		   uiData.card = card;
		   uiData.mjData = tmpMaData --麻将ID
		   if(tmpMaData.isM>0) then --isM  int  是否中马(0: 不中   1:中)
		     uiData.isMa = true
		   else
		     uiData.isMa = false
		   end
		   if(uiData.isMa) then
		     self.m_maNum  = self.m_maNum +1 
		   end

		   self.m_uiTable[k][i] = uiData
		   
	       index= index -1
		   Log.i( "posX  ... " .. posX .. visibleWidth)
	    end

    end

	self:createAnimation();
end

--uiData数据，麻将是多少，麻将的类型， 
function fanMaimaWnd:createAnimation()
	-- dump(self.m_posTable, "nimab")
   for k=1,#self.m_uiTable do
   		for i=1,#self.m_uiTable[k] do
	        local tmpData = self.m_uiTable[k][i]
	        -- print("k  ,    i ", k, i )
	        -- dump(tmpData, "sunbinLog:fanma =========")
	       --先执行位移动作
		    local pos = self.m_posTable[k][i]
		    -- local posX = self.m_posTable[k][i].x
		    -- local posY = self.m_posTable[k][i].y
		    -- tmpData.cloneUI:setPosition(pos)
		    
		    -- dump(pos,"sunbinLog:------createAnimation--pos ====")

		    local moveTo = cc.MoveTo:create(0.1*i,pos)--cc.p(posX, posY))
		    -- local moveTo = cc.MoveTo:create(0.1,pos)
			
			local callFunc = cc.CallFunc:create(function () 		   
				local function animationFinish()
				    Log.i(".........animation finish.....")
					local pai = getCardPngByValue(tmpData.mjData.faI6)--传翻马的牌，显示出来
	                local spMj = cc.Sprite:createWithSpriteFrameName(pai);
					tmpData.cloneUI:addChild(spMj);
					tmpData.mj = spMj
					spMj:setPosition(cc.p(tmpData.card:getContentSize().width / 2,tmpData.card:getContentSize().height / 2 + 15))
					
					local finalPos = tmpData.cloneUI:getPosition()
					-- dump(finalPos , "finalPos ========================")
					if(tmpData.isMa) then
				       self:playLightAnimation(tmpData.cloneUI,tmpData.mj);--调光
			        end

					
					if(self.m_maNum<=0) then --一个马也没有
	                    tmpData.cloneUI:setOpacity(80)
						tmpData.card:setOpacity(80)
						tmpData.mj:setOpacity(255)
					end
				end
				
				local frames    = display.newFrames("fanma%d.png",1,5)
				local fama      = display.newSprite(frames[1])
				local animation = display.newAnimation(frames,0.04)
				transition.playAnimationOnce(tmpData.card,animation, false,animationFinish,0.04)
			end)
			
			tmpData.cloneUI:runAction(cc.Sequence:create(moveTo,cc.DelayTime:create(0.15),callFunc))
   		end

   end

end

function fanMaimaWnd:playLightAnimation(bg,mj)
    local tmpBg= bg;
	local tmpMj = mj;
	local function animationFinish()
		Log.i("animation light finish.....")
		self.m_lightNum = self.m_lightNum + 1
		
		if(self.m_lightNum == self.m_maNum and self.m_maNum>0) then --全部亮动画播放完成
		       for k=1,#self.m_uiTable do
		       		for i=1,#self.m_uiTable[k] do
	                    local tmpData = self.m_uiTable[k][i]
					    if(tmpData.isMa==false) then
		                    tmpData.cloneUI:setOpacity(80)
							tmpData.card:setOpacity(80)
							tmpData.mj:setOpacity(255)
		                end
		       		end
			   end
		end
	end
	
	local frames    = display.newFrames("fanmalight%d.png",1,14)
	local fama      = display.newSprite(frames[1])
	local animation = display.newAnimation(frames,0.04)
	transition.playAnimationOnce(fama,animation,true,animationFinish,0.04)--animationFinish播完动画
	bg:addChild(fama)
	fama:setScale(3)
	fama:setPosition(cc.p(bg:getContentSize().width / 2,bg:getContentSize().height-20))
	
end

function fanMaimaWnd:createHead(parent, player, headPos, playerCount)
	local img_head = ccui.ImageView:create("hall/Common/default_head_2.png"):addTo(parent)
	img_head:setPosition(headPos)
	img_head:setAnchorPoint(0.5, 0)

    local name =  ToolKit.subUtfStrByCn(player.nick,0,5,"...")

    local params = {}
    params.text = name or ""
    params.font = "hall/font/fangzhengcuyuan.TTF"
    local nickText = display.newTTFLabel(params):addTo(parent)
     
    Util.updateNickName(nickText,name, 18)  --繁体字处理
	nickText:setColor(cc.c3b(55, 182, 102))
	nickText:setPosition(headPos.x, headPos.y - 10)
	-- img_head:setAnchorPoint(0.5, 0)

    local userId = player.userid
    local imgURL = self.gameSystem:gameStartGetPlayerByUserid(userId):getProp(enCreatureEntityProp.ICON_ID) .. "";
    if string.len(imgURL) > 3 then
        local imgName = self.gameSystem:gameStartGetPlayerByUserid(userId):getProp(enCreatureEntityProp.USERID)..".jpg";
        local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(headFile) then
            img_head:loadTexture(headFile)
            img_head:setScale(70 / img_head:getContentSize().width)
        else
            if self.images== nil then
                self.images = {}
            end
            self.images[imgName] = img_head
            self:getNetworkImage(imgURL, imgName)
        end
    else
        local headFile = "hall/Common/default_head_2.png"
        headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile)
        if io.exists(headFile) then
            img_head:loadTexture(headFile)
            img_head:setScale(70 / img_head:getContentSize().width)
        end
    end

	local headBg = display.newSprite("hall/Common/head_bg.png")
	headBg:setAnchorPoint(0.5, 0)
	headBg:setPosition(headPos)
	parent:addChild(headBg)

	local site = self.gameSystem:getPlayerSiteById(userId)
    local zhuangSite = self.gameSystem:gameStartGetBankerSite()
    if site  and  zhuangSite ~= site then
        local imgZuiDetail = ccui.ImageView:create("package_res/games/jieyangmj/common/site_details.png")
        local players  = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()
        if #players ~= 2 then
        headBg:addChild(imgZuiDetail)
        end
        imgZuiDetail:setPosition(cc.p(33,17))
        imgZuiDetail:setLocalZOrder(-1)
        -- imgZuiDetail:setRotation(180)
        print("zahung site ", zhuangSite, site)
        local text = getZhuangText(zhuangSite, site, playerCount)
        local labelDesc = cc.Label:createWithTTF(text, "hall/font/fangzhengcuyuan.TTF", 16)
        imgZuiDetail:addChild(labelDesc)
        labelDesc:setAnchorPoint(cc.p(1, 0.5))
        labelDesc:setPosition(imgZuiDetail:getContentSize().width - 3, imgZuiDetail:getContentSize().height * 0.5)
    elseif zhuangSite == site then
        local zhuangIcon = ccui.ImageView:create("games/common/game/friendRoom/mjOver/zhuang.png")
        headBg:addChild(zhuangIcon)
        zhuangIcon:setPosition(cc.p(0,65))
    end
end
return fanMaimaWnd