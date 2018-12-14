--翻马UI
MJFanMa = class("MJFanMa", UIWndBase);

function MJFanMa:ctor(data, ...)
    self.super.ctor(self, "package_res/games/hongzhongmj/game/fangma.csb", ...);
    self.m_data = data --结算数据中有马
    self.m_posTable={}
    self.m_uiTable={}
    self.m_lightNum=0
    self.m_maNum=0;
end

function MJFanMa:onClose()

end

function MJFanMa:onInit()
   cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/mj/majiang_pai.plist")
   cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/game/fangma.plist")
   cc.SpriteFrameCache:getInstance():addSpriteFrames("games/common/game/fanmalight.plist")
   
   Log.i("收到麻将翻马数据",self.m_data.faI)
   local num=#self.m_data.faI;
   self.clonePanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "clonePanel");
  
   local nsize = self.clonePanel:getContentSize()
   Log.i("size ... " .. nsize.width)
   local interval=50 --间隔50
   local nTotalSize =(nsize.width*num) + (num-1)*interval
   local midSize = nTotalSize*0.5
   
   local animationPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "animationPanel");
   local visibleWidth  = animationPanel:getContentSize().width*0.5
   local visibleHeight = cc.Director:getInstance():getVisibleSize().height
   local startPos = visibleWidth - midSize
   local index=num
   for i=1,num do
        local tmpMaData= self.m_data.faI[i];
        local posx = startPos+(index-1)*nsize.width +(index-1)*interval
        local clone = self.clonePanel:clone();
        animationPanel:addChild(clone)
       
        local card      = cc.Sprite:createWithSpriteFrameName("startFrame.png");
        card:setAnchorPoint(cc.p(0,0))
        clone:addChild(card)
                                                                     
        --card:setBlendFunc(gl.ZERO,gl.ONE_MINUS_SRC_ALPHA)
        
       
       clone:setPosition(cc.p(0-posx-nsize.width,30));--设置在屏幕外面
       table.insert(self.m_posTable,posx); 
       
       local uiData={}
       uiData.cloneUI = clone;
       uiData.card = card;
       uiData.mjData = tmpMaData.faI6 --麻将ID
       if(tmpMaData.isM==1) then --isM  int  是否中马(0: 不中   1:中)
         uiData.isMa = true
       else
         uiData.isMa = false
       end
       if(uiData.isMa) then
         self.m_maNum  = self.m_maNum +1 
       end

       table.insert(self.m_uiTable,uiData);
       
       index= index -1
       Log.i( "posx  ... " .. posx .. visibleWidth)
   end
   
   self:createAnimation();
end

function MJFanMa:createAnimation()
   for i=1,#self.m_uiTable do
       local tmpData = self.m_uiTable[i]
       --先执行位移动作
        local posx = self.m_posTable[i]
        local moveTo = cc.MoveTo:create(0.1*i,cc.p(posx,30))
        
        local callFunc = cc.CallFunc:create(function () 
           
            local function animationFinish()
                Log.i("animation finish.....")
                local pai = getCardPngByValue(tmpData.mjData)
                local spMj = cc.Sprite:createWithSpriteFrameName(pai);
                tmpData.cloneUI:addChild(spMj);
                tmpData.mj = spMj
                spMj:setPosition(cc.p(tmpData.card:getContentSize().width / 2,tmpData.card:getContentSize().height / 2 + 15))
                
                if(tmpData.isMa) then
                   self:playLightAnimation(tmpData.cloneUI,tmpData.mj);--调光
                end
                
                if(self.m_maNum<=0) then --一个马也没有
                    tmpData.card:setOpacity(50)
                    spMj:setOpacity(50)
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

function MJFanMa:playLightAnimation(bg,mj)
    local tmpBg= bg;
    local tmpMj = mj;
    local function animationFinish()
        Log.i("animation light finish.....")
        self.m_lightNum = self.m_lightNum + 1
        
        if(self.m_lightNum == self.m_maNum and self.m_maNum>0) then --全部亮动画播放完成
               for i=1,#self.m_uiTable do
                   local tmpData = self.m_uiTable[i]
                   if(tmpData.isMa==false) then
                        tmpData.cloneUI:setOpacity(50)
                        tmpData.card:setOpacity(50)
                        tmpData.mj:setOpacity(50)
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
function MJFanMa:onKeyBack()
end