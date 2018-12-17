--
-- Author: Your Name
-- Date: 2017-05-23 19:39:13
--
--翻马UI
MJFanma = class("MJFanma", UIWndBase);

function MJFanma:ctor(...)
    self.super.ctor(self, "package_res/games/jieyangmj/game/fangma.csb", ...);
    self.gameSystem     = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.m_data = self.gameSystem:getGameOverDatas()
    self.m_posTable={}
	self.m_uiTable={}
	self.m_lightNum=0
	self.m_maNum=0;
end

function MJFanma:onClose()

end

function MJFanma:onInit()
   cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
   cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/jieyangmj/game/fangma.plist")
   cc.SpriteFrameCache:getInstance():addSpriteFrames("package_res/games/jieyangmj/game/fanmalight.plist")
   
   --faI{[1]:{faM:什么牌，ishorse:是否中马}}
   -- Log.i("收到麻将翻马数据",self.m_data.ho)
   local titleImage = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_38")
   titleImage:loadTexture("package_res/games/jieyangmj/game/fanmaTitle.png")
   titleImage:setScale(1.6)

   -- local titleImageNew = ccui.ImageView:create("res/games/yunfujiangmamj/game/fanmaTitle.png")
   -- titleImageNew:setPosition(cc.p(titleImage:getPosition()))
   -- local parent = titleImage:getParent()
   -- parent:addChild(titleImageNew)
   -- titleImage:removeFromParent(true)

   local num=#self.m_data.fanma;
   self.clonePanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "clonePanel");
  
   local nsize = self.clonePanel:getContentSize()
   Log.i("size ... " .. nsize.width)
   local interval=-5--间隔50
   local nTotalSize =(nsize.width*num) + (num-1)*interval
   local midSize = nTotalSize*0.5
   
   local animationPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "animationPanel");
   local visibleWidth  = animationPanel:getContentSize().width*0.5
   local visibleHeight = cc.Director:getInstance():getVisibleSize().height
   local startPos = visibleWidth - midSize
   local index=num
   for i=1,num do
        local tmpMaData= self.m_data.fanma[i];
        local posx = startPos+(index-1)*nsize.width +(index-1)*interval
        local clone = self.clonePanel:clone();
	    animationPanel:addChild(clone)
	   
		local card      = cc.Sprite:createWithSpriteFrameName("startFrame.png");
	   	card:setAnchorPoint(cc.p(0,0))
		clone:addChild(card)
                                                                     
		--card:setBlendFunc(gl.ZERO,gl.ONE_MINUS_SRC_ALPHA)
		Log.i("...aaaaaa....tmpData.mjData...bbbbbb...:",tmpMaData )
	   
	   clone:setPosition(cc.p(0-posx-nsize.width,30));--设置在屏幕外面
       table.insert(self.m_posTable,posx); 
	   
	   local uiData={}
	   uiData.cloneUI = clone;
	   uiData.card = card;
	   uiData.mjData = tmpMaData --麻将ID
	   uiData.isMa = tmpMaData.isM
	   -- if(tmpMaData.isM==1) then --ishorse  int  是否中马(0: 不中   1:中)
	   --   uiData.isMa = true
	   -- else
	   --   uiData.isMa = false
	   -- end
	   if(uiData.isMa == 1 or uiData.isMa == 2) then
	     self.m_maNum  = self.m_maNum +1 
	   end

	   table.insert(self.m_uiTable,1,uiData);
	   
       index= index -1
	   Log.i( "posx  ... " .. posx .. visibleWidth)
   end

   self:createAnimation();
end

--uiData数据，麻将是多少，麻将的类型， 
function MJFanma:createAnimation()
   for i=1,#self.m_uiTable do
       local tmpData = self.m_uiTable[i]
       --先执行位移动作
	    local posx = self.m_posTable[i]
	    local moveTo = cc.MoveTo:create(0.1*i,cc.p(posx,30))
		-- if tmpData.isMa == 0 then
		-- 	tmpData.card:setColor(cc.c3b(128,128,128))
		-- elseif tmpData.isMa == 2 then
		-- 	tmpData.card:setColor(cc.c3b(255,255,0))
		-- end
		local callFunc = cc.CallFunc:create(function () 		   
			local function animationFinish()
			    Log.i(".........animation finish.....")
				local pai = getCardPngByValue(tmpData.mjData.faI6)--传翻马的牌，显示出来
                local spMj = cc.Sprite:createWithSpriteFrameName(pai);
				tmpData.cloneUI:addChild(spMj);
				tmpData.mj = spMj
				spMj:setPosition(cc.p(tmpData.card:getContentSize().width / 2,tmpData.card:getContentSize().height / 2 + 15))
				
				if(tmpData.isMa == 1 or tmpData.isMa == 2) then
			       self:playLightAnimation(tmpData.cloneUI,tmpData.mj);--调光
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


function MJFanma:keyBack()
end

function MJFanma:playLightAnimation(bg,mj)
    local tmpBg= bg;
	local tmpMj = mj;
	local function animationFinish()
		Log.i("animation light finish.....")
		self.m_lightNum = self.m_lightNum + 1
		
		if(self.m_lightNum == self.m_maNum and self.m_maNum>0) then --全部亮动画播放完成
		       for i=1,#self.m_uiTable do
                   local tmpData = self.m_uiTable[i]
				   if(tmpData.isMa==0) then
	                   --tmpData.cloneUI:setOpacity(50)
						--tmpData.card:setColor(cc.c3b(128,128,128))
						--tmpData.mj:setOpacity(50)
					elseif tmpData.isMa == 2 then
						--tmpData.card:setColor(cc.c3b(255,255,0))
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

return MJFanma
