--
MJFanMa = class("MJFanMa", UIWndBase);

function MJFanMa:ctor(data, ...)
    self.super.ctor(self, "package_res/games/zhongshanmj/game/fangma.csb", ...);
    self.m_data = data
    self.m_posTable={}
	self.m_uiTable={}
	self.m_lightNum=0
	self.m_maNum={};
end

function MJFanMa:onClose()

end

function MJFanMa:onInit()
   cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
   cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/zhongshanmj/game/fangma.plist")
   cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/zhongshanmj/game/fanmalight.plist")
   	
   	self:qiangGangHuFanMa();
  --  Log.i("self.m_data.faI9",self.m_data.faI9)
  --  local num=#self.m_data.faI9;
  --  self.clonePanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "clonePanel");
  --  self.clonePanel:setScale(0.8)
  --  local nsize = self.clonePanel:getContentSize()
  --  Log.i("size ... " .. nsize.width)
  --  local interval=20 --¼ä¸ô50
  --  local nTotalSize =(nsize.width*num) + (num-1)*interval
  --  local midSize = nTotalSize*0.5
   
  --  local animationPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "animationPanel");
  --  local visibleWidth  = animationPanel:getContentSize().width*0.5
  --  local visibleHeight = cc.Director:getInstance():getVisibleSize().height
  --  local startPos = visibleWidth - midSize
  --  local index=num
  --  for i=1,num do
  --       local tmpMaData= self.m_data.faI9[i];
  --       local posx = startPos+(index-1)*nsize.width +(index-1)*interval
  --       local clone = self.clonePanel:clone();
	 --    animationPanel:addChild(clone)
	   
		-- local card      = cc.Sprite:createWithSpriteFrameName("startFrame.png");
	 --   	card:setAnchorPoint(cc.p(0,0))
		-- clone:addChild(card)
                                                                     
		-- --card:setBlendFunc(gl.ZERO,gl.ONE_MINUS_SRC_ALPHA)
		
	   
	 --   clone:setPosition(cc.p(0-posx-nsize.width,70));--ÉèÖÃÔÚÆÁÄ»ÍâÃæ
  --      table.insert(self.m_posTable,posx); 
	   
	 --   local uiData={}
	 --   uiData.cloneUI = clone;
	 --   uiData.card = card;
	 --   uiData.mjData = tmpMaData.faI --Âé½«ID
	 --   if(tmpMaData.isM==1) then --isM  int  ÊÇ·ñÖÐÂí(0: ²»ÖÐ   1:ÖÐ)
	 --     uiData.isMa = true
	 --   else
	 --     uiData.isMa = false
	 --   end
	 --   if(uiData.isMa) then
	 --     self.m_maNum  = self.m_maNum +1 
	 --   end

	 --   table.insert(self.m_uiTable,uiData);
	   
  --      index= index -1
	 --   Log.i( "posx  ... " .. posx .. visibleWidth)
  --  end
   
  --  self:createAnimation();
end

-- 单人翻马
function MJFanMa:normalFanMa(fanmaList, playIndex)
	
end

function MJFanMa:normalFanMa1(fanmaList, playIndex)
	
end

