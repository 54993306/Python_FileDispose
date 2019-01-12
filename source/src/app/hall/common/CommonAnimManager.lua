--窗口管理器

CommonAnimManager = class("CommonAnimManager");

CommonAnimManager.getInstance = function()
    if not CommonAnimManager.s_instance then
        CommonAnimManager.s_instance = CommonAnimManager.new();
    end

    return CommonAnimManager.s_instance;
end

CommonAnimManager.releaseInstance = function()
    if CommonAnimManager.s_instance then
        CommonAnimManager.s_instance:dtor();
    end
    CommonAnimManager.s_instance = nil;
end

function CommonAnimManager:ctor()
end

function CommonAnimManager:dtor()

end

--暂停一下自动恢复（用于游戏从后台回到前台）
function CommonAnimManager:pauseMoment(time)
    if self.m_pauseScheduler then
        scheduler.unscheduleGlobal(self.m_pauseScheduler);
        self.m_pauseScheduler = nil;
    end
    self.m_isPause = true
    self.m_pauseScheduler = scheduler.performWithDelayGlobal(function ()
        self.m_isPause = false;
    end, time or 1);
end

function CommonAnimManager:isPause()
    return self.m_isPause;
end

--赢取金币界面
--num: 金币个数（默认100个）
function CommonAnimManager:showMoneyWinAnim(num,is_yuanbao)
    SoundManager.playEffect("gold_rain", false);
    num = num or 100;
    if self.m_anim_layer then
        display.getRunningScene():removeChild(self.m_anim_layer);
        self.m_anim_layer = nil;
    end
    self.m_anim_layer = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/null_layer.csb");
    display.getRunningScene():addChild(self.m_anim_layer, 1001);
    local img = "img_diamond.png"
    if is_yuanbao then
        img = "yuanbao.png"
    end
    local gold = ccui.ImageView:create("hall/main/"..img);
    local count = 0;
    for i = 1 , num do
        local curCoin = gold:clone();
        curCoin:setScale(math.random(70, 120)/100);
        self.m_anim_layer:addChild(curCoin);
        curCoin:setPosition(cc.p(math.random(5, 95)/100*display.width, 1*display.height));
        local posX = math.random(20, 80);
        local angel = math.random(40, 80);
        if i%2 == 0 then
            posX = -posX;
            angel = -angel;
        else
           
        end
        local rotation = curCoin:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.1, angel)));
        --
        local time1 = math.random(40, 60)/100;
        
        local pos1Y = math.random(10, 30)/100*display.height;
        local pos2Y = pos1Y/2;
        local time2 = pos1Y/1000;
        local time3 = time2/2;
        
        transition.execute(curCoin, cc.EaseIn:create(cc.MoveBy:create(time1, cc.p(0, -display.height)), 2),{
            onComplete = function ()
                transition.execute(curCoin, cc.EaseOut:create(cc.MoveBy:create(time2, cc.p(posX, pos1Y)), 2),{
                    onComplete = function ()
                        transition.execute(curCoin, cc.EaseIn:create(cc.MoveBy:create(time2, cc.p(0, -pos1Y)), 2),{
                            onComplete = function ()
                                transition.execute(curCoin, cc.EaseOut:create(cc.MoveBy:create(time3, cc.p(posX/2, pos2Y)), 2),{
                                    onComplete = function ()
                                        transition.execute(curCoin, cc.EaseIn:create(cc.MoveBy:create(time3, cc.p(0, -pos2Y)), 2),{
                                            onComplete = function ()
                                                curCoin:stopAction(rotation);
                                                count = count + 1;
                                                if count == num then
                                                    display.getRunningScene():removeChild(self.m_anim_layer);
                                                end
                                            end
                                        });
                                    end
                                });
                            end
                        });
                    end
                });
            end
        });
    end
end