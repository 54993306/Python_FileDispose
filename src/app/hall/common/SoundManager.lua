SoundManager = {};

--大厅音效
local sound_config ={
    ["btn"] = "btn_click",--按钮音效
    ["dialog_pop"] = "dialog_pop",--对话框弹出
    ["gold_rain"] = "gold_rain",--金币雨
}

--游戏音效
_gameAudioEffectCfg = {};

--音效句柄
SoundManager.handles = {};
SoundManager.isStartGame = false;

--暂停一下自动恢复（用于游戏从后台回到前台）
SoundManager.pauseMoment = function(time)
    if SoundManager.m_pauseScheduler then
        scheduler.unscheduleGlobal(SoundManager.m_pauseScheduler);
        SoundManager.m_pauseScheduler = nil;
    end
    SoundManager.m_isPause = true
    SoundManager.m_pauseScheduler = scheduler.performWithDelayGlobal(function ()
        SoundManager.m_isPause = false;
    end, time or 1);
end

--播放音效
SoundManager.playEffect = function(effectName, isLoop)
    if SoundManager.m_isPause then
        return;
    end
    local fileName = nil;
    -- 由于声音控制是整个游戏的所以在这里判断如果状态是禁止直接返回
    if not kSettingInfo:getSoundStatus() then
        return;
    end
    --print( debug.traceback())
	Log.i("------播放音效" .. effectName)

    if cc.FileUtils:getInstance():isFileExist(effectName) then
        fileName = effectName
    end

    local isChatFlag = false
    if IsPortrait then -- TODO
        isChatFlag = string.find(effectName, "liaotianyongyu")
    end
    if kSettingInfo:getGameDialectStatus() or isChatFlag then
        if not fileName and _gameAudioEffectCfg[effectName] and _gameDialectAudioEffectPath then
            local dialectFileName = _gameDialectAudioEffectPath .. _gameAudioEffectCfg[effectName] .. ".mp3";
            if io.exists(cc.FileUtils:getInstance():fullPathForFilename(dialectFileName)) then
                fileName = dialectFileName
            end
        end
    end

    if not fileName and _gameAudioEffectCfg[effectName] then
        local gamePtfileName = _gameAudioEffectPath .. _gameAudioEffectCfg[effectName] .. ".mp3";
        if cc.FileUtils:getInstance():isFileExist(gamePtfileName) then
            fileName = gamePtfileName
        end
    end
    if not fileName and _gameCommonAudioEffectCfg and _gameCommonAudioEffectCfg[effectName] then
        fileName = _gameCommonAudioEffectPath .. _gameCommonAudioEffectCfg[effectName] .. ".mp3";
    end
    if not fileName and sound_config[effectName] then
        fileName = "hall/audio/mp3/effect/" .. sound_config[effectName] .. ".mp3";
    end
    Log.i("------SoundManager.playEffect fileName", fileName);
    return audio.playSound(fileName, isLoop);
end

--循环播放音效
SoundManager.playEffectLoop = function (effectName)
    if not kSettingInfo:getSoundStatus() then
        return;
    end
    SoundManager.handles[effectName] = SoundManager.playEffect(effectName, nil, true);

end

--关闭循环播放的音效
SoundManager.stopEffect = function (effectName)
    Log.i("------stopEffect", effectName);
    if SoundManager.handles[effectName] then
        Log.i("------stopEffect", effectName);
        audio.stopSound(SoundManager.handles[effectName]);
        SoundManager.handles[effectName] = nil;
    end
end
