--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
AnimationManager = {}

AnimationManager.runAction = function(data)
    Log.i("AnimationManager.runAction....",data)
    --动画依附的精灵
    local sprite = data.sprite
    --动画的图片名称前缀
    local imageName = data.imageName
    --动画的总共帧数
    local frame = data.frame
    --动画播放几秒
    local delayTime = data.delayTime
    --循环播放的间隔时间（不传值则不循环）
    local delay = data.delay
    --第一帧动画的起始数
    local startframenum = data.sfn
    --动画的命名规则
    local frameNum = data.fn
    local frames = display.newFrames(imageName.."_"..frameNum,startframenum,frame)
    local animation = display.newAnimation(frames, delayTime / frame) -- 0.5s play 20 frames

    local animate = cc.Animate:create(animation)
    local action
    if delay ~= nil then
        if type(delay) == "number" and delay > 0 then
    --        sprite:setVisible(false)
            local sequence = transition.sequence({
                animate,
                cc.DelayTime:create(delay),
            })
            action = cc.RepeatForever:create(sequence)
        else
            action = cc.RepeatForever:create(animate)
        end
    else
        action = animate
    end
    -- sprite:setBlendFunc(_G.ONE_MINUS_SRC_ALPHA, _G.GL_ONE_MINUS_SRC_COLOR)
    sprite:runAction(action)
end

--endregion