-- 抢杠胡
function MJFanMa:qiangGangHuFanMa()
	self.gameSystem     = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
	local players  = self.gameSystem:gameStartGetPlayers()
	local index = 0;
	self.fanmaData = {}
	local maMaxNum = 1;
	for i = 1, #players do
		local fanmaList = self.m_data.score[i].faI9;
		local isEF = self.m_data.score[i].isEF;
		
		if #fanmaList > 0 then
			index = index + 1
			local fanmaItem = {}
			fanmaItem.maList = {}
			-- fanmaItem.player = {}
			-- table.insert(fanmaItem, fanmaList)
			-- table.insert(fanmaItem, players[i])
			-- for i = 1, #fanmaList do
			-- 	table.insert(fanmaItem.maList, fanmaList[i])
			-- end
			fanmaItem.maList = fanmaList;
			fanmaItem.playerIndex = i;
			fanmaItem.isEF = isEF;
			-- table.insert(fanmaItem.player, players[i])
			table.insert(self.fanmaData, fanmaItem)
			
			if maMaxNum <= #fanmaList then
				maMaxNum = #fanmaList;
			end
		end
	end
	 Log.i("-------------self.fanmaData-----------------------------", self.fanmaData)
	for i = 1, #self.fanmaData do
		self:duoRenFanMa(self.fanmaData[i].maList, self.fanmaData[i].playerIndex, i, #self.fanmaData, maMaxNum, self.fanmaData[i].isEF)
	end

	
end
-- 多人翻马
function MJFanMa:duoRenFanMa(fanmaList, playerSite, playerIndex, playerNum, maMaxNum, isEF)
	-- local visibleHeight = cc.Director:getInstance():getVisibleSize().height
	-- local visibleHeight = cc.Director:getInstance():getContentSize().height
	-- Log.i("---------------多人翻马----------------", visibleHeight)
	-- local playerPosY = 120;
	-- local playerPosY = visibleHeight/2;
	-- if playerNum == 2 then
	-- 	if playerIndex == 1 then
	-- 		-- playerPosY = 180;
	-- 		playerPosY = visibleHeight/2 + 60;
	-- 	else 
	-- 		-- playerPosY = 80;
	-- 		playerPosY = visibleHeight/2 - 60;
	-- 	end
	-- elseif playerNum == 3 then
	-- 	if playerIndex == 1 then
	-- 		playerPosY = visibleHeight/2 + 60;
	-- 		-- playerPosY = 200;
	-- 	elseif playerIndex == 2 then
	-- 		playerPosY = visibleHeight/2 + 60;
	-- 		-- playerPosY = 110;
	-- 	else
	-- 		playerPosY = visibleHeight/2 + 60;
	-- 		-- playerPosY = 20;
	-- 	end
	-- end
	-- ui
	self.clonePanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "clonePanel");

	local animationPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "animationPanel");
	local panelHeight  = animationPanel:getContentSize().height*0.5
   	-- animationPanel:setScaleY(2)
   	-- animationPanel:setAnchorPoint(0.5,0.75)

   	self.fanmaIcon = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_38");
	
   	-- local panelY = animationPanel:getPositionY();
   	local panelY = panelHeight;
   	local playerPosY = panelY - panelY/5;
	if playerNum == 2 then
		if playerIndex == 1 then
			playerPosY = panelY - panelY/5 + panelY/3;
		else 
			playerPosY = panelY - panelY/5 - panelY/3;
		end
	elseif playerNum == 3 then
		if playerIndex == 1 then
			playerPosY = panelY + panelY/2 - panelY/10;
		elseif playerIndex == 2 then
			playerPosY = panelY - panelY/5 - panelY/20;
		else
			playerPosY = panelY - panelY/5 - panelY/5 -panelY/2 ;
		end
	end

	--- 翻马
   local num=#fanmaList;
   
   local interval=125;
   local scale = 0.7;
   local disX = 140;
   if 8 < maMaxNum and maMaxNum <=12 then
   		interval=80
   		scale = 0.5
   	elseif 12 < maMaxNum and maMaxNum <= 24 then
   		interval=45
   		scale = 0.3
   end

   self.clonePanel:setScale(scale)
   -- self.clonePanel:setScaleY(scale*0.5)

   --玩家头像
	self.gameSystem     = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
	local players  = self.gameSystem:gameStartGetPlayers()
	for i = 1, #players do
		if playerSite == i then
			local player = players[i];
			local playerBg = display.newSprite("hall/Common/head_bg.png");     -- "hall/Common/head_bg.png" 
			playerBg:setPosition(cc.p(30,playerPosY));
			playerBg:setAnchorPoint(0,0)
			-- playerBg:setScaleY(0.5)
			animationPanel:addChild(playerBg)

			--local playerHead = display.newSprite("hall/Common/default_head_2.png");  -- "hall/Common/default_head_2.png"
			local playerHead = cc.Sprite:create("hall/Common/default_head_2.png")
			playerHead:setAnchorPoint(0.5,0.5)
			playerHead:setPosition(cc.p(40,40));
			playerBg:addChild(playerHead)
			local playerName = cc.Label:createWithTTF("", "hall/font/fangzhengcuyuan.TTF", 20);
			-- playerName:setAnchorPoint(0.5,0.5)
			playerName:setPosition(cc.p(40,-10));
			playerBg:addChild(playerName)

			local userId = player:getProp(enCreatureEntityProp.USERID)
	        local imgURL = self.gameSystem:gameStartGetPlayerByUserid(userId):getProp(enCreatureEntityProp.ICON_ID) .. "";
	        if string.len(imgURL) > 3 then
	            local imgName = self.gameSystem:gameStartGetPlayerByUserid(userId):getProp(enCreatureEntityProp.USERID)..".jpg";
	            local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
	            if io.exists(headFile) then
	                -- playerHead:loadTexture(headFile)
	                playerHead:setTexture(headFile)
	                playerHead:setScale(70 / playerHead:getContentSize().width)
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
	                playerHead:setTexture(headFile)
	                playerHead:setScale(70 / playerHead:getContentSize().width)
	            end
	        end
	        local strNickName = player:getProp(enCreatureEntityProp.NAME)
	        -- local strNickName = self.m_scoreitems[i].nick
	        local strNickNameLen = string.len(strNickName)
	        local nickName = ""
	        nickName = ToolKit.subUtfStrByCn(strNickName,0,5,"")
	        playerName:setString(nickName)
	        Util.updateNickName(lab_nick, nickName, 22)
		end	
	end


   local nsize = self.clonePanel:getContentSize()
   Log.i("size ... " .. nsize.width)
   
   local nTotalSize =(num-1)*interval
   local midSize = nTotalSize*0.5
   
   
   local visibleWidth  = animationPanel:getContentSize().width*0.5
   local visibleHeight = cc.Director:getInstance():getVisibleSize().height
   local startPos = visibleWidth - midSize

   local index=num

   local posItem = {}
   local uiItem = {}
   local maNum = 0;
   for i=1,num do
        local tmpMaData= fanmaList[i];

        local posx = startPos +(i-1)*interval
        if isEF and i == num then
        	posx = posx + 20
        end
        ---1马居中
        if num < 5 then
        	posx = posx - 35
        end
        -- local posx = 140 +(index-1)*interval
 
        local clone = self.clonePanel:clone();
	    animationPanel:addChild(clone)
	   
		local card      = cc.Sprite:createWithSpriteFrameName("startFrame.png");
	   	card:setAnchorPoint(cc.p(0,0))
		clone:addChild(card)

		clone:setPosition(cc.p(140,playerPosY));
       -- table.insert(self.m_posTable,posx);
       table.insert(posItem,posx); 
	   
	   local uiData={}

	   uiData.cloneUI = clone;
	   uiData.card = card;
	   uiData.mjData = tmpMaData.faI6
	   if(tmpMaData.isM==1) then --isM
	     uiData.isMa = true
	   else
	     uiData.isMa = false
	   end

	   if(uiData.isMa) then
	       maNum  = maNum +1 
	   end

	   table.insert(uiItem,uiData);
	   
	   --补马颜色变化
	    if isEF and i == num then
	   		-- card:setColor(cc.c3b(255, 255, 0))
	   		clone:setColor(cc.c3b(255, 255, 0))
	    end
       -- index= index -1
	   -- Log.i( "posx  ... " .. posx .. visibleWidth)
   end
   table.insert(self.m_maNum,maNum);
   table.insert(self.m_posTable,posItem);
   table.insert(self.m_uiTable,uiItem);
   Log.i("--------------self.m_posTable-----------", self.m_posTable)
   self:createAnimation(playerPosY, playerIndex);
