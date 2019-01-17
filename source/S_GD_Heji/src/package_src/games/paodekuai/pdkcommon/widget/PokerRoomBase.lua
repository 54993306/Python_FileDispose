--
-- Author: Machine
-- Date: 2018-01-18
-- 扑克房间的公共基类
--

local PokerRoomBase = class("PokerRoomBase", PokerUIWndBase);
local PokerCommonSocketCmd = require("package_src.games.paodekuai.pdkcommon.data.PokerCommonSocketCmd")
local PokerDataConst = require("package_src.games.paodekuai.pdkcommon.data.PokerDataConst")
local PokerRoomDialogView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomDialogView")
local PokerDismissDeskView = require("package_src.games.paodekuai.pdkcommon.widget.PokerDismissDeskView")
local UmengClickEvent = require("app.common.UmengClickEvent")

PokerRoomBase._selectBtn = {
    agree = false,
    agreeTime = 0.5,
}

function PokerRoomBase:ctor(...)
    PokerRoomBase.super.ctor(self, ...)

    self.m_maintainCode = "009" -- 维护提示框代码

    -- 网络重连框重连回调
    self.m_netDialogYesCallback = function ()
        Log.i("PokerRoomBase.m_netDialogYesCallback")
        SocketManager.getInstance():addDDZCloseSocket(false)
        SocketManager.getInstance():onConnectException()
    end
    -- 网络重连框退出回调
    self.m_netDialogCloseCallback = function ()
        Log.i("PokerRoomBase.m_netDialogCloseCallback")
        self:onExitRoom();
        SocketManager.getInstance():addDDZCloseSocket(false);
        DataMgr:getInstance():init()
    end
    -- 网络退出框退出回调
    self.m_netDialogCancalCallback = self.m_netDialogCloseCallback
end

----------------------------------------------
-- @desc 解散房间处理
----------------------------------------------
function PokerRoomBase:jiesanBtnEvent()
   local data = {}
    data.type = 2
    data.content = "确认申请解散牌局吗？\n解散后按目前得分最终排名。"
    data.yesCallback = function()
    --[[
        type = 2,code=22020, 私有房解散牌局问询  client  <-->  server
        ##  usI  long  玩家id
        ##  re  int  结果(-1:没有问询   0:还没有回应   1:同意  2:不同意)
        ##  niN  String  发起的用户昵称
        ##  isF  int  是否是刚发起的问询, 如果是刚发起的需要起定时器(0:是  1:不是)]]
        if self._selectBtn.agree == false then
            local tmpData={}
            tmpData.usI =  HallAPI.DataAPI:getUserId()
            tmpData.re = 1
            tmpData.niN = HallAPI.DataAPI:getUserName()
            tmpData.isF = 0
            HallAPI.DataAPI:send(CODE_TYPE_ROOM, PokerCommonSocketCmd.CODE_FRIEND_ROOM_LEAVE,tmpData);
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.PDKGameAskDismiss)
            self._selectBtn.agree = true
            if not tolua.isnull(self.btn_jiesan) then
                self.btn_jiesan:runAction(cc.Sequence:create(cc.DelayTime:create(self._selectBtn.agreeTime),cc.CallFunc:create(function() self._selectBtn.agree = false end)))
            end
        end
    end

    data.cancelCallback = function()
        NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.PDKGameContinue)
    end

    data.yesStr = "申请解散"                               --确定按钮文本
    data.cancalStr = "继续游戏"                            --取消按钮文本
    local cDialog = PokerUIManager:getInstance():pushWnd(PokerRoomDialogView, data, 100)
end

