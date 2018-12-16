--
-- Author: Jinds
-- Date: 2017-10-31 12:22:20
--
PokerSoundPlayer = class("PokerSoundPlayer");

PokerSoundPlayer.getInstance = function()
    if not PokerSoundPlayer.s_instance then
        PokerSoundPlayer.s_instance = PokerSoundPlayer.new();
    end

    return PokerSoundPlayer.s_instance;
end

PokerSoundPlayer.releaseInstance = function()
    if PokerSoundPlayer.s_instance then
        PokerSoundPlayer.s_instance:dtor();
    end
    PokerSoundPlayer.s_instance = nil;
end

--设置音效播放路径文件夹、音效路径映射、背景音乐路径  每个游戏初始化时都需要设置一下
function PokerSoundPlayer:setEffectCfg(rootpath, map, bgpath)
	Log.i("PokerSoundPlayer:setEffectCfg :", rootpath)
	self.rootpath = rootpath
	self.effMap = map or {}
	self.musicName = bgpath.. ".mp3"
end

--播放音效
function PokerSoundPlayer:playEffect(effectName, isLoop)
    -- print(debug.traceback())
    Log.i("------播放音效" ,effectName)
	Log.i("------播放音效" ,self.effMap[effectName])
    local eff = self.effMap[effectName]["path"]
    Log.i("------播放音效" ,eff)
    local fileName
    if not fileName and self.effMap[effectName] then
        fileName = self.rootpath .. eff .. ".mp3";
    end

    Log.i("------PokerSoundPlayer.playEffect fileName", fileName);
    if fileName and HallAPI.SoundAPI:getSoundVolume() > 0 then
        if isLoop then
            HallAPI.SoundAPI:playSound(fileName, true);
        else
            HallAPI.SoundAPI:playSound(fileName, false);
        end
    else
    	Log.i("effect not found ", effectName)
    end
end

--播放背景音乐
function PokerSoundPlayer:playBGMusic(musicName, isLoop)
	if not musicName then
		HallAPI.SoundAPI:playMusic(self.musicName, true)	
	else
		HallAPI.SoundAPI:playMusic(musicName, isLoop)
	end
end

kPokerSoundPlayer =  PokerSoundPlayer.getInstance()