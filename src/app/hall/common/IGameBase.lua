--游戏基类
IGameBase = class("IGameBase")

--构造函数
function IGameBase:ctor(tmpData)
	Log.i("IGameBase:ctor")
	self.m_data=tmpData
end

--析构函数
function IGameBase:dtor()
   Log.i("IGameBase:dtor")
end

--游戏初始化
function IGameBase:init()
 Log.i("IGameBase:init")
end

--开始游戏
function IGameBase:starGame()
 Log.i("IGameBase:starGame")
end

--游戏进行中
function IGameBase:gameDoing()
 Log.i("IGameBase:gameDoing")
end

--结束游戏
function IGameBase:endGame()
 Log.i("IGameBase:endGame")
end

--下一轮/下一局 游戏
function IGameBase:nextRoundGame()
 Log.i("IGameBase:nextRoundGame")
end

--手动点击退出游戏
function IGameBase:quitGame()
 Log.i("IGameBase:quitGame")
end