end

function MJFanMa:createAnimation(playerPosY, playerIndex)
   local uiTable = self.m_uiTable[playerIndex];
   local posTable = self.m_posTable[playerIndex];
   local maNum = self.m_maNum[playerIndex];
   for i=1,#uiTable do
       local tmpData = uiTable[i]
    
	    local posx = posTable[i]

	    local moveTo = cc.MoveTo:create(0.1*i,cc.p(posx,playerPosY))
	    
		local callFunc = cc.CallFunc:create(function () 
		   
			local function animationFinish()
			    Log.i("animation finish.....")
				local pai = getCardPngByValue(tmpData.mjData)
                local spMj = cc.Sprite:createWithSpriteFrameName(pai);

                -- if #self.m_uiTable > 4 then
                -- 	tmpData.cloneUI:setScale(0.5)
                -- end

				tmpData.cloneUI:addChild(spMj);
				tmpData.mj = spMj
				spMj:setPosition(cc.p(tmpData.card:getContentSize().width / 2,tmpData.card:getContentSize().height / 2 + 15))
				
				if(tmpData.isMa) then
			       self:playLightAnimation(tmpData.cloneUI,tmpData.mj, playerIndex);
		        end
				
				if(maNum<=0) then --
				  	tmpData.card:setOpacity(50)
					tmpData.cloneUI:setOpacity(50)
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

function MJFanMa:playLightAnimation(bg,mj, playerIndex)
	local uiTable = self.m_uiTable[playerIndex];
    local tmpBg= bg;
	local tmpMj = mj;
	local function animationFinish()
		Log.i("animation light finish.....")
		-- self.m_lightNum = self.m_lightNum + 1
		-- self.m_lightNum == self.m_maNum and
		if( self.m_maNum[playerIndex]>0) then --
		      for i=1,#uiTable do
	            local tmpData = uiTable[i]
			    if(tmpData.isMa==false) then
	                tmpData.cloneUI:setOpacity(50)
					tmpData.card:setOpacity(50)
					-- tmpData.mj:setOpacity(50)
	            end
		    end 
		end
	end
	
	local frames    = display.newFrames("fanmalight%d.png",1,14)
	local fama      = display.newSprite(frames[1])
	local animation = display.newAnimation(frames,0.04)
	transition.playAnimationOnce(fama,animation,true,animationFinish,0.04)
	bg:addChild(fama)
	fama:setScale(3)
	fama:setPosition(cc.p(bg:getContentSize().width / 2,bg:getContentSize().height-20))
	
end

-- 收到返回键事件
function MJFanMa:keyBack()
end
