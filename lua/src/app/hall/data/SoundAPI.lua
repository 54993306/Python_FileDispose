--SoundAPI
local SoundAPI = class("SoundAPI")

function SoundAPI:ctor( )

end

--desc:播放音效
--param sSoundPath{string} 播放路径
--param isLoop{bool} 是否循环
function SoundAPI:playSound(sSoundPath, isLoop)
    SoundManager.playEffect(sSoundPath, isLoop)
end

--:停止所有音效
function SoundAPI:stopAllSound()
    audio.stopAllSounds()
end

--desc:播放背景音乐
--param sMusicPath{string} 播放路径
--param isLoop{bool} 是否循环
--朋友开房入参无效
function SoundAPI:playMusic(sSoundPath, isLoop)
	audio.stopMusic();
	audio.playMusic(sSoundPath, isLoop)
end


--:停止背景音乐
function SoundAPI:stopMusic()
    audio.stopMusic()
end


--:停止背景音乐
function SoundAPI:preloadMusic(filename)
    audio.preloadMusic(filename)
end

--是否正在播放背景音乐
function SoundAPI:isMusicPlaying()
	return audio.isMusicPlaying()
end

--停止所有音效
function SoundAPI:stopAllSounds()
	audio.stopAllSounds()
end

--暂停背景音乐
function SoundAPI:pauseMusic()
	audio.pauseMusic()
end

--开启背景音乐
function SoundAPI:resumeMusic()
	audio.resumeMusic()
end

--设置音效音量
function SoundAPI:setSoundVolume(nVolume)
	SettingInfo.getInstance():setGameSoundValue(nVolume)
end
--获得音效音量
function SoundAPI:getSoundVolume()
	return SettingInfo.getInstance():getGameSoundValue()
end

--设置音乐音量
function SoundAPI:setMusicVolume(nVolume)
	SettingInfo.getInstance():setGameMusicValue(nVolume)
end
--获得音乐音量
function SoundAPI:getMusicVolume()
	return SettingInfo.getInstance():getGameMusicValue()
end


--设置音效静音
function SoundAPI:setSoundMute(isMute)
	local nVolume = isMute and 0 or 50
	audio.setSoundsVolume(nVolume)
	kSettingInfo:setSoundStatus(not isMute)
end

function SoundAPI:getSoundMute()
	return kSettingInfo:getSoundStatus()
end

--设置音乐静音
function SoundAPI:setMusicMute(isMute)
	local nVolume = isMute and 0 or 80
	audio.setMusicVolume(nVolume)
	kSettingInfo:setMusicStatus(not isMute)
end

function SoundAPI:getMusicMute()
	return kSettingInfo:getMusicStatus()
end


function SoundAPI:setGameVoiceStatus( status )
	return SettingInfo.getInstance():setGameVoiceStatus(status)
end


return SoundAPI