--游戏动画层

local Define = require "app.games.common.Define"

AnimLayer = class("AnimLayer")

function AnimLayer:ctor()
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/null_layer.csb");

    self.handlers = {}
    -- 定缺动画
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(MJ_EVENT.GAME_dingque_Anim_start, 
        handler(self, self.onDingqueAnimStart)))
end

function AnimLayer:getView()
    return self.m_pWidget;
end

function AnimLayer:setDelegate(delegate)
    self.m_delegate = delegate;
end

function AnimLayer:onDingqueAnimStart(event)
    Log.i("------onDingqueAnimStart event", unpack(event._userdata));
    local result, site, srcPoint, desPoint = unpack(event._userdata);
    local resultImg = nil;
    if site == 1 and not VideotapeManager.getInstance():isPlayingVideo() then
        if result == 1 then
            resultImg = ccui.ImageView:create("real_res/1004191.png");
        elseif result == 2 then
            resultImg = ccui.ImageView:create("real_res/1004189.png");
        elseif result == 3 then
            resultImg = ccui.ImageView:create("real_res/1004190.png");
        end
    else
        if result == 1 then
            resultImg = ccui.ImageView:create("real_res/1004198.png");
        elseif result == 2 then
            resultImg = ccui.ImageView:create("real_res/1004196.png");
        elseif result == 3 then
            resultImg = ccui.ImageView:create("real_res/1004197.png");
        end
    end
    if not resultImg then
        return;
    end
    resultImg:setPosition(srcPoint);
    self.m_pWidget:addChild(resultImg);
    --self.m_pWidget:runAction(action)
    resultImg:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.5, desPoint),
        cc.CallFunc:create(function ()
            resultImg:removeFromParent()
            resultImg = nil;
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(MJ_EVENT.GAME_dingque_Anim_finsh, result, site);
        end)
        )
    )
end

function AnimLayer:onClose()
    -- 移除监听
    table.walk(self.handlers, function(h)
        MjMediator.getInstance():getEventServer():removeEventListener(h)
    end)
    self.handlers = {}
end

return AnimLayer