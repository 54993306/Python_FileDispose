--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Profiler = require("app.common.profiler")

local MjGameScene = class("MjGameScene", function ()
    local scene = cc.Scene:create()
    scene:setAutoCleanupEnabled()
    scene:setNodeEventEnabled(true)
    scene:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    scene:setName("MjGameScene")
    return scene
end)
local UmengClickEvent = require("app.common.UmengClickEvent")


function MjGameScene:ctor(data)
    self.m_date = data;
    cc.Director:getInstance():setAnimationInterval(1/60);
    cc(self):addComponent("app.games.common.components.SingleTouchSwallow"):exportMethods()
end

--返回键
function MjGameScene:onKeyboard(code, event)
    Log.i("------MainScene:onKeyboard code", code);
    if code == cc.KeyCode.KEY_BACK then
        UIManager.getInstance():disPatchKeyBackEvent();
        if self.m_runningScene then
            self.m_runningScene:onKeyboard();
        end
        if IsPortrait then -- TODO
            self:onEnterForeground()
        end
    end
end

function MjGameScene:onEnterBackGround()
    Log.i("-----MjGameScene:onEnterBackGround")
    if device.platform == "ios" then
        audio.stopMusic()
    else
        if kSettingInfo:getMusicStatus() == true then
            audio:pauseMusic()
        end
    end
end

function MjGameScene:onEnterForeground()
    Log.i("-----MjGameScene:onEnterForeground")
    if device.platform == "ios" then
        audio.playMusic(_gameBgMusicPath, true)
    else
        if kSettingInfo:getMusicStatus() == true then
            if audio.willPlayMusic() then
                audio.resumeMusic()
            else
                _playGameMusic();
            end
        end
    end
    MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_SET_ENTER_FOREGROUND_NTF)
end

function MjGameScene:onEnter()
    Log.i("MjGameScene:onEnter....",self.m_date)
    self:regSwallowTouchEvent()

    if not self.m_add then
        self.m_add = true;
        --朋友开房逻辑特殊处理
        if kFriendRoomInfo:isFriendRoom() then
            Log.i("当前游戏是从朋友开房进入")
            --
            local data ={}
            data.startGameWay = StartGameType.FIRENDROOM;
            data.m_delegate = self;
            data.roomGameType = FriendRoomGameType.MJ; --麻将游戏
            self.m_friendOpenRoom = OpenRoomGame.new(data)
        end
        MjMediator.getInstance():onGameEntryComplete(self.m_date);

        local keyListener = cc.EventListenerKeyboard:create();
        keyListener:registerScriptHandler(handler(self, self.onKeyboard), cc.Handler.EVENT_KEYBOARD_RELEASED);
        local eventDispatch = self:getEventDispatcher();
        eventDispatch:addEventListenerWithSceneGraphPriority(keyListener, self);
    end

    SocketManager.getInstance():reStartReceivePacket();
    SettingInfo.getInstance():setSelectAreaGameID(kFriendRoomInfo:getGameID())

    if not VideotapeManager.getInstance():isPlayingVideo() then
        self:addDismissBtn()
    end

    self.profiler = Profiler.new()
    -- 启动
    -- self.profiler:start("call")
    -- self.msgThread = scheduler.scheduleGlobal(function() 
    --     self:drawProFiler()
    -- end,20);
    -- self:drawProFiler()
    -- if true then
    --     Log.i("GameEngine:AddLoggerWindow")
    --     LoggerWindow:getInstance():removeFromParent()
    --     MjMediator:getInstance()._gameLayer:addChild(LoggerWindow:getInstance(), 99999)
    -- end
end

function MjGameScene:drawProFiler()
    self.profiler:stop("call")
    self.profiler:start("call")
end

function MjGameScene:addDismissBtn(  )
    self.dismiss_btn = ccui.Button:create()
    self.dismiss_btn:loadTextureNormal("games/common/game/games/menu_btn_jieshan.png")

    self.dismiss_btn:setPosition(cc.p(display.width -60, display.height - 135))
    self.dismiss_btn:addTo(self)
    self.dismiss_btn:addTouchEventListener(handler(self, self.onClickedQuitCallBack))
    self.dismiss_btn:setTouchEnabled(true)
end

function MjGameScene:onClickedQuitCallBack(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
        if not IsPortrait then -- TODO
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameDismiss)
        end

        local data = {}
        data.type = 2
        data.content = "确认申请解散牌局吗？\n解散后按目前得分最终排名。"
        data.switchBtn = true
        data.yesCallback = function() 
        --[[
            type = 2,code=22020, 私有房解散牌局问询  client  <-->  server
            ##  usI  long  玩家id
            ##  re  int  结果(-1:没有问询   0:还没有回应   1:同意  2:不同意)
            ##  niN  String  发起的用户昵称
            ##  isF  int  是否是刚发起的问询, 如果是刚发起的需要起定时器(0:是  1:不是)]]
            local tmpData={}
            tmpData.usI =  kUserInfo:getUserId()
            tmpData.re = 1
            tmpData.niN = kUserInfo:getUserName()
            tmpData.isF = 0
            SocketManager.getInstance():send(CODE_TYPE_ROOM, HallSocketCmd.CODE_FRIEND_ROOM_LEAVE,tmpData);
            Log.i("press GameAskDismiss")
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameAskDismiss)
        end

        data.cancalCallback = function()
            Log.i("press GameContinue")
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameContinue)
        end

        data.closeCallback = function()
            Log.i("press GameContinue")
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameContinue)
        end

        data.switchBtn = true                           --互换按钮位置
        data.yesStr = "申请解散"                               --确定按钮文本
        data.cancalStr = "继续游戏"                            --取消按钮文本
        UIManager:getInstance():pushWnd(CommonDialog, data)   
    end
end

function MjGameScene:onExit()
  Log.i("MjGameScene:onExit()..............");
  self:releaseSwallowTouchEvent()
  --朋友开房逻辑特殊处理
  if(self.m_friendOpenRoom~=nil) then
	   self.m_friendOpenRoom:dtor();
	   self.m_friendOpenRoom=nil
  end
end

function MjGameScene:setRunningLayer(layer)
    self.m_runningScene = layer
end

return MjGameScene

--endregion