----------------------------------------------
-- @desc 收到请求解散消息
-- @pram packetInfo :网络消息
----------------------------------------------
function PokerRoomBase:onRecvReqDismiss(packetInfo)
    local dismissDeskView = PokerUIManager.getInstance():getWnd(PokerDismissDeskView);
    if dismissDeskView == nil then
        dismissDeskView = PokerUIManager:getInstance():pushWnd(PokerDismissDeskView, nil, 100, self)
    end
    local commonDialog = PokerUIManager.getInstance():getWnd(PokerRoomDialogView);
    local dismissDeskViewLocalZOrder
    if commonDialog ~=nil then
        dismissDeskViewLocalZOrder = commonDialog.m_pBaseNode:getLocalZOrder()
        PokerUIManager.getInstance():popWnd(commonDialog)
    else
        dismissDeskViewLocalZOrder = dismissDeskView.m_pBaseNode:getLocalZOrder()
    end
    dismissDeskView.m_pBaseNode:setLocalZOrder(dismissDeskViewLocalZOrder+1)
    dismissDeskView:updateUI(packetInfo)
end

----------------------------------------------
-- @desc 收到解散结果
-- @pram packetInfo :网络消息
----------------------------------------------
function PokerRoomBase:onRecvDismissEnd(packetInfo)
    Log.i("PokerRoomBase:onRecvDismissEnd", packetInfo)
    local dismissDeskView = PokerUIManager.getInstance():getWnd(PokerDismissDeskView);
    if dismissDeskView ~= nil then
        PokerUIManager.getInstance():popWnd(PokerDismissDeskView);
    end
    Log.i("self.m_isShowGameOverUI")
    if self.m_isShowGameOverUI then--如果已经显示结算UI
        -- self:onRecvRoomEnd(packetInfo)
    else
        if packetInfo.ty ~= 1 and (packetInfo.ty ~= 0) then --后台强制结束时候发来的是0
            self:onRecvRoomEnd(packetInfo);
        end
    end
end

----------------------------------------------
-- @desc 显示总结算界面
-- @pram packetInfo :网络消息
----------------------------------------------
function PokerRoomBase:onRecvRoomEnd(packetInfo)
    local data = {}
    data.type = 1;
    data.title = "提示";
    data.content = packetInfo.ti;
    data.yesCallback = function ()
        self:gameOverUICallBack();
    end
    PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data)
end

----------------------------------------------
--回调,查看总战绩
----------------------------------------------
function PokerRoomBase:gameOverUICallBack()
    local totalData = DataMgr.getInstance():getObjectByKey(PokerDataConst.DataMgrKey_FRIENDTOTALDATA)
    if totalData == nil then
        self:onExitRoom();
    else
        self:OnRecvRoomReWard()
        DataMgr.getInstance():setObject(PokerDataConst.DataMgrKey_FRIENDTOTALDATA, nil)
    end
end

----------------------------------------------
-- @desc 网络弱
----------------------------------------------
function PokerRoomBase:onNetWorkWeak()
    Log.i("------PokerRoomBase:onNetWorkWeak");
    HallAPI.ViewAPI:hideLoadingView("networkState")
    HallAPI.ViewAPI:releaseLoadingView()
    HallAPI.ViewAPI:showLoadingView("您当前的网络不稳定，请检查您的网络", 1000, true, "networkState")
end
----------------------------------------------

-- @desc 网络正常隐藏转圈
 ----------------------------------------------
function PokerRoomBase:onNetWorkConnectHealthly()
    Log.i("------PokerRoomBase:onNetWorkConnectHealthly");
    HallAPI.ViewAPI:hideLoadingView("networkState")
end

----------------------------------------------
-- @desc 网络重连成功
----------------------------------------------
function PokerRoomBase:onNetWorkReconnected()
    Log.i("------PokerRoomBase:onNetWorkReconnected")
    if kLoginInfo:requestLogin() then
        self.m_pWidget:performWithDelay(function()
            HallAPI.ViewAPI:hideLoadingView()

            local dismissDeskView = PokerUIManager.getInstance():getWnd(PokerDismissDeskView)
            if dismissDeskView ~= nil then
                PokerUIManager.getInstance():popWnd(PokerDismissDeskView)
            end

            PokerToast.getInstance():show("网络已连接");

            local data = {};
            data.plID = DataMgr:getInstance():getObjectByKey(PokerDataConst.DataMgrKey_GAMEPLAYID)
            HallAPI.DataAPI:send(CODE_TYPE_GAME, PokerCommonSocketCmd.CODE_SEND_RESUMEGAME,  data);

        end, 1);
    end
end

----------------------------------------------
-- @desc 网络关闭
----------------------------------------------
function PokerRoomBase:onNetWorkClosed(event)
    Log.i("------PokerRoomBase:onNetWorkClosed")
    -- dump(event)
    --print(debug.traceback())
    self:showNetWorkClosedNotify("网络异常，请检查您的网络是否正常再进入游戏！代码-010", kLoginInfo:isServerMaintain(), event._forceReturnToLogin)
end

----------------------------------------------
-- @desc 网络连通失败
----------------------------------------------
function PokerRoomBase:onNetWorkConnectFail()
    Log.i("------PokerRoomBase:onNetWorkConnectFail");
    self:showNetWorkClosedNotify("连接服务器失败，请检查您的网络是否正常再进入游戏")
end

-- 网络断开通知
function PokerRoomBase:showNetWorkClosedNotify(content, is_maintain, forceReturnToLogin)
    Log.i("PokerRoomBase:showNetWorkClosedNotify(content, is_maintain)", content, is_maintain, tostring(forceReturnToLogin))

    if forceReturnToLogin then
        self:showDialogReturnToLogin("重连失败, 请检查您的网络后重新登录!")
        return
    end

    local commonDialog = PokerUIManager.getInstance():getWnd(PokerRoomDialogView);
    if commonDialog and (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK
        or commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED) then
        return;
    end

    if is_maintain then
        self:showDialogReturnToLogin("服务器即将进行维护！代码" .. self.m_maintainCode)
    else
        self:showDialogRetryConnect(content)
    end
end

-- 弹框提示玩家返回登录界面
function PokerRoomBase:showDialogReturnToLogin(content)
    HallAPI.ViewAPI:hideLoadingView()
    HallAPI.ViewAPI:hideLoadingView("networkState")
    SocketManager.getInstance():addDDZCloseSocket(true)
    SocketManager.getInstance():closeSocket()

    local data = {}
    data.title = "提示";
    data.contentType = COMNONDIALOG_TYPE_NETWORK;
    data.content = content

    data.type = 1;

    data.yesCallback = self.m_netDialogCloseCallback

    PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data)
end

-- 弹框提示玩家重新连接
function PokerRoomBase:showDialogRetryConnect(content)
    HallAPI.ViewAPI:hideLoadingView()
    HallAPI.ViewAPI:hideLoadingView("networkState")
    SocketManager.getInstance():addDDZCloseSocket(true)
    SocketManager.getInstance():closeSocket()

    local data = {}
    data.title = "提示";
    data.contentType = COMNONDIALOG_TYPE_NETWORK;
    data.content = content

    data.type = 2

    data.yesCallback = self.m_netDialogYesCallback
    data.yesTitlePath = "package_res/games/pokercommon/image/image_reconnect.png"
    data.yesTitlePathType = ccui.TextureResType.localType

    data.cancelCallback = self.m_netDialogCancalCallback
    data.cancelTitlePath = "package_res/games/pokercommon/image/image_quit.png"
    data.cancelTitlePathType = ccui.TextureResType.localType

    PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data)
end

----------------------------------------------
-- @desc 网络异常
----------------------------------------------
function PokerRoomBase:onNetWorkException()
    Log.i("------PokerRoomBase:onNetWorkException");
    HallAPI.ViewAPI:hideLoadingView("networkState")
    HallAPI.ViewAPI:releaseLoadingView()
    HallAPI.ViewAPI:showLoadingView("网络异常，正在重连...", 1000, true, "networkState")
end

---------------------------------------
-- 函数功能：    退出到大厅
-- 返回值：      无
---------------------------------------
function PokerRoomBase:onExitRoom()
    PokerUIManager.getInstance():popAllWnd(true);
    PokerUIManager.getInstance():recoverToDesignOrient()
    cc.Director:getInstance():popScene();
end

return PokerRoomBase